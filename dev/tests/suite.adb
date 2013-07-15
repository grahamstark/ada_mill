--
-- Created by ada_generator.py on 2012-02-23 13:59:30.989114
-- 
with AUnit.Test_Suites; use AUnit.Test_Suites;

with Simple_Pg_Test;

function Suite return Access_Test_Suite is
        result : Access_Test_Suite := new Test_Suite;
begin
        Add_Test( result, new Simple_Pg_Test.test_Case ); -- Adrs_Data_Ada_Tests.Test_Case
        return result;
end Suite;
