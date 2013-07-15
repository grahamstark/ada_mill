--
-- Created by ada_generator.py on 2013-04-04 14:16:21.786783
-- 
with Simple_Pg_Data;


with Ada.Containers.Vectors;

with Environment;

with DB_Commons; 
with DB_Commons.ODBC; 

with GNU.DB.SQLCLI;  
with GNU.DB.SQLCLI.Bind;
with GNU.DB.SQLCLI.Info;
with GNU.DB.SQLCLI.Environment_Attribute;
with GNU.DB.SQLCLI.Connection_Attribute;

with Ada.Exceptions;  
with Ada.Strings; 
with Ada.Strings.Wide_Fixed;
with Ada.Characters.Conversions;
with Ada.Strings.Unbounded; 
with Text_IO;
with Ada.Strings.Maps;
with Connection_Pool;

with Group_Members_Type_IO;

with DB_Logger;

package body Standard_Group_Type_IO_Base is

   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Strings;

   package dodbc renames DB_Commons.ODBC;
   package sql renames GNU.DB.SQLCLI;
   package sql_info renames GNU.DB.SQLCLI.Info;
   use sql;
   use Base_Types;
   --
   -- generic packages to handle each possible type of decimal, if any, go here
   --
   
   --
   -- Select all variables; substring to be competed with output from some criteria
   --
   SELECT_PART : constant String := "select " &
         "name, description " &
         " from standard_group " ;
   
   --
   -- Insert all variables; substring to be competed with output from some criteria
   --
   INSERT_PART : constant String := "insert into standard_group (" &
         "name, description " &
         " ) values " ;

   
   --
   -- delete all the records identified by the where SQL clause 
   --
   DELETE_PART : constant String := "delete from standard_group ";
   
   --
   -- update
   --
   UPDATE_PART : constant String := "update standard_group set  ";
   
   

   --
   -- returns true if the primary key parts of Standard_Group_Type match the defaults in Simple_Pg_Data.Null_Standard_Group_Type
   --
   --
   -- Does this Standard_Group_Type equal the default Simple_Pg_Data.Null_Standard_Group_Type ?
   --
   function Is_Null( standard_group : Simple_Pg_Data.Standard_Group_Type ) return Boolean is
   use Simple_Pg_Data;
   begin
      return standard_group = Simple_Pg_Data.Null_Standard_Group_Type;
   end Is_Null;


   
   --
   -- returns the single Standard_Group_Type matching the primary key fields, or the Simple_Pg_Data.Null_Standard_Group_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( Name : Unbounded_String ) return Simple_Pg_Data.Standard_Group_Type is
      l : Simple_Pg_Data.Standard_Group_Type_List.Vector;
      standard_group : Simple_Pg_Data.Standard_Group_Type;
      c : d.Criteria;
   begin      
      Add_Name( c, Name );
      l := Retrieve( c );
      if( not Simple_Pg_Data.Standard_Group_Type_List.is_empty( l ) ) then
         standard_group := Simple_Pg_Data.Standard_Group_Type_List.First_Element( l );
      else
         standard_group := Simple_Pg_Data.Null_Standard_Group_Type;
      end if;
      return standard_group;
   end Retrieve_By_PK;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Simple_Pg_Data.Standard_Group_Type_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Simple_Pg_Data.Standard_Group_Type_List.Vector is
      type Timestamp_Access is access all SQL_TIMESTAMP_STRUCT;
      type Real_Access is access all Real;
      type String_Access is access all String;

      l : Simple_Pg_Data.Standard_Group_Type_List.Vector;
      ps : SQLHDBC := SQL_NULL_HANDLE;
      has_data : Boolean := false;
      connection : dodbc.Database_Connection := Connection_Pool.Lease;
      query : constant String := SELECT_PART & " " & sqlstr;
      --
      -- aliased local versions of fields 
      --
      Name: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      Description: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" &
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      --
      -- access variables for any variables retrieved via access types
      --
      Name_access : String_Access := Name'access;
      Description_access : String_Access := Description'access;
      --
      -- length holders for each retrieved variable
      --
      Name_len : aliased SQLLEN := Name'Size;
      Description_len : aliased SQLLEN := Description'Size;
      standard_group : Simple_Pg_Data.Standard_Group_Type;
   begin
      DB_Logger.info( "retrieve made this as query " & query );
      begin -- exception block
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 1,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Name_access.all'address ),
            BufferLength     => Name_len,
            StrLen_Or_IndPtr => Name_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 2,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Description_access.all'address ),
            BufferLength     => Description_len,
            StrLen_Or_IndPtr => Description_len'access );
         SQLExecute( ps );
         loop
            dodbc.next_row( ps, has_data );
            if( not has_data ) then
               exit;
            end if;
            standard_group.Name := Slice_To_Unbounded( Name, 1, Natural( Name_len ) );
            standard_group.Description := Slice_To_Unbounded( Description, 1, Natural( Description_len ) );
            Simple_Pg_Data.Standard_Group_Type_List.append( l, standard_group );        
         end loop;
         DB_Logger.info( "retrieve: Query Run OK" );
      exception 
         when No_Data => Null; 
         when Error : others =>
            Raise_Exception( d.DB_Exception'Identity, 
               "retrieve: exception " & Exception_Information(Error) );
      end; -- exception block
      begin
         dodbc.Close_Prepared_Statement( ps );
         Connection_Pool.Return_Connection( connection );
      exception 
         when Error : others =>
            Raise_Exception( d.DB_Exception'Identity, 
               "retrieve: exception " & Exception_Information(Error) );
      end; -- exception block
      return l;
   end Retrieve;

   
   --
   -- Update the given record 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Update( standard_group : Simple_Pg_Data.Standard_Group_Type ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection := Connection_Pool.Lease;
      query : Unbounded_String := UPDATE_PART & To_Unbounded_String(" ");
      pk_c : d.Criteria;
      values_c : d.Criteria;
   begin
      --
      -- values to be updated
      --
      Add_Description( values_c, standard_group.Description );
      --
      -- primary key fields
      --
      Add_Name( pk_c, standard_group.Name );
      query := query & d.To_String( values_c, "," ) & d.to_string( pk_c );
      DB_Logger.info( "update; executing query" & To_String(query) );
      begin -- exception block      
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLExecute( ps );
         DB_Logger.info( "update; execute query OK" );
      exception 
         when No_Data => Null; -- ignore if no updates made
         when Error : others =>
            DB_Logger.error( "update: failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "update: exception thrown " & Exception_Information(Error) );
      end; -- exception block
      dodbc.Close_Prepared_Statement( ps );
      Connection_Pool.Return_Connection( connection );
   end Update;


   --
   -- Save the compelete given record 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( standard_group : Simple_Pg_Data.Standard_Group_Type; overwrite : Boolean := True ) is   
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection;
      query : Unbounded_String := INSERT_PART & To_Unbounded_String(" ");
      c : d.Criteria;
      standard_group_tmp : Simple_Pg_Data.Standard_Group_Type;
   begin
      if( overwrite ) then
         standard_group_tmp := retrieve_By_PK( standard_group.Name );
         if( not is_Null( standard_group_tmp )) then
            Update( standard_group );
            return;
         end if;
      end if;
      Add_Name( c, standard_group.Name );
      Add_Description( c, standard_group.Description );
      query := query & "( "  & d.To_Crude_Array_Of_Values( c ) & " )";
      DB_Logger.info( "save; executing query" & To_String(query) );
      begin
         connection := Connection_Pool.Lease;
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLExecute( ps );
         DB_Logger.info( "save; execute query OK" );
         
      exception 
         when Error : others =>
            DB_Logger.error( "save; execute query failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "save: exception thrown " & Exception_Information(Error) );
      end;
      begin
         dodbc.Close_Prepared_Statement( ps );
         Connection_Pool.Return_Connection( connection );
      exception 
         when Error : others =>
            DB_Logger.error( "save/close " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "save/close: exception " & Exception_Information(Error) );
      end;
      
   end Save;


   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_Group_Type
   --

   procedure Delete( standard_group : in out Simple_Pg_Data.Standard_Group_Type ) is
         c : d.Criteria;
   begin  
      Add_Name( c, standard_group.Name );
      delete( c );
      standard_group := Simple_Pg_Data.Null_Standard_Group_Type;
      DB_Logger.info( "delete record; execute query OK" );
   end Delete;


   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria ) is
   begin      
      delete( d.to_string( c ) );
      DB_Logger.info( "delete criteria; execute query OK" );
   end Delete;
   
   procedure Delete( where_Clause : String ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection;
      query : Unbounded_String := DELETE_PART & To_Unbounded_String(" ");
   begin
      query := query & where_Clause;
      begin -- try catch block for execute
         DB_Logger.info( "delete; executing query" & To_String(query) );
         connection := Connection_Pool.Lease;
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         SQLExecute( ps );
         DB_Logger.info( "delete; execute query OK" );
      exception 
         when Error : No_Data => Null; -- silently ignore no data exception, which is hardly exceptional
         when Error : others =>
            DB_Logger.error( "delete; execute query failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "delete: exception thrown " & Exception_Information(Error) );
      end;
      begin -- try catch block for close
         dodbc.Close_Prepared_Statement( ps );
         Connection_Pool.Return_Connection( connection );
      exception 
         when Error : others =>
            DB_Logger.error( "delete; execute query failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "delete: exception thrown " & Exception_Information(Error) );
      end;
   end Delete;


   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --
   function Retrieve_Associated_Group_Members_Types( standard_group : Simple_Pg_Data.Standard_Group_Type ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
      c : d.Criteria;
   begin
      Group_Members_Type_IO.Add_Group_Name( c, standard_group.Name );
      return Group_Members_Type_IO.retrieve( c );
   end Retrieve_Associated_Group_Members_Types;



   --
   -- functions to add something to a criteria
   --
   procedure Add_Name( c : in out d.Criteria; Name : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "name", op, join, To_String( Name ), 30 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Name;


   procedure Add_Name( c : in out d.Criteria; Name : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "name", op, join, Name, 30 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Name;


   procedure Add_Description( c : in out d.Criteria; Description : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "description", op, join, To_String( Description ), 120 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Description;


   procedure Add_Description( c : in out d.Criteria; Description : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "description", op, join, Description, 120 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Description;


   
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Name_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "name", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Name_To_Orderings;


   procedure Add_Description_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "description", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Description_To_Orderings;


   
end Standard_Group_Type_IO_Base;
