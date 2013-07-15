--
-- Created by ada_generator.py on 2013-06-11 18:39:29.761568
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

package body Standard_User_Type_IO is

   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Strings;

   package gsi renames GNATCOLL.SQL_Impl;
   package gsp renames GNATCOLL.SQL.Postgres;
   package gse renames GNATCOLL.SQL.Exec;
   
   use Base_Types;
   
   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "STANDARD_USER_TYPE_IO" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;
   
   
   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   
   --
   -- generic packages to handle each possible type of decimal, if any, go here
   --
   function make_criterion_element_Decimal_12_2 is new d.Make_Decimal_Criterion_Element( Decimal_12_2 );


   
   --
   -- Select all variables; substring to be competed with output from some criteria
   --
   SELECT_PART : constant String := "select " &
         "user_id, username, password, type1, type2, a_bigint, a_real, a_decimal, a_double, a_boolean," &
         "a_varchar, a_date " &
         " from standard_user " ;
   
   --
   -- Insert all variables; substring to be competed with output from some criteria
   --
   INSERT_PART : constant String := "insert into standard_user (" &
         "user_id, username, password, type1, type2, a_bigint, a_real, a_decimal, a_double, a_boolean," &
         "a_varchar, a_date " &
         " ) values " ;

   
   --
   -- delete all the records identified by the where SQL clause 
   --
   DELETE_PART : constant String := "delete from standard_user ";
   
   --
   -- update
   --
   UPDATE_PART : constant String := "update standard_user set  ";
   
   
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
      query      : constant String := "select max( user_id ) from standard_user";
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
   -- returns true if the primary key parts of Standard_User_Type match the defaults in Simple_Pg_Data.Null_Standard_User_Type
   --
   --
   -- Does this Standard_User_Type equal the default Simple_Pg_Data.Null_Standard_User_Type ?
   --
   function Is_Null( standard_user : Simple_Pg_Data.Standard_User_Type ) return Boolean is
   use Simple_Pg_Data;
   begin
      return standard_user = Simple_Pg_Data.Null_Standard_User_Type;
   end Is_Null;


   
   --
   -- returns the single Standard_User_Type matching the primary key fields, or the Simple_Pg_Data.Null_Standard_User_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( User_Id : Integer; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_User_Type is
      l : Simple_Pg_Data.Standard_User_Type_List.Vector;
      standard_user : Simple_Pg_Data.Standard_User_Type;
      c : d.Criteria;
   begin      
      Add_User_Id( c, User_Id );
      l := Retrieve( c, connection );
      if( not Simple_Pg_Data.Standard_User_Type_List.is_empty( l ) ) then
         standard_user := Simple_Pg_Data.Standard_User_Type_List.First_Element( l );
      else
         standard_user := Simple_Pg_Data.Null_Standard_User_Type;
      end if;
      return standard_user;
   end Retrieve_By_PK;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_User_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_User_Type_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_User_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_User_Type_List.Vector is
      l : Simple_Pg_Data.Standard_User_Type_List.Vector;
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
           standard_user : Simple_Pg_Data.Standard_User_Type;
         begin
            if not gse.Is_Null( cursor, 0 )then
               standard_user.User_Id := Integer( gse.Integer_Value( cursor, 0 ));
            end if;
            if not gse.Is_Null( cursor, 1 )then
               standard_user.Username:= To_Unbounded_String( gse.Value( cursor, 1 ));
            end if;
            if not gse.Is_Null( cursor, 2 )then
               standard_user.Password:= To_Unbounded_String( gse.Value( cursor, 2 ));
            end if;
            if not gse.Is_Null( cursor, 3 )then
               declare
                  i : constant Integer := gse.Integer_Value( cursor, 3 );
               begin
                  standard_user.Type1 := standard_user_type1_Enum'Val( i );
               end;            end if;
            if not gse.Is_Null( cursor, 4 )then
               declare
                  i : constant Integer := gse.Integer_Value( cursor, 4 );
               begin
                  standard_user.Type2 := standard_user_type2_Enum'Val( i );
               end;            end if;
            if not gse.Is_Null( cursor, 5 )then
               standard_user.A_Bigint := Big_Integer( gse.Integer_Value( cursor, 5 ));
            end if;
            if not gse.Is_Null( cursor, 6 )then
               standard_user.A_Real:= Real( gse.Float_Value( cursor, 6 ));
            end if;
            if not gse.Is_Null( cursor, 7 )then
               standard_user.A_Decimal:= Decimal_12_2( gse.Float_Value( cursor, 7 ));
            end if;
            if not gse.Is_Null( cursor, 8 )then
               standard_user.A_Double:= Real( gse.Float_Value( cursor, 8 ));
            end if;
            if not gse.Is_Null( cursor, 9 )then
               declare
                  i : constant Integer := gse.Integer_Value( cursor, 9 );
               begin
                  standard_user.A_Boolean := Boolean'Val( i );
               end;            end if;
            if not gse.Is_Null( cursor, 10 )then
               standard_user.A_Varchar:= To_Unbounded_String( gse.Value( cursor, 10 ));
            end if;
            if not gse.Is_Null( cursor, 11 )then
               standard_user.A_Date := gse.Time_Value( cursor, 11 );
            end if;
            l.append( standard_user ); 
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
   procedure Update( standard_user : Simple_Pg_Data.Standard_User_Type; connection : Database_Connection := null ) is
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
      Add_Username( values_c, standard_user.Username );
      Add_Password( values_c, standard_user.Password );
      Add_Type1( values_c, standard_user.Type1 );
      Add_Type2( values_c, standard_user.Type2 );
      Add_A_Bigint( values_c, standard_user.A_Bigint );
      Add_A_Real( values_c, standard_user.A_Real );
      Add_A_Decimal( values_c, standard_user.A_Decimal );
      Add_A_Double( values_c, standard_user.A_Double );
      Add_A_Boolean( values_c, standard_user.A_Boolean );
      Add_A_Varchar( values_c, standard_user.A_Varchar );
      Add_A_Date( values_c, standard_user.A_Date );
      --
      -- primary key fields
      --
      Add_User_Id( pk_c, standard_user.User_Id );
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
   procedure Save( standard_user : Simple_Pg_Data.Standard_User_Type; overwrite : Boolean := True; connection : Database_Connection := null ) is   
      c : d.Criteria;
      standard_user_tmp : Simple_Pg_Data.Standard_User_Type;
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
         standard_user_tmp := retrieve_By_PK( standard_user.User_Id );
         if( not is_Null( standard_user_tmp )) then
            Update( standard_user );
            return;
         end if;
      end if;
      Add_User_Id( c, standard_user.User_Id );
      Add_Username( c, standard_user.Username );
      Add_Password( c, standard_user.Password );
      Add_Type1( c, standard_user.Type1 );
      Add_Type2( c, standard_user.Type2 );
      Add_A_Bigint( c, standard_user.A_Bigint );
      Add_A_Real( c, standard_user.A_Real );
      Add_A_Decimal( c, standard_user.A_Decimal );
      Add_A_Double( c, standard_user.A_Double );
      Add_A_Boolean( c, standard_user.A_Boolean );
      Add_A_Varchar( c, standard_user.A_Varchar );
      Add_A_Date( c, standard_user.A_Date );
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
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_User_Type
   --

   procedure Delete( standard_user : in out Simple_Pg_Data.Standard_User_Type; connection : Database_Connection := null ) is
         c : d.Criteria;
   begin  
      Add_User_Id( c, standard_user.User_Id );
      Delete( c, connection );
      standard_user := Simple_Pg_Data.Null_Standard_User_Type;
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
   function Retrieve_Associated_Group_Members_Types( standard_user : Simple_Pg_Data.Standard_User_Type; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
      c : d.Criteria;
   begin
      Group_Members_Type_IO.Add_User_Id( c, standard_user.User_Id );
      return Group_Members_Type_IO.retrieve( c, connection );
   end Retrieve_Associated_Group_Members_Types;



   --
   -- functions to add something to a criteria
   --
   procedure Add_User_Id( c : in out d.Criteria; User_Id : Integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "user_id", op, join, Integer( User_Id ) );
   begin
      d.add_to_criteria( c, elem );
   end Add_User_Id;


   procedure Add_Username( c : in out d.Criteria; Username : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "username", op, join, To_String( Username ), 16 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Username;


   procedure Add_Username( c : in out d.Criteria; Username : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "username", op, join, Username, 16 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Username;


   procedure Add_Password( c : in out d.Criteria; Password : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "password", op, join, To_String( Password ), 32 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Password;


   procedure Add_Password( c : in out d.Criteria; Password : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "password", op, join, Password, 32 );
   begin
      d.add_to_criteria( c, elem );
   end Add_Password;


   procedure Add_Type1( c : in out d.Criteria; Type1 : standard_user_type1_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "type1", op, join, Integer( standard_user_type1_Enum'Pos( Type1 )) );
   begin
      d.add_to_criteria( c, elem );
   end Add_Type1;


   procedure Add_Type2( c : in out d.Criteria; Type2 : standard_user_type2_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "type2", op, join, Integer( standard_user_type2_Enum'Pos( Type2 )) );
   begin
      d.add_to_criteria( c, elem );
   end Add_Type2;


   procedure Add_A_Bigint( c : in out d.Criteria; A_Bigint : Big_Integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_bigint", op, join, A_Bigint );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Bigint;


   procedure Add_A_Real( c : in out d.Criteria; A_Real : Real; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_real", op, join, A_Real );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Real;


   procedure Add_A_Decimal( c : in out d.Criteria; A_Decimal : Decimal_12_2; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := make_criterion_element_Decimal_12_2( "a_decimal", op, join, A_Decimal );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Decimal;


   procedure Add_A_Double( c : in out d.Criteria; A_Double : Real; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_double", op, join, A_Double );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Double;


   procedure Add_A_Boolean( c : in out d.Criteria; A_Boolean : Boolean; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_boolean", op, join, Integer( Boolean'Pos( A_Boolean )) );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Boolean;


   procedure Add_A_Varchar( c : in out d.Criteria; A_Varchar : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_varchar", op, join, To_String( A_Varchar ), 200 );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Varchar;


   procedure Add_A_Varchar( c : in out d.Criteria; A_Varchar : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_varchar", op, join, A_Varchar, 200 );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Varchar;


   procedure Add_A_Date( c : in out d.Criteria; A_Date : Ada.Calendar.Time; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "a_date", op, join, A_Date );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Date;


   
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_User_Id_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "user_id", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_User_Id_To_Orderings;


   procedure Add_Username_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "username", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Username_To_Orderings;


   procedure Add_Password_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "password", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Password_To_Orderings;


   procedure Add_Type1_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "type1", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Type1_To_Orderings;


   procedure Add_Type2_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "type2", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Type2_To_Orderings;


   procedure Add_A_Bigint_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_bigint", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Bigint_To_Orderings;


   procedure Add_A_Real_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_real", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Real_To_Orderings;


   procedure Add_A_Decimal_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_decimal", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Decimal_To_Orderings;


   procedure Add_A_Double_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_double", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Double_To_Orderings;


   procedure Add_A_Boolean_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_boolean", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Boolean_To_Orderings;


   procedure Add_A_Varchar_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_varchar", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Varchar_To_Orderings;


   procedure Add_A_Date_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "a_date", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_A_Date_To_Orderings;


   
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Standard_User_Type_IO;
