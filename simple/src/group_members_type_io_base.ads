--
-- Created by ada_generator.py on 2013-04-04 14:16:21.787314
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

with Test_Package;
with Test_Package_2;

package Group_Members_Type_IO_Base is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   
   use Test_Package;
   use Test_Package_2;
   
   function Next_Free_User_Id return Integer;

   --
   -- returns true if the primary key parts of Group_Members_Type match the defaults in Simple_Pg_Data.Null_Group_Members_Type
   --
   function Is_Null( group_members : Simple_Pg_Data.Group_Members_Type ) return Boolean;
   
   --
   -- returns the single Group_Members_Type matching the primary key fields, or the Simple_Pg_Data.Null_Group_Members_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( Group_Name : Unbounded_String; User_Id : Integer ) return Simple_Pg_Data.Group_Members_Type;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Simple_Pg_Data.Group_Members_Type_List.Vector;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Simple_Pg_Data.Group_Members_Type_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( group_members : Simple_Pg_Data.Group_Members_Type; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Group_Members_Type
   --
   procedure Delete( group_members : in out Simple_Pg_Data.Group_Members_Type );
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

   --
   -- functions to add something to a criteria
   --
   procedure Add_Group_Name( c : in out d.Criteria; Group_Name : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Group_Name( c : in out d.Criteria; Group_Name : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_User_Id( c : in out d.Criteria; User_Id : Integer; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Group_Name_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_User_Id_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Group_Members_Type_IO_Base;
