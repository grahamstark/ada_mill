--
-- Created by ada_generator.py on 2013-06-11 18:39:29.772359
-- 
with Simple_Pg_Data;


with Ada.Containers.Vectors;

with Environment;

with DB_Commons; 

with GNATCOLL.SQL_Impl;
with GNATCOLL.SQL.Postgres;


with Ada.Exceptions;  
with Ada.Strings; 
with Ada.Strings.Wide_Fixed;
with Ada.Characters.Conversions;
with Ada.Strings.Unbounded; 
with Text_IO;
with Ada.Strings.Maps;
with Connection_Pool;
with GNATColl.Traces;

with Group_Members_Type_IO;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Standard_Group_Type_IO is

   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Strings;

   package gsi renames GNATCOLL.SQL_Impl;
   package gsp renames GNATCOLL.SQL.Postgres;
   package gse renames GNATCOLL.SQL.Exec;
   
   use Base_Types;
   
   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "STANDARD_GROUP_TYPE_IO" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;
   
   
   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   
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
   
   
   procedure Check_Result( conn : in out gse.Database_Connection ) is
      error_msg : constant String := gse.Error( conn );
   begin
      if( error_msg /= "" )then
         Log( error_msg );
         Connection_Pool.Return_Connection( conn );
         Raise_Exception( db_commons.DB_Exception'Identity, error_msg );
      end if;
   end  Check_Result;     


   

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
   function Retrieve_By_PK( Name : Unbounded_String; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_Group_Type is
      l : Simple_Pg_Data.Standard_Group_Type_List.Vector;
      standard_group : Simple_Pg_Data.Standard_Group_Type;
      c : d.Criteria;
   begin      
      Add_Name( c, Name );
      l := Retrieve( c, connection );
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
   function Retrieve( c : d.Criteria; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_Group_Type_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_Group_Type_List.Vector is
      l : Simple_Pg_Data.Standard_Group_Type_List.Vector;
      ps : gse.Prepared_Statement;
      local_connection : Database_Connection;
      is_local_connection : Boolean;
      query : constant String := SELECT_PART & " " & sqlstr;
      cursor   : gse.Forward_Cursor;
   begin
      if( connection = null )then
          local_connection := Connection_Pool.Lease;
          is_local_connection := True;
      else
          local_connection := connection;          
          is_local_connection := False;
      end if;
      Log( "retrieve made this as query " & query );
      ps := gse.Prepare( query, On_Server => True );
      cursor.Fetch( local_connection, ps );
      Check_Result( local_connection );
      while gse.Has_Row( cursor ) loop
         declare
           standard_group : Simple_Pg_Data.Standard_Group_Type;
         begin
            if not gse.Is_Null( cursor, 0 )then
               standard_group.Name:= To_Unbounded_String( gse.Value( cursor, 0 ));
            end if;
            if not gse.Is_Null( cursor, 1 )then
               standard_group.Description:= To_Unbounded_String( gse.Value( cursor, 1 ));
            end if;
            l.append( standard_group ); 
         end;
         gse.Next( cursor );
      end loop;
      if( is_local_connection )then
         local_connection.Commit;
         Connection_Pool.Return_Connection( local_connection );
      end if;
      return l;
   end Retrieve;

   
   --
   -- Update the given record 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Update( standard_group : Simple_Pg_Data.Standard_Group_Type; connection : Database_Connection := null ) is
      pk_c : d.Criteria;
      values_c : d.Criteria;
      local_connection : Database_Connection;
      is_local_connection : Boolean;

   begin
      if( connection = null )then
          local_connection := Connection_Pool.Lease;
          is_local_connection := True;
      else
          local_connection := connection;          
          is_local_connection := False;
      end if;

      --
      -- values to be updated
      --
      Add_Description( values_c, standard_group.Description );
      --
      -- primary key fields
      --
      Add_Name( pk_c, standard_group.Name );
      declare      
         query : constant String := UPDATE_PART & " " & d.To_String( values_c, "," ) & d.To_String( pk_c );
      begin
         Log( "update; executing query" & query );
         gse.Execute( local_connection, query );
         Check_Result( local_connection );
         if( is_local_connection )then
            local_connection.Commit;
            Connection_Pool.Return_Connection( local_connection );
         end if;
      end;
   end Update;


   --
   -- Save the compelete given record 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( standard_group : Simple_Pg_Data.Standard_Group_Type; overwrite : Boolean := True; connection : Database_Connection := null ) is   
      c : d.Criteria;
      standard_group_tmp : Simple_Pg_Data.Standard_Group_Type;
      local_connection : Database_Connection;
      is_local_connection : Boolean;
   begin
      if( connection = null )then
          local_connection := Connection_Pool.Lease;
          is_local_connection := True;
      else
          local_connection := connection;          
          is_local_connection := False;
      end if;
      if( overwrite ) then
         standard_group_tmp := retrieve_By_PK( standard_group.Name );
         if( not is_Null( standard_group_tmp )) then
            Update( standard_group );
            return;
         end if;
      end if;
      Add_Name( c, standard_group.Name );
      Add_Description( c, standard_group.Description );
      declare
         query : constant String := INSERT_PART & " ( "  & d.To_Crude_Array_Of_Values( c ) & " )";
      begin
         Log( "save; executing query" & query );
         gse.Execute( local_connection, query );
         local_connection.Commit;
         Check_Result( local_connection );
      end;   
      if( is_local_connection )then
         Connection_Pool.Return_Connection( local_connection );
      end if;
   end Save;


   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_Group_Type
   --

   procedure Delete( standard_group : in out Simple_Pg_Data.Standard_Group_Type; connection : Database_Connection := null ) is
         c : d.Criteria;
   begin  
      Add_Name( c, standard_group.Name );
      Delete( c, connection );
      standard_group := Simple_Pg_Data.Null_Standard_Group_Type;
      Log( "delete record; execute query OK" );
   end Delete;


   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria; connection : Database_Connection := null ) is
   begin      
      delete( d.to_string( c ), connection );
      Log( "delete criteria; execute query OK" );
   end Delete;
   
   procedure Delete( where_Clause : String; connection : gse.Database_Connection := null ) is
      local_connection : gse.Database_Connection;     
      is_local_connection : Boolean;
      query : constant String := DELETE_PART & where_Clause;
   begin
      if( connection = null )then
          local_connection := Connection_Pool.Lease;
          is_local_connection := True;
      else
          local_connection := connection;          
          is_local_connection := False;
      end if;
      Log( "delete; executing query" & query );
      gse.Execute( local_connection, query );
      Check_Result( local_connection );
      Log( "delete; execute query OK" );
      if( is_local_connection )then
         local_connection.Commit;
         Connection_Pool.Return_Connection( local_connection );
      end if;
   end Delete;


   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --
   function Retrieve_Associated_Group_Members_Types( standard_group : Simple_Pg_Data.Standard_Group_Type; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
      c : d.Criteria;
   begin
      Group_Members_Type_IO.Add_Group_Name( c, standard_group.Name );
      return Group_Members_Type_IO.retrieve( c, connection );
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


   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Standard_Group_Type_IO;
