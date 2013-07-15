--
-- Created by ada_generator.py on 2013-06-11 17:03:46.741066
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
   
   
   function To_String( rec : Group_Members_Type ) return String is
   begin
      return  "Group_Members_Type: " &
         "Group_Name = " & To_String( rec.Group_Name ) &
         "User_Id = " & rec.User_Id'Img;
   end to_String;



   function To_String( rec : Standard_Group_Type ) return String is
   begin
      return  "Standard_Group_Type: " &
         "Name = " & To_String( rec.Name ) &
         "Description = " & To_String( rec.Description );
   end to_String;



   function To_String( rec : Standard_User_Type ) return String is
   begin
      return  "Standard_User_Type: " &
         "User_Id = " & rec.User_Id'Img &
         "Username = " & To_String( rec.Username ) &
         "Password = " & To_String( rec.Password ) &
         "Type1 = " & rec.Type1'Img &
         "Type2 = " & rec.Type2'Img &
         "Date_Created = " & tio.Image( rec.Date_Created, tio.ISO_Date );
   end to_String;



        
   -- === CUSTOM PROCS START ===
   -- u                                                                                                       
   -- i                                                                                                         
   -- o                                                                                                         
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
