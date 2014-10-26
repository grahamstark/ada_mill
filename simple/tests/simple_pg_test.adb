--
-- Created by ada_generator.py on 2014-02-01 16:13:07.781336
-- 


with Ada.Calendar;
with Ada.Exceptions;
with Ada.Strings.Unbounded; 

with GNATColl.Traces;

with AUnit.Assertions;             
with AUnit.Test_Cases; 

with Base_Types;
with Environment;

with DB_Commons;
with Simple_Pg_Data;

with Connection_Pool;

with Standard_User_IO;
with Standard_Group_IO;
with Group_Members_IO;

with Test_Package;
with Test_Package_2;

-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Simple_Pg_Test is

   RECORDS_TO_ADD     : constant integer := 100;
   RECORDS_TO_DELETE  : constant integer := 50;
   RECORDS_TO_ALTER   : constant integer := 50;
   
   package d renames DB_Commons;
   
   use Base_Types;
   use ada.strings.Unbounded;
   use Simple_Pg_Data;
   use Test_Package;
   use Test_Package_2;

   log_trace : GNATColl.Traces.Trace_Handle := GNATColl.Traces.Create( "SIMPLE_PG_TEST" );
   
   procedure Log( s : String ) is
   begin
      GNATColl.Traces.Trace( log_trace, s );
   end Log;

   
      -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===

   use AUnit.Test_Cases;
   use AUnit.Assertions;
   use AUnit.Test_Cases.Registration;
   
   use Ada.Strings.Unbounded;
   use Ada.Exceptions;
   use Ada.Calendar;
   
   
--
-- test creating and deleting records  
--
--
   procedure Standard_User_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Standard_User_List.Cursor ) is 
      a_standard_user_test_item : Simple_Pg_Data.Standard_User;
      begin
         a_standard_user_test_item := Standard_User_List.element( pos );
         Log( To_String( a_standard_user_test_item ));
      end print;

   
      a_standard_user_test_item : Simple_Pg_Data.Standard_User;
      a_standard_user_test_list : Simple_Pg_Data.Standard_User_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Standard_User_Create_Test" );
      
      Log( "Clearing out the table" );
      Standard_User_IO.Delete( criteria );
      
      Log( "Standard_User_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         a_standard_user_test_item.user_id := Standard_User_IO.Next_Free_user_id;
         a_standard_user_test_item.username := To_Unbounded_String("dat forusername");
         a_standard_user_test_item.password := To_Unbounded_String("dat forpassword");
         -- missinga_standard_user_test_item declaration ;
         -- missinga_standard_user_test_item declaration ;
         a_standard_user_test_item.date_created := Ada.Calendar.Clock;
         Standard_User_IO.Save( a_standard_user_test_item, False );         
      end loop;
      
      a_standard_user_test_list := Standard_User_IO.Retrieve( criteria );
      
      Log( "Standard_User_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         a_standard_user_test_item := Standard_User_List.element( a_standard_user_test_list, i );
         a_standard_user_test_item.username := To_Unbounded_String("Altered::dat forusername");
         a_standard_user_test_item.password := To_Unbounded_String("Altered::dat forpassword");
         Standard_User_IO.Save( a_standard_user_test_item );         
      end loop;
      
      Log( "Standard_User_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         a_standard_user_test_item := Standard_User_List.element( a_standard_user_test_list, i );
         Standard_User_IO.Delete( a_standard_user_test_item );         
      end loop;
      
      Log( "Standard_User_Create_Test: retrieve all records" );
      Standard_User_List.iterate( a_standard_user_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Standard_User_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Standard_User_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Standard_User_Create_Test : exception thrown " & Exception_Information(Error) );
   end Standard_User_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Standard_Group_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Standard_Group_List.Cursor ) is 
      a_standard_group_test_item : Simple_Pg_Data.Standard_Group;
      begin
         a_standard_group_test_item := Standard_Group_List.element( pos );
         Log( To_String( a_standard_group_test_item ));
      end print;

   
      a_standard_group_test_item : Simple_Pg_Data.Standard_Group;
      a_standard_group_test_list : Simple_Pg_Data.Standard_Group_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Standard_Group_Create_Test" );
      
      Log( "Clearing out the table" );
      Standard_Group_IO.Delete( criteria );
      
      Log( "Standard_Group_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         a_standard_group_test_item.name := To_Unbounded_String( "k_" & i'img );
         a_standard_group_test_item.description := To_Unbounded_String("dat fordescription");
         Standard_Group_IO.Save( a_standard_group_test_item, False );         
      end loop;
      
      a_standard_group_test_list := Standard_Group_IO.Retrieve( criteria );
      
      Log( "Standard_Group_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         a_standard_group_test_item := Standard_Group_List.element( a_standard_group_test_list, i );
         a_standard_group_test_item.description := To_Unbounded_String("Altered::dat fordescription");
         Standard_Group_IO.Save( a_standard_group_test_item );         
      end loop;
      
      Log( "Standard_Group_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         a_standard_group_test_item := Standard_Group_List.element( a_standard_group_test_list, i );
         Standard_Group_IO.Delete( a_standard_group_test_item );         
      end loop;
      
      Log( "Standard_Group_Create_Test: retrieve all records" );
      Standard_Group_List.iterate( a_standard_group_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Standard_Group_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Standard_Group_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Standard_Group_Create_Test : exception thrown " & Exception_Information(Error) );
   end Standard_Group_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Group_Members_Create_Test(  T : in out AUnit.Test_Cases.Test_Case'Class ) is
      --
      -- local print iteration routine
      --
      procedure Print( pos : Group_Members_List.Cursor ) is 
      a_group_members_test_item : Simple_Pg_Data.Group_Members;
      begin
         a_group_members_test_item := Group_Members_List.element( pos );
         Log( To_String( a_group_members_test_item ));
      end print;

   
      a_group_members_test_item : Simple_Pg_Data.Group_Members;
      a_group_members_test_list : Simple_Pg_Data.Group_Members_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Group_Members_Create_Test" );
      
      Log( "Clearing out the table" );
      Group_Members_IO.Delete( criteria );
      
      Log( "Group_Members_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         a_group_members_test_item.group_name := To_Unbounded_String( "k_" & i'img );
         a_group_members_test_item.user_id := Group_Members_IO.Next_Free_user_id;
         Group_Members_IO.Save( a_group_members_test_item, False );         
      end loop;
      
      a_group_members_test_list := Group_Members_IO.Retrieve( criteria );
      
      Log( "Group_Members_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         a_group_members_test_item := Group_Members_List.element( a_group_members_test_list, i );
         Group_Members_IO.Save( a_group_members_test_item );         
      end loop;
      
      Log( "Group_Members_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         a_group_members_test_item := Group_Members_List.element( a_group_members_test_list, i );
         Group_Members_IO.Delete( a_group_members_test_item );         
      end loop;
      
      Log( "Group_Members_Create_Test: retrieve all records" );
      Group_Members_List.iterate( a_group_members_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Group_Members_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Group_Members_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Group_Members_Create_Test : exception thrown " & Exception_Information(Error) );
   end Group_Members_Create_Test;

   
   
   
   
   
   procedure Register_Tests (T : in out Test_Case) is
   begin
      --
      -- Tests of record creation/deletion
      --
      Register_Routine (T, Standard_User_Create_Test'Access, "Test of Creation and deletion of Standard_User" );
      Register_Routine (T, Standard_Group_Create_Test'Access, "Test of Creation and deletion of Standard_Group" );
      Register_Routine (T, Group_Members_Create_Test'Access, "Test of Creation and deletion of Group_Members" );
      --
      -- Tests of foreign key relationships
      --
      --  not implemented yet Register_Routine (T, Standard_User_Child_Retrieve_Test'Access, "Test of Finding Children of Standard_User" );
      --  not implemented yet Register_Routine (T, Standard_Group_Child_Retrieve_Test'Access, "Test of Finding Children of Standard_Group" );
   end Register_Tests;
   
   --  Register routines to be run
   
   
   function Name ( t : Test_Case ) return Message_String is
   begin
      return Format( "Simple_Pg_Test Test Suite" );
   end Name;

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===
   
   --  Preparation performed before each routine:
   procedure Set_Up( t : in out Test_Case ) is
   begin
       Connection_Pool.Initialise(
              Environment.Get_Server_Name,
              Environment.Get_Database_Name,
              Environment.Get_Username,
              Environment.Get_Password,
              10 );
      GNATColl.Traces.Parse_Config_File( "./etc/logging_config_file.txt" );
   end Set_Up;
   
   --  Preparation performed after each routine:
   procedure Shut_Down( t : in out Test_Case ) is
   begin
      Connection_Pool.Shutdown;
   end Shut_Down;
   
   
begin
   null;
end Simple_Pg_Test;
