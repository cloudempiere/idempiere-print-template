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

import org.compiere.model.PO;
import org.idempiere.print.template.TemplateRendererConfiguration;
import org.idempiere.print.template.model.MPrintTemplate;

/**
 * Configuração do renderer FreeMarker — o construtor (MPrintTemplate, PO)
 * é o contrato instanciado por reflexão pelo TemplateRenderDispatcher.
 */
public class FreemarkerReportRendererConfiguration extends TemplateRendererConfiguration {

	public FreemarkerReportRendererConfiguration(MPrintTemplate template, PO targetPO) {
		super(template, targetPO);
	}
}
