--
-- Created by ada_generator.py on 2013-06-11 18:39:29.773914
-- 
with Simple_Pg_Data;
with DB_Commons;
with Base_Types;
with ADA.Calendar;
with Ada.Strings.Unbounded;

with GNATCOLL.SQL.Exec;


-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Group_Members_Type_IO is
  
   package d renames DB_Commons;   
   use Base_Types;
   use Ada.Strings.Unbounded;
   
   use GNATCOLL.SQL.Exec;
   

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   
   function Next_Free_User_Id( connection : Database_Connection := null) return Integer;

   --
   -- returns true if the primary key parts of Group_Members_Type match the defaults in Simple_Pg_Data.Null_Group_Members_Type
   --
   function Is_Null( group_members : Simple_Pg_Data.Group_Members_Type ) return Boolean;
   
   --
   -- returns the single Group_Members_Type matching the primary key fields, or the Simple_Pg_Data.Null_Group_Members_Type record
   -- if no such record exists
   --
   function Retrieve_By_PK( Group_Name : Unbounded_String; User_Id : Integer; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type matching the criteria, or throws an exception
   --
   function Retrieve( c : d.Criteria; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector;
   
   --
   -- Retrieves a list of Simple_Pg_Data.Group_Members_Type retrived by the sql string, or throws an exception
   --
   function Retrieve( sqlstr : String; connection : Database_Connection := null ) return Simple_Pg_Data.Group_Members_Type_List.Vector;
   
   --
   -- Save the given record, overwriting if it exists and overwrite is true, 
   -- otherwise throws DB_Exception exception. 
   --
   procedure Save( group_members : Simple_Pg_Data.Group_Members_Type; overwrite : Boolean := True; connection : Database_Connection := null );
   
   --
   -- Delete the given record. Throws DB_Exception exception. Sets value to Simple_Pg_Data.Null_Group_Members_Type
   --
   procedure Delete( group_members : in out Simple_Pg_Data.Group_Members_Type; connection : Database_Connection := null );
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

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

  
end Group_Members_Type_IO;
