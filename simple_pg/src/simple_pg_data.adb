--
-- Created by ada_generator.py on 2013-06-11 18:39:29.623759
-- 

with GNAT.Calendar.Time_IO;
-- === CUSTOM IMPORTS START ===
-- === CUSTOM IMPORTS END ===

package body Simple_Pg_Data is

   use ada.strings.Unbounded;
   package tio renames GNAT.Calendar.Time_IO;

   -- === CUSTOM TYPES START ===
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
         "A_Bigint = " & rec.A_Bigint'Img &
         "A_Real = " & rec.A_Real'Img &
         "A_Decimal = " & rec.A_Decimal'Img &
         "A_Double = " & rec.A_Double'Img &
         "A_Boolean = " & rec.A_Boolean'Img &
         "A_Varchar = " & To_String( rec.A_Varchar ) &
         "A_Date = " & tio.Image( rec.A_Date, tio.ISO_Date );
   end to_String;



        
   -- === CUSTOM PROCS START ===
   -- === CUSTOM PROCS END ===

end Simple_Pg_Data;
