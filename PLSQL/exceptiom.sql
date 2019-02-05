DECLARE
   stock_price NUMBER := 9.73;
   net_earnings NUMBER := 0;
   pe_ratio NUMBER;
BEGIN
-- Calculation might cause division-by-zero error.
   pe_ratio := stock_price / net_earnings;
   DBMS_OUTPUT.PUT_LINE('Price/earnings ratio = ' || pe_ratio);
EXCEPTION  -- exception handlers begin
-- Only one of the WHEN blocks is executed.
   WHEN ZERO_DIVIDE THEN  -- handles 'division by zero' error
      DBMS_OUTPUT.PUT_LINE('Company must have had zero earnings.');
      pe_ratio := NULL;
   WHEN OTHERS THEN  -- handles all other errors
      DBMS_OUTPUT.PUT_LINE('Some other kind of error occurred.');
      pe_ratio := NULL;
END;  -- exception handlers and block end here
/