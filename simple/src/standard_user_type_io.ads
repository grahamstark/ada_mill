--
-- Created by ada_generator.py on 2013-06-11 17:03:46.797835
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

with DB_Commons.ODBC;

with Test_Package;
with Test_Package_2;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Standard_User_Type_IO is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   
   use DB_Commons.ODBC;
   
   use Test_Package;
   use Test_Package_2;

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   
   function Next_Free_User_Id( connection : Database_Connection := Null_Database_Connection) return Integer;

   --
   -- returns true if the primary key parts of Standard_User_Type match the defaults in Simple_Pg_Data.Null_Standard_User_Type
   --
   function Is_Null( standard_user : Simple_Pg_Data.Standard_User_Type ) return Boolean;
   
   --
   -- returns the single Standard_User_Type matching the primary key fields, or the Simple_Pg_Data.Null_Standard_User_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( User_Id : Integer; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Standard_User_Type;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_User_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Standard_User_Type_List.Vector;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_User_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Standard_User_Type_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( standard_user : Simple_Pg_Data.Standard_User_Type; overwrite : Boolean := True; connection : Database_Connection := Null_Database_Connection );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_User_Type
   --
   procedure Delete( standard_user : in out Simple_Pg_Data.Standard_User_Type; connection : Database_Connection := Null_Database_Connection );
   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria; connection : Database_Connection := Null_Database_Connection );
   --
   -- delete all the records identified by the where SQL clause 
   --
   procedure Delete( where_Clause : String; connection : Database_Connection := Null_Database_Connection );
   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --
   function Retrieve_Associated_Group_Members_Types( standard_user : Simple_Pg_Data.Standard_User_Type; connection : Database_Connection := Null_Database_Connection ) return Simple_Pg_Data.Group_Members_Type_List.Vector;

   --
   -- functions to add something to a criteria
   --
   procedure Add_User_Id( c : in out d.Criteria; User_Id : Integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Username( c : in out d.Criteria; Username : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Username( c : in out d.Criteria; Username : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Password( c : in out d.Criteria; Password : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Password( c : in out d.Criteria; Password : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Type1( c : in out d.Criteria; Type1 : An_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Type2( c : in out d.Criteria; Type2 : standard_user_type2_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Date_Created( c : in out d.Criteria; Date_Created : Ada.Calendar.Time; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_User_Id_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Username_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Password_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Type1_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Type2_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Date_Created_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

  
end Standard_User_Type_IO;
