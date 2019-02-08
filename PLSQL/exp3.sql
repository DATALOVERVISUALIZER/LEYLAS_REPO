/* Formatted on 11.01.2018 14:54:51 (QP5 v5.269.14213.34769) */
SELECT
       MALI_VERI_GIR_EKRAN
      ,UPD_TRH
      ,SPR_REF_NO
      ,MUSTERI_NO
      ,MUS_UNVAN
      ,MUS_SGMNT
      ,BOLGE_KODU
      ,BOLGE_ADI
      ,SUBE_KODU
      ,SUBE_ADI
      ,SUBE_AKTIF_F
      ,UPD_SICIL
      ,UPD_KLLNC_ADI
      ,UPD_UNVAN
      ,UPD_SICIL_UNVAN
      ,IL
      ,UPD_PROGRAM
      ,ETL_TRH
      ,ETL_JOB
FROM
       ((SELECT
                'OLE' AS MALI_VERI_GIR_EKRAN
               ,A.UPD_TARIH AS UPD_TRH
               ,NULL AS SPR_REF_NO --Bilanconun (RATIMUSNO-b�lancodonem-ID  kolonlar�n�n birle�iini tutar )
               ,A.MUSTERI_NO AS MUSTERI_NO
               ,MM.MUS_RP_ADI AS MUS_UNVAN
               ,CASE
                   WHEN MM.CALISMA_SEKLI = 1
                   THEN
                      'B�REYSEL'
                   WHEN MM.CALISMA_SEKLI = 2
                   THEN
                      'T�CAR�'
                   WHEN MM.CALISMA_SEKLI = 3
                   THEN
                      'KURUMSAL'
                   WHEN MM.CALISMA_SEKLI = 4
                   THEN
                      'KOB�'
                   WHEN MM.CALISMA_SEKLI = 5
                   THEN
                      'M�KRO'
                   ELSE
                      'OTHER'
                END
                   AS MUS_SGMNT
               ,SUBE.BOLGE_KOD AS BOLGE_KODU
               ,SUBE.BOLGE_AD AS BOLGE_AD�
               ,SUBE.SUBE_KOD AS SUBE_KODU
               ,SUBE.SUBE_AD AS SUBE_AD�
               ,SUBE.AKTF_F SUBE_AKTIF_F
               ,A.UPD_SICIL AS UPD_SICIL --u.sicil
               ,U.ISIM || ' ' || U.SOYAD UPD_KLLNC_ADI
               ,U.UNVAN AS UPD_UNVAN
               ,G.ACIKLAMA UPD_SICIL_UNVAN
               ,IL.ACIKLAMA AS IL
               ,A.UPD_PROGRAM AS UPD_PROGRAM
               ,TRUNC(SYSDATE - 1) ETL_TRH
               ,'NULL' ETL_JOB
         FROM
                EXTR.FS_FINANCIAL_DATA_RAW A
                INNER JOIN EXTR.FS_MUSTERI_MASTER MM
                   ON MM.MUSTERI_NO = A.MUSTERI_NO
                LEFT JOIN EXTR.FS_USERID_VIEW U ON U.SICIL = A.UPD_SICIL
                LEFT JOIN EXTR.FS_GOREV G ON G.GOREV = U.GOREV
                LEFT JOIN EXTR.FS_SUBE SB ON SB.SUBE = U.CALISSUBE
                LEFT JOIN EXTR.FS_IL IL ON IL.IL = SB.ILKODU
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
                        KST_TRH =
                           (SELECT MAX(KST_TRH) FROM DM_MIS.DIM_MIS_BOLGE))
                SUBE
                   ON SUBE.SUBE_KOD = MM.ANA_SUBE AND (SUBE.BOLGE_AD <>
                      'Serbest B�lge' OR SUBE.BOLGE_AD LIKE '%Ticari%') AND
                      (SUBE.BOLGE_AD LIKE '%B�lge%' OR SUBE.BOLGE_AD LIKE
                         '%Ticari%')
         WHERE
                (A.UPD_TARIH) >= TO_DATE('05.06.2017', 'DD.mm.yyyy') AND
                TRUNC                                                    (
                A.UPD_TARIH) =
                   TRUNC                                                 (
                SYSDATE - 1)) -- OLE ekranlar�na yap�lan gri�ler min bu tarihten ba�lamaktad�r.
        UNION ALL
        (SELECT
                'FINSOFT' AS MALI_VERI_GIR_EKRAN
               ,S.GUNC_TAR UPD_TRH
               ,S.SPR_REF_NO --Bilanconun (RATIMUSNO-b�lancodonem-ID  kolonlar�n�n birle�iini tutar )
               ,M.FINSOFT_MUST_NO AS FINSOFT_MUS_NO
               ,MM.MUS_RP_ADI AS FIN_MUS_UNVAN
               ,CASE
                   WHEN MM.CALISMA_SEKLI = 1
                   THEN
                      'B�REYSEL'
                   WHEN MM.CALISMA_SEKLI = 2
                   THEN
                      'T�CAR�'
                   WHEN MM.CALISMA_SEKLI = 3
                   THEN
                      'KURUMSAL'
                   WHEN MM.CALISMA_SEKLI = 4
                   THEN
                      'KOB�'
                   WHEN MM.CALISMA_SEKLI = 5
                   THEN
                      'M�KRO'
                   ELSE
                      'OTHER'
                END
                   AS ING_SEGMENT_FIN
               ,SUBE.BOLGE_KOD AS FIN_BOLGE_KODU
               ,SUBE.BOLGE_AD AS FIN_BOLGE_AD�
               ,SUBE.SUBE_KOD AS FIN_SUBE_KODU
               ,SUBE.SUBE_AD AS FIN_SUBE_AD�
               ,SUBE.AKTF_F
               ,OFSDATA.TONUMBER(S.ILK_TNM_OP_ID) --u.sicil
               ,U.ISIM || ' ' || U.SOYAD FIN_KULLANICI_ADI
               ,U.UNVAN AS FIN_UPD_SICIL
               ,G.ACIKLAMA FIN_UNVAN_ACIKLAMA
               ,IL.ACIKLAMA IL
               ,'FINSOFT' AS UPD_PROGRAM --HArdcoded yazmam dogru mu sorulacak
               ,TRUNC(SYSDATE - 1) ETL_TRH
               ,'NULL' ETL_JOB
         FROM
                EXTR.FS_SPR_REF S --hem ole hem de finsofttan girilen kay�tlar�n datas� duser.
                LEFT JOIN EXTR.FS_MUST M ON M.MUST_NO = S.MUST_NO
                LEFT JOIN EXTR.FS_MUSTERI_MASTER MM
                   ON MM.MUSTERI_NO = M.FINSOFT_MUST_NO
                LEFT JOIN EXTR.FS_USERID_VIEW U
                   ON U.SICIL = S.ILK_TNM_OP_ID AND S.SPR_DRM_KOD = 'GOT' --GOT genel mudurluk onayl�
                LEFT JOIN EXTR.FS_GOREV G ON G.GOREV = U.GOREV
                LEFT JOIN EXTR.FS_SUBE SB ON SB.SUBE = U.CALISSUBE
                LEFT JOIN EXTR.FS_IL IL ON IL.IL = SB.ILKODU
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
                        DM_MIS.DIM_MIS_BOLGE B
                 WHERE
                        KST_TRH =
                           (SELECT MAX(KST_TRH) FROM DM_MIS.DIM_MIS_BOLGE)
                        AND (B.BOLGE_AD <> 'Serbest B�lge' OR B.BOLGE_AD
                        LIKE
                           '%Ticari%') AND (B.BOLGE_AD LIKE '%B�lge%' OR B.
                        BOLGE_AD LIKE
                           '%Ticari%')) SUBE
                   ON SUBE.SUBE_KOD = MM.ANA_SUBE
         WHERE
                1 = 1 AND M.FINSOFT_MUST_NO NOT IN (SELECT
                                                           MUSTERI_NO
                                                    FROM
                                                           EXTR.
                FS_CORP_BILANCO_RAW
                                                    WHERE
                                                           TRUNC(UPD_TARIH)
                >=
                   TO_DATE                                 ('05.06.2017'
                                                           ,'dd.mm.yyyy'))
                AND M.FINSOFT_MUST_NO NOT IN (SELECT
                                                     R.MUSTERI_NO
                                              FROM
                                                     EXTR.
                FS_FINANCIAL_DATA_RAW R
                                              WHERE
                                                     R.DURUM = 1 AND TRUNC(
                UPD_TARIH) >=
                   TO_DATE                                           (
                '05.06.2017'
                                                                     ,
                'dd.mm.yyyy')) AND S.SPR_REF_NO NOT LIKE '%201612%' AND S.
                SPR_REF_NO NOT LIKE
                   '%201512%' AND S.SPR_REF_NO NOT LIKE '%201412%' AND S.
                SPR_REF_NO NOT LIKE
                   '%201312%' AND S.SPR_REF_NO NOT LIKE '%201212%' AND S.
                SPR_REF_NO NOT LIKE
                   '%201112%' AND S.SPR_REF_NO NOT LIKE '%201012%' AND S.
                SPR_REF_NO NOT LIKE
                   '%200912%' AND S.SPR_REF_NO NOT LIKE '%200812%' AND S.
                SPR_REF_NO NOT LIKE
                   '%200712%' AND S.SPR_REF_NO NOT LIKE '%200612%' AND S.
                SPR_REF_NO NOT LIKE
                   '%200512%' AND S.SPR_REF_NO NOT LIKE '%200412%' AND S.
                ILK_TNM_TAR >=
                   TO_DATE                                             (
                '05.06.2017'
                                                                       ,
                'dd.mm.yyyy') --projenin canl�ya al�nd��� tarih filtre olarak kullan�lm��t�r ��nk� kaynak tabloda ba�ka veriler de mevcut.
                             AND TRUNC(S.ILK_TNM_TAR) =v_tarih))



--i� birimi m��terinin �zerinde FOCUS �zerinde t�klad���nda bu ayr�nt�lara gidecek.

--SORU1
select  count(*) from     EXTR.FS_FINANCIAL_DATA_RAW  
--SPR_REF_NO , OLE mali veri giri�te hangi tablodan eri�ilebilir. Financial data_Raw tablosu ile joini ne olmal�d�r. 

--YIGIT CEVAP
select  * from     EXTR.FS_FINANCIAL_DATA_RAW  
--SPR_REF_NO , OLE verisine  mali veri giri�te hangi tablodan eri�ilebilir. Financial data_Raw tablosu ile joini ne olmal�d�r. 
Bu bilgi i�in direkt join yapamazs�n.Bu bilgiye ula�abilmek i�in 3-4 tabloya gitmek gerekiyor.�uan i�in laz�m m� ? Ben a�a��da yaz�yorum yinede .

select donem from CUTL.FINANCIAL_DATA where MASTER_ID in (
select id from CUTL.FINANCIAL_DATA_RAW where musteri_no=8386558) � olede hangi doneme ait girmi�se o d�nem i�in rati tablolar�ndan kontrol ederiz.
select * from kredi.must where finsoft_must_no=8386558
select * from kredi.spr_ref where must_no=14788 and spr_yil=2017 and spr_ay=03 --14788-201703-A-25


--SORU 2
select  distinct DURUM   from     EXTR.FS_FINANCIAL_DATA_RAW --durum kolonu burada ne ifade ediyor. t�m veriler 1 olarak geliyor.     EXTR.FS_SPR_REF bu tablodaki (SPR_DRM_KOD) bu kolona denk geliyor diyemeyiz. De�il mi?  

durum 1 girilmi� demek.O iki kolon birbiriyle alakas�z

--SORU3
select distinct  tip from EXTR.FS_FINANCIAL_DATA_RAW  --tip kolonu hangi veriyi tutar. T�m de�erler 2 olarak geliyor.

Bu da hep 2 at�yor.Excel-mizan t�r� i�in 2 at�yoruz.


--SORU4
select  *  from        EXTR.FS_SPR_REF --SPR_DRM_KOD kolonunun ac�klamalar�n�n oldugu�u bir parametre tablosu mevcut mu? 
--Bu tabloda upd_program kolonu mecut de�il, hardcoded F�nsoft basmak do�ru olur mu? 
A��klamalar�n� bilmiyorum ama biz spr_drm_kod = �GOT� olanlar� al�yoruz bu da genel m�d�rl�k onayl� anlam�na geliyor.Bu tabloya ole ve finsofttan girilen kay�tlar�n datas� d���yor.




