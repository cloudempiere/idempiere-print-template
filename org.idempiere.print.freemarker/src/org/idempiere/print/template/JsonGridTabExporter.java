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
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.adempiere.base.IGridTabExporter;
import org.adempiere.exceptions.AdempiereException;
import org.compiere.model.GridTab;
import org.compiere.model.GridTable;
import org.compiere.model.PO;

/**
 * Formato JSON no diálogo NATIVO de Exportar do iDempiere (extension
 * point org.adempiere.base.IGridTabExporter — zero patch de core/fork).
 *
 * - Registro atual: objeto com as colunas (FK = {id, display}, mesma
 *   visão que os print templates recebem via PO2MapBuilder) + os tabs
 *   filhos selecionados como arrays.
 * - Todos os registros: array de objetos (sem filhos).
 *
 * Caso de uso primário: alimentar um prompt de IA na autoria de
 * templates (spec §11 — mesma árvore do data model do template).
 */
public class JsonGridTabExporter implements IGridTabExporter {

	@Override
	public void export(GridTab gridTab, List<GridTab> childs, boolean isCurrentRowOnly,
			File file, int indxDetailSelected) {
		try {
			Object payload = isCurrentRowOnly
					? exportCurrentRow(gridTab, childs)
					: exportAllRows(gridTab);
			try (Writer writer = new OutputStreamWriter(new FileOutputStream(file, false),
					StandardCharsets.UTF_8)) {
				writer.write(PO2MapBuilder.toJson(payload, true));
			}
		} catch (AdempiereException e) {
			throw e;
		} catch (Exception e) {
			throw new AdempiereException("Falha exportando JSON: " + e.getMessage(), e);
		}
	}

	private Map<String, Object> exportCurrentRow(GridTab gridTab, List<GridTab> childs) {
		PO po = currentPO(gridTab);
		Map<String, Object> map = PO2MapBuilder.buildFlat(po);
		if (childs != null) {
			for (GridTab child : childs) {
				if (!isExportableTab(child) || map.containsKey(child.getTableName()))
					continue;
				List<Map<String, Object>> rows = PO2MapBuilder.loadChildrenByFK(po, child.getTableName());
				if (rows != null)
					map.put(child.getTableName(), rows);
			}
		}
		return map;
	}

	private List<Map<String, Object>> exportAllRows(GridTab gridTab) {
		List<Map<String, Object>> rows = new ArrayList<>();
		GridTable table = gridTab.getTableModel();
		for (int i = 0; i < gridTab.getRowCount(); i++) {
			PO po = table.getPO(i);
			if (po != null)
				rows.add(PO2MapBuilder.buildFlat(po));
		}
		return rows;
	}

	private PO currentPO(GridTab gridTab) {
		PO po = gridTab.getTableModel().getPO(gridTab.getCurrentRow());
		if (po == null)
			throw new AdempiereException("Sem registro corrente pra exportar");
		return po;
	}

	@Override
	public String getFileExtension() {
		return "json";
	}

	@Override
	public String getFileExtensionLabel() {
		return "JSON";
	}

	@Override
	public String getContentType() {
		return "application/json";
	}

	@Override
	public String getSuggestedFileName(GridTab gridTab) {
		return gridTab.getTableName() + ".json";
	}

	@Override
	public boolean isExportableTab(GridTab childTab) {
		return !childTab.isSortTab();
	}

	@Override
	public boolean isExportChildTabsForCurrentRowOnly() {
		return true;
	}

	@Override
	public int maxDeepOfChildTab() {
		return 1;
	}
}
