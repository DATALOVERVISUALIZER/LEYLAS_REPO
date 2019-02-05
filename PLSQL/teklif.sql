--ole teklif ekraný ise 5 Aðustos 2017 tarihinde canlýya alýnmýþtýr. 
--31599
/* Formatted on 23.01.2018 16:52:13 (QP5 v5.269.14213.34769) */
SELECT
       TM.MUSTERI AS CUST_NO
      ,MM.MUS_RP_ADI AS CUST_NAME
      ,CASE
          WHEN MM.CALISMA_SEKLI = 1
          THEN
             'BÝREYSEL'
          WHEN MM.CALISMA_SEKLI = 2
          THEN
             'TÝCARÝ'
          WHEN MM.CALISMA_SEKLI = 3
          THEN
             'KURUMSAL'
          WHEN MM.CALISMA_SEKLI = 4
          THEN
             'KOBÝ'
          WHEN MM.CALISMA_SEKLI = 5
          THEN
             'MÝKRO'
          ELSE
             'OTHER'
       END
          AS CUST_SEGMENT
      ,SUBE.BOLGE_KOD AS RGN_CODE
      ,SUBE.BOLGE_AD AS RGN_NAME
      ,SUBE.SUBE_KOD AS BRANCH_CODE
      ,SUBE.SUBE_AD AS BRANCH_NAME
      ,SUBE.AKTF_F BRANCH_STATUS
      ,MG.GRUP AS GRP_CODE
      ,GR.ACIKLAMA AS GRP_NAME
      ,MG.GRUP_TIPI AS GRP_TYPE
      ,GR.DURUM AS GRP_STATUS
      ,TM.TEKLIF_ID AS PROP_NMBR
      ,TM.TEKLIF_NUMARASI AS PROP_ID
      ,TM.PUAN AS PROP_GRADE
      ,TM.BOLUM_NO AS PROP_DPRTMNT_NO
      ,TM.SERVIS_ID AS PROP_SERVIS_ID
      ,TM.SCORECARD_SW AS PROP_SCORECARD_SW
      ,TM.TEKLIF_SONUCU AS PROP_RESULT
      ,TM.DURUM AS PROP_STATU_CODE
      ,DECODE(TM.DURUM,  0, 'Devam Ediyor',  1, 'Onaylý',  9, 'Ýptal/Red')
          AS PROP_STATU_CODE_EXP
      ,TM.TARIH PROP_START_DATE
      ,I.TARIH PROP_FINISH_DATE
      ,NVL(P.VAL, 0) PROP_OLE_FLAG
      ,CASE WHEN P.VAL = 1 THEN 'OLE' ELSE 'FINSOFT' END AS PROP_SOURCE
      ,U.SICIL AS UPD_PRSN_NO
      ,U.ISIM || ' ' || U.SOYAD UPD_PRSN_NAME
      ,U.UNVAN AS UPD_PRSN_NO_TITLE
      ,G.ACIKLAMA UPD_PRSN_NO_TITLE_EXP
FROM
       EXTR.FS_TEKLIF_MASTER TM
       LEFT JOIN EXTR.FS_MUSTERI_MASTER MM ON MM.MUSTERI_NO = TM.MUSTERI
       INNER JOIN EXTR.FS_WF_IS I ON I.REFERANS = TO_CHAR(TM.TEKLIF_ID)
       LEFT JOIN EXTR.FS_WF_IS_PRM P ON P.ISNO = I.ISNO AND P.KEY = 'OLE'
       INNER JOIN EXTR.FS_USERID_VIEW U ON U.SICIL = I.USERID -- bazý upduser_id'lerin kaynak tabloda cift kaydý oldugundan cokluyor. Inner ile data kaybý yok
       LEFT JOIN EXTR.FS_GOREV G ON G.GOREV = U.GOREV
       LEFT JOIN EXTR.FS_MUSTERI_GRUP MG ON MG.MUSTERI_NO = MM.MUSTERI_NO -- bir müþterinin birden fazla grubu olabilir bu nedenle FOCUSTa musterinin grubunun aktif pasif oldugu flag'i mutlaka eklenmeli.
       LEFT JOIN EXTR.FS_GRUP GR ON GR.GRUP = MG.GRUP
       INNER JOIN
       (SELECT
               SUBE_KOD
              ,BOLGE_KOD
              ,BOLGE_AD
              ,SUBE_AD
              ,KST_TRH
              ,UPD_TRH
              ,AKTF_F
        FROM
               DM_MIS.DIM_MIS_BOLGE WHERE KST_TRH = (SELECT MAX(KST_TRH) FROM DM_MIS.DIM_MIS_BOLGE))
        SUBE ON SUBE.SUBE_KOD = MM.ANA_SUBE --þubeye inner gittik çünkü sadece canlýya aliýnan where kosulundaki þubeler üzerinden ilerliyoruz.
          WHERE
          1=1
        AND    TM.TARIH >=TO_DATE('2017/08/05', 'YYYY/MM/DD') --ole teklif ekraný ise 5 Aðustos 2017 tarihinde canlýya alýnmýþtýr.
         AND MM.ANA_SUBE IN (142, 143, 177, 225, 247, 264, 279, 433, 439, 455, 656, 199, 398, 249, 475, 657, 183, 195, 184, 196, 147, 265, 718, 366, 227, 395, 451, 230, 191, 442, 198, 676, 472, 178, 779, 107, 186, 780, 680, 202, 223, 158, 266, 260, 212, 176, 434, 161, 724, 431, 219, 721, 373, 221, 667, 139, 410, 335 )
        --where musteri=19725665 
           order by 1,3,4 ,9 desc;
           
           
           
--select* from extr.fs_grup where gruptip='3' and  gruptur='K' risk gruplarý demek oluyor
          
        

          
         