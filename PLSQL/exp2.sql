drop table kgf_komisyon_test_2;

 select * from kgf_komisyon_test_2;

create table  kgf_komisyon_test_2 as 


SELECT 
 (SUBSTR(NVL(SUBSTR(ACIK1, 0, REGEXP_INSTR(ACIK1,'M',1, 1, 0, 'i')), ACIK1  ),5)) 
 ,REGEXP_INSTR(ACIK1,'K',1, 1, 0, 'i')-1
 ,acik1, acik2,ilk7,tutar,hestur,sinif,fistarih
FROM 
((
  SELECT  h.acik1, h.acik2,h.ilk7,h.tutar,h.hestur,h.sinif,h.fistarih
    FROM extr.fs_hrktdet_sg h
         INNER JOIN (
         select hr.islsube, hr.fistarih, hr.fissicil, hr.fisno, hr.tutar
FROM extr.fs_hrktdet_sg HR
WHERE 1=1
AND hr.durum = 0 
  AND sinif = 'C' 
  AND ilk7 = 7827248 
  AND hestur = 'AL' 
  AND ekno IN (1, 2)
         ) t
                    ON     h.islsube = t.islsube
                       AND h.fistarih = t.fistarih
                       AND h.fissicil = t.fissicil
                       AND h.fisno = t.fisno
   WHERE 1 = 1
     AND h.durum = 0
     AND h.sinif = 'A'
     AND h.ilk7 = 3920300
)
UNION ALL 
(select  
 h.acik1, h.acik2,h.ilk7,h.tutar,h.hestur,h.sinif,h.fistarih
 from
   extr.fs_hrktdet_sg H
where 
1=1
AND ILK7=2789994  --HER ZAMAN ILK7 ye gitmeliyim
AND SINIF='A'  --THP iþlemi almak filtre olarak verilmelidir.  7827248 C hesaplarý için  )
))
--order by 7 desc
where fistarih=to_date('25.01.2017','dd.mm.yyyy')




select * from kgf_komisyon_test_2




--komisyon bilgisinin alýndýgý tablo


SELECT KGF.musteri_id FROM DM_INFOMAN.KGF_OZT    KGF
where 
1=1
AND KGF.musteri_id='1020578032'
AND KGF.kst_trh=trunc(sysdate-1)
AND KGF.musteri_id IN 
 (select  
acik1
 from
   extr.fs_hrktdet_sg HR
where 
1=1
AND ILK7=2789994  --HER ZAMAN ILK7 ye gitmeliyim
AND SINIF='A'  --THP iþlemi almak filtre olarak verilmelidir.  7827248 C hesaplarý için  )
)




