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

import org.adempiere.base.Core;
import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.PO;
import org.compiere.util.CLogger;
import org.idempiere.print.renderer.IReportRenderer;
import org.idempiere.print.renderer.IReportRendererConfiguration;
import org.idempiere.print.template.model.MPrintTemplate;

/**
 * Resolve o {@link IReportRenderer} cujo getId() casa com o
 * TemplateEngineType do template (lookup OSGi via Core) e dispara a
 * renderização. Renderers template-based consomem só a configuração;
 * por isso não precisam do ReportEngine da API de conteúdo.
 *
 * Spec: riskora/docs/SPEC_IDEMPIERE_PRINT_TEMPLATE_ENGINE.md §7.3
 */
public class TemplateRenderDispatcher {

	private static final CLogger log = CLogger.getCLogger(TemplateRenderDispatcher.class);

	private TemplateRenderDispatcher() {}

	/**
	 * Decisão ÚNICA de formato: tipo pedido (viewer/batch, "PDF"/"HTML")
	 * manda; senão QUALQUER sinal do template basta pra pdf (extension,
	 * content type ou Binary Output).
	 */
	public static String resolveOutputExtension(String requestedType, MPrintTemplate template) {
		if ("PDF".equalsIgnoreCase(requestedType))
			return "pdf";
		if ("HTML".equalsIgnoreCase(requestedType))
			return "html";
		if ("pdf".equalsIgnoreCase(template.getOutputFileExtension())
				|| "application/pdf".equalsIgnoreCase(template.getOutputContentType())
				|| template.isBinaryOutput())
			return "pdf";
		String ext = template.getOutputFileExtension();
		return ext == null || ext.isEmpty() ? "html" : ext;
	}

	/**
	 * @return false quando não há renderer registrado pro engine type
	 *         (caller decide a mensagem); demais falhas lançam exceção
	 */
	public static boolean render(MPrintTemplate template, PO targetPO, File outputFile) {
		return render(template, targetPO, outputFile, null);
	}

	/**
	 * @param outputFormat extensão efetiva ("pdf"/"html"); null = default do template
	 */
	public static boolean render(MPrintTemplate template, PO targetPO, File outputFile, String outputFormat) {
		String engineType = template.getTemplateEngineType();
		IReportRenderer<IReportRendererConfiguration> renderer = Core.getReportRenderer(engineType);
		if (renderer == null) {
			log.warning("Nenhum IReportRenderer registrado pra TemplateEngineType=" + engineType);
			return false;
		}

		Class<?> configType = renderer.getConfigurationType();
		if (!TemplateRendererConfiguration.class.isAssignableFrom(configType))
			throw new AdempiereException("Renderer '" + engineType + "' não é template-based (config "
					+ configType.getName() + " não estende TemplateRendererConfiguration)");

		TemplateRendererConfiguration config;
		try {
			config = (TemplateRendererConfiguration) configType
					.getDeclaredConstructor(MPrintTemplate.class, PO.class)
					.newInstance(template, targetPO);
		} catch (ReflectiveOperationException e) {
			throw new AdempiereException("Config do renderer '" + engineType
					+ "' sem construtor (MPrintTemplate, PO)", e);
		}
		config.outputFile(outputFile);
		config.outputFormat(outputFormat);

		renderer.renderReport(null, config);
		return true;
	}
}
