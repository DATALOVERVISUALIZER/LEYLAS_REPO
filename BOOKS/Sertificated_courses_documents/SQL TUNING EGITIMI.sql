--SQL TUNING EGITIMI
select * from duald
alter table hr.employees
storage(buffer_pool keep)-- cach pin

select * from v$sql  where sql_text --ile hangi tablonun kontrolunu yapacagımızı kontrol edebiliriz.--tablo cash, hard parse, sorgu kac defa calsıırılmıs bunun gibikontrolleri tutar 
select * FROM v$fixed_table  where name like 'V$%SESSION%'-- butun v$ ile baslayan tabloların ısımlerını saklar
select * from dictionary where table_name like 'V$%'

select * from hr.employees where employee_id=:abc

variable abc number;
begin
:abc := 100;
end;


select * from V$parameter where NAME like '%optimizer_index_cost_adj%' -- tablonun %20si bile donse index kullanır sorgunun %20 si bile gelse index kullanır. Daha cok index kullanmaya calısır. 
optimizer_index_cost_adj% 1 , 10 -- 1 olursa sadece primary  key kullanarak index kullanır. 10 olursa sadece %1 olursa index kullanır.
select * from V$instance -- kullanılan database versiyonunu ogrenmek ıcın 
select * from dba_tables where table_name='TABLO'
select count(*) from HR.TABLO



begin 
dbms_stats.gather_table_stats('HR','Countries');  --TABLONUN ISTATISTIGINI TUTMAK ICIN KULANILIR 
END;

SELECT * FROM dba_tab_statistics;-- her tablonun istatıstıksel datasının tutuldugu tablo tablolar chain olmamalı deger 0 olmalı- partıon olmalı


ALTER TABLE HR.Countries  enable row movement 
alter table shrink HR.countries  -- tablolar shrink edılerek row chaining 0 a dusurulur, daha hızlı calısır

grant dba to HR 
-- Tablo ıstatıstıkleri konrol edildiğinde shrink etme ihtiyacları dogar

--DATA VOLUME CHANGED -- data daha kucuk parcalara bolunup partion ile sql tuning daglanabilir. 


--OBTAIM BETTER PLAN 
optimizer_index_cost_adj
optimizer_mood --data chache e konulduktan sonra satır satır gosterilir, bunun yerine data satır satır cache edilip gösterilir. -- bunun için kod--OPTIMIZER_MOOD(FIRST_ROWS_N,ALL_rows)
optimizer_features_enabled=11.1.0 00 -- bu version için ebanled edıldı
alter system set optimizer_mode=FIRST_ROWS_100


SELECT /*+FIRST_ROWS */ CUST_ID, sum(amount_sold) from hr.tablo group by cust_id -- Hint yazılarak datanın hepsi cache' atılmadan satır satır gosterılenilir 

SELECT /*ordered*/ --Boylece join sırası yazılan sırada yapılır, join sırası otomatik yapılmaz. İyi bilinen joinlerde yapılırsa optimizer'a iş bırakmamış oluruz. 
cust_id from a,b,c, d  -- optimizerın yaptıgı join sırasında bazen buyuk sorgularda yanlıs planla gıdebılır istatistikler dogru olsa bile
where a.c=b.d 


select /*leading(a,b)*/  -- önce a ile b joinlerin gerisine karısmaz. sıranın bu sekilde yönnetilmesi sorgu iyi biliniyorsa işe yarar. Noylece optimizer'a daha iş düşer ve sorgular daha hızlı calısır
from a,b,c,d where a.c=d.b 


Select * from  where ID='100'  YANLIS 1000 -DOGRU-- wrong type hatası bu sekılde yapılınca number data auto-convert ile once char yapar sonra arar, bu da sorgunun yavas calısmasına sebep olur.  data type değiştiği için index'de kullanılamaz oluyor. 


create table tip(a varchar2(20), b char(20)) ; -- varchar sadece 20 karakterlık yer ayırır ve data sıgmazsa data shrink edilmek zorunda kalır
inser into tip value('ALİ','ALİ')
select * from tip where a=trim(b) --char da ise null degerlerını temızlemek gereklı olabilir 


--JOIN ALGORITMALARI
select /*+ USE NL */* from sh.cannels s ,costs c  --use nasted loop -en maaliyetlı join algoritması- for-- for 
where  s.id=c.is 


select /*+ USE hash(c.id) */* from sh.cannels s ,costs c  --maaliyeti en dusuk join algoritması -- buyuk tablolara uygun olan join algoritmasıdır kesinlikle
where  s.id=c.is 

select /*+ SORT MERGE(c.id) */* from sh.cannels s ,costs c   -- kucuk tabloalrda sort maaliyetinin öenmli olmadıgı tablolarda kullanılır. SORT ILE JOIN yapması dezavantajdır
where  s.id=c.is 


--SUBQERY UNNESTING EXAMPLE 
Select* from a where id in(select b from c) yerine select * from a,c wherer id=c --SUBQUERY yerine JOIN kullanmak daha hızlıdr.
--IN yerıne dogru yerlerde EXIST kullanmak daha dogrudur. d







