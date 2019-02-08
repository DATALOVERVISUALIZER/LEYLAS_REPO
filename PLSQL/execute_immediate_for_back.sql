DECLARE
   V_SQL VARCHAR2(4000) ;
   V_TARIH VARCHAR2(8);
   
   CURSOR ANA_SET IS 
   SELECT DATE_KEY V_TARIH FROM  prsn.tarih WHERE DATE_KEY BETWEEN  '20160701' AND '20161231' ORDER BY 1;
   
BEGIN
       FOR C IN ANA_SET LOOP
                             
 
V_SQL:='EXEC    ETL.SP_GISE_ISLEM_DETAY_GERIYE(to_date('||''''||C.V_TARIH||''''||','''||'YYYYMMDD'||'''))'||';';              
 
DBMS_OUTPUT.PUT_LINE(V_SQL);
 
--EXECUTE IMMEDIATE V_SQL;
 
 
       END LOOP;
         
END; 




--select  count(*)
--from OFSDATa.GISE_ISLEM_DETAY
--where tarih>=to_date('20160101','YYYYMMDD')

-- TRFM.GISE_ISLEM_DETAY_20180129 --yedek tablosu 

--
--ETL.SP_GISE_ISLEM_DETAY_GERIYE
--test
select * from 
(select * from 
(
select * from TRFM.GISE_ISLEM_DETAY_GERIYE  --geriye yonelýk calýstý
where tarih=to_date('20160101','YYYYMMDD')
and islem_adi=1
minus
select * from ofsdata.gise_islem_detay --suanki hali 
where tarih=to_date('20160101','YYYYMMDD')
and islem_adi=1
))
MINUS 
(
SELECT
 A.ISLTARIH AS TARIH -- bu iþlemde data iþlem tarihtir.
      ,NULL AS ZAMAN_DILIMI
      ,A.ISLSUBE SUBE
      ,A.karhilk7 AS MUSTERI_NO
      ,M.CALISMA_SEKLI
      ,1 AS ISLEM_ADI -- --11  'Hesaptan Hesaba Yapýlan Havaleler' ,iþlem yeni eklendi.06.01.18
      ,CASE
          WHEN A.ISLSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger')
       END
          AS SICIL_TUR
      ,A.ISLSICIL AS FISSICIL
      ,  COUNT (DISTINCT a.islsube || a.isltarih || a.islsicil || a.islfisno) as  ISLEM_ADET
      ,SUM((A.ISLTUTAR * F.D_ALIS) / F.KATSAYI) ISLEM_TUTAR
      ,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
          AS TURUNCU_HESAP
      ,CASE WHEN SUM((A.ISLTUTAR * F.D_ALIS) / F.KATSAYI) <= 1000 THEN '1000 ve 1000 TL alti'
          WHEN SUM((A.ISLTUTAR * F.D_ALIS) / F.KATSAYI) > 1000 AND SUM((A.ISLTUTAR * F.D_ALIS) / F.KATSAYI) <= 2000 THEN '1000 ve 2000 TL arasi'
          WHEN SUM((A.ISLTUTAR * F.D_ALIS) / F.KATSAYI) > 2000 AND SUM( (A.ISLTUTAR * F.D_ALIS) / F.KATSAYI) <= 5000  THEN '2000 ve 5000 TL arasi'
          ELSE '5000 TL üstü' END AS TUTAR_SKALA
      ,A.ISLHESTUR AS HESTUR
      ,M.ANA_SUBE
FROM
       EXTR.FS_SUBCARI A
      ,OFSDATA.NORMKADRO_SICIL_TUR C
      ,EXTR.FS_MUSTERI_MASTER M
      ,EXTR.FS_FDOVIZ F
      ,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =to_date('20160101','YYYYMMDD')) TH
WHERE
       ISLTARIH =to_date('20160101','YYYYMMDD')
       AND A.ISLHILK7 = M.MUSTERI_NO(+)
        AND A.ISLHILK7 = TH.MUSTERI_NO(+)
        AND A.ISLSICIL = C.FINSICIL(+)
        AND A.ISLTARIH = F.TARIH
         AND F.KURTIPI = 1
         AND F.PARA = A.PARA
       AND ISLBAKOD= 'B'
       AND ISLHESTUR = 'KS'
 GROUP BY
 A.ISLTARIH
,A.ISLSUBE
,A.karhilk7
,M.CALISMA_SEKLI
,CASE WHEN A.ISLSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
,A.ISLSICIL
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
,A.ISLHESTUR
,M.ANA_SUBE
UNION ALL
   /*when secenek=6 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-YP Para Yatýrma'
 when secenek=7 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube TL-YP Para Yatýrma'
 when secenek=3 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-TL Ödeme'
 when secenek=5 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-TL Para Yatýrma'*/
SELECT           /*+ Full(a) driving_site(a) */
                 fistarih tarih,
                 null as zaman_dilimi,
                 islsube sube,
                 ilk7 musteri_no,
                 calisma_sekli,
                 1 as islem_adi,
                  case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.fissicil as finsicil,
                 COUNT (DISTINCT islsube || fistarih || fissicil || fisno) adet,
                 SUM((a.tutar * f.d_alis / f.katsayi))   tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when SUM((a.tutar * f.d_alis / f.katsayi)) <=1000 THEN '1000 ve 1000 TL alti'
                      when SUM((a.tutar * f.d_alis / f.katsayi)) >1000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=2000 THEN '1000 ve 2000 TL arasi'
                      when SUM((a.tutar * f.d_alis / f.katsayi)) >2000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 'KS' as HESTUR,
                 m.ana_sube
          FROM   EXTR.FS_HRKTDET_SG a,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m
                , EXTR.FS_FDOVIZ F
                 ,(SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = to_date('20160101','YYYYMMDD')) th
         WHERE   a.ilk7=th.musteri_no(+)
                 AND a.fistarih = to_date('20160101','YYYYMMDD')
                 AND a.fissicil = f.finsicil(+)
                 AND m.musteri_no=a.ilk7
                 AND a.musteri=a.ilk7
                 AND A.FISTARIH = F.TARIH
               AND A.PARA = F.PARA
                     AND F.KURTIPI = 1
                 AND a.durum = 0
                 AND hestur IN ('MT','MY')
                 AND a.updprogram = 'KAM101'  --when secenek=6 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-YP Para Yatýrma' , when secenek=7 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube TL-YP Para Yatýrma' ,when secenek=3 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-TL Ödeme',when secenek=5 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-TL Para Yatýrma'
                 AND secenek IN (5,6,7)
             GROUP BY
             fistarih,
                 ilk7,
                 calisma_sekli,
                 islsube,
                 case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.fissicil,
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,
                        m.ana_sube
   UNION ALL
   -- when bakod='A' and updprogram in ('ATM113','ATM115','ATM130','ATM101','ATM114') and ACIK1 like 'ATM%' then 'ATM Para Yatýrma'
SELECT           /*+ Full(a) driving_site(a) */
                 fistarih tarih,
                 null as zaman_dilimi,
                 islsube sube,
                 ilk7 musteri_no,
                 calisma_sekli,
                 1 as islem_adi,
                  case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.fissicil as finsicil,
                 COUNT (DISTINCT islsube || fistarih || fissicil || fisno) adet,
                 SUM((a.tutar * f.d_alis / f.katsayi))   tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when SUM((a.tutar * f.d_alis / f.katsayi)) <=1000 THEN '1000 ve 1000 TL alti'
                      when SUM((a.tutar * f.d_alis / f.katsayi)) >1000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=2000 THEN '1000 ve 2000 TL arasi'
                      when SUM((a.tutar * f.d_alis / f.katsayi)) >2000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 'KS' as HESTUR,
                 m.ana_sube
          FROM   EXTR.FS_HRKTDET_SG a,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m
                , EXTR.FS_FDOVIZ F
                 ,(SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = to_date('20160101','YYYYMMDD')) th
         WHERE   a.ilk7=th.musteri_no(+)
                 AND a.fistarih = to_date('20160101','YYYYMMDD')
                 AND a.fissicil = f.finsicil(+)
                 AND m.musteri_no=a.ilk7
                 AND a.musteri=a.ilk7
                 AND A.FISTARIH = F.TARIH
               AND A.PARA = F.PARA
                     AND F.KURTIPI = 1
                 AND hestur IN ('MT','MY')
                 AND A.updprogram in ('ATM113','ATM115','ATM130','ATM101','ATM114')  -- when bakod='A' and updprogram in ('ATM113','ATM115','ATM130','ATM101','ATM114') and ACIK1 like 'ATM%' then 'ATM Para Yatýrma'
                 AND bakod='A'
                AND  ACIK1 like 'ATM%'
             GROUP BY
             fistarih,
                 ilk7,
                 calisma_sekli,
                 islsube,
                 case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.fissicil,
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,
                        m.ana_sube )




