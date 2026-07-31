/**********************************************************************
* This file is part of the iDempiere Print Template Engine plugin.    *
*                                                                     *
* This program is free software; you can redistribute it and/or       *
* modify it under the terms of the GNU General Public License         *
* as published by the Free Software Foundation; either version 2      *
* of the License, or (at your option) any later version.              *
**********************************************************************/
package org.idempiere.print.template;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

import org.adempiere.exceptions.AdempiereException;
import org.apache.pdfbox.io.MemoryUsageSetting;
import org.apache.pdfbox.multipdf.PDFMergerUtility;
import org.compiere.model.MTable;
import org.compiere.model.PO;
import org.compiere.model.PrintInfo;
import org.compiere.print.MPrintFormat;
import org.compiere.process.ProcessInfo;
import org.idempiere.print.IReportContentRenderer;
import org.idempiere.print.IReportContentRendererFactory;
import org.idempiere.print.ReportContentRequest;
import org.idempiere.print.ReportContentType;
import org.idempiere.print.template.model.I_AD_PrintTemplate;
import org.idempiere.print.template.model.MPrintTemplate;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;

/** Integrates print templates with the report-content API from IDEMPIERE-7070. */
public class PrintTemplateContentRendererFactory implements IReportContentRendererFactory {

	@Override
	public IReportContentRenderer createRenderer(ReportContentRequest request) {
		if (request == null || request.reportEngine() == null)
			return null;
		MPrintFormat printFormat = request.printFormat();
		if (printFormat == null
				|| printFormat.get_ColumnIndex(I_AD_PrintTemplate.COLUMNNAME_AD_PrintTemplate_ID) < 0)
			return null;
		int templateId = printFormat.get_ValueAsInt(I_AD_PrintTemplate.COLUMNNAME_AD_PrintTemplate_ID);
		if (templateId <= 0)
			return null;
		MPrintTemplate template = MPrintTemplate.get(printFormat.getCtx(), templateId);
		if (template == null || !template.isActive())
			throw new AdempiereException("Print Template: template " + templateId + " does not exist or is inactive");
		return new PrintTemplateContentRenderer(template, resolveTargetPOs(request, template));
	}

	private static final class PrintTemplateContentRenderer implements IReportContentRenderer {
		private static final ReportContentType[] CONTENT_TYPES = {
				new ReportContentType("PDF", "pdf", "application/pdf"),
				new ReportContentType("HTML", "html", "text/html; charset=utf-8") };

		private final MPrintTemplate template;
		private final List<PO> targets;

		private PrintTemplateContentRenderer(MPrintTemplate template, List<PO> targets) {
			this.template = template;
			this.targets = targets;
		}

		@Override
		public File getContent(String contentType, String fileExtension) {
			String extension = normalizeExtension(contentType, fileExtension);
			try {
				List<File> rendered = new ArrayList<>();
				for (PO target : targets) {
					File output = Files.createTempFile("print-template-" + target.get_ID() + "-", "." + extension).toFile();
					if (!TemplateRenderDispatcher.render(template, target, output, extension))
						throw new AdempiereException("Print Template: no renderer installed for engine '"
								+ template.getTemplateEngineType() + "'");
					rendered.add(output);
				}
				if (rendered.size() == 1)
					return rendered.get(0);
				try {
					return merge(rendered, extension);
				} finally {
					for (File file : rendered)
						Files.deleteIfExists(file.toPath());
				}
			} catch (AdempiereException e) {
				throw e;
			} catch (Exception e) {
				throw new AdempiereException("Print Template: unable to create report content", e);
			}
		}

		@Override
		public ReportContentType[] getSupportedContentTypes() {
			return CONTENT_TYPES.clone();
		}

		@Override
		public int getRowCount() {
			return targets.size();
		}

		private File merge(List<File> rendered, String extension) throws Exception {
			File combined = Files.createTempFile("print-template-combined-", "." + extension).toFile();
			if ("pdf".equals(extension)) {
				PDFMergerUtility merger = new PDFMergerUtility();
				for (File file : rendered)
					merger.addSource(file);
				merger.setDestinationFileName(combined.getAbsolutePath());
				merger.mergeDocuments(MemoryUsageSetting.setupTempFileOnly());
				return combined;
			}

			Document document = Jsoup.parse(rendered.get(0), StandardCharsets.UTF_8.name());
			for (int i = 1; i < rendered.size(); i++) {
				Document next = Jsoup.parse(rendered.get(i), StandardCharsets.UTF_8.name());
				document.body().append("<div style=\"page-break-before: always\"></div>");
				document.body().append(next.body().html());
			}
			Files.writeString(combined.toPath(), document.outerHtml(), StandardCharsets.UTF_8);
			return combined;
		}
	}

	private static String normalizeExtension(String contentType, String fileExtension) {
		if ("pdf".equalsIgnoreCase(fileExtension)
				|| (contentType != null && contentType.toLowerCase().startsWith("application/pdf")))
			return "pdf";
		if ("html".equalsIgnoreCase(fileExtension)
				|| (contentType != null && contentType.toLowerCase().startsWith("text/html")))
			return "html";
		throw new AdempiereException("Print Template: unsupported output type " + contentType + " (" + fileExtension + ")");
	}

	private static List<PO> resolveTargetPOs(ReportContentRequest request, MPrintTemplate template) {
		PrintInfo printInfo = request.printInfo();
		ProcessInfo processInfo = request.processInfo();
		MPrintFormat printFormat = request.printFormat();

		int tableId = printInfo != null ? printInfo.getAD_Table_ID() : 0;
		int recordId = printInfo != null ? printInfo.getRecord_ID() : 0;
		if (tableId <= 0 && processInfo != null)
			tableId = processInfo.getTable_ID();
		if (recordId <= 0 && processInfo != null)
			recordId = processInfo.getRecord_ID();
		if (tableId <= 0 && printFormat != null)
			tableId = printFormat.getAD_Table_ID();
		if (tableId <= 0 && template.getAD_Table_ID() > 0)
			tableId = template.getAD_Table_ID();

		List<Integer> recordIds = new ArrayList<>();
		if (processInfo != null && processInfo.getRecord_IDs() != null) {
			for (Integer id : processInfo.getRecord_IDs()) {
				if (id != null && id.intValue() > 0)
					recordIds.add(id);
			}
		}
		if (recordId > 0)
			recordIds.add(recordId);
		recordIds = new ArrayList<>(new LinkedHashSet<>(recordIds));

		if (tableId <= 0 || recordIds.isEmpty())
			throw new AdempiereException("Print Template: report has no record context"
					+ " (AD_Table_ID=" + tableId + ", Record_ID=" + recordId + ")");
		List<PO> targets = new ArrayList<>();
		MTable table = MTable.get(template.getCtx(), tableId);
		for (int id : recordIds) {
			PO target = table.getPO(id, null);
			if (target == null)
				throw new AdempiereException("Print Template: record " + id + " not found in table " + tableId);
			if (template.getAD_Table_ID() > 0 && template.getAD_Table_ID() != target.get_Table_ID())
				throw new AdempiereException("Print Template: template '" + template.getName()
						+ "' does not apply to table " + target.get_TableName());
			targets.add(target);
		}
		return targets;
	}
}
