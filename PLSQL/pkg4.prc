CREATE OR REPLACE PROCEDURE OFSDATA.SP_GISE_ISLEM_DETAY (p_date DATE DEFAULT TRUNC(SYSDATE-1) ) is

   v_rapor_tarihi     date := p_date;
   v_sqlcode          NUMBER (10);
   v_sqlcodeexp       VARCHAR2 (200);
   v_module_name      VARCHAR2 (100) := 'GISE_ISLEM_DETAY';
   v_owner            VARCHAR2 (40) := 'OFSDATA';
   v_line_no          NUMBER := 0;
   v_sp_name          VARCHAR2 (40) := 'SP_GISE_ISLEM_DETAY';
   v_is_restartable   NUMBER (1) := 1;
   v_etl_tarih        VARCHAR2 (8) := TO_CHAR (SYSDATE - 1, 'YYYYMMDD');


            /*****************************************************************************************
            /*  SP_GISE_ISLEM_DETAY
            /*
            /*****************************************************************************************
            /* AÇIKLAMA:
            /*
            /*
            /*  ÇALIÞMA RUTINI : Günlük
            /*
            /*     OUTPUT:
            /*
            /*
            /*     SORUMLULAR: Ýlteriþ MUTLU, Semih KUTLUAY
            /*
            /*     GELÝÞTÝRME TARÝHÝ:
            /* Developer-Name (KUTLUAY Semih, MUTLU Ýlteriþ) 02/07/2014 Release oldu. Günlük çalýþmaya baþladý (Original development)
            /* Developer-Name (MUTLU Ýlteriþ) 16/09/2014 Para Çekme ve Para Yatýrma Ýþlemlerinde, yapýlan iþlemin turuncu hesap olup olmadýðý bilgisi eklendi.
            /* Developer-Name (MUTLU Ýlteriþ) 26/12/2014 hrktdet_sg tablosundan gelen fiszaman datasýndan kaynaklý hatanýn düzeltilmesi için;zaman bilgisinin formatý düzeltildi.
            /* Developer-Name (Last, First) mm/dd/yyyy (yapýlan deðiþiklik nedir, yaz kimsen çekinme)
            /* ...
            /* ...
            /*****************************************************************************************/

BEGIN


   -- START LOG
   ETL.PKG_UTIL_LIB.prc_log_begin (V_MODULE_NAME,
                                   NULL,
                                   V_OWNER,
                                   V_SP_NAME,
                                   V_ETL_TARIH,
                                   V_IS_RESTARTABLE);
   -- Ýþleri Session bazýnda takip edebilmek için
   DBMS_APPLICATION_INFO.set_module (v_sp_name, NULL);
          /*
1    Para Yatýrma
2    Para Çekme
3    Bireysel Kredi Taksit Ödeme
4    Cüzdan Bastýrma
5    Fatura Tahsilatlarý
6    EFT
7    Havale
8    Kredi Kartý Nakit Avans
9    Kredi Kartý Tahsilatý
10   Motorlu Taþýt Vergi Tahsilatý
11 Hesaptan Hesaba Yapýlan Havaleler --iþlem yeni eklendi.06.01.18
12 Virman   --iþlem yeni eklendi.06.01.18
*/

          /*

 SELECT tarih,
        zaman_dilimi,
        sube,
        musteri_no,
        calisma_sekli,
        sicil_tur,
        CASE WHEN islem_adi = 1 THEN 'Para Yatýrma'
             WHEN islem_adi = 2 then   'Para Çekme'
             WHEN islem_adi = 3 then   'Bireysel Kredi Taksit Ödeme'
             WHEN islem_adi = 4 then   'Cüzdan Bastýrma'
             WHEN islem_adi = 5 then   'Fatura Tahsilatlarý'
             WHEN islem_adi = 6 then   'EFT'
             WHEN islem_adi = 7 THEN 'Havale'
             WHEN islem_adi = 8  then  'Kredi Kartý Nakit Avans'
             WHEN islem_adi = 9 then   'Kredi Kartý Tahsilatý'
             WHEN islem_adi = 10 THEN 'Motorlu Taþýt Vergi Tahsilatý'
        END as urun_ad,
        finsicil, adet, tutar, turuncu_hesap, tutar_skala, hes_tur, ana_sube
FROM GISE_ISLEM_DETAY



CREATE OR REPLACE FORCE VIEW gise_islem_detay_ozet
(
   tarih,
   ana_sube,
   ISLEM_SUBE,
   KANAL,
   ATM_ONSITE_OFFSITE,
   HES_TUR,
   URUN_AD,
   ADET
)
AS
SELECT trunc(TARIH,'Q') as tarih,
       ANA_SUBE,
       SUBE as islem_sube,
       sicil_tur as kanal,
       ' ' as atm_onsite_offsite,
       hes_tur,
        CASE WHEN islem_adi = 1 THEN 'Para Yatýrma'
             WHEN islem_adi = 2 then   'Para Çekme'
             WHEN islem_adi = 3 then   'Bireysel Kredi Taksit Ödeme'
            WHEN islem_adi = 4 then   'Cüzdan Bastýrma'
            WHEN islem_adi = 5 then   'Fatura Tahsilatlarý'
            WHEN islem_adi = 6 then   'EFT'
            WHEN islem_adi = 7 THEN 'Havale'
            WHEN islem_adi = 8  then  'Kredi Kartý Nakit Avans'
            WHEN islem_adi = 9 then   'Kredi Kartý Tahsilatý'
            WHEN islem_adi = 10 THEN 'Motorlu Taþýt Vergi Tahsilatý'
        END as urun_ad,
        sum(adet) as adet
FROM GISE_ISLEM_DETAY WHERE 1=1 AND tarih BETWEEN '01.01.2015' and '31.03.2015'
GROUP BY trunc(TARIH,'Q'), ANA_SUBE, SUBE , sicil_tur, hes_tur,
CASE WHEN islem_adi = 1 THEN 'Para Yatýrma'
             WHEN islem_adi = 2 then   'Para Çekme'
             WHEN islem_adi = 3 then   'Bireysel Kredi Taksit Ödeme'
        WHEN islem_adi = 4 then   'Cüzdan Bastýrma'
        WHEN islem_adi = 5 then   'Fatura Tahsilatlarý'
        WHEN islem_adi = 6 then   'EFT'
        WHEN islem_adi = 7 THEN 'Havale'
        WHEN islem_adi = 8  then  'Kredi Kartý Nakit Avans'
        WHEN islem_adi = 9 then   'Kredi Kartý Tahsilatý'
        WHEN islem_adi = 10 THEN 'Motorlu Taþýt Vergi Tahsilatý'
        END;


*/

DELETE FROM ofsdata.GISE_ISLEM_DETAY where tarih = v_rapor_tarihi ;
COMMIT;

INSERT     /*+ append */ INTO  ofsdata.GISE_ISLEM_DETAY
     /*when bakod='A' and updprogram in ('FIS101') and durum=0 then 'Ayný Þube TL-TL Para Yatýrma'*/
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
                 ,(SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
         WHERE   a.ilk7=th.musteri_no(+)
                 AND a.fistarih = v_rapor_tarihi
                 AND a.fissicil = f.finsicil(+)
                 AND m.musteri_no=a.ilk7
                 AND a.musteri=a.ilk7
                 AND A.FISTARIH = F.TARIH
               AND A.PARA = F.PARA
                     AND F.KURTIPI = 1
                 AND a.durum = 0
                 AND hestur IN ('MT','MY')
                 AND a.updprogram = 'FIS101' -- when bakod='A' and updprogram in ('FIS101') and durum=0 then 'Ayný Þube TL-TL Para Yatýrma'
                 AND bakod = 'A'
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
  /*    case when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para = 0 then 'Farklý þube TL-TL Para Yatýrma'
             when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para <> 0 then 'Farklý þube YP-YP Para Yatýrma'
       case when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para = 0 then 'Farklý þube TL-TL Para Yatýrma'
             when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para <> 0 then 'Farklý þube YP-YP Para Yatýrma'*/
             --FARKLI SUBE PARa YATIRMA ISLEMI
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
      ,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =v_rapor_tarihi) TH
WHERE
       ISLTARIH =v_rapor_tarihi
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
                 ,(SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
         WHERE   a.ilk7=th.musteri_no(+)
                 AND a.fistarih = v_rapor_tarihi
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
                 ,(SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
         WHERE   a.ilk7=th.musteri_no(+)
                 AND a.fistarih = v_rapor_tarihi
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
                        m.ana_sube ;

                        COMMIT;
   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
         /* when bakod='B' and updprogram in ('FIS101') and durum=0 then 'Ayný Þube TL-TL Para Çekme'*/
SELECT           /*+ Full (a)*/
                 fistarih tarih,
                 null as zaman_dilimi,
                 islsube sube,
                 ilk7 musteri_no,
                 calisma_sekli,
                 2 as islem_adi,   --tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Ayni Sube TL Hesaptan TL Para Çekme"
                    case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.fissicil,
                 COUNT (DISTINCT islsube || fistarih || a.fissicil || fisno) adet,
                  SUM((a.tutar * f.d_alis / f.katsayi))  tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when  SUM((a.tutar * f.d_alis / f.katsayi)) <=1000 THEN '1000 ve 1000 TL alti'
                      when  SUM((a.tutar * f.d_alis / f.katsayi)) >1000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=2000 THEN '1000 ve 2000 TL arasi'
                      when  SUM((a.tutar * f.d_alis / f.katsayi)) >2000  and  SUM((a.tutar * f.d_alis / f.katsayi)) <=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 'KS' as hestur,
                 m.ana_sube
          FROM   extr.FS_HRKTDET_SG a,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m
                   , EXTR.FS_FDOVIZ F
                , (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
         WHERE   a.musteri=th.musteri_no(+)
                 AND a.fistarih = v_rapor_tarihi
                   AND A.FISTARIH = F.TARIH
                    AND A.PARA = F.PARA
                  AND F.KURTIPI = 1
                  AND a.fissicil = f.finsicil(+)
                 AND a.ilk7 = m.musteri_no
                 AND a.durum = 0
                 AND a.hestur in ('MT','MY')
                 AND a.updprogram = 'FIS101'
                 AND bakod = 'B' -- when bakod='B' and updprogram in ('FIS101') and durum=0 then 'Ayný Þube TL-TL Para Çekme'
             GROUP BY   fistarih,
                 islsube,
                       case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.fissicil,
                 ilk7,
                 calisma_sekli,
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,
             m.ana_sube
            /*when secenek=4 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-YP Para Çekme'
, when secenek=8 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube TL-YP Para Çekme'*/
     UNION ALL
     SELECT           /*+ Full (a)*/
                 fistarih tarih,
                 null as zaman_dilimi,
                 islsube sube,
                 ilk7 musteri_no,
                 calisma_sekli,
                 2 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Ayni Sube TL Hesaptan TL Para Çekme"
                    case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.fissicil,
                 COUNT (DISTINCT islsube || fistarih || a.fissicil || fisno) adet,
                  SUM((a.tutar * f.d_alis / f.katsayi))  tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when  SUM((a.tutar * f.d_alis / f.katsayi)) <=1000 THEN '1000 ve 1000 TL alti'
                      when  SUM((a.tutar * f.d_alis / f.katsayi)) >1000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=2000 THEN '1000 ve 2000 TL arasi'
                      when  SUM((a.tutar * f.d_alis / f.katsayi)) >2000  and  SUM((a.tutar * f.d_alis / f.katsayi)) <=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 'KS' as hestur,
                 m.ana_sube
          FROM   extr.FS_HRKTDET_SG a,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m
                   , EXTR.FS_FDOVIZ F
                , (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
         WHERE   a.musteri=th.musteri_no(+)
                 AND a.fistarih = v_rapor_tarihi
                   AND A.FISTARIH = F.TARIH
                    AND A.PARA = F.PARA
                  AND F.KURTIPI = 1
                  AND a.fissicil = f.finsicil(+)
                 AND a.ilk7 = m.musteri_no
               AND a.hestur in ('MT','MY')
                 AND a.updprogram = 'KAM101'
                 AND secenek IN (4,8,3) -- when secenek=4 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube YP-YP Para Çekme' , when secenek=8 and updprogram in ('KAM101') and durum=0 then 'Ayný Þube TL-YP Para Çekme'
             GROUP BY   fistarih,
                 islsube,
                       case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.fissicil,
                 ilk7,
                 calisma_sekli,
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,
             m.ana_sube
UNION ALL
  /* 'ATM Para Çekme'*/
   SELECT           /*+ Full (a)*/
                 fistarih tarih,
                 null as zaman_dilimi,
                 islsube sube,
                 ilk7 musteri_no,
                 calisma_sekli,
                 2 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Ayni Sube TL Hesaptan TL Para Çekme"
                    case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.fissicil,
                 COUNT (DISTINCT islsube || fistarih || a.fissicil || fisno) adet,
                  SUM((a.tutar * f.d_alis / f.katsayi))  tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when  SUM((a.tutar * f.d_alis / f.katsayi)) <=1000 THEN '1000 ve 1000 TL alti'
                      when  SUM((a.tutar * f.d_alis / f.katsayi)) >1000  and SUM((a.tutar * f.d_alis / f.katsayi)) <=2000 THEN '1000 ve 2000 TL arasi'
                      when  SUM((a.tutar * f.d_alis / f.katsayi)) >2000  and  SUM((a.tutar * f.d_alis / f.katsayi)) <=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 'KS' as hestur,
                 m.ana_sube
          FROM   extr.FS_HRKTDET_SG a,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m
                   , EXTR.FS_FDOVIZ F
                , (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
         WHERE   a.musteri=th.musteri_no(+)
                 AND a.fistarih = v_rapor_tarihi
                   AND A.FISTARIH = F.TARIH
                    AND A.PARA = F.PARA
                  AND F.KURTIPI = 1
                  AND a.fissicil = f.finsicil(+)
                 AND a.ilk7 = m.musteri_no
               AND a.hestur in ('MT','MY')
                 AND a.updprogram in ('ATM113','ATM115','ATM130','ATM101','ATM114')
                 AND bakod='B'
                 AND  ACIK1 like 'ATM%' --  'ATM Para Çekme'
             GROUP BY   fistarih,
                 islsube,
                       case when a.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.fissicil,
                 ilk7,
                 calisma_sekli,
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,
             m.ana_sube
UNION ALL
  /*    case when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para = 0 then 'Farklý þube TL-TL Para Yatýrma'
             when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para <> 0 then 'Farklý þube YP-YP Para Yatýrma'
       case when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para = 0 then 'Farklý þube TL-TL Para Yatýrma'
             when a.islhestur = 'KS' AND a.islbakod = 'B' AND a.para <> 0 then 'Farklý þube YP-YP Para Yatýrma'*/
             --FARKLI SUBE PARa CEKME ISLEMI
SELECT
 A.ISLTARIH AS TARIH -- bu iþlemde data iþlem tarihtir.
      ,NULL AS ZAMAN_DILIMI
      ,A.ISLSUBE SUBE
      ,A.karhilk7 AS MUSTERI_NO
      ,M.CALISMA_SEKLI
      ,2 AS ISLEM_ADI -- --11  'Hesaptan Hesaba Yapýlan Havaleler' ,iþlem yeni eklendi.06.01.18
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
      ,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =v_rapor_tarihi) TH
WHERE
       ISLTARIH =v_rapor_tarihi
       AND A.ISLHILK7 = M.MUSTERI_NO(+)
        AND A.ISLHILK7 = TH.MUSTERI_NO(+)
        AND A.ISLSICIL = C.FINSICIL(+)
        AND A.ISLTARIH = F.TARIH
         AND F.KURTIPI = 1
         AND F.PARA = A.PARA
       AND ISLBAKOD= 'A'
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
,M.ANA_SUBE;


             COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
       SELECT  a.islem_tarihi as tarih,
               null as zaman_dilimi,
               --to_char(trunc(to_date(substr(to_char(a.updtarih,'dd.mm.yyyy hh24:mi:ss'),12,8),'HH24:MI:SS'), 'hh')+
               --(width_bucket(to_number(to_char(to_date(substr(to_char(a.updtarih,'dd.mm.yyyy hh24:mi:ss'),12,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') as zaman_dilimi,
               to_number(a.virman_sube_kodu) as sube,
               to_number(r.degismez_sayi) as musteri_no,
               m.calisma_sekli as calisma_sekli,
               3 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Bireysel Kredi Taksit Ödeme"
               --NVL (f.sicil_tur, 'SUBE') as sicil_tur,
               case when to_number(a.kullanici) >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'SUBE')
               end as sicil_tur,
               to_number(a.kullanici) as sicil_no,
               COUNT (a.kullanici) adet,
               sum(virman_tutar) as tutar,
               (CASE WHEN th.musteri_no IS NOT NULL THEN 1 ELSE 0 END) as turuncu_hesap,
               case when a.virman_tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.virman_tutar>1000  and a.virman_tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.virman_tutar>2000  and a.virman_tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
               end as tutar_skala,
               'MT' as hestur,
               m.ana_sube
        FROM   extr.OY_BOSS_FINSOFT_TAHSILAT a,
               ofsdata.NORMKADRO_SICIL_TUR f,
               extr.OY_VIEW_KO_REZERVASYON r,
               extr.FS_MUSTERI_MASTER m,
               (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
       WHERE   islem_tarihi = v_rapor_tarihi--between '14.07.2014' and '31.12.2014'
               and a.kullanici = f.finsicil(+)
               and a.kullanici = th.musteri_no (+)
               and a.virman_tutar>0
               and a.talep_no = r.talep_no
               and r.degismez_sayi = m.musteri_no
               --and f.sicil_tur in ('Gise','Operasyon')
               and to_number(a.virman_sube_kodu) is not null
     GROUP BY  a.islem_tarihi,
               --to_char(trunc(to_date(substr(to_char(a.updtarih,'dd.mm.yyyy hh24:mi:ss'),12,8),'HH24:MI:SS'), 'hh')+
               --(width_bucket(to_number(to_char(to_date(substr(to_char(a.updtarih,'dd.mm.yyyy hh24:mi:ss'),12,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI'),
               to_number(a.virman_sube_kodu),
               to_number(r.degismez_sayi),
               m.calisma_sekli,
               --NVL (f.sicil_tur, 'SUBE'),
               case when to_number(a.kullanici) >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'SUBE')
               end,
               to_number(a.kullanici),
               case when a.virman_tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.virman_tutar>1000  and a.virman_tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.virman_tutar>2000  and a.virman_tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
               END,
               (CASE WHEN th.musteri_no IS NOT NULL THEN 1 ELSE 0 END),
               m.ana_sube;
    COMMIT;

   v_line_no := $$PLSQL_LINE;








          /*kanal göçü kapsamýnda ilave edilen kodlar:BAÞLANGIÇ*/

INSERT           /*+ APPEND */ INTO ofsdata.GISE_ISLEM_DETAY
 Select TRUNC(ofis.updtarih) as tarih,
        null as zaman_dilimi,
        ofis_fsube as sube,
        ofis_musteri as musteri_no,
        mm.calisma_sekli,
        3 as islem_adi,      --ofsdata.GISE_ISLEM_DETAY_DIM "Bireysel Kredi Taksit Ödeme"
        st.sicil_tur,
        ofis.updsicil as finsicil,
        count(*) as ADET,
        null as TUTAR,
        (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
        null TUTAR_SKALA,
        null HES_TUR,
        mm.ana_sube
   from extr.FS_OYK_FIS ofis,
        EXTR.FS_MUSTERI_MASTER mm,
        OFSDATA.NORMKADRO_SICIL_TUR st,
        (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi) th
  WHERE 1=1
        AND  ofis.updsicil BETWEEN  46000 and 48999
        and trunc(ofis.updtarih) = v_rapor_tarihi --between '01.01.2015' and '30.11.2015'
        and ofis_toplucalistir=1
        and ofis.updprogram<>'BSS899'
        and ofis.ofis_musteri = mm.musteri_no
        and ofis.updsicil =  st.finsicil
        and ofis.ofis_musteri = th.musteri_no (+)
GROUP BY trunc(ofis.updtarih),
         ofis_fsube,
         ofis_musteri,
         mm.calisma_sekli,
         st.sicil_tur,
         ofis.updsicil,
         (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
         mm.ana_sube;
COMMIT;
   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
SELECT a.fistarih,
       null as zaman_dilimi,
       a.islsube as sube,
       m.musteri_no,
       m.calisma_sekli,
       1 as islem_adi,                      --ofsdata.GISE_ISLEM_DETAY_DIM "Para Yatýrma"
     case when a.fissicil >49000 THEN 'BATCH'
          else NVL (st.sicil_tur, 'Diger')
     end as sicil_tur,
     a.fissicil as finsicil,
     COUNT(*) as adet,
     (a.tutar * f.d_alis / f.katsayi) tutar,
     (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
     case when (a.tutar * f.d_alis / f.katsayi)<=1000 THEN '1000 ve 1000 TL alti'
          when (a.tutar * f.d_alis / f.katsayi)>1000  and (a.tutar * f.d_alis / f.katsayi)<=2000 THEN '1000 ve 2000 TL arasi'
          when (a.tutar * f.d_alis / f.katsayi)>2000  and (a.tutar * f.d_alis / f.katsayi)<=5000 THEN '2000 ve 5000 TL arasi'
          else '5000 TL üstü'
     end as tutar_skala,
     A.HESTUR as hes_tur,
     M.ANA_SUBE
  FROM extr.fs_hrktdet_sg a,
       extr.fs_musteri_master m,
--       extr.fs_musteri_segment ms,
       --gizemko.kanal_bilgisi k,
       OFSDATA.NORMKADRO_SICIL_TUR st,
       (SELECT fistarih, fissicil, islsube,fisno,tutar
          FROM extr.fs_hrktdet_sg h
         WHERE h.fistarih = v_rapor_tarihi
           AND h.kmhtutar IN (100000, 110000)
           AND h.durum NOT IN (2, 3, 9)) b,
       extr.fs_fdoviz f,
       (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
WHERE a.fistarih = v_rapor_tarihi
   AND m.musteri_no = a.ilk7
--   AND m.calisma_sekli = ms.kod
--   AND a.fissicil BETWEEN k.sicil1 AND k.sicil2
   AND a.fissicil = ST.FINSICIL(+)
   AND a.fistarih = b.fistarih
   AND a.fissicil = b.fissicil
   AND a.islsube = b.islsube
   AND a.fisno = b.fisno
   AND a.tutar = b.tutar
   AND a.hestur IN ('MT', 'MY')
   AND a.durum NOT IN (2, 3, 9)
   AND a.bakod = 'A'
   AND a.fistarih = f.tarih
   AND a.para = f.para
   AND f.kurtipi = 1
   AND a.ilk7=th.musteri_no(+)
   and st.sicil_tur = 'ATM'
GROUP BY a.fistarih,
       a.islsube,
       m.musteri_no,
       m.calisma_sekli,
     case when a.fissicil >49000 THEN 'BATCH'
          else NVL (st.sicil_tur, 'Diger')
     end,
     a.fissicil,
     (a.tutar * f.d_alis / f.katsayi),
     (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
     case when (a.tutar * f.d_alis / f.katsayi)<=1000 THEN '1000 ve 1000 TL alti'
          when (a.tutar * f.d_alis / f.katsayi)>1000  and (a.tutar * f.d_alis / f.katsayi)<=2000 THEN '1000 ve 2000 TL arasi'
          when (a.tutar * f.d_alis / f.katsayi)>2000  and (a.tutar * f.d_alis / f.katsayi)<=5000 THEN '2000 ve 5000 TL arasi'
          else '5000 TL üstü'
     end,
     a.hestur,
     m.ana_sube;
COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  ofsdata.GISE_ISLEM_DETAY
SELECT a.fistarih,
       null as zaman_dilimi,
       a.islsube as sube,
       m.musteri_no,
       m.calisma_sekli,
       2 as islem_adi,      --ofsdata.GISE_ISLEM_DETAY_DIM "Para Çekme"
       case when a.fissicil >49000 THEN 'BATCH'
          else NVL (st.sicil_tur, 'Diger')
       end as sicil_tur,
       a.fissicil as finsicil,
       COUNT(*) as adet,
       (a.tutar * f.d_alis / f.katsayi) tltutar,
       (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
     case when (a.tutar * f.d_alis / f.katsayi)<=1000 THEN '1000 ve 1000 TL alti'
          when (a.tutar * f.d_alis / f.katsayi)>1000  and (a.tutar * f.d_alis / f.katsayi)<=2000 THEN '1000 ve 2000 TL arasi'
          when (a.tutar * f.d_alis / f.katsayi)>2000  and (a.tutar * f.d_alis / f.katsayi)<=5000 THEN '2000 ve 5000 TL arasi'
          else '5000 TL üstü'
     end as tutar_skala,
     A.HESTUR as hes_tur,
     M.ANA_SUBE
  FROM extr.fs_musteri_master m,
--       extr.fs_musteri_segment ms,
--       gizemko.kanal_bilgisi k,
       OFSDATA.NORMKADRO_SICIL_TUR st,
       extr.fs_hrktdet_sg a,
       (SELECT *
          FROM extr.fs_hrktdet_sg h
         WHERE h.fistarih = v_rapor_tarihi
           AND h.kmhtutar IN (100000, 110000)
           AND h.durum NOT IN (2, 3, 9)) b,
       extr.fs_fdoviz f,
      (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
WHERE a.fistarih = v_rapor_tarihi
   AND m.musteri_no = a.ilk7
--   AND m.calisma_sekli = ms.kod
   AND a.fissicil = ST.FINSICIL(+)
--   AND a.fissicil BETWEEN k.sicil1 AND k.sicil2
   AND a.fistarih = b.fistarih
   AND a.fissicil = b.fissicil
   AND a.islsube = b.islsube
   AND a.fisno = b.fisno
   AND a.tutar = b.tutar
   AND a.hestur IN ('MT', 'MY')
   AND a.durum NOT IN (2, 3, 9)
   AND a.bakod = 'B'
   AND a.fistarih = f.tarih
   AND a.para = f.para
   AND f.kurtipi = 1
      AND a.ilk7=th.musteri_no(+)
      and st.sicil_tur = 'ATM'
GROUP BY a.fistarih,
--       null as zaman_dilimi,
       a.islsube,
       m.musteri_no,
       m.calisma_sekli,
       case when a.fissicil >49000 THEN 'BATCH'
          else NVL (st.sicil_tur, 'Diger')
       end,
       a.fissicil,
       (a.tutar * f.d_alis / f.katsayi) ,
       (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
     case when (a.tutar * f.d_alis / f.katsayi)<=1000 THEN '1000 ve 1000 TL alti'
          when (a.tutar * f.d_alis / f.katsayi)>1000  and (a.tutar * f.d_alis / f.katsayi)<=2000 THEN '1000 ve 2000 TL arasi'
          when (a.tutar * f.d_alis / f.katsayi)>2000  and (a.tutar * f.d_alis / f.katsayi)<=5000 THEN '2000 ve 5000 TL arasi'
          else '5000 TL üstü'
     end,
     A.HESTUR,
     M.ANA_SUBE;

COMMIT;


   v_line_no := $$PLSQL_LINE;

--
--NOT: BATCH için a.sicil>49000
--49000?den büyükse BATCH diyoruz.

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
   SELECT     /*+ full(a) use_hash(a b) use_hash(a f) use_hash(a e) use_hash(a g) use_hash(a s1) use_hash(a s2) use_hash(a th) */
          a.tarih,
          null as zaman_dilimi,
          a.sube,
          a.musteri as musteri_no,
          B.CALISMA_SEKLI,
          7 as islem_adi,     --ofsdata.GISE_ISLEM_DETAY_DIM "Havale"
          CASE WHEN a.sicil>49000 THEN 'Batch'
               ELSE s1.kodaciklama  --'ATM'
          END as sicil_tur,
          a.sicil as finsicil,
          COUNT(*) adet,
          (a.isltutar * f.d_alis / f.katsayi) tl_tutar,
          (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
           case when (a.isltutar * f.d_alis / f.katsayi)<=1000 THEN '1000 ve 1000 TL alti'
                  when (a.isltutar * f.d_alis / f.katsayi)>1000  and (a.isltutar * f.d_alis / f.katsayi)<=2000 THEN '1000 ve 2000 TL arasi'
                  when (a.isltutar * f.d_alis / f.katsayi)>2000  and (a.isltutar * f.d_alis / f.katsayi)<=5000 THEN '2000 ve 5000 TL arasi'
                  else '5000 TL üstü'
             END as tutar_skala,
             a.bhestur,     --emir kontrol edecek.
             b.ANA_SUBE
     FROM extr.fs_masraffark a,
          (SELECT musteri_no, calisma_sekli,ana_sube FROM extr.fs_musteri_master
           UNION ALL
           SELECT musteri_no, calisma_sekli,ana_sube FROM extr.fs_inaktif_musteri) b,
          extr.fs_musteri_segment c,
          extr.fs_fdoviz f,
          extr.fs_bcekbolgem g,
          extr.fs_aff_analiz e, --altsegment aciklamasi aff_analiz_parametre tablosunda ,
          (SELECT *
             FROM extr.fs_secimparam
            WHERE secimtip = 1057) s1,
          (SELECT *
             FROM extr.fs_secimparam
            WHERE secimtip = 1056) s2,
--           OFSDATA.NORMKADRO_SICIL_TUR st,
           (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
    WHERE     a.isltip IN (1,
                           2,
                           6,
                           13,
                           14,
                           23,
                           24)
          AND a.durum = 0
          AND a.musteri = b.musteri_no
          AND b.calisma_sekli = c.kod(+)
          AND a.tarih = f.tarih
          AND a.parakodu = f.para
          AND f.kurtipi = 2
          AND a.musteri = e.musteri_no(+)
          AND a.sube = g.sube(+)
          AND a.islyeri = s1.kod(+)
          AND a.isltip = s2.kod(+)
          and a.tarih = v_rapor_tarihi
--          and a.sicil = ST.FINSICIL
--          and st.sicil_tur = 'ATM'
          and s1.kodaciklama = 'ATM'
          and s2.kodaciklama like '%HAVALE%'
          and a.musteri = th.musteri_no
GROUP BY a.tarih,
          a.sube,
          a.musteri ,
          B.CALISMA_SEKLI,
          CASE WHEN a.sicil>49000 THEN 'Batch'
               ELSE s1.kodaciklama  --'ATM'
          END ,
          a.sicil ,
          (a.isltutar * f.d_alis / f.katsayi) ,
          (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
           case when (a.isltutar * f.d_alis / f.katsayi)<=1000 THEN '1000 ve 1000 TL alti'
                  when (a.isltutar * f.d_alis / f.katsayi)>1000  and (a.isltutar * f.d_alis / f.katsayi)<=2000 THEN '1000 ve 2000 TL arasi'
                  when (a.isltutar * f.d_alis / f.katsayi)>2000  and (a.isltutar * f.d_alis / f.katsayi)<=5000 THEN '2000 ve 5000 TL arasi'
                  else '5000 TL üstü'
             END ,
             a.bhestur,
             b.ANA_SUBE;
COMMIT;

   v_line_no := $$PLSQL_LINE;

--SELECT distinct sicil_tur FROM OFSDATA.NORMKADRO_SICIL_TUR WHERE 1=1 AND upper(sicil_tur) like upper('%Mob_l%')
--'SMART MOBIL' + 'MOBIL BANKACILIK' => MOBIL
--'CALL CENTER', -> MIM
INSERT     /*+  append */ INTO gise_islem_detay
    SELECT a.tarih,
           null as zaman_dilimi,
           sube,
           a.musteri,
           mm.calisma_sekli,
           6 islem_adi, --EFT
           CASE WHEN A.ISLEMYERI IN ('SMART MOBIL', 'MOBIL BANKACILIK') THEN 'MOBIL'
                WHEN a.islemyeri in ('CALL CENTER') THEN 'MIM'
                WHEN a.islemyeri in ('INTERNET', 'ATM') THEN a.islemyeri
           END as sicil_tur,
           a.sicil as finsicil,
           COUNT(*) Adet,
           tl_tutar,
           (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
           case when tl_tutar<=1000 THEN '1000 ve 1000 TL alti'
                  when tl_tutar>1000  and tl_tutar<=2000 THEN '1000 ve 2000 TL arasi'
                  when tl_tutar>2000  and tl_tutar<=5000 THEN '2000 ve 5000 TL arasi'
                  else '5000 TL üstü'
             END tutar_skala,
           substr(gonderen_hesap,
                               instr(gonderen_hesap,'-',1,3)+1,
                               instr(gonderen_hesap,'-',1,4)-instr(gonderen_hesap,'-',1,3)-1
                              ) as hes_tur,
           mm.Ana_sube
    FROM OFSDATA.V_EFTHAVALE a
         LEFT JOIN EXTR.FS_MUSTERI_MASTER mm ON A.MUSTERI = MM.MUSTERI_NO
         LEFT JOIN (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th ON a.musteri = th.musteri_no
    WHERE 1=1
          AND islemtip LIKE '%EFT%'
          and tarih = v_rapor_tarihi
--    and sicil_tur = 'Genel Müdürlük'
        and islemyeri in ( 'INTERNET', 'MOBIL BANKACILIK', 'CALL CENTER', 'ATM', 'SMART MOBIL')
    GROUP BY a.tarih,
           sube,
           a.musteri,
           mm.calisma_sekli,
           CASE WHEN A.ISLEMYERI IN ('SMART MOBIL', 'MOBIL BANKACILIK') THEN 'MOBIL'
                WHEN a.islemyeri in ('CALL CENTER') THEN 'MIM'
                WHEN a.islemyeri in ('INTERNET', 'ATM') THEN a.islemyeri
           END,
           a.sicil,
           tl_tutar,
           (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
           case when tl_tutar<=1000 THEN '1000 ve 1000 TL alti'
                  when tl_tutar>1000  and tl_tutar<=2000 THEN '1000 ve 2000 TL arasi'
                  when tl_tutar>2000  and tl_tutar<=5000 THEN '2000 ve 5000 TL arasi'
                  else '5000 TL üstü'
             END ,
           substr(gonderen_hesap,
                               instr(gonderen_hesap,'-',1,3)+1,
                               instr(gonderen_hesap,'-',1,4)-instr(gonderen_hesap,'-',1,3)-1
                              ) ,
           mm.Ana_sube ;

           COMMIT;


   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
 SELECT trunc(fis_tarihi) as tarih, null as zaman_dilimi , kredi_sube_kodu as sube,  to_number(substr(trim(kredi_hesap_no),2,8)) as mus_no,
        mm.calisma_sekli,
        3 as islem_adi, --ofsdata.GISE_ISLEM_DETAY_DIM "Bireysel Kredi Taksit Ödeme"
        'ATM' as sicil_tur, fis_sicil as finsicil,
        COUNT(*) as adet,
        odenecek_net_tutar as tutar,
        (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
        case when a.odenecek_net_tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.odenecek_net_tutar>1000  and a.odenecek_net_tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.odenecek_net_tutar>2000  and a.odenecek_net_tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
               end tutar_skala,
        'KS' as hestur,
        mm.ana_sube
   FROM extr.OY_ATM_TAKSIT_TAHSILATI a
        INNER JOIN EXTR.FS_MUSTERI_MASTER mm ON to_number(substr(trim(a.kredi_hesap_no),2,8)) = MM.MUSTERI_NO
        LEFT JOIN (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
                  ON to_number(substr(trim(a.kredi_hesap_no),2,8))=th.musteri_no
  WHERE a.durum = 'G'
        AND TRUNC (a.fis_tarihi) = v_rapor_tarihi
GROUP BY trunc(fis_tarihi), kredi_sube_kodu,  to_number(substr(trim(kredi_hesap_no),2,8)),
        mm.calisma_sekli,
        fis_sicil,
        odenecek_net_tutar,
        (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
        case when a.odenecek_net_tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.odenecek_net_tutar>1000  and a.odenecek_net_tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.odenecek_net_tutar>2000  and a.odenecek_net_tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
               end,
        mm.ana_sube;
COMMIT;

   v_line_no := $$PLSQL_LINE;



--INSERT           /*+ APPEND */ INTO GISE_ISLEM_DETAY
--        SELECT   isltarih tarih,
--                 null as zaman_dilimi,
--                 islsube sube,
--                 a.KARHILK7 as musteri_no,
--                 MM.CALISMA_SEKLI,
--                 7 as islem_adi,     --ofsdata.GISE_ISLEM_DETAY_DIM "Havale"        --norm kadro rapor: 'Kasadan Hesaba Yapýlan Havaleler'
--                 case when a.karhilk7 >49000 THEN 'BATCH'
--                      else NVL (f.sicil_tur, 'Diger')
--                 end as sicil_tur,
--                 a.islsicil as finsicil,
--                 COUNT ( * ) adet,
--                 SUM(Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)) tutar,
--                 --(CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END)
--                 null as turuncu_hesap,  --16.09.2014 tarihinde eklendi
--                 CASE when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=1000 THEN '1000 ve 1000 TL alti'
--                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>1000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=2000 THEN '1000 ve 2000 TL arasi'
--                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>2000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=5000 THEN '2000 ve 5000 TL arasi'
--                      else '5000 TL üstü'
--                 END as tutar_skala,
--                 a.karhhestur,
--                 MM.ANA_SUBE
--          FROM   extr.FS_SUBCARI a
--                 LEFT JOIN OFSDATA.NORMKADRO_SICIL_TUR f ON f.finsicil = a.islsicil
--                 INNER JOIN extr.fs_musteri_master mm ON a.karhilk7 = mm.musteri_no
--                 INNER JOIN extr.FS_FDOVIZ fd ON a.isltarih = fd.tarih
--                                                 and fd.kurtipi = 1
--                                                 and fd.para = a.para
----                 LEFT JOIN (SELECT distinct musteri_no,rapor_tarihi FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi =v_rapor_tarihi  ) th
----                           ON  a.karhilk7=th.musteri_no
----                                and A.isltarih = th.rapor_tarihi
----                                and th.rapor_tarihi =v_rapor_tarihi
--         WHERE       isltarih = v_rapor_tarihi
--                 AND islbakod = 'B'
--                 AND a.durum = 1
--                 AND a.isltur IN ( 2)
----                 AND a.islhestur = 'KS'
--                 AND karhhestur <> 'KS'
--      GROUP BY   isltarih,
--                 islsube,
--                 a.KARHILK7,
--                 MM.CALISMA_SEKLI,
--                 case when a.karhilk7 >49000 THEN 'BATCH'
--                      else NVL (f.sicil_tur, 'Diger')
--                 END,
--                 a.islsicil,
----                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) ,
--                 CASE when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=1000 THEN '1000 ve 1000 TL alti'
--                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>1000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=2000 THEN '1000 ve 2000 TL arasi'
--                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>2000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=5000 THEN '2000 ve 5000 TL arasi'
--                      else '5000 TL üstü'
--                 END ,
--                 a.karhhestur,
--                 mm.ana_sube;

--COMMIT;
  /*kanal göçü kapsamýnda ilave edilen kodlar:BÝTÝÞ*/
--   v_line_no := $$PLSQL_LINE;





INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
        SELECT   isltarih tarih,
                 null as zaman_dilimi,
                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
                 islsube sube,
                 ilk7 musteri_no,
                 calisma_sekli,
                 4 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Cüzdan Bastirma"
                 --NVL (f.sicil_tur, 'Diger') islem_tur,
                 case when c.islsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as islem_tur,
                 c.islsicil,
                 COUNT ( * ) adet,
                 SUM(bakiye) tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when c.bakiye<=1000 THEN '1000 ve 1000 TL alti'
                      when c.bakiye>1000  and c.bakiye<=2000 THEN '1000 ve 2000 TL arasi'
                      when c.bakiye>2000  and c.bakiye<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 c.hestur,
                 m.ana_sube
          FROM   extr.FS_CUZDANLOG c,
                 ofsdata.NORMKADRO_SICIL_TUR f,
                 extr.FS_MUSTERI_MASTER m,
                 (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
         WHERE       1 = 1
                 AND c.isltarih = v_rapor_tarihi
                 and m.musteri_no = c.ilk7
                 AND c.islsicil = f.finsicil(+)
                 and c.isltur=1 and c.mesaj='2.Insert'
                 and c.ilk7 = th.musteri_no (+)
      GROUP BY   c.islsicil,
                 islsube,
                 --NVL (f.sicil_tur, 'Diger'),
                 case when c.islsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 c.islsicil,
                 ilk7,
                 calisma_sekli,
                 isltarih,
                 case when c.bakiye<=1000 THEN '1000 ve 1000 TL alti'
                      when c.bakiye>1000  and c.bakiye<=2000 THEN '1000 ve 2000 TL arasi'
                      when c.bakiye>2000  and c.bakiye<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end,
                 c.hestur,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
                 m.ana_sube;

                 COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
        SELECT   a.girtarih tarih,
                 null as zaman_dilimi,
                 --to_char(trunc(to_date(substr(girzaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(girzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
                 a.girsube sube,
                 a.bhesmusteri musteri_no,
                 calisma_sekli,
--                 (CASE
--                     WHEN refnit = 'KD' THEN 8   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Giden EFT Hesaba"
--                     WHEN refnit = 'NM' THEN 9   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Giden EFT Isme"
--                     WHEN refnit = 'KK' THEN 10  --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Giden EFT Kredi Kartina"
--                  END)
                 6 as islem_adi,
                 --NVL (f.sicil_tur, 'Diger') sicil_tur,
                 case when a.girsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.girsicil,
                 COUNT ( * ) adet,
                 SUM(a.tutar) tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
                      when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                      when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 a.bhestur,
                 m.ana_sube
          FROM   EXTR.FS_EFTMSG a,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m,
                 (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
         WHERE   NOT EXISTS
                    (SELECT 1
                       FROM EXTR.FS_SOPREFERANS t
                      WHERE islemtur = 1
                        AND durum = 8
                        AND tarih = v_rapor_tarihi
                        AND a.sube = t.sube
                        AND a.reftur = t.reftur
                        AND a.refsirano = t.refsirano)
                 AND a.girtarih = v_rapor_tarihi
                 AND a.girsicil = f.finsicil(+)
                 --AND sicil_tur in ('Gise','Operasyon')
                 AND a.alsaat <> 'SOP'
                 --AND bhessinif = 'C'      --26.12.2014 tarihinde çikarildi. Ilteris MUTLU, Mutlu Emir BILISIK
                 and a.odeme_kaynak = 'S'   --26.12.2014 tarihinde eklendi. Ilteris MUTLU, Mutlu Emir BILISIK
                 AND a.reftur = 'OM'
                 AND (refnit IN ('KD', 'NM', 'KK'))
                 and m.musteri_no = a.bhesmusteri
                 and a.bhesmusteri = th.musteri_no(+)
      GROUP BY   girtarih,
                 girsube,
--                 (CASE
--                     WHEN refnit = 'KD' THEN 8   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Giden EFT Hesaba"
--                     WHEN refnit = 'NM' THEN 9   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Giden EFT Isme"
--                     WHEN refnit = 'KK' THEN 10  --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Giden EFT Kredi Kartina"
--                  END),
                 --NVL (f.sicil_tur, 'Diger'),
                 case when a.girsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.girsicil,
                 calisma_sekli,
                 bhesmusteri,
                 case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
                      when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                      when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end,
                 a.bhestur,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
                 m.ana_sube;
COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
         SELECT                             /*+ Full (a)*/
                 isltarih tarih,
                 null as zaman_dilimi,
                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
                 islsube sube,
                 karhilk7 musteri_no,
                 calisma_sekli,
                 1 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Farkli Sube TL Hesaba TL Para Yatirma"
                 --NVL (f.sicil_tur, 'Diger') sicil_tur,
                 case when a.islsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.islsicil,
                 COUNT (DISTINCT islsube || isltarih || a.islsicil || islfisno) adet,
                 SUM(Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)) tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,  --16.09.2014 tarihinde eklendi
                 CASE when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=1000 THEN '1000 ve 1000 TL alti'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>1000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=2000 THEN '1000 ve 2000 TL arasi'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>2000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 END as tutar_skala,
                 'KS' as hestur,
                 m.ana_sube
          FROM   EXTR.FS_SUBCARI a,
                 extr.FS_FDOVIZ fd,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m,
                 (SELECT distinct musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
         WHERE   a.karhilk7=th.musteri_no(+)          --16.09.2014 tarihinde eklendi
                 AND a.isltarih = v_rapor_tarihi
                 --and para = 0 --fs_fdoviz ile joinlendi. 10.03.2015 Ýlteriþ M.
                 AND a.islhestur in('KS')
                 AND a.islbakod = 'B'
                 AND a.islsicil = f.finsicil(+)
                 --and f.sicil_tur in ('Gise', 'Operasyon')
                 and m.musteri_no = a.karhilk7
                 and a.karhilk7 <> 0
                 and a.isltarih = fd.tarih
                 and fd.kurtipi = 1
                 and fd.para = a.para
      GROUP BY   isltarih,
                 islsube,
                 --NVL (f.sicil_tur, 'Diger'),
                 case when a.islsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.islsicil,
                 karhilk7,
                 calisma_sekli,
                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI'),
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,
                 CASE when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=1000 THEN '1000 ve 1000 TL alti'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>1000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=2000 THEN '1000 ve 2000 TL arasi'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>2000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 END,
                 m.ana_sube;


COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
        SELECT           /*+ Full (a)*/
                 isltarih tarih,
                 null as zaman_dilimi,
                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
                 islsube sube,
                 karhilk7 musteri_no,
                 calisma_sekli,
                 2 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Farkli Sube TL Hesaptan TL Para Çekme"
                 --NVL (f.sicil_tur, 'Diger') sicil_tur,
                 case when a.islsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 a.islsicil,
                 COUNT (DISTINCT islsube || isltarih || islsicil || islfisno) adet,
                 SUM(Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)) tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 CASE when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=1000 THEN '1000 ve 1000 TL alti'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>1000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=2000 THEN '1000 ve 2000 TL arasi'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>2000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 END as tutar_skala,
                 'KS' as hestur,
                 m.ana_sube
          FROM   EXTR.FS_SUBCARI a,
                 extr.FS_FDOVIZ fd,
                 OFSDATA.NORMKADRO_SICIL_TUR f,
                 EXTR.FS_MUSTERI_MASTER m,
                 (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
         WHERE   1=1
                 AND a.karhilk7=th.musteri_no(+)
                 AND isltarih = v_rapor_tarihi
                 AND islhestur = 'KS'
                 AND islbakod = 'A'
                 --AND para = 0
                 AND a.islsicil = f.finsicil(+)
                 --AND sicil_tur in('Gise','Operasyon')
                 AND m.musteri_no = a.karhilk7
                 and a.isltarih = fd.tarih
                 and fd.kurtipi = 1
                 and fd.para = a.para
      GROUP BY   isltarih,
                 islsube,
                 --NVL (f.sicil_tur, 'Diger'),
                 case when a.islsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 a.islsicil,
                 karhilk7,
                 calisma_sekli,
                 --f.finsicil,
                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI'),
                 CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END,     --16.09.2014 tarihinde eklendi
                 CASE when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=1000 THEN '1000 ve 1000 TL alti'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>1000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=2000 THEN '1000 ve 2000 TL arasi'
                      when Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)>2000  and Round(a.ISLTUTAR * fd.d_alis / fd.katsayi, 2)<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 END,
                 m.ana_sube;
COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
       SELECT    zz.fistarih tarih,
                 null as zaman_dilimi,
                 --to_char(trunc(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'hh')+
                 --(width_bucket(to_number(to_char(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI')  zaman_dilimi,
                 zz.fissube sube,
                 brcilk7 musteri_no,
                 calisma_sekli,
                 5 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Fatura Tahsilatlari"
                 case when zz.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end as sicil_tur,
                 --NVL (f.sicil_tur, 'Diger') sicil_tur,
                 zz.fissicil,--f.finsicil,
                 SUM (islem_adet) adet,
                 SUM(tutar) tutar,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,
                 case when zz.tutar<=1000 THEN '1000 ve 1000 TL alti'
                      when zz.tutar>1000  and zz.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                      when zz.tutar>2000  and zz.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end as tutar_skala,
                 zz.brchestur as hestur,
                 m.ana_sube
          FROM   (  SELECT   'TEB CETELEM' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             35 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   EXTR.FS_ACETELEMTAHSIL tah
                     WHERE   tah.durumkodu < 8
                             --AND tah.fissicil <> 49001    --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                   GROUP BY  tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   'AFJET-AFYON SU' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             24 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.afytahsil_fsbcv tah
                     WHERE       tah.durumkodu < 8
                             --AND tah.fissicil <> 49001      --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                UNION
                    SELECT   'ANKARA SU (ASKI)' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             12 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.askitahsil_fsbcv tah
                     WHERE       tah.durumkodu < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                 UNION
                    SELECT   'ANKARA TICARET ODASI (ATO)' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             34 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_atotahsil tah
                     WHERE       tah.durumkodu < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   'IZMIT GAZ (IZGAZ)' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             39 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_botastahsil tah
                     WHERE       tah.durumkodu < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   'HSBC K.K.' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             18 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_cititahsil tah
                     WHERE       tah.durumkodu < 8
                             AND tah.fissicil <> 49001
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   kurum.kurum kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             tah.krm_id krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.gnlfattahsil_fsbcv tah,
                             extr.fs_toptah_kurum kurum
                     WHERE       tah.durumkodu < 8
                             AND kurum.tahsilat_talimat = 'TAH'
                             AND kurum.durum < 8
                             AND tah.krm_id = kurum.kurumkodu
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube,
                             tah.fistarih,
                             tah.fissicil,
                             kurum.kurum,
                             tah.krm_id,
                             brcilk7,
                             brchestur
                  UNION
                    SELECT   kurum.kurum kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             kurum.kurumkodu krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.igdastahsil_fsbcv tah,
                             extr.fs_toptah_kurum kurum
                     WHERE       tah.durumkodu < 8
                             AND kurum.tahsilat_talimat = 'TAH'
                             AND kurum.durum < 8
                             AND kurum.kurumkodu =
                                   DECODE (TRIM (tah.islemtipi), 'B', 527, 131)
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,
                             tah.fissube,
                             tah.fistarih,
                             tah.fissicil,
                             kurum.kurum,
                             kurum.kurumkodu,brcilk7,
                             brchestur
                  UNION
                    SELECT   'ISKI (ISTANBUL SU)' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             11 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_kurum_tahsil tah  --extr.fs_iskitahsil tah
                     WHERE    tah.krm_id=11
                             AND tah.durumkodu < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   'KOÇ FINANS(Talep No)' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             6 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.kocfintahsil_fsbcv tah
                     WHERE   tah.durumkodu < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   kurum.kurum kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             tah.krm_id krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_mtstahsil tah,
                             extr.fs_toptah_kurum kurum
                     WHERE       tah.durumkodu < 8
                             AND kurum.tahsilat_talimat = 'TAH'
                             AND kurum.durum < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             AND tah.krm_id = kurum.kurumkodu
                             AND tah.krm_id <> 79
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,
                             tah.fissube,
                             tah.fistarih,
                             tah.fissicil,
                             kurum.kurum,
                             tah.krm_id,brcilk7,brchestur
                  UNION
                    SELECT   'TTNET-ADSL' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             79 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_mtstahsil tah
                     WHERE       tah.durumkodu < 8
                             AND tah.krm_id = 79
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
                  UNION
                    SELECT   kurum.kurum kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             tah.krm_id krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.sutahsil_fsbcv tah,
                             extr.fs_toptah_kurum kurum
                     WHERE       tah.durumkodu < 8
                             AND kurum.tahsilat_talimat = 'TAH'
                             AND kurum.durum < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             AND tah.krm_id = kurum.kurumkodu
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube,
                             tah.fistarih,
                             tah.fissicil,
                             kurum.kurum,
                             tah.krm_id,brcilk7,brchestur
                  UNION
                    SELECT   'null' kurum,
                             tah.fissube,
                             brcilk7,
                             tah.fistarih,
                             tah.fissicil,
                             tah.fisno,
                             COUNT ( * ) islem_adet,
                             1 krm_id,
                             SUM(tutar) tutar,
                             brchestur
                      FROM   extr.fs_tedastahsil tah
                     WHERE       tah.durumkodu < 8
                             --AND tah.fissicil <> 49001     --15.04.2015
                             AND tah.fistarih = v_rapor_tarihi
                             --AND brchestur in ('MT','MY')
                  GROUP BY   tah.fisno,tah.fissube, tah.fistarih, tah.fissicil,brcilk7,brchestur
               ) zz,
               OFSDATA.NORMKADRO_SICIL_TUR f,
               EXTR.FS_MUSTERI_MASTER m,
               (SELECT                            /*+parallel ( sg 4) */
                      distinct --fiszaman,  fiszaman formatlandi.26.12.2014. Ilteris MUTLU
                      case when substr(fiszaman,2,1)='.'
                                then to_char(to_number(substr(fiszaman,1,1))+12) || ':'||substr(fiszaman,3,2)||':'||substr(fiszaman,6,8)
                           else fiszaman
                      end as fiszaman,
                      sg.fistarih,sg.fissicil,sg.fisno,sg.islsube,sg.ilk7
                 FROM EXTR.FS_hrktdet_sg sg
                WHERE fistarih = v_rapor_tarihi
                  AND BAKOD = 'B'
                  --AND hestur in ('MT','MY')
               ) sg,
               (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
         WHERE 1=1
           AND zz.brcilk7=th.musteri_no(+)
           AND zz.fissicil = f.finsicil(+)
           AND zz.fistarih=sg.fistarih
           AND zz.fissicil = sg.fissicil
           AND zz.fisno = sg.fisno
           AND zz.fissube = sg.islsube
           AND zz.brcilk7=sg.ilk7
           --AND f.sicil_tur in ('Gise','Operasyon')
           AND m.musteri_no = zz.brcilk7
      GROUP BY   zz.fistarih,
                 zz.fissube,
                 case when zz.fissicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 zz.fissicil,
                 brcilk7,
                 calisma_sekli,
                 case when zz.tutar<=1000 THEN '1000 ve 1000 TL alti'
                      when zz.tutar>1000  and zz.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                      when zz.tutar>2000  and zz.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                      else '5000 TL üstü'
                 end,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
                 zz.brchestur,
                 m.ana_sube;
COMMIT;

   v_line_no := $$PLSQL_LINE;


--Hesaptan hesaba yapýlan havaleler olarak yeni bir iþlem adýyla eklenmiþtir. Bu nedenle buradan kaldýrýldý.
--INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
--         SELECT  isltarih tarih,
--                 null as zaman_dilimi,
--                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
--                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
--                 islsube sube,
--                 islhilk7 musteri_no,
--                 calisma_sekli,
--                 7 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Hesaptan Yapilan Havale"
--                 case when a.islsicil >49000 THEN 'BATCH'
--                      else NVL (f.sicil_tur, 'Diger')
--                 end as sicil_tur,
--                 a.islsicil,
--                 COUNT ( * ) adet,
--                 SUM(isltutar) tutar,
--                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,     --16.09.2014 tarihinde eklendi
--                 case when a.isltutar<=1000 THEN '1000 ve 1000 TL alti'
--                      when a.isltutar>1000  and a.isltutar<=2000 THEN '1000 ve 2000 TL arasi'
--                      when a.isltutar>2000  and a.isltutar<=5000 THEN '2000 ve 5000 TL arasi'
--                      else '5000 TL üstü'
--                 end as tutar_skala,
--                 a.islhestur,
--                 m.ana_sube
--           FROM  EXTR.FS_SUBCARI a, OFSDATA.NORMKADRO_SICIL_TUR f,EXTR.FS_MUSTERI_MASTER m,
--                 (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
--          WHERE  1=1
--                 AND isltarih = v_rapor_tarihi
--                 AND a.islsicil = f.finsicil(+)
--                 AND islbakod = 'B'
--                 AND a.durum = 1
--                 AND a.isltur IN ( 1,2)
----                 AND a.islhestur = 'KS'
--                 AND karhhestur <> 'KS'
--                 --AND sicil_tur in ('Gise','Operasyon')
--                 and a.islhilk7 = m.musteri_no(+)
--                 AND a.islhilk7 = th.musteri_no(+)
--     GROUP BY    isltarih,
--                 --to_char(trunc(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'hh')+
--                 --(width_bucket(to_number(to_char(to_date(substr(islzaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI'),
--                 islsube,
--                 case when a.islsicil >49000 THEN 'BATCH'
--                      else NVL (f.sicil_tur, 'Diger')
--                 end,
--                 a.islsicil,
--                 islhilk7,
--                 calisma_sekli,
--                 case when a.isltutar<=1000 THEN '1000 ve 1000 TL alti'
--                      when a.isltutar>1000  and a.isltutar<=2000 THEN '1000 ve 2000 TL arasi'
--                      when a.isltutar>2000  and a.isltutar<=5000 THEN '2000 ve 5000 TL arasi'
--                      else '5000 TL üstü'
--                 end,
--                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
--                 a.islhestur,
--                 m.ana_sube;
--COMMIT;
--
--   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
       SELECT  fistarih tarih,
               null as zaman_dilimi,
               --to_char(trunc(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'hh')+
               --(width_bucket(to_number(to_char(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
               islsube sube,
               ilk7 musteri_no,
               calisma_sekli,
               8 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Kredi Karti Nakit Avans"
               case when a.updsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
               end as sicil_tur,
               a.updsicil finsicil,
               COUNT ( * ) adet ,
               SUM (tutar) tutar,
               (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,     --16.09.2014 tarihinde eklendi
               case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
               end as tutar_skala,
               hestur,
               m.ana_sube
          FROM EXTR.FS_HRKTDET_SG a, OFSDATA.NORMKADRO_SICIL_TUR f, EXTR.FS_MUSTERI_MASTER m,
               (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
         WHERE   1 = 1
                 AND fistarih = v_rapor_tarihi
                 AND a.durum = 0
                 AND a.updprogram IN ('KKR101', 'KKR106')
                 AND a.updsicil = f.finsicil(+)
                 --AND sicil_tur in ('Operasyon','Gise')
                 AND hestur ='KT'
                 AND a.ilk7 = m.musteri_no
                 AND a.ilk7 = th.musteri_no(+)
       GROUP BY  fistarih,
                 islsube,
                 ilk7,
                 a.updsicil,
                 calisma_sekli,
                 case when a.updsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
                 end,
                 case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
                 end,
                 (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
                 hestur,
                 m.ana_sube;
COMMIT;
   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
--Kredi Kartý Tahsilatý 9.iþlem turu
----Kredi Kartý Tahsilatlarý_ATM
SELECT
A.FISTARIH AS TARIH
,NULL AS ZAMAN_DILIMI
,A.ISLSUBE SUBE
,A.ILK7 AS MUSTERI_NO
,M.CALISMA_SEKLI
,9 AS ISLEM_ADI -- 06.01.2018  tarihinde deðiþtirildi   ofsdata.GISE_ISLEM_DETAY_DIM "Kredi Karti Tahsilati"
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END AS SICIL_TUR
,A.FISSICIL
,COUNT(*) ISLEM_ADET
,SUM( (a.tutar * f.d_alis / f.katsayi)) ISLEM_TUTAR
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
AS TURUNCU_HESAP
,CASE
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) <= 1000 THEN '1000 ve 1000 TL alti'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 1000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 2000 THEN '1000 ve 2000 TL arasi'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 2000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 5000 THEN '2000 ve 5000 TL arasi'
ELSE '5000 TL üstü' END AS TUTAR_SKALA
,NULL AS HESTUR
,M.ANA_SUBE
FROM
EXTR.FS_HRKTDET_SG A
,OFSDATA.NORMKADRO_SICIL_TUR C
,EXTR.FS_MUSTERI_MASTER M
,EXTR.FS_FDOVIZ F
,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =v_rapor_tarihi) TH
WHERE
1=1
AND A.FISSICIL = C.FINSICIL(+)
AND M.MUSTERI_NO = A.ILK7
 AND A.ILK7 = TH.MUSTERI_NO(+)
AND A.FISTARIH = F.TARIH
AND A.PARA = F.PARA
AND F.KURTIPI = 1
AND a.fistarih =v_rapor_tarihi
AND  A.UPDPROGRAM IN ('KKR102')
AND A.HESTUR NOT IN ('SC', 'BL')
AND ACIK1 LIKE ('ATM%')
AND BAKOD = 'A'
GROUP BY
A.FISTARIH
,A.ISLSUBE
,A.ILK7
,M.CALISMA_SEKLI
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
 ,A.FISSICIL
 ,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
 ,M.ANA_SUBE
 UNION ALL
--Kredi Kartý Tahsilatlarý_Internet-Mobil
SELECT
 A.FISTARIH AS TARIH
,NULL AS ZAMAN_DILIMI
,A.ISLSUBE SUBE
,A.ILK7 AS MUSTERI_NO
,M.CALISMA_SEKLI
,9 AS ISLEM_ADI -- --06.01.2018  tarihinde deðiþtirildi  ofsdata.GISE_ISLEM_DETAY_DIM "Kredi Karti Tahsilati"
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH'
ELSE NVL(C.SICIL_TUR, 'Diger') END AS SICIL_TUR
, A.FISSICIL
,COUNT(*) ISLEM_ADET
,SUM((a.tutar * f.d_alis / f.katsayi)) ISLEM_TUTAR
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END) AS TURUNCU_HESAP
,CASE
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) <= 1000 THEN '1000 ve 1000 TL alti'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 1000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 2000 THEN '1000 ve 2000 TL arasi'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 2000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 5000 THEN '2000 ve 5000 TL arasi'
ELSE '5000 TL üstü' END AS TUTAR_SKALA
,NULL AS HESTUR
,M.ANA_SUBE
FROM
EXTR.FS_HRKTDET_SG a
, OFSDATA.NORMKADRO_SICIL_TUR c
,EXTR.FS_MUSTERI_MASTER M
,EXTR.FS_FDOVIZ F
,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =v_rapor_tarihi) TH
where
1=1
AND A.FISSICIL = C.FINSICIL(+)
AND M.MUSTERI_NO = A.ILK7
 AND A.ILK7 = TH.MUSTERI_NO(+)
AND A.FISTARIH = F.TARIH
AND A.PARA = F.PARA
AND F.KURTIPI = 1
AND a.fistarih =v_rapor_tarihi
AND A.updprogram IN ('KKR102')
and A.hestur not in ('SC','BL')
and A.bakod = 'B'
and c.sicil_tur in ('INTERNET','MOBIL')
AND A.FISTARIH = F.TARIH
AND A.PARA = F.PARA
AND F.KURTIPI = 1
GROUP BY
 A.FISTARIH
,A.ISLSUBE
,A.ILK7
,M.CALISMA_SEKLI
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
 ,A.FISSICIL
 ,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
 ,M.ANA_SUBE
UNION ALL
--Kredi Kartý Tahsilatlarý_Þube
select
A.FISTARIH AS TARIH
,NULL AS ZAMAN_DILIMI
,A.ISLSUBE SUBE
,A.ILK7 AS MUSTERI_NO
,M.CALISMA_SEKLI
,9 AS ISLEM_ADI -- --06.01.2018  tarihinde deðiþtirildi.ofsdata.GISE_ISLEM_DETAY_DIM "Kredi Karti Tahsilati"
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH'
ELSE NVL(C.SICIL_TUR, 'Diger') END AS SICIL_TUR
, A.FISSICIL
,COUNT(*) ISLEM_ADET
,SUM((a.tutar * f.d_alis / f.katsayi)) ISLEM_TUTAR
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END) AS TURUNCU_HESAP
,CASE
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) <= 1000 THEN '1000 ve 1000 TL alti'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 1000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 2000 THEN '1000 ve 2000 TL arasi'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 2000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 5000 THEN '2000 ve 5000 TL arasi'
ELSE '5000 TL üstü' END AS TUTAR_SKALA
,NULL AS HESTUR
,M.ANA_SUBE
from EXTR.FS_HRKTDET_SG a
, OFSDATA.NORMKADRO_SICIL_TUR c
,EXTR.FS_MUSTERI_MASTER M
,EXTR.FS_FDOVIZ F
,(SELECT DISTINCT MUSTERI_NO  FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =v_rapor_tarihi) TH
where
1=1
AND A.FISSICIL = C.FINSICIL(+)
AND M.MUSTERI_NO = A.ILK7
 AND A.ILK7 = TH.MUSTERI_NO(+)
AND A.FISTARIH = F.TARIH
AND A.PARA = F.PARA
AND F.KURTIPI = 1
AND a.fistarih =v_rapor_tarihi
AND A.updprogram IN ('KKR102')
and A.fistarih=v_rapor_tarihi
and a.hestur='MT'
and a.ACIK1 like ('SUB%')
and a.bakod = 'B'
GROUP BY
 A.FISTARIH
,A.ISLSUBE
,A.ILK7
,M.CALISMA_SEKLI
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
 ,A.FISSICIL
 ,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
 ,M.ANA_SUBE
UNION ALL
--Kredi Kartý Tahsilatlarý_Batch
select
A.FISTARIH AS TARIH
,NULL AS ZAMAN_DILIMI
,A.ISLSUBE SUBE
,A.ILK7 AS MUSTERI_NO
,M.CALISMA_SEKLI
,9 AS ISLEM_ADI -- 06.01.2018  tarihinde deðiþtirildi   ofsdata.GISE_ISLEM_DETAY_DIM "Kredi Karti Tahsilati"
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH'
ELSE NVL(C.SICIL_TUR, 'Diger') END AS SICIL_TUR
, A.FISSICIL
,COUNT(*) ISLEM_ADET
,SUM((a.tutar * f.d_alis / f.katsayi)) ISLEM_TUTAR
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END) AS TURUNCU_HESAP
,CASE
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) <= 1000 THEN '1000 ve 1000 TL alti'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 1000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 2000 THEN '1000 ve 2000 TL arasi'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 2000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 5000 THEN '2000 ve 5000 TL arasi'
ELSE '5000 TL üstü' END AS TUTAR_SKALA
,NULL AS HESTUR
,M.ANA_SUBE
from EXTR.FS_HRKTDET_SG a
, OFSDATA.NORMKADRO_SICIL_TUR c
,EXTR.FS_MUSTERI_MASTER M
,EXTR.FS_FDOVIZ F
,(SELECT DISTINCT MUSTERI_NO  FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI =v_rapor_tarihi) TH
where
1=1
AND A.FISSICIL = C.FINSICIL(+)
AND M.MUSTERI_NO = A.ILK7
 AND A.ILK7 = TH.MUSTERI_NO(+)
AND A.FISTARIH = F.TARIH
AND A.PARA = F.PARA
AND F.KURTIPI = 1
AND a.fistarih =v_rapor_tarihi
AND a.updprogram IN ('KKR102')
AND  a.durum = 0
and ACIK1 not in ('RISK KAPAMA')
and ACIK1 not like ('ATM%')
and c.sicil_tur is null
GROUP BY
 A.FISTARIH
,A.ISLSUBE
,A.ILK7
,M.CALISMA_SEKLI
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
 ,A.FISSICIL
 ,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
 ,M.ANA_SUBE;

  /*iþlem bazýnda coklama oldugundan iþ birimi talebi ile yukarýdaki yeni kod ile replace edildi* 06.01.2018*/
--       SELECT  a.fistarih tarih,
--               null as zaman_dilimi,
--               --to_char(trunc(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'hh')+
--               --(width_bucket(to_number(to_char(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
--               a.islsube sube,
--               b.ilk7 musteri_no,
--               m.calisma_sekli,
--               9 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Kredi Karti Tahsilati"
--               case when a.fissicil >49000 THEN 'BATCH'
--                  else NVL (f.sicil_tur, 'Diger')
--               end as sicil_tur,
--               a.fissicil,
--               COUNT ( * ) islem_adet,
--               SUM (a.tutar) islem_tutar,
--               (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,     --16.09.2014 tarihinde eklendi
--               case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
--                    when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
--                    when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
--                    else '5000 TL üstü'
--               end as tutar_skala,
--               a.hestur,
--               m.ana_sube
--         FROM  EXTR.FS_HRKTDET_SG a,
--               EXTR.FS_HRKTDET_SG b,
--               OFSDATA.NORMKADRO_SICIL_TUR f,
--               EXTR.FS_MUSTERI_MASTER m,
--               (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
--        WHERE  1 = 1
--               AND a.fistarih = v_rapor_tarihi
--               AND a.durum = 0
--               AND a.updprogram IN ('KKR102')
--               AND m.musteri_no = b.ilk7
--               AND b.fissicil = f.finsicil(+)
--               --AND sicil_tur in ('Operasyon','Gise')
--               AND a.HESTUR <>'SC'
--               AND b.HESTUR <>'SC'
--               and a.bakod = 'B'
--               and b.bakod = 'A'
--               AND b.durum = 0
--               AND b.updprogram IN ('KKR102')
--               and a.fistarih = b.fistarih and a.fissicil = b.fissicil and a.fisno=b.fisno and a.fiszaman = b.fiszaman
--               AND a.ilk7 = th.musteri_no(+)
--      GROUP BY a.islsube,
--               b.ilk7,
--               a.fissicil,
--               calisma_sekli,
--               case when a.fissicil >49000 THEN 'BATCH'
--                  else NVL (f.sicil_tur, 'Diger')
--               end,
--               a.fistarih,
--               case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
--                    when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
--                    when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
--                    else '5000 TL üstü'
--               end,
--               (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
--               a.hestur,
--               m.ana_sube;

COMMIT;

   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
       SELECT  fistarih tarih,
               null as zaman_dilimi,
               --to_char(trunc(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'hh')+
               --(width_bucket(to_number(to_char(to_date(substr(fiszaman,1,8),'HH24:MI:SS'), 'mi')), 0 , 60, 4)-1)*15/(24*60),'HH24:MI') zaman_dilimi,
               islsube sube,
               ilk7 musteri_no,
               calisma_sekli,
               10 as islem_adi,   --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM "Motorlu Tasit Vergi Tahsilati"
               case when a.updsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
               end as sicil_tur,
               a.fissicil,
               COUNT (DISTINCT islsube || fistarih || a.fissicil || fisno) adet,
               SUM(tutar) tutar,
               (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END) as turuncu_hesap,     --16.09.2014 tarihinde eklendi
               case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
                        when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                        when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                        else '5000 TL üstü'
               end as tutar_skala,
               a.hestur,
               m.ana_sube
        FROM   EXTR.FS_hrktdet_sg a, OFSDATA.NORMKADRO_SICIL_TUR f, EXTR.FS_MUSTERI_MASTER m,
               (SELECT DISTINCT musteri_no FROM ofsdata.TURUNCU_HESAP_RPR WHERE rapor_tarihi = v_rapor_tarihi ) th
       WHERE   1 = 1
               AND fistarih  = v_rapor_tarihi
               AND a.fissicil = f.finsicil(+)
               and a.ilk7 = m.musteri_no
               AND a.durum = 0
               AND a.updprogram IN ( 'VRG102', 'VRG112')
               AND a.HESTUR in ('KS','MT')
               AND a.BAKOD = 'B'
               AND a.ilk7 = th.musteri_no(+)
               --AND f.sicil_tur in ('Gise','Operasyon')
     GROUP BY  islsube,
               ilk7,
               case when a.updsicil >49000 THEN 'BATCH'
                      else NVL (f.sicil_tur, 'Diger')
               end,
               a.fissicil,
               calisma_sekli,
               fistarih,
               case when a.tutar<=1000 THEN '1000 ve 1000 TL alti'
                    when a.tutar>1000  and a.tutar<=2000 THEN '1000 ve 2000 TL arasi'
                    when a.tutar>2000  and a.tutar<=5000 THEN '2000 ve 5000 TL arasi'
                    else '5000 TL üstü'
               end,
               (CASE WHEN th.musteri_no is not null THEN 1 ELSE 0 END),
               a.hestur,
               m.ana_sube;

     COMMIT;
   v_line_no := $$PLSQL_LINE;

INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
--Hesaptan Hesaba Yapýlan Havaleler --11. ci iþlem olarak koda yeni eklenen iþlem türü
SELECT
       A.ISLTARIH AS TARIH -- bu iþlemde data iþlem tarihtir.
      ,NULL AS ZAMAN_DILIMI
      ,A.ISLSUBE SUBE
      ,A.karhilk7 AS MUSTERI_NO
      ,M.CALISMA_SEKLI
      ,11 AS ISLEM_ADI -- --11  'Hesaptan Hesaba Yapýlan Havaleler' ,iþlem yeni eklendi.06.01.18
      ,CASE
          WHEN A.ISLSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger')
       END
          AS SICIL_TUR
      ,A.ISLSICIL AS FISSICIL
      ,COUNT(*) ISLEM_ADET
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
      ,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI = v_rapor_tarihi) TH
WHERE
       ISLTARIH =v_rapor_tarihi
       AND A.ISLHILK7 = M.MUSTERI_NO(+)
        AND A.ISLHILK7 = TH.MUSTERI_NO(+)
        AND A.ISLSICIL = C.FINSICIL(+)
        AND A.ISLTARIH = F.TARIH
         AND F.KURTIPI = 1
         AND F.PARA = A.PARA
       AND ISLBAKOD= 'B'
       AND A.DURUM = 1
       AND ISLTUR IN (1, 2)
       AND ISLHESTUR <> 'KS' AND
       KARHHESTUR <> 'KS'
GROUP BY
 A.ISLTARIH
,A.ISLSUBE
,A.karhilk7
,M.CALISMA_SEKLI
,CASE WHEN A.ISLSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
,A.ISLSICIL
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
,A.ISLHESTUR
,M.ANA_SUBE;

COMMIT;
   v_line_no := $$PLSQL_LINE;

--Virman -- 12. ci iþlem olarak koda yeni eklenen iþlem türü
INSERT     /*+ append */ INTO  GISE_ISLEM_DETAY
SELECT
A.FISTARIH AS TARIH
,NULL AS ZAMAN_DILIMI
,A.ISLSUBE SUBE
,A.ILK7 AS MUSTERI_NO
,M.CALISMA_SEKLI
,12 AS ISLEM_ADI -- --19.11.2017 tarihinde eklendi ofsdata.VÝRMAN
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END AS SICIL_TUR
,A.FISSICIL
,COUNT(*) ISLEM_ADET
,SUM( (a.tutar * f.d_alis / f.katsayi)) ISLEM_TUTAR
,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
AS TURUNCU_HESAP
,CASE
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) <= 1000 THEN '1000 ve 1000 TL alti'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 1000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 2000 THEN '1000 ve 2000 TL arasi'
WHEN SUM( (a.tutar * f.d_alis / f.katsayi)) > 2000 AND SUM( (a.tutar * f.d_alis / f.katsayi)) <= 5000 THEN '2000 ve 5000 TL arasi'
ELSE '5000 TL üstü' END AS TUTAR_SKALA
,A.HESTUR AS HESTUR
,M.ANA_SUBE
FROM
EXTR.FS_HRKTDET_SG A
,OFSDATA.NORMKADRO_SICIL_TUR C
,EXTR.FS_MUSTERI_MASTER M
,EXTR.FS_FDOVIZ F
,(SELECT DISTINCT MUSTERI_NO FROM OFSDATA.TURUNCU_HESAP_RPR WHERE RAPOR_TARIHI = v_rapor_tarihi) TH
WHERE
1=1
AND A.FISSICIL = C.FINSICIL(+)
AND M.MUSTERI_NO = A.ILK7
 AND A.ILK7 = TH.MUSTERI_NO(+)
AND A.FISTARIH = F.TARIH
AND A.PARA = F.PARA
AND F.KURTIPI = 1
AND a.fistarih =v_rapor_tarihi
AND a.updprogram IN ('FIS103')
and bakod='B'
and C.sicil_tur in ('Giþe')
GROUP BY
A.FISTARIH
,A.ISLSUBE
,A.ILK7
,M.CALISMA_SEKLI
,CASE WHEN A.FISSICIL > 49000 THEN 'BATCH' ELSE NVL(C.SICIL_TUR, 'Diger') END
 ,A.FISSICIL
 ,(CASE WHEN TH.MUSTERI_NO IS NOT NULL THEN 1 ELSE 0 END)
 ,M.ANA_SUBE
 ,A.HESTUR;


     COMMIT;
   v_line_no := $$PLSQL_LINE;



DELETE FROM   OFSDATA.GISE_ISLEM_DETAY
           WHERE  sube > 899;
     COMMIT;

   v_line_no := $$PLSQL_LINE;


     DELETE FROM OFSDATA.GISE_ZINCIR_ISLEMLERI
           WHERE tarih = v_rapor_tarihi;
     COMMIT;

     INSERT     /*+ append */ INTO OFSDATA.GISE_ZINCIR_ISLEMLERI
     SELECT pt.tarih,pt.zaman_dilimi,pt.sube,pt.musteri_no,pt.calisma_sekli,
            dim.islem_adi,                          --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM
            pt.sicil_tur,pt.finsicil,adet,tutar
       FROM OFSDATA.GISE_ISLEM_DETAY pt,
            ofsdata.GISE_ISLEM_DETAY_DIM dim,      --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM
            (  SELECT tarih,zaman_dilimi,sube,musteri_no,calisma_sekli,sicil_tur,finsicil, COUNT(*)
                 FROM OFSDATA.GISE_ISLEM_DETAY
                WHERE tarih = v_rapor_tarihi
             GROUP BY tarih,zaman_dilimi,sube,musteri_no,calisma_sekli,sicil_tur,finsicil
             HAVING COUNT(*) >1
            ) kd
      WHERE pt.tarih = kd.tarih and PT.ZAMAN_DILIMI = kd.zaman_dilimi and pt.sube= kd.sube and pt.musteri_no = kd.musteri_no
        AND pt.calisma_sekli = kd.calisma_sekli and pt.finsicil = kd.finsicil and pt.sicil_tur = kd.sicil_tur
        AND pt.islem_adi = dim.id_islem             --16.09.2014 tarihinde eklendi ofsdata.GISE_ISLEM_DETAY_DIM
        AND pt.tarih = v_rapor_tarihi;
      COMMIT;

   v_line_no := $$PLSQL_LINE;

     ETL.PKG_UTIL_LIB.prc_log_end;


EXCEPTION
   WHEN OTHERS
   THEN
      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

      --FAILURE LOG
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;

END;
/