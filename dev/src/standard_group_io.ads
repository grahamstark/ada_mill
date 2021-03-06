--
-- Created by ada_generator.py on 2012-02-23 13:59:30.848846
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

package Standard_Group_IO is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   

   --
   -- returns true if the primary key parts of Standard_Group match the defaults in Simple_Pg_Data.Null_Standard_Group
   --
   function Is_Null( Standard_Group : Simple_Pg_Data.Standard_Group ) return Boolean;
   
   --
   -- returns the single Standard_Group matching the primary key fields, or the Simple_Pg_Data.Null_Standard_Group record
   -- if no such record exists
   --
   function Retrieve_By_PK( Name : Unbounded_String ) return Simple_Pg_Data.Standard_Group;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria ) return Simple_Pg_Data.Standard_Group_List.Vector;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String ) return Simple_Pg_Data.Standard_Group_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( Standard_Group : Simple_Pg_Data.Standard_Group; overwrite : Boolean := True );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_Group
   --
   procedure Delete( Standard_Group : in out Simple_Pg_Data.Standard_Group );
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
   function Retrieve_Associated_Group_Members( Standard_Group : Simple_Pg_Data.Standard_Group ) return Simple_Pg_Data.Group_Members_List.Vector;

   --
   -- functions to add something to a criteria
   --
   procedure Add_Name( c : in out d.Criteria; Name : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Name( c : in out d.Criteria; Name : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Description( c : in out d.Criteria; Description : Unbounded_String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   procedure Add_Description( c : in out d.Criteria; Description : String; op : d.operation_type:= d.eq; join : d.join_type := d.join_and );
   --
   -- functions to add an ordering to a criteria
   --
   procedure Add_Name_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
   procedure Add_Description_To_Orderings( c : in out d.Criteria; direction : d.Asc_Or_Desc );
 
end Standard_Group_IO;
