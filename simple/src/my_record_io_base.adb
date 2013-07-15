--
-- Created by ada_generator.py on 2013-04-04 14:16:21.780307
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

package body My_Record_IO_Base is

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
   function make_criterion_element_Decimal_10_2 is new d.Make_Decimal_Criterion_Element( Decimal_10_2 );
   
   --
   -- Select all variables; substring to be competed with output from some criteria
   --
   SELECT_PART : constant String := "select " &
         "user_id, username, password, salary, rate, type1, type2, date_created " &
         " from standard_user " ;
   
   --
   -- Insert all variables; substring to be competed with output from some criteria
   --
   INSERT_PART : constant String := "insert into standard_user (" &
         "user_id, username, password, salary, rate, type1, type2, date_created " &
         " ) values " ;

   
   --
   -- delete all the records identified by the where SQL clause 
   --
   DELETE_PART : constant String := "delete from standard_user ";
   
   --
   -- update
   --
   UPDATE_PART : constant String := "update standard_user set  ";
   
   
   -- 
   -- Next highest avaiable value of User_Id - useful for saving  
   --
   function Next_Free_User_Id return Integer is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection := Connection_Pool.Lease;
      query : constant String := "select max( user_id ) from standard_user";
      ai : aliased Integer;
      has_data : boolean := true; 
      output_len : aliased sql.SQLLEN;     
   begin
      ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
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
      Connection_Pool.Return_Connection( connection );
      return ai;
   exception 
      when Error : others =>
         Raise_Exception( d.DB_Exception'Identity, 
            "next_free_user_id: exception thrown " & Exception_Information(Error) );
      return  Base_Types.MISSING_I_KEY;    
   end Next_Free_User_Id;



   --
   -- returns true if the primary key parts of My_Record match the defaults in Null_My_Record
   --
   --
   -- Does this My_Record equal the default Null_My_Record ?
   --
   function Is_Null( standard_user : My_Record ) return Boolean is
   use Simple_Pg_Data;
   begin
      return standard_user = Null_My_Record;
   end Is_Null;


   
   --
   -- returns the single My_Record matching the primary key fields, or the Null_My_Record record
   -- if no such record exists
   --
   function Retrieve_By_PK( User_Id : Integer ) return My_Record is
      l : My_Record_List.Vector;
      standard_user : My_Record;
      c : d.Criteria;
   begin      
      Add_User_Id( c, User_Id );
      l := Retrieve( c );
      if( not My_Record_List.is_empty( l ) ) then
         standard_user := My_Record_List.First_Element( l );
      else
         standard_user := Null_My_Record;
      end if;
      return standard_user;
   end Retrieve_By_PK;

   
   --
   -- Retrieves a list of My_Record matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return My_Record_List.Vector is
   begin      
      return Retrieve( d.to_string( c ) );
   end Retrieve;

   
   --
   -- Retrieves a list of My_Record retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return My_Record_List.Vector is
      type Timestamp_Access is access all SQL_TIMESTAMP_STRUCT;
      type Real_Access is access all Real;
      type String_Access is access all String;

      l : My_Record_List.Vector;
      ps : SQLHDBC := SQL_NULL_HANDLE;
      has_data : Boolean := false;
      connection : dodbc.Database_Connection := Connection_Pool.Lease;
      query : constant String := SELECT_PART & " " & sqlstr;
      --
      -- aliased local versions of fields 
      --
      User_Id: aliased integer;
      Username: aliased String := 
            "@@@@@@@@@@@@@@@@";
      Password: aliased String := 
            "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@";
      Salary: aliased Real;
      Rate: aliased Real;
      Type1: aliased Integer;
      Type2: aliased Integer;
      Date_Created: aliased SQL_TIMESTAMP_STRUCT;
      --
      -- access variables for any variables retrieved via access types
      --
      Username_access : String_Access := Username'access;
      Password_access : String_Access := Password'access;
      Salary_access : Real_Access := Salary'access;
      Rate_access : Real_Access := Rate'access;
      Date_Created_access : Timestamp_Access := Date_Created'access;
      --
      -- length holders for each retrieved variable
      --
      User_Id_len : aliased SQLLEN := User_Id'Size;
      Username_len : aliased SQLLEN := Username'Size;
      Password_len : aliased SQLLEN := Password'Size;
      Salary_len : aliased SQLLEN := Salary'Size;
      Rate_len : aliased SQLLEN := Rate'Size;
      Type1_len : aliased SQLLEN := Type1'Size;
      Type2_len : aliased SQLLEN := Type2'Size;
      Date_Created_len : aliased SQLLEN := Date_Created'Size;
      standard_user : My_Record;
   begin
      DB_Logger.info( "retrieve made this as query " & query );
      begin -- exception block
         ps := dodbc.Initialise_Prepared_Statement( connection.connection, query );       
         dodbc.I_Out_Binding.SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 1,
            TargetValue      => User_Id'access,
            IndPtr           => User_Id_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 2,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Username_access.all'address ),
            BufferLength     => Username_len,
            StrLen_Or_IndPtr => Username_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 3,
            TargetType       => SQL_C_CHAR,
            TargetValuePtr   => To_SQLPOINTER( Password_access.all'address ),
            BufferLength     => Password_len,
            StrLen_Or_IndPtr => Password_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            TargetType       => SQL_C_DOUBLE,
            ColumnNumber     => 4,
            TargetValuePtr   => To_SQLPOINTER( Salary_access.all'address ),
            BufferLength     => 0,
            StrLen_Or_IndPtr => Salary_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            TargetType       => SQL_C_DOUBLE,
            ColumnNumber     => 5,
            TargetValuePtr   => To_SQLPOINTER( Rate_access.all'address ),
            BufferLength     => 0,
            StrLen_Or_IndPtr => Rate_len'access );
         dodbc.I_Out_Binding.SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 6,
            TargetValue      => Type1'access,
            IndPtr           => Type1_len'access );
         dodbc.I_Out_Binding.SQLBindCol(
            StatementHandle  => ps,
            ColumnNumber     => 7,
            TargetValue      => Type2'access,
            IndPtr           => Type2_len'access );
         SQLBindCol(
            StatementHandle  => ps,
            TargetType       => SQL_C_TYPE_TIMESTAMP,
            ColumnNumber     => 8,
            TargetValuePtr   => To_SQLPOINTER( Date_Created_access.all'address ),
            BufferLength     => 0,
            StrLen_Or_IndPtr => Date_Created_len'access );
         SQLExecute( ps );
         loop
            dodbc.next_row( ps, has_data );
            if( not has_data ) then
               exit;
            end if;
            standard_user.User_Id := User_Id;
            standard_user.Username := Slice_To_Unbounded( Username, 1, Natural( Username_len ) );
            standard_user.Password := Slice_To_Unbounded( Password, 1, Natural( Password_len ) );
            standard_user.Salary:= Decimal_10_2( Salary_access.all );
            standard_user.Rate:= A_Float( Rate_access.all );
            standard_user.Type1 := An_Enum'Val( Type1 );
            standard_user.Type2 := standard_user_type2_Enum'Val( Type2 );
            standard_user.Date_Created:= dodbc.Timestamp_To_Ada_Time( Date_Created_access.all );
            My_Record_List.append( l, standard_user );        
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
   procedure Update( standard_user : My_Record ) is
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection := Connection_Pool.Lease;
      query : Unbounded_String := UPDATE_PART & To_Unbounded_String(" ");
      pk_c : d.Criteria;
      values_c : d.Criteria;
   begin
      --
      -- values to be updated
      --
      Add_Username( values_c, standard_user.Username );
      Add_Password( values_c, standard_user.Password );
      Add_Salary( values_c, standard_user.Salary );
      Add_Rate( values_c, standard_user.Rate );
      Add_Type1( values_c, standard_user.Type1 );
      Add_Type2( values_c, standard_user.Type2 );
      Add_Date_Created( values_c, standard_user.Date_Created );
      --
      -- primary key fields
      --
      Add_User_Id( pk_c, standard_user.User_Id );
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
   procedure Save( standard_user : My_Record; overwrite : Boolean := True ) is   
      ps : sql.SQLHDBC := sql.SQL_NULL_HANDLE;
      connection : dodbc.Database_Connection;
      query : Unbounded_String := INSERT_PART & To_Unbounded_String(" ");
      c : d.Criteria;
      standard_user_tmp : My_Record;
   begin
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
      Add_Salary( c, standard_user.Salary );
      Add_Rate( c, standard_user.Rate );
      Add_Type1( c, standard_user.Type1 );
      Add_Type2( c, standard_user.Type2 );
      Add_Date_Created( c, standard_user.Date_Created );
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
   -- Delete the given record. Throws DB_Exception exception. Sets value to Null_My_Record
   --

   procedure Delete( standard_user : in out My_Record ) is
         c : d.Criteria;
   begin  
      Add_User_Id( c, standard_user.User_Id );
      delete( c );
      standard_user := Null_My_Record;
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
   function Retrieve_Associated_Group_Members_Types( standard_user : My_Record ) return Simple_Pg_Data.Group_Members_Type_List.Vector is
      c : d.Criteria;
   begin
      Group_Members_Type_IO.Add_User_Id( c, standard_user.User_Id );
      return Group_Members_Type_IO.retrieve( c );
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


   procedure Add_Salary( c : in out d.Criteria; Salary : Decimal_10_2; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := make_criterion_element_Decimal_10_2( "salary", op, join, Salary );
   begin
      d.add_to_criteria( c, elem );
   end Add_Salary;


   procedure Add_Rate( c : in out d.Criteria; Rate : A_Float; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "rate", op, join, Real( Rate ) );
   begin
      d.add_to_criteria( c, elem );
   end Add_Rate;


   procedure Add_Type1( c : in out d.Criteria; Type1 : An_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "type1", op, join, Integer( An_Enum'Pos( Type1 )) );
   begin
      d.add_to_criteria( c, elem );
   end Add_Type1;


   procedure Add_Type2( c : in out d.Criteria; Type2 : standard_user_type2_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "type2", op, join, Integer( standard_user_type2_Enum'Pos( Type2 )) );
   begin
      d.add_to_criteria( c, elem );
   end Add_Type2;


   procedure Add_Date_Created( c : in out d.Criteria; Date_Created : Ada.Calendar.Time; op : d.operation_type:= d.eq; join : d.join_type := d.join_and ) is   
   elem : d.Criterion := d.make_Criterion_Element( "date_created", op, join, Date_Created );
   begin
      d.add_to_criteria( c, elem );
   end Add_Date_Created;


   
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


   procedure Add_Salary_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "salary", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Salary_To_Orderings;


   procedure Add_Rate_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "rate", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Rate_To_Orderings;


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


   procedure Add_Date_Created_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc ) is   
   elem : d.Order_By_Element := d.Make_Order_By_Element( "date_created", direction  );
   begin
      d.add_to_criteria( c, elem );
   end Add_Date_Created_To_Orderings;


   
end My_Record_IO_Base;
