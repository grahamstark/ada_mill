--
-- Created by ada_generator.py on 2016-09-24 16:35:18.582264
-- 
with AUnit.Test_Suites; use AUnit.Test_Suites;

with Adrs_Data_Test;

function Suite return Access_Test_Suite is
        result : Access_Test_Suite := new Test_Suite;
begin
        Add_Test( result, new Adrs_Data_Test.Test_Case ); -- Adrs_Data_Ada_Tests.Test_Case
        return result;
end Suite;
