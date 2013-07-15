pragma Ada_95;
pragma Source_File_Name (ada_main, Spec_File_Name => "b~harness.ads");
pragma Source_File_Name (ada_main, Body_File_Name => "b~harness.adb");
with Ada.Exceptions;

package body ada_main is
   pragma Warnings (Off);

   E018 : Short_Integer; pragma Import (Ada, E018, "system__soft_links_E");
   E218 : Short_Integer; pragma Import (Ada, E218, "system__fat_lflt_E");
   E184 : Short_Integer; pragma Import (Ada, E184, "system__fat_llf_E");
   E026 : Short_Integer; pragma Import (Ada, E026, "system__exception_table_E");
   E153 : Short_Integer; pragma Import (Ada, E153, "ada__containers_E");
   E080 : Short_Integer; pragma Import (Ada, E080, "ada__io_exceptions_E");
   E125 : Short_Integer; pragma Import (Ada, E125, "ada__strings_E");
   E129 : Short_Integer; pragma Import (Ada, E129, "ada__strings__maps_E");
   E327 : Short_Integer; pragma Import (Ada, E327, "ada__strings__maps__constants_E");
   E051 : Short_Integer; pragma Import (Ada, E051, "ada__tags_E");
   E049 : Short_Integer; pragma Import (Ada, E049, "ada__streams_E");
   E120 : Short_Integer; pragma Import (Ada, E120, "interfaces__c_E");
   E122 : Short_Integer; pragma Import (Ada, E122, "interfaces__c__strings_E");
   E068 : Short_Integer; pragma Import (Ada, E068, "ada__calendar_E");
   E322 : Short_Integer; pragma Import (Ada, E322, "gnat__calendar_E");
   E324 : Short_Integer; pragma Import (Ada, E324, "gnat__calendar__time_io_E");
   E145 : Short_Integer; pragma Import (Ada, E145, "system__object_reader_E");
   E124 : Short_Integer; pragma Import (Ada, E124, "system__dwarf_lines_E");
   E022 : Short_Integer; pragma Import (Ada, E022, "system__secondary_stack_E");
   E090 : Short_Integer; pragma Import (Ada, E090, "system__finalization_root_E");
   E088 : Short_Integer; pragma Import (Ada, E088, "ada__finalization_E");
   E155 : Short_Integer; pragma Import (Ada, E155, "ada__strings__unbounded_E");
   E235 : Short_Integer; pragma Import (Ada, E235, "ada__strings__wide_maps_E");
   E098 : Short_Integer; pragma Import (Ada, E098, "system__storage_pools_E");
   E086 : Short_Integer; pragma Import (Ada, E086, "ada__finalization__heap_management_E");
   E172 : Short_Integer; pragma Import (Ada, E172, "system__os_lib_E");
   E108 : Short_Integer; pragma Import (Ada, E108, "system__pool_global_E");
   E175 : Short_Integer; pragma Import (Ada, E175, "system__file_control_block_E");
   E241 : Short_Integer; pragma Import (Ada, E241, "ada__streams__stream_io_E");
   E169 : Short_Integer; pragma Import (Ada, E169, "system__file_io_E");
   E239 : Short_Integer; pragma Import (Ada, E239, "system__strings__stream_ops_E");
   E167 : Short_Integer; pragma Import (Ada, E167, "ada__text_io_E");
   E222 : Short_Integer; pragma Import (Ada, E222, "ada__text_io__editing_E");
   E181 : Short_Integer; pragma Import (Ada, E181, "ada__text_io__generic_aux_E");
   E064 : Short_Integer; pragma Import (Ada, E064, "ada_containers__aunit_lists_E");
   E005 : Short_Integer; pragma Import (Ada, E005, "aunit_E");
   E008 : Short_Integer; pragma Import (Ada, E008, "aunit__memory_E");
   E061 : Short_Integer; pragma Import (Ada, E061, "aunit__memory__utils_E");
   E106 : Short_Integer; pragma Import (Ada, E106, "aunit__tests_E");
   E101 : Short_Integer; pragma Import (Ada, E101, "aunit__test_filters_E");
   E066 : Short_Integer; pragma Import (Ada, E066, "aunit__time_measure_E");
   E059 : Short_Integer; pragma Import (Ada, E059, "aunit__test_results_E");
   E105 : Short_Integer; pragma Import (Ada, E105, "aunit__assertions_E");
   E012 : Short_Integer; pragma Import (Ada, E012, "aunit__reporter_E");
   E072 : Short_Integer; pragma Import (Ada, E072, "aunit__reporter__text_E");
   E103 : Short_Integer; pragma Import (Ada, E103, "aunit__simple_test_cases_E");
   E159 : Short_Integer; pragma Import (Ada, E159, "aunit__test_cases_E");
   E084 : Short_Integer; pragma Import (Ada, E084, "aunit__test_suites_E");
   E082 : Short_Integer; pragma Import (Ada, E082, "aunit__run_E");
   E161 : Short_Integer; pragma Import (Ada, E161, "base_types_E");
   E220 : Short_Integer; pragma Import (Ada, E220, "db_commons_E");
   E280 : Short_Integer; pragma Import (Ada, E280, "environment_E");
   E249 : Short_Integer; pragma Import (Ada, E249, "gnu__db__sqlcli_E");
   E245 : Short_Integer; pragma Import (Ada, E245, "db_commons__odbc_E");
   E284 : Short_Integer; pragma Import (Ada, E284, "gnu__db__sqlcli__bind_E");
   E259 : Short_Integer; pragma Import (Ada, E259, "gnu__db__sqlcli__dispatch_E");
   E300 : Short_Integer; pragma Import (Ada, E300, "gnu__db__sqlcli__generic_attr__bitmap_attribute_E");
   E298 : Short_Integer; pragma Import (Ada, E298, "gnu__db__sqlcli__dispatch__a_bitmap_E");
   E264 : Short_Integer; pragma Import (Ada, E264, "gnu__db__sqlcli__generic_attr__boolean_attribute_E");
   E262 : Short_Integer; pragma Import (Ada, E262, "gnu__db__sqlcli__dispatch__a_boolean_E");
   E304 : Short_Integer; pragma Import (Ada, E304, "gnu__db__sqlcli__generic_attr__boolean_string_attribute_E");
   E302 : Short_Integer; pragma Import (Ada, E302, "gnu__db__sqlcli__dispatch__a_boolean_string_E");
   E308 : Short_Integer; pragma Import (Ada, E308, "gnu__db__sqlcli__generic_attr__context_attribute_E");
   E306 : Short_Integer; pragma Import (Ada, E306, "gnu__db__sqlcli__dispatch__a_context_E");
   E268 : Short_Integer; pragma Import (Ada, E268, "gnu__db__sqlcli__generic_attr__enumerated_attribute_E");
   E266 : Short_Integer; pragma Import (Ada, E266, "gnu__db__sqlcli__dispatch__a_enumerated_E");
   E314 : Short_Integer; pragma Import (Ada, E314, "gnu__db__sqlcli__generic_attr__pointer_attribute_E");
   E312 : Short_Integer; pragma Import (Ada, E312, "gnu__db__sqlcli__dispatch__a_pointer_E");
   E272 : Short_Integer; pragma Import (Ada, E272, "gnu__db__sqlcli__generic_attr__string_attribute_E");
   E270 : Short_Integer; pragma Import (Ada, E270, "gnu__db__sqlcli__dispatch__a_string_E");
   E276 : Short_Integer; pragma Import (Ada, E276, "gnu__db__sqlcli__generic_attr__unsigned_attribute_E");
   E274 : Short_Integer; pragma Import (Ada, E274, "gnu__db__sqlcli__dispatch__a_unsigned_E");
   E257 : Short_Integer; pragma Import (Ada, E257, "gnu__db__sqlcli__environment_attribute_E");
   E290 : Short_Integer; pragma Import (Ada, E290, "gnu__db__sqlcli__generic_attr__wide_string_attribute_E");
   E288 : Short_Integer; pragma Import (Ada, E288, "gnu__db__sqlcli__dispatch__a_wide_string_E");
   E286 : Short_Integer; pragma Import (Ada, E286, "gnu__db__sqlcli__connection_attribute_E");
   E310 : Short_Integer; pragma Import (Ada, E310, "gnu__db__sqlcli__statement_attribute_E");
   E294 : Short_Integer; pragma Import (Ada, E294, "gnu__db__sqlcli__info_E");
   E316 : Short_Integer; pragma Import (Ada, E316, "logger_E");
   E320 : Short_Integer; pragma Import (Ada, E320, "simple_pg_data_E");
   E282 : Short_Integer; pragma Import (Ada, E282, "group_members_io_E");
   E152 : Short_Integer; pragma Import (Ada, E152, "simple_pg_test_E");
   E331 : Short_Integer; pragma Import (Ada, E331, "standard_group_io_E");
   E333 : Short_Integer; pragma Import (Ada, E333, "standard_user_io_E");

   Local_Priority_Specific_Dispatching : constant String := "";
   Local_Interrupt_States : constant String := "";

   Is_Elaborated : Boolean := False;

   procedure finalize_library is
      LE_Set : Boolean;
      pragma Import (Ada, LE_Set, "__gnat_library_exception_set");
   begin
      E152 := E152 - 1;
      declare
         procedure F1;
         pragma Import (Ada, F1, "simple_pg_test__finalize_spec");
      begin
         F1;
      end;
      E320 := E320 - 1;
      declare
         procedure F2;
         pragma Import (Ada, F2, "simple_pg_data__finalize_spec");
      begin
         F2;
      end;
      E294 := E294 - 1;
      declare
         procedure F3;
         pragma Import (Ada, F3, "gnu__db__sqlcli__info__finalize_spec");
      begin
         F3;
      end;
      E310 := E310 - 1;
      declare
         procedure F4;
         pragma Import (Ada, F4, "gnu__db__sqlcli__statement_attribute__finalize_spec");
      begin
         F4;
      end;
      E286 := E286 - 1;
      declare
         procedure F5;
         pragma Import (Ada, F5, "gnu__db__sqlcli__connection_attribute__finalize_spec");
      begin
         F5;
      end;
      E257 := E257 - 1;
      declare
         procedure F6;
         pragma Import (Ada, F6, "gnu__db__sqlcli__environment_attribute__finalize_spec");
      begin
         F6;
      end;
      E220 := E220 - 1;
      declare
         procedure F7;
         pragma Import (Ada, F7, "db_commons__finalize_spec");
      begin
         F7;
      end;
      E084 := E084 - 1;
      declare
         procedure F8;
         pragma Import (Ada, F8, "aunit__test_suites__finalize_spec");
      begin
         F8;
      end;
      E159 := E159 - 1;
      declare
         procedure F9;
         pragma Import (Ada, F9, "aunit__test_cases__finalize_spec");
      begin
         F9;
      end;
      E101 := E101 - 1;
      E103 := E103 - 1;
      declare
         procedure F10;
         pragma Import (Ada, F10, "aunit__simple_test_cases__finalize_spec");
      begin
         F10;
      end;
      E072 := E072 - 1;
      declare
         procedure F11;
         pragma Import (Ada, F11, "aunit__reporter__text__finalize_spec");
      begin
         F11;
      end;
      E105 := E105 - 1;
      declare
         procedure F12;
         pragma Import (Ada, F12, "aunit__assertions__finalize_spec");
      begin
         F12;
      end;
      E059 := E059 - 1;
      declare
         procedure F13;
         pragma Import (Ada, F13, "aunit__test_results__finalize_spec");
      begin
         F13;
      end;
      declare
         procedure F14;
         pragma Import (Ada, F14, "aunit__test_filters__finalize_spec");
      begin
         F14;
      end;
      declare
         procedure F15;
         pragma Import (Ada, F15, "aunit__tests__finalize_spec");
      begin
         E106 := E106 - 1;
         F15;
      end;
      declare
         procedure F16;
         pragma Import (Ada, F16, "ada__text_io__generic_aux__finalize_body");
      begin
         E181 := E181 - 1;
         F16;
      end;
      declare
         procedure F17;
         pragma Import (Ada, F17, "ada__text_io__finalize_body");
      begin
         E167 := E167 - 1;
         F17;
      end;
      declare
         procedure F18;
         pragma Import (Ada, F18, "ada__text_io__finalize_spec");
      begin
         F18;
      end;
      declare
         procedure F19;
         pragma Import (Ada, F19, "ada__streams__stream_io__finalize_body");
      begin
         E241 := E241 - 1;
         F19;
      end;
      declare
         procedure F20;
         pragma Import (Ada, F20, "system__file_io__finalize_body");
      begin
         E169 := E169 - 1;
         F20;
      end;
      declare
         procedure F21;
         pragma Import (Ada, F21, "ada__streams__stream_io__finalize_spec");
      begin
         F21;
      end;
      declare
         procedure F22;
         pragma Import (Ada, F22, "system__file_control_block__finalize_spec");
      begin
         E175 := E175 - 1;
         F22;
      end;
      E108 := E108 - 1;
      declare
         procedure F23;
         pragma Import (Ada, F23, "system__pool_global__finalize_spec");
      begin
         F23;
      end;
      E086 := E086 - 1;
      declare
         procedure F24;
         pragma Import (Ada, F24, "ada__finalization__heap_management__finalize_spec");
      begin
         F24;
      end;
      E235 := E235 - 1;
      declare
         procedure F25;
         pragma Import (Ada, F25, "ada__strings__wide_maps__finalize_spec");
      begin
         F25;
      end;
      E155 := E155 - 1;
      declare
         procedure F26;
         pragma Import (Ada, F26, "ada__strings__unbounded__finalize_spec");
      begin
         F26;
      end;
      E090 := E090 - 1;
      declare
         procedure F27;
         pragma Import (Ada, F27, "system__finalization_root__finalize_spec");
      begin
         F27;
      end;
      if LE_Set then
         declare
            LE : Ada.Exceptions.Exception_Occurrence;
            pragma Import (Ada, LE, "__gnat_library_exception");
            procedure Raise_From_Controlled_Operation (X : Ada.Exceptions.Exception_Occurrence;  From_Abort : Boolean);
            pragma Import (Ada, Raise_From_Controlled_Operation, "__gnat_raise_from_controlled_operation");
         begin
            Raise_From_Controlled_Operation (LE, False);
         end;
      end if;
   end finalize_library;

   procedure adafinal is
      procedure s_stalib_adafinal;
      pragma Import (C, s_stalib_adafinal, "system__standard_library__adafinal");
   begin
      if not Is_Elaborated then
         return;
      end if;
      Is_Elaborated := False;
      s_stalib_adafinal;
   end adafinal;

   type No_Param_Proc is access procedure;

   procedure adainit is
      Main_Priority : Integer;
      pragma Import (C, Main_Priority, "__gl_main_priority");
      Time_Slice_Value : Integer;
      pragma Import (C, Time_Slice_Value, "__gl_time_slice_val");
      WC_Encoding : Character;
      pragma Import (C, WC_Encoding, "__gl_wc_encoding");
      Locking_Policy : Character;
      pragma Import (C, Locking_Policy, "__gl_locking_policy");
      Queuing_Policy : Character;
      pragma Import (C, Queuing_Policy, "__gl_queuing_policy");
      Task_Dispatching_Policy : Character;
      pragma Import (C, Task_Dispatching_Policy, "__gl_task_dispatching_policy");
      Priority_Specific_Dispatching : System.Address;
      pragma Import (C, Priority_Specific_Dispatching, "__gl_priority_specific_dispatching");
      Num_Specific_Dispatching : Integer;
      pragma Import (C, Num_Specific_Dispatching, "__gl_num_specific_dispatching");
      Main_CPU : Integer;
      pragma Import (C, Main_CPU, "__gl_main_cpu");
      Interrupt_States : System.Address;
      pragma Import (C, Interrupt_States, "__gl_interrupt_states");
      Num_Interrupt_States : Integer;
      pragma Import (C, Num_Interrupt_States, "__gl_num_interrupt_states");
      Unreserve_All_Interrupts : Integer;
      pragma Import (C, Unreserve_All_Interrupts, "__gl_unreserve_all_interrupts");
      Zero_Cost_Exceptions : Integer;
      pragma Import (C, Zero_Cost_Exceptions, "__gl_zero_cost_exceptions");
      Detect_Blocking : Integer;
      pragma Import (C, Detect_Blocking, "__gl_detect_blocking");
      Default_Stack_Size : Integer;
      pragma Import (C, Default_Stack_Size, "__gl_default_stack_size");
      Leap_Seconds_Support : Integer;
      pragma Import (C, Leap_Seconds_Support, "__gl_leap_seconds_support");

      procedure Install_Handler;
      pragma Import (C, Install_Handler, "__gnat_install_handler");

      Handler_Installed : Integer;
      pragma Import (C, Handler_Installed, "__gnat_handler_installed");

      Finalize_Library_Objects : No_Param_Proc;
      pragma Import (C, Finalize_Library_Objects, "__gnat_finalize_library_objects");
   begin
      if Is_Elaborated then
         return;
      end if;
      Is_Elaborated := True;
      Main_Priority := -1;
      Time_Slice_Value := -1;
      WC_Encoding := 'b';
      Locking_Policy := ' ';
      Queuing_Policy := ' ';
      Task_Dispatching_Policy := ' ';
      Priority_Specific_Dispatching :=
        Local_Priority_Specific_Dispatching'Address;
      Num_Specific_Dispatching := 0;
      Main_CPU := -1;
      Interrupt_States := Local_Interrupt_States'Address;
      Num_Interrupt_States := 0;
      Unreserve_All_Interrupts := 0;
      Zero_Cost_Exceptions := 1;
      Detect_Blocking := 0;
      Default_Stack_Size := -1;
      Leap_Seconds_Support := 0;

      if Handler_Installed = 0 then
         Install_Handler;
      end if;

      Finalize_Library_Objects := finalize_library'access;

      System.Soft_Links'Elab_Spec;
      System.Fat_Lflt'Elab_Spec;
      E218 := E218 + 1;
      System.Fat_Llf'Elab_Spec;
      E184 := E184 + 1;
      System.Exception_Table'Elab_Body;
      E026 := E026 + 1;
      Ada.Containers'Elab_Spec;
      E153 := E153 + 1;
      Ada.Io_Exceptions'Elab_Spec;
      E080 := E080 + 1;
      Ada.Strings'Elab_Spec;
      E125 := E125 + 1;
      Ada.Strings.Maps'Elab_Spec;
      Ada.Strings.Maps.Constants'Elab_Spec;
      E327 := E327 + 1;
      Ada.Tags'Elab_Spec;
      Ada.Streams'Elab_Spec;
      E049 := E049 + 1;
      Interfaces.C'Elab_Spec;
      Interfaces.C.Strings'Elab_Spec;
      Ada.Calendar'Elab_Spec;
      Ada.Calendar'Elab_Body;
      E068 := E068 + 1;
      Gnat.Calendar'Elab_Spec;
      E322 := E322 + 1;
      Gnat.Calendar.Time_Io'Elab_Spec;
      System.Object_Reader'Elab_Spec;
      System.Dwarf_Lines'Elab_Spec;
      E122 := E122 + 1;
      E120 := E120 + 1;
      Ada.Tags'Elab_Body;
      E051 := E051 + 1;
      E129 := E129 + 1;
      System.Soft_Links'Elab_Body;
      E018 := E018 + 1;
      System.Secondary_Stack'Elab_Body;
      E022 := E022 + 1;
      System.Dwarf_Lines'Elab_Body;
      E124 := E124 + 1;
      System.Object_Reader'Elab_Body;
      E145 := E145 + 1;
      System.Finalization_Root'Elab_Spec;
      E090 := E090 + 1;
      Ada.Finalization'Elab_Spec;
      E088 := E088 + 1;
      Ada.Strings.Unbounded'Elab_Spec;
      E155 := E155 + 1;
      Ada.Strings.Wide_Maps'Elab_Spec;
      E235 := E235 + 1;
      System.Storage_Pools'Elab_Spec;
      E098 := E098 + 1;
      Ada.Finalization.Heap_Management'Elab_Spec;
      E086 := E086 + 1;
      System.Os_Lib'Elab_Body;
      E172 := E172 + 1;
      System.Pool_Global'Elab_Spec;
      E108 := E108 + 1;
      System.File_Control_Block'Elab_Spec;
      E175 := E175 + 1;
      Ada.Streams.Stream_Io'Elab_Spec;
      System.File_Io'Elab_Body;
      E169 := E169 + 1;
      Ada.Streams.Stream_Io'Elab_Body;
      E241 := E241 + 1;
      System.Strings.Stream_Ops'Elab_Body;
      E239 := E239 + 1;
      Ada.Text_Io'Elab_Spec;
      Ada.Text_Io'Elab_Body;
      E167 := E167 + 1;
      E324 := E324 + 1;
      Ada.Text_Io.Editing'Elab_Spec;
      Ada.Text_Io.Generic_Aux'Elab_Body;
      E181 := E181 + 1;
      E222 := E222 + 1;
      E008 := E008 + 1;
      E005 := E005 + 1;
      E061 := E061 + 1;
      E064 := E064 + 1;
      Aunit.Tests'Elab_Spec;
      E106 := E106 + 1;
      Aunit.Test_Filters'Elab_Spec;
      Aunit.Time_Measure'Elab_Spec;
      E066 := E066 + 1;
      Aunit.Test_Results'Elab_Spec;
      Aunit.Test_Results'Elab_Body;
      E059 := E059 + 1;
      Aunit.Assertions'Elab_Spec;
      Aunit.Assertions'Elab_Body;
      E105 := E105 + 1;
      Aunit.Reporter'Elab_Spec;
      E012 := E012 + 1;
      Aunit.Reporter.Text'Elab_Spec;
      Aunit.Reporter.Text'Elab_Body;
      E072 := E072 + 1;
      Aunit.Simple_Test_Cases'Elab_Spec;
      E103 := E103 + 1;
      E101 := E101 + 1;
      Aunit.Test_Cases'Elab_Spec;
      E159 := E159 + 1;
      Aunit.Test_Suites'Elab_Spec;
      E084 := E084 + 1;
      E082 := E082 + 1;
      base_types'elab_spec;
      E161 := E161 + 1;
      Db_Commons'Elab_Spec;
      E220 := E220 + 1;
      E280 := E280 + 1;
      GNU.DB.SQLCLI'ELAB_SPEC;
      GNU.DB.SQLCLI'ELAB_BODY;
      E249 := E249 + 1;
      Db_Commons.Odbc'Elab_Spec;
      E284 := E284 + 1;
      E259 := E259 + 1;
      E300 := E300 + 1;
      E298 := E298 + 1;
      E264 := E264 + 1;
      E262 := E262 + 1;
      E304 := E304 + 1;
      E302 := E302 + 1;
      E308 := E308 + 1;
      E306 := E306 + 1;
      E268 := E268 + 1;
      E266 := E266 + 1;
      E314 := E314 + 1;
      E312 := E312 + 1;
      E272 := E272 + 1;
      E270 := E270 + 1;
      E276 := E276 + 1;
      E274 := E274 + 1;
      GNU.DB.SQLCLI.ENVIRONMENT_ATTRIBUTE'ELAB_SPEC;
      GNU.DB.SQLCLI.ENVIRONMENT_ATTRIBUTE'ELAB_BODY;
      E257 := E257 + 1;
      E245 := E245 + 1;
      E290 := E290 + 1;
      E288 := E288 + 1;
      GNU.DB.SQLCLI.CONNECTION_ATTRIBUTE'ELAB_SPEC;
      GNU.DB.SQLCLI.CONNECTION_ATTRIBUTE'ELAB_BODY;
      E286 := E286 + 1;
      GNU.DB.SQLCLI.STATEMENT_ATTRIBUTE'ELAB_SPEC;
      GNU.DB.SQLCLI.STATEMENT_ATTRIBUTE'ELAB_BODY;
      E310 := E310 + 1;
      GNU.DB.SQLCLI.INFO'ELAB_SPEC;
      GNU.DB.SQLCLI.INFO'ELAB_BODY;
      E294 := E294 + 1;
      E316 := E316 + 1;
      Simple_Pg_Data'Elab_Spec;
      E320 := E320 + 1;
      E282 := E282 + 1;
      Simple_Pg_Test'Elab_Spec;
      E331 := E331 + 1;
      standard_user_io'elab_body;
      E333 := E333 + 1;
      E152 := E152 + 1;
   end adainit;

   procedure Ada_Main_Program;
   pragma Import (Ada, Ada_Main_Program, "_ada_harness");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer
   is
      procedure Initialize (Addr : System.Address);
      pragma Import (C, Initialize, "__gnat_initialize");

      procedure Finalize;
      pragma Import (C, Finalize, "__gnat_finalize");
      SEH : aliased array (1 .. 2) of Integer;

      Ensure_Reference : aliased System.Address := Ada_Main_Program_Name'Address;
      pragma Volatile (Ensure_Reference);

   begin
      gnat_argc := argc;
      gnat_argv := argv;
      gnat_envp := envp;

      Initialize (SEH'Address);
      adainit;
      Ada_Main_Program;
      adafinal;
      Finalize;
      return (gnat_exit_status);
   end;

--  BEGIN Object file/option list
   --   /opt/gnat-2011/lib/gcc/x86_64-pc-linux-gnu/4.5.3/adalib/g-trasym.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/base_types.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/db_commons.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/environment.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-bind.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-bitmap_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_bitmap.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-boolean_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_boolean.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-boolean_string_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_boolean_string.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-context_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_context.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-enumerated_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_enumerated.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-pointer_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_pointer.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-string_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_string.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-unsigned_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_unsigned.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-environment_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/db_commons-odbc.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-generic_attr-wide_string_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-dispatch-a_wide_string.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-connection_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-statement_attribute.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/gnu-db-sqlcli-info.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/logger.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/simple_pg_data.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/group_members_io.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/suite.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/harness.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/standard_group_io.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/standard_user_io.o
   --   /home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/simple_pg_test.o
   --   -L/home/graham_s/VirtualWorlds/projects/ada_mill/dev/bin/
   --   -L/opt/ada_libraries/lib/aunit/native-full/
   --   -L/opt/gnat-2011/lib/gcc/x86_64-pc-linux-gnu/4.5.3/adalib/
   --   -lodbc
   --   -static
   --   -lgnat
--  END Object file/option list   

end ada_main;
