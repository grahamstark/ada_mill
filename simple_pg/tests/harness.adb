--
-- Created by ada_generator.py on 2016-03-22 22:11:02.399275
-- 
with Suite;

with AUnit.Run;
with AUnit.Reporter.Text;

procedure Harness is
   procedure RunTestSuite is new AUnit.Run.Test_Runner( Suite );
   reporter : AUnit.Reporter.Text.Text_Reporter;
begin
   RunTestSuite( reporter );
end Harness;
