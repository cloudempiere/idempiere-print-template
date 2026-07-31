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

/** Generated Interface for AD_PrintTemplate_Include
 *  @author iDempiere (generated) 
 *  @version Release 12
 */
@SuppressWarnings("all")
public interface I_AD_PrintTemplate_Include 
{

    /** TableName=AD_PrintTemplate_Include */
    public static final String Table_Name = "AD_PrintTemplate_Include";

    /** AD_Table_ID=5000007 */
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

	public I_AD_PrintTemplate getAD_PrintTemplate() throws RuntimeException;

    /** Column name AD_PrintTemplate_Include_ID */
    public static final String COLUMNNAME_AD_PrintTemplate_Include_ID = "AD_PrintTemplate_Include_ID";

	/** Set Print Template Include	  */
	public void setAD_PrintTemplate_Include_ID (int AD_PrintTemplate_Include_ID);

	/** Get Print Template Include	  */
	public int getAD_PrintTemplate_Include_ID();

    /** Column name AD_PrintTemplate_Include_UU */
    public static final String COLUMNNAME_AD_PrintTemplate_Include_UU = "AD_PrintTemplate_Include_UU";

	/** Set AD_PrintTemplate_Include_UU	  */
	public void setAD_PrintTemplate_Include_UU (String AD_PrintTemplate_Include_UU);

	/** Get AD_PrintTemplate_Include_UU	  */
	public String getAD_PrintTemplate_Include_UU();

    /** Column name AD_Table_ID */
    public static final String COLUMNNAME_AD_Table_ID = "AD_Table_ID";

	/** Set Table.
	  * Tabela filha a carregar (FK reversa pro registro raiz)
	  */
	public void setAD_Table_ID (int AD_Table_ID);

	/** Get Table.
	  * Tabela filha a carregar (FK reversa pro registro raiz)
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

    /** Column name IncludeNested */
    public static final String COLUMNNAME_IncludeNested = "IncludeNested";

	/** Set Include Nested	  */
	public void setIncludeNested (boolean IncludeNested);

	/** Get Include Nested	  */
	public boolean isIncludeNested();

    /** Column name IsActive */
    public static final String COLUMNNAME_IsActive = "IsActive";

	/** Set Active	  */
	public void setIsActive (boolean IsActive);

	/** Get Active	  */
	public boolean isActive();

    /** Column name MaxRows */
    public static final String COLUMNNAME_MaxRows = "MaxRows";

	/** Set Max Rows	  */
	public void setMaxRows (int MaxRows);

	/** Get Max Rows	  */
	public int getMaxRows();

    /** Column name OrderByClause */
    public static final String COLUMNNAME_OrderByClause = "OrderByClause";

	/** Set Sql ORDER BY	  */
	public void setOrderByClause (String OrderByClause);

	/** Get Sql ORDER BY	  */
	public String getOrderByClause();

    /** Column name SeqNo */
    public static final String COLUMNNAME_SeqNo = "SeqNo";

	/** Set Sequence	  */
	public void setSeqNo (int SeqNo);

	/** Get Sequence	  */
	public int getSeqNo();

    /** Column name TargetName */
    public static final String COLUMNNAME_TargetName = "TargetName";

	/** Set Target Name.
	  * Nome da coleção no data model (ex.: lines)
	  */
	public void setTargetName (String TargetName);

	/** Get Target Name.
	  * Nome da coleção no data model (ex.: lines)
	  */
	public String getTargetName();

    /** Column name Updated */
    public static final String COLUMNNAME_Updated = "Updated";

	/** Get Updated	  */
	public Timestamp getUpdated();

    /** Column name UpdatedBy */
    public static final String COLUMNNAME_UpdatedBy = "UpdatedBy";

	/** Get Updated By	  */
	public int getUpdatedBy();

    /** Column name WhereClause */
    public static final String COLUMNNAME_WhereClause = "WhereClause";

	/** Set Sql WHERE.
	  * Filtro adicional (sem prefixo AND)
	  */
	public void setWhereClause (String WhereClause);

	/** Get Sql WHERE.
	  * Filtro adicional (sem prefixo AND)
	  */
	public String getWhereClause();
}
