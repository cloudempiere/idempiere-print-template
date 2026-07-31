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
package org.idempiere.print.template.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import org.compiere.model.*;
import org.compiere.util.KeyNamePair;

/** Generated Interface for AD_PrintTemplate
 *  @author iDempiere (generated) 
 *  @version Release 12
 */
@SuppressWarnings("all")
public interface I_AD_PrintTemplate 
{

    /** TableName=AD_PrintTemplate */
    public static final String Table_Name = "AD_PrintTemplate";

    /** AD_Table_ID=5000006 */
    public static final int Table_ID = MTable.getTable_ID(Table_Name);

    KeyNamePair Model = new KeyNamePair(Table_ID, Table_Name);

    /** AccessLevel = 6 - System - Client 
     */
    BigDecimal accessLevel = BigDecimal.valueOf(6);

    /** Load Meta Data */

    /** Column name AD_Client_ID */
    public static final String COLUMNNAME_AD_Client_ID = "AD_Client_ID";

	/** Get Client	  */
	public int getAD_Client_ID();

    /** Column name AD_Org_ID */
    public static final String COLUMNNAME_AD_Org_ID = "AD_Org_ID";

	/** Set Organization	  */
	public void setAD_Org_ID (int AD_Org_ID);

	/** Get Organization	  */
	public int getAD_Org_ID();

    /** Column name AD_PrintTemplate_ID */
    public static final String COLUMNNAME_AD_PrintTemplate_ID = "AD_PrintTemplate_ID";

	/** Set Print Template	  */
	public void setAD_PrintTemplate_ID (int AD_PrintTemplate_ID);

	/** Get Print Template	  */
	public int getAD_PrintTemplate_ID();

    /** Column name AD_PrintTemplate_UU */
    public static final String COLUMNNAME_AD_PrintTemplate_UU = "AD_PrintTemplate_UU";

	/** Set AD_PrintTemplate_UU	  */
	public void setAD_PrintTemplate_UU (String AD_PrintTemplate_UU);

	/** Get AD_PrintTemplate_UU	  */
	public String getAD_PrintTemplate_UU();

    /** Column name AD_Table_ID */
    public static final String COLUMNNAME_AD_Table_ID = "AD_Table_ID";

	/** Set Table.
	  * Tabela primária esperada (validação opcional)
	  */
	public void setAD_Table_ID (int AD_Table_ID);

	/** Get Table.
	  * Tabela primária esperada (validação opcional)
	  */
	public int getAD_Table_ID();

	public org.compiere.model.I_AD_Table getAD_Table() throws RuntimeException;

    /** Column name Created */
    public static final String COLUMNNAME_Created = "Created";

	/** Get Created	  */
	public Timestamp getCreated();

    /** Column name CreatedBy */
    public static final String COLUMNNAME_CreatedBy = "CreatedBy";

	/** Get Created By	  */
	public int getCreatedBy();

    /** Column name Description */
    public static final String COLUMNNAME_Description = "Description";

	/** Set Description	  */
	public void setDescription (String Description);

	/** Get Description	  */
	public String getDescription();

    /** Column name Help */
    public static final String COLUMNNAME_Help = "Help";

	/** Set Comment/Help	  */
	public void setHelp (String Help);

	/** Get Comment/Help	  */
	public String getHelp();

    /** Column name IsActive */
    public static final String COLUMNNAME_IsActive = "IsActive";

	/** Set Active	  */
	public void setIsActive (boolean IsActive);

	/** Get Active	  */
	public boolean isActive();

    /** Column name IsBinaryOutput */
    public static final String COLUMNNAME_IsBinaryOutput = "IsBinaryOutput";

	/** Set Binary Output	  */
	public void setIsBinaryOutput (boolean IsBinaryOutput);

	/** Get Binary Output	  */
	public boolean isBinaryOutput();

    /** Column name Name */
    public static final String COLUMNNAME_Name = "Name";

	/** Set Name.
	  * Resolvível por &lt;
#include &quot;
Name&quot;
&gt;
 e pelo fallback de classpath
	  */
	public void setName (String Name);

	/** Get Name.
	  * Resolvível por &lt;
#include &quot;
Name&quot;
&gt;
 e pelo fallback de classpath
	  */
	public String getName();

    /** Column name OutputContentType */
    public static final String COLUMNNAME_OutputContentType = "OutputContentType";

	/** Set Output Content Type	  */
	public void setOutputContentType (String OutputContentType);

	/** Get Output Content Type	  */
	public String getOutputContentType();

    /** Column name OutputFileExtension */
    public static final String COLUMNNAME_OutputFileExtension = "OutputFileExtension";

	/** Set Output File Extension	  */
	public void setOutputFileExtension (String OutputFileExtension);

	/** Get Output File Extension	  */
	public String getOutputFileExtension();

    /** Column name TemplateBody */
    public static final String COLUMNNAME_TemplateBody = "TemplateBody";

	/** Set Template Body.
	  * Código-fonte do template
	  */
	public void setTemplateBody (String TemplateBody);

	/** Get Template Body.
	  * Código-fonte do template
	  */
	public String getTemplateBody();

    /** Column name TemplateEncoding */
    public static final String COLUMNNAME_TemplateEncoding = "TemplateEncoding";

	/** Set Template Encoding	  */
	public void setTemplateEncoding (String TemplateEncoding);

	/** Get Template Encoding	  */
	public String getTemplateEncoding();

    /** Column name TemplateEngineType */
    public static final String COLUMNNAME_TemplateEngineType = "TemplateEngineType";

	/** Set Template Engine Type	  */
	public void setTemplateEngineType (String TemplateEngineType);

	/** Get Template Engine Type	  */
	public String getTemplateEngineType();

    /** Column name Updated */
    public static final String COLUMNNAME_Updated = "Updated";

	/** Get Updated	  */
	public Timestamp getUpdated();

    /** Column name UpdatedBy */
    public static final String COLUMNNAME_UpdatedBy = "UpdatedBy";

	/** Get Updated By	  */
	public int getUpdatedBy();
}
