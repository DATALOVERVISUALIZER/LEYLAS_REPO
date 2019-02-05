CREATE OR REPLACE PROCEDURE display_multiple_years
(start_year_in IN NUMBER,
end_year_in IN NUMBER
)IS
l_current_year NUMBER(10):=start_year_in;
BEGIN
LOOP 
EXIT WHEN l_current_year>end_year_in;
dbms_output.put_line(l_current_year);
l_current_year:=l_current_year+1;
END LOOP;
END display_multiple_years;


DECLARE 
   i number(1); 
   j number(1); 
BEGIN 
   << outer_loop >> 
   FOR i IN 1..3 LOOP 
      << inner_loop >> 
      FOR j IN 1..3 LOOP 
         dbms_output.put_line('i is: '|| i || ' and j is: ' || j); 
      END loop inner_loop; 
   END loop outer_loop; 
END; 
/

