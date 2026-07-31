/**********************************************************************
* This file is part of the iDempiere Print Template Engine plugin.    *
*                                                                     *
* This program is free software; you can redistribute it and/or       *
* modify it under the terms of the GNU General Public License         *
* as published by the Free Software Foundation; either version 2      *
* of the License, or (at your option) any later version.              *
*                                                                     *
* This program is distributed in the hope that it will be useful,     *
* but WITHOUT ANY WARRANTY; without even the implied warranty of      *
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the        *
* GNU General Public License for more details.                        *
**********************************************************************/
package org.idempiere.print.template;

import java.io.File;
import java.nio.file.Files;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.model.PrintInfo;
import org.compiere.print.MPrintFormat;
import org.compiere.print.ServerReportCtl;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.process.SvrProcess;
import org.idempiere.print.template.model.I_AD_PrintTemplate;
import org.idempiere.print.template.model.MPrintTemplate;

/**
 * Processo ponte ("report starter") do print template engine — papel
 * idêntico ao ReportStarter do Jasper: o AD_PrintFormat aponta este
 * processo via JasperProcess_ID (auto-setado pelo
 * {@link PrintFormatEventDelegate}) e o desvio genérico do
 * ReportEngine/ServerReportCtl entrega PARAM_PRINT_FORMAT /
 * PARAM_PRINT_INFO / PARAM_PRINTER_NAME aqui.
 *
 * Saída: arquivo renderizado entregue via IProcessUI.download (UI) e
 * ProcessInfo.setExportFile (batch/scheduler).
 *
 * Spec: riskora/docs/SPEC_IDEMPIERE_PRINT_TEMPLATE_ENGINE.md §5.2/§8.1
 */
public class TemplateReportStarter extends SvrProcess {

	/** AD_Process.Value do processo ponte — lookup sempre por Value, nunca por ID (§6.6) */
	public static final String PROCESS_VALUE = "PrintTemplate_ReportStarter";

	private MPrintFormat printFormat;
	private PrintInfo printInfo;

	@Override
	protected void prepare() {
		ProcessInfoParameter[] params = getParameter();
		if (params == null)
			return;
		for (ProcessInfoParameter param : params) {
			if (ServerReportCtl.PARAM_PRINT_FORMAT.equals(param.getParameterName()))
				printFormat = (MPrintFormat) param.getParameter();
			else if (ServerReportCtl.PARAM_PRINT_INFO.equals(param.getParameterName()))
				printInfo = (PrintInfo) param.getParameter();
		}
	}

	@Override
	protected String doIt() throws Exception {
		if (printFormat == null)
			throw new AdempiereException("Print Template: PARAM_PRINT_FORMAT não recebido — este processo só deve ser executado pelo desvio de impressão (JasperProcess_ID)");

		int templateId = printFormat.get_ValueAsInt(I_AD_PrintTemplate.COLUMNNAME_AD_PrintTemplate_ID);
		if (templateId <= 0)
			throw new AdempiereException("Print Template: o print format " + printFormat.getName()
					+ " aponta a ponte mas não tem AD_PrintTemplate_ID — limpe o JasperProcess_ID ou selecione um template");

		MPrintTemplate template = MPrintTemplate.get(getCtx(), templateId);
		if (template == null || !template.isActive())
			throw new AdempiereException("Print Template: template " + templateId + " inexistente ou inativo");

		PO targetPO = resolveTargetPO();
		if (template.getAD_Table_ID() > 0 && template.getAD_Table_ID() != targetPO.get_Table_ID())
			throw new AdempiereException("Print Template: template '" + template.getName()
					+ "' espera a tabela " + MTable.get(getCtx(), template.getAD_Table_ID()).getTableName()
					+ ", mas o registro é de " + targetPO.get_TableName());

		// Decisão ÚNICA de formato: tipo pedido no viewer (ReportType) manda;
		// senão QUALQUER sinal do template basta (extension pdf OU content type
		// application/pdf OU Binary Output) — três campos redundantes exigidos
		// juntos era arma de misconfiguração (HTML dentro de .pdf).
		String extension = TemplateRenderDispatcher.resolveOutputExtension(
				getProcessInfo().getReportType(), template);
		File outputDir = Files.createTempDirectory("printtemplate").toFile();
		File outputFile = new File(outputDir, sanitizeFileName(template.getName())
				+ "_" + targetPO.get_ID() + "." + extension);

		boolean handled = TemplateRenderDispatcher.render(template, targetPO, outputFile, extension);
		if (!handled)
			throw new AdempiereException("Print Template: engine '" + template.getTemplateEngineType()
					+ "' sem renderer instalado — instale o plugin correspondente ou troque o engine do template");

		getProcessInfo().setExportFile(outputFile);
		getProcessInfo().setExportFileExtension(extension);
		if (processUI != null)
			processUI.download(outputFile);

		return "@OK@ - " + template.getName() + " (" + targetPO.get_TableName()
				+ " #" + targetPO.get_ID() + ")";
	}

	private PO resolveTargetPO() {
		if (printInfo == null || printInfo.getAD_Table_ID() <= 0 || printInfo.getRecord_ID() <= 0)
			throw new AdempiereException("Print Template: PARAM_PRINT_INFO sem tabela/registro — renderização exige um documento (registro único)");
		PO po = MTable.get(getCtx(), printInfo.getAD_Table_ID())
				.getPO(printInfo.getRecord_ID(), get_TrxName());
		if (po == null || po.get_ID() != printInfo.getRecord_ID())
			throw new AdempiereException("Print Template: registro " + printInfo.getRecord_ID()
					+ " não encontrado em " + printInfo.getAD_Table_ID());
		return po;
	}

	private String sanitizeFileName(String name) {
		String safe = name.replaceAll("[^a-zA-Z0-9._-]", "_");
		return safe.length() < 3 ? "template_" + safe : safe;
	}
}
