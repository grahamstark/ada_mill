--
-- Created by ada_generator.py on 2013-06-11 18:39:29.766647
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

with GNATCOLL.SQL.Exec;


-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Standard_Group_Type_IO is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   
   use GNATCOLL.SQL.Exec;
   

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   

   --
   -- returns true if the primary key parts of Standard_Group_Type match the defaults in Simple_Pg_Data.Null_Standard_Group_Type
   --
   function Is_Null( standard_group : Simple_Pg_Data.Standard_Group_Type ) return Boolean;
   
   --
   -- returns the single Standard_Group_Type matching the primary key fields, or the Simple_Pg_Data.Null_Standard_Group_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( Name : Unbounded_String; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_Group_Type;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_Group_Type_List.Vector;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Standard_Group_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := null ) return Simple_Pg_Data.Standard_Group_Type_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( standard_group : Simple_Pg_Data.Standard_Group_Type; overwrite : Boolean := True; connection : Database_Connection := null );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Standard_Group_Type
   --
   procedure Delete( standard_group : in out Simple_Pg_Data.Standard_Group_Type; connection : Database_Connection := null );
   --
   -- delete the records indentified by the criteria
   --
   procedure Delete( c : d.Criteria; connection : Database_Connection := null );
   --
   -- delete all the records identified by the where SQL clause 
   --
   procedure Delete( where_Clause : String; connection : Database_Connection := null );
   --
   -- functions to retrieve records from tables with foreign keys
   -- referencing the table modelled by this package
   --
   function Retrieve_Associated_Group_Members_Types( standard_group : Simple_Pg_Data.Standard_Group_Type; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector;

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

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

  
end Standard_Group_Type_IO;
