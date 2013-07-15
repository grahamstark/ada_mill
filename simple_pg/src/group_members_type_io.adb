--
-- Created by ada_generator.py on 2013-06-11 18:39:29.779550
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


-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Group_Members_Type_IO is

   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Strings;

   package gsi renames GNATCOLL.SQL_Impl;
   package gsp renames GNATCOLL.SQL.Postgres;
   package gse renames GNATCOLL.SQL.Exec;
   
   use Base_Types;
   
   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "GROUP_MEMBERS_TYPE_IO" );
   
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
         "group_name, user_id " &
         " from group_members " ;
   
   --
   -- Insert all variables; substring to be competed with output from some criteria
   --
   INSERT_PART : constant String := "insert into group_members (" &
         "group_name, user_id " &
         " ) values " ;

   
   --
   -- delete all the records identified by the where SQL clause 
   --
   DELETE_PART : constant String := "delete from group_members ";
   
   --
   -- update
   --
   UPDATE_PART : constant String := "update group_members set  ";
   
   
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
   -- Next highest avaiable value of User_Id - useful for saving  
   --
   function Next_Free_User_Id( connection : Database_Connection := null) return Integer is
      query      : constant String := "select max( user_id ) from group_members";
      cursor     : gse.Forward_Cursor;
      ai         : Integer := 0;
      ps : gse.Prepared_Statement;
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

      ps := gse.Prepare( query, On_Server => True );
      cursor.Fetch( local_connection, ps );
      Check_Result( local_connection );
      if( gse.Has_Row( cursor ))then
         ai := gse.Integer_Value( cursor, 0 );
      end if;
      if( is_local_connection )then
         Connection_Pool.Return_Connection( local_connection );
      end if;
      return ai+1;
   end Next_Free_User_Id;



   --
   -- returns true if the primary key parts of Group_Members_Type match the defaults in Simple_Pg_Data.Null_Group_Members_Type
   --
   --
   -- Does this Group_Members_Type equal the default Simple_Pg_Data.Null_Group_Members_Type ?
   --
   function Is_Null( group_members : Simple_Pg_Data.Group_Members_Type ) return Boolean is
   use Simple_Pg_Data;
   begin
      return group_members = Simple_Pg_Data.Null_Group_Members_Type;
   end Is_Null;


   
   --
   -- returns the single Group_Members_Type matching the primary key fields, or the Simple_Pg_Data.Null_Group_Members_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( Group_Name : Unbounded_String; User_Id : Integer; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type is
      l : Simple_Pg_Data.Group_Members_Type_List.Vector;
      group_members : Simple_Pg_Data.Group_Members_Type;
      c : d.Criteria;
   begin      
      Add_Group_Name( c, Group_Name );
      Add_User_Id( c, User_Id );
      l := Retrieve( c, connection );
      if( not Simple_Pg_Data.Group_Members_Type_List.is_empty( l ) ) then
         group_members := Simple_Pg_Data.Group_Members_Type_List.First_Element( l );
      else
         group_members := Simple_Pg_Data.Null_Group_Members_Type;
      end if;
      return group_members;
   end Retrieve_By_PK;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
      l : Simple_Pg_Data.Group_Members_Type_List.Vector;
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
           group_members : Simple_Pg_Data.Group_Members_Type;
         begin
            if not gse.Is_Null( cursor, 0 )then
               group_members.Group_Name:= To_Unbounded_String( gse.Value( cursor, 0 ));
            end if;
            if not gse.Is_Null( cursor, 1 )then
               group_members.User_Id := Integer( gse.Integer_Value( cursor, 1 ));
            end if;
            l.append( group_members ); 
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
   procedure Update( group_members : Simple_Pg_Data.Group_Members_Type; connection : Database_Connection := null ) is
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
      --
      -- primary key fields
      --
      Add_Group_Name( pk_c, group_members.Group_Name );
      Add_User_Id( pk_c, group_members.User_Id );
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
   procedure Save( group_members : Simple_Pg_Data.Group_Members_Type; overwrite : Boolean := True; connection : Database_Connection := null ) is   
      c : d.Criteria;
      group_members_tmp : Simple_Pg_Data.Group_Members_Type;
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
         group_members_tmp := retrieve_By_PK( group_members.Group_Name, group_members.User_Id );
         if( not is_Null( group_members_tmp )) then
            Update( group_members );
            return;
         end if;
      end if;
      Add_Group_Name( c, group_members.Group_Name );
      Add_User_Id( c, group_members.User_Id );
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
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Group_Members_Type
   --

   procedure Delete( group_members : in out Simple_Pg_Data.Group_Members_Type; connection : Database_Connection := null ) is
         c : d.Criteria;
   begin  
      Add_Group_Name( c, group_members.Group_Name );
      Add_User_Id( c, group_members.User_Id );
      Delete( c, connection );
      group_members := Simple_Pg_Data.Null_Group_Members_Type;
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

   --
   -- functions to add something to a criteria
   --
   procedure Add_Group_Name( c : in out d.Criteria; Group_Name : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "group_name", op, join, To_String( Group_Name ), 30 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Group_Name;


   procedure Add_Group_Name( c : in out d.Criteria; Group_Name : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "group_name", op, join, Group_Name, 30 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Group_Name;


   procedure Add_User_Id( c : in out d.Criteria; User_Id : Integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "user_id", op, join, User_Id );
   begin
      d.add_to_criteria( c, elem );
   end Add_User_Id;


   
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Group_Name_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "group_name", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Group_Name_To_Orderings;


   procedure Add_User_Id_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "user_id", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_User_Id_To_Orderings;


   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Group_Members_Type_IO;
