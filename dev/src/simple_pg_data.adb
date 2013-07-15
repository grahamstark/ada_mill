--
-- Created by ada_generator.py on 2012-02-23 13:59:30.713875
-- 

with GNAT.Calendar.Time_IO;

package body Simple_Pg_Data is

   use ada.strings.Unbounded;
   package tio renames GNAT.Calendar.Time_IO;

   function To_String( rec : Group_Members ) return String is
   begin
      return  "Group_Members: " &
         "Group_Name = " & To_String( rec.Group_Name ) &
         "User_Id = " & rec.User_Id'Img;
   end to_String;



   function To_String( rec : Standard_Group ) return String is
   begin
      return  "Standard_Group: " &
         "Name = " & To_String( rec.Name ) &
         "Description = " & To_String( rec.Description );
   end to_String;



   function To_String( rec : Standard_User ) return String is
   begin
      return  "Standard_User: " &
         "User_Id = " & rec.User_Id'Img &
         "Username = " & To_String( rec.Username ) &
         "Password = " & To_String( rec.Password ) &
         "Salary = " & rec.Salary'Img &
         "Rate = " & rec.Rate'Img &
         "Date_Created = " & tio.Image( rec.Date_Created, tio.ISO_Date );
   end to_String;



        

end Simple_Pg_Data;
