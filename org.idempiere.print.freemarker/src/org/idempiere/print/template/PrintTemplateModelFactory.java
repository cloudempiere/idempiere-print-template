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

import java.sql.ResultSet;

import org.adempiere.base.IModelFactory;
import org.compiere.model.PO;
import org.compiere.util.Env;
import org.idempiere.print.template.model.I_AD_PrintTemplate;
import org.idempiere.print.template.model.I_AD_PrintTemplate_Include;
import org.idempiere.print.template.model.MPrintTemplate;
import org.idempiere.print.template.model.MPrintTemplateInclude;

/**
 * Resolve os models deste bundle — sem isso, Query/MTable hidratam
 * GenericPO em vez de MPrintTemplate(Include).
 */
public class PrintTemplateModelFactory implements IModelFactory {

	@Override
	public Class<?> getClass(String tableName) {
		if (I_AD_PrintTemplate.Table_Name.equals(tableName))
			return MPrintTemplate.class;
		if (I_AD_PrintTemplate_Include.Table_Name.equals(tableName))
			return MPrintTemplateInclude.class;
		return null;
	}

	@Override
	public PO getPO(String tableName, int Record_ID, String trxName) {
		if (I_AD_PrintTemplate.Table_Name.equals(tableName))
			return new MPrintTemplate(Env.getCtx(), Record_ID, trxName);
		if (I_AD_PrintTemplate_Include.Table_Name.equals(tableName))
			return new MPrintTemplateInclude(Env.getCtx(), Record_ID, trxName);
		return null;
	}

	@Override
	public PO getPO(String tableName, ResultSet rs, String trxName) {
		if (I_AD_PrintTemplate.Table_Name.equals(tableName))
			return new MPrintTemplate(Env.getCtx(), rs, trxName);
		if (I_AD_PrintTemplate_Include.Table_Name.equals(tableName))
			return new MPrintTemplateInclude(Env.getCtx(), rs, trxName);
		return null;
	}
}
