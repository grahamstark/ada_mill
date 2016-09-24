--
-- Created by ada_generator.py on 2016-09-24 16:35:18.584446
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
