--
-- Created by ada_generator.py on 2014-11-10 20:22:15.500083
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

with Adrs_Data.standard_user_IO;
with Adrs_Data.standard_group_IO;
with Adrs_Data.group_members_IO;


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
   procedure Adrs_Data_standard_user_Create_Test( T : in out AUnit.Test_Cases.Test_Case'Class ) is
   
      --
      -- local print iteration routine
      --
      procedure Print( pos : Adrs_Data.standard_user_List.Cursor ) is 
      a_standard_user_test_item : Adrs_Data.standard_user;
      begin
         a_standard_user_test_item := Adrs_Data.standard_user_List.Vector.Element( pos );
         Log( To_String( a_standard_user_test_item ));
      end print;

   
      a_standard_user_test_item : Adrs_Data.standard_user;
      a_standard_user_test_list : Adrs_Data.standard_user_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Adrs_Data_standard_user_Create_Test" );
      
      Log( "Clearing out the table" );
      Adrs_Data.standard_user_IO.Delete( criteria );
      
      Log( "Adrs_Data_standard_user_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         a_standard_user_test_item.user_id := Adrs_Data.standard_user_IO.Next_Free_user_id;
         a_standard_user_test_item.username := To_Unbounded_String("dat forusername" & i'Img );
         a_standard_user_test_item.password := To_Unbounded_String("dat forpassword" & i'Img );
         -- missing declaration for a_standard_user_test_item.type1;
         -- missing declaration for a_standard_user_test_item.type2;
         -- missing declaration for a_standard_user_test_item.a_bigint;
         a_standard_user_test_item.a_real := 1010100.012 + Long_Float( i );
         a_standard_user_test_item.a_decimal := 10201.11;
         a_standard_user_test_item.a_double := 1010100.012 + Long_Float( i );
         -- missing declaration for a_standard_user_test_item.a_boolean;
         a_standard_user_test_item.a_varchar := To_Unbounded_String("dat fora_varchar" & i'Img );
         a_standard_user_test_item.a_date := Ada.Calendar.Clock;
         Adrs_Data.standard_user_IO.Save( a_standard_user_test_item, False );         
      end loop;
      
      a_standard_user_test_list := Adrs_Data.standard_user_IO.Retrieve( criteria );
      
      Log( "Adrs_Data_standard_user_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         a_standard_user_test_item := Adrs_Data.standard_user_List.element( a_standard_user_test_list, i );
         a_standard_user_test_item.username := To_Unbounded_String("Altered::dat forusername" & i'Img);
         a_standard_user_test_item.password := To_Unbounded_String("Altered::dat forpassword" & i'Img);
         a_standard_user_test_item.a_varchar := To_Unbounded_String("Altered::dat fora_varchar" & i'Img);
         Adrs_Data.standard_user_IO.Save( a_standard_user_test_item );         
      end loop;
      
      Log( "Adrs_Data_standard_user_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         a_standard_user_test_item := Adrs_Data.standard_user_List.element( a_standard_user_test_list, i );
         Adrs_Data.standard_user_IO.Delete( a_standard_user_test_item );         
      end loop;
      
      Log( "Adrs_Data_standard_user_Create_Test: retrieve all records" );
      Adrs_Data.standard_user_List.iterate( a_standard_user_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Adrs_Data_standard_user_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Adrs_Data_standard_user_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Adrs_Data_standard_user_Create_Test : exception thrown " & Exception_Information(Error) );
   end Adrs_Data_standard_user_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Adrs_Data_standard_group_Create_Test( T : in out AUnit.Test_Cases.Test_Case'Class ) is
   
      --
      -- local print iteration routine
      --
      procedure Print( pos : Adrs_Data.standard_group_List.Cursor ) is 
      a_standard_group_test_item : Adrs_Data.standard_group;
      begin
         a_standard_group_test_item := Adrs_Data.standard_group_List.Vector.Element( pos );
         Log( To_String( a_standard_group_test_item ));
      end print;

   
      a_standard_group_test_item : Adrs_Data.standard_group;
      a_standard_group_test_list : Adrs_Data.standard_group_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Adrs_Data_standard_group_Create_Test" );
      
      Log( "Clearing out the table" );
      Adrs_Data.standard_group_IO.Delete( criteria );
      
      Log( "Adrs_Data_standard_group_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         a_standard_group_test_item.name := To_Unbounded_String( "k_" & i'img );
         a_standard_group_test_item.description := To_Unbounded_String("dat fordescription" & i'Img );
         Adrs_Data.standard_group_IO.Save( a_standard_group_test_item, False );         
      end loop;
      
      a_standard_group_test_list := Adrs_Data.standard_group_IO.Retrieve( criteria );
      
      Log( "Adrs_Data_standard_group_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         a_standard_group_test_item := Adrs_Data.standard_group_List.element( a_standard_group_test_list, i );
         a_standard_group_test_item.description := To_Unbounded_String("Altered::dat fordescription" & i'Img);
         Adrs_Data.standard_group_IO.Save( a_standard_group_test_item );         
      end loop;
      
      Log( "Adrs_Data_standard_group_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         a_standard_group_test_item := Adrs_Data.standard_group_List.element( a_standard_group_test_list, i );
         Adrs_Data.standard_group_IO.Delete( a_standard_group_test_item );         
      end loop;
      
      Log( "Adrs_Data_standard_group_Create_Test: retrieve all records" );
      Adrs_Data.standard_group_List.iterate( a_standard_group_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Adrs_Data_standard_group_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Adrs_Data_standard_group_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Adrs_Data_standard_group_Create_Test : exception thrown " & Exception_Information(Error) );
   end Adrs_Data_standard_group_Create_Test;

   
--
-- test creating and deleting records  
--
--
   procedure Adrs_Data_group_members_Create_Test( T : in out AUnit.Test_Cases.Test_Case'Class ) is
   
      --
      -- local print iteration routine
      --
      procedure Print( pos : Adrs_Data.group_members_List.Cursor ) is 
      a_group_members_test_item : Adrs_Data.group_members;
      begin
         a_group_members_test_item := Adrs_Data.group_members_List.Vector.Element( pos );
         Log( To_String( a_group_members_test_item ));
      end print;

   
      a_group_members_test_item : Adrs_Data.group_members;
      a_group_members_test_list : Adrs_Data.group_members_List.Vector;
      criteria  : d.Criteria;
      startTime : Time;
      endTime   : Time;
      elapsed   : Duration;
   begin
      startTime := Clock;
      Log( "Starting test Adrs_Data_group_members_Create_Test" );
      
      Log( "Clearing out the table" );
      Adrs_Data.group_members_IO.Delete( criteria );
      
      Log( "Adrs_Data_group_members_Create_Test: create tests" );
      for i in 1 .. RECORDS_TO_ADD loop
         a_group_members_test_item.group_name := To_Unbounded_String( "k_" & i'img );
         a_group_members_test_item.user_id := Adrs_Data.group_members_IO.Next_Free_user_id;
         Adrs_Data.group_members_IO.Save( a_group_members_test_item, False );         
      end loop;
      
      a_group_members_test_list := Adrs_Data.group_members_IO.Retrieve( criteria );
      
      Log( "Adrs_Data_group_members_Create_Test: alter tests" );
      for i in 1 .. RECORDS_TO_ALTER loop
         a_group_members_test_item := Adrs_Data.group_members_List.element( a_group_members_test_list, i );
         Adrs_Data.group_members_IO.Save( a_group_members_test_item );         
      end loop;
      
      Log( "Adrs_Data_group_members_Create_Test: delete tests" );
      for i in RECORDS_TO_DELETE .. RECORDS_TO_ADD loop
         a_group_members_test_item := Adrs_Data.group_members_List.element( a_group_members_test_list, i );
         Adrs_Data.group_members_IO.Delete( a_group_members_test_item );         
      end loop;
      
      Log( "Adrs_Data_group_members_Create_Test: retrieve all records" );
      Adrs_Data.group_members_List.iterate( a_group_members_test_list, print'Access );
      endTime := Clock;
      elapsed := endTime - startTime;
      Log( "Ending test Adrs_Data_group_members_Create_Test. Time taken = " & elapsed'Img );

   exception 
      when Error : others =>
         Log( "Adrs_Data_group_members_Create_Test execute query failed with message " & Exception_Information(Error) );
         assert( False,  
            "Adrs_Data_group_members_Create_Test : exception thrown " & Exception_Information(Error) );
   end Adrs_Data_group_members_Create_Test;

   
   
   
   
   
   procedure Register_Tests (T : in out Test_Case) is
   begin
      --
      -- Tests of record creation/deletion
      --
      Register_Routine (T, Adrs_Data_standard_user_Create_Test'Access, "Test of Creation and deletion of Adrs_Data.standard_user" );
      Register_Routine (T, Adrs_Data_standard_group_Create_Test'Access, "Test of Creation and deletion of Adrs_Data.standard_group" );
      Register_Routine (T, Adrs_Data_group_members_Create_Test'Access, "Test of Creation and deletion of Adrs_Data.group_members" );
      --
      -- Tests of foreign key relationships
      --
      --  not implemented yet Register_Routine (T, Adrs_Data_standard_user_Child_Retrieve_Test'Access, "Test of Finding Children of Adrs_Data.standard_user" );
      --  not implemented yet Register_Routine (T, Adrs_Data_standard_group_Child_Retrieve_Test'Access, "Test of Finding Children of Adrs_Data.standard_group" );
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
