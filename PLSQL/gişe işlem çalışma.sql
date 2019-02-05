
--ok

SELECT                 
     'KS' as HESTUR,
     a.*
FROM   EXTR.FS_HRKTDET_SG a
WHERE    a.fistarih = '28/11/2017'
     AND a.durum = 0
     --AND hestur IN ('MT') 
     AND a.updprogram = 'FIS101'
     AND bakod = 'A'
     and a.fisno=3 and a.islsube=240 and a.fissicil=5002 and a.fistarih='28/11/2017'     

--ok

SELECT   *
FROM   extr.FS_HRKTDET_SG a
WHERE   a.fistarih = '28/11/2017'
     AND a.durum = 0
     --AND a.hestur IN ('MT')
     AND a.updprogram = 'FIS101'
     AND bakod = 'B'
     and a.fisno=3 and a.islsube=240 and a.fissicil=5002 and a.fistarih='28/11/2017'     
                 
                 
--ok

SELECT  * FROM   EXTR.FS_HRKTDET_SG a
         WHERE    a.updprogram = 'HPL101'
                 AND fistarih = '28/11/2017'
                 AND a.durum = 0


--ok

SELECT  *
FROM   EXTR.FS_hrktdet_sg a
WHERE   1 = 1
       AND fistarih  = '28/11/2017'               
       AND a.durum = 0
       AND a.updprogram IN ( 'VRG102', 'VRG112')
       AND a.HESTUR in ('KS','MT')
       AND a.BAKOD = 'B'
            
  

--ok

SELECT *
  FROM EXTR.FS_HRKTDET_SG a
 WHERE   1 = 1
         AND fistarih = '28/11/2017'
         AND a.durum = 0
         AND a.updprogram IN ('KKR101', 'KKR106')


--KKR102

SELECT *
 FROM  EXTR.FS_HRKTDET_SG a,
       EXTR.FS_HRKTDET_SG b,
       OFSDATA.NORMKADRO_SICIL_TUR f,
       EXTR.FS_MUSTERI_MASTER m,
       (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = '28/11/2017' ) th
WHERE  1 = 1
       AND a.fistarih = '28/11/2017'
       AND a.durum = 0
       AND a.updprogram IN ('KKR102')
       AND m.musteri_no = b.ilk7
       AND b.fissicil = f.finsicil(+)
       --AND sicil_tur in ('Operasyon','Gise')
       AND a.HESTUR <>'SC'
       AND b.HESTUR <>'SC'
       and a.bakod = 'B'
       and b.bakod = 'A'
       AND b.durum = 0
       AND b.updprogram IN ('KKR102')
       and a.fistarih = b.fistarih and a.fissicil = b.fissicil and a.fisno=b.fisno and a.fiszaman = b.fiszaman
       AND a.ilk7 = th.musteri_no(+)
and a.fisno=3 and a.islsube=240 and a.fissicil=5002 and a.fistarih='28/11/2017'       
     



--1

SELECT *
FROM extr.fs_hrktdet_sg a
--   (SELECT fistarih, fissicil, islsube,fisno,tutar
--      FROM extr.fs_hrktdet_sg h
--     WHERE h.fistarih = '28/11/2017'
--       AND h.kmhtutar IN (100000, 110000)
--       AND h.durum NOT IN (2, 3, 9)) b
WHERE a.fistarih = '28/11/2017' 
--AND a.fistarih = b.fistarih
--AND a.fissicil = b.fissicil
--AND a.islsube = b.islsube
--AND a.fisno = b.fisno
--AND a.tutar = b.tutar
AND a.hestur IN ('MT', 'MY')
AND a.durum NOT IN (2, 3, 9)
AND a.bakod = 'A'
and a.fisno=3 and a.islsube=240 and a.fissicil=5002 and a.fistarih='28/11/2017'


--2

SELECT *
FROM 
   extr.fs_hrktdet_sg a      
WHERE a.fistarih = '28/11/2017'
AND a.hestur IN ('MT', 'MY')
AND a.durum NOT IN (2, 3, 9)
AND a.bakod = 'B'
and a.fisno=3 and a.islsube=240 and a.fissicil=5002 and a.fistarih='28/11/2017'



