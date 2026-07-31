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
package org.idempiere.print.template.model;

import java.sql.ResultSet;
import java.util.Properties;

/**
 * Tabela filha declarada no data model do template (spec §6.2).
 */
public class MPrintTemplateInclude extends X_AD_PrintTemplate_Include {

	private static final long serialVersionUID = 1L;

	public MPrintTemplateInclude(Properties ctx, int AD_PrintTemplate_Include_ID, String trxName) {
		super(ctx, AD_PrintTemplate_Include_ID, trxName);
	}

	public MPrintTemplateInclude(Properties ctx, String AD_PrintTemplate_Include_UU, String trxName) {
		super(ctx, AD_PrintTemplate_Include_UU, trxName);
	}

	public MPrintTemplateInclude(Properties ctx, ResultSet rs, String trxName) {
		super(ctx, rs, trxName);
	}
}
