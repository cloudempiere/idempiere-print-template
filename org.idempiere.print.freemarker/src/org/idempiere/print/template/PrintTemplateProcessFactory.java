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

import org.adempiere.base.IProcessFactory;
import org.compiere.process.ProcessCall;

/**
 * Resolve as classes de processo deste bundle — o DefaultProcessFactory
 * do core não enxerga classes de plugin (@Process sozinho não basta).
 */
public class PrintTemplateProcessFactory implements IProcessFactory {

	@Override
	public ProcessCall newProcessInstance(String className) {
		if (TemplateReportStarter.class.getName().equals(className))
			return new TemplateReportStarter();
		if (TemplateValidateProcess.class.getName().equals(className))
			return new TemplateValidateProcess();
		return null;
	}
}
