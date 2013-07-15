--
-- Created by ada_generator.py on 2013-04-04 14:16:21.691792
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

with Test_Package;
with Test_Package_2;

package My_Record_IO_Base is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   
   use Test_Package;
   use Test_Package_2;
   
   function Next_Free_User_Id return Integer;

   --
   -- returns true if the primary key parts of My_Record match the defaults in Null_My_Record
   --
   function Is_Null( standard_user : My_Record ) return Boolean;
   
   --
   -- returns the single My_Record matching the primary key fields, or the Null_My_Record record
   -- if no such record exists
   --
   function Retrieve_By_PK( User_Id : Integer ) return My_Record;
   
   --
   -- Retrieves a list of My_Record matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return My_Record_List.Vector;
   
   --
   -- Retrieves a list of My_Record retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return My_Record_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( standard_user : My_Record; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Null_My_Record
   --
   procedure Delete( standard_user : in out My_Record );
   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria );
   --
   -- delete all the records identified by the where SQL clause 
   --
   procedure Delete( where_Clause : String );
   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --
   function Retrieve_Associated_Group_Members_Types( standard_user : My_Record ) return Simple_Pg_Data.Group_Members_Type_List.Vector;

   --
   -- functions to add something to a criteria
   --
   procedure Add_User_Id( c : in out d.Criteria; User_Id : Integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Username( c : in out d.Criteria; Username : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Username( c : in out d.Criteria; Username : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Password( c : in out d.Criteria; Password : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Password( c : in out d.Criteria; Password : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Salary( c : in out d.Criteria; Salary : Decimal_10_2; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Rate( c : in out d.Criteria; Rate : A_Float; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Type1( c : in out d.Criteria; Type1 : An_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Type2( c : in out d.Criteria; Type2 : standard_user_type2_Enum; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Date_Created( c : in out d.Criteria; Date_Created : Ada.Calendar.Time; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_User_Id_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Username_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Password_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Salary_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Rate_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Type1_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Type2_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Date_Created_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end My_Record_IO_Base;
