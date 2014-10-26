--
-- Created by ada_generator.py on 2014-02-01 16:13:07.407760
-- 

with GNAT.Calendar.Time_IO;
-- === CUSTOM IMPORTS START ===
-- q                                                                                                             
-- w                                                                                                             
-- e                                                                                                             
-- === CUSTOM IMPORTS END ===

package body Simple_Pg_Data is

   use ada.strings.Unbounded;
   package tio renames GNAT.Calendar.Time_IO;

   -- === CUSTOM TYPES START ===
   -- r                                                                                                             
   -- t                                                                                                             
   -- y                                                                                                             
   -- === CUSTOM TYPES END ===
   
   
   function To_String( rec : Group_Members ) return String is
   begin
      return  "Group_Members: " &
         "group_name = " & To_String( rec.group_name ) &
         "user_id = " & rec.user_id'Img;
   end to_String;



   function To_String( rec : Standard_Group ) return String is
   begin
      return  "Standard_Group: " &
         "name = " & To_String( rec.name ) &
         "description = " & To_String( rec.description );
   end to_String;



   function To_String( rec : Standard_User ) return String is
   begin
      return  "Standard_User: " &
         "user_id = " & rec.user_id'Img &
         "username = " & To_String( rec.username ) &
         "password = " & To_String( rec.password ) &
         "type1 = " & rec.type1'Img &
         "type2 = " & rec.type2'Img &
         "date_created = " & tio.Image( rec.date_created, tio.ISO_Date );
   end to_String;



        
   -- === CUSTOM PROCS START ===
   -- u                                                                                                           
   -- i                                                                                                             
   -- o                                                                                                             
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
