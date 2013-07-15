--
-- Created by ada_generator.py on 2012-02-23 13:59:30.739482
-- 
package body Base_Types is

   function Slice_To_Unbounded( s : String; start : Positive; stop : Natural ) return Unbounded_String is
   begin
      return To_Unbounded_String( Slice( To_Unbounded_String( s ), start, stop ) );
   end Slice_To_Unbounded;


end Base_Types;
