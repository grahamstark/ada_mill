--
-- Created by ada_generator.py on 2014-02-01 16:13:07.741551
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
