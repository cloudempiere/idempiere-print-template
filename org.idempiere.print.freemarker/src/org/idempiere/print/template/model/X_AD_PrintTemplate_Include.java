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

/** Generated Model for AD_PrintTemplate_Include
 *  @author iDempiere (generated)
 *  @version Release 12 - $Id$ */
@org.adempiere.base.Model(table="AD_PrintTemplate_Include")
public class X_AD_PrintTemplate_Include extends PO implements I_AD_PrintTemplate_Include, I_Persistent
{

	/**
	 *
	 */
	private static final long serialVersionUID = 20260715L;

    /** Standard Constructor */
    public X_AD_PrintTemplate_Include (Properties ctx, int AD_PrintTemplate_Include_ID, String trxName)
    {
      super (ctx, AD_PrintTemplate_Include_ID, trxName);
      /** if (AD_PrintTemplate_Include_ID == 0)
        {
			setAD_PrintTemplate_ID (0);
			setAD_PrintTemplate_Include_ID (0);
			setAD_Table_ID (0);
			setIncludeNested (false);
// N
			setSeqNo (0);
// 10
			setTargetName (null);
        } */
    }

    /** Standard Constructor */
    public X_AD_PrintTemplate_Include (Properties ctx, int AD_PrintTemplate_Include_ID, String trxName, String ... virtualColumns)
    {
      super (ctx, AD_PrintTemplate_Include_ID, trxName, virtualColumns);
      /** if (AD_PrintTemplate_Include_ID == 0)
        {
			setAD_PrintTemplate_ID (0);
			setAD_PrintTemplate_Include_ID (0);
			setAD_Table_ID (0);
			setIncludeNested (false);
// N
			setSeqNo (0);
// 10
			setTargetName (null);
        } */
    }

    /** Standard Constructor */
    public X_AD_PrintTemplate_Include (Properties ctx, String AD_PrintTemplate_Include_UU, String trxName)
    {
      super (ctx, AD_PrintTemplate_Include_UU, trxName);
      /** if (AD_PrintTemplate_Include_UU == null)
        {
			setAD_PrintTemplate_ID (0);
			setAD_PrintTemplate_Include_ID (0);
			setAD_Table_ID (0);
			setIncludeNested (false);
// N
			setSeqNo (0);
// 10
			setTargetName (null);
        } */
    }

    /** Standard Constructor */
    public X_AD_PrintTemplate_Include (Properties ctx, String AD_PrintTemplate_Include_UU, String trxName, String ... virtualColumns)
    {
      super (ctx, AD_PrintTemplate_Include_UU, trxName, virtualColumns);
      /** if (AD_PrintTemplate_Include_UU == null)
        {
			setAD_PrintTemplate_ID (0);
			setAD_PrintTemplate_Include_ID (0);
			setAD_Table_ID (0);
			setIncludeNested (false);
// N
			setSeqNo (0);
// 10
			setTargetName (null);
        } */
    }

    /** Load Constructor */
    public X_AD_PrintTemplate_Include (Properties ctx, ResultSet rs, String trxName)
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
      StringBuilder sb = new StringBuilder ("X_AD_PrintTemplate_Include[")
        .append(get_ID()).append("]");
      return sb.toString();
    }

	public I_AD_PrintTemplate getAD_PrintTemplate() throws RuntimeException
	{
		return (I_AD_PrintTemplate)MTable.get(getCtx(), I_AD_PrintTemplate.Table_ID)
			.getPO(getAD_PrintTemplate_ID(), get_TrxName());
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

	/** Set Print Template Include.
		@param AD_PrintTemplate_Include_ID Print Template Include
	*/
	public void setAD_PrintTemplate_Include_ID (int AD_PrintTemplate_Include_ID)
	{
		if (AD_PrintTemplate_Include_ID < 1)
			set_ValueNoCheck (COLUMNNAME_AD_PrintTemplate_Include_ID, null);
		else
			set_ValueNoCheck (COLUMNNAME_AD_PrintTemplate_Include_ID, Integer.valueOf(AD_PrintTemplate_Include_ID));
	}

	/** Get Print Template Include.
		@return Print Template Include	  */
	public int getAD_PrintTemplate_Include_ID()
	{
		Integer ii = (Integer)get_Value(COLUMNNAME_AD_PrintTemplate_Include_ID);
		if (ii == null)
			 return 0;
		return ii.intValue();
	}

	/** Set AD_PrintTemplate_Include_UU.
		@param AD_PrintTemplate_Include_UU AD_PrintTemplate_Include_UU
	*/
	public void setAD_PrintTemplate_Include_UU (String AD_PrintTemplate_Include_UU)
	{
		set_Value (COLUMNNAME_AD_PrintTemplate_Include_UU, AD_PrintTemplate_Include_UU);
	}

	/** Get AD_PrintTemplate_Include_UU.
		@return AD_PrintTemplate_Include_UU	  */
	public String getAD_PrintTemplate_Include_UU()
	{
		return (String)get_Value(COLUMNNAME_AD_PrintTemplate_Include_UU);
	}

	public org.compiere.model.I_AD_Table getAD_Table() throws RuntimeException
	{
		return (org.compiere.model.I_AD_Table)MTable.get(getCtx(), org.compiere.model.I_AD_Table.Table_ID)
			.getPO(getAD_Table_ID(), get_TrxName());
	}

	/** Set Table.
		@param AD_Table_ID Tabela filha a carregar (FK reversa pro registro raiz)
	*/
	public void setAD_Table_ID (int AD_Table_ID)
	{
		if (AD_Table_ID < 1)
			set_Value (COLUMNNAME_AD_Table_ID, null);
		else
			set_Value (COLUMNNAME_AD_Table_ID, Integer.valueOf(AD_Table_ID));
	}

	/** Get Table.
		@return Tabela filha a carregar (FK reversa pro registro raiz)
	  */
	public int getAD_Table_ID()
	{
		Integer ii = (Integer)get_Value(COLUMNNAME_AD_Table_ID);
		if (ii == null)
			 return 0;
		return ii.intValue();
	}

	/** Set Include Nested.
		@param IncludeNested Include Nested
	*/
	public void setIncludeNested (boolean IncludeNested)
	{
		set_Value (COLUMNNAME_IncludeNested, Boolean.valueOf(IncludeNested));
	}

	/** Get Include Nested.
		@return Include Nested	  */
	public boolean isIncludeNested()
	{
		Object oo = get_Value(COLUMNNAME_IncludeNested);
		if (oo != null)
		{
			 if (oo instanceof Boolean)
				 return ((Boolean)oo).booleanValue();
			return "Y".equals(oo);
		}
		return false;
	}

	/** Set Max Rows.
		@param MaxRows Max Rows
	*/
	public void setMaxRows (int MaxRows)
	{
		set_Value (COLUMNNAME_MaxRows, Integer.valueOf(MaxRows));
	}

	/** Get Max Rows.
		@return Max Rows	  */
	public int getMaxRows()
	{
		Integer ii = (Integer)get_Value(COLUMNNAME_MaxRows);
		if (ii == null)
			 return 0;
		return ii.intValue();
	}

	/** Set Sql ORDER BY.
		@param OrderByClause Sql ORDER BY
	*/
	public void setOrderByClause (String OrderByClause)
	{
		set_Value (COLUMNNAME_OrderByClause, OrderByClause);
	}

	/** Get Sql ORDER BY.
		@return Sql ORDER BY	  */
	public String getOrderByClause()
	{
		return (String)get_Value(COLUMNNAME_OrderByClause);
	}

	/** Set Sequence.
		@param SeqNo Sequence
	*/
	public void setSeqNo (int SeqNo)
	{
		set_Value (COLUMNNAME_SeqNo, Integer.valueOf(SeqNo));
	}

	/** Get Sequence.
		@return Sequence	  */
	public int getSeqNo()
	{
		Integer ii = (Integer)get_Value(COLUMNNAME_SeqNo);
		if (ii == null)
			 return 0;
		return ii.intValue();
	}

	/** Set Target Name.
		@param TargetName Nome da coleção no data model (ex.: lines)
	*/
	public void setTargetName (String TargetName)
	{
		set_Value (COLUMNNAME_TargetName, TargetName);
	}

	/** Get Target Name.
		@return Nome da coleção no data model (ex.: lines)
	  */
	public String getTargetName()
	{
		return (String)get_Value(COLUMNNAME_TargetName);
	}

    /** Get Record ID/ColumnName
        @return ID/ColumnName pair
      */
    public KeyNamePair getKeyNamePair()
    {
        return new KeyNamePair(get_ID(), getTargetName());
    }

	/** Set Sql WHERE.
		@param WhereClause Filtro adicional (sem prefixo AND)
	*/
	public void setWhereClause (String WhereClause)
	{
		set_Value (COLUMNNAME_WhereClause, WhereClause);
	}

	/** Get Sql WHERE.
		@return Filtro adicional (sem prefixo AND)
	  */
	public String getWhereClause()
	{
		return (String)get_Value(COLUMNNAME_WhereClause);
	}
}