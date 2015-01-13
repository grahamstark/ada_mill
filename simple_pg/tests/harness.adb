--
-- Created by ada_generator.py on 2014-11-11 00:46:56.999685
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
