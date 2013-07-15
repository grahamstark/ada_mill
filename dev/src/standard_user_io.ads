--
-- Created by ada_generator.py on 2012-02-23 13:59:30.754260
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

package Standard_User_IO is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   
   function Next_Free_User_Id return integer;

   --
   -- returns true if the primary key parts of Standard_User match the defaults in Simple_Pg_Data.Null_Standard_User
   --
   function Is_Null( Standard_User : Simple_Pg_Data.Standard_User ) return Boolean;
   
   --
   -- returns the single Standard_User matching the primary key fields, or the Simple_Pg_Data.Null_Standard_User record
   -- if no such record exists
   --
   function Retrieve_By_PK( User_Id : integer ) return Simple_Pg_Data.Standard_User;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_User matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Simple_Pg_Data.Standard_User_List.Vector;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_User retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Simple_Pg_Data.Standard_User_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( Standard_User : Simple_Pg_Data.Standard_User; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_User
   --
   procedure Delete( Standard_User : in out Simple_Pg_Data.Standard_User );
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
   function Retrieve_Associated_Group_Members( Standard_User : Simple_Pg_Data.Standard_User ) return Simple_Pg_Data.Group_Members_List.Vector;

   --
   -- functions to add something to a criteria
   --
   procedure Add_User_Id( c : in out d.Criteria; User_Id : integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Username( c : in out d.Criteria; Username : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Username( c : in out d.Criteria; Username : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Password( c : in out d.Criteria; Password : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Password( c : in out d.Criteria; Password : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Salary( c : in out d.Criteria; Salary : Decimal_10_2; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Rate( c : in out d.Criteria; Rate : Real; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Date_Created( c : in out d.Criteria; Date_Created : Ada.Calendar.Time; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_User_Id_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Username_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Password_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Salary_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Rate_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Date_Created_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Standard_User_IO;
