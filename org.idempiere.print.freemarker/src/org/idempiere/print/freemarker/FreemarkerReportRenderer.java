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
package org.idempiere.print.freemarker;

import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.sql.Timestamp;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;

import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.MClient;
import org.compiere.model.MOrg;
import org.compiere.model.PO;
import org.compiere.print.ReportEngine;
import org.compiere.util.Env;
import org.idempiere.print.renderer.IReportRenderer;
import org.idempiere.print.template.HtmlToPdfConverter;
import org.idempiere.print.template.PO2MapBuilder;
import org.idempiere.print.template.model.MPrintTemplate;
import org.idempiere.print.template.model.X_AD_PrintTemplate;

import freemarker.template.Template;

/**
 * Renderer FreeMarker (TemplateEngineType 'FM'). Consome só a
 * configuração — o ReportEngine chega null no fluxo da ponte (§7.3).
 *
 * Data model: colunas do PO (FK como {id, display}) + coleções dos
 * includes + namespace {@code ctx} (client/org/user/idioma/now) +
 * {@code assets} (anexos do template em base64).
 */
public class FreemarkerReportRenderer implements IReportRenderer<FreemarkerReportRendererConfiguration> {

	@Override
	public String getId() {
		return X_AD_PrintTemplate.TEMPLATEENGINETYPE_FreeMarker;
	}

	@Override
	public String getName() {
		return "FreeMarker Template";
	}

	@Override
	public String getContentType() {
		return "text/html";
	}

	@Override
	public String getFileExtension() {
		return "html";
	}

	@Override
	public boolean isBinary() {
		return false;
	}

	@Override
	public Class<FreemarkerReportRendererConfiguration> getConfigurationType() {
		return FreemarkerReportRendererConfiguration.class;
	}

	@Override
	public void renderReport(ReportEngine reportEngine, FreemarkerReportRendererConfiguration config) {
		MPrintTemplate printTemplate = config.getTemplate();
		PO targetPO = config.getPO();
		try {
			Template template = new Template(printTemplate.getName(),
					printTemplate.getTemplateBody(), FreemarkerConfigurationFactory.get());

			Map<String, Object> dataModel = PO2MapBuilder.build(targetPO, printTemplate.getIncludes());
			dataModel.put("ctx", contextMap(targetPO.getCtx()));
			dataModel.put("assets", AssetResolver.asBase64(printTemplate));

			if (isPdfOutput(config, printTemplate)) {
				// Fase 4: FreeMarker → HTML em memória → openhtmltopdf (@page CSS
				// controla tamanho/margens; jsoup tolera HTML não-XHTML)
				StringWriter html = new StringWriter();
				template.process(dataModel, html);
				try (OutputStream output = resolveOutputStream(config)) {
					HtmlToPdfConverter.convert(html.toString(), output);
				}
			} else {
				Writer writer = resolveWriter(config, printTemplate.getTemplateEncoding());
				template.process(dataModel, writer);
				writer.flush();
			}
		} catch (AdempiereException e) {
			throw e;
		} catch (Exception e) {
			throw new AdempiereException("Falha renderizando template '" + printTemplate.getName()
					+ "': " + e.getMessage(), e);
		}
	}

	private boolean isPdfOutput(FreemarkerReportRendererConfiguration config, MPrintTemplate template) {
		if (config.getOutputFormat() != null)
			return "pdf".equalsIgnoreCase(config.getOutputFormat());
		// sem hint: QUALQUER sinal do template basta
		return "pdf".equalsIgnoreCase(template.getOutputFileExtension())
				|| "application/pdf".equalsIgnoreCase(template.getOutputContentType())
				|| template.isBinaryOutput();
	}

	private OutputStream resolveOutputStream(FreemarkerReportRendererConfiguration config) throws Exception {
		if (config.getOutputStream() != null)
			return config.getOutputStream();
		if (config.getOutputFile() != null)
			return new FileOutputStream(config.getOutputFile(), false);
		throw new AdempiereException("Saída binária exige stream ou file (writer não suportado)");
	}

	private Writer resolveWriter(FreemarkerReportRendererConfiguration config, String encoding)
			throws Exception {
		if (config.getOutputWriter() != null)
			return config.getOutputWriter();
		if (config.getOutputStream() != null)
			return new OutputStreamWriter(config.getOutputStream(), encoding);
		if (config.getOutputFile() != null)
			return new OutputStreamWriter(new FileOutputStream(config.getOutputFile(), false), encoding);
		throw new AdempiereException("Nenhum output configurado (writer/stream/file)");
	}

	private Map<String, Object> contextMap(Properties ctx) {
		Map<String, Object> map = new LinkedHashMap<>();
		int orgId = Env.getAD_Org_ID(ctx);
		map.put("AD_Client_ID", Env.getAD_Client_ID(ctx));
		map.put("AD_Org_ID", orgId);
		map.put("AD_User_ID", Env.getAD_User_ID(ctx));
		map.put("AD_Role_ID", Env.getAD_Role_ID(ctx));
		map.put("language", Env.getLanguage(ctx).getAD_Language());
		map.put("client_name", MClient.get(ctx).getName());
		map.put("org_name", orgId > 0 ? MOrg.get(orgId).getName() : "*");
		map.put("date", Env.getContextAsDate(ctx, "#Date"));
		map.put("now", new Timestamp(System.currentTimeMillis()));
		return map;
	}
}
