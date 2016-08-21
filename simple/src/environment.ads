--
-- Created by ada_generator.py on 2016-07-05 16:20:16.518129
-- 
-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package Environment is

   -- === CUSTOM TYPES START ===
   -- === CUSTOM TYPES END ===
   
   function Get_Server_Name return String;
   function Get_Database_Name return String;   
   function Get_Username return String;
   function Get_Password return String;
   
   procedure Set_Server_Name( name : String );
   procedure Set_Database_Name( name : String );
   procedure Set_Username( name : String );
   procedure Set_Password( pwd : String );

   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Environment;
