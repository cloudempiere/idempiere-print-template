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

import org.compiere.model.MSysConfig;

import freemarker.cache.ClassTemplateLoader;
import freemarker.cache.MultiTemplateLoader;
import freemarker.cache.TemplateLoader;
import freemarker.core.HTMLOutputFormat;
import freemarker.core.TemplateClassResolver;
import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;

/**
 * Configuration singleton do FreeMarker:
 * - MultiTemplateLoader: banco (AD_PrintTemplate) → classpath do bundle
 *   (/templates) — spec §4.8;
 * - HTMLOutputFormat (auto-escape XSS em ${var}; ${var?no_esc} opt-out);
 * - RETHROW: erro de template quebra a renderização com causa real
 *   (plugin genérico não engole erro);
 * - SAFER_RESOLVER: template não instancia classe arbitrária;
 * - formatos default BR, sobrescrevíveis via SysConfig PRT_FREEMARKER_*.
 */
public final class FreemarkerConfigurationFactory {

	public static final String SYSCONFIG_DATE_FORMAT = "PRT_FREEMARKER_DATE_FORMAT";
	public static final String SYSCONFIG_TIME_FORMAT = "PRT_FREEMARKER_TIME_FORMAT";
	public static final String SYSCONFIG_DATETIME_FORMAT = "PRT_FREEMARKER_DATETIME_FORMAT";
	public static final String SYSCONFIG_NUMBER_FORMAT = "PRT_FREEMARKER_NUMBER_FORMAT";

	private static volatile Configuration s_configuration;

	private FreemarkerConfigurationFactory() {}

	public static Configuration get() {
		if (s_configuration == null) {
			synchronized (FreemarkerConfigurationFactory.class) {
				if (s_configuration == null)
					s_configuration = build();
			}
		}
		return s_configuration;
	}

	private static Configuration build() {
		Configuration cfg = new Configuration(Configuration.VERSION_2_3_31);
		cfg.setTemplateLoader(new MultiTemplateLoader(new TemplateLoader[] {
				new DatabaseTemplateLoader(),
				new ClassTemplateLoader(FreemarkerConfigurationFactory.class, "/templates")
		}));
		cfg.setLocalizedLookup(false);
		cfg.setTemplateUpdateDelayMilliseconds(5000);
		cfg.setDefaultEncoding("UTF-8");
		cfg.setOutputFormat(HTMLOutputFormat.INSTANCE);
		cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
		cfg.setLogTemplateExceptions(false);
		cfg.setWrapUncheckedExceptions(true);
		cfg.setNewBuiltinClassResolver(TemplateClassResolver.SAFER_RESOLVER);
		cfg.setDateFormat(MSysConfig.getValue(SYSCONFIG_DATE_FORMAT, "dd/MM/yyyy"));
		cfg.setTimeFormat(MSysConfig.getValue(SYSCONFIG_TIME_FORMAT, "HH:mm:ss"));
		cfg.setDateTimeFormat(MSysConfig.getValue(SYSCONFIG_DATETIME_FORMAT, "dd/MM/yyyy HH:mm"));
		cfg.setNumberFormat(MSysConfig.getValue(SYSCONFIG_NUMBER_FORMAT, "#,##0.##"));
		return cfg;
	}
}
