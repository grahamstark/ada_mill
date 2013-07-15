--
-- Created by ada_generator.py on 2013-06-11 17:03:46.910551
-- 
with Simple_Pg_Data;


with Ada.Containers.Vectors;

with Environment;

with DB_Commons; 

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
with GNATColl.Traces;


-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Group_Members_Type_IO is

   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Strings;

   package dodbc renames DB_Commons.ODBC;
   package sql_info renames GNU.DB.SQLCLI.Info;
   package sql renames GNU.DB.SQLCLI;
   
   use Base_Types;
   use GNU.DB.SQLCLI;
   
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
   

   
   -- 
   -- Next highest avaiable value of User_Id - useful for saving  
   --
   function Next_Free_User_Id( connection : Database_Connection := Null_Database_Connection) return Integer is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      local_connection : Database_Connection;
      locally_allocated_connection : Boolean;

      query : constant String := "select max( user_id ) from group_members";
      ai : aliased Integer;
      has_data : boolean := true; 
      output_len : aliased sql.SQLLEN;     
   begin
      if( connection = Null_Database_Connection )then
         local_connection := Connection_Pool.Lease;
         locally_allocated_connection := True;
      else
         local_connection := connection;
         locally_allocated_connection := False;         
      end if;
   
      ps := dodbc.Initialise_Prepared_Statement( local_connection.connection, query );       
      dodbc.I_Out_Binding.SQLBindCol( 
            StatementHandle  => ps, 
            ColumnNumber     => 1, 
            TargetValue      => ai'access, 
            IndPtr           => output_len'Access );
      SQLExecute( ps );
      loop
         dodbc.next_row( ps, has_data );
         if( not has_data ) then
            exit;
         end if;
         if( ai = Base_Types.MISSING_I_KEY ) then
            ai := 1;
         else
            ai := ai + 1;
         end if;        
      end loop;
      dodbc.Close_Prepared_Statement( ps );
      if( locally_allocated_connection )then
         Connection_Pool.Return_Connection( local_connection );
      end if;
      return ai;
   exception 
      when Error : others =>
         Raise_Exception( d.DB_Exception'Identity, 
            "next_free_user_id: exception thrown " & Exception_Information(Error) );
      return  Base_Types.MISSING_I_KEY;    
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
   function Retrieve_By_PK( Group_Name : Unbounded_String; User_Id : Integer; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Group_Members_Type is
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
   function Retrieve( c : d.Criteria; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
      type Timestamp_Access is access all SQL_TIMESTAMP_STRUCT;
      type Real_Access is access all Real;
      type String_Access is access all String;

      l : Simple_Pg_Data.Group_Members_Type_List.Vector;
      ps : SQLHDBC := SQL_NULL_HANDLE;
      has_data : Boolean := false;
      local_connection : dodbc.Database_Connection;
      locally_allocated_connection : Boolean;

      query : constant String := SELECT_PART & " " & sqlstr;
      --
      -- aliased local versions of fields 
      --
      Group_Name: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      User_Id: aliased integer;
      --
      -- access variables for any variables retrieved via access types
      --
      Group_Name_access : String_Access := Group_Name'access;
      --
      -- length holders for each retrieved variable
      --
      Group_Name_len : aliased SQLLEN := Group_Name'Size;
      User_Id_len : aliased SQLLEN := User_Id'Size;
      group_members : Simple_Pg_Data.Group_Members_Type;
   begin
      Log( "retrieve made this as query " & query );
      begin -- exception block
         if( connection = Null_Database_Connection )then
            local_connection := Connection_Pool.Lease;
            locally_allocated_connection := True;
         else
            local_connection := connection;
            locally_allocated_connection := False;         
         end if;

         ps := dodbc.Initialise_Prepared_Statement( local_connection.connection, query );       
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 1,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Group_Name_access.all'address ),
            BufferLength     => Group_Name_len,
            StrLen_Or_IndPtr => Group_Name_len'access );
         dodbc.I_Out_Binding.SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 2,
            TargetValue      => User_Id'access,
            IndPtr           => User_Id_len'access );
         SQLExecute( ps );
         loop
            dodbc.next_row( ps, has_data );
            if( not has_data ) then
               exit;
            end if;
            group_members.Group_Name := Slice_To_Unbounded( Group_Name, 1, Natural( Group_Name_len ) );
            group_members.User_Id := User_Id;
            Simple_Pg_Data.Group_Members_Type_List.append( l, group_members );        
         end loop;
         Log( "retrieve: Query Run OK" );
      exception 
         when No_Data => Null; 
         when Error : others =>
            Raise_Exception( d.DB_Exception'Identity, 
               "retrieve: exception " & Exception_Information(Error) );
      end; -- exception block
      begin
         dodbc.Close_Prepared_Statement( ps );
         if( locally_allocated_connection )then
            Connection_Pool.Return_Connection( local_connection );
         end if;
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
   procedure Update( group_members : Simple_Pg_Data.Group_Members_Type; connection : Database_Connection := Null_Database_Connection ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      local_connection : Database_Connection;
      locally_allocated_connection : Boolean;
      
      query : Unbounded_String := UPDATE_PART & To_Unbounded_String(" ");
      pk_c : d.Criteria;
      values_c : d.Criteria;
   begin
      --
      -- values to be updated
      --
      --
      -- primary key fields
      --
      Add_Group_Name( pk_c, group_members.Group_Name );
      Add_User_Id( pk_c, group_members.User_Id );
      query := query & d.To_String( values_c, "," ) & d.to_string( pk_c );
      Log( "update; executing query" & To_String(query) );
      begin -- exception block 
         if( connection = Null_Database_Connection )then
            local_connection := Connection_Pool.Lease;
            locally_allocated_connection := True;
         else
            local_connection := connection;
            locally_allocated_connection := False;         
         end if;

         ps := dodbc.Initialise_Prepared_Statement( local_connection.connection, query );
         
         SQLExecute( ps );
         Log( "update; execute query OK" );
      exception 
         when No_Data => Null; -- ignore if no updates made
         when Error : others =>
            Log( "update: failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "update: exception thrown " & Exception_Information(Error) );
      end; -- exception block
      dodbc.Close_Prepared_Statement( ps );
      if( locally_allocated_connection )then
         Connection_Pool.Return_Connection( local_connection );
      end if;
   end Update;


   --
   -- Save the compelete given record 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( group_members : Simple_Pg_Data.Group_Members_Type; overwrite : Boolean := True; connection : Database_Connection := Null_Database_Connection ) is   
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      local_connection : Database_Connection;
      locally_allocated_connection : Boolean;

      query : Unbounded_String := INSERT_PART & To_Unbounded_String(" ");
      c : d.Criteria;
      group_members_tmp : Simple_Pg_Data.Group_Members_Type;
   begin
      if( overwrite ) then
         group_members_tmp := retrieve_By_PK( group_members.Group_Name, group_members.User_Id );
         if( not is_Null( group_members_tmp )) then
            Update( group_members );
            return;
         end if;
      end if;
      Add_Group_Name( c, group_members.Group_Name );
      Add_User_Id( c, group_members.User_Id );
      query := query & "( "  & d.To_Crude_Array_Of_Values( c ) & " )";
      Log( "save; executing query" & To_String(query) );
      begin
         if( connection = Null_Database_Connection )then
            local_connection := Connection_Pool.Lease;
            locally_allocated_connection := True;
         else
            local_connection := connection;
            locally_allocated_connection := False;         
         end if;
         ps := dodbc.Initialise_Prepared_Statement( local_connection.connection, query );       
         SQLExecute( ps );
         Log( "save; execute query OK" );         
      exception 
         when Error : others =>
            Log( "save; execute query failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "save: exception thrown " & Exception_Information(Error) );
      end;
      begin
         dodbc.Close_Prepared_Statement( ps );
         if( locally_allocated_connection )then
            Connection_Pool.Return_Connection( local_connection );
         end if;
      exception 
         when Error : others =>
            Log( "save/close " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "save/close: exception " & Exception_Information(Error) );
      end;
      
   end Save;


   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Group_Members_Type
   --

   procedure Delete( group_members : in out Simple_Pg_Data.Group_Members_Type; connection : Database_Connection := Null_Database_Connection ) is
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
   procedure Delete( c : d.Criteria; connection : Database_Connection := Null_Database_Connection ) is
   begin      
      delete( d.to_string( c ), connection );
      Log( "delete criteria; execute query OK" );
   end Delete;
   
   procedure Delete( where_Clause : String; connection : Database_Connection :=Null_Database_Connection ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      local_connection : dodbc.Database_Connection;
      locally_allocated_connection : Boolean;
      query : Unbounded_String := DELETE_PART & To_Unbounded_String(" ");
   begin
      query := query & where_Clause;
      begin -- try catch block for execute
         Log( "delete; executing query" & To_String(query) );
         if( connection = Null_Database_Connection )then
            local_connection := Connection_Pool.Lease;
            locally_allocated_connection := True;
         else
            local_connection := connection;
            locally_allocated_connection := False;         
         end if;

         ps := dodbc.Initialise_Prepared_Statement( local_connection.connection, query );       
         SQLExecute( ps );
         Log( "delete; execute query OK" );
      exception 
         when Error : No_Data => Null; -- silently ignore no data exception, which is hardly exceptional
         when Error : others =>
            Log( "delete; execute query failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "delete: exception thrown " & Exception_Information(Error) );
      end;
      begin -- try catch block for close
         dodbc.Close_Prepared_Statement( ps );
         if( locally_allocated_connection )then
            Connection_Pool.Return_Connection( local_connection );
         end if;
      exception 
         when Error : others =>
            Log( "delete; execute query failed with message " & Exception_Information(Error)  );
            Raise_Exception( d.DB_Exception'Identity, 
               "delete: exception thrown " & Exception_Information(Error) );
      end;
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
