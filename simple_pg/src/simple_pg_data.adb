--
-- Created by ada_generator.py on 2014-02-14 14:43:50.729358
-- 

with GNAT.Calendar.Time_IO;
-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Simple_Pg_Data is

   use ada.strings.Unbounded;
   package tio renames GNAT.Calendar.Time_IO;

   -- === CUSTOM TYPES START ===
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
         "a_bigint = " & rec.a_bigint'Img &
         "a_real = " & rec.a_real'Img &
         "a_decimal = " & rec.a_decimal'Img &
         "a_double = " & rec.a_double'Img &
         "a_boolean = " & rec.a_boolean'Img &
         "a_varchar = " & To_String( rec.a_varchar ) &
         "a_date = " & tio.Image( rec.a_date, tio.ISO_Date );
   end to_String;



        
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
