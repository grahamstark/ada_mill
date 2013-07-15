--
-- Created by ada_generator.py on 2013-06-11 17:03:47.042334
-- 
with AUnit.Test_Suites; use AUnit.Test_Suites;

with Simple_Pg_Test;

function Suite return Access_Test_Suite is
        result : Access_Test_Suite := new Test_Suite;
begin
        Add_Test( result, new Simple_Pg_Test.test_Case ); -- Adrs_Data_Ada_Tests.Test_Case
        return result;
end Suite;
