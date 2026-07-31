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

import org.adempiere.base.event.AbstractEventHandler;
import org.adempiere.base.event.IEventTopics;
import org.compiere.model.I_AD_PrintFormat;
import org.compiere.model.PO;
import org.compiere.util.CLogger;
import org.compiere.util.DB;
import org.idempiere.print.template.model.I_AD_PrintTemplate;
import org.osgi.service.event.Event;

/**
 * UX de um campo só: quando o usuário preenche AD_PrintTemplate_ID no
 * AD_PrintFormat, este delegate seta o JasperProcess_ID pro processo
 * ponte ({@link TemplateReportStarter}); quando limpa o template,
 * limpa a ponte junto — sem tocar num Jasper "de verdade" apontado
 * manualmente.
 *
 * Degrada graceful antes do 2Pack: se a coluna AD_PrintTemplate_ID
 * ainda não existe no dicionário, o evento é ignorado.
 *
 * Spec: riskora/docs/SPEC_IDEMPIERE_PRINT_TEMPLATE_ENGINE.md §8.3
 */
public class PrintFormatEventDelegate extends AbstractEventHandler {

	private static final CLogger log = CLogger.getCLogger(PrintFormatEventDelegate.class);

	@Override
	protected void initialize() {
		registerTableEvent(IEventTopics.PO_BEFORE_NEW, I_AD_PrintFormat.Table_Name);
		registerTableEvent(IEventTopics.PO_BEFORE_CHANGE, I_AD_PrintFormat.Table_Name);
	}

	@Override
	protected void doHandleEvent(Event event) {
		PO po = getPO(event);
		if (po.get_ColumnIndex(I_AD_PrintTemplate.COLUMNNAME_AD_PrintTemplate_ID) < 0)
			return; // 2Pack ainda não aplicado

		int templateId = po.get_ValueAsInt(I_AD_PrintTemplate.COLUMNNAME_AD_PrintTemplate_ID);
		int jasperId = po.get_ValueAsInt(I_AD_PrintFormat.COLUMNNAME_JasperProcess_ID);
		int bridgeId = getBridgeProcessId();
		if (bridgeId <= 0) {
			if (templateId > 0)
				log.warning("AD_Process ponte '" + TemplateReportStarter.PROCESS_VALUE
						+ "' não encontrado — template não será renderizado");
			return;
		}

		if (templateId > 0 && jasperId != bridgeId) {
			po.set_ValueOfColumn(I_AD_PrintFormat.COLUMNNAME_JasperProcess_ID, Integer.valueOf(bridgeId));
		} else if (templateId <= 0 && jasperId == bridgeId) {
			// só limpa se era a ponte — Jasper legítimo fica intacto
			po.set_ValueOfColumn(I_AD_PrintFormat.COLUMNNAME_JasperProcess_ID, null);
		}
	}

	private int getBridgeProcessId() {
		return DB.getSQLValueEx(null,
				"SELECT AD_Process_ID FROM AD_Process WHERE Value=? AND IsActive='Y'",
				TemplateReportStarter.PROCESS_VALUE);
	}
}
