/******************************************************************************
 * Product: iDempiere ERP & CRM Smart Business Solution                       *
 * Copyright (C) 1999-2012 ComPiere, Inc. All Rights Reserved.                *
 * This program is free software, you can redistribute it and/or modify it    *
 * under the terms version 2 of the GNU General Public License as published   *
 * by the Free Software Foundation. This program is distributed in the hope   *
 * that it will be useful, but WITHOUT ANY WARRANTY, without even the implied *
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.           *
 * See the GNU General Public License for more details.                       *
 * You should have received a copy of the GNU General Public License along    *
 * with this program, if not, write to the Free Software Foundation, Inc.,    *
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.                     *
 * For the text or an alternative of this public license, you may reach us    *
 * ComPiere, Inc., 2620 Augustine Dr. #245, Santa Clara, CA 95054, USA        *
 * or via info@compiere.org or http://www.compiere.org/license.html           *
 *****************************************************************************/
/** Generated Model - DO NOT CHANGE */
package org.idempiere.print.template.model;

import java.sql.ResultSet;
import java.util.Properties;
import org.compiere.model.*;
import org.compiere.util.KeyNamePair;

/** Generated Model for AD_PrintTemplate
 *  @author iDempiere (generated)
 *  @version Release 12 - $Id$ */
@org.adempiere.base.Model(table="AD_PrintTemplate")
public class X_AD_PrintTemplate extends PO implements I_AD_PrintTemplate, I_Persistent
{

	/**
	 *
	 */
	private static final long serialVersionUID = 20260715L;

    /** Standard Constructor */
    public X_AD_PrintTemplate (Properties ctx, int AD_PrintTemplate_ID, String trxName)
    {
      super (ctx, AD_PrintTemplate_ID, trxName);
      /** if (AD_PrintTemplate_ID == 0)
        {
			setAD_PrintTemplate_ID (0);
			setIsBinaryOutput (false);
// N
			setName (null);
			setOutputContentType (null);
// text/html
			setOutputFileExtension (null);
// html
			setTemplateBody (null);
			setTemplateEncoding (null);
// UTF-8
			setTemplateEngineType (null);
// FM
        } */
    }

    /** Standard Constructor */
    public X_AD_PrintTemplate (Properties ctx, int AD_PrintTemplate_ID, String trxName, String ... virtualColumns)
    {
      super (ctx, AD_PrintTemplate_ID, trxName, virtualColumns);
      /** if (AD_PrintTemplate_ID == 0)
        {
			setAD_PrintTemplate_ID (0);
			setIsBinaryOutput (false);
// N
			setName (null);
			setOutputContentType (null);
// text/html
			setOutputFileExtension (null);
// html
			setTemplateBody (null);
			setTemplateEncoding (null);
// UTF-8
			setTemplateEngineType (null);
// FM
        } */
    }

    /** Standard Constructor */
    public X_AD_PrintTemplate (Properties ctx, String AD_PrintTemplate_UU, String trxName)
    {
      super (ctx, AD_PrintTemplate_UU, trxName);
      /** if (AD_PrintTemplate_UU == null)
        {
			setAD_PrintTemplate_ID (0);
			setIsBinaryOutput (false);
// N
			setName (null);
			setOutputContentType (null);
// text/html
			setOutputFileExtension (null);
// html
			setTemplateBody (null);
			setTemplateEncoding (null);
// UTF-8
			setTemplateEngineType (null);
// FM
        } */
    }

    /** Standard Constructor */
    public X_AD_PrintTemplate (Properties ctx, String AD_PrintTemplate_UU, String trxName, String ... virtualColumns)
    {
      super (ctx, AD_PrintTemplate_UU, trxName, virtualColumns);
      /** if (AD_PrintTemplate_UU == null)
        {
			setAD_PrintTemplate_ID (0);
			setIsBinaryOutput (false);
// N
			setName (null);
			setOutputContentType (null);
// text/html
			setOutputFileExtension (null);
// html
			setTemplateBody (null);
			setTemplateEncoding (null);
// UTF-8
			setTemplateEngineType (null);
// FM
        } */
    }

    /** Load Constructor */
    public X_AD_PrintTemplate (Properties ctx, ResultSet rs, String trxName)
    {
      super (ctx, rs, trxName);
    }

    /** AccessLevel
      * @return 6 - System - Client
      */
    protected int get_AccessLevel()
    {
      return accessLevel.intValue();
    }

    /** Load Meta Data */
    protected POInfo initPO (Properties ctx)
    {
      POInfo poi = POInfo.getPOInfo (ctx, Table_ID, get_TrxName());
      return poi;
    }

    public String toString()
    {
      StringBuilder sb = new StringBuilder ("X_AD_PrintTemplate[")
        .append(get_ID()).append(",Name=").append(getName()).append("]");
      return sb.toString();
    }

	/** Set Print Template.
		@param AD_PrintTemplate_ID Print Template
	*/
	public void setAD_PrintTemplate_ID (int AD_PrintTemplate_ID)
	{
		if (AD_PrintTemplate_ID < 1)
			set_ValueNoCheck (COLUMNNAME_AD_PrintTemplate_ID, null);
		else
			set_ValueNoCheck (COLUMNNAME_AD_PrintTemplate_ID, Integer.valueOf(AD_PrintTemplate_ID));
	}

	/** Get Print Template.
		@return Print Template	  */
	public int getAD_PrintTemplate_ID()
	{
		Integer ii = (Integer)get_Value(COLUMNNAME_AD_PrintTemplate_ID);
		if (ii == null)
			 return 0;
		return ii.intValue();
	}

	/** Set AD_PrintTemplate_UU.
		@param AD_PrintTemplate_UU AD_PrintTemplate_UU
	*/
	public void setAD_PrintTemplate_UU (String AD_PrintTemplate_UU)
	{
		set_Value (COLUMNNAME_AD_PrintTemplate_UU, AD_PrintTemplate_UU);
	}

	/** Get AD_PrintTemplate_UU.
		@return AD_PrintTemplate_UU	  */
	public String getAD_PrintTemplate_UU()
	{
		return (String)get_Value(COLUMNNAME_AD_PrintTemplate_UU);
	}

	public org.compiere.model.I_AD_Table getAD_Table() throws RuntimeException
	{
		return (org.compiere.model.I_AD_Table)MTable.get(getCtx(), org.compiere.model.I_AD_Table.Table_ID)
			.getPO(getAD_Table_ID(), get_TrxName());
	}

	/** Set Table.
		@param AD_Table_ID Tabela primária esperada (validação opcional)
	*/
	public void setAD_Table_ID (int AD_Table_ID)
	{
		if (AD_Table_ID < 1)
			set_Value (COLUMNNAME_AD_Table_ID, null);
		else
			set_Value (COLUMNNAME_AD_Table_ID, Integer.valueOf(AD_Table_ID));
	}

	/** Get Table.
		@return Tabela primária esperada (validação opcional)
	  */
	public int getAD_Table_ID()
	{
		Integer ii = (Integer)get_Value(COLUMNNAME_AD_Table_ID);
		if (ii == null)
			 return 0;
		return ii.intValue();
	}

	/** Set Description.
		@param Description Description
	*/
	public void setDescription (String Description)
	{
		set_Value (COLUMNNAME_Description, Description);
	}

	/** Get Description.
		@return Description	  */
	public String getDescription()
	{
		return (String)get_Value(COLUMNNAME_Description);
	}

	/** Set Comment/Help.
		@param Help Comment/Help
	*/
	public void setHelp (String Help)
	{
		set_Value (COLUMNNAME_Help, Help);
	}

	/** Get Comment/Help.
		@return Comment/Help	  */
	public String getHelp()
	{
		return (String)get_Value(COLUMNNAME_Help);
	}

	/** Set Binary Output.
		@param IsBinaryOutput Binary Output
	*/
	public void setIsBinaryOutput (boolean IsBinaryOutput)
	{
		set_Value (COLUMNNAME_IsBinaryOutput, Boolean.valueOf(IsBinaryOutput));
	}

	/** Get Binary Output.
		@return Binary Output	  */
	public boolean isBinaryOutput()
	{
		Object oo = get_Value(COLUMNNAME_IsBinaryOutput);
		if (oo != null)
		{
			 if (oo instanceof Boolean)
				 return ((Boolean)oo).booleanValue();
			return "Y".equals(oo);
		}
		return false;
	}

	/** Set Name.
		@param Name Resolvível por &lt;#include &quot;Name&quot;&gt; e pelo fallback de classpath
	*/
	public void setName (String Name)
	{
		set_Value (COLUMNNAME_Name, Name);
	}

	/** Get Name.
		@return Resolvível por &lt;#include &quot;Name&quot;&gt; e pelo fallback de classpath
	  */
	public String getName()
	{
		return (String)get_Value(COLUMNNAME_Name);
	}

    /** Get Record ID/ColumnName
        @return ID/ColumnName pair
      */
    public KeyNamePair getKeyNamePair()
    {
        return new KeyNamePair(get_ID(), getName());
    }

	/** Set Output Content Type.
		@param OutputContentType Output Content Type
	*/
	public void setOutputContentType (String OutputContentType)
	{
		set_Value (COLUMNNAME_OutputContentType, OutputContentType);
	}

	/** Get Output Content Type.
		@return Output Content Type	  */
	public String getOutputContentType()
	{
		return (String)get_Value(COLUMNNAME_OutputContentType);
	}

	/** Set Output File Extension.
		@param OutputFileExtension Output File Extension
	*/
	public void setOutputFileExtension (String OutputFileExtension)
	{
		set_Value (COLUMNNAME_OutputFileExtension, OutputFileExtension);
	}

	/** Get Output File Extension.
		@return Output File Extension	  */
	public String getOutputFileExtension()
	{
		return (String)get_Value(COLUMNNAME_OutputFileExtension);
	}

	/** Set Template Body.
		@param TemplateBody Código-fonte do template
	*/
	public void setTemplateBody (String TemplateBody)
	{
		set_Value (COLUMNNAME_TemplateBody, TemplateBody);
	}

	/** Get Template Body.
		@return Código-fonte do template
	  */
	public String getTemplateBody()
	{
		return (String)get_Value(COLUMNNAME_TemplateBody);
	}

	/** Set Template Encoding.
		@param TemplateEncoding Template Encoding
	*/
	public void setTemplateEncoding (String TemplateEncoding)
	{
		set_Value (COLUMNNAME_TemplateEncoding, TemplateEncoding);
	}

	/** Get Template Encoding.
		@return Template Encoding	  */
	public String getTemplateEncoding()
	{
		return (String)get_Value(COLUMNNAME_TemplateEncoding);
	}

	/** FreeMarker = FM */
	public static final String TEMPLATEENGINETYPE_FreeMarker = "FM";
	/** Handlebars = HB */
	public static final String TEMPLATEENGINETYPE_Handlebars = "HB";
	/** Mustache = MS */
	public static final String TEMPLATEENGINETYPE_Mustache = "MS";
	/** Thymeleaf = TH */
	public static final String TEMPLATEENGINETYPE_Thymeleaf = "TH";
	/** Velocity = VL */
	public static final String TEMPLATEENGINETYPE_Velocity = "VL";
	/** Set Template Engine Type.
		@param TemplateEngineType Template Engine Type
	*/
	public void setTemplateEngineType (String TemplateEngineType)
	{

		set_Value (COLUMNNAME_TemplateEngineType, TemplateEngineType);
	}

	/** Get Template Engine Type.
		@return Template Engine Type	  */
	public String getTemplateEngineType()
	{
		return (String)get_Value(COLUMNNAME_TemplateEngineType);
	}
}