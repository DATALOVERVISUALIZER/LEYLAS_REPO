--Step 0:   9-2 yoksa 9-1 olacak --- 0-Firm Hard Reject  GROUP_SHAREHOLDER'  'START'(LOG9 )-'GROUP_PROPOSAL'  (LOG1) or 'CUST_PROPOSAL START' ('LOG2)
--Step 1:    proposal info start (15) – group_shareholder start ( 9)    --- 1-Grup ve Taraf Bilgileri   LOG15  'LOG9'
--Step 2:  fin data start (log18) - proposal info start(log15)    ------- 2-Teklif Bilgileri   LOG18  'LOG15'
--Step 3: fin data end (LOG19)- Fin data start  (LOG18)   ---3- Mali Veri Yükleme -LOG19-18
--Step 4: question end - questins start    -- 4-Sektör ve Finansal Olmayan Bilgiler
--Step 5: limit end -  limit start  5- Limit Teklifi

--rapora teklif id ve teklif numarasý da eklenecek.
--log19 null geliyor step3 ve mali veri adýmý bu durumdan etkileniyor. Yiðit'e sordum.

drop table LEYLAY.TEMP_LOG_CAT;

--TRFM.TEMP_LOG_CAT

select * from  LEYLAY.TEMP_LOG_CAT where  cust_no=9089060 order by UPD_TARIH asc

create table  LEYLAY.TEMP_LOG_CAT as
SELECT 
main.watch_id
,main.activity_name
--,main.REFERENCE_TYPE --bir müþteri için 2 referans gelýyor
,main.PROCESS_TYPE 
,main.STATUS watch_status
,main.UPD_TARIH as OLEDATE 
,main.LOG
,main.step_no
,main.STEP_ACIKLAMA
,main.cust_no
,mm.MUS_RP_ADI as cust_name
,CASE
WHEN MM.CALISMA_SEKLI = 1 THEN 'BÝREYSEL' 
WHEN MM.CALISMA_SEKLI = 2 THEN 'TÝCARÝ'
WHEN MM.CALISMA_SEKLI = 3  THEN 'KURUMSAL'
WHEN MM.CALISMA_SEKLI = 4  THEN 'KOBÝ'
WHEN MM.CALISMA_SEKLI = 5 THEN 'MÝKRO'
ELSE 'OTHER'
END  AS cust_segment
,SUBE.BOLGE_KOD AS RGN_CODE
,SUBE.BOLGE_AD AS RGN_NAME
,SUBE.SUBE_KOD AS BRANCH_CODE
,SUBE.SUBE_AD AS BRANCH_NAME
,SUBE.AKTF_F  BRANCH_STATUS
,IL.ACIKLAMA AS BRANCH_PROVINCE
,MG.GRUP  as GRP_CODE
,GR.ACIKLAMA as  GRP_NAME
,MG.grup_tipi as GRP_TYPE
,GR.DURUM as GRP_STATUS
,main.UPDSICIL as UPD_PRSN_NO
,U.ISIM || ' ' || U.SOYAD UPD_PRSN_NAME
,U.UNVAN AS UPD_PRSN_NO_TITLE
,G.ACIKLAMA UPD_PRSN_NO_TITLE_EXP
,main.UPD_PROGRAM
,main.UPD_CHANNEL
,  TEKLIF.TEKLIF_ID AS PROP_ID
,TEKLIF.TEKLIF_NUMARASI as PROP_NMBR
,TEKLIF.PUAN as PROP_GRADE
,TEKLIF.BOLUM_NO as PROP_DPRTMNT_NO
,TEKLIF.SERVIS_ID as PROP_SERVIS_ID
,TEKLIF.SCORECARD_SW 
,TEKLIF.TEKLIF_SONUCU as PROP_RESULT
,TEKLIF.teklif_durum_kodu as PROP_STATU_CODE
,TEKLIF.DURUM  as PROP_STATU_CODE_EXP
,TEKLIF.TEKLIF_BAS_TAR as  PROP_START_DATE
,TEKLIF.TEKLIF_BIT_TAR as PROP_FIN_DATE
,TEKLIF.OLE_FLAG as PROP_OLE_FLAG
,TEKLIF.KAYNAK as PROP_SOURCE
from
(SELECT
watch_id
,cust_no 
,UPDSICIL
,process_type
,activity_name
 ,UPD_PROGRAM
,UPD_CHANNEL
,UPD_TARIH
,LOG
,STATUS
,step_no
--,REFERENCE_TYPE
,CASE WHEN step_no='STEP0'  THEN 'FIRM_HARDREJECT'
 WHEN step_no='STEP1'  THEN 'GRUP_VE_TARAF_BILGILERI'
 WHEN step_no='STEP2'  THEN 'TEKLIF_BILGILERI'
  WHEN step_no='STEP3'  THEN 'MALI_VERI_YÜKLEME'
    WHEN step_no='STEP4'  THEN 'SEKTÖR_VE_FINANSAL_OLMAYAN_BILGILER'
        WHEN step_no='STEP5'  THEN 'LIMIT_TEKLIFI' ELSE  'OTHER' END AS STEP_ACIKLAMA
 FROM
 (
select 
distinct 
w.watch_id
--,w.REFERENCE_TYPE
,w.STATUS
,w.reference as cust_no
,w.process_type
 ,l.activity_name
 , l.step_name
 , l.step_Detail
 ,l.UPD_TARIH
 ,w.UPDSICIL as 
 ,l.UPD_PROGRAM
,l.UPD_CHANNEL
  , CASE WHEN   w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='GROUP_PROPOSAL' AND  l.step_Detail = 'START'  then 'LOG1' 
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='CUST_PROPOSAL' AND  l.step_Detail = 'START'  then 'LOG2'  --müþteri numarasý yazýlýrsa
 WHEN  w.process_type='OLE'  and l.activity_name = 'HARD_REJECT'   and  l.step_name='DATA_GATHERING' AND  l.step_Detail = 'START'  then 'LOG3'  --log3,4,5,6,7 adýmlarý müþteri bilgileri toplanmadan once otomatik kkb gibi kurumlarda yapýlan sorgular sonrasý oto_ret
WHEN  w.process_type='OLE'  and l.activity_name = 'HARD_REJECT'   and  l.step_name='DATA_GATHERING' AND  l.step_Detail = 'KKKB_START'  then 'LOG4' 
WHEN  w.process_type='OLE'  and l.activity_name = 'HARD_REJECT'   and  l.step_name='DATA_GATHERING' AND  l.step_Detail = 'KKKB_END'  then 'LOG5'
WHEN  w.process_type='OLE'  and l.activity_name = 'HARD_REJECT'   and  l.step_name='DATA_GATHERING' AND  l.step_Detail = 'END'  then 'LOG6'
 WHEN  w.process_type='OLE'  and l.activity_name = 'HARD_REJECT'   and  l.step_name='EXEC_GDS' AND  l.step_Detail = 'END'  then 'LOG7'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='CUST_HR' AND  l.step_Detail = 'END'  then 'LOG8'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='GROUP_SHAREHOLDER' AND  l.step_Detail = 'START'  then 'LOG9'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='GROUP_QUERY' AND  l.step_Detail = 'START'  then 'LOG10'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='GROUP_QUERY' AND  l.step_Detail = 'END'  then 'LOG11'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='GROUP_CUST_LIST' AND  l.step_Detail = 'START'  then 'LOG12'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='CUST_MERSIS' AND  l.step_Detail = 'START'  then 'LOG13A'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='CUST_MERSIS' AND  l.step_Detail = 'END'  then 'LOG13B'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='GROUP_CUST_LIST' AND  l.step_Detail = 'END'  then 'LOG14'
WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='PROPOSAL_INFO' AND  l.step_Detail = 'START'  then 'LOG15'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='START_PROP' AND  l.step_Detail = 'START'  then 'LOG16'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='START_PROP' AND  l.step_Detail = 'END'  then 'LOG17'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='FIN_DATA' AND  l.step_Detail = 'START'  then 'LOG18'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='FIN_DATA' AND  l.step_Detail = 'END'  then 'LOG19'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='QUESTIONS' AND  l.step_Detail = 'START'  then 'LOG20'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='QUESTIONS' AND  l.step_Detail = 'END'  then 'LOG21'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='LIMIT_ALLOC' AND  l.step_Detail = 'START'  then 'LOG22'
 WHEN  w.process_type='OLE'  and l.activity_name = 'LENDING'   and  l.step_name='LIMIT_ALLOC' AND  l.step_Detail = 'END'  then 'LOG23'
 ELSE 'OTHER' --other ile gelen kayýtlat KKB ayrýntýlarý zaman hesaplamarýnda datayý deiþtirmez
 END AS LOG
,  CASE WHEN  process_type='OLE'  and( activity_name = 'LENDING' or  activity_name = 'HARD_REJECT' )    and  step_name IN ('GROUP_PROPOSAL','CUST_PROPOSAL','DATA_GATHERING','EXEC_GDS','CUST_HR' )   
 THEN 'STEP0'  ---Step 0:Firm Hard Reject : GROUP_SHAREHOLDER'  'START'(LOG9 )-'GROUP_PROPOSAL'  (LOG1) or 'CUST_PROPOSAL START' ('LOG2) --CASE WHEN LOG IN ('LOG1','LOG2','LOG3','LOG4','LOG5','LOG6','LOG7','LOG8','LOG9') 
 WHEN  activity_name = 'LENDING' and step_name IN ('GROUP_CUST_LIST','CUST_MERSIS' ,'GROUP_QUERY','GROUP_SHAREHOLDER')  THEN 'STEP1' -- Step 1: proposal info start (15)_GRUP_VE_TARAF_BILGILERI – group_shareholder start ( 9)    WHEN LOG IN ('LOG15','LOG9',LOG10,LOG11,LOG12,LOG13A,LOG13B,LOG14)
 WHEN  activity_name = 'LENDING' and step_name IN ('PROPOSAL_INFO','START_PROP','START_PROPOSAL') THEN 'STEP2'  --Step 2:Teklif Bilgileri   fin data start (log18) roposal info start(log15) ('LOG18','LOG15',LOG16,LOG17)
WHEN  activity_name = 'LENDING'   and  step_name='FIN_DATA'  THEN 'STEP3' --Step 3:Mali Veri Yükleme - fin data end (LOG19)- Fin data start  (LOG18) LOG IN ('LOG19','LOG18') 
WHEN   activity_name = 'LENDING'   and  step_name='QUESTIONS' THEN 'STEP4' --Step 4:SEKTÖR_VE_FINANSAL_OLMAYAN_BILGILER - question end (LOG21)- questins start (LOG20)  LOG IN ('LOG21','LOG20') 
WHEN   activity_name = 'LENDING'   and  step_name='LIMIT_ALLOC'   THEN 'STEP5' --STEP5_LIMIT_TEKLIFI: limit end(LOG23) -  limit start(LOG22) LOG IN ('LOG23','LOG22') 
END AS STEP_no
  FROM
       EXTR.FS_PROCESS_WATCH W
       INNER JOIN EXTR.FS_PROCESS_LOG L ON TO_CHAR(W.WATCH_ID) = L.REFERENCE
               WHERE 
               1=1
--                  W.REFERENCE=11551058
and  w.process_type = 'OLE'
  --  and w.watch_id=10733   -- tum step'lere giren watch_id
   )  )main
   LEFT JOIN EXTR.FS_MUSTERI_MASTER MM ON MM.MUSTERI_NO = main.cust_no
 LEFT JOIN (SELECT
         TM.TEKLIF_ID
       ,TM.TEKLIF_NUMARASI
       ,TM.PUAN 
      ,TM.BOLUM_NO
      ,Tm.SERVIS_ID
      ,TM.SCORECARD_SW
      ,TM.TEKLIF_SONUCU
       , MM.ANA_SUBE 
      ,TM.MUSTERI
      ,TM.DURUM teklif_durum_kodu
      ,DECODE(TM.DURUM,  0, 'Devam Ediyor',  1, 'Onaylý',  9, 'Ýptal/Red') DURUM
      ,TM.TARIH TEKLIF_BAS_TAR
      ,I.TARIH TEKLIF_BIT_TAR
      ,NVL(P.VAL, 0) OLE_FLAG
      ,CASE WHEN P.VAL = 1 THEN 'OLE' ELSE 'FINSOFT' END AS KAYNAK
FROM
       EXTR.FS_TEKLIF_MASTER TM
      ,EXTR.FS_MUSTERI_MASTER MM
      ,EXTR.FS_WF_IS I
      ,EXTR.FS_WF_IS_PRM P
   WHERE
       MM.MUSTERI_NO = TM.MUSTERI 
          AND I.REFERANS = TO_CHAR(TM.TEKLIF_ID)
              AND P.ISNO(+) = I.ISNO
                AND P.KEY(+) = 'OLE'
       AND  TM.TARIH >=TO_DATE('2017/08/05', 'YYYY/MM/DD')
   --  AND TRUNC(TM.TARIH) =to_date('06.11.2017','dd.mm.yyyy')-- baþlangýc logu ile teklifin baþlaðý tarih joinlenir.
       AND  MM.ANA_SUBE IN (199,    398,    249,    475,    657,    183,    195,    184,    196,    147,    265,    718,    366,    227,    395,    451,    433,    230,    191,    442,    198,    676,    472,    178,    779,    107,    186,    780,    680,    202,    223,    158,    266,    260,    212,    176,    434,    161,    724,    431,    219,    721,    373,    225,    221,    142,    439,    667,    455,    139,    143,    410,    335
) 
     ) TEKLIF  On TEKLIF.MUSTERI=MM.MUSTERI_NO
      AND TEKLIF.ANA_SUBE=MM.ANA_SUBE 
     AND TRUNC(TEKLIF.TEKLIF_BAS_TAR)=TRUNC(main.upd_tarih)-- baþlangýc logu ile teklifin baþlaðý tarih joinlenir.
       LEFT JOIN EXTR.FS_USERID_VIEW U ON U.SICIL = main.UPDSICIL
       LEFT JOIN EXTR.FS_GOREV G ON G.GOREV = U.GOREV
       LEFT JOIN EXTR.FS_SUBE SB ON SB.SUBE = U.CALISSUBE
      LEFT JOIN EXTR.FS_IL IL ON IL.IL = SB.ILKODU
       LEFT JOIN EXTR.FS_MUSTERI_GRUP MG ON MG.MUSTERI_NO = main.cust_no -- bir müþterinin birden fazla grubu olabilir bu nedenle FOCUSTa musterinin grubunun aktif pasif oldugu flag'i mutlaka eklenmeli.
       LEFT JOIN EXTR.FS_GRUP GR ON GR.GRUP = MG.GRUP
         LEFT JOIN 
                (SELECT
                        SUBE_KOD
                       ,BOLGE_KOD
                       ,BOLGE_AD
                       ,SUBE_AD
                       ,KST_TRH
                       ,UPD_TRH
                       ,AKTF_F
                 FROM
                        DM_MIS.DIM_MIS_BOLGE
                 WHERE
                        KST_TRH =(SELECT MAX(KST_TRH) FROM DM_MIS.DIM_MIS_BOLGE))SUBE ON SUBE.SUBE_KOD = MM.ANA_SUBE
                        WHERE TRUNC(main.UPD_TARIH)=trunc(sysdate-1) 
                        
                 --       AND (SUBE.BOLGE_AD <>'Serbest Bölge' OR SUBE.BOLGE_AD LIKE '%Ticari%') AND (SUBE.BOLGE_AD LIKE '%Bölge%' OR SUBE.BOLGE_AD LIKE '%Ticari%') --yarýn sor

  -- SUBE.BOLGE_AD <>'Serbest Bölge'  bu kýsýtlamayý FOCUS'ta verceðiz
           
  
  drop table LEYLAY.TEMP_time_spend_second;
  
   select * from LEYLAY.TEMP_time_spend_second  where cust_segment = '1' 

--PRSN.TIME_SPEND_SECOND  

create table  LEYLAY.TEMP_time_spend_second as 
SELECT
       MAIN.OLEDATE
      , MAIN.WATCH_ID
      ,MAIN.CUST_NO
     -- ,MAIN.REFERENCE_TYPE
      ,MAIN.PROCESS_TYPE
      ,MAIN.WATCH_STATUS
      ,MAIN.CUST_NAME AS CUST_NAME
      ,MAIN.cust_segment
      ,MAIN.RGN_CODE AS RGN_CODE
      ,MAIN.RGN_NAME AS RGN_NAME
      ,MAIN.BRANCH_CODE AS BRANCH_CODE
      ,MAIN.BRANCH_NAME AS BRANCH_NAME
      ,MAIN.BRANCH_STATUS AS BRANCH_STATUS
      ,MAIN.BRANCH_PROVINCE AS BRANCH_PROVINCE
      ,MAIN.GRP_CODE AS GRP_CODE
      ,MAIN.GRP_NAME AS GRP_NAME
      ,MAIN.GRP_TYPE AS GRP_TYPE
      ,MAIN.GRP_STATUS AS GRP_STATUS
      ,MAIN.PROP_ID AS PROP_ID
      ,MAIN.PROP_NMBR AS PROP_NMBR
      ,MAIN.PROP_GRADE AS PROP_GRADE
      ,MAIN.PROP_DPRTMNT_NO AS PROP_DPRTMNT_NO
      ,MAIN.PROP_SERVIS_ID AS PROP_SERVIS_ID
      ,MAIN.SCORECARD_SW AS PROP_SCORECARD_SW
      ,MAIN.PROP_RESULT AS PROP_RESULT
      ,MAIN.PROP_STATU_CODE PROP_STATU_CODE
      ,MAIN.PROP_STATU_CODE_EXP  as PROP_STATU_CODE_EXP
        ,MAIN.PROP_START_DATE AS PROP_START_DATE
      ,MAIN.PROP_FIN_DATE AS PROP_FINISH_DATE
      ,MAIN.PROP_OLE_FLAG
      ,MAIN.PROP_SOURCE AS PROP_SOURCE
      ,MAIN.UPD_PRSN_NO as UPD_PRSN_NO
      ,MAIN.UPD_PRSN_NAME AS UPD_PRSN_NAME
      ,MAIN.UPD_PRSN_NO_TITLE 
      ,MAIN.UPD_PRSN_NO_TITLE_EXP
      ,MAIN.FRM_HRD_RJCT_SPND_SCND
      ,MAIN.DT_GTHRNG_SPND_SCND --Data_Toplama
      ,MAIN.GDS_SPND_SCND --GDS_Adimi
      ,MAIN.GRP_SHRHLDR_DATA_SPND_SCND -- Grup_ve_Taraf_Bilgileri_Second,
      ,MAIN.GROUP_QUERY_SPND_SCND --grup sorgulama,
      ,MAIN.MERSIS_QUERY_SPND_SCND --grup sorgulama
      ,MAIN.GRP_SUM_HRD_RJCT_SPND_SCND, --Grup_Toplam_Hard_Reject,
       MAIN.GRP_GDS_SPND_SCND --GRup GDS adýmý
      ,MAIN.SCRN_IDLE_SPND_SCND --ekran_idle_time
      ,MAIN.FIN_DATA_SPND_SCND --financial data,Mali_Veri
      ,MAIN.NON_FINANCIAL_QUES_SPND_SCND
      ,MAIN.LIMIT_ALLCTION_SPND_SCND --Limit_Allocation
      ,MAIN.PRPSL_DATA_SPND_SCND --teklif_bilgileri
      ,MAIN.STEP0_SPND_SCND
      ,MAIN.STEP1_SPND_SCND
      ,MAIN.STEP2_SPND_SCND
      ,MAIN.STEP3_SPND_SCND
      ,MAIN.STEP4_SPND_SCND
      ,MAIN.STEP5_SPND_SCND
      ,MAIN.LOG1_UPD_TARIH
      ,MAIN.LOG2_UPD_TARIH
      ,MAIN.LOG3_UPD_TARIH
      ,MAIN.LOG4_UPD_TARIH
      ,MAIN.LOG5_UPD_TARIH
      ,MAIN.LOG6_UPD_TARIH
      ,MAIN.LOG7_UPD_TARIH
      ,MAIN.LOG8_UPD_TARIH
      ,MAIN.LOG9_UPD_TARIH
      ,MAIN.LOG10_UPD_TARIH
      ,MAIN.LOG11_UPD_TARIH
      ,MAIN.LOG12_UPD_TARIH
      ,MAIN.LOG13A_UPD_TARIH
      ,MAIN.LOG13B_UPD_TARIH
      ,MAIN.LOG14_UPD_TARIH
      ,MAIN.LOG15_UPD_TARIH
      ,MAIN.LOG16_UPD_TARIH
      ,MAIN.LOG17_UPD_TARIH
      ,MAIN.LOG18_UPD_TARIH
      ,MAIN.LOG19_UPD_TARIH
      ,MAIN.LOG20_UPD_TARIH
      ,MAIN.LOG21_UPD_TARIH
      ,MAIN.LOG22_UPD_TARIH
      ,MAIN.LOG23_UPD_TARIH
      ,MAIN.PRPSL_STATUS
          FROM
       (SELECT
             UPD_TARIH_2 OLEDATE
               ,WATCH_ID
              ,CUST_NO
             -- ,REFERENCE_TYPE
              ,PROCESS_TYPE
              ,WATCH_STATUS
              ,CUST_NAME
              ,cust_segment
              ,RGN_CODE
              ,RGN_NAME
              ,BRANCH_CODE
              ,BRANCH_NAME
              ,BRANCH_STATUS
              ,BRANCH_PROVINCE
              ,GRP_CODE
              ,GRP_NAME
             ,GRP_TYPE
               ,GRP_STATUS
              ,UPD_PRSN_NO
              ,UPD_PRSN_NAME
              ,UPD_PRSN_NO_TITLE
              ,UPD_PRSN_NO_TITLE_EXP
              ,PROP_ID
              ,PROP_NMBR
              ,PROP_GRADE
              ,PROP_DPRTMNT_NO
              ,PROP_SERVIS_ID
              ,SCORECARD_SW
              ,PROP_RESULT
              ,PROP_STATU_CODE
                ,PROP_STATU_CODE_EXP
              ,PROP_START_DATE
              ,PROP_FIN_DATE
              ,PROP_OLE_FLAG
              ,PROP_SOURCE
              ,LOG1_UPD_TARIH
              ,LOG2_UPD_TARIH
              ,LOG3_UPD_TARIH
              ,LOG4_UPD_TARIH
              ,LOG5_UPD_TARIH
              ,LOG6_UPD_TARIH
              ,LOG7_UPD_TARIH
              ,LOG8_UPD_TARIH
              ,LOG9_UPD_TARIH
              ,LOG10_UPD_TARIH
              ,LOG11_UPD_TARIH
              ,LOG12_UPD_TARIH
              ,LOG13A_UPD_TARIH
              ,LOG13B_UPD_TARIH
              ,LOG14_UPD_TARIH
              ,LOG15_UPD_TARIH
              ,LOG16_UPD_TARIH
              ,LOG17_UPD_TARIH
              ,LOG18_UPD_TARIH
              ,LOG19_UPD_TARIH
              ,LOG20_UPD_TARIH
              ,LOG21_UPD_TARIH
              ,LOG22_UPD_TARIH
              ,LOG23_UPD_TARIH
              ,(LOG8_UPD_TARIH - LOG2_UPD_TARIH) * 60 * 60 * 24 AS FRM_HRD_RJCT_SPND_SCND
              ,(LOG6_UPD_TARIH - LOG3_UPD_TARIH) * 60 * 60 * 24 AS DT_GTHRNG_SPND_SCND --Data_Toplama
              ,(LOG7_UPD_TARIH - LOG6_UPD_TARIH) * 60 * 60 * 24 AS GDS_SPND_SCND --GDS_Adimi
              ,(LOG15_UPD_TARIH - LOG10_UPD_TARIH) * 60 * 60 * 24 AS GRP_SHRHLDR_DATA_SPND_SCND -- Grup_ve_Taraf_Bilgileri_Second,
              ,(LOG11_UPD_TARIH - LOG10_UPD_TARIH) * 60 * 60 * 24 AS GROUP_QUERY_SPND_SCND --grup sorgulama,
              ,(LOG14_UPD_TARIH - LOG12_UPD_TARIH) * 60 * 60 * 24 AS MERSIS_QUERY_SPND_SCND --grup sorgulama
                ,(LOG7_UPD_TARIH - LOG3_UPD_TARIH) * 60 * 60 * 24 AS GRP_SUM_HRD_RJCT_SPND_SCND , --Grup_Toplam_Hard_Reject,
               (LOG7_UPD_TARIH - LOG6_UPD_TARIH) * 60 * 60 * 24 AS GRP_GDS_SPND_SCND --GRup GDS adýmý
              ,((LOG15_UPD_TARIH - LOG10_UPD_TARIH) * 60 * 60 * 24) - ((LOG11_UPD_TARIH - LOG10_UPD_TARIH) * 60 * 60 * 24) - ((LOG14_UPD_TARIH - LOG12_UPD_TARIH) * 60 * 60 * 24) SCRN_IDLE_SPND_SCND --ekran_idle_time
              ,(LOG19_UPD_TARIH - LOG18_UPD_TARIH) * 60 * 60 * 24 AS FIN_DATA_SPND_SCND --financial data,Mali_Veri 
              ,(LOG21_UPD_TARIH - LOG20_UPD_TARIH) * 60 * 60 * 24 AS NON_FINANCIAL_QUES_SPND_SCND
              ,(LOG23_UPD_TARIH - LOG22_UPD_TARIH) * 60 * 60 * 24 AS LIMIT_ALLCTION_SPND_SCND --Limit_Allocation
              ,(LOG18_UPD_TARIH - LOG15_UPD_TARIH) * 60 * 60 * 24 AS PRPSL_DATA_SPND_SCND --teklif_bilgileri
              ,((LOG9_UPD_TARIH) - (NVL(LOG1_UPD_TARIH, LOG2_UPD_TARIH))) * 60 * 60 * 24 AS STEP0_SPND_SCND
              ,(LOG15_UPD_TARIH - LOG9_UPD_TARIH) * 60 * 60 * 24 AS STEP1_SPND_SCND
               ,(LOG18_UPD_TARIH - LOG15_UPD_TARIH) * 60 * 60 * 24 AS STEP2_SPND_SCND
              ,(LOG19_UPD_TARIH - LOG18_UPD_TARIH) * 60 * 60 * 24 AS STEP3_SPND_SCND
              ,(LOG21_UPD_TARIH - LOG20_UPD_TARIH) * 60 * 60 * 24 AS STEP4_SPND_SCND
              ,(LOG23_UPD_TARIH - LOG22_UPD_TARIH) * 60 * 60 * 24 AS STEP5_SPND_SCND
            ,CASE WHEN LOG23_UPD_TARIH IS NULL THEN 'SONLANMAMIS' ELSE 'SONLANMIS' END AS PRPSL_STATUS --TEKLIF_DURUMU
                                   FROM
(
select 
*
 from 
(
SELECT
       DISTINCT CAT.WATCH_ID
               ,CAT.LOG
               ,CUST_NO
           -- ,CAT.REFERENCE_TYPE
               ,CAT.PROCESS_TYPE
               ,CAT.WATCH_STATUS
               ,CAT.OLEDATE
               ,TRUNC(CAT.OLEDATE) as UPD_TARIH_2
            ,CAT.CUST_NAME
               ,CAT.cust_segment
               ,CAT.RGN_CODE
               ,CAT.RGN_NAME
               ,CAT.BRANCH_CODE
               ,CAT.BRANCH_NAME
               ,CAT.BRANCH_STATUS
               ,CAT.BRANCH_PROVINCE
               ,CAT.GRP_CODE
               ,CAT.GRP_NAME
               ,CAT.GRP_TYPE
               ,CAT.GRP_STATUS as GRP_STATUS
               ,CAT.UPD_PRSN_NO
               ,CAT.UPD_PRSN_NAME
               ,CAT.UPD_PRSN_NO_TITLE
               ,CAT.UPD_PRSN_NO_TITLE_EXP
               ,CAT.PROP_ID
               ,CAT.PROP_NMBR
               ,CAT.PROP_GRADE
               ,CAT.PROP_DPRTMNT_NO
               ,CAT.PROP_SERVIS_ID
               ,CAT.SCORECARD_SW
               ,CAT.PROP_RESULT
                ,CAT.PROP_STATU_CODE
                ,CAT.PROP_STATU_CODE_EXP
               ,CAT.PROP_START_DATE
               ,CAT.PROP_FIN_DATE
               ,CAT.PROP_OLE_FLAG
               ,CAT.PROP_SOURCE
            FROM
      LEYLAY.TEMP_LOG_CAT  CAT
                WHERE
                1=1
                and CAT.cust_segment<>'OTHER'
       --  and cat.watch_id=10733  
        )
         PIVOT  ( 
         MAX(OLEDATE) AS UPD_TARIH  
         FOR ( LOG)
                                       IN  ('LOG1' AS log1,
                                       'LOG2' AS log2,
                                       'LOG3' AS log3,
                                       'LOG4' AS log4,
                                       'LOG5' AS log5,
                                       'LOG6' AS log6,
                                       'LOG7' AS log7,
                                       'LOG8' AS log8,
                                       'LOG9' AS log9,
                                       'LOG10' AS log10,
                                       'LOG11' AS log11,
                                       'LOG12' AS log12,
                                       'LOG13A' AS log13a,
                                       'LOG13B' AS log13b,
                                       'LOG14' AS log14,
                                       'LOG15' AS log15,
                                       'LOG16' AS log16,
                                       'LOG17' AS log17,
                                       'LOG18' AS log18,
                                       'LOG19' AS log19,
                                       'LOG20' AS log20,
                                       'LOG21' AS log21,
                                       'LOG22' AS log22,
                                       'LOG23' AS log23
                  ))p
                  ) )main
                  WHERE 
                  1=1
                 AND  TRUNC( MAIN.OLEDATE)=TRUNC(SYSDATE-1)



select * from  LEYLAY.TEMP_LOG_CAT CAT 

--stepler
--toplam zaman(stepler toplamý)
--sum(stepler)/count()
-- musteri basýna gecen zAMAN (DÝSTÝNCT MUSTERÝ)
--TEKLÝF NUMARASI BASINA GECEN ZAMAN(TOPLAM/DÝSTÝNCT TEKLÝF)
 


--PRSN.TIME_SPEND_SECOND_SUMMARY 

create table LEYLAY.TIME_SPEND_SECOND_SUMMARY as 
--BANKA GENEL
select 
'BANKA' as category
 ,OLEDATE
,1 as cust_segment
  ,1 AS RGN_CODE
 , 1 AS RGN_NAME
 ,1 AS BRANCH_NAME
 ,1AS BRANCH_CODE
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,NVL((SUM_SPND_SCND)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST
,NVL(NVL(SUM_SPND_SCND,0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_mus_count,0),0)   SUM_SPND_SCND_PERCUST_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP5
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_prop_count,0),0)   SUM_SPND_SCND_PERPROP_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP5
from 
(
 select 
  OLEDATE 
 ,count(distinct cust_no) sum_mus_count--toplam musteri sayýsý   
  ,count(distinct PROP_NMBR) as sum_prop_count --toplam teklif adedi
  ,sum(nvl(STEP0_SPND_SCND,0)) as  SUM_STEP0_SPND_SCND
  ,sum(nvl(STEP1_SPND_SCND,0))  as SUM_STEP1_SPND_SCND
  ,sum(nvl(STEP2_SPND_SCND,0)) aS SUM_STEP2_SPND_SCND
 , sum(nvl(STEP3_SPND_SCND,0)) AS SUM_STEP3_SPND_SCND
 , sum(NVL(STEP4_SPND_SCND,0)) AS SUM_STEP4_SPND_SCND
 , sum(NVL(STEP5_SPND_SCND,0)) AS SUM_STEP5_SPND_SCND
,(sum(nvl(STEP0_SPND_SCND,0))+sum(nvl(STEP1_SPND_SCND,0))+sum(nvl(STEP2_SPND_SCND,0))+sum(nvl(STEP3_SPND_SCND,0))+sum(NVL(STEP4_SPND_SCND,0))+sum(NVL(STEP5_SPND_SCND,0))) AS SUM_SPND_SCND
        from 
 LEYLAY.TEMP_time_spend_second  
    where trunc(OLEDATE)=trunc(sysdate-1)
  group by 
 OLEDATE
 )a
 GROUP BY 
OLEDATE
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND

UNION ALL 
  --SEGMENT GENEL
select 
'SEGMENT' as category
 ,OLEDATE
,cust_segment
,NULL AS RGN_CODE
 , NULL AS RGN_NAME
  ,NULL AS BRANCH_NAME
 ,NULL AS BRANCH_CODE
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,NVL((SUM_SPND_SCND)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST
,NVL(NVL(SUM_SPND_SCND,0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_mus_count,0),0)   SUM_SPND_SCND_PERCUST_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP5
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_prop_count,0),0)   SUM_SPND_SCND_PERPROP_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP5
from 
(
 select 
  cust_segment
 ,OLEDATE 
 ,count(distinct cust_no) sum_mus_count--toplam musteri sayýsý   
  ,count(distinct PROP_NMBR) as sum_prop_count --toplam teklif adedi
  ,sum(nvl(STEP0_SPND_SCND,0)) as  SUM_STEP0_SPND_SCND
  ,sum(nvl(STEP1_SPND_SCND,0))  as SUM_STEP1_SPND_SCND
  ,sum(nvl(STEP2_SPND_SCND,0)) aS SUM_STEP2_SPND_SCND
 , sum(nvl(STEP3_SPND_SCND,0)) AS SUM_STEP3_SPND_SCND
 , sum(NVL(STEP4_SPND_SCND,0)) AS SUM_STEP4_SPND_SCND
 , sum(NVL(STEP5_SPND_SCND,0)) AS SUM_STEP5_SPND_SCND
,(sum(nvl(STEP0_SPND_SCND,0))+sum(nvl(STEP1_SPND_SCND,0))+sum(nvl(STEP2_SPND_SCND,0))+sum(nvl(STEP3_SPND_SCND,0))+sum(NVL(STEP4_SPND_SCND,0))+sum(NVL(STEP5_SPND_SCND,0))) AS SUM_SPND_SCND
        from 
  PRSN.TIME_SPEND_SECOND  
    where trunc(OLEDATE)=trunc(sysdate-1)
  group by 
 cust_segment
 ,OLEDATE
 )a
 GROUP BY 
 cust_segment
 ,OLEDATE
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND
UNION ALL 
--BOLGE GENEL
select 
'BOLGE' as category
 ,OLEDATE
,NULL AS cust_segment
 ,RGN_CODE
 ,RGN_NAME
 ,NULL AS BRANCH_NAME
 ,NULL AS BRANCH_CODE 
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,NVL((SUM_SPND_SCND)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST
,NVL(NVL(SUM_SPND_SCND,0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_mus_count,0),0)   SUM_SPND_SCND_PERCUST_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP5
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_prop_count,0),0)   SUM_SPND_SCND_PERPROP_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP5
from 
(
 select 
 OLEDATE 
 ,RGN_CODE
 ,RGN_NAME
 ,count(distinct cust_no) sum_mus_count--toplam musteri sayýsý   
  ,count(distinct PROP_NMBR) as sum_prop_count --toplam teklif adedi
  ,sum(nvl(STEP0_SPND_SCND,0)) as  SUM_STEP0_SPND_SCND
  ,sum(nvl(STEP1_SPND_SCND,0))  as SUM_STEP1_SPND_SCND
  ,sum(nvl(STEP2_SPND_SCND,0)) aS SUM_STEP2_SPND_SCND
 , sum(nvl(STEP3_SPND_SCND,0)) AS SUM_STEP3_SPND_SCND
 , sum(NVL(STEP4_SPND_SCND,0)) AS SUM_STEP4_SPND_SCND
 , sum(NVL(STEP5_SPND_SCND,0)) AS SUM_STEP5_SPND_SCND
,(sum(nvl(STEP0_SPND_SCND,0))+sum(nvl(STEP1_SPND_SCND,0))+sum(nvl(STEP2_SPND_SCND,0))+sum(nvl(STEP3_SPND_SCND,0))+sum(NVL(STEP4_SPND_SCND,0))+sum(NVL(STEP5_SPND_SCND,0))) AS SUM_SPND_SCND
        from 
PRSN.TIME_SPEND_SECOND  
    where trunc(OLEDATE)=trunc(sysdate-1)
  group by 
OLEDATE
  ,RGN_CODE
 ,RGN_NAME
 )a
 GROUP BY 
OLEDATE
  ,RGN_CODE
 ,RGN_NAME
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND
UNION ALL 
--SUBE GENEL
select 
'SUBE' as category
 ,OLEDATE
,NULL AS cust_segment
 ,RGN_CODE
 ,RGN_NAME
  ,BRANCH_NAME
 , BRANCH_CODE
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,NVL((SUM_SPND_SCND)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST
,NVL(NVL(SUM_SPND_SCND,0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_mus_count,0),0)   SUM_SPND_SCND_PERCUST_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_mus_count,0),0) SUM_SPND_SCND_PERCUST_STEP5
,NVL(NVL(sum(SUM_STEP0_SPND_SCND),0)/NULLIF(sum_prop_count,0),0)   SUM_SPND_SCND_PERPROP_STEP0
,NVL(NVL(sum(SUM_STEP1_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP1
,NVL(NVL(sum(SUM_STEP2_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP2
,NVL(NVL(sum(SUM_STEP3_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP3
,NVL(NVL(sum(SUM_STEP4_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP4
,NVL(NVL(sum(SUM_STEP5_SPND_SCND),0)/NULLIF(sum_prop_count,0),0) SUM_SPND_SCND_PERPROP_STEP5
from 
(
 select 
 OLEDATE 
 ,RGN_CODE
 ,RGN_NAME
  ,BRANCH_NAME
 , BRANCH_CODE
 ,count(distinct cust_no) sum_mus_count--toplam musteri sayýsý   
  ,count(distinct PROP_NMBR) as sum_prop_count --toplam teklif adedi
  ,sum(nvl(STEP0_SPND_SCND,0)) as  SUM_STEP0_SPND_SCND
  ,sum(nvl(STEP1_SPND_SCND,0))  as SUM_STEP1_SPND_SCND
  ,sum(nvl(STEP2_SPND_SCND,0)) aS SUM_STEP2_SPND_SCND
 , sum(nvl(STEP3_SPND_SCND,0)) AS SUM_STEP3_SPND_SCND
 , sum(NVL(STEP4_SPND_SCND,0)) AS SUM_STEP4_SPND_SCND
 , sum(NVL(STEP5_SPND_SCND,0)) AS SUM_STEP5_SPND_SCND
,(sum(nvl(STEP0_SPND_SCND,0))+sum(nvl(STEP1_SPND_SCND,0))+sum(nvl(STEP2_SPND_SCND,0))+sum(nvl(STEP3_SPND_SCND,0))+sum(NVL(STEP4_SPND_SCND,0))+sum(NVL(STEP5_SPND_SCND,0))) AS SUM_SPND_SCND
        from 
 PRSN.TIME_SPEND_SECOND  
    where trunc(OLEDATE)=trunc(sysdate-1)
  group by 
OLEDATE
  ,RGN_CODE
 ,RGN_NAME
  ,BRANCH_NAME
 , BRANCH_CODE
 )a
 GROUP BY 
OLEDATE
  ,RGN_CODE
 ,RGN_NAME
  ,BRANCH_NAME
 , BRANCH_CODE
,sum_mus_count
,sum_prop_count
,SUM_SPND_SCND
,SUM_STEP0_SPND_SCND
,SUM_STEP1_SPND_SCND
,SUM_STEP2_SPND_SCND
,SUM_STEP3_SPND_SCND
,SUM_STEP4_SPND_SCND
,SUM_STEP5_SPND_SCND





select *  from   LEYLAY.TEMP_time_spend_second
  where trunc(OLEDATE)=trunc(sysdate-1)
 --14 bolge var 

select count(distinct BRANCH_CODE)  from   LEYLAY.TEMP_time_spend_second
  where trunc(OLEDATE)=trunc(sysdate-1)
 --70 sube  var 

  
  --BANKA GENEL
  --SEGMENT GENEL
  --BOLGE GENEL
  --SUBE GENEL
 --MUSTERÝ BAZLI AYRINTI
 
 -----AYRI BÝR RAPORDA TUM LOG SURELERI 
  
 select  * from 
  LEYLAY.TEMP_time_spend_second t
 where 
 1=1
 --trunc(tarih)=trunc(sysdate-3)
 and cust_segment='TÝCARÝ'
 
 group by oledate,watch_id
  having count(distinct watch_id)>1
  
  --4451227
  select cust_no, count(distinct PROP_NMBR) from LEYLAY.TEMP_time_spend_second t
  where  tarih=to_date('06.11.2017','dd.mm.yyyy')
  group by cust_no
  having count(distinct P2ROP_NMBR)>1
  
  --CUST_NO TEST 
    select cust_no, count( cust_no) from LEYLAY.TEMP_time_spend_second t
--  where  tarih=TRUNC(SYSDATE-1)
  group by cust_no,TARIH
  having count( cust_no)>1
  
  
  select t.PROP_NMBR,t.* from LEYLAY.TEMP_time_spend_second t where t.cust_no in (1364271)
  and tarih=trunc(sysdate-1)
  
  
   select * from  EXTR.FS_MUSTERI_GRUP MG
          LEFT JOIN EXTR.FS_GRUP GR ON GR.GRUP = MG.GRUP  where MG.MUSTERI_NO 
       in (14242527,
7325670)     --iki grup adý ve numarasý gelen musteri  var.
     
select *  
    from LEYLAY.TEMP_time_spend_second
    where trunc(tarih)=to_date('06.11.2017','dd.mm.yyyy')


--3692576 musteri ticari olmasýna ragment bolge adý ve kodu ve sube býlgýsý gelmýyor
  
--       





   
             
               
