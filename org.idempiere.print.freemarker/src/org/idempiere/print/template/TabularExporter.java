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
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

/**
 * Exporta a saída de uma listagem (modo IsForm='N') para formatos
 * tabulares. Como o template FreeMarker já produz um {@code <table>}
 * HTML, a grade é extraída com jsoup (respeitando {@code colspan}) e
 * reescrita como CSV (RFC 4180) ou XLSX (OOXML mínimo via ZIP, sem
 * dependência externa). As células saem como TEXTO exatamente como o
 * template as formatou (ex.: "20.000,00").
 */
public final class TabularExporter {

	private TabularExporter() {}

	/**
	 * Extrai a PRIMEIRA {@code <table>} do HTML como linhas de células.
	 * Honra {@code colspan} inserindo células vazias à direita, então
	 * cabeçalhos de grupo/subtotais permanecem alinhados às colunas.
	 */
	public static List<List<String>> extractTable(String html) {
		List<List<String>> rows = new ArrayList<>();
		if (html == null || html.isEmpty())
			return rows;
		Document doc = Jsoup.parse(html);
		Element table = doc.selectFirst("table");
		if (table == null)
			return rows;
		for (Element tr : table.select("tr")) {
			List<String> cells = new ArrayList<>();
			for (Element cell : tr.children()) {
				String tag = cell.normalName();
				if (!"td".equals(tag) && !"th".equals(tag))
					continue;
				cells.add(cell.text());
				int span = 1;
				String colspan = cell.attr("colspan");
				if (!colspan.isEmpty()) {
					try {
						span = Math.max(1, Integer.parseInt(colspan.trim()));
					} catch (NumberFormatException ignore) {}
				}
				for (int i = 1; i < span; i++)
					cells.add("");
			}
			if (!cells.isEmpty())
				rows.add(cells);
		}
		return rows;
	}

	public static void writeCsv(List<List<String>> rows, File out) throws IOException {
		int width = width(rows);
		StringBuilder sb = new StringBuilder();
		sb.append('﻿'); // BOM: Excel abre UTF-8 com acento correto
		for (List<String> row : rows) {
			for (int c = 0; c < width; c++) {
				if (c > 0)
					sb.append(',');
				sb.append(csvEscape(c < row.size() ? row.get(c) : ""));
			}
			sb.append("\r\n");
		}
		Files.writeString(out.toPath(), sb.toString(), StandardCharsets.UTF_8);
	}

	public static void writeXlsx(List<List<String>> rows, File out) throws IOException {
		int width = width(rows);
		try (ZipOutputStream zip = new ZipOutputStream(new FileOutputStream(out))) {
			putEntry(zip, "[Content_Types].xml", CONTENT_TYPES);
			putEntry(zip, "_rels/.rels", RELS);
			putEntry(zip, "xl/workbook.xml", WORKBOOK);
			putEntry(zip, "xl/_rels/workbook.xml.rels", WORKBOOK_RELS);
			putEntry(zip, "xl/styles.xml", STYLES);
			putEntry(zip, "xl/worksheets/sheet1.xml", sheetXml(rows, width));
		}
	}

	// ---- helpers ---------------------------------------------------------

	private static int width(List<List<String>> rows) {
		int width = 0;
		for (List<String> row : rows)
			width = Math.max(width, row.size());
		return Math.max(width, 1);
	}

	private static String csvEscape(String value) {
		if (value == null)
			return "";
		if (value.indexOf(',') < 0 && value.indexOf('"') < 0
				&& value.indexOf('\n') < 0 && value.indexOf('\r') < 0)
			return value;
		return '"' + value.replace("\"", "\"\"") + '"';
	}

	private static String sheetXml(List<List<String>> rows, int width) {
		StringBuilder sb = new StringBuilder();
		String dimension = rows.isEmpty() ? "A1" : "A1:" + colName(width - 1) + rows.size();
		sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>");
		sb.append("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">");
		// dimension + sheetView ativos: o Keikai precisa deles pra montar o viewport
		// (sem isso o grid pinta e some — "linhas piscam e somem")
		sb.append("<dimension ref=\"").append(dimension).append("\"/>");
		sb.append("<sheetViews><sheetView tabSelected=\"1\" workbookViewId=\"0\"/></sheetViews>");
		sb.append("<sheetFormatPr defaultRowHeight=\"15\"/>");
		sb.append("<sheetData>");
		int r = 0;
		for (List<String> row : rows) {
			r++;
			sb.append("<row r=\"").append(r).append("\">");
			for (int c = 0; c < width; c++) {
				String value = c < row.size() ? row.get(c) : "";
				if (value.isEmpty())
					continue; // célula esparsa é válida em OOXML e mantém o arquivo enxuto
				sb.append("<c r=\"").append(colName(c)).append(r)
						.append("\" t=\"inlineStr\"><is><t xml:space=\"preserve\">")
						.append(xmlEscape(value)).append("</t></is></c>");
			}
			sb.append("</row>");
		}
		sb.append("</sheetData></worksheet>");
		return sb.toString();
	}

	/** 0-based → A, B, ... Z, AA, AB, ... */
	private static String colName(int col) {
		StringBuilder sb = new StringBuilder();
		int n = col + 1;
		while (n > 0) {
			int rem = (n - 1) % 26;
			sb.insert(0, (char) ('A' + rem));
			n = (n - 1) / 26;
		}
		return sb.toString();
	}

	private static String xmlEscape(String value) {
		return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
	}

	private static void putEntry(ZipOutputStream zip, String name, String content) throws IOException {
		zip.putNextEntry(new ZipEntry(name));
		zip.write(content.getBytes(StandardCharsets.UTF_8));
		zip.closeEntry();
	}

	private static final String CONTENT_TYPES =
			"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
			+ "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
			+ "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
			+ "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
			+ "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"
			+ "<Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
			+ "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
			+ "</Types>";

	private static final String RELS =
			"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
			+ "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
			+ "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>"
			+ "</Relationships>";

	private static final String WORKBOOK =
			"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
			+ "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\""
			+ " xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">"
			+ "<bookViews><workbookView activeTab=\"0\"/></bookViews>"
			+ "<sheets><sheet name=\"Sheet1\" sheetId=\"1\" r:id=\"rId1\"/></sheets>"
			+ "</workbook>";

	private static final String WORKBOOK_RELS =
			"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
			+ "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
			+ "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>"
			+ "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"
			+ "</Relationships>";

	/** StylesTable mínima: o POI do Keikai (org.zkoss.poi) exige a parte styles (senão stylesSource==null → NPE no import) */
	private static final String STYLES =
			"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
			+ "<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">"
			+ "<fonts count=\"1\"><font><sz val=\"11\"/><name val=\"Calibri\"/></font></fonts>"
			+ "<fills count=\"2\"><fill><patternFill patternType=\"none\"/></fill>"
			+ "<fill><patternFill patternType=\"gray125\"/></fill></fills>"
			+ "<borders count=\"1\"><border/></borders>"
			+ "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
			+ "<cellXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/></cellXfs>"
			+ "<cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>"
			+ "</styleSheet>";
}
