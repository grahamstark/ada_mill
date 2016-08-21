--
-- Created by ada_generator.py on 2015-10-15 00:52:41.752575
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
