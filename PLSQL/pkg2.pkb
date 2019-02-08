CREATE OR REPLACE PACKAGE BODY DM_INFOMAN.PKG_PORTFOY_RAPORU AS

    --global variables:
    g_module_name      VARCHAR2 (100):= 'PORTFÖY RAPORU';
    g_package_name     VARCHAR2 (40) := 'PKG_PORTFOY_RAPORU';
    g_owner            VARCHAR2 (40) := 'DM_INFOMAN';
    g_is_restartable   NUMBER (1)    := 1;

    --private procedures
    PROCEDURE SF_NLS_DEGERLERINI_OUTPUTA_YAZ;

                                                       /*****************************************************************************************
                                                       /*  PORTFOY RAPORU
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
                                                       /*     HAZIRLAYAN: Dilek KESKÝN, Ýlteriþ MUTLU
                                                       /*
                                                       /*
                                                       /*     Developer-Name (Ýlteriþ MUTLU, Dilek KESKÝN) 27/08/2014 Original Development.
                                                       /*
                                                       /*     Geriye Dönük Çalýþtýrma: SP_MAIN proceduru ile kod geriye dönük çalýþtýrýlabilir, fakat geriye dönük çalýþtma iþlerinden sonra,
                                                       /*                              bazý kolonlarýn pre (onck) deðerleri tutulduðu için, eski tarihin bir sonraki günü de çalýþtýrýlmalýdýr.
                                                       /*                              Eski tarihli bazý kayýtlar üzerinde manuel update olduðu için eski tarih güncelleneceðinde data
                                                       /*                              sahibinden (Mimar Sinan Tekin) onay alýnmalýdýr.
                                                       /*
                                                       /*  Not: Procedure'lerin çalýþma sýrasý þu þekildedir:
                                                       /*      1) SP_MAIN                  --uc4(automic)'ten
                                                       /*      2) SP_MEMZUC_DONEM          --SP_MAIN içinden (sysdate-1 için çalýþacak yalnýzca. kod içerde zaten son 3 aya bakýyor)
                                                       /*      3) SP_PORTFOY_RAPORU        --SP_MAIN içinden
                                                       /*      4) SP_KRD_ANLZ              --SP_MAIN içinden
                                                       /*      5) SP_MEMZUC_GELEN_PORTFOY  --SP_MAIN içinden
                                                       /*      6) SP_PRTFY_RPR_KYT_DGSM    --SP_MAIN içinden
                                                       /*      7) SP_IKTS_DATAMART         --uc4(automic)'ten
                                                       /*      8) SP_AVKT_PRFRMNS          --uc4(automic)'ten
                                                       /*
                                                       /*****************************************************************************************/


    PROCEDURE SP_MAIN (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) ) IS

        v_tarih             DATE;
        v_sqlcode           NUMBER   (10);
        v_sqlcodeexp        VARCHAR2 (200);
        v_sp_name           VARCHAR2 (40) := 'SP_MAIN';
        v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no           NUMBER;


    BEGIN

        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

        v_tarih := NVL(p_tarih, TRUNC(SYSDATE-1));

        --kaynak tablo (tcmbrisk) tablosu arþivlendiði için, procedure'un geriye dönük çalýþtýrýlýp içerdeki datayý SÝLMEMESÝ için kontrol eklendi. 27.01.2016 Ý.MUTLU
        IF ( v_tarih = TRUNC(SYSDATE-1) ) THEN
            PKG_PORTFOY_RAPORU.SP_MEMZUC_DONEM(v_tarih);
            v_line_no := $$PLSQL_LINE;
        END IF;

        PKG_PORTFOY_RAPORU.SP_PORTFOY_RAPORU(v_tarih);
        v_line_no := $$PLSQL_LINE;
        PKG_PORTFOY_RAPORU.SP_KRD_ANLZ(v_tarih);
        v_line_no := $$PLSQL_LINE;
        PKG_PORTFOY_RAPORU.SP_MEMZUC_GELEN_PORTFOY(v_tarih);
        v_line_no := $$PLSQL_LINE;
        PKG_PORTFOY_RAPORU.SP_PRTFY_RPR_KYT_DGSM(v_tarih);
        v_line_no := $$PLSQL_LINE;

    -- END LOG
    ETL.PKG_UTIL_LIB.PRC_LOG_END;

    DBMS_APPLICATION_INFO.set_module(NULL,NULL);

    EXCEPTION WHEN OTHERS THEN
      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

      --FAILURE LOG
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;

    END SP_MAIN;


    PROCEDURE SP_MEMZUC_DONEM (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

    v_tarih            DATE;
    v_SqlCode          NUMBER (10);
    v_SqlCodeExp       VARCHAR2 (200);
    v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
    v_line_no          NUMBER;
    v_sp_name          VARCHAR2 (40) := 'SP_MEMZUC_DONEM';
    v_memzuc_donem     trfm.TMP_MEMZUC_DNM.memzuc_dnm%TYPE;
    v_memzuc_gelen     trfm.TMP_MEMZUC_GELN.dnm%TYPE;
    v_tarih_donem      NUMBER;


    v_donem_baslangic  NUMBER;
    v_donem_bitis      NUMBER;

    v_donem_ara_1      NUMBER;
    v_donem_ara_2      NUMBER;
    v_partition_name   VARCHAR2(100);

                                    /*
      NOT: SP_MEMZUC_DONEM proceduru TCMBRISK tablosunun arþivlenmesi sebebi ile private yapýldý.
           Portfoy raporunun tekrar çalýþtýrýlmasý gereksinimi doðduðunda, SP_MAIN job'ý ile baþlatýlmalýdýr.

           Kaynak tabloya (tcmbrisk) datalar eski dönemler içinde yüklendiði için , Procedure çalýþtýðýnda son 3 ay
           datasýný silip yükleyecek þekilde oluþturulmuþtur.
    */

BEGIN
    ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);

    v_tarih := trunc(p_tarih);

    v_tarih_donem     := TO_NUMBER(TO_CHAR(v_tarih,'yyyymmdd'));

    v_donem_baslangic := TO_NUMBER(TO_CHAR(add_months(v_tarih,-3),'yyyymm'));
    v_donem_bitis     := TO_NUMBER(TO_CHAR(v_tarih,'yyyymm'));

    --truncate partition için kullanýlacak deðiþkenler
    v_donem_ara_1     := TO_NUMBER(TO_CHAR(add_months(v_tarih,-1),'yyyymm'));
    v_donem_ara_2     := TO_NUMBER(TO_CHAR(add_months(v_tarih,-2),'yyyymm'));

    v_line_no := $$PLSQL_LINE;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_MEMZUC_GELN_PRTFY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;
    v_line_no := $$PLSQL_LINE;

    INSERT                                /*+ APPEND */ INTO trfm.TMP_MEMZUC_GELN_PRTFY
     SELECT a.kst_trh, a.mus_no, a.tplm_rsk, a.firm_lmt, a.npl_nkt_rsk, a.npl_gnakdi_rsk,
            a.ing_sktr, a.ing_sktr_acklm_tr, a.ing_sktr_acklm_en, a.ytk_svy, a.ytk_svy_acklm,
            a.rtg, a.krnotu, a.yakn_gzlm_drm, a.prtfy_sahibi_kod_acklm as prtfy_shp_acklm,
            a.p, a.krd_ynlm_vade, a.cnli_nkt_rsk_gncl_kur,a.cnli_gnakdi_rsk,a.thp_156,
            a.thp_158_159,a.cek_thht, LPAD(TRIM(a.verg_no),11,0) as verg_no,
            a.clsm_skl, a.bank_ciro, a.bank_trh, a.sim_ciro, a.sim_trh, a.mus_tip,
            sysdate AS etl_trh,
            v_sp_name AS etl_job,
            a.ana_sube
       FROM dm_infoman.PORTFOY_RAPOR a
            INNER JOIN (SELECT DISTINCT
                               LPAD(TRIM(ic.verg_no),11,0) as verg_no,
                               MAX(ic.mus_no) KEEP (DENSE_RANK FIRST ORDER BY (ic.cnli_nkt_rsk_gncl_kur+ic.thp_158_159+ic.thp_156+ic.cnli_gnakdi_rsk+ic.cek_thht+ic.npl_nkt_rsk+ic.npl_gnakdi_rsk) desc)
                                               OVER (PARTITION BY LPAD(TRIM(ic.verg_no),11,0)) as musteri_no
                          FROM dm_infoman.PORTFOY_RAPOR ic
                         WHERE 1=1
                               AND ic.kst_trh=LAST_DAY(ic.kst_trh)
                               and ic.firm_lmt<>0
                               and LENGTH(LPAD(TRIM(ic.verg_no),11,0))=11
                       ) ss ON ss.verg_no = LPAD(TRIM(a.verg_no),11,0) AND a.mus_no = ss.musteri_no
      WHERE 1=1
      and a.mus_no<>1760030
            AND a.kst_trh=LAST_DAY(a.kst_trh);
    COMMIT;
    v_line_no := $$PLSQL_LINE;


    --DELETE FROM trfm.TMP_MEMZUC_GELN WHERE dnm BETWEEN v_donem_baslangic and v_donem_bitis;
    --COMMIT;

                        --TRUNCATE PARTITIONS--
    v_partition_name:= 'P_'||TO_CHAR(v_donem_baslangic) ;
    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_MEMZUC_GELN',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'tp',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;


    v_partition_name:= 'P_'||TO_CHAR(v_donem_ara_2) ;
    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_MEMZUC_GELN',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'tp',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;

    v_partition_name:= 'P_'||TO_CHAR(v_donem_ara_1) ;
    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_MEMZUC_GELN',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'tp',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;

    v_partition_name:= 'P_'||TO_CHAR(v_donem_bitis) ;
    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_MEMZUC_GELN',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'tp',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;

    v_line_no:= $$PLSQL_LINE;

    INSERT                                  /*+ APPEND */ INTO trfm.TMP_MEMZUC_GELN
    SELECT DISTINCT
           a.donem as dnm,
           z.mus_no,
           z.clsm_skl,
           a.unvan as unvn,
           mg.grp,
           g.aciklama as grp_ad,
           z.ana_sube AS ana_sube_kod,
           s.ad as sube_ad,
           bg.bolgeadi as bolge_ad,
           CASE WHEN e.durum = 0       THEN e.yeni_portfoy_kod
                WHEN e.durum IN (1, 2) THEN e.eski_portfoy_kod
           ELSE '1907'
           END as prtfy_kod,
           a.verkimno as verg_kmlk_no,
           a.riskkodu as rsk_kod,
           a.genellimit as lmt,
           a.kisarisk as kisa_vade,
           a.ortauzunrisk as orta_vade,
           a.uzunrisk as uzn_vade,
           a.faiz,
           a.tahakkuk as tahkuk,
           a.ksayi as bank_adet,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT gn.durum, gn.donem, gn.unvan, gn.riskkodu, gn.bnkadi, gn.genellimit, gn.faiz, gn.tahakkuk, gn.kisarisk, gn.ortauzunrisk, gn.uzunrisk, gn.verkimno, gn.ksayi
              FROM extr.FS_TCMBRISK gn
             WHERE 1=1
                   AND gn.genellimit > 0
                   AND gn.durum = 'G'
                   AND gn.donem BETWEEN v_donem_baslangic and v_donem_bitis
          UNION ALL
            SELECT ar.durum, ar.donem, ar.unvan, ar.riskkodu, ar.bnkadi, ar.genellimit, ar.faiz, ar.tahakkuk, ar.kisarisk, ar.ortauzunrisk, ar.uzunrisk, ar.verkimno, ar.ksayi
              FROM bankdb.TCMBRISK_ESKI@arsivx ar
             WHERE 1=1
                   AND ar.genellimit > 0
                   AND ar.durum = 'G'
                   AND ar.donem BETWEEN v_donem_baslangic and v_donem_bitis
            ) a,
           extr.FS_MUSTERI_PORTFOY e,
--           (SELECT mus_no, ana_sube_kod, clsm_skl, vergi_no
--              FROM (
--                    SELECT musteri_no as mus_no, ana_sube as ana_sube_kod, calisma_sekli as clsm_skl, vergi_no,
--                           ROW_NUMBER() OVER(PARTITION BY vergi_no ORDER BY acilis_tarihi DESC) sira
--                      FROM extr.FS_MUSTERI_MASTER z
--                     WHERE calisma_sekli IN (2,3,4,5)
--                           and durum<>9
--                   )
--             WHERE sira=1
--           ) z,
           trfm.TMP_MEMZUC_GELN_PRTFY z,
           (SELECT musteri_no,grup as grp,sira
              FROM (SELECT musteri_no,grup,
                           ROW_NUMBER() OVER(PARTITION BY musteri_no ORDER BY sira_no ASC) sira
                      FROM extr.FS_MUSTERI_GRUP
                   )
             WHERE sira= 1
           ) mg,
           extr.FS_SUBE s,
           extr.FS_BCEKBOLGEM bg,
           extr.FS_GRUP g
     WHERE 1=1
--           AND a.durum = 'G'
--           and a.donem BETWEEN v_donem_baslangic and v_donem_bitis
           and z.verg_no = LPAD(TRIM(a.verkimno),11,0)-- LPAD(TRIM(z.vergi_no),11,0) = LPAD(TRIM(a.verkimno),11,0)    --and LPAD(z.vergi_no,11,0) = a.verkimno
           and a.donem = TO_CHAR(z.kst_trh,'yyyymm')
--           and a.genellimit > 0
           and z.mus_no = e.musteri_no(+)
           and z.mus_no = mg.musteri_no(+)
           and z.ana_sube = s.sube(+)
           and z.ana_sube = bg.sube(+)
           and g.grup(+) = mg.grp
           and z.mus_no<>1760030;

    COMMIT;

    v_line_no:=$$PLSQL_LINE;

                            --ANALYZE PARTITIONS--
    v_partition_name:= 'P_'||TO_CHAR(v_donem_ara_1) ;
    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_MEMZUC_GELN',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'at',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;


    v_partition_name:= 'P_'||TO_CHAR(v_donem_bitis) ;
    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_MEMZUC_GELN',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'at',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;

    SELECT NVL(MAX(memzuc_dnm),9999) INTO v_memzuc_donem
      FROM TRFM.TMP_MEMZUC_DNM
     WHERE memzuc_dnm <= v_tarih_donem;

    SELECT MAX(dnm) INTO v_memzuc_gelen
      FROM TRFM.TMP_MEMZUC_GELN
     WHERE dnm <= v_tarih_donem;

    v_line_no := $$PLSQL_LINE;

    IF(v_memzuc_gelen <> v_memzuc_donem ) THEN

       DELETE FROM trfm.TMP_MEMZUC_DNM WHERE memzuc_dnm <= v_memzuc_gelen ;
       COMMIT;

       INSERT                                  /*+ APPEND */ INTO trfm.TMP_MEMZUC_DNM
       SELECT   f.memzuc_dnm,
                f.mus_no,
                f.tplm_memzuc_lmt,
                f.tplm_memzuc_rsk,
                f.memzuc_lmt_dolk_oran,
                f.tplm_memzuc_tkp_bky,
                f.tplm_memzuc_faiz_tahkuk,
                f.tplm_memzuc_bank_adet,
                f.sira,
                ROUND(CASE WHEN lead(tplm_memzuc_rsk,1,0) over (partition by mus_no order by sira)=0 THEN 0
                           ELSE (tplm_memzuc_rsk-lead(tplm_memzuc_rsk,1,0) over (partition by mus_no order by sira))
                                 /lead(tplm_memzuc_rsk,1,0) over (partition by mus_no order by sira) END,2) as son_ay_memzuc_art_oran,
                ROUND(CASE WHEN lead(tplm_memzuc_rsk,2,0) over (partition by mus_no order by sira) =0 THEN 0
                           ELSE (tplm_memzuc_rsk-lead(tplm_memzuc_rsk,2,0) over (partition by mus_no order by sira) )
                                 /lead(tplm_memzuc_rsk,2,0) over (partition by mus_no order by sira)  END,2) as son_2_ay_memzuc_art_oran,
                ROUND(CASE WHEN lead(tplm_memzuc_rsk,3,0) over (partition by mus_no order by sira) =0 THEN 0
                           ELSE (tplm_memzuc_rsk-lead(tplm_memzuc_rsk,3,0) over (partition by mus_no order by sira) )
                                /lead(tplm_memzuc_rsk,3,0) over (partition by mus_no order by sira)  END,2) as son_3_ay_memzuc_art_oran,
                ROUND(CASE WHEN lead(tplm_memzuc_rsk,6,0) over (partition by mus_no order by sira) =0 THEN 0
                           ELSE (tplm_memzuc_rsk-lead(tplm_memzuc_rsk,6,0) over (partition by mus_no order by sira) )
                                /lead(tplm_memzuc_rsk,6,0) over (partition by mus_no order by sira)  END,2) as son_6_ay_memzuc_art_oran,
                ROUND(CASE WHEN lead(tplm_memzuc_rsk,12,0) over (partition by mus_no order by sira) =0 THEN 0
                           ELSE (tplm_memzuc_rsk-lead(tplm_memzuc_rsk,12,0) over (partition by mus_no order by sira) )
                                /lead(tplm_memzuc_rsk,12,0) over (partition by mus_no order by sira)  END,2) as son_12_ay_memzuc_art_oran,
                sysdate as etl_trh,
                v_sp_name as etl_job
         FROM   (SELECT dnm as memzuc_dnm,
                        mus_no,
                        SUM(lmt) as tplm_memzuc_lmt,
                        SUM(kisa_vade)+SUM(orta_vade)+SUM(uzn_vade)+SUM(faiz)+SUM(tahkuk) as tplm_memzuc_rsk,
                        ROUND((SUM(kisa_vade)+SUM(orta_vade)+SUM(uzn_vade)+SUM(faiz)+SUM(tahkuk))/SUM(lmt),2) as memzuc_lmt_dolk_oran,
                        SUM(CASE WHEN rsk_kod in (313,312,311,310,302,301,300)
                                 THEN (kisa_vade+orta_vade+uzn_vade+faiz+tahkuk) ELSE 0 END) as tplm_memzuc_tkp_bky,
                        SUM(faiz)+SUM(tahkuk) as tplm_memzuc_faiz_tahkuk,
                        MAX(bank_adet) as tplm_memzuc_bank_adet,
                        rank () over (partition by mus_no order by dnm desc) as sira
                   FROM TRFM.TMP_MEMZUC_GELN f
                  WHERE dnm <= v_memzuc_gelen
                        and rsk_kod<>1 --25.03.2015 tarihinde eklendi
                        and f.mus_no<>1760030
               GROUP BY dnm,mus_no) f;

       COMMIT;

        --        --v_cal_tarih  := trunc(to_date(TO_CHAR(v_memzuc_gelen),'yyyymm'));
        --
        --        --memzuc dönemde deðiþiklik varsa, ay sonlarý ve v_tarih çalýþacak.
        --        DECLARE
        --            l_tarih   DATE;
        --            --v_memzuc_gelen date := to_date('01.12.2014');
        --            --v_tarih date := trunc(sysdate-1);
        --        BEGIN
        --
        --           FOR tar
        --           IN (    SELECT   tarih
        --                     FROM   ofsdata.subeperf_tarih
        --                    WHERE
        --                                language = 'tr'
        --                            AND tarih >= TO_DATE(v_memzuc_gelen,'YYYYMM')
        --                            AND tarih <= v_tarih
        --                            and aysonu_f=1
        --              UNION ALL
        --                   SELECT v_tarih FROM DUAL
        --              )
        --           LOOP
        --              l_tarih := tar.tarih;
        --              SP_PORTFOY_RAPORU(l_tarih);
        --              DBMS_OUTPUT.PUT_LINE(l_tarih);
        --           END LOOP;
        --        END;



    END IF;

    v_line_no := $$PLSQL_LINE;

    -- END LOG
    ETL.PKG_UTIL_LIB.prc_log_end;

    DBMS_APPLICATION_INFO.set_module(NULL,NULL);

    EXCEPTION WHEN OTHERS THEN
      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

      --FAILURE LOG
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;

    END SP_MEMZUC_DONEM;





    PROCEDURE SP_PORTFOY_RAPORU (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

    v_tarih            DATE;

    v_SqlCode          NUMBER (10);
    v_SqlCodeExp       VARCHAR2 (200);
    v_line_no          NUMBER;
    v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
    v_sp_name          VARCHAR2 (40) := 'SP_PORTFOY_RAPORU';

    v_tarih_donem      NUMBER;
    v_memzuc_gelen     NUMBER;
    v_partition_name   VARCHAR2(100);

    v_GUNLUK_HPLANDET_SG_arsiv_mi   NUMBER;
    v_RT_ESLESME_SONUC_arsiv_mi     NUMBER;

    v_min_c1_giris_trh              DATE;
    v_min_c1_avkt_atama_trh         DATE;

--    v_ecl_max_kst_trh               DATE;

BEGIN

    ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name, v_etl_tarih, g_is_restartable);

    v_tarih := trunc(p_tarih);
    v_tarih_donem := TO_NUMBER(TO_CHAR(v_tarih,'yyyymm'));

    v_line_no := $$PLSQL_LINE;

    SELECT count(*) INTO v_GUNLUK_HPLANDET_SG_arsiv_mi  --0 döner ise data; bankdb.GUNLUK_HPLANDET_ESKI_SG@arsivx e arþivlenmiþtir.
      FROM extr.FS_GUNLUK_HPLANDET_SG
     WHERE tarih = v_tarih;
    v_line_no := $$PLSQL_LINE;
                                      /*Tüm kodlarda extr.FS_GUNLUK_HPLANDET_SG yerine =>
                                                        extr.FS_GUNLUK_HPLANDET_SG
                                                        UNION ALL
                                                        trfm.TMP_GUNLUK_HPLANDET_ESKI_SG
      kullanýlacaktýr.
      gunluk_hplandet_sg tablosuna 7 defa join yapýlmasý sebebi ile ciddi performans problemi yaþanýyordu. Bu sebple
      yalnýzca etl'de kullanýlacak sütunlarýn datasý tmp tabloya aktarýldý.
    */

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GUNLUK_HPLANDET_ESKI_SG',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;
    v_line_no := $$PLSQL_LINE;

    IF v_GUNLUK_HPLANDET_SG_arsiv_mi = 0 THEN
        INSERT                                  /*+ APPEND */ INTO trfm.TMP_GUNLUK_HPLANDET_ESKI_SG
        SELECT tarih, sube, sinif, ilk7, hestur, borc, alac, ana, alt, tali1, tali2, para, sysdate as etl_trh, v_sp_name as etl_job
          FROM bankdb.GUNLUK_HPLANDET_ESKI_SG@arsivx
         WHERE 1=1
               AND tarih = v_tarih;
        COMMIT;

        trfm.PKG_TRFM_UTIL_LIB.prc_utl_object ('TMP_GUNLUK_HPLANDET_ESKI_SG', NULL, NULL, 'at', v_sqlcode, v_sqlcodeexp);

        IF v_SqlCode<>0 THEN
            raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
        END IF;

    END IF;
    v_line_no := $$PLSQL_LINE;


    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_MUS_DTY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    IF ( v_tarih >= LAST_DAY(ADD_MONTHS(trunc(sysdate-1),-1)) ) THEN    --geriye dönük çalýþtýrmada, çalýþma þeklinin historic datadan gelmesi kontrolü.

        INSERT                                  /*+ APPEND */ INTO trfm.TMP_MUS_DTY
         SELECT  v_tarih as kst_trh,
                 a.musteri_no as mus_no,
                 a.isim_unvan as isim_unvn,
                 CASE WHEN a.ana_sube=504 THEN a.sorumlu_sube ELSE a.ana_sube END as ana_sube,--a.ana_sube,
                 s.ad as ana_sube_ad,
                 h.bolgeadi as bolge_ad,
                 a.calisma_sekli as clsm_skl,
                 a.vergi_no as verg_no,
                 b.rsk_ktgr,
                 b.tmslc_scl,
                 b.tmslc_ad_soyad,
                 b.brm_kod,
                 b.gckme_gun_arlk,
                 b.gckme_gun_adet,
                 b.gckmeli_tutar,
                 m.sinif_kodu as krd_sinif,
                 k.grp_kod,
                 k.grp_kod_acklm,
                 k.clsn_adet,
                 k.p,
                 kod.boss_drm_kod,
                 f.sktr,
                 f.sktr_acklm,
                 f.ing_sktr,
                 f.ing_sktr_acklm_tr,
                 f.ing_sktr_acklm_en,
                 f.bank_sktr,
                 f.bank_sktr_acklm,
                 f.tcmb_kod,
                 f.ing_sktr_krlm_1,
                 f.ing_sktr_krlm_1_acklm,
                 f.sktr_grp,
                 k.grp_lmt,
                 k.grp_rsk,
                 k.grp_kod_1,
                 k.grp_lmt_1,
                 k.grp_rsk_1,
                 k.grp_kod_2,
                 k.grp_lmt_2,
                 k.grp_rsk_2,
                 k.lmt_ynlm_vade,
                 k.firm_lmt,
                 CASE WHEN (ciro.ciro is null or ciro.ciro<=0) and k.rati_ciro>0 THEN k.rati_ciro ELSE ciro.ciro END as bank_ciro,--k.bank_ciro,
                 CASE WHEN (ciro.ciro is null or ciro.ciro<=0) and k.rati_ciro>0 THEN k.rati_trh ELSE ciro.ciro_trh END as bank_trh,--k.bank_trh,
                 k.rati_ciro,
                 k.rati_trh,
                 k.tmnt_yetrszlk_tutar,
                 krd.krd_ynlm_vade,
                 a.grid_no,
                 f.ing_sktr_krlm_2,
                 f.ing_sktr_krlm_2_acklm,
                 f.ing_sktr_krlm_3,
                 f.ing_sktr_krlm_3_acklm,
                 sysdate as etl_trh,
                 v_sp_name as etl_job,
                 CASE WHEN (ciro.simulasyon_ciro is null or ciro.simulasyon_ciro<=0) and k.rati_ciro>0 THEN k.rati_trh ELSE ciro.simulasyon_ciro_trh END as sim_trh,
                 ((CASE WHEN (ciro.simulasyon_ciro is null or ciro.simulasyon_ciro<=0) and k.rati_ciro>0 THEN k.rati_ciro ELSE ciro.simulasyon_ciro END)
                    /TO_NUMBER(TO_CHAR((CASE WHEN (ciro.simulasyon_ciro is null or ciro.simulasyon_ciro<=0) and k.rati_ciro>0
                                             THEN k.rati_trh ELSE ciro.simulasyon_ciro_trh END),'MM')))*12 as sim_ciro,
                 a.musteri_tip as mus_tip
          FROM   ( SELECT mm.musteri_no, mm.musteri_tip, mm.isim_unvan, mm.acilis_tarihi, mm.ana_sube, mm.sorumlu_sube, mm.vergi_no, mm.calisma_sekli, mm.ing_sektor, mm.grid_no
                     FROM extr.FS_MUSTERI_MASTER mm
                    WHERE mm.calisma_sekli in (2,3,4,5)
                 UNION ALL
                   SELECT im.musteri_no, im.musteri_tip, im.isim_unvan, im.acilis_tarihi, im.ana_sube, im.sorumlu_sube, im.vergi_no, im.calisma_sekli, im.ing_sektor, im.grid_no
                     FROM extr.FS_INAKTIF_MUSTERI im
                    WHERE im.calisma_sekli in (2,3,4,5)
                    and  im.musteri_no<>1760030
                                 ) a,
                 extr.FS_SUBE s,
                 extr.FS_BCEKBOLGEM h,
                 trfm.TMP_SKTR_MAP f,
                 ofsdata.MUSTERI_RISK_SINIF_HIST m,
                 (SELECT DISTINCT
                         v_tarih as process_date, -- as f.process_date,
                         f.customer as mus_no,
                         f.riskcategory as rsk_ktgr,
                         f.delayinterval as gckme_gun_arlk,
                         f.delayamount as gckmeli_tutar,
                         f.maxdelay as gckme_gun_adet,
                         g.brm_kod,
                         g.tmslc_scl,
                         g.tmslc_ad_soyad
                    FROM extr.COLL_CUST_GUNLUK_RAPOR_F f,
                         (SELECT DISTINCT process_date,
                                 customer,
                                 CASE WHEN cc.unitcode<>'BRA' THEN cc.unitcode END as brm_kod,
                                 CASE WHEN cc.unitcode<>'BRA' THEN cc.temsilci_sicil END as tmslc_scl,
                                 CASE WHEN cc.unitcode<>'BRA' THEN cc.temsilci_adsoyad END as tmslc_ad_soyad
                            FROM extr.COLL_CUST_GUNLUK_RAPOR_F cc
                           WHERE cc.process_date=v_tarih
                                 and cc.process_date not in (TO_DATE('12/03/2014','DD/MM/YYYY'),TO_DATE('13/03/2014','DD/MM/YYYY'),TO_DATE('14/03/2014','DD/MM/YYYY') ) --bu tarihlerde datada çoklama var.
                                 and cc.process_date >='01.01.2014'  --19.09.2014 tarihinde eklendi. 2014 öncesi datada çoklama var.
                                 and CASE WHEN cc.process_date IN (TO_DATE('03/10/2015','DD/MM/YYYY'),
                                                                   TO_DATE('04/10/2015','DD/MM/YYYY'),
                                                                   TO_DATE('05/10/2015','DD/MM/YYYY') )
                                               and cc.temsilci_sicil=13235
                                          THEN 0 --bu tarihlerde 13235 nolu temsilci sicil yüzünden çoklama oluyor. 06.10.2015 Ý.MUTLU
                                        --WHEN cc.process_date = TO_DATE('XX/XX/2015','DD/MM/YYYY')  and cc.temsilci_sicil=XXXXX THEN 0 --çoklayan gün ve temsilci sicil gir.
                                          ELSE 1
                                      END = 1
                         ) g
                   WHERE f.process_date=v_tarih
                     and f.process_date=g.process_date(+)
                     and f.customer=g.customer(+)
                 ) b,
                 (SELECT DISTINCT a.musteri, b.aciklama as grp_kod_acklm, a.grup_kodu as grp_kod,
                         calisan_sayisi as clsn_adet,puan as p, grup_limit as grp_lmt,grup_risk as grp_rsk,
                         grup_kodu1 as grp_kod_1, grup_limit1 as grp_lmt_1, grup_risk1 as grp_rsk_1,
                         grup_kodu2 as grp_kod_2, grup_limit2 as grp_lmt_2, grup_risk2 as grp_rsk_2,
                         kredi_yenileme_vadesi as krd_ynlm_vade, limit_yenileme_vadesi as lmt_ynlm_vade,
                         firma_limit as firm_lmt, banka_ciro as bank_ciro, banka_tarih as bank_trh,
                         rati_ciro, rati_tarih as rati_trh, teminat_yetersizlik_tutari as tmnt_yetrszlk_tutar
                    FROM extr.FS_KRD_RAPOR_MUS_BILGI_DET_GNC a,
                         extr.FS_GRUP b
                   WHERE a.grup_kodu=b.grup(+) and a.tarih=v_tarih
                 ) k,
                 (SELECT DISTINCT ms.musteri_no,
                         MAX(ms.revizyon_vadesi) KEEP (DENSE_RANK FIRST ORDER BY ms.islem_sira_no desc) OVER (PARTITION BY ms.musteri_no) as krd_ynlm_vade
                    FROM extr.FS_MUSTERI_STATU_TX ms
                   WHERE 1=1
                         and ms.revizyon_vadesi>TO_DATE('01.01.1900','DD.MM.YYYY')
                         and ms.gunceleme_tarihi<=v_tarih
                 ) krd,
                 (SELECT DISTINCT musteri_no,
                         statu_kodu as boss_drm_kod
                    FROM extr.OY_OY_KAT_KRM_BILGILERI
                   WHERE statu_kodu in ('KTK','KTS','WOFF','KTAC')
                 ) kod,
                 (SELECT ct.musteri_no,
                         MAX(ct.ciro_trh) ciro_trh,
                         MAX(ct.ciro_max) ciro,
                         MAX(CASE WHEN flag=1 THEN s_ciro ELSE ciro_max END) simulasyon_ciro,
                         MAX(CASE WHEN flag=1 THEN donem_sonu_eh ELSE ciro_trh END) simulasyon_ciro_trh
                    FROM (SELECT ss.tarih,
                                 ss.musteri_no,
                                 ss.ciro ,
                                 MAX(tarih) KEEP (DENSE_RANK FIRST ORDER BY tarih desc) OVER (PARTITION BY musteri_no) as ciro_trh,
                                 MAX(ciro) KEEP (DENSE_RANK FIRST ORDER BY tarih desc) OVER (PARTITION BY musteri_no) as ciro_max,
                                 CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=tarih THEN tarih ELSE TO_DATE('01/01/1800','dd/mm/yyyy') END as donem_sonu_eh,
                                 MAX(CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=ss.tarih THEN 1 ELSE 0 END)
                                        KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=tarih THEN 1 ELSE 0 END desc) OVER (PARTITION BY musteri_no) as flag,
                                 MAX(ciro) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=tarih THEN tarih ELSE TO_DATE('01/01/1800','dd/mm/yyyy') END desc) OVER (PARTITION BY musteri_no) as s_ciro
                            FROM (SELECT t.tarih,t.musteri_no,t.ciro,t.updprogram FROM extr.FS_MUSTERI_TUZEL_MALI t
                                  UNION ALL
                                  SELECT y.tarih,y.musteri_no,y.aylik_net_gelir as ciro,y.updprogram FROM extr.FS_MUSTERI_GERCEK_MALI y
                                 ) ss
                           WHERE ss.updprogram in ('MUS102', 'MUS101', 'MANUEL', 'RATI')
                         ) ct
                 GROUP BY ct.musteri_no
                 )  ciro
           WHERE 1=1
                 and (CASE WHEN a.ana_sube=504 THEN a.sorumlu_sube ELSE a.ana_sube END) = s.sube  --a.ana_sube = s.sube
                 and (CASE WHEN a.ana_sube=504 THEN a.sorumlu_sube ELSE a.ana_sube END) = h.sube  --and a.ana_sube = h.sube
                 and a.calisma_sekli in (2,3,4,5)
                 and a.musteri_no = b.mus_no(+)
                 and a.musteri_no = k.musteri(+)
                 and a.musteri_no = kod.musteri_no(+)
                 and a.ing_sektor = f.ing_sktr(+)
                 and a.musteri_no = m.musteri(+)
                 and m.tarih(+) = v_tarih
                 and a.musteri_no = ciro.musteri_no(+)
                 and a.musteri_no = krd.musteri_no(+)
               and a.acilis_tarihi <= v_tarih
               and a.musteri_no<>1760030;
        COMMIT;

    ELSE

        INSERT                                  /*+ APPEND */ INTO trfm.TMP_MUS_DTY
          SELECT v_tarih kst_trh,
                 a.musteri_no,
                 a.isim_unvan,
                 CASE WHEN a.ana_sube=504 THEN a.sorumlu_sube ELSE a.ana_sube END as ana_sube,--a.ana_sube,
                 s.ad as ana_sube_ad,
                 h.bolgeadi,
                 NVL(mmc.clsm_skl,a.calisma_sekli) as clsm_skl,
                 a.vergi_no,
                 b.rsk_ktgr,
                 b.tmslc_scl,
                 b.tmslc_ad_soyad,
                 b.brm_kod,
                 b.gckme_gun_arlk,
                 b.gckme_gun_adet,
                 b.gckmeli_tutar,
                 m.sinif_kodu as kredi_sinifi,
                 k.grp_kod,
                 k.grp_kod_acklm,
                 k.clsn_adet,
                 k.p,
                 kod.boss_drm_kod,
                 f.sktr,
                 f.sktr_acklm,
                 f.ing_sktr,
                 f.ing_sktr_acklm_tr,
                 f.ing_sktr_acklm_en,
                 f.bank_sktr,
                 f.bank_sktr_acklm,
                 f.tcmb_kod,
                 f.ing_sktr_krlm_1,
                 f.ing_sktr_krlm_1_acklm,
                 f.sktr_grp,
                 k.grp_lmt,
                 k.grp_rsk,
                 k.grp_kod_1,
                 k.grp_lmt_1,
                 k.grp_rsk_1,
                 k.grp_kod_2,
                 k.grp_lmt_2,
                 k.grp_rsk_2,
                 k.lmt_ynlm_vade,
                 k.firm_lmt,
                 CASE WHEN (ciro.ciro is null or ciro.ciro<=0) and k.rati_ciro>0 THEN k.rati_ciro ELSE ciro.ciro END as bank_ciro,--k.bank_ciro,
                 CASE WHEN (ciro.ciro is null or ciro.ciro<=0) and k.rati_ciro>0 THEN k.rati_trh ELSE ciro.ciro_trh END as bank_trh,--k.bank_trh,
                 k.rati_ciro,
                 k.rati_trh,
                 k.tmnt_yetrszlk_tutar,
                 krd.krd_ynlm_vade,
                 a.grid_no,
                 f.ing_sktr_krlm_2,
                 f.ing_sktr_krlm_2_acklm,
                 f.ing_sktr_krlm_3,
                 f.ing_sktr_krlm_3_acklm,
                 sysdate as etl_trh,
                 v_sp_name as etl_job,
                 CASE WHEN (ciro.simulasyon_ciro IS NULL OR ciro.simulasyon_ciro<=0) and k.rati_ciro>0 THEN k.rati_trh ELSE ciro.simulasyon_ciro_trh END as sim_trh,
                 ((CASE WHEN (ciro.simulasyon_ciro IS NULL OR ciro.simulasyon_ciro<=0) and k.rati_ciro>0 THEN k.rati_ciro ELSE ciro.simulasyon_ciro END)
                    /TO_NUMBER(TO_CHAR((CASE WHEN (ciro.simulasyon_ciro is null or ciro.simulasyon_ciro<=0) and k.rati_ciro>0
                                             THEN k.rati_trh ELSE ciro.simulasyon_ciro_trh END),'MM')))*12 as sim_ciro,
                 a.musteri_tip as mus_tip
            FROM ( SELECT mm.musteri_no, mm.musteri_tip, mm.isim_unvan, mm.acilis_tarihi, mm.ana_sube, mm.sorumlu_sube, mm.vergi_no, mm.calisma_sekli, mm.ing_sektor, mm.grid_no
                     FROM extr.FS_MUSTERI_MASTER mm
                    WHERE mm.calisma_sekli in (2,3,4,5)
                 UNION ALL
                   SELECT im.musteri_no, im.musteri_tip, im.isim_unvan, im.acilis_tarihi, im.ana_sube, im.sorumlu_sube, im.vergi_no, im.calisma_sekli, im.ing_sektor, im.grid_no
                     FROM extr.FS_INAKTIF_MUSTERI im
                    WHERE im.calisma_sekli in (2,3,4,5)
                    and  im.musteri_no<>1760030
                     ) a,
                 extr.FS_SUBE s,
                 extr.FS_BCEKBOLGEM h,
                 TRFM.TMP_SKTR_MAP f,
                 ofsdata.MUSTERI_RISK_SINIF_HIST m,
                 (SELECT DISTINCT
                         v_tarih as process_date, -- as f.process_date,
                         f.customer as mus_no,
                         f.riskcategory as rsk_ktgr,
                         f.delayinterval as gckme_gun_arlk,
                         f.delayamount as gckmeli_tutar,
                         f.maxdelay as gckme_gun_adet,
                         g.brm_kod,
                         g.tmslc_scl,
                         g.tmslc_ad_soyad
                    FROM extr.COLL_CUST_GUNLUK_RAPOR_F f,
                         (SELECT DISTINCT process_date,
                                 customer,
                                 CASE WHEN cc.unitcode<>'BRA' THEN cc.unitcode END as brm_kod,
                                 CASE WHEN cc.unitcode<>'BRA' THEN cc.temsilci_sicil END as tmslc_scl,
                                 CASE WHEN cc.unitcode<>'BRA' THEN cc.temsilci_adsoyad END as tmslc_ad_soyad
                            FROM extr.COLL_CUST_GUNLUK_RAPOR_F cc
                           WHERE cc.process_date=v_tarih
                                 and cc.process_date not in (TO_DATE('12/03/2014','DD/MM/YYYY'),TO_DATE('13/03/2014','DD/MM/YYYY'),TO_DATE('14/03/2014','DD/MM/YYYY') ) --bu tarihlerde datada çoklama var.
                                 and cc.process_date >='01.01.2014'  --19.09.2014 tarihinde eklendi. 2014 öncesi datada çoklama var.
                                 and CASE WHEN cc.process_date IN (TO_DATE('03/10/2015','DD/MM/YYYY'),
                                                                   TO_DATE('04/10/2015','DD/MM/YYYY'),
                                                                   TO_DATE('05/10/2015','DD/MM/YYYY') )
                                               and cc.temsilci_sicil=13235
                                          THEN 0 --bu tarihlerde 13235 nolu temsilci sicil yüzünden çoklama oluyor. 06.10.2015 Ý.MUTLU
                                        --WHEN cc.process_date = TO_DATE('XX/XX/2015','DD/MM/YYYY')  and cc.temsilci_sicil=XXXXX THEN 0 --çoklayan gün ve temsilci sicil gir.
                                          ELSE 1
                                      END = 1
                         ) g
                   WHERE f.process_date=v_tarih
                     and f.process_date=g.process_date(+)
                     and f.customer=g.customer(+)
                 ) b,
                 (SELECT DISTINCT a.musteri, b.aciklama as grp_kod_acklm, a.grup_kodu as grp_kod,
                         calisan_sayisi as clsn_adet,puan as p, grup_limit as grp_lmt,grup_risk as grp_rsk,
                         grup_kodu1 as grp_kod_1, grup_limit1 as grp_lmt_1, grup_risk1 as grp_rsk_1,
                         grup_kodu2 as grp_kod_2, grup_limit2 as grp_lmt_2, grup_risk2 as grp_rsk_2,
                         kredi_yenileme_vadesi as krd_ynlm_vade, limit_yenileme_vadesi as lmt_ynlm_vade,
                         firma_limit as firm_lmt, banka_ciro as bank_ciro, banka_tarih as bank_trh,
                         rati_ciro, rati_tarih as rati_trh, teminat_yetersizlik_tutari as tmnt_yetrszlk_tutar
                    FROM extr.FS_KRD_RAPOR_MUS_BILGI_DET_GNC a,
                         extr.FS_GRUP b
                   WHERE a.grup_kodu=b.grup(+) and a.tarih=v_tarih
                 ) k,
                 (SELECT DISTINCT ms.musteri_no,
                         MAX(ms.revizyon_vadesi) KEEP (DENSE_RANK FIRST ORDER BY ms.islem_sira_no DESC) OVER (PARTITION BY ms.musteri_no) as krd_ynlm_vade
                    FROM extr.FS_MUSTERI_STATU_TX ms
                   WHERE 1=1
                         and ms.revizyon_vadesi>TO_DATE('01.01.1900','DD.MM.YYYY')
                         and ms.gunceleme_tarihi<=v_tarih
                 ) krd,
                 (SELECT DISTINCT musteri_no, statu_kodu as boss_drm_kod
                    FROM extr.OY_OY_KAT_KRM_BILGILERI
                   WHERE statu_kodu in ('KTK','KTS','WOFF','KTAC')
                 ) kod,
                 (SELECT mh.tarih, mh.musteri_no, mh.calisma_sekli as clsm_skl
                    FROM ofsdata.MUSTERI_MASTER_CS_HIST mh
                   WHERE mh.tarih = last_day(v_tarih)
                 ) mmc, --gerye dönük hesaplamada, eski tarihteki calisma_sekli bulunmasý amaçlanmýþtýr.
                 (SELECT ct.musteri_no,
                         MAX(ct.ciro_trh) ciro_trh,
                         MAX(ct.ciro_max) ciro,
                         MAX(CASE WHEN flag=1 THEN s_ciro ELSE ciro_max END) simulasyon_ciro,
                         MAX(CASE WHEN flag=1 THEN donem_sonu_eh ELSE ciro_trh END) simulasyon_ciro_trh
                    FROM (SELECT ss.tarih,
                                 ss.musteri_no,
                                 ss.ciro ,
                                 MAX(tarih) KEEP (DENSE_RANK FIRST ORDER BY tarih desc) OVER (PARTITION BY musteri_no) as ciro_trh,
                                 MAX(ciro) KEEP (DENSE_RANK FIRST ORDER BY tarih desc) OVER (PARTITION BY musteri_no) as ciro_max,
                                 CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=tarih THEN tarih ELSE TO_DATE('01/01/1800','dd/mm/yyyy') END as donem_sonu_eh,
                                 MAX(CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=ss.tarih THEN 1 ELSE 0 END)
                                        KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=tarih THEN 1 ELSE 0 END desc) OVER (PARTITION BY musteri_no) as flag,
                                 MAX(ciro) KEEP (DENSE_RANK FIRST ORDER BY CASE WHEN TO_DATE('31/12/'||TO_CHAR(trunc(ss.tarih),'yyyy'),'dd/mm/yyyy')=tarih THEN tarih ELSE TO_DATE('01/01/1800','dd/mm/yyyy') END desc) OVER (PARTITION BY musteri_no) as s_ciro
                            FROM (SELECT t.tarih,t.musteri_no,t.ciro,t.updprogram FROM extr.FS_MUSTERI_TUZEL_MALI t
                                  UNION ALL
                                  SELECT y.tarih,y.musteri_no,y.aylik_net_gelir as ciro,y.updprogram FROM extr.FS_MUSTERI_GERCEK_MALI y
                                 ) ss
                           WHERE ss.updprogram in ('MUS102', 'MUS101', 'MANUEL', 'RATI')
                         ) ct
                 GROUP BY ct.musteri_no
                 )  ciro
           WHERE 1=1
                 and (CASE WHEN a.ana_sube=504 THEN a.sorumlu_sube ELSE a.ana_sube END) = s.sube  --a.ana_sube = s.sube
                 and (CASE WHEN a.ana_sube=504 THEN a.sorumlu_sube ELSE a.ana_sube END) = h.sube  --and a.ana_sube = h.sube
                 and NVL(mmc.clsm_skl,a.calisma_sekli) in (2,3,4,5)  --a.calisma_sekli. inaktiflerin de listeden kaçmamasý için.
                 and a.musteri_no = b.mus_no(+)
                 and a.musteri_no = k.musteri(+)
                 and a.musteri_no = kod.musteri_no(+)
                 and a.ing_sektor = f.ing_sktr(+)
                 and a.musteri_no = m.musteri(+)
                 and m.tarih(+) = v_tarih
                 and a.musteri_no = mmc.musteri_no (+) --inaktiflerin kaçmamasý için left baðlandý.
                 and a.acilis_tarihi <= v_tarih
                 and a.musteri_no = ciro.musteri_no(+)
                 and a.musteri_no = krd.musteri_no(+)
                 and a.acilis_tarihi <= v_tarih
                 and a.musteri_no<>1760030;
        COMMIT;

    END IF;

    v_line_no := $$PLSQL_LINE;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_YAKN_GZLM_TMNT',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;
    --EXECUTE IMMEDIATE 'TRUNCATE TABLE TMP_YAKN_GZLM_TMNT';

    INSERT                                  /*+ APPEND */ INTO trfm.TMP_YAKN_GZLM_TMNT
    SELECT  tarih as TRH,
            musteri_no as MUS_NO,
            kurumsal_bireysel as KRMSL_BRYSL_F,
            SUM(CASE WHEN derece||teminat_turu ='3Ýpotek' THEN ekspertiz_tl ELSE 0 END) as iptk_exprt_3,
            SUM(CASE WHEN derece||teminat_turu ='2Ýpotek' THEN ekspertiz_tl ELSE 0 END) as iptk_exprt_2,
            SUM(CASE WHEN derece||teminat_turu ='1Ýpotek' THEN ekspertiz_tl ELSE 0 END) as iptk_exprt_1,
            SUM(CASE WHEN derece||teminat_turu ='3Ýpotek' THEN teminat_tutari_tl ELSE 0 END) as iptk_3,
            SUM(CASE WHEN derece||teminat_turu ='2Ýpotek' THEN teminat_tutari_tl ELSE 0 END) as iptk_2,
            SUM(CASE WHEN derece||teminat_turu ='1Ýpotek' THEN teminat_tutari_tl ELSE 0 END) as iptk_1,
            SUM(CASE WHEN derece||teminat_turu ='Firma Garantisi' THEN teminat_tutari_tl ELSE 0 END) as firm_grnt,
            SUM(CASE WHEN derece||teminat_turu ='Dövizli Çekler' THEN teminat_tutari_tl ELSE 0 END) as dvz_cek,
            SUM(CASE WHEN derece||teminat_turu ='Çekler' THEN teminat_tutari_tl ELSE 0 END) as cek,
            SUM(CASE WHEN derece||teminat_turu ='Çek Mevduat Rehni' THEN teminat_tutari_tl ELSE 0 END) as cek_mvdt_rehni,
            SUM(CASE WHEN derece||teminat_turu ='Araç Rehni' THEN teminat_tutari_tl ELSE 0 END) as arac_rehni,
            SUM(CASE WHEN derece||teminat_turu ='Hat Rehni' THEN teminat_tutari_tl ELSE 0 END) as hat_rehni,
            SUM(CASE WHEN derece||teminat_turu in ('Ticari Ýþletme Rehni','Hisse Senetleri Rehni','Diðer Rehinler') THEN teminat_tutari_tl ELSE 0 END) as rhn,
            SUM(CASE WHEN derece||teminat_turu ='Alacaðýn Temliki' THEN teminat_tutari_tl ELSE 0 END) as alck_tmlk,
            SUM(CASE WHEN derece||teminat_turu ='Kefalet(Genel Kredi Sözleþmesi)' THEN teminat_tutari_tl ELSE 0 END) as kflt,
            SUM(CASE WHEN derece||teminat_turu ='Finansman Senedi' THEN teminat_tutari_tl ELSE 0 END) as fnsmn_senet,
            SUM(CASE WHEN derece||teminat_turu ='Teminat Senetleri' THEN teminat_tutari_tl ELSE 0 END) as tmnt_senet,
            SUM(CASE WHEN derece||teminat_turu ='Teminat Senetleri Mevduat Rehni' THEN teminat_tutari_tl ELSE 0 END) as tmnt_senet_mvdt_rehni,
            SUM(CASE WHEN derece||teminat_turu ='Mevduat Rehni - Bankamýz' THEN teminat_tutari_tl ELSE 0 END) as mvdt_rehni,
            sysdate as etl_trh,
            v_sp_name as etl_job
      FROM ofsdata.YAKIN_GOZLEM_TEMINAT_TUM a
     WHERE tarih=v_tarih and kurumsal_bireysel='K'
     and musteri_no<>1760030
  GROUP BY tarih,
           musteri_no,
           kurumsal_bireysel;
    COMMIT;

    v_line_no := $$PLSQL_LINE;

    --EXECUTE IMMEDIATE 'TRUNCATE TABLE TRFM.TMP_MRD_SUB_PART_1';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_MUS_RSK_DTY_ALT_SRG',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_MUS_RSK_DTY_ALT_SRG
    SELECT a.tarih as kst_trh,
           b.clsm_skl,
           a.thp_no,
           a.musteri as mus_no,
           CASE WHEN SUBSTR (referans_no, 4, 4) IN ('TKRO', 'TKGI','TKRG')
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Rotatif'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKIH'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Ýhracat Rotatif_Spot'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKEX'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Eximbank_TL'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKSP'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Spot'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKNY'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Nakit Yön.Kre.'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKON'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Overnight'
                WHEN SUBSTR (referans_no, 4, 4) IN ('TKIK','TKET')
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Senet-Ýskonto'
                WHEN SUBSTR (referans_no, 4, 4) IN ('TTAA', 'TTAT', 'TTFA', 'TTFT', 'TTIT', 'TTSA', 'TTST','TTIA')
                     AND a.para_kodu = 'TL'
                     AND a.kaynak_aciklama = '2'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Taksitli Ticari'
                WHEN SUBSTR (referans_no, 4, 4) <> 'TKRO'
                     AND a.updprogram IN ('KMH', 'NKRD')
                     AND a.kaynak_aciklama IN ('3')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'KMH'
                WHEN SUBSTR (referans_no, 4, 4) IN ('DKTL', 'DKDV', 'TDST')
                     AND a.kaynak_aciklama IN ('1', '2')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Döviz Kredileri'
                WHEN SUBSTR (referans_no, 4, 4) IN ('DKEX')
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Eximbank_YP'
                WHEN SUBSTR (referans_no, 4, 4) IN ('DEDD', 'TTAT', 'TTIT', 'TTSA', 'TTST', 'TTFT')
                     AND a.para_kodu <> 'TL'
                     AND a.kaynak_aciklama IN ('1', '2')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'DEK'
                WHEN SUBSTR (referans_no, 4, 4) IN ('YIPO')
                     AND a.kaynak_aciklama IN ('13')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'YIPO'
                WHEN SUBSTR (a.thp_no, 1, 3) IN (910, 912)
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Teminat Mektubu TL'
                WHEN SUBSTR (a.thp_no, 1, 3) IN (911, 913)
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Teminat Mektubu YP'
                WHEN SUBSTR (a.thp_no, 1, 3) = 922
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Kabul Kredisi TL'
                WHEN SUBSTR (a.thp_no, 1, 3) = 923
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Kabul Kredisi YP'
                WHEN SUBSTR (a.thp_no, 1, 3) = 932
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Akreditif TL'
                WHEN SUBSTR (a.thp_no, 1, 3) = 962
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Dið.Gar.&Kef TL'
                WHEN SUBSTR (a.thp_no, 1, 3) IN (963, 961)
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Dið.Gar.&Kef YP'
                WHEN a.thp_no in ('1194110','1192110','1184110','1184103','1182110','1182106','1182105','1182104','1182103','1182101',
                                  '1174110','1172110','1172106','1164110','1164107','1164106','1164105','1164104','1164103','1164101',
                                  '1162110','1162107','1162106','1162105','1162104','1162103','1162101','1162100')
                THEN 'Bireysel Kredi Kartlarý'
                WHEN a.thp_no in ('1193110','1183110','1183104','1183103','1173110','1163110','1163106','1163105','1163104','1163103','1163101')
                THEN 'Kurumsal Kredi Kartlarý'
           END AS KRD_GRP,
           SUM (a.risk_tutari_tl_karsilik) AS tutar,
           'K-1' as kynk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM ofsdata.MUSTERI_RISK_DETAY_HIST a,
           trfm.TMP_MUS_DTY b
     WHERE 1=1
           AND a.tarih = b.kst_trh
           AND a.musteri = b.mus_no
           AND b.clsm_skl IN (2, 3, 4, 5)
           AND a.tarih = v_tarih
           and a.musteri<>1760030
  GROUP BY a.tarih,
           b.clsm_skl,
           a.thp_no,
           a.musteri,
           CASE WHEN SUBSTR (referans_no, 4, 4) IN ('TKRO', 'TKGI','TKRG')
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Rotatif'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKIH'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Ýhracat Rotatif_Spot'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKEX'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Eximbank_TL'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKSP'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Spot'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKNY'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Nakit Yön.Kre.'
                WHEN SUBSTR (referans_no, 4, 4) = 'TKON'
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Overnight'
                WHEN SUBSTR (referans_no, 4, 4) IN ('TKIK','TKET')
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Senet-Ýskonto'
                WHEN SUBSTR (referans_no, 4, 4) IN ('TTAA', 'TTAT', 'TTFA', 'TTFT', 'TTIT', 'TTSA', 'TTST','TTIA')
                     AND a.para_kodu = 'TL'
                     AND a.kaynak_aciklama = '2'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Taksitli Ticari'
                WHEN SUBSTR (referans_no, 4, 4) <> 'TKRO'
                     AND a.updprogram IN ('KMH', 'NKRD')
                     AND a.kaynak_aciklama IN ('3')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'KMH'
                WHEN SUBSTR (referans_no, 4, 4) IN ('DKTL', 'DKDV', 'TDST')
                     AND a.kaynak_aciklama IN ('1', '2')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Döviz Kredileri'
                WHEN SUBSTR (referans_no, 4, 4) IN ('DKEX')
                     AND a.kaynak_aciklama = '1'
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'Eximbank_YP'
                WHEN SUBSTR (referans_no, 4, 4) IN ('DEDD', 'TTAT', 'TTIT', 'TTSA', 'TTST', 'TTFT')
                     AND a.para_kodu <> 'TL'
                     AND a.kaynak_aciklama IN ('1', '2')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'DEK'
                WHEN SUBSTR (referans_no, 4, 4) IN ('YIPO')
                     AND a.kaynak_aciklama IN ('13')
                     AND a.kaynak = 'Nakdi Risk'
                THEN 'YIPO'
                WHEN SUBSTR (a.thp_no, 1, 3) IN (910, 912)
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Teminat Mektubu TL'
                WHEN SUBSTR (a.thp_no, 1, 3) IN (911, 913)
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Teminat Mektubu YP'
                WHEN SUBSTR (a.thp_no, 1, 3) = 922
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Kabul Kredisi TL'
                WHEN SUBSTR (a.thp_no, 1, 3) = 923
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Kabul Kredisi YP'
                WHEN SUBSTR (a.thp_no, 1, 3) = 932
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Akreditif TL'
                WHEN SUBSTR (a.thp_no, 1, 3) = 962
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Dið.Gar.&Kef TL'
                WHEN SUBSTR (a.thp_no, 1, 3) IN (963, 961)
                     AND a.kaynak = 'GNakdi Risk'
                THEN 'Dið.Gar.&Kef YP'
                WHEN a.thp_no in ('1194110','1192110','1184110','1184103','1182110','1182106','1182105','1182104','1182103','1182101',
                                  '1174110','1172110','1172106','1164110','1164107','1164106','1164105','1164104','1164103','1164101',
                                  '1162110','1162107','1162106','1162105','1162104','1162103','1162101','1162100')
                THEN 'Bireysel Kredi Kartlarý'
                WHEN a.thp_no in ('1193110','1183110','1183104','1183103','1173110','1163110','1163106','1163105','1163104','1163103','1163101')
                THEN 'Kurumsal Kredi Kartlarý'
           END;
COMMIT;

    v_line_no := $$PLSQL_LINE;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_MUS_RSK_DTY_ALT_SRG
    --bankalar suna manuel ekledikleri mizanla tutuyor
    SELECT a.tarih as kst_trh,
           b.clsm_skl,
           a.thp_no,
           a.musteri as mus_no,
           CASE
               WHEN SUBSTR (referans_no, 4, 4) IN ('YIPO')
                    AND a.kaynak_aciklama IN ('13')
                    AND a.thp_no IN ('1260011', '1260021', '1260051')
               THEN 'DEK'
               WHEN SUBSTR (referans_no, 4, 4) IN ('YIPO')
                    AND a.kaynak_aciklama IN ('13')
                    AND a.thp_no IN ('1260010', '1260020', '1260050')
               THEN 'Spot'
               ELSE 'Döviz Kredileri_x'
           END
               AS krd_grp,
           SUM (a.risk_tutari_tl_karsilik) tutar,
           'K-2' as kynk,
           sysdate as etl_trh,
           v_sp_name as etl_jo
      FROM ofsdata.MUSTERI_RISK_DETAY_HIST a,
           trfm.TMP_MUS_DTY b
     WHERE a.musteri = b.mus_no
           AND SUBSTR (referans_no, 4, 4) IN ('YIPO')
           AND b.clsm_skl IN (2, 3, 4, 5)
           and a.tarih = v_tarih
           and  a.musteri<>1760030
  GROUP BY a.tarih,
           b.clsm_skl,
           a.thp_no,
           a.musteri,
           CASE
               WHEN SUBSTR (a.referans_no, 4, 4) IN ('YIPO')
                    AND a.kaynak_aciklama IN ('13')
                    AND a.thp_no IN ('1260011', '1260021', '1260051')
               THEN 'DEK'
               WHEN SUBSTR (a.referans_no, 4, 4) IN ('YIPO')
                    AND a.kaynak_aciklama IN ('13')
                    AND a.thp_no IN ('1260010', '1260020', '1260050')
               THEN 'Spot'
               ELSE 'Döviz Kredileri_x'
           END;
    COMMIT;

    v_line_no := $$PLSQL_LINE;

        INSERT                                  /*+ APPEND */ INTO TRFM.TMP_MUS_RSK_DTY_ALT_SRG
        SELECT a.tarih as kst_trh,
               b.clsm_skl,
               TO_NUMBER(ana || LPAD (alt, 2, 0) || tali1 || tali2) as thp_no,
               a.ilk7 as mus_no,
               CASE WHEN ana = 980 THEN 'Bloke Çek TL'
                    WHEN ana = 981 THEN 'Bloke Çek YP'
                    WHEN ana IN (931,933) THEN 'Akreditif YP'
               END AS krd_grp,
               SUM ( CASE WHEN ana in (980,981) THEN ((a.borc - a.alac) * k.d_alis/k.katsayi)*(-1)
                          ELSE ((a.borc - a.alac) * k.d_alis/k.katsayi)
                      END
                   ) as tutar,
               'K-3' as kynk,
               sysdate as etl_trh,
               v_sp_name as etl_job
          FROM --extr.FS_GUNLUK_HPLANDET_SG a
               (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                  FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                 WHERE 1=1
                       AND gnc.tarih = v_tarih
               UNION ALL
                SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
                  FROM TRFM.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                 WHERE ars.tarih = v_tarih
               ) a,
               trfm.TMP_MUS_DTY b,
               extr.FS_FDOVIZ k
         WHERE a.borc - a.alac <> 0
               AND a.para = k.para
               AND k.kurtipi = 1
               AND k.tarih =v_tarih
               AND (a.Ana IN (933, 931)
                    OR (a.Ana IN (980, 981) AND a.Alt=3 AND a.Tali1=0 AND a.Tali2=0))
               and a.ilk7 = b.mus_no
               and a.sube<900 and a.sinif='C'
               AND a.ana IN (980, 981, 931)
               and a.tarih =v_tarih
               and  a.ilk7<>1760030
      GROUP BY a.tarih,
               b.clsm_skl,
               TO_NUMBER(ana || LPAD (alt, 2, 0) || tali1 || tali2),
               a.ilk7,
               CASE WHEN ana = 980 THEN 'Bloke Çek TL'
                    WHEN ana = 981 THEN 'Bloke Çek YP'
                    WHEN ana in (931,933) THEN 'Akreditif YP'
               END;

        COMMIT;
        v_line_no := $$PLSQL_LINE;




--NPL ORANI HESAPLAMAK ÝÇÝN DEKLERDE GUNCEL KUR OLARAKTA ALINDI
    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_MUS_RSK_DTY_ALT_SRG
    SELECT kst_trh,
           clsm_skl,
           thp_no,
           mus_no,
           'DEK_guncel_kur' AS krd_grp,
           SUM (tutar) tutar,
           'K-4' as kynk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT a.tarih as kst_trh,
                   b.clsm_skl,
                   a.thp_no,
                   a.para_kodu,
                   a.musteri as mus_no,
                   SUM ( (a.risk_tutari * f.d_alis) / f.katsayi) tutar
              FROM ofsdata.MUSTERI_RISK_DETAY_HIST a,
                   trfm.TMP_MUS_DTY b,
                   (SELECT t.kisaad, k.*
                      FROM extr.FS_FDOVIZ k,
                           extr.FS_PARA t
                     WHERE k.para = t.para
                           AND k.kurtipi = 1
                           AND k.tarih = v_tarih) f
             WHERE a.tarih = v_tarih
                   AND a.musteri = b.mus_no
                   AND b.clsm_skl IN (2, 3, 4, 5)
                   AND SUBSTR(a.referans_no, 4, 4) IN ('DEDD', 'TTAT', 'TTIT', 'TTSA', 'TTST', 'TTFT')
                   AND a.para_kodu <> 'TL'
                   AND a.kaynak_aciklama IN ('1', '2')
                   AND a.kaynak = 'Nakdi Risk'
                   AND TO_CHAR (a.para_kodu) = TO_CHAR (f.kisaad)
                   and mus_no<>1760030
          GROUP BY a.tarih,
                   b.clsm_skl,
                   a.thp_no,
                   a.para_kodu,
                   a.musteri
        UNION ALL
            SELECT a.tarih as kst_trh,
                   b.clsm_skl,
                   a.thp_no,
                   a.para_kodu,
                   a.musteri as mus_no,
                   SUM ( (a.risk_tutari * f.d_alis) / f.katsayi) tutar
              FROM ofsdata.MUSTERI_RISK_DETAY_HIST a,
                   trfm.TMP_MUS_DTY b,
                   (SELECT t.kisaad, k.*
                      FROM extr.FS_FDOVIZ k,
                           extr.FS_PARA t
                     WHERE k.para = t.para
                           AND k.kurtipi = 1
                           AND k.tarih = v_tarih) f
             WHERE a.tarih = v_tarih
                   AND a.musteri = b.mus_no
                   AND b.clsm_skl IN (2, 3, 4, 5)
                   AND SUBSTR (referans_no, 4, 4) IN ('YIPO')
                   AND a.kaynak_aciklama IN ('13')
                   AND a.thp_no IN ('1260011', '1260021', '1260051')
                   AND TO_CHAR (a.para_kodu) = TO_CHAR (f.kisaad)
                   and a.musteri<>1760030
          GROUP BY a.tarih,
                   b.clsm_skl,
                   a.thp_no,
                   a.para_kodu,
                   a.musteri
           )
  GROUP BY kst_trh,
           clsm_skl,
           thp_no,
           mus_no;
    COMMIT;
    v_line_no := $$PLSQL_LINE;


        INSERT                                  /*+ APPEND */ INTO TRFM.TMP_MUS_RSK_DTY_ALT_SRG
        SELECT a.tarih as kst_trh,
               b.clsm_skl,
               1290000 AS thp_no,
               a.ilk7 as mus_no,
               'Döviz Kredileri' as krd_grp,
               SUM ( (a.borc - a.alac) * k.d_alis) as tutar,
               'K-5' as kynk,
               sysdate as etl_date,
               v_sp_name as etl_job
          FROM --extr.FS_GUNLUK_HPLANDET_SG a,
               (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                  FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                 WHERE 1=1
                       AND gnc.tarih =v_tarih
               UNION ALL
                SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
                  FROM trfm.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                 WHERE ars.tarih = v_tarih
               ) a,
               trfm.TMP_MUS_DTY b,
               extr.FS_FDOVIZ k
         WHERE a.borc - a.alac <> 0
               and a.ana = 129
               AND a.alt = 0
               AND a.tali1 = 0
               AND a.tali2 = 0
               AND a.para = k.para
               AND k.kurtipi = 1
               AND k.tarih = v_tarih
               and a.ilk7 = b.mus_no
               and a.tarih = v_tarih
               and a.ilk7 <>1760030
      GROUP BY a.tarih, b.clsm_skl, a.ilk7;

        COMMIT;

    v_line_no := $$PLSQL_LINE;

    --EXECUTE IMMEDIATE 'TRUNCATE TABLE trfm.TMP_MUS_RSK_DTY';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_MUS_RSK_DTY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */  INTO trfm.TMP_MUS_RSK_DTY
    SELECT kst_trh,
           mus_no,

           SUM(DECODE(krd_grp, 'Teminat Mektubu TL', tutar, 0))+SUM (DECODE (krd_grp, 'Teminat Mektubu YP', tutar, 0))+
           SUM(DECODE(krd_grp, 'Akreditif TL', tutar, 0))+SUM (DECODE (krd_grp, 'Akreditif YP', tutar, 0))+
           SUM(DECODE(krd_grp, 'Kabul Kredisi TL', tutar, 0))+SUM (DECODE (krd_grp, 'Kabul Kredisi YP', tutar, 0))+
           SUM(DECODE(krd_grp, 'Dið.Gar.&Kef TL', tutar, 0))+SUM (DECODE (krd_grp, 'Dið.Gar.&Kef YP', tutar, 0))+
           SUM(DECODE(krd_grp, 'Bloke Çek TL',tutar,0))+SUM(DECODE(krd_grp,'Bloke Çek YP',tutar,0)) as cnli_gnakdi_rsk,

           SUM(DECODE(krd_grp, 'Rotatif', tutar, 0))+SUM (DECODE (krd_grp, 'Ýhracat Rotatif_Spot', tutar, 0))+
           SUM(DECODE(krd_grp, 'Eximbank_TL', tutar, 0))+SUM (DECODE (krd_grp, 'Spot', tutar, 0))+
           SUM(DECODE(krd_grp, 'Nakit Yön.Kre.', tutar, 0))+SUM (DECODE (krd_grp, 'Overnight', tutar, 0))+
           SUM(DECODE(krd_grp, 'Senet-Ýskonto', tutar, 0))+SUM (DECODE (krd_grp, 'Taksitli Ticari', tutar, 0))+
           SUM(DECODE(krd_grp, 'KMH', tutar, 0))+SUM (DECODE (krd_grp, 'Döviz Kredileri', tutar, 0))+
           SUM(DECODE(krd_grp, 'Eximbank_YP', tutar, 0))+SUM (DECODE (krd_grp, 'DEK', tutar, 0))+
           SUM(DECODE(krd_grp, 'Kurumsal Kredi Kartlarý', tutar, 0)) as cnli_nkt_rsk,

           SUM(DECODE(krd_grp, 'Rotatif', tutar, 0))+SUM (DECODE (krd_grp, 'Ýhracat Rotatif_Spot', tutar, 0))+
           SUM(DECODE(krd_grp, 'Eximbank_TL', tutar, 0))+SUM (DECODE (krd_grp, 'Spot', tutar, 0))+
           SUM(DECODE(krd_grp, 'Nakit Yön.Kre.', tutar, 0))+SUM (DECODE (krd_grp, 'Overnight', tutar, 0))+
           SUM(DECODE(krd_grp, 'Senet-Ýskonto', tutar, 0))+SUM (DECODE (krd_grp, 'Taksitli Ticari', tutar, 0))+
           SUM(DECODE(krd_grp, 'KMH', tutar, 0))+SUM (DECODE (krd_grp, 'Döviz Kredileri', tutar, 0))+
           SUM(DECODE(krd_grp, 'Eximbank_YP', tutar, 0))+SUM (DECODE (krd_grp, 'DEK_guncel_kur', tutar, 0))+
           SUM(DECODE(krd_grp, 'Kurumsal Kredi Kartlarý', tutar, 0)) as cnli_nkt_rsk_gncl_kur,

           SUM(DECODE(krd_grp, 'Rotatif', tutar, 0)) AS rttf,
           SUM(DECODE(krd_grp, 'Ýhracat Rotatif_Spot', tutar, 0)) AS ihr_rttf_spot,
           SUM(DECODE(krd_grp, 'Eximbank_TL', tutar, 0)) AS ebnk_tl,
           SUM(DECODE(krd_grp, 'Spot', tutar, 0)) AS spot,
           SUM(DECODE(krd_grp, 'Nakit Yön.Kre.', tutar, 0)) AS nkt_yntm,
           SUM(DECODE(krd_grp, 'Overnight', tutar, 0)) AS ovngt,
           SUM(DECODE(krd_grp, 'Senet-Ýskonto', tutar, 0)) AS senet_isknt,
           SUM(DECODE(krd_grp, 'Taksitli Ticari', tutar, 0)) AS tkst_tcr,
           SUM(DECODE(krd_grp, 'KMH', tutar, 0)) AS kmh,
           SUM(DECODE(krd_grp, 'Döviz Kredileri', tutar, 0)) AS dvz_krd,
           SUM(DECODE(krd_grp, 'Eximbank_YP', tutar, 0)) AS ebnk_yp,
           SUM(DECODE(krd_grp, 'DEK', tutar, 0)) AS dvz_endks_krd,
           SUM(DECODE(krd_grp, 'Teminat Mektubu TL', tutar, 0)) AS tmnt_mktp_tl,
           SUM(DECODE(krd_grp, 'Teminat Mektubu YP', tutar, 0)) AS tmnt_mktp_yp,
           SUM(DECODE(krd_grp, 'Akreditif TL', tutar, 0)) AS akrdtf_tl,
           SUM(DECODE(krd_grp, 'Akreditif YP', tutar, 0)) AS akrdtf_yp,
           SUM(DECODE(krd_grp, 'Kabul Kredisi TL', tutar, 0)) AS kbl_krd_tl,
           SUM(DECODE(krd_grp, 'Kabul Kredisi YP', tutar, 0)) AS kbl_krd_yp,
           SUM(DECODE(krd_grp, 'Dið.Gar.&Kef TL', tutar, 0)) AS diger_grntr_kflt_tl,
           SUM(DECODE(krd_grp, 'Dið.Gar.&Kef YP', tutar, 0)) AS diger_grntr_kflt_yp,
           SUM(DECODE(krd_grp, 'Bloke Çek TL', tutar, 0)) AS blk_cek_tl,
           SUM(DECODE(krd_grp, 'Bloke Çek YP', tutar, 0)) AS blk_cek_yp,
           SUM(DECODE(krd_grp, 'Bireysel Kredi Kartlarý', tutar, 0)) AS brysl_kkr,
           SUM(DECODE(krd_grp, 'Kurumsal Kredi Kartlarý', tutar, 0)) AS krmsl_kkr,
           SUM(DECODE(krd_grp, 'YIPO', tutar, 0)) AS yipo,
           SUM(DECODE(krd_grp, 'DEK_guncel_kur', tutar, 0)) AS dvz_endks_krd_gncl_kur,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM trfm.TMP_MUS_RSK_DTY_ALT_SRG
      where
      1=1
      and mus_no <>1760030
  GROUP BY kst_trh,mus_no;

    COMMIT;

    v_line_no := $$PLSQL_LINE;
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GNAKDI_TKP',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO trfm.TMP_GNAKDI_TKP
    SELECT tarih as trh, musteri as mus_no,
           SUM(CASE WHEN thp not in ('9771102','9771112','9771114','9771115','9800600')
                    THEN gnakitrisk_tl * ( - 1) ELSE 0 END) as npl_gnakdi_rsk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM ofsdata.TEKLIF_21183_RPR
     WHERE tarih=v_tarih
     and musteri<>1760030
  GROUP BY tarih,musteri;
    COMMIT;



    v_line_no := $$PLSQL_LINE;
    --DELETE FROM TRFM.TMP_TKP_KARSLK_HSP WHERE kst_trh = v_tarih;
    --COMMIT;

    v_partition_name := 'P_' || SUBSTR(TO_CHAR(v_tarih,'YYYYMMDD'),1,8);
    TRFM.PKG_TRFM_UTIL_LIB.prc_utl_object ('TMP_TKP_KARSLK_HSP',v_partition_name,NULL,'tp',v_sqlcode,v_sqlcodeexp);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;


    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKP_KARSLK_HSP
     SELECT v_tarih as kst_trh,
            md.mus_no as mus_no,
            trunc(b.tkp_acls_trh) as tkp_acls_trh,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=170 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_170,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=172 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_172,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=174 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_174,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=176 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_176,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_nkt_rsk,
            SUM(CASE WHEN SUBSTR(t.skont,1,3) in (158,159) and a.sube<900 THEN (a.alac-a.borc)*(-1)else 0 END) as thp_158_159,
            SUM(CASE WHEN SUBSTR(t.skont,1,3) in (156) and a.sube<900  THEN (a.alac-a.borc)*(-1) ELSE 0 END) as thp_156,
            SUM(CASE WHEN (a.ana=980 and a.alt=6 and a.tali1=0 and (a.tali2 in (0,1))) and a.sube<900  THEN (alac-borc) ELSE 0 END) as cek_thht,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=18 and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END) as bddk_nkt_karslk,
            SUM(CASE WHEN (a.ana=350 and a.alt =9 and a.tali1=0 and a.tali2=0 ) and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END) as bddk_gnakdi_karslk,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=18 and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END)+
            SUM(CASE WHEN (a.ana=350 and a.alt =9 and a.tali1=0 and a.tali2=0 ) and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END) as bddk_tplm_karslk,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tcr_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Taþýt' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tkst_arac_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Ýþyeri' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tkst_isyr_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Diðer' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tkst_diger_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Kredi Kartý' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_kkr,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal KMH' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_ovngt,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Çek Taahhüdü' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_gnakdi,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Diðer Ticari-Kurumsal' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_diger,
            v_sp_name as etl_job,
            sysdate as etl_trh
       FROM trfm.TMP_MUS_DTY md
            LEFT JOIN (
                         SELECT mus_no, min(tkp_acls_trh) as tkp_acls_trh
                           FROM (
                                  SELECT ilk7 mus_no,
                                         MIN (actarih) tkp_acls_trh
                                    FROM extr.FS_DUNPLDET_SG
                                   WHERE 1 = 1
                                     AND ana IN (170, 172, 174, 176, 350)
                                     AND ilk7 NOT IN (  SELECT DISTINCT ilk7
                                                          FROM extr.FS_DUNPLDET_SG
                                                         WHERE ana IN (170, 172, 174, 176, 350)
                                                           and sube >= 900
                                                     )
                                GROUP BY ilk7
                               UNION
                                  SELECT ilk7 mus_no,
                                         MIN (actarih) tkp_acls_trh
                                    FROM extr.FS_ESKIPLAN_SG
                                   WHERE 1 = 1
                                     AND ana IN (170, 172, 174, 176, 350)
                                     AND ilk7 NOT IN (  SELECT DISTINCT ilk7
                                                          FROM extr.FS_ESKIPLAN_SG
                                                         WHERE ana IN (170, 172, 174, 176, 350)
                                                           and sube >= 900
                                                     )
                                GROUP BY ilk7
                                )
                         GROUP BY mus_no
                        ) b ON MD.MUS_NO = B.MUS_NO
            LEFT JOIN (SELECT hp.ilk7 as mus_no, hp.tarih, hp.ana, hp.alt, hp.tali1, hp.tali2, hp.sube, hp.alac, hp.borc
                         FROM --extr.FS_GUNLUK_HPLANDET_SG hp,
                              (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                                 FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                                WHERE 1=1
                                      AND gnc.tarih =v_tarih
                                      AND gnc.ana in (170,172,174,176,116,118,158,156,980,180,350)
                              UNION ALL
                               SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
                                 FROM trfm.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                                WHERE ars.tarih = v_tarih
                                      and ars.ana in (170,172,174,176,116,118,158,156,980,180,350)
                              ) hp
                      ) a ON a.mus_no=md.mus_no
--                          AND a.ana in (170,172,174,176,116,118,158,156,980,180,350)
            LEFT JOIN trfm.TMP_NPL_THP2 t --temp tablo excel dosyasindan dolmaktadir.
                      ON TO_NUMBER (a.ana || LPAD (a.alt, 2, 0) || a.tali1 || a.tali2) = t.skont
      WHERE 1=1
      and  md.mus_no<>1760030
   GROUP BY md.mus_no,trunc(b.tkp_acls_trh);
                                                                 /*SELECT  v_tarih as kst_trh,
            NVL(a.mus_no,b.mus_no) as mus_no,
            trunc(b.tkp_acls_trh) as tkp_acls_trh,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=170 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_170,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=172 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_172,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=174 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_174,
            SUM(CASE WHEN SUBSTR(t.skont,1,3)=176 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1)else 0 END) as thp_176,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.aciklama in ('Diðer Ticari-Kurumsal','Ticari-Kurumsal','Çek Taahhüdü') and a.sube<900
                     THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_nkt_rsk,
            SUM(CASE WHEN SUBSTR(t.skont,1,3) in (158,159) and a.sube<900 THEN (a.alac-a.borc)*(-1)else 0 END) as thp_158_159,
            SUM(CASE WHEN SUBSTR(t.skont,1,3) in (156) and a.sube<900  THEN (a.alac-a.borc)*(-1) ELSE 0 END) as thp_156,
            SUM(CASE WHEN (a.ana=980 and a.alt=6 and a.tali1=0 and (a.tali2 in (0,1))) and a.sube<900  THEN (alac-borc) ELSE 0 END) as cek_thht,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=18 and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END) as bddk_nkt_karslk,
            SUM(CASE WHEN (a.ana=350 and a.alt =9 and a.tali1=0 and a.tali2=0 ) and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END) as bddk_gnakdi_karslk,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=18 and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END)+
            SUM(CASE WHEN (a.ana=350 and a.alt =9 and a.tali1=0 and a.tali2=0 ) and a.sube<900 THEN (a.alac-a.borc) ELSE 0 END) as bddk_tplm_karslk,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tcr_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Taþýt' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tkst_arac_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Ýþyeri' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tkst_isyr_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Diðer' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_tkst_diger_krd,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal Kredi Kartý' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_kkr,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Ticari-Kurumsal KMH' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_ovngt,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Çek Taahhüdü' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_gnakdi,
            SUM(CASE WHEN SUBSTR(t.skont,1,2)=17 and t.detay='Diðer Ticari-Kurumsal' and a.sube<900 THEN (a.alac-a.borc)*(-1) ELSE 0 END) as npl_diger,
            v_sp_name as etl_job,
            sysdate as etl_trh
       FROM (
             SELECT mus_no, min(tkp_acls_trh) as tkp_acls_trh
               FROM (
                      SELECT ilk7 mus_no,
                             MIN (actarih) tkp_acls_trh
                        FROM extr.FS_DUNPLDET_SG
                       WHERE 1 = 1
                         AND ana IN (170, 172, 174, 176, 350)
                         AND ilk7 NOT IN (  SELECT DISTINCT ilk7
                                              FROM extr.FS_DUNPLDET_SG
                                             WHERE ana IN (170, 172, 174, 176, 350)
                                               and sube >= 900
                                         )
                    GROUP BY ilk7
                   UNION
                      SELECT ilk7 mus_no,
                             MIN (actarih) tkp_acls_trh
                        FROM extr.FS_ESKIPLAN_SG
                       WHERE 1 = 1
                         AND ana IN (170, 172, 174, 176, 350)
                         AND ilk7 NOT IN (  SELECT DISTINCT ilk7
                                              FROM extr.FS_ESKIPLAN_SG
                                             WHERE ana IN (170, 172, 174, 176, 350)
                                               and sube >= 900
                                         )
                    GROUP BY ilk7
                    )
             GROUP BY mus_no
            ) b
            FULL JOIN (SELECT hp.ilk7 as mus_no, hp.tarih, hp.ana, hp.alt, hp.tali1, hp.tali2, hp.sube, hp.alac, hp.borc
                         FROM --extr.FS_GUNLUK_HPLANDET_SG hp,
                              (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                                 FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                                WHERE 1=1
                                      AND gnc.tarih =v_tarih
                              UNION ALL
                               SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
                                 FROM trfm.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                                WHERE ars.tarih = v_tarih
                              ) hp,
                              trfm.TMP_MUS_DTY md
                        WHERE hp.ilk7 = md.mus_no
                              and hp.tarih = v_tarih
                      ) a ON a.mus_no=b.mus_no
                          AND a.ana in (170,172,174,176,116,118,158,156,980,180,350)
            LEFT JOIN trfm.TMP_NPL_THP2 t --temp tablo excel dosyasindan dolmaktadir.
                      ON TO_NUMBER (a.ana || LPAD (a.alt, 2, 0) || a.tali1 || a.tali2) = t.skont
      WHERE 1=1
   GROUP BY NVL(a.mus_no,b.mus_no),trunc(b.tkp_acls_trh);*/

    COMMIT;
    v_line_no := $$PLSQL_LINE;


    trfm.PKG_TRFM_UTIL_LIB.prc_utl_object (p_ObjectName=> 'TMP_TKP_KARSLK_HSP',
                                           p_SubObjectName=> v_partition_name,
                                           p_SubObjectName2=> NULL,
                                           p_OperationType=> 'at',
                                           p_SqlCode=> v_sqlcode,
                                           p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;

    --Paket Automic/UC4 dan çalýþtýrýldýðýnda, trfm.TMP_DIM_YAKN_GZLM_DRM_HIST tablosunun sorgusu hata alabiliyor.
    --Problemin hangi deðerden kaynaklandýðýnýn bulunmasý için private procedure oluþturulmuþtur.
  --  PKG_PORTFOY_RAPORU.SF_NLS_DEGERLERINI_OUTPUTA_YAZ; --problem bulundu artýk çalýþtýrýlmaya gerek kalmamýþtýr.
    v_line_no := $$PLSQL_LINE;

    --EXECUTE IMMEDIATE 'TRUNCATE TABLE trfm.TMP_DIM_YAKN_GZLM_DRM_HIST';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_DIM_YAKN_GZLM_DRM_HIST',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO  trfm.TMP_DIM_YAKN_GZLM_DRM_HIST
    SELECT  v_tarih kst_trh,
            m.mus_no,
            CASE WHEN zzz.tkp_bky>0 and TO_NUMBER(NVL(m.yakn_gzlm_drm,0))<5 THEN 5
                 ELSE TO_NUMBER(NVL(m.yakn_gzlm_drm,0))
            END as yakn_gzlm_drm,
            CASE WHEN z.tkp_bky>0 and TO_NUMBER(NVL(k.onck_yakn_gzlm_drm,0))<5 THEN 5
                 ELSE TO_NUMBER(NVL(k.onck_yakn_gzlm_drm,0))
            END as onck_yakn_gzlm_drm,
            CASE WHEN zz.tkp_bky>0 and TO_NUMBER(NVL(t.onck_ay_yakn_gzlm_drm,0))<5 THEN 5
                 ELSE TO_NUMBER(NVL(t.onck_ay_yakn_gzlm_drm,0))
            END as onck_ay_yakn_gzlm_drm,
            m.grid_no,m.ing_rtg_1,m.ing_rtg_2,m.ing_rtg_3,
            m.krnotu,m.gnclm_trh, r1.rtg_dgr||r2.rtg_dgr||TO_CHAR(m.ing_rtg_3) as rtg,
            m.ytk_svy,
            g.aciklama as ytk_svy_acklm,
            NVL(y.onck_15_gun_yakn_gzlm_drm,0) as onck_15_gun_yakn_gzlm_drm,
            v_sp_name as etl_job,
            SYSDATE as etl_trh,
            NVL(d.onck_90_gun_yakn_gzlm_drm,0) as onck_90_gun_yakn_gzlm_drm
      FROM  (SELECT a.musteri_no as mus_no,
                    decode(a.yakin_gozlem_statu,'A',null,a.yakin_gozlem_statu) as yakn_gzlm_drm, --yakin_gozlem_statu kirli data yüzünden decode edildi. 21.04.215.
                    a.grid_no,
                    a.ing_rating1 as ing_rtg_1,
                    a.ing_rating2 as ing_rtg_2,
                    a.ing_rating3 as ing_rtg_3,
                    a.kredibilite_notu as krnotu,
                    a.gunceleme_tarihi as gnclm_trh,
                    a.yetki_seviyesi as ytk_svy
               FROM extr.FS_MUSTERI_STATU_TX a
              WHERE (a.musteri_no,a.islem_sira_no) IN ( SELECT i.musteri_no, MAX(i.islem_sira_no) as islem_sira_no
                                                          FROM extr.FS_MUSTERI_STATU_TX i
                                                         WHERE i.gunceleme_tarihi <= v_tarih
                                                      GROUP BY i.musteri_no)
            ) m,
            (SELECT DISTINCT g1.musteri_no as mus_no,
                    MAX(decode(g1.yakin_gozlem_statu,'A',null,g1.yakin_gozlem_statu))
                        KEEP (DENSE_RANK FIRST ORDER BY g1.islem_sira_no desc) OVER (PARTITION BY g1.musteri_no) as onck_yakn_gzlm_drm
               FROM extr.FS_MUSTERI_STATU_TX g1
              WHERE g1.gunceleme_tarihi <=TO_DATE (v_tarih,'dd/mm/yyyy')-1
            ) k,
            (SELECT DISTINCT m1.musteri_no as mus_no,
                    MAX(decode(m1.yakin_gozlem_statu,'A',null,m1.yakin_gozlem_statu))
                        KEEP (DENSE_RANK FIRST ORDER BY m1.islem_sira_no desc) OVER (PARTITION BY m1.musteri_no) onck_ay_yakn_gzlm_drm
               FROM extr.FS_MUSTERI_STATU_TX m1
              WHERE m1.gunceleme_tarihi <=trunc(TO_DATE(v_tarih,'dd/mm/yyyy'),'MM')-1
            ) t,
            (SELECT DISTINCT g15.musteri_no as mus_no,
                    MAX(DECODE(g15.yakin_gozlem_statu,'A',null,g15.yakin_gozlem_statu))
                        KEEP (DENSE_RANK FIRST ORDER BY g15.islem_sira_no desc) OVER (PARTITION BY g15.musteri_no) onck_15_gun_yakn_gzlm_drm
               FROM extr.FS_MUSTERI_STATU_TX g15
              WHERE g15.gunceleme_tarihi <=TO_DATE (v_tarih,'dd/mm/yyyy')-15
            ) y,
            (SELECT DISTINCT g90.musteri_no as mus_no,
                    MAX(DECODE(g90.yakin_gozlem_statu,'A',null,g90.yakin_gozlem_statu))
                        KEEP (DENSE_RANK FIRST ORDER BY g90.islem_sira_no desc) OVER (PARTITION BY g90.musteri_no) onck_90_gun_yakn_gzlm_drm
               FROM extr.FS_MUSTERI_STATU_TX g90
              WHERE g90.gunceleme_tarihi <=TO_DATE (v_tarih,'dd/mm/yyyy')-90
            ) d,
            (SELECT tg1.mus_no,tg1.thp_170+tg1.thp_172+tg1.thp_174+tg1.thp_176+tg1.bddk_gnakdi_karslk as tkp_bky
               FROM trfm.TMP_TKP_KARSLK_HSP tg1
              WHERE tg1.kst_trh=to_date (v_tarih,'dd/mm/yyyy')-1
            ) z,
            (SELECT ta1.mus_no,ta1.thp_170+ta1.thp_172+ta1.thp_174+ta1.thp_176+ta1.bddk_gnakdi_karslk as tkp_bky
               FROM trfm.TMP_TKP_KARSLK_HSP ta1
              WHERE ta1.kst_trh=trunc(TO_DATE(v_tarih,'dd/mm/yyyy'),'MM')-1
            ) zz,
            (SELECT t1.mus_no,t1.thp_170+t1.thp_172+t1.thp_174+t1.thp_176+t1.bddk_gnakdi_karslk as tkp_bky
               FROM trfm.TMP_TKP_KARSLK_HSP t1
              WHERE t1.kst_trh=TO_DATE(v_tarih,'dd/mm/yyyy')
            ) zzz,
            trfm.TMP_RFRNS_RTG r1,
            trfm.TMP_RFRNS_RTG r2,
            extr.FS_YETKI_DUZEYI g
     WHERE  1=1
            AND m.mus_no = k.mus_no(+)
            AND m.mus_no = y.mus_no(+)
            AND m.mus_no = d.mus_no(+)
            AND k.mus_no = z.mus_no(+)
            AND t.mus_no = zz.mus_no(+)
            AND m.mus_no = zzz.mus_no(+)
            AND m.mus_no = t.mus_no(+)
            and m.ing_rtg_1 = r1.ing_rtg_kod(+)
            and m.ing_rtg_2 = r2.ing_rtg_kod(+)
            AND m.ytk_svy= g.kod(+)
            and m.mus_no<>1760030;

    COMMIT;
    v_line_no := $$PLSQL_LINE;


    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_EN_SON_YPLNDRM_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_EN_SON_YPLNDRM_TRH
    SELECT tarih as trh,
           musteri_no as mus_no,
           MAX(yplndrm_trh) as en_son_yplndrm_trh,
           sysdate as etl_trh,
           v_sp_name as etl_job,
           MIN(yplndrm_trh) AS ilk_yplndrm_trh
      FROM (SELECT v_tarih AS tarih, a.musteri_no,
                   CASE WHEN lag (a.yakin_gozlem_statu,1) OVER (ORDER BY a.musteri_no, a.islem_sira_no)<>'4' AND a.yakin_gozlem_statu='4'
                        THEN a.gunceleme_tarihi END AS yplndrm_trh
              FROM extr.FS_MUSTERI_STATU_TX a
             WHERE a.gunceleme_tarihi<=v_tarih
             and a.musteri_no<>1760030
           )
  GROUP BY musteri_no, tarih;
    COMMIT;
    v_line_no := $$PLSQL_LINE;

---------------------------------------Yelizden gelen kod burada kullanýldý-------------------------------------Baþlangýç

    --gnakit kredi ilk kullandýrýmlarýný bulmak için yazýldý, 09/2015, yeliz
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GNAKDI_ILK_KLNDRM_1',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    --gnakit kredisi olan müþteriler bulunur
    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_GNAKDI_ILK_KLNDRM_1
    SELECT t.ilk7 as mus_no,
           min(trunc(t.actarih)) as gnakdi_acls_trh,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (
           SELECT d.ilk7,trunc(d.actarih) AS actarih
             FROM extr.FS_DUNPLDET_SG d
            WHERE 1=1
                  AND d.ana in (350,910,911,912,913,922,923,932,962,963,961,980)
           UNION
            SELECT e.ilk7,trunc(e.actarih) AS actarih
              FROM extr.FS_ESKIPLAN_SG e
             WHERE 1=1
                   AND e.ana in (350,910,911,912,913,922,923,932,962,963,961,980)
           ) t,
           trfm.TMP_MUS_DTY md
     WHERE 1=1
           --AND t.ana in (350,910,911,912,913,922,923,932,962,963,961,980)
           and t.ilk7 = md.mus_no
           and t.ilk7<>1760030
  GROUP BY ilk7;
    COMMIT;
    v_line_no := $$PLSQL_LINE;

    --son aydaki hareketlerden min tutar ve tarih bilgileri bulunur, ilk kez çalýþtýrýldýðýnda geriye dönük arþivden veri dolduruldu
    --delete insert olacak
    DELETE FROM TRFM.TMP_GNAKDI_ILK_KLNDRM_2 WHERE islm_trh BETWEEN trunc(v_tarih,'mm') and v_tarih;
    v_line_no := $$PLSQL_LINE;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_GNAKDI_ILK_KLNDRM_2
    SELECT h.ilk7 as mus_no,
           min(fistarih) as islm_trh,
           min(tutar) KEEP (DENSE_RANK FIRST ORDER BY fistarih,fiszaman) as tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM extr.FS_HRKTDET_SG h,
           trfm.TMP_GNAKDI_ILK_KLNDRM_1 t
     WHERE 1=1
           and h.ilk7=t.mus_no
           and h.fistarih between trunc(v_tarih,'mm') and v_tarih
           and SUBSTR(kmhtutar,1,3) IN (350,910,911,912,913,922,923,932,962,963,961,980)
           and h.ilk7<>1760030
  GROUP BY h.ilk7;
    COMMIT;
    v_line_no := $$PLSQL_LINE;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GNAKDI_ILK_KLNDRM_3',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    --aylýk dolan verilerden ilk tarih ve tutar bilgisi bulunur
    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_GNAKDI_ILK_KLNDRM_3
    SELECT mus_no,
           MIN (islm_trh) as islm_trh,
           MIN (tutar) KEEP (DENSE_RANK FIRST ORDER BY islm_trh) as tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM trfm.tmp_gnakdi_ilk_klndrm_2
      where
     mus_no<>1760030
  GROUP BY mus_no;
  COMMIT;
  --gnakit ilk kullandýrým bitiþ
    v_line_no := $$PLSQL_LINE;


    --nakit kredi ilk kullandýrýmlarýný bulmak için yazýldý, 09/2015, yeliz

    --nakit kredi içinde sayýlan kmh ilk kullandýrýmlarý hareket kayýtlarý aylýk olarak bulunur, ara tabloda biriktirilir
    DELETE FROM TRFM.TMP_KMH_ILK_KLNDRM_1 WHERE islm_trh BETWEEN trunc(v_tarih,'mm') and v_tarih;
    v_line_no := $$PLSQL_LINE;
    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_KMH_ILK_KLNDRM_1
    SELECT ilk7 as mus_no, min(fistarih) as islm_trh,
          min(tutar) KEEP (DENSE_RANK FIRST ORDER BY fistarih,fiszaman) as tutar,
          sysdate as etl_trh,
          v_sp_name as  etl_job
     FROM extr.FS_HRKTDET_SG
    WHERE fistarih BETWEEN  trunc(v_tarih,'mm') and v_tarih
      AND kmhtutar IN ('1164210','1184210','1164201','1184201')
      and ilk7<>1760030
 GROUP BY ilk7;
    COMMIT;
    v_line_no := $$PLSQL_LINE;

    --kmh aylýk kayýtlarýndan ilk kullandýýrmlar bulunur
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_KMH_ILK_KLNDRM_2',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_KMH_ILK_KLNDRM_2
   SELECT mus_no,
          min(islm_trh) as islm_trh,
          min(tutar) KEEP (DENSE_RANK FIRST ORDER BY islm_trh) as tutar,
          sysdate as etl_trh,
          v_sp_name as  etl_job
     FROM trfm.TMP_KMH_ILK_KLNDRM_1
     where  mus_no<>1760030
 GROUP BY mus_no;
     COMMIT;
    v_line_no := $$PLSQL_LINE;


    --kmh ve tkrd nkrd(esp) hepsi toplanarak nakdi kredi kullandýrým tarih ve tutarlarý bulunur
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_ILK_KLNDRM_1',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_ILK_KLNDRM_1
   SELECT prim_cst_nmr as mus_no,eff_dt as islm_trh,SUM(alct_loan_amt) as tutar,
          sysdate as etl_trh,
          v_sp_name as etl_job
     FROM (
            SELECT a.prim_cst_nmr,a.eff_dt,b.alct_loan_amt,'NKRD' as kynk
              FROM esp.AR a,ESP.CMRCL_LOC_AR b
             WHERE ar_tp_id =10 and a.ar_id=b.ar_id and a.eff_dt>=TO_DATE('01/01/1901','dd/mm/yyyy') --and  a.prim_cst_nmr=12315619
          UNION ALL
            SELECT a.prim_cst_nmr,a.eff_dt,b.LOAN_AMT,'TKRD' as kynk
              FROM esp.AR a,esp.CMRCL_LOAN_AR b
             WHERE ar_tp_id =9 and a.ar_id=b.ar_id and a.eff_dt>=TO_DATE('01/01/1901','dd/mm/yyyy') --and  a.prim_cst_nmr=12315619
          UNION ALL
            SELECT mus_no, islm_trh, tutar,'KMH' as kynk FROM trfm.TMP_KMH_ILK_KLNDRM_2
          )
          where prim_cst_nmr<>1760030
GROUP BY prim_cst_nmr,eff_dt;

    COMMIT;
    v_line_no := $$PLSQL_LINE;
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_ILK_KLNDRM_2',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

   INSERT                                  /*+ APPEND */ INTO TRFM.TMP_ILK_KLNDRM_2
   SELECT mus_no as musteri,
          trunc(min(islm_trh)) ilk_kull_tarih,
          min(tutar) KEEP (DENSE_RANK FIRST ORDER BY islm_trh,tutar desc) as ilk_kull_tutar,
          sysdate as etl_trh,
          v_sp_name as etl_job
     FROM TRFM.TMP_ILK_KLNDRM_1
     where mus_no<>1760030
 GROUP BY mus_no;

    commit;
    v_line_no := $$PLSQL_LINE;

    --takip açýlýþ tarihlerini bulmak için yazýldý, 09/2015, yeliz
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TKP_ACLS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

   INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKP_ACLS_TRH
   SELECT ilk7 as mus_no,
          trunc(min(CASE WHEN ana in (170,172,174,176) THEN actarih END)) as tkp_acls_trh_170,
          trunc(min(CASE WHEN ana=350 THEN actarih END)) as tkp_acls_trh_350,
          sysdate as etl_trh,
          v_sp_name as etl_job
     FROM (SELECT ilk7,ana,trunc(actarih) as actarih
             FROM extr.FS_DUNPLDET_SG
            WHERE 1=1
                  and ana in (170,172,174,176,350)
                  and ilk7 NOT IN (SELECT DISTINCT a.ilk7
                                     FROM extr.FS_DUNPLDET_SG a
                                    WHERE ana in (170,172,174,176,350)
                                          and a.sube>=900)
          UNION
          SELECT ilk7,ana,trunc(actarih) as actarih
             FROM extr.FS_ESKIPLAN_SG
            WHERE 1=1
                  and ana in (170,172,174,176,350)
                  and ilk7 NOT IN (SELECT DISTINCT a.ilk7
                                     FROM extr.FS_ESKIPLAN_SG a
                                    WHERE ana in (170,172,174,176,350)
                                          and a.sube>=900)
          ) t
          --INNER JOIN trfm.TMP_MUS_DTY md ON t.ilk7=md.mus_no      --01.08.2016 tarihinde IRB projesinde kullanýlabilmesi için, müþteri seti kýsýtý kaldýrýldý.
          where ilk7<>1760030
 GROUP BY ilk7;
    COMMIT;
    v_line_no := $$PLSQL_LINE;


    DELETE FROM TRFM.TMP_TKP_ACLS_TRH_350_GNAKDI WHERE tkp_acls_trh_350=v_tarih;
    v_line_no := $$PLSQL_LINE;


    MERGE INTO trfm.TMP_TKP_ACLS_TRH_350_GNAKDI c
    USING (    SELECT t.mus_no,
                      t.tkp_acls_trh_350,
                      SUM(CASE WHEN ana=350 THEN hp.alac-hp.borc ELSE 0 END) as tkp_acls_tutar_350,
                      SUM(CASE WHEN hp.ana IN (910,911,912,913,922,923,932,962,963,961) THEN hp.borc ELSE hp.alac END) as tkp_acls_tutar_gnakdi,
                      sysdate as etl_trh,
                      v_sp_name as etl_job
                 FROM trfm.TMP_TKP_ACLS_TRH t,
                      --extr.FS_GUNLUK_HPLANDET_SG hp
                      (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                         FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                        WHERE 1=1
                              AND gnc.tarih =v_tarih
                      UNION ALL
                       SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
                         FROM TRFM.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                        WHERE ars.tarih = v_tarih
                      ) hp
                WHERE 1=1
                      and t.mus_no = hp.ilk7
                      and hp.tarih = t.tkp_acls_trh_350
                      and ana in (350,910,911,912,913,922,923,932,962,963,961,980)
                      and hp.tarih = v_tarih
                      and t.mus_no<>1760030
            GROUP BY t.mus_no,t.tkp_acls_trh_350
          ) d
    ON (c.mus_no=d.mus_no)
    WHEN MATCHED THEN
      UPDATE
         SET  c.tkp_acls_trh_350 =d.tkp_acls_trh_350,
              c.tkp_acls_tutar_350 =d.tkp_acls_tutar_350,
              c.tkp_acls_tutar_gnakdi = d.tkp_acls_tutar_gnakdi,
              c.etl_trh = sysdate,
              c.etl_job = 'UPDATED'
    WHEN NOT MATCHED THEN
      INSERT (c.mus_no,
              c.tkp_acls_trh_350,
              c.tkp_acls_tutar_350,
              c.tkp_acls_tutar_gnakdi,
              c.etl_trh,
              c.etl_job)
      VALUES
            (
              d.mus_no,
              d.tkp_acls_trh_350,
              d.tkp_acls_tutar_350,
              d.tkp_acls_tutar_gnakdi,
              sysdate,
              v_sp_name
            );

    COMMIT;
    v_line_no := $$PLSQL_LINE;



    DELETE FROM TRFM.TMP_TKP_ACLS_TRH_170_180 WHERE tkp_acls_trh_170=v_tarih;
    v_line_no := $$PLSQL_LINE;

       INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKP_ACLS_TRH_170_180
       SELECT t.mus_no, t.tkp_acls_trh_170,
              --SUM(hp.borc)*-1 as tkp_acls_tutar_170,     --THEN hp.alac-hp.borc => borc*-1
              SUM(CASE WHEN substr (hp.ana,1,2)=17 THEN hp.borc*-1 ELSE 0 END) as tkp_acls_tutar_170, ----yeni
              SUM(CASE WHEN hp.ana=180 THEN hp.alac-hp.borc ELSE 0 END) as tkp_acls_tutar_180,
              sysdate as etl_trh,
              v_sp_name as etl_job
         FROM trfm.TMP_TKP_ACLS_TRH t,
              --extr.FS_GUNLUK_HPLANDET_SG hp,
              (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                 FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                WHERE 1=1
                      AND gnc.tarih =v_tarih
                                   UNION ALL
               SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
                 FROM TRFM.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                WHERE ars.tarih = v_tarih
              ) hp
        WHERE 1=1
              and t.mus_no = hp.ilk7
              and hp.tarih = t.tkp_acls_trh_170
              and hp.ana in (170,172,174,176,180)
              and hp.tarih = v_tarih
              and t.mus_no<>1760030
     GROUP BY t.mus_no, t.tkp_acls_trh_170;
        COMMIT;
       v_line_no := $$PLSQL_LINE;


   --günlük olarak yeniden yapýlandýrýlanlar tabloya insert edilir:
   DELETE FROM trfm.TMP_YPLNDRM_RSK_TUTAR WHERE mus_no IN (SELECT mus_no FROM TRFM.TMP_EN_SON_YPLNDRM_TRH WHERE en_son_yplndrm_trh=v_tarih);
   v_line_no := $$PLSQL_LINE;

       INSERT                                  /*+ APPEND */ INTO trfm.TMP_YPLNDRM_RSK_TUTAR
       SELECT t.mus_no, t.en_son_yplndrm_trh,
              SUM(CASE WHEN hp.ana IN (910,911,912,913,922,923,932,962,963,961,980) THEN hp.alac-hp.borc END) as yplndrm_gnakdi_rsk,
              SUM(CASE WHEN LPAD(ana,3,0) BETWEEN 100 AND 169
                       THEN hp.borc-hp.alac END) as yplndrm_nkt_rsk,
              sysdate as etl_trh,
              v_sp_name as etl_job
         FROM trfm.TMP_EN_SON_YPLNDRM_TRH t,
              --extr.FS_GUNLUK_HPLANDET_SG hp,
              (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana--, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
                 FROM extr.FS_GUNLUK_HPLANDET_SG gnc
                WHERE 1=1
                      AND gnc.tarih =v_tarih
                      AND (LPAD(gnc.ana,3,0) BETWEEN 100 AND 169 OR gnc.ana IN (910,911,912,913,922,923,932,962,963,961,980) )
              UNION ALL
               SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana--, ars.alt, ars.tali1, ars.tali2, ars.para
                 FROM TRFM.TMP_GUNLUK_HPLANDET_ESKI_SG ars
                WHERE ars.tarih = v_tarih
                      AND (LPAD(ars.ana,3,0) BETWEEN 100 AND 169 OR ars.ana IN (910,911,912,913,922,923,932,962,963,961,980) )
              ) hp
        WHERE 1=1
              and t.mus_no = hp.ilk7
              and hp.tarih = t.en_son_yplndrm_trh
              and hp.tarih = v_tarih
              and  t.mus_no<>1760030
     GROUP BY t.mus_no, t.en_son_yplndrm_trh;
        COMMIT;
        v_line_no := $$PLSQL_LINE;



---------------------------------------Yelizden gelen kod burada kullanýldý-------------------------------------Bitiþ



    --DELETE FROM  DM_INFOMAN.PORTFOY_RAPOR_GNC WHERE tarih = v_tarih; --performans sebebi ile truncate partition ile degistirildi. 31.12.2014
    --v_partition_name := 'P_' || SUBSTR(TO_CHAR(v_tarih,'YYYYMMDD'),1,8);

    --EXECUTE IMMEDIATE 'ALTER TABLE dm_infoman.TMP_PRTFY_RPR TRUNCATE PARTITION ' || v_partition_name ;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PRTFY_RPR_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;
    v_line_no := $$PLSQL_LINE;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_PRTFY_RPR_01
    SELECT  a.kst_trh,
            a.mus_no,
            a.isim_unvn,
            a.ana_sube,
            a.ana_sube_ad,
            a.bolge_ad,
            a.clsm_skl,
            a.verg_no,
            a.rsk_ktgr,
            a.tmslc_scl,
            a.tmslc_ad_soyad,
            a.brm_kod,
            a.gckme_gun_arlk,
            a.gckme_gun_adet,
            a.gckmeli_tutar,
            a.krd_sinif,
            a.grp_kod,
            a.grp_kod_acklm,
            a.clsn_adet,
            a.p,
            a.boss_drm_kod,
            a.sktr,
            a.sktr_acklm,
            a.ing_sktr,
            a.ing_sktr_acklm_tr,
            a.ing_sktr_acklm_en,
            a.bank_sktr,
            a.bank_sktr_acklm,
            a.tcmb_kod,
            TO_NUMBER(a.ing_sktr_krlm_1) AS ing_sktr_krlm_1,
            a.ing_sktr_krlm_1_acklm,
            a.sktr_grp,
            NVL(b.yakn_gzlm_drm,0) AS yakn_gzlm_drm,
            NVL(b.onck_yakn_gzlm_drm,0) AS onck_yakn_gzlm_drm,
            NVL(b.onck_ay_yakn_gzlm_drm,0) AS onck_ay_yakn_gzlm_drm,
            a.grid_no,
            b.ing_rtg_1, b.ing_rtg_2,b.ing_rtg_3,
            b.krnotu,
            b.gnclm_trh,
            g.tkp_acls_trh as tkp_acls_trh,
            NVL(SUM(g.thp_170),0) as thp_170,
            NVL(SUM(g.thp_172),0) as thp_172,
            NVL(SUM(g.thp_174),0) as thp_174,
            NVL(SUM(g.thp_176),0) as thp_176,
            NVL(SUM(g.thp_156),0) as thp_156,
            NVL(SUM(g.thp_158_159),0) as thp_158_159,
            NVL(SUM(g.cek_thht),0) as cek_thht,
            --------
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_nkt_rsk ELSE 0 END),0)+
            NVL(SUM(g.npl_nkt_rsk),0)+
            NVL(SUM(g.thp_156),0)+
            NVL(SUM(g.thp_158_159),0) as nkt_rsk,
            --------
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_gnakdi_rsk ELSE 0 END),0)+NVL(SUM(g.cek_thht),0)+
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)>4 THEN k.npl_gnakdi_rsk ELSE 0 END),0) as gnakdi_rsk,
            --------
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_nkt_rsk ELSE 0 END),0)+
            NVL(SUM(g.npl_nkt_rsk),0)+
            NVL(SUM(g.thp_156),0)+
            NVL(SUM(g.thp_158_159),0) +
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_gnakdi_rsk ELSE 0 END),0)+NVL(SUM(g.cek_thht),0)+
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)>4 THEN k.npl_gnakdi_rsk ELSE 0 END),0) as tplm_rsk,
            --------
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_nkt_rsk_gncl_kur ELSE 0 END),0) as cnli_nkt_rsk_gncl_kur,
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_nkt_rsk ELSE 0 END),0) as cnli_nkt_rsk,
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_gnakdi_rsk ELSE 0 END),0) as cnli_gnakdi_rsk,
            --------
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_nkt_rsk ELSE 0 END),0) +
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)<=4 THEN f.cnli_gnakdi_rsk ELSE 0 END),0) as tplm_cnli_rsk,
            --------
            NVL(SUM(g.npl_tcr_krd),0) as npl_tcr_krd,
            NVL(SUM(g.npl_tkst_arac_krd),0) as npl_tkst_arac_krd,
            NVL(SUM(g.npl_tkst_isyr_krd),0) as npl_tkst_isyr_krd,
            NVL(SUM(g.npl_tkst_diger_krd),0) as npl_tkst_diger_krd,
            NVL(SUM(g.npl_kkr),0) as npl_kkr,
            NVL(SUM(g.npl_ovngt),0) as npl_ovngt,
            NVL(SUM(g.npl_gnakdi),0) as npl_gnakdi,
            NVL(SUM(g.npl_diger),0) as npl_diger,
            NVL(SUM(g.bddk_nkt_karslk),0) as bddk_nkt_karslk ,
            NVL(SUM(g.bddk_gnakdi_karslk),0) as bddk_gnakdi_karslk,
            NVL(SUM(g.bddk_tplm_karslk),0) as bddk_tplm_karslk,
            b.rtg,
            NVL(SUM(t.kredi_tl+t.faiz_tl+gn_tl+t.komisyon_tl),0) as thsl_tutar,
            TO_NUMBER(TO_CHAR(a.kst_trh,'yyyymm')) as memzuc_dnm,
            b.ytk_svy,
            b.ytk_svy_acklm,
            a.grp_lmt,
            a.grp_rsk,
            a.grp_kod_1,
            a.grp_lmt_1,
            a.grp_rsk_1,
            a.grp_kod_2,
            a.grp_lmt_2,
            a.grp_rsk_2,
            a.lmt_ynlm_vade,
            a.firm_lmt,
            a.bank_ciro,
            a.bank_trh,
            a.rati_ciro,
            a.rati_trh,
            a.tmnt_yetrszlk_tutar AS tmnt_ytrsz_tutar,
            CASE WHEN v_tarih>g.tkp_acls_trh THEN v_tarih - g.tkp_acls_trh ELSE 0 END as tkp_gun_adet, --29.08.2014 tarihinde degistirildi.
            NVL(SUM(f.rttf),0) as rttf,
            NVL(SUM(f.ihr_rttf_spot),0) as ihr_rttf_spot,
            NVL(SUM(f.ebnk_tl),0) as ebnk_tl,
            NVL(SUM(f.spot),0) as spot,
            NVL(SUM(f.nkt_yntm),0) as nkt_yntm,
            NVL(SUM(f.ovngt),0) as ovngt,
            NVL(SUM(f.senet_isknt),0) as senet_isknt,
            NVL(SUM(f.tkst_tcr),0) as tkst_tcr,
            NVL(SUM(f.kmh),0) as kmh,
            NVL(SUM(f.dvz_krd),0) as dvz_krd,
            NVL(SUM(f.ebnk_yp),0) as ebnk_yp,
            NVL(SUM(f.dvz_endks_krd),0) as dvz_endks_krd,
            NVL(SUM(f.tmnt_mktp_tl),0) as tmnt_mktp_tl,
            NVL(SUM(f.tmnt_mktp_yp),0) as tmnt_mktp_yp,
            NVL(SUM(f.akrdtf_tl),0) as akrdtf_tl,
            NVL(SUM(f.akrdtf_yp),0) as akrdtf_yp,
            NVL(SUM(f.kbl_krd_tl),0) as kbl_krd_tl,
            NVL(SUM(f.kbl_krd_yp),0) as kbl_krd_yp,
            NVL(SUM(f.diger_grntr_kflt_tl),0) as diger_grntr_kflt_tl,
            NVL(SUM(f.diger_grntr_kflt_yp),0) as diger_grntr_kflt_yp,
            NVL(SUM(f.blk_cek_tl),0) as blk_cek_tl,
            NVL(SUM(f.blk_cek_yp),0) as blk_cek_yp,
            NVL(SUM(f.brysl_kkr),0) as brysl_kkr,
            NVL(SUM(f.krmsl_kkr),0) as krmsl_kkr,
            NVL(SUM(f.yipo),0) as yipo,
            NVL(SUM(f.dvz_endks_krd_gncl_kur),0) as dvz_endks_krd_gncl_kur,
            NVL(SUM(g.npl_nkt_rsk),0) as npl_nkt_rsk,
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)> 4 THEN k.npl_gnakdi_rsk ELSE 0 END),0) as npl_gnakdi_rsk,
            -------
            NVL(SUM(g.npl_nkt_rsk ),0)+
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)> 4 THEN k.npl_gnakdi_rsk ELSE 0 END),0)+
            NVL(SUM(CASE WHEN NVL(b.yakn_gzlm_drm,0)> 4 THEN g.cek_thht ELSE 0 END),0) as npl_tplm_rsk,
            -------,
            sysdate as etl_trh,
            a.krd_ynlm_vade,
            TO_CHAR(NVL(b.onck_15_gun_yakn_gzlm_drm,0)) AS onck_15_gun_yakn_gzlm_drm,
            CASE WHEN NVL(b.onck_90_gun_yakn_gzlm_drm,0) in (0,1) and NVL(b.yakn_gzlm_drm,0)=4 and NVL(b.onck_yakn_gzlm_drm,0)<4 THEN 'Y' --yapilandirma dublejump_flag
                 WHEN NVL(b.onck_90_gun_yakn_gzlm_drm,0) in (0,1) and NVL(b.yakn_gzlm_drm,0)in(5,6) and NVL(b.onck_yakn_gzlm_drm,0)<5 THEN 'T' --takip dublejump_flag
            END as DJ_F,
            a.ing_sktr_krlm_2,
            a.ing_sktr_krlm_2_acklm,
            a.ing_sktr_krlm_3,
            a.ing_sktr_krlm_3_acklm,
            a.sim_trh,
            a.sim_ciro,
            a.mus_tip,
            gi.islm_trh as gnakdi_ilk_klndrm_trh,
            gi.tutar as gnakdi_ilk_klndrm_tutar,
            ik.islm_trh as nkt_ilk_klndrm_trh,
            ik.tutar as nkt_ilk_klndrm_tutar,
            tag.tkp_acls_trh_350,
            tag.tkp_acls_tutar_350,
            tag.tkp_acls_tutar_gnakdi,
            CASE WHEN ta.tkp_acls_trh_170<=a.kst_trh THEN ta.tkp_acls_trh_170 ELSE NULL END as tkp_acls_trh_170,
            CASE WHEN ta.tkp_acls_trh_170<=a.kst_trh THEN ta.tkp_acls_tutar_170 ELSE NULL END as tkp_acls_tutar_170,
            ta.tkp_acls_tutar_180,
            yr.yplndrm_gnakdi_rsk,
            yr.yplndrm_nkt_rsk,
            TO_CHAR(NVL(b.onck_90_gun_yakn_gzlm_drm,0)) AS onck_90_gun_yakn_gzlm_drm
      FROM  trfm.TMP_MUS_DTY a
            LEFT JOIN trfm.TMP_DIM_YAKN_GZLM_DRM_HIST b ON a.mus_no=b.mus_no
            LEFT JOIN trfm.TMP_TKP_KARSLK_HSP g ON a.mus_no=g.mus_no AND g.kst_trh = v_tarih
            LEFT JOIN trfm.TMP_MUS_RSK_DTY f ON a.mus_no=f.mus_no AND f.kst_trh = v_tarih
            LEFT JOIN trfm.TMP_GNAKDI_TKP k ON a.mus_no=k.mus_no
            LEFT JOIN ofsdata.YAKIN_GOZLEM_TAHSILAT t ON a.mus_no = t.musteri_no AND t.fistarih = v_tarih
            LEFT JOIN trfm.TMP_GNAKDI_ILK_KLNDRM_3 gi ON a.mus_no = gi.mus_no
            LEFT JOIN trfm.TMP_ILK_KLNDRM_2 ik ON a.mus_no = ik.mus_no
            LEFT JOIN trfm.TMP_TKP_ACLS_TRH_350_GNAKDI tag ON a.mus_no = tag.mus_no
            LEFT JOIN trfm.TMP_TKP_ACLS_TRH_170_180 ta ON a.mus_no = ta.mus_no
            LEFT JOIN TRFM.TMP_YPLNDRM_RSK_TUTAR yr ON a.mus_no = yr.mus_no
            where
            a.mus_no<>1760030
  GROUP BY  a.kst_trh,a.mus_no,a.isim_unvn,a.ana_sube,a.ana_sube_ad,a.bolge_ad,a.clsm_skl,
            a.rsk_ktgr,a.tmslc_scl,a.tmslc_ad_soyad,a.brm_kod,a.gckme_gun_arlk,
            a.gckme_gun_adet,a.gckmeli_tutar,a.krd_sinif,a.grp_kod,a.grp_kod_acklm,
            a.clsn_adet,a.p,b.yakn_gzlm_drm,b.onck_yakn_gzlm_drm,
            b.onck_ay_yakn_gzlm_drm,a.grid_no,b.ing_rtg_1,b.ing_rtg_2,b.ing_rtg_3,
            b.krnotu,b.gnclm_trh,g.tkp_acls_trh,a.sktr,a.sktr_acklm,a.ing_sktr,
            a.ing_sktr_acklm_tr,a.ing_sktr_acklm_en,a.bank_sktr,a.bank_sktr_acklm,a.tcmb_kod,
            a.ing_sktr_krlm_1,a.ing_sktr_krlm_1_acklm, a.sktr_grp,a.boss_drm_kod,b.rtg,
            TO_CHAR(a.kst_trh,'yyyymm'),b.ytk_svy,a.grp_lmt,a.grp_rsk,a.grp_kod_1,
            a.grp_lmt_1,a.grp_rsk_1,a.grp_kod_2,a.grp_lmt_2,a.grp_rsk_2,a.lmt_ynlm_vade,
            a.firm_lmt,a.bank_ciro,a.bank_trh,a.rati_ciro,a.rati_trh,a.tmnt_yetrszlk_tutar,
            b.ytk_svy_acklm,a.verg_no,a.krd_ynlm_vade,NVL(b.onck_15_gun_yakn_gzlm_drm,0),
            a.ing_sktr_krlm_2, a.ing_sktr_krlm_2_acklm, a.ing_sktr_krlm_3, a.ing_sktr_krlm_3_acklm,
            CASE WHEN NVL(b.onck_90_gun_yakn_gzlm_drm,0) in (0,1) and NVL(b.yakn_gzlm_drm,0)=4 and NVL(b.onck_yakn_gzlm_drm,0)<4 THEN 'Y' --yapilandirma dublejump_flag
                 WHEN NVL(b.onck_90_gun_yakn_gzlm_drm,0) in (0,1) and NVL(b.yakn_gzlm_drm,0)in(5,6) and NVL(b.onck_yakn_gzlm_drm,0)<5 THEN 'T' --takip dublejump_flag
            END,
            a.sim_trh,a.sim_ciro,a.mus_tip,
            gi.islm_trh,gi.tutar,
            ik.islm_trh,
            ik.tutar,
            tag.tkp_acls_trh_350,
            tag.tkp_acls_tutar_350,
            tag.tkp_acls_tutar_gnakdi,
            ta.tkp_acls_trh_170,
            ta.tkp_acls_tutar_170,
            ta.tkp_acls_tutar_180,
            yr.yplndrm_gnakdi_rsk,
            yr.yplndrm_nkt_rsk,
            TO_CHAR(NVL(b.onck_90_gun_yakn_gzlm_drm,0));

    COMMIT;
    v_line_no := $$PLSQL_LINE;

    SELECT MAX(dnm) INTO v_memzuc_gelen
      FROM trfm.TMP_MEMZUC_GELN --ofsdata.MEMZUC_GELEN
     WHERE dnm <= TO_NUMBER(TO_CHAR(v_tarih,'yyyymmdd'));

    v_line_no := $$PLSQL_LINE;


    SELECT count(*) INTO v_RT_ESLESME_SONUC_arsiv_mi --0 döner ise data; bankdb.RT_ESLESME_SONUC_ESKI@ARSIVX e arþivlenmiþtir.
      FROM bankdb.RT_ESLESME_SONUC@FSBCV
     WHERE tarih = v_tarih;

    --EXECUTE IMMEDIATE 'TRUNCATE TABLE DM_INFOMAN.TMP_BHS_YETERLILIK';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_BHS_YTRLK',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

IF v_RT_ESLESME_SONUC_arsiv_mi >0 THEN --bankdb.RT_ESLESME_SONUC@FSBCV'e gider. Arþiv olsaydý:  bankdb.RT_ESLESME_SONUC_ESKI@ARSIVX 'e gidecekti.
    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_BHS_YTRLK
    SELECT tarih as kst_trh,
           musteri as mus_no,
           teminat_yet as tmnt_ytrlk,
           bhs_yet as bhs_ytrlk,
           gkt_yet as gkt_ytrlk,
           kefil_yet as kfl_ytrlk,
           ozel_sart_yet as ozl_sart_ytrlk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM bankdb.RT_ESLESME_SONUC@FSBCV    --bankdb.RT_ESLESME_SONUC_ESKI@ARSIVX
     WHERE tarih=v_tarih
     and musteri<>1760030;
    COMMIT;
    v_line_no := $$PLSQL_LINE;

ELSE

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_BHS_YTRLK
    SELECT tarih as kst_trh,
           musteri as mus_no,
           teminat_yet as tmnt_ytrlk,
           bhs_yet as bhs_ytrlk,
           gkt_yet as gkt_ytrlk,
           kefil_yet as kfl_ytrlk,
           ozel_sart_yet as ozl_sart_ytrlk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM bankdb.RT_ESLESME_SONUC_ESKI@ARSIVX    --bankdb.RT_ESLESME_SONUC@FSBCV
     WHERE tarih=v_tarih
     and musteri<>1760030;
    COMMIT;
    v_line_no := $$PLSQL_LINE;

END IF;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_UPUAN',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_UPUAN
    SELECT v_tarih AS kst_trh,
           mus_no,
           ROUND(avg(puan),2) AS  ort_upuan,
           MAX(upuan_t_1) AS upuan_t_1,
           MAX(upuan_t_2) AS upuan_t_2,
           sysdate as etl_trh,
           v_sp_name as etl_job
    FROM (SELECT tarih,
                 musteri as mus_no,
                 puan,
                 CASE WHEN tarih=v_tarih THEN puan END AS upuan_t_1,
                 CASE WHEN tarih=v_tarih-1 THEN puan END AS upuan_t_2
            FROM extr.FS_KRD_RAPOR_MUS_BILGI_DET_GNC a
           WHERE
           1=1
           and a.tarih BETWEEN TRUNC(TO_DATE(v_tarih,'dd/mm/yyyy'),'mm') AND v_tarih
           and musteri<>1760030)
               GROUP BY mus_no;

    COMMIT;
    v_line_no := $$PLSQL_LINE;



    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GKTS_GCKME_ADET',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_GKTS_GCKME_ADET
    SELECT v_tarih as trh,
           customer as mus_no,
           count(DISTINCT a.collid) as gkts_gckme_adet,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM extr.COLL_CUST_GUNLUK_RAPOR_F a
     WHERE a.process_date BETWEEN TRUNC(TO_DATE(v_tarih,'dd/mm/yyyy'),'yyyy') AND TO_DATE(v_tarih,'dd/mm/yyyy')
     and customer<>1760030
  GROUP BY customer;

    COMMIT;
    v_line_no := $$PLSQL_LINE;


    --EXECUTE IMMEDIATE 'TRUNCATE TABLE DM_INFOMAN.TMP_GECIKME_TUTAR';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GCKME_TUTAR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_GCKME_TUTAR
    SELECT v_tarih AS trh,
           musteri as mus_no,
           SUM(CASE WHEN kaynak IN ('Boss','Nakdi Risk') and a.updprogram not in ('KMH','SKK') THEN bakiye_tl_karsilik ELSE 0 END) AS nkrd_gckme_tutar,
           SUM(CASE WHEN a.kaynak IN ('KMH') or a.updprogram='KMH' THEN bakiye_tl_karsilik ELSE 0 END) AS kmh_gckme_tutar,
           SUM(CASE WHEN a.kaynak IN ('KREDI KARTI') or a.updprogram='SKK' THEN bakiye_tl_karsilik ELSE 0 END) AS skk_gckme_tutar,
           SUM(CASE WHEN kaynak IN ('GNakdi Risk') THEN bakiye_tl_karsilik ELSE 0 END) AS gnakdi_krd_gckme_tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM ofsdata.MUSTERI_RISK_DETAY_HIST a
     WHERE 1=1
           AND tarih=v_tarih
           AND bakiye_tl_karsilik<>0
           and musteri<>1760030
  GROUP BY musteri;
    COMMIT;
    v_line_no := $$PLSQL_LINE;


    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PRTFY_SHP',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
        IF V_SQLCODE<>0 THEN
            RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
        END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_PRTFY_SHP
    SELECT v_tarih as kst_trh,
           a.musteri_no as mus_no,
           a.portfoy_sahip as prtfy_sahibi_kod,
           b.kodaciklama as prtfy_sahibi_kod_acklm,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM extr.FS_MUSTERI_STATU_MASTER a,
           (SELECT tp.kod, tp.kodaciklama
              FROM extr.FS_TEKLIFPARAM tp
             WHERE tp.secimtip=2085) b
                 WHERE a.portfoy_sahip=b.kod(+)
                 and   a.musteri_no <>1760030;

    COMMIT;
---------------------------------------------------------------------------------
    v_line_no := $$PLSQL_LINE;
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_NPL_THSL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_NPL_THSL
    SELECT a.islem_tarihi as islm_trh,
           TO_NUMBER(SUBSTR(cari_hesap_no,2,8)) as mus_no,
           SUM(a.tahsilat_tutar) as npl_thsl_tutar,
           SUM(a.masraf_tutar) as npl_msrf_tutar,
           SUM(a.anapara_tutar) as npl_anpr_tutar,
           SUM(a.faiz_tutar) as npl_faiz_tutar,
           SUM(a.bsmv_tutar) as npl_bsmv_tutar,
           sysdate as et_trh,
           v_sp_name etl_job
      FROM extr.OY_OY_KAT_MAHSUP_TAHSILAT a
     WHERE a.islem_tarihi = v_tarih
     and TO_NUMBER(SUBSTR(cari_hesap_no,2,8)) <>1760030
  GROUP BY a.islem_tarihi,
           TO_NUMBER(SUBSTR(cari_hesap_no,2,8));

    COMMIT;
    ---------------------------------------------------------------------------------
    v_line_no := $$PLSQL_LINE;
    --EXECUTE IMMEDIATE 'TRUNCATE TABLE TRFM.MVDT_BKY';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('MVDT_BKY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;


    INSERT                                  /*+ APPEND */ INTO trfm.MVDT_BKY
    SELECT a.tarih as trh,
           a.ilk7 as mus_no,
           ROUND(SUM(CASE WHEN a.hestur in ('MT') THEN ((a.alac-a.borc)*b.d_alis)/b.katsayi ELSE 0 END),2) as vds_tl,
           ROUND(SUM(CASE WHEN a.hestur in ('MY') THEN ((a.alac-a.borc)*b.d_alis)/b.katsayi ELSE 0 END),2) as vds_yp_tl_karslk,
           ROUND(SUM(CASE WHEN a.hestur in ('VT') THEN ((a.alac-a.borc)*b.d_alis)/b.katsayi ELSE 0 END),2) as vdl_tl,
           ROUND(SUM(CASE WHEN a.hestur in ('VY') THEN ((a.alac-a.borc)*b.d_alis)/b.katsayi ELSE 0 END),2) as vdl_yp_tl_karslk,
           sysdate as et_trh,
           v_sp_name etl_job
      FROM --extr.FS_GUNLUK_HPLANDET_SG a,
           (SELECT gnc.tarih, gnc.sube, gnc.sinif, gnc.ilk7, gnc.hestur, gnc.borc, gnc.alac, gnc.ana, gnc.alt, gnc.tali1, gnc.tali2, gnc.para
              FROM extr.FS_GUNLUK_HPLANDET_SG gnc
             WHERE 1=1
            AND gnc.tarih =v_tarih
           UNION ALL
            SELECT ars.tarih, ars.sube, ars.sinif, ars.ilk7, ars.hestur, ars.borc, ars.alac, ars.ana, ars.alt, ars.tali1, ars.tali2, ars.para
              FROM TRFM.TMP_GUNLUK_HPLANDET_ESKI_SG ars
             WHERE ars.tarih = v_tarih
           ) a,
           extr.FS_FDOVIZ b,
           extr.FS_MUSTERI_MASTER k
     WHERE 1=1
     and a.ilk7<>1760030
           and a.tarih=v_tarih
           and b.tarih=v_tarih
           and b.kurtipi=1
           and a.para=b.para
           and a.hestur in ('MT','MY','VT','VY')
           and a.sube<900
           and (a.alac-a.borc)<>0
           and a.ilk7=k.musteri_no and k.calisma_sekli in (2,3,4,5)
  GROUP BY a.tarih,a.ilk7;

    COMMIT;
    v_line_no := $$PLSQL_LINE;




    --EXECUTE IMMEDIATE 'TRUNCATE TABLE TRFM.TEKLIF_TEBLIG_TARIH';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TKLF_TBLG_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKLF_TBLG_TRH
    SELECT v_tarih as kst_trh,
           a.musteri as mus_no,
           MIN(a.tebtarih) as ilk_tblg_trh,
           MAX(a.tebtarih) as ilk_tblg_trh,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM extr.FS_TEKLIF a,
           extr.FS_MUSTERI_MASTER b
     WHERE 1=1
           and a.musteri=b.musteri_no
           and b.calisma_sekli in (2,3,4,5)
           and a.durum=1
           and a.tebtarih>=TO_DATE('01.01.2000','dd.mm.yyyy')
           and   a.musteri<>1760030
     GROUP BY a.musteri;

    COMMIT;
    v_line_no := $$PLSQL_LINE;
    -----------------------------------------------------------------------------------------
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TKLF_BLG',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
        IF V_SQLCODE<>0 THEN
            RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
        END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKLF_BLG
    SELECT  v_tarih as kst_trh,
            f.mus_no,
            y.son_tklf_trh,
            y.knl_kod,
            DECODE(y.knl_kod,1,'Þube',2,'Otomatik Teklif',3,'SMS',4,'WEB',5,'Direkt Satýþ') as knl_kod_acklm,
            f.ytk_kod,
            f.ytk_kod_acklm,
            sysdate as etl_trh,
            v_sp_name as etl_job,
            t.max_tklf_lmt_trh
      FROM  (SELECT mus_no,
                    MAX(max_tklf_lmt_trh) max_tklf_lmt_trh,
                    MAX(son_tklf_trh) son_tklf_trh,
                    MAX(knl_kod) knl_kod
               FROM (SELECT f.musno as mus_no,
                            MAX(teklif_son_tar) KEEP (DENSE_RANK FIRST ORDER BY teklif_son_tar desc,f.teklif_id desc) OVER (PARTITION BY f.musno) son_tklf_trh,
                            MAX(kanal_kodu) KEEP (DENSE_RANK FIRST ORDER BY f.teklif_son_tar desc,f.teklif_id desc) OVER (PARTITION BY f.musno) knl_kod,
                            MAX(teklif_tar) KEEP (DENSE_RANK FIRST ORDER BY (f.teklif_nakdi_limit+f.teklif_gnakdi_limit) desc) OVER (PARTITION BY musno) MAX_TKLF_LMT_TRH
                       FROM extr.FS_ARES_DM_TEKLIF_BILGI f
                      WHERE teklif_statu_aciklama = 'Onaylý')
           GROUP BY mus_no
            ) y,
            (SELECT DISTINCT a.musteri_no as mus_no,
                    MAX(a.yetki_kodu) KEEP (DENSE_RANK FIRST ORDER BY a.islem_sira_no desc) OVER (PARTITION BY a.musteri_no) as  ytk_kod,
                    MAX(a.yetki_kodu_ack) KEEP (DENSE_RANK FIRST ORDER BY a.islem_sira_no desc) OVER (PARTITION BY a.musteri_no) as  ytk_kod_acklm
               FROM extr.FS_ARES_DM_MUSTERI_STATU a
              WHERE a.gunceleme_tarihi<=v_tarih
            ) f,
            (SELECT DISTINCT b.musteri as mus_no,
                    MAX(b.tebtarih) KEEP (DENSE_RANK FIRST ORDER BY b.tllimit desc ) OVER (PARTITION BY b.musteri) as max_tklf_lmt_trh
               FROM extr.FS_TEKLIF b
              WHERE b.durum=1 and b.tebtarih>=TO_DATE('01/01/2000' ,'dd.mm.yyyy') ) t
     WHERE  y.mus_no(+)=f.mus_no
            and f.mus_no=t.mus_no(+)
            and  f.mus_no<>1760030;

    COMMIT;
    v_line_no := $$PLSQL_LINE;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PRTFY_RPR_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
        IF V_SQLCODE<>0 THEN
            RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
        END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_PRTFY_RPR_02        --TMP_PRTFY_RPR_02 olacak.
     SELECT a.kst_trh, a.mus_no,a.isim_unvn,a.ana_sube,
            a.ana_sube_ad,a.bolge_ad,a.clsm_skl, a.verg_no,
            a.rsk_ktgr,a.tmslc_scl,a.tmslc_ad_soyad,
            a.brm_kod,a.gckme_gun_arlk,a.gckme_gun_adet,
            a.gckmeli_tutar,a.krd_sinif,a.grp_kod,a.grp_kod_acklm,
            a.clsn_adet,a.p,a.boss_drm_kod,a.sktr,
            a.sktr_acklm,a.ing_sktr,a.ing_sktr_acklm_tr,
            a.ing_sktr_acklm_en,a.bank_sktr,a.bank_sktr_acklm,
            a.tcmb_kod,a.ing_sktr_krlm_1,a.ing_sktr_krlm_1_acklm,
            a.sktr_grp,a.yakn_gzlm_drm, a.onck_yakn_gzlm_drm,
            a.onck_ay_yakn_gzlm_drm,a.grid_no,a.ing_rtg_1,
            a.ing_rtg_2,a.ing_rtg_3,a.krnotu,a.gnclm_trh,
            a.tkp_acls_trh,a.thp_170,a.thp_172, a.thp_174,a.thp_176,
            a.thp_156,a.thp_158_159,a.cek_thht,a.nkt_rsk,a.gnakdi_rsk,
            a.tplm_rsk,a.cnli_nkt_rsk_gncl_kur,a.cnli_nkt_rsk,
            a.cnli_gnakdi_rsk,a.tplm_cnli_rsk,
            a.npl_tcr_krd,a.npl_tkst_arac_krd,a.npl_tkst_isyr_krd,
            a.npl_tkst_diger_krd,a.npl_kkr,a.npl_ovngt,
            a.npl_gnakdi,a.npl_diger,a.bddk_nkt_karslk,
            a.bddk_gnakdi_karslk,a.bddk_tplm_karslk,a.rtg,
            a.thsl_tutar,a.ytk_svy,a.ytk_svy_acklm,
            a.grp_lmt,a.grp_rsk,a.grp_kod_1,a.grp_lmt_1,
            a.grp_rsk_1,a.grp_kod_2,a.grp_lmt_2,a.grp_rsk_2,
            a.lmt_ynlm_vade,a.firm_lmt,a.bank_ciro,
            a.bank_trh,a.rati_ciro,a.rati_trh,
            a.tmnt_ytrsz_tutar,a.tkp_gun_adet,a.rttf,
            a.ihr_rttf_spot,a.ebnk_tl,a.spot,a.nkt_yntm,a.ovngt,
            a.senet_isknt,a.tkst_tcr,a.kmh,a.dvz_krd,
            a.ebnk_yp,a.dvz_endks_krd,a.tmnt_mktp_tl,a.tmnt_mktp_yp,a.akrdtf_tl,
            a.akrdtf_yp,a.kbl_krd_tl,a.kbl_krd_yp,
            a.diger_grntr_kflt_tl,a.diger_grntr_kflt_yp,a.blk_cek_tl,
            a.blk_cek_yp,a.brysl_kkr,a.krmsl_kkr,a.yipo,
            a.dvz_endks_krd_gncl_kur,a.npl_nkt_rsk,a.npl_gnakdi_rsk,
            a.npl_tplm_rsk,a.krd_ynlm_vade,
            a.onck_15_gun_yakn_gzlm_drm, a.dj_f,
            a.ing_sktr_krlm_2,a.ing_sktr_krlm_2_acklm,a.ing_sktr_krlm_3,a.ing_sktr_krlm_3_acklm,
            v_tarih - a.krd_ynlm_vade as odue_gun_adet,
            b.rsk_ktgr as onck_rsk_ktgr,
            b.gckmeli_tutar as onck_gckmeli_tutar,
            b.bddk_tplm_karslk as onck_bddk_tplm_karslk,
            b.clsm_skl as onck_clsm_skl,
            NVL(b.tplm_rsk,0) onck_tplm_rsk,
            NVL(b.nkt_rsk,0) as onck_nakdi_rsk,
            NVL(c.tplm_rsk,0) onck_ay_tplm_rsk,
            NVL(c.nkt_rsk,0) as onck_ay_nakdi_rsk,
            yg.iptk_exprt_3,yg.iptk_exprt_2,yg.iptk_exprt_1,
            yg.iptk_3,yg.iptk_2,yg.iptk_1,yg.firm_grnt,
            yg.dvz_cek,yg.cek,yg.cek_mvdt_rehni,
            yg.arac_rehni,yg.hat_rehni,yg.rhn,yg.alck_tmlk,
            yg.kflt,yg.fnsmn_senet,yg.tmnt_senet,
            yg.tmnt_senet_mvdt_rehni,yg.mvdt_rehni,
            CASE WHEN (b.clsm_skl in (4,5) and a.clsm_skl=2) or (b.clsm_skl=2  and a.clsm_skl in (4,5))
                      or (b.clsm_skl in (4,5) and a.clsm_skl=3) or (b.clsm_skl=3  and a.clsm_skl in (4,5))
                      or (b.clsm_skl =3  and a.clsm_skl=2) or (b.clsm_skl=2  and a.clsm_skl=3)
                 THEN 'E' ELSE 'H'
            END as tfr_f,
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.tplm_rsk<a.tplm_rsk) THEN 'NPL-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and ((b.nkt_rsk>0 and a.nkt_rsk=0)  and a.boss_drm_kod='KTS') THEN 'NPL-Kapama/Satýþ'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and ((b.nkt_rsk>0 and a.nkt_rsk=0)  and a.boss_drm_kod='WOFF') THEN 'NPL-Kapama/Aktiften Silme/write off'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk>1 and (a.nkt_rsk>0 and a.nkt_rsk<1)   and a.boss_drm_kod='KTAC') THEN 'NPL-Kapama/Aktiften Silme/Aciz'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.tplm_rsk>0 and a.tplm_rsk=0) THEN 'NPL-Kapama/Nakit Kapama'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1) THEN 'NPL-Kapama/Aktife Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2) THEN 'NPL-Kapama/Önizlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3) THEN 'NPL-Kapama/izlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4) THEN 'NPL-Kapama/Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.tplm_rsk>a.tplm_rsk) THEN 'NPL-Kýsmi Kapama'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.tplm_rsk=a.tplm_rsk) THEN 'NPL-Current/Current'
            END as tkp_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.tplm_rsk<a.tplm_rsk) THEN 'RS-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.tplm_rsk>0 and a.tplm_rsk=0) THEN 'RS-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.tplm_rsk>a.tplm_rsk) THEN 'RS-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1) THEN 'RS-Aktive Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2) THEN 'RS-Önizlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3) THEN 'RS-Ýzlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4) THEN 'RS-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.tplm_rsk=a.tplm_rsk) THEN 'RS-Current/Current'
            END as yplndrm_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Aktif Gelen'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.tplm_rsk<a.tplm_rsk) THEN 'WL-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.tplm_rsk>0 and a.tplm_rsk=0) THEN 'WL-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.tplm_rsk>a.tplm_rsk) THEN 'WL-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1) THEN 'WL-Aktive Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2) THEN 'WL-ÖnizlemeyeTransfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4) THEN 'WL-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4) THEN 'WL-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.tplm_rsk=a.tplm_rsk) THEN 'WL-Current/Current'
            END as izlm_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.tplm_rsk<a.tplm_rsk) THEN 'WB-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.tplm_rsk>0 and a.tplm_rsk=0) THEN 'WB-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.tplm_rsk>a.tplm_rsk) THEN 'WB-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1) THEN 'WB-Aktive Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3) THEN 'WB-Ýzlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4) THEN 'WB-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4) THEN 'WB-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.tplm_rsk=a.tplm_rsk) THEN 'WB-Current/Current'
            END as onzlm_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=0 and a.yakn_gzlm_drm=1 and (b.tplm_rsk=0 and a.tplm_rsk<>0) THEN 'ACT-Ýlk Kullandýrým'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.tplm_rsk<a.tplm_rsk) THEN 'ACT-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.tplm_rsk>0 and a.tplm_rsk=0) THEN 'ACT-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.tplm_rsk>a.tplm_rsk) THEN 'ACT-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2) THEN 'ACT-Önizlemeye Devir'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3) THEN 'ACT-Ýzlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4) THEN 'ACT-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4) THEN 'ACT-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.tplm_rsk=a.tplm_rsk) THEN 'ACT-Current/Current'
            END as aktf_drm_1,
            --
            ---aylýk durumlar
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.tplm_rsk<a.tplm_rsk) THEN 'NPL-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and ((c.tplm_rsk>0 and a.nkt_rsk=0) and a.boss_drm_kod='KTS') THEN 'NPL-Kapama/Satýþ'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and ((c.tplm_rsk>0 and a.nkt_rsk=0) and a.boss_drm_kod='WOFF') THEN 'NPL-Kapama/Aktiften Silme/write off'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.tplm_rsk>1 and (a.tplm_rsk>0 and a.nkt_rsk<1)  and a.boss_drm_kod='KTAC') THEN 'NPL-Kapama/Aktiften Silme/Aciz'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.tplm_rsk>0 and a.tplm_rsk=0) THEN 'NPL-Kapama/Nakit Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1) THEN 'NPL-Kapama/Aktife Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2) THEN 'NPL-Kapama/Önizlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3) THEN 'NPL-Kapama/izlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4) THEN 'NPL-Kapama/Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.tplm_rsk>a.tplm_rsk) THEN 'NPL-Kýsmi Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.tplm_rsk=a.tplm_rsk) THEN 'NPL-Current/Current'
            END as ayl_tkp_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.tplm_rsk<a.tplm_rsk) THEN 'RS-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.tplm_rsk>0 and a.tplm_rsk=0) THEN 'RS-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.tplm_rsk>a.tplm_rsk) THEN 'RS-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1) THEN 'RS-Aktive Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2) THEN 'RS-Önizlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3) THEN 'RS-Ýzlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4) THEN 'RS-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.tplm_rsk=a.tplm_rsk) THEN 'RS-Current/Current'
            END as ayl_yplndrm_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Aktif Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.tplm_rsk<a.tplm_rsk) THEN 'WL-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.tplm_rsk>0 and a.tplm_rsk=0) THEN 'WL-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.tplm_rsk>a.tplm_rsk) THEN 'WL-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1) THEN 'WL-Aktive Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2) THEN 'WL-ÖnizlemeyeTransfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4) THEN 'WL-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4) THEN 'WL-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.tplm_rsk=a.tplm_rsk) THEN 'WL-Current/Current'
            END as ayl_izlm_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.tplm_rsk<a.tplm_rsk) THEN 'WB-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.tplm_rsk>0 and a.tplm_rsk=0) THEN 'WB-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.tplm_rsk>a.tplm_rsk) THEN 'WB-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1) THEN 'WB-Aktive Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3) THEN 'WB-Ýzlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4) THEN 'WB-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4) THEN 'WB-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.tplm_rsk=a.tplm_rsk) THEN 'WB-Current/Current'
                 END as ayl_onzlm_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=0 and a.yakn_gzlm_drm=1 and (c.tplm_rsk=0 and a.tplm_rsk<>0)  THEN 'ACT-Ýlk Kullandýrým'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.tplm_rsk<a.tplm_rsk) THEN 'ACT-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.tplm_rsk>0 and a.tplm_rsk=0) THEN 'ACT-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.tplm_rsk>a.tplm_rsk) THEN 'ACT-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2) THEN 'ACT-Önizlemeye Devir'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3) THEN 'ACT-Ýzlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4) THEN 'ACT-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4) THEN 'ACT-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.tplm_rsk=a.tplm_rsk) THEN 'ACT-Current/Current'
            END as ayl_aktf_drm_1,
            --
            ---nakit riske göre durumlar
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk<a.nkt_rsk) THEN 'NPL-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk>0 and a.nkt_rsk=0) and a.boss_drm_kod='KTS' THEN 'NPL-Kapama/Satýþ'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk>0 and a.nkt_rsk=0) and a.boss_drm_kod='WOFF' THEN 'NPL-Kapama/Aktiften Silme/write off'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk>1 and (a.nkt_rsk>0 and a.nkt_rsk<1))  and a.boss_drm_kod='KTAC' THEN 'NPL-Kapama/Aktiften Silme/Aciz'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk>0 and a.nkt_rsk=0) THEN 'NPL-Kapama/Nakit Kapama'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1) THEN 'NPL-Kapama/Aktife Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2) THEN 'NPL-Kapama/Önizlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3) THEN 'NPL-Kapama/izlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4) THEN 'NPL-Kapama/Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk>a.nkt_rsk) THEN 'NPL-Kýsmi Kapama'
                 WHEN (a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (b.nkt_rsk=a.nkt_rsk) THEN 'NPL-Current/Current'
            END as nkt_rsk_tkp_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.nkt_rsk<a.nkt_rsk) THEN 'RS-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.nkt_rsk>0 and a.nkt_rsk=0) THEN 'RS-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.nkt_rsk>a.nkt_rsk) THEN 'RS-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1) THEN 'RS-Aktive Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2) THEN 'RS-Önizlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3) THEN 'RS-Ýzlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4) THEN 'RS-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (b.nkt_rsk=a.nkt_rsk) THEN 'RS-Current/Current'
            END as nkt_rsk_yplndrm_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Aktif Gelen'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.nkt_rsk<a.nkt_rsk) THEN 'WL-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.nkt_rsk>0 and a.nkt_rsk=0) THEN 'WL-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.nkt_rsk>a.nkt_rsk) THEN 'WL-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1) THEN 'WL-Aktive Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2) THEN 'WL-ÖnizlemeyeTransfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4) THEN 'WL-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4) THEN 'WL-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (b.nkt_rsk=a.nkt_rsk) THEN 'WL-Current/Current'
            END as nkt_rsk_izlm_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.nkt_rsk<a.nkt_rsk) THEN 'WB-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.nkt_rsk>0 and a.nkt_rsk=0) THEN 'WB-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.nkt_rsk>a.nkt_rsk) THEN 'WB-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1) THEN 'WB-Aktive Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3) THEN 'WB-Ýzlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4) THEN 'WB-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4) THEN 'WB-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (b.nkt_rsk=a.nkt_rsk) THEN 'WB-Current/Current'
            END as nkt_rsk_onzlm_drm_1,
            --
            CASE WHEN a.onck_yakn_gzlm_drm=0 and a.yakn_gzlm_drm=1 and (b.nkt_rsk=0 and a.nkt_rsk<>0) THEN 'ACT-Ýlk Kullandýrým'
                 WHEN a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.nkt_rsk<a.nkt_rsk) THEN 'ACT-Bakiyesi Artan'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.nkt_rsk>0 and a.nkt_rsk=0) THEN 'ACT-Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.nkt_rsk>a.nkt_rsk) THEN 'ACT-Kýsmý Kapama'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2) THEN 'ACT-Önizlemeye Devir'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3) THEN 'ACT-Ýzlemeye Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4) THEN 'ACT-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4) THEN 'ACT-NPL e Transfer'
                 WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (b.nkt_rsk=a.nkt_rsk) THEN 'ACT-Current/Current'
            END as nkt_rsk_aktf_drm_1,
            --
            ---aylýk durumlar
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4 THEN 'NPL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk<a.nkt_rsk) THEN 'NPL-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk>0 and a.nkt_rsk=0) and a.boss_drm_kod='KTS' THEN 'NPL-Kapama/Satýþ'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk>0 and a.nkt_rsk=0 ) and a.boss_drm_kod='WOFF' THEN 'NPL-Kapama/Aktiften Silme/write off'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk>1 and (a.nkt_rsk>0 and a.nkt_rsk<1)  and a.boss_drm_kod='KTAC') THEN 'NPL-Kapama/Aktiften Silme/Aciz'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk>0 and a.nkt_rsk=0) THEN 'NPL-Kapama/Nakit Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1) THEN 'NPL-Kapama/Aktife Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2) THEN 'NPL-Kapama/Önizlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3) THEN 'NPL-Kapama/izlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4) THEN 'NPL-Kapama/Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk>a.nkt_rsk) THEN 'NPL-Kýsmi Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm>4) and (c.nkt_rsk=a.nkt_rsk) THEN 'NPL-Current/Current'
            END as nkt_rsk_ayl_tkp_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=4 THEN 'RS-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.nkt_rsk<a.nkt_rsk) THEN 'RS-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.nkt_rsk>0 and a.nkt_rsk=0) THEN 'RS-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.nkt_rsk>a.nkt_rsk) THEN 'RS-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1) THEN 'RS-Aktive Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2) THEN 'RS-Önizlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3) THEN 'RS-Ýzlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm>4) THEN 'RS-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=4) and (c.nkt_rsk=a.nkt_rsk) THEN 'RS-Current/Current'
            END as nkt_rsk_ayl_yplndrm_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Aktif Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Ön Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=3 THEN 'WL-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.nkt_rsk<a.nkt_rsk) THEN 'WL-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.nkt_rsk>0 and a.nkt_rsk=0) THEN 'WL-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.nkt_rsk>a.nkt_rsk) THEN 'WL-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1) THEN 'WL-Aktive Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2) THEN 'WL-ÖnizlemeyeTransfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4) THEN 'WL-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm>4) THEN 'WL-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=3) and (c.nkt_rsk=a.nkt_rsk) THEN 'WL-Current/Current'
            END as nkt_rsk_ayl_izlm_drm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Aktifden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=2 THEN 'WB-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.nkt_rsk<a.nkt_rsk) THEN 'WB-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.nkt_rsk>0 and a.nkt_rsk=0) THEN 'WB-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.nkt_rsk>a.nkt_rsk) THEN 'WB-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1) THEN 'WB-Aktive Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3) THEN 'WB-Ýzlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4) THEN 'WB-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm>4) THEN 'WB-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=2) and (c.nkt_rsk=a.nkt_rsk) THEN 'WB-Current/Current'
            END as nkt_rsk_ayl_onzlm_rdm_1,
            --
            CASE WHEN a.onck_ay_yakn_gzlm_drm=0 and a.yakn_gzlm_drm=1 and (c.nkt_rsk=0 and a.nkt_rsk<>0)  THEN 'ACT-Ýlk Kullandýrým'
                 WHEN a.onck_ay_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Önizlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/ Ýzlemeden Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/Yapýlandýrmadan Gelen'
                 WHEN a.onck_ay_yakn_gzlm_drm>4 and a.yakn_gzlm_drm=1 THEN 'ACT-Yeni Devir/NPL den Gelen'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.nkt_rsk<a.nkt_rsk) THEN 'ACT-Bakiyesi Artan'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.nkt_rsk>0 and a.nkt_rsk=0) THEN 'ACT-Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.nkt_rsk>a.nkt_rsk) THEN 'ACT-Kýsmý Kapama'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2) THEN 'ACT-Önizlemeye Devir'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3) THEN 'ACT-Ýzlemeye Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4) THEN 'ACT-Yapýlandýrmaya Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm>4) THEN 'ACT-NPL e Transfer'
                 WHEN (a.onck_ay_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=1) and (c.nkt_rsk=a.nkt_rsk) THEN 'ACT-Current/Current'
            END as nkt_rsk_ayl_aktf_drm_1,
            d.tplm_memzuc_lmt,d.tplm_memzuc_rsk,d.memzuc_lmt_dolk_oran,
            d.tplm_memzuc_tkp_bky,d.tplm_memzuc_faiz_tahkuk,d.tplm_memzuc_bank_adet,d.sira,
            d.son_ay_memzuc_art_oran,d.son_2_ay_memzuc_art_oran,d.son_3_ay_memzuc_art_oran,
            d.son_6_ay_memzuc_art_oran,d.son_12_ay_memzuc_art_oran,
            d.memzuc_dnm,
            decode(pb.durum,1,pb.eski_portfoy_kod,2,pb.eski_portfoy_kod,pb.yeni_portfoy_kod) as prtfy_kod,       --yeni eklenen kolonlar. 23.07.2014
            tb.prtfy_sahibi_kod,tb.prtfy_sahibi_kod_acklm,
            mb.tmnt_ytrlk, mb.bhs_ytrlk, mb.gkt_ytrlk, mb.kfl_ytrlk,mb.ozl_sart_ytrlk,
            kb.ort_upuan,
            kb.upuan_t_1,
            kb.upuan_t_2,
            zb.en_son_yplndrm_trh,
            gt.nkrd_gckme_tutar, gt.kmh_gckme_tutar, gt.skk_gckme_tutar, gt.gnakdi_krd_gckme_tutar,
            NVL(nt.npl_thsl_tutar,0) as npl_thsl_tutar,
            NVL(nt.npl_msrf_tutar,0) as npl_msrf_tutar,
            NVL(nt.npl_anpr_tutar,0) as npl_anpr_tutar,
            NVL(nt.npl_faiz_tutar,0) as npl_faiz_tutar,
            NVL(nt.npl_bsmv_tutar,0) as npl_bsmv_tutar,
            mv.vds_tl,
            mv.vds_yp_tl_karslk,
            mv.vdl_tl,
            mv.vdl_yp_tl_karslk,
            tt.ilk_tblg_trh,
            tt.son_tblg_trh,
            b.bddk_nkt_karslk as onck_bddk_nkt_karslk,
            b.bddk_gnakdi_karslk as onck_bddk_gnakdi_karslk,
            b.krnotu as onck_krnotu,
            c.krnotu as onck_ay_son_gun_krnotu,
            CASE WHEN a.bddk_nkt_karslk>0 and b.bddk_nkt_karslk=0 THEN 'New Comer'
                 WHEN a.bddk_nkt_karslk > b.bddk_nkt_karslk THEN 'Balance Increase'
                 WHEN a.bddk_nkt_karslk < b.bddk_nkt_karslk THEN 'Balance Decrease'
                 ELSE 'Current'
             END as nkt_karslk_drm,
            CASE WHEN a.bddk_gnakdi_karslk>0 and b.bddk_gnakdi_karslk=0 THEN 'New Comer'
                 WHEN a.bddk_gnakdi_karslk > b.bddk_gnakdi_karslk THEN 'Balance Increase'
                 WHEN a.bddk_gnakdi_karslk < b.bddk_gnakdi_karslk THEN 'Balance Decrease'
                 ELSE 'Current'
             END as gnakdi_karslk_drm,
            CASE WHEN a.bddk_tplm_karslk>0 and b.bddk_tplm_karslk=0 THEN 'New Comer'
                 WHEN a.bddk_tplm_karslk > b.bddk_tplm_karslk THEN 'Balance Increase'
                 WHEN a.bddk_tplm_karslk < b.bddk_tplm_karslk THEN 'Balance Decrease'
                 ELSE 'Current'
             END as tplm_karslk_drm,
            tk.son_tklf_trh, tk.knl_kod, tk.knl_kod_acklm, tk.ytk_kod, tk.ytk_kod_acklm,
            tk.max_tklf_lmt_trh,
            fb.forbal_f, fb.forbal_bits_trh,
            a.sim_trh,
            a.sim_ciro,
            a.mus_tip,
            a.gnakdi_ilk_klndrm_trh,
            a.gnakdi_ilk_klndrm_tutar,
            a.nkt_ilk_klndrm_trh,
            a.nkt_ilk_klndrm_tutar,
            a.tkp_acls_trh_350,
            a.tkp_acls_tutar_350,
            a.tkp_acls_tutar_gnakdi,
            a.tkp_acls_trh_170,
            a.tkp_acls_tutar_170,
            a.tkp_acls_tutar_180,
            a.yplndrm_gnakdi_rsk,
            a.yplndrm_nkt_rsk,
            sysdate as etl_trh,
            v_sp_name as etl_job,
            b.brm_kod as onck_brm_kod,
            c.ana_sube AS onck_ay_ana_sube,
            a.onck_90_gun_yakn_gzlm_drm,
            zb.ilk_yplndrm_trh
       FROM trfm.TMP_PRTFY_RPR_01 a,    --eski tablosu dm_infoman.TMP_PRTFY_RPR a, dm_infoman.portfoy_rapor_gnc
            dm_infoman.PORTFOY_RAPOR b, --onceki güne ait datalarý almak için kullanýldý.
            dm_infoman.PORTFOY_RAPOR c, --onceki ayýn son gününe ait datalarý almak için kullanýldý.
            trfm.TMP_MEMZUC_DNM d,      --ofsdata.MEMZUC_DONEM d,
            extr.FS_MUSTERI_PORTFOY pb, --ofsdata.MUSTERI_PORTFOY pb,
            trfm.TMP_PRTFY_SHP tb,
            trfm.TMP_BHS_YTRLK mb,
            trfm.TMP_UPUAN kb,
            trfm.TMP_EN_SON_YPLNDRM_TRH zb,
            trfm.TMP_GCKME_TUTAR gt,
            trfm.TMP_YAKN_GZLM_TMNT yg,
            trfm.TMP_NPL_THSL nt,
            trfm.MVDT_BKY mv,
            trfm.TMP_TKLF_TBLG_TRH tt,
            trfm.TMP_TKLF_BLG tk,
            (SELECT musteri_no as mus_no,
                    forbalance_evet as forbal_f,
                    forbalance_tarih as forbal_bits_trh,
                    ADD_MONTHS(forbalance_tarih,-24) as trh
               FROM extr.FS_MUSTERI_STATU_MASTER
              WHERE forbalance_evet='E') fb
      WHERE 1=1
            and a.mus_no=b.mus_no(+)
            and a.mus_no=c.mus_no(+)
            and a.mus_no = d.mus_no(+)
            and d.memzuc_dnm(+) = v_memzuc_gelen
            and a.mus_no=pb.musteri_no(+)
            and a.mus_no=tb.mus_no(+)
            and a.mus_no=zb.mus_no(+)
            and a.mus_no=yg.mus_no(+)
            and a.mus_no=nt.mus_no(+)
            and a.mus_no=mb.mus_no(+)
            and a.mus_no=gt.mus_no(+)
            and a.mus_no=kb.mus_no(+)
            and a.mus_no=mv.mus_no(+)
            and a.mus_no=tt.mus_no(+)
            and a.mus_no=tk.mus_no(+)
            and a.mus_no=fb.mus_no(+)
            and v_tarih=fb.trh(+)
            --and a.kst_trh = v_tarih   --tek gün datasý olduðu için commentlendi.
            and c.kst_trh (+) = trunc(trunc(v_tarih,'mm') -1)
            and a.mus_no<>1760030
            and b.kst_trh (+) = v_tarih-1;
COMMIT;

    v_line_no := $$PLSQL_LINE;


    --EXECUTE IMMEDIATE 'TRUNCATE TABLE TRFM.TMP_C1_BILG';
    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_C1_BILG',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

   v_line_no := $$PLSQL_LINE;

   INSERT                                  /*+ APPEND */ INTO trfm.TMP_C1_BILG
   SELECT mus_no,
          c1_giris_trh,
          c1_kynk_isim,
          c1_avkt_atama_trh,
          c1_avkt_no,
          c1_avkt_ad_soyad,
          sysdate as etl_trh,
          v_sp_name as etl_job,
          c1_drm_kod
     FROM (SELECT tk.musterino as mus_no,
                  tk.c1_giris_tarihi as c1_giris_trh,
                  kt.kaynak_isim as c1_kynk_isim,
                  ROW_NUMBER() OVER (PARTITION BY tk.musterino ORDER BY CASE WHEN tk.statu_kodu IN ('LTC') THEN 0 ELSE 1 END DESC, tk.c1_giris_tarihi ASC) as sira,
                  av.atama_tarihi as c1_avkt_atama_trh,
                  av.avukat_no as c1_avkt_no,
                  sor.ad ||' '|| sor.soyad as c1_avkt_ad_soyad,
                  tk.statu_kodu AS c1_drm_kod
             FROM extr.FS_TAKIP_ISLEMLERI tk
                  INNER JOIN extr.FS_TAKIP_KAYNAK_TANIM kt ON tk.kaynak_id = kt.kaynak_id
                  LEFT JOIN extr.FS_TAKIP_ISLEMLERI_C1_DETAY av ON TK.TAKIP_ID = AV.TAKIP_ID AND statu = 'A'
                  LEFT JOIN extr.FS_AVUKAT_TANIM sor ON av.avukat_no=sor.avukat_no
            WHERE 1=1
--                  AND tk.statu_kodu NOT IN ('LTC')
                  AND tk.c1_giris_tarihi IS NOT NULL
                  and tk.musterino<>1760030
          )
    WHERE sira =1;

    COMMIT;

    v_line_no := $$PLSQL_LINE;

   SELECT MIN(c1_giris_trh), MIN(c1_avkt_atama_trh) INTO v_min_c1_giris_trh, v_min_c1_avkt_atama_trh FROM trfm.TMP_C1_BILG;

--   v_line_no := $$PLSQL_LINE;
--
--   SELECT MAX(kst_trh) INTO v_ecl_max_kst_trh
--     FROM dm_infoman.rwa_ecl_krmsl
--    WHERE 1=1
--          AND mus_no <> 999999999
--          AND aktf_drm = 0
--          AND rwa_ecl_urun_tip = 'E'
--          AND kst_trh > TO_DATE( '31.07.2016','DD.MM.YYYY') --bu tarih ve öncesinde çoklama var.
--          AND kst_trh <= v_tarih;

   v_line_no := $$PLSQL_LINE;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PRTFY_RPR_03',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
        IF V_SQLCODE<>0 THEN
            RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
        END IF;

    v_line_no := $$PLSQL_LINE;


--daha sonra exchange partition ile dm_infoman.portfoy_rapor tablosuna INSERT edilecek.
INSERT                                  /*+ APPEND */ INTO trfm.TMP_PRTFY_RPR_03
 SELECT p.kst_trh,
        p.mus_no,
        p.isim_unvn,
        p.ana_sube,
        p.ana_sube_ad,
        p.bolge_ad,
        p.clsm_skl,
        p.verg_no,
        p.rsk_ktgr,
        p.tmslc_scl,
        p.tmslc_ad_soyad,
        p.brm_kod,
        p.gckme_gun_arlk,
        p.gckme_gun_adet,
        p.gckmeli_tutar,
        p.krd_sinif,
        p.grp_kod,
        p.grp_kod_acklm,
        p.clsn_adet,
        p.p,
        p.boss_drm_kod,
        p.sktr,
        p.sktr_acklm,
        p.ing_sktr,
        p.ing_sktr_acklm_tr,
        p.ing_sktr_acklm_en,
        p.bank_sktr,
        p.bank_sktr_acklm,
        p.tcmb_kod,
        p.ing_sktr_krlm_1,
        p.ing_sktr_krlm_1_acklm,
        p.sktr_grp,
        p.yakn_gzlm_drm,
        p.onck_yakn_gzlm_drm,
        p.onck_ay_yakn_gzlm_drm,
        p.grid_no,
        p.ing_rtg_1,
        p.ing_rtg_2,
        p.ing_rtg_3,
        p.krnotu,
        p.gnclm_trh,
        p.tkp_acls_trh,
        p.thp_170,
        p.thp_172,
        p.thp_174,
        p.thp_176,
        p.thp_156,
        p.thp_158_159,
        p.cek_thht,
        p.nkt_rsk,
        p.gnakdi_rsk,
        p.tplm_rsk,
        p.cnli_nkt_rsk_gncl_kur,
        p.cnli_nkt_rsk,
        p.cnli_gnakdi_rsk,
        p.tplm_cnli_rsk,
        p.npl_tcr_krd,
        p.npl_tkst_arac_krd,
        p.npl_tkst_isyr_krd,
        p.npl_tkst_diger_krd,
        p.npl_kkr,
        p.npl_ovngt,
        p.npl_gnakdi,
        p.npl_diger,
        p.bddk_nkt_karslk,
        p.bddk_gnakdi_karslk,
        p.bddk_tplm_karslk,
        p.rtg,
        p.thsl_tutar,
        p.ytk_svy,
        p.ytk_svy_acklm,
        p.grp_lmt,
        p.grp_rsk,
        p.grp_kod_1,
        p.grp_lmt_1,
        p.grp_rsk_1,
        p.grp_kod_2,
        p.grp_lmt_2,
        p.grp_rsk_2,
        p.lmt_ynlm_vade,
        p.firm_lmt,
        p.bank_ciro,
        p.bank_trh,
        p.rati_ciro,
        p.rati_trh,
        p.tmnt_ytrsz_tutar,
        p.tkp_gun_adet,
        p.rttf,
        p.ihr_rttf_spot,
        p.ebnk_tl,
        p.spot,
        p.nkt_yntm,
        p.ovngt,
        p.senet_isknt,
        p.tkst_tcr,
        p.kmh,
        p.dvz_krd,
        p.ebnk_yp,
        p.dvz_endks_krd,
        p.tmnt_mktp_tl,
        p.tmnt_mktp_yp,
        p.akrdtf_tl,
        p.akrdtf_yp,
        p.kbl_krd_tl,
        p.kbl_krd_yp,
        p.diger_grntr_kflt_tl,
        p.diger_grntr_kflt_yp,
        p.blk_cek_tl,
        p.blk_cek_yp,
        p.brysl_kkr,
        p.krmsl_kkr,
        p.yipo,
        p.dvz_endks_krd_gncl_kur,
        p.iptk_exprt_3,
        p.iptk_exprt_2,
        p.iptk_exprt_1,
        p.iptk_3,
        p.iptk_2,
        p.iptk_1,
        p.firm_grnt,
        p.dvz_cek,
        p.cek,
        p.cek_mvdt_rehni,
        p.arac_rehni,
        p.hat_rehni,
        p.rhn,
        p.alck_tmlk,
        p.kflt,
        p.fnsmn_senet,
        p.tmnt_senet,
        p.tmnt_senet_mvdt_rehni,
        p.mvdt_rehni,
        p.tfr_f,
        p.onck_tplm_rsk,
        p.onck_ay_tplm_rsk,
        p.tkp_drm_1,
        p.yplndrm_drm_1,
        p.izlm_drm_1,
        p.onzlm_drm_1,
        p.aktf_drm_1,
        p.ayl_tkp_drm_1,
        p.ayl_yplndrm_drm_1,
        p.ayl_izlm_drm_1,
        p.ayl_onzlm_drm_1,
        p.ayl_aktf_drm_1,
        CASE WHEN p.tkp_drm_1 in ('NPL-Yeni Devir/Aktifden Gelen' ,'NPL-Yeni Devir/Önizlemeden Gelen','NPL-Yeni Devir/Ýzlemeden Gelen','NPL-Yeni Devir/Yapýlandýrmadan Gelen','NPL-Bakiyesi Artan') THEN 'NPL-INFLOW'
             WHEN p.tkp_drm_1 in ('NPL-Kapama/Nakit Kapama' ,'NPL-Kapama/Satýþ','NPL-Kapama/Aktiften Silme/write off','NPL-Kapama/Aktiften Silme/Aciz','NPL-Kapama/Aktife Transfer',
                                   'NPL-Kapama/Önizlemeye Transfer','NPL-Kapama/izlemeye Transfer','NPL-Kapama/Yapýlandýrmaya Transfer','NPL-Kýsmi Kapama') THEN 'NPL-OUTFLOW'
             WHEN p.tkp_drm_1= 'NPL-Current/Current' THEN 'NPL-Current'
        END as tkp_drm_2,
        --
        CASE WHEN p.yplndrm_drm_1 in ('RS-Yeni Devir/Aktifden Gelen' ,'RS-Yeni Devir/Ön Ýzlemeden Gelen' ,'RS-Yeni Devir/Ýzlemeden Gelen','RS-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'RS-INFLOW'
             WHEN p.yplndrm_drm_1 in ('RS-Kapama','RS-Kýsmý Kapama','RS-Aktive Transfer','RS-Önizlemeye Transfer','RS-Ýzlemeye Transfer','RS-NPL e Transfer') THEN 'RS-OUTFLOW'
             WHEN p.yplndrm_drm_1='RS-Current/Current' THEN 'RS-CURRENT'
        END as yplndrm_drm_2,
        --
        CASE WHEN p.izlm_drm_1 in ('WL-Yeni Devir/Aktif Gelen' ,'WL-Yeni Devir/Ön Ýzlemeden Gelen','WL-Yeni Devir/Yapýlandýrmadan Gelen','WL-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'WL-INFLOW'
             WHEN p.izlm_drm_1 in ('WL-Kapama','WB-Aktive Transfer','WL-ÖnizlemeyeTransfer','WL-Yapýlandýrmaya Transfer','WL-NPL e Transfer') THEN 'WL-OUTFLOW'
             WHEN p.izlm_drm_1='WL-Current/Current' THEN 'WL-CURRENT'
        END as izlm_drm_2,
        --
        CASE WHEN p.onzlm_drm_1 in ('WB-Yeni Devir/Aktifden Gelen','WB-Yeni Devir/ Ýzlemeden Gelen','WB-Yeni Devir/Yapýlandýrmadan Gelen','WB-Yeni Devir/NPL den Gelen','WB-Bakiyesi Artan') THEN 'WB-INFLOW'
             WHEN p.onzlm_drm_1 in ('WB-Kapama','WB-Kýsmý Kapama','WB-Aktive Transfer','WB-Ýzlemeye Transfer','WB-Yapýlandýrmaya Transfer','WB-NPL e Transfer') THEN 'WB-OUTFLOW'
             WHEN p.onzlm_drm_1 ='WB-Current/Current' THEN 'WB-CURRENT'
        END as onzlm_drm_2,
        --
        CASE WHEN p.aktf_drm_1 in ('ACT-Ýlk Kullandýrým' ,'ACT-Yeni Devir/Önizlemeden Gelen' ,'ACT-Yeni Devir/ Ýzlemeden Gelen','ACT-Yeni Devir/Yapýlandýrmadan Gelen','ACT-Yeni Devir/NPL den Gelen',
                                   'ACT-Bakiyesi Artan') THEN 'ACT-INFLOW'
             WHEN p.aktf_drm_1 in ('ACT-Kapama','ACT-Kýsmý Kapama','ACT-Önizlemeye Devir','ACT-Ýzlemeye Transfer','ACT-Yapýlandýrmaya Transfer','ACT-NPL e Transfer') THEN 'ACT-OUTFLOW'
             WHEN p.aktf_drm_1='ACT-Current/Current' THEN 'ACT-CURRENT'
        END as aktf_drm_2,
        --
        CASE WHEN p.ayl_tkp_drm_1 in ('NPL-Yeni Devir/Aktifden Gelen' ,'NPL-Yeni Devir/Önizlemeden Gelen','NPL-Yeni Devir/Ýzlemeden Gelen','NPL-Yeni Devir/Yapýlandýrmadan Gelen',
                                       'NPL-Bakiyesi Artan') THEN 'NPL-INFLOW'
             WHEN p.ayl_tkp_drm_1 in ('NPL-Kapama/Nakit Kapama' ,'NPL-Kapama/Satýþ','NPL-Kapama/Aktiften Silme/write off','NPL-Kapama/Aktiften Silme/Aciz','NPL-Kapama/Aktife Transfer',
                                       'NPL-Kapama/Önizlemeye Transfer','NPL-Kapama/izlemeye Transfer','NPL-Kapama/Yapýlandýrmaya Transfer','NPL-Kýsmi Kapama') THEN 'NPL-OUTFLOW'
             WHEN p.ayl_tkp_drm_1= 'NPL-Current/Current' THEN 'NPL-Current'
        END as ayl_tkp_drm_2,
        --
        CASE WHEN p.ayl_yplndrm_drm_1 in ('RS-Yeni Devir/Aktifden Gelen' ,'RS-Yeni Devir/Ön Ýzlemeden Gelen' ,'RS-Yeni Devir/Ýzlemeden Gelen','RS-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'RS-INFLOW'
             WHEN p.ayl_yplndrm_drm_1 in ('RS-Kapama','RS-Kýsmý Kapama','RS-Aktive Transfer','RS-Önizlemeye Transfer','RS-Ýzlemeye Transfer','RS-NPL e Transfer') THEN 'RS-OUTFLOW'
             WHEN p.ayl_yplndrm_drm_1='RS-Current/Current' THEN 'RS-CURRENT'
        END as ayl_yplndrm_drm_2,
        --
        CASE WHEN p.ayl_izlm_drm_1 in ('WL-Yeni Devir/Aktif Gelen' ,'WL-Yeni Devir/Ön Ýzlemeden Gelen','WL-Yeni Devir/Yapýlandýrmadan Gelen','WL-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'WL-INFLOW'
             WHEN p.ayl_izlm_drm_1 in ('WL-Kapama','WL-Aktive Transfer','WL-Ýzlemeye Transfer','WL-Yapýlandýrmaya Transfer','WL-NPL e Transfer') THEN 'WL-OUTFLOW'
             WHEN p.ayl_izlm_drm_1='WL-Current/Current'  THEN 'WL-CURRENT'
        END as ayl_izlm_drm_2,
        --
        CASE WHEN p.ayl_onzlm_drm_1 in ('WB-Yeni Devir/Aktifden Gelen','WB-Yeni Devir/ Ýzlemeden Gelen','WB-Yeni Devir/Yapýlandýrmadan Gelen','WB-Yeni Devir/NPL den Gelen','WB-Bakiyesi Artan') THEN 'WB-INFLOW'
             WHEN p.ayl_onzlm_drm_1 in ('WB-Kapama','WB-Kýsmý Kapama','WB-Aktive Transfer','WB-Ýzlemeye Transfer','WB-Yapýlandýrmaya Transfer','WB-NPL e Transfer') THEN 'WB-OUTFLOW'
             WHEN p.ayl_onzlm_drm_1 ='WB-Current/Current' THEN 'WB-CURRENT'
        END as ayl_onzlm_drm_2,
        --
        CASE WHEN p.ayl_aktf_drm_1 in ('ACT-Ýlk Kullandýrým' ,'ACT-Yeni Devir/Önizlemeden Gelen' ,'ACT-Yeni Devir/ Ýzlemeden Gelen','ACT-Yeni Devir/Yapýlandýrmadan Gelen','ACT-Yeni Devir/NPL den Gelen',
                                       'ACT-Bakiyesi Artan') THEN 'ACT-INFLOW'
             WHEN p.ayl_aktf_drm_1 in ('ACT-Kapama','ACT-Kýsmý Kapama','ACT-Önizlemeye Devir','ACT-Ýzlemeye Transfer','ACT-Yapýlandýrmaya Transfer','ACT-NPL e Transfer') THEN 'ACT-OUTFLOW'
             WHEN p.ayl_aktf_drm_1='ACT-Current/Current' THEN 'ACT-CURRENT'
        END as ayl_aktf_drm_2,
        p.nkt_rsk_tkp_drm_1,
        p.nkt_rsk_yplndrm_drm_1,
        p.nkt_rsk_izlm_drm_1,
        p.nkt_rsk_onzlm_drm_1,
        p.nkt_rsk_aktf_drm_1,
        p.nkt_rsk_ayl_tkp_drm_1,
        p.nkt_rsk_ayl_yplndrm_drm_1,
        p.nkt_rsk_ayl_izlm_drm_1,
        p.nkt_rsk_ayl_onzlm_rdm_1,
        p.nkt_rsk_ayl_aktf_drm_1,
        CASE WHEN p.nkt_rsk_aktf_drm_1 in ('ACT-Ýlk Kullandýrým' ,'ACT-Yeni Devir/Önizlemeden Gelen' ,'ACT-Yeni Devir/ Ýzlemeden Gelen','ACT-Yeni Devir/Yapýlandýrmadan Gelen','ACT-Yeni Devir/NPL den Gelen',
                                      'ACT-Bakiyesi Artan') THEN 'ACT-INFLOW'
             WHEN p.nkt_rsk_aktf_drm_1 in ('ACT-Kapama','ACT-Kýsmý Kapama','ACT-Önizlemeye Devir','ACT-Ýzlemeye Transfer','ACT-Yapýlandýrmaya Transfer','ACT-NPL e Transfer') THEN 'ACT-OUTFLOW'
             WHEN p.nkt_rsk_aktf_drm_1='ACT-Current/Current' THEN 'ACT-CURRENT'
        END as nkt_rsk_aktf_drm_2,
        --
        CASE WHEN p.nkt_rsk_ayl_aktf_drm_1 in ('ACT-Ýlk Kullandýrým' ,'ACT-Yeni Devir/Önizlemeden Gelen' ,'ACT-Yeni Devir/ Ýzlemeden Gelen','ACT-Yeni Devir/Yapýlandýrmadan Gelen','ACT-Yeni Devir/NPL den Gelen',
                                          'ACT-Bakiyesi Artan') THEN 'ACT-INFLOW'
             WHEN p.nkt_rsk_ayl_aktf_drm_1 in ('ACT-Kapama','ACT-Kýsmý Kapama','ACT-Önizlemeye Devir','ACT-Ýzlemeye Transfer','ACT-Yapýlandýrmaya Transfer','ACT-NPL e Transfer') THEN 'ACT-OUTFLOW'
             WHEN p.nkt_rsk_ayl_aktf_drm_1='ACT-Current/Current' THEN 'ACT-CURRENT'
        END as nkt_rsk_ayl_aktf_drm_2,
        --
        CASE WHEN p.nkt_rsk_ayl_izlm_drm_1 in ('WL-Yeni Devir/Aktif Gelen' ,'WL-Yeni Devir/Ön Ýzlemeden Gelen','WL-Yeni Devir/Yapýlandýrmadan Gelen','WL-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'WL-INFLOW'
             WHEN p.nkt_rsk_ayl_izlm_drm_1 in ('WL-Kapama','WL-Aktive Transfer','WL-Ýzlemeye Transfer','WL-Yapýlandýrmaya Transfer','WL-NPL e Transfer') THEN 'WL-OUTFLOW'
             WHEN p.nkt_rsk_ayl_izlm_drm_1='WL-Current/Current'  THEN 'WL-CURRENT'
        END as nkt_rsk_ayl_izlm_drm_2,
        --
        CASE WHEN p.nkt_rsk_ayl_onzlm_rdm_1 in ('WB-Yeni Devir/Aktifden Gelen','WB-Yeni Devir/ Ýzlemeden Gelen','WB-Yeni Devir/Yapýlandýrmadan Gelen','WB-Yeni Devir/NPL den Gelen','WB-Bakiyesi Artan') THEN 'WB-INFLOW'
             WHEN p.nkt_rsk_ayl_onzlm_rdm_1 in ('WB-Kapama','WB-Kýsmý Kapama','WB-Aktive Transfer','WB-Ýzlemeye Transfer','WB-Yapýlandýrmaya Transfer','WB-NPL e Transfer') THEN 'WB-OUTFLOW'
             WHEN p.nkt_rsk_ayl_onzlm_rdm_1 ='WB-Current/Current' THEN 'WB-CURRENT'
        END as nkt_rsk_ayl_onzlm_rdm_2,
        --
        CASE WHEN p.nkt_rsk_ayl_tkp_drm_1 in ('NPL-Yeni Devir/Aktifden Gelen' ,'NPL-Yeni Devir/Önizlemeden Gelen','NPL-Yeni Devir/Ýzlemeden Gelen','NPL-Yeni Devir/Yapýlandýrmadan Gelen','NPL-Bakiyesi Artan') THEN 'NPL-INFLOW'
             WHEN p.nkt_rsk_ayl_tkp_drm_1 in ('NPL-Kapama/Nakit Kapama' ,'NPL-Kapama/Satýþ','NPL-Kapama/Aktiften Silme/write off','NPL-Kapama/Aktiften Silme/Aciz','NPL-Kapama/Aktife Transfer','NPL-Kapama/Önizlemeye Transfer',
                                          'NPL-Kapama/izlemeye Transfer','NPL-Kapama/Yapýlandýrmaya Transfer','NPL-Kýsmi Kapama') THEN 'NPL-OUTFLOW'
             WHEN p.nkt_rsk_ayl_tkp_drm_1= 'NPL-Current/Current' THEN 'NPL-Current'
        END as nkt_rsk_ayl_tkp_drm_2,
        --
        CASE WHEN p.nkt_rsk_ayl_yplndrm_drm_1 in ('RS-Yeni Devir/Aktifden Gelen' ,'RS-Yeni Devir/Ön Ýzlemeden Gelen' ,'RS-Yeni Devir/Ýzlemeden Gelen','RS-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'RS-INFLOW'
             WHEN p.nkt_rsk_ayl_yplndrm_drm_1 in ('RS-Kapama','RS-Kýsmý Kapama','RS-Aktive Transfer','RS-Önizlemeye Transfer','RS-Ýzlemeye Transfer','RS-NPL e Transfer') THEN 'RS-OUTFLOW'
             WHEN p.nkt_rsk_ayl_yplndrm_drm_1='RS-Current/Current' THEN 'RS-CURRENT'
        END as nkt_rsk_ayl_yplndrm_drm_2,
        --
        CASE WHEN p.nkt_rsk_izlm_drm_1 in ('WL-Yeni Devir/Aktif Gelen' ,'WL-Yeni Devir/Ön Ýzlemeden Gelen','WL-Yeni Devir/Yapýlandýrmadan Gelen','WL-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'WL-INFLOW'
             WHEN p.nkt_rsk_izlm_drm_1 in ('WL-Kapama','WB-Aktive Transfer','WL-ÖnizlemeyeTransfer','WL-Yapýlandýrmaya Transfer','WL-NPL e Transfer') THEN 'WL-OUTFLOW'
             WHEN p.nkt_rsk_izlm_drm_1='WL-Current/Current' THEN 'WL-CURRENT'
        END as nkt_rsk_izlm_drm_2,
        --
        CASE WHEN p.nkt_rsk_onzlm_drm_1 in ('WB-Yeni Devir/Aktifden Gelen','WB-Yeni Devir/ Ýzlemeden Gelen','WB-Yeni Devir/Yapýlandýrmadan Gelen','WB-Yeni Devir/NPL den Gelen','WB-Bakiyesi Artan') THEN 'WB-INFLOW'
             WHEN p.nkt_rsk_onzlm_drm_1 in ('WB-Kapama','WB-Kýsmý Kapama','WB-Aktive Transfer','WB-Ýzlemeye Transfer','WB-Yapýlandýrmaya Transfer','WB-NPL e Transfer') THEN 'WB-OUTFLOW'
             WHEN p.nkt_rsk_onzlm_drm_1 ='WB-Current/Current' THEN 'WB-CURRENT'
        END as nkt_rsk_onzlm_drm_2,
        --
        CASE WHEN p.nkt_rsk_tkp_drm_1 in ('NPL-Yeni Devir/Aktifden Gelen' ,'NPL-Yeni Devir/Önizlemeden Gelen','NPL-Yeni Devir/Ýzlemeden Gelen','NPL-Yeni Devir/Yapýlandýrmadan Gelen','NPL-Bakiyesi Artan') THEN 'NPL-INFLOW'
             WHEN p.nkt_rsk_tkp_drm_1 in ('NPL-Kapama/Nakit Kapama' ,'NPL-Kapama/Satýþ','NPL-Kapama/Aktiften Silme/write off','NPL-Kapama/Aktiften Silme/Aciz','NPL-Kapama/Aktife Transfer','NPL-Kapama/Önizlemeye Transfer',
                                      'NPL-Kapama/izlemeye Transfer','NPL-Kapama/Yapýlandýrmaya Transfer','NPL-Kýsmi Kapama') THEN 'NPL-OUTFLOW'
             WHEN p.nkt_rsk_tkp_drm_1= 'NPL-Current/Current' THEN 'NPL-Current'
        END as nkt_rsk_tkp_drm_2,
        --
        CASE WHEN p.nkt_rsk_yplndrm_drm_1 in ('RS-Yeni Devir/Aktifden Gelen' ,'RS-Yeni Devir/Ön Ýzlemeden Gelen' ,'RS-Yeni Devir/Ýzlemeden Gelen','RS-Yeni Devir/NPL den Gelen','RS-Bakiyesi Artan') THEN 'RS-INFLOW'
             WHEN p.nkt_rsk_yplndrm_drm_1 in ('RS-Kapama','RS-Kýsmý Kapama','RS-Aktive Transfer','RS-Önizlemeye Transfer','RS-Ýzlemeye Transfer','RS-NPL e Transfer') THEN 'RS-OUTFLOW'
             WHEN p.nkt_rsk_yplndrm_drm_1='RS-Current/Current' THEN 'RS-CURRENT'
        END as nkt_rsk_yplndrm_drm_2,
        p.onck_ay_nakdi_rsk,
        p.onck_nakdi_rsk,
        p.tplm_memzuc_lmt,
        p.tplm_memzuc_rsk,
        p.memzuc_lmt_dolk_oran,
        p.tplm_memzuc_tkp_bky,
        p.tplm_memzuc_faiz_tahkuk,
        p.tplm_memzuc_bank_adet,
        p.sira,
        p.son_ay_memzuc_art_oran,
        p.son_2_ay_memzuc_art_oran,
        p.son_3_ay_memzuc_art_oran,
        p.son_6_ay_memzuc_art_oran,
        p.son_12_ay_memzuc_art_oran,
        p.memzuc_dnm,
        p.prtfy_kod,
        p.prtfy_sahibi_kod,
        p.prtfy_sahibi_kod_acklm,
        p.tmnt_ytrlk,
        p.bhs_ytrlk,
        p.gkt_ytrlk,
        p.kfl_ytrlk,
        p.ozl_sart_ytrlk,
        p.ort_upuan,
        p.upuan_t_1,
        p.upuan_t_2,
        p.en_son_yplndrm_trh,
        p.nkrd_gckme_tutar,
        p.kmh_gckme_tutar,
        p.skk_gckme_tutar,
        p.gnakdi_krd_gckme_tutar,
        p.npl_thsl_tutar,
        p.npl_msrf_tutar,
        p.npl_anpr_tutar,
        p.npl_faiz_tutar,
        p.npl_bsmv_tutar,
        p.npl_nkt_rsk,
        p.npl_gnakdi_rsk,
        p.npl_tplm_rsk,
        p.onck_rsk_ktgr,
        p.onck_gckmeli_tutar,
        SYSDATE as etl_trh,
        p.onck_bddk_tplm_karslk,
        p.onck_clsm_skl,
        p.odue_gun_adet,
        CASE WHEN p.odue_gun_adet >360 THEN '> 360 Days'
             WHEN p.odue_gun_adet between  271 and  360 THEN '(271 - 360) Days'
             WHEN p.odue_gun_adet between  181 and  270 THEN '(181 - 270) Days'
             WHEN p.odue_gun_adet between   91 and  180 THEN '(91 - 180) Days'
             WHEN p.odue_gun_adet between   61 and   90 THEN '(61 - 90) Days'
             WHEN p.odue_gun_adet between   31 and   60 THEN '(31 - 60) Days'
             WHEN p.odue_gun_adet between    0 and   30 THEN '(0 - 30) Days'
             WHEN p.odue_gun_adet between  -30 and   -1 THEN '-(1 - 30) Days'
             WHEN p.odue_gun_adet between  -60 and  -31 THEN '-(31 - 60) Days'
             WHEN p.odue_gun_adet between  -90 and  -61 THEN '-(61 - 90) Days'
             WHEN p.odue_gun_adet between -180 and  -91 THEN '-(91 - 180) Days'
             WHEN p.odue_gun_adet between -270 and -181 THEN '-(181 - 270) Days'
             WHEN p.odue_gun_adet between -360 and -271 THEN '-(271 - 360) Days'
             WHEN p.odue_gun_adet <-360 THEN '< -360 Days'
        END as odue_grp,
        p.krd_ynlm_vade,
        p.vds_tl,
        p.vds_yp_tl_karslk,
        p.vdl_tl,
        p.vdl_yp_tl_karslk,
        p.ilk_tblg_trh,
        p.son_tblg_trh,
        p.onck_15_gun_yakn_gzlm_drm,
        p.dj_f,
        p.onck_bddk_nkt_karslk,
        p.onck_bddk_gnakdi_karslk,
        p.nkt_karslk_drm,
        p.gnakdi_karslk_drm,
        p.tplm_karslk_drm,
        p.ing_sktr_krlm_2,
        p.ing_sktr_krlm_2_acklm,
        p.ing_sktr_krlm_3,
        p.ing_sktr_krlm_3_acklm,
        p.onck_krnotu,
        p.son_tklf_trh, p.knl_kod, p.knl_kod_acklm, p.ytk_kod, p.ytk_kod_acklm,
        p.max_tklf_lmt_trh, p.forbal_f, p.forbal_bits_trh, p.onck_ay_son_gun_krnotu,
        p.sim_trh, p.sim_ciro, p.mus_tip,
        p.gnakdi_ilk_klndrm_trh,
        p.gnakdi_ilk_klndrm_tutar,
        p.nkt_ilk_klndrm_trh,
        p.nkt_ilk_klndrm_tutar,
        p.tkp_acls_trh_350,
        p.tkp_acls_tutar_350,
        p.tkp_acls_tutar_gnakdi,
        p.tkp_acls_trh_170,
        p.tkp_acls_tutar_170,
        p.tkp_acls_tutar_180,
        p.yplndrm_gnakdi_rsk,
        p.yplndrm_nkt_rsk,
        p.onck_brm_kod,
        c1.c1_giris_trh,
        c1.c1_kynk_isim,
        c1.c1_avkt_atama_trh,
        c1.c1_avkt_no,
        c1.c1_avkt_ad_soyad,
        --alttaki kýsýmýn CASE WHEN'e çevrilmesinin sebebi, portfoy_raporunda çoklama olmasý durumunda, sýkýntý çýkmamasý için yazýldý. Ý.M. 20170301
        CASE WHEN c1.c1_giris_trh = v_tarih THEN p.tplm_rsk ELSE gr.tplm_rsk END as c1_giris_trh_tplm_rsk, --gr.tplm_rsk as c1_giris_trh_tplm_rsk,
        CASE WHEN c1.c1_giris_trh = v_tarih THEN p.nkt_rsk ELSE gr.nkt_rsk END as c1_giris_trh_nkt_rsk, --gr.nkt_rsk as c1_giris_trh_nkt_rsk,
        CASE WHEN c1.c1_giris_trh = v_tarih THEN p.gckme_gun_adet ELSE gr.gckme_gun_adet END as c1_giris_trh_gckme_gun_adet, --gr.gckme_gun_adet AS c1_giris_trh_gckme_gun_adet,
        CASE WHEN c1.c1_avkt_atama_trh = v_tarih THEN p.tplm_rsk ELSE aa.tplm_rsk END as c1_avkt_atm_trh_tplm_rsk, --aa.tplm_rsk as c1_avkt_atm_trh_tplm_rsk,
        CASE WHEN c1.c1_avkt_atama_trh = v_tarih THEN p.nkt_rsk ELSE aa.nkt_rsk END as c1_avk_atm_rsk_nkt_rsk, --aa.nkt_rsk as c1_avk_atm_rsk_nkt_rsk,
        c1.c1_drm_kod,
        p.onck_ay_ana_sube,
        p.onck_90_gun_yakn_gzlm_drm,
        p.ilk_yplndrm_trh,
--        s.calisma_sekli_yeni AS clsm_skl_yeni
        CASE WHEN p.clsm_skl IN (2,4,5) THEN
             CASE WHEN aff.alt_segment = 4 AND aff.alt_alt_segment = 1 THEN 5
                  WHEN aff.alt_segment = 4 AND aff.alt_alt_segment IN (2,3) THEN 4
             ELSE p.clsm_skl
             END
        ELSE p.clsm_skl
        END AS clsm_skl_yeni,
        ka.tcmb_acklm
   FROM trfm.tmp_prtfy_rpr_02 p
        LEFT JOIN trfm.tmp_c1_bilg c1 ON p.mus_no = c1.mus_no
        LEFT JOIN dm_infoman.portfoy_rapor gr ON gr.kst_trh = c1.c1_giris_trh
                                                AND gr.mus_no = c1.mus_no
                                                AND gr.kst_trh < v_tarih   -- v_tarih ten gelecek bilgiler TRFM.TMP_PRTFY_RPR_02 den gelecek.
                                                AND gr.kst_trh>=v_min_c1_giris_trh     --partition'dan faydalanmasý için.
        LEFT JOIN dm_infoman.portfoy_rapor aa ON aa.kst_trh = c1.c1_avkt_atama_trh
                                                AND gr.kst_trh < v_tarih   -- v_tarih ten gelecek bilgiler TRFM.TMP_PRTFY_RPR_02 den gelecek.
                                                AND aa.mus_no = c1.mus_no
                                                AND gr.kst_trh>=v_min_c1_avkt_atama_trh    --partition'dan faydalanmasý için.
        LEFT JOIN extr.fs_aff_analiz aff ON p.mus_no = aff.musteri_no
--        LEFT JOIN opr.v_fs_musteri_master_cs_yeni s ON s.musteri_no = p.mus_no;
        LEFT JOIN dep_data.tcmb_kod_acklm ka ON 1=1 AND ka.tcmb_kod = p.tcmb_kod
        where
         p.mus_no<>1760030;

    COMMIT;
    v_line_no := $$PLSQL_LINE;


    --müþteri bazlý hatalý data oluþtuðunda, ilgili müþterinin datasýnýn, farklý bir tarihteki doðru datasý ile replace eden kod alttaki gibidir
    <<gry_dnk_clstrmada_data_dzltme>>
    DECLARE
       CURSOR hatali_data_curs
       IS
          SELECT c.kst_trh_ynls_data, c.mus_no, c.kst_trh_dgru_data
            FROM trfm.PRTFY_RPR_YNLS_DATA_GNCLM c
           WHERE c.kst_trh_ynls_data = v_tarih;
    BEGIN
       FOR hatali_data_for
       IN hatali_data_curs
       LOOP
          DBMS_OUTPUT.put_line (hatali_data_for.mus_no ||' nolu müþterinin ' ||
                                    TO_CHAR(hatali_data_for.kst_trh_ynls_data,'DD.MM.YYYY') ||' tarihindeki hatalý datasý ' ||
                                    TO_CHAR(hatali_data_for.kst_trh_dgru_data,'DD.MM.YYYY') ||' tarihindeki doðru data ile deðiþtirildi.' );
          v_line_no := $$PLSQL_LINE;
          DELETE FROM trfm.TMP_PRTFY_RPR_03 t
                WHERE 1=1
                      AND t.kst_trh = hatali_data_for.kst_trh_ynls_data
                      AND t.mus_no = hatali_data_for.mus_no;
          COMMIT;
          v_line_no := $$PLSQL_LINE;
          INSERT                                  /*+ APPEND */ INTO trfm.TMP_PRTFY_RPR_03
          SELECT hatali_data_for.kst_trh_ynls_data as kst_trh, a.mus_no, a.isim_unvn, a.ana_sube, a.ana_sube_ad, a.bolge_ad, a.clsm_skl, a.verg_no, a.rsk_ktgr,
                 a.tmslc_scl, a.tmslc_ad_soyad, a.brm_kod, a.gckme_gun_arlk, a.gckme_gun_adet, a.gckmeli_tutar, a.krd_sinif, a.grp_kod, a.grp_kod_acklm,
                 a.clsn_adet, a.p, a.boss_drm_kod, a.sktr, a.sktr_acklm, a.ing_sktr, a.ing_sktr_acklm_tr, a.ing_sktr_acklm_en, a.bank_sktr, a.bank_sktr_acklm,
                 a.tcmb_kod, a.ing_sktr_krlm_1, a.ing_sktr_krlm_1_acklm, a.sktr_grp, a.yakn_gzlm_drm, a.onck_yakn_gzlm_drm, a.onck_ay_yakn_gzlm_drm,
                 a.grid_no, a.ing_rtg_1, a.ing_rtg_2, a.ing_rtg_3, a.krnotu, a.gnclm_trh, a.tkp_acls_trh, a.thp_170, a.thp_172, a.thp_174, a.thp_176, a.thp_156,
                 a.thp_158_159, a.cek_thht, a.nkt_rsk, a.gnakdi_rsk, a.tplm_rsk, a.cnli_nkt_rsk_gncl_kur, a.cnli_nkt_rsk, a.cnli_gnakdi_rsk,
                 a.tplm_cnli_rsk, a.npl_tcr_krd, a.npl_tkst_arac_krd, a.npl_tkst_isyr_krd, a.npl_tkst_diger_krd, a.npl_kkr, a.npl_ovngt, a.npl_gnakdi,
                 a.npl_diger, a.bddk_nkt_karslk, a.bddk_gnakdi_karslk, a.bddk_tplm_karslk, a.rtg, a.thsl_tutar, a.ytk_svy, a.ytk_svy_acklm, a.grp_lmt, a.grp_rsk,
                 a.grp_kod_1, a.grp_lmt_1, a.grp_rsk_1, a.grp_kod_2, a.grp_lmt_2, a.grp_rsk_2, a.lmt_ynlm_vade, a.firm_lmt, a.bank_ciro, a.bank_trh, a.rati_ciro,
                 a.rati_trh, a.tmnt_ytrsz_tutar, a.tkp_gun_adet, a.rttf, a.ihr_rttf_spot, a.ebnk_tl, a.spot, a.nkt_yntm, a.ovngt, a.senet_isknt,
                 a.tkst_tcr, a.kmh, a.dvz_krd, a.ebnk_yp, a.dvz_endks_krd, a.tmnt_mktp_tl, a.tmnt_mktp_yp, a.akrdtf_tl, a.akrdtf_yp, a.kbl_krd_tl, a.kbl_krd_yp,
                 a.diger_grntr_kflt_tl, a.diger_grntr_kflt_yp, a.blk_cek_tl, a.blk_cek_yp, a.brysl_kkr, a.krmsl_kkr, a.yipo, a.dvz_endks_krd_gncl_kur,
                 a.iptk_exprt_3, a.iptk_exprt_2, a.iptk_exprt_1, a.iptk_3, a.iptk_2, a.iptk_1, a.firm_grnt, a.dvz_cek, a.cek, a.cek_mvdt_rehni, a.arac_rehni,
                 a.hat_rehni, a.rhn, a.alck_tmlk, a.kflt, a.fnsmn_senet, a.tmnt_senet, a.tmnt_senet_mvdt_rehni, a.mvdt_rehni, a.tfr_f, a.onck_tplm_rsk,
                 a.onck_ay_tplm_rsk, a.tkp_drm_1, a.yplndrm_drm_1, a.izlm_drm_1, a.onzlm_drm_1, a.aktf_drm_1, a.ayl_tkp_drm_1, a.ayl_yplndrm_drm_1,
                 a.ayl_izlm_drm_1, a.ayl_onzlm_drm_1, a.ayl_aktf_drm_1, a.tkp_drm_2, a.yplndrm_drm_2, a.izlm_drm_2, a.onzlm_drm_2, a.aktf_drm_2,
                 a.ayl_tkp_drm_2, a.ayl_yplndrm_drm_2, a.ayl_izlm_drm_2, a.ayl_onzlm_drm_2, a.ayl_aktf_drm_2, a.nkt_rsk_tkp_drm_1, a.nkt_rsk_yplndrm_drm_1,
                 a.nkt_rsk_izlm_drm_1, a.nkt_rsk_onzlm_drm_1, a.nkt_rsk_aktf_drm_1, a.nkt_rsk_ayl_tkp_drm_1, a.nkt_rsk_ayl_yplndrm_drm_1,
                 a.nkt_rsk_ayl_izlm_drm_1, a.nkt_rsk_ayl_onzlm_rdm_1, a.nkt_rsk_ayl_aktf_drm_1, a.nkt_rsk_aktf_drm_2, a.nkt_rsk_ayl_aktf_drm_2,
                 a.nkt_rsk_ayl_izlm_drm_2, a.nkt_rsk_ayl_onzlm_rdm_2, a.nkt_rsk_ayl_tkp_drm_2, a.nkt_rsk_ayl_yplndrm_drm_2, a.nkt_rsk_izlm_drm_2,
                 a.nkt_rsk_onzlm_drm_2, a.nkt_rsk_tkp_drm_2, a.nkt_rsk_yplndrm_drm_2, a.onck_ay_nakdi_rsk, a.onck_nakdi_rsk, a.tplm_memzuc_lmt, a.tplm_memzuc_rsk,
                 a.memzuc_lmt_dolk_oran, a.tplm_memzuc_tkp_bky, a.tplm_memzuc_faiz_tahkuk, a.tplm_memzuc_bank_adet, a.sira, a.son_ay_memzuc_art_oran,
                 a.son_2_ay_memzuc_art_oran, a.son_3_ay_memzuc_art_oran, a.son_6_ay_memzuc_art_oran, a.son_12_ay_memzuc_art_oran, a.memzuc_dnm, a.prtfy_kod,
                 a.prtfy_sahibi_kod, a.prtfy_sahibi_kod_acklm, a.tmnt_ytrlk, a.bhs_ytrlk, a.gkt_ytrlk, a.kfl_ytrlk, a.ozl_sart_ytrlk, a.ort_upuan, a.upuan_t_1,
                 a.upuan_t_2, a.en_son_yplndrm_trh, a.nkrd_gckme_tutar, a.kmh_gckme_tutar, a.skk_gckme_tutar, a.gnakdi_krd_gckme_tutar, a.npl_thsl_tutar,
                 a.npl_msrf_tutar, a.npl_anpr_tutar, a.npl_faiz_tutar, a.npl_bsmv_tutar, a.npl_nkt_rsk, a.npl_gnakdi_rsk, a.npl_tplm_rsk, a.onck_rsk_ktgr,
                 a.onck_gckmeli_tutar, a.etl_trh, a.onck_bddk_tplm_karslk, a.onck_clsm_skl, a.odue_gun_adet, a.odue_grp, a.krd_ynlm_vade, a.vds_tl,
                 a.vds_yp_tl_karslk, a.vdl_tl, a.vdl_yp_tl_karslk, a.ilk_tblg_trh, a.son_tblg_trh, a.onck_15_gun_yakn_gzlm_drm, a.dj_f, a.onck_bddk_nkt_karslk,
                 a.onck_bddk_gnakdi_karslk, a.nkt_karslk_drm, a.gnakdi_karslk_drm, a.tplm_karslk_drm, a.ing_sktr_krlm_2, a.ing_sktr_krlm_2_acklm,
                 a.ing_sktr_krlm_3, a.ing_sktr_krlm_3_acklm, a.onck_krnotu, a.son_tklf_trh, a.knl_kod, a.knl_kod_acklm, a.ytk_kod, a.ytk_kod_acklm,
                 a.max_tklf_lmt_trh, a.forbal_f, a.forbal_bits_trh, a.onck_ay_son_gun_krnotu, a.sim_trh, a.sim_ciro, a.mus_tip, a.gnakdi_ilk_klndrm_trh,
                 a.gnakdi_ilk_klndrm_tutar, a.nkt_ilk_klndrm_trh, a.nkt_ilk_klndrm_tutar, a.tkp_acls_trh_350, a.tkp_acls_tutar_350, a.tkp_acls_tutar_gnakdi,
                 a.tkp_acls_trh_170, a.tkp_acls_tutar_170, a.tkp_acls_tutar_180, a.yplndrm_gnakdi_rsk, a.yplndrm_nkt_rsk, a.onck_brm_kod,
                 a.c1_giris_trh, a.c1_kynk_isim, a.c1_avkt_atama_trh, a.c1_avkt_no, a.c1_avkt_ad_soyad, a.c1_giris_trh_tplm_rsk, a.c1_giris_trh_nkt_rsk,
                 a.c1_giris_trh_gckme_gun_adet, a.c1_avkt_atm_trh_tplm_rsk, a.c1_avk_atm_rsk_nkt_rsk, a.c1_drm_kod, a.onck_ay_ana_sube, a.onck_90_gun_yakn_gzlm_drm,
                 a.ilk_yplndrm_trh, a.clsm_skl_yeni, a.tcmb_acklm
            FROM dm_infoman.PORTFOY_RAPOR a
           WHERE 1=1
                 and a.kst_trh =hatali_data_for.kst_trh_dgru_data
                 and a.mus_no<>1760030
                 and a.mus_no=hatali_data_for.mus_no;
          COMMIT;
          v_line_no := $$PLSQL_LINE;
       END LOOP;
    END gry_dnk_clstrmada_data_dzltme;

    v_partition_name := 'P_' || SUBSTR(TO_CHAR(v_tarih,'YYYYMMDD'),1,8);
    --EXECUTE IMMEDIATE 'ALTER TABLE dm_infoman.PORTFOY_RAPOR TRUNCATE PARTITION ' || v_partition_name ;

    v_line_no := $$PLSQL_LINE;
    -- INSERT INTO DM_INFOMAN.PORTFOY_RAPOR    INSERT INTO PORTFOY_RAPOR   insert into portfoy_rapor insert INTO dm_infoman.portfoy_rapor

    --ALTER TABLE PORTFOY_RAPOR EXCHANGE PARTITION P_20151110 WITH TABLE TRFM.TMP_PRTFY_RPR_03 INCLUDING INDEXES WITHOUT VALIDATION;
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.PRC_UTL_OBJECT('PORTFOY_RAPOR',v_partition_name,'TRFM.TMP_PRTFY_RPR_03','atep',v_sqlcode,v_sqlcodeexp);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(v_sqlcode)||v_sqlcodeexp);
    END IF;

    v_line_no := $$PLSQL_LINE;


    --exchange yapýlan partitiona analiz geçilmesi.
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object (p_ObjectName=> 'PORTFOY_RAPOR',
                                                       p_SubObjectName=> v_partition_name,
                                                       p_SubObjectName2=> NULL,
                                                       p_OperationType=> 'at',
                                                       p_SqlCode=> v_sqlcode,
                                                       p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;

    v_line_no := $$PLSQL_LINE;


DELETE FROM dm_infoman.YAPILNDRLN_KRD WHERE rpr_trh = v_tarih;

INSERT      /*+ APPEND */ INTO dm_infoman.YAPILNDRLN_KRD
SELECT v_tarih AS rpr_trh,
       a.musteri as mus_no,
       a.sube as sube_kod,
       a.reftur as rfrns_tur,
       a.refsirano as rfrns_sira_no,
       a.refnitelik as rfrns_nitlk,
       a.durum as drm,
       b.kod_aciklamasi as drm_acklm,
       a.acilissube as acls_sube,
       a.acilistarih as acls_trh,
       a.ilkvadetarih as ilk_vade_trh,
       a.kapanistarih as kpns_trh,
       a.taksitsayisi as tkst_adet,
       a.odemevadeno as odm_vade_no,
       g.krd_tutar,
       g.odnn_tutar,
       g.kln_bky,
       a.faizoran,
       g.son_odnn_tkst_no,
       g.kln_tkst,
       g.tkst_tutar,
       t.gercekkomisyon+t.masraf as yplndrm_kmsyn,
       g.gckn_tkst_tutar,
       g.gckn_tkst_adet,
       a.kampanyano as kmpn_no,
       kam.kampanya_adi as kmpn_ad,
       kam.aciklama as acklm,
       TO_NUMBER (hes.ana || LPAD (hes.alt, 2, 0) || hes.tali1 || hes.tali2) as thp,
       CASE WHEN y.restloanid IS NULL THEN 0 ELSE 1 END gkts_giris_f,
       sysdate as etl_trh,
       v_sp_name as etl_job,
       a.kreditutar as krd_klndrm_tutar,
       g.vade_trh,
       g.anpr,
       g.odnn_anpr,
       g.kln_anpr,
       t.kodaciklama as taksittip,
       bk.para,
       CASE WHEN r.yeni_sube IS NOT NULL THEN (r.yeni_sube || '-' || r.yeni_reftur || '-' || r.yeni_refsirano) ELSE NULL END dvr_edln_rfrns
  FROM extr.FS_BKRMASTER a
       LEFT OUTER JOIN extr.FS_KOLON_DEGER_ACIKLAMASI b
           ON     TO_CHAR (a.durum) = TO_CHAR (b.kolon_kodu)
              AND b.kolon_adi = 'durum'
              AND b.tablo_adi = 'bkrmaster'
       LEFT OUTER JOIN extr.fs_secimparam t
           ON     TO_CHAR (a.taksittip) = TO_CHAR (t.kod)
              AND t.secimtip=680
       LEFT OUTER JOIN (SELECT a.sube,
                               a.reftur,
                               a.refsirano,
                               SUM (a.anapara + a.faiz + a.bsmv) AS krd_tutar,
                               SUM ( CASE WHEN a.durum <> 0
                                          THEN a.anapara + a.faiz + a.bsmv
                                          ELSE 0
                                     END )
                               AS ODNN_TUTAR,
                               SUM ( CASE WHEN a.durum = 0
                                          THEN a.anapara + a.faiz + a.bsmv
                                          ELSE 0
                                   END) AS KLN_BKY,
                               COUNT (a.taksitno) AS toplam_taksit_adet,
                               SUM (CASE WHEN a.durum <> 0 THEN 1 ELSE 0 END) AS odenen_taksit_adet,
                               SUM (CASE WHEN a.durum = 0 THEN 1 ELSE 0 END) AS kln_tkst,
                               MAX (a.son_odnn_tkst_no) AS son_odnn_tkst_no,
                               MAX (a.tkst_tutar) AS tkst_tutar,
                               SUM (
                                   CASE WHEN a.durum = 0 AND a.vadetarih <= v_tarih
                                        THEN 1
                                        ELSE 0
                                   END) AS gckn_tkst_adet,
                               SUM ( CASE WHEN a.durum = 0 AND a.vadetarih <= v_tarih
                                       THEN a.anapara + a.faiz + a.bsmv
                                       ELSE 0
                                     END) AS gckn_tkst_tutar,
                               SUM (a.gecikme) AS odenen_gecikme_faiz,
                               MAX (a.vadetarih) AS vade_trh,
                               SUM (a.anapara) AS anpr,
                               SUM ( CASE WHEN a.durum <> 0
                                          THEN a.anapara
                                          ELSE 0
                                     END )
                               AS ODNN_ANPR,
                              SUM ( CASE WHEN a.durum = 0
                                         THEN a.anapara
                                         ELSE 0
                                      END) AS KLN_ANPR
                          FROM (SELECT y.sube, y.reftur, y.refsirano, y.taksitno, y.vadetarih, y.odemetarih, y.anapara, y.gecikme, y.faiz, y.bsmv, y.durum,
                                       MAX ( CASE WHEN durum <> 0 THEN taksitno END)
                                            OVER ( PARTITION BY y.sube, y.reftur, y.refsirano ORDER BY taksitno) AS son_odnn_tkst_no,
                                       MAX( manapara + mfaiz + mbsmv ) KEEP (DENSE_RANK FIRST ORDER BY (CASE WHEN vadetarih>=v_tarih THEN vadetarih END) asc)
                                            OVER (PARTITION BY  y.sube, y.reftur, y.refsirano) AS tkst_tutar
                                  FROM extr.FS_BKRHRKT y) a
                          LEFT OUTER JOIN extr.FS_KOLON_DEGER_ACIKLAMASI b
                               ON TO_CHAR (a.durum) = TO_CHAR (b.kolon_kodu)
                                  AND b.kolon_adi = 'durum'
                                  AND b.tablo_adi = 'bkrhrkt'
                         WHERE a.durum <> 99
                        GROUP BY a.sube, a.reftur, a.refsirano) g
           ON     a.sube = g.sube
              AND a.reftur = g.reftur
              AND a.refsirano = g.refsirano
       LEFT OUTER JOIN extr.FS_TKRD_DETAY t
           ON     a.sube = t.sube
              AND a.reftur = t.reftur
              AND a.refsirano = t.refsirano
       LEFT OUTER JOIN (SELECT DISTINCT restloanid FROM extr.COLL_CORP_COLLECTION_REST_F) y
           ON a.sube || '' || a.reftur || '' || a.refsirano = REPLACE(y.restloanid,'-')
       LEFT OUTER JOIN extr.FS_KAMPANYA kam
           ON a.kampanyano=kam.kampanya_id
       LEFT OUTER JOIN extr.FS_DUNPLDET_SG hes
           ON a.musteri=hes.ilk7 and a.sube=hes.sube and a.krdhestur=hes.hestur and a.krdekno=hes.ekno
       INNER JOIN extr.FS_SECIMPARAM k
           ON a.kampanyano = TRIM(k.kodaciklama) and k.secimtip = 93009
       LEFT OUTER JOIN extr.FS_ESKIYENIREFERANS r
                       ON     1 = 1
                          AND a.sube = r.eski_sube
                          AND a.reftur = r.eski_reftur
                          AND TO_CHAR (a.refsirano) = r.eski_refsirano
       LEFT OUTER JOIN extr.FS_BKRMASTER bk
                       ON     1 = 1
                          AND a.sube = bk.sube
                          AND a.reftur = bk.reftur
                          AND a.refsirano = bk.refsirano
 WHERE 1=1
 and a.musteri<>1760030
       AND a.durum <> 99;
                                                                                      /*and a.kampanyano IN ('20120913171028976100', --YYAP ACIK- AYLIK
                        '20110128102038805506',
                        '20110128102315805593',
                        '20110128102642805836',
                        '20110128173940817456',
                        '20110131115033827238', --YYAPKR-TMT
                        '20110222155351089072', --YYAPKR-TMTAYLIK
                        '20120430122619734630',
                        '20130712131503387796', --KGF-TL-YYAP
                        '20130712132019388944', --KGF-USD-YYAP
                        '20140327174652140029', --YYAPKR- TICARI
                        '20140327174839140850', --YYAPKR- TICARI- AYLIK
                        '20151016194817801752', --YYAP-ESNEK ÖDEMELI-2
                        '20151106140933814488', --YYAP-ESNEK-YP USD
                        '20151106140746813218', --YYAP-ESNEK YP-EUR
                        '20151106160100892887', --YYAP-ESNEK ÖDEME-USD 2
                        '20151106161140900763', --YYAAP-ESNEK ÖDEME EUR 2
                        '20151207110425560000', --YYAP-ESNEK-USD
                        '20151207110630562429', --YYAP-ESNEK-EUR
                        '20151117161043075055', --YYAP- ESNEK ÖDEME ST
                        '20151117161552078199'  --YYAP-EÞIT TAKSIT
                       );
        */

   COMMIT;

   v_line_no := $$PLSQL_LINE;

       TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_ECL_RWA_ANLZ',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP); --Farkli Semadaki Temp Tablo Truncate Edilir.
        IF V_SQLCODE<>0 THEN
            RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
        END IF;

    v_line_no := $$PLSQL_LINE;


   INSERT      /*+ APPEND */ INTO trfm.tmp_ecl_rwa_anlz
   SELECT tarih, grid, rating, limit, toplam_risk, pd, ead, lgd, rwa, vortex_ecl, ilave_20_mio_eur_tl_tutar, lg, woff, nihai_ecl, sube, rw, sube_ad, bolgeadi, mus_no,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM (
            SELECT e.tarih, e.grid, e.rating, e.limit, e.toplam_risk, e.pd, e.ead, e.lgd, e.rwa, e.vortex_ecl, e.ilave_20_mio_eur_tl_tutar, e.lg, e.woff, e.nihai_ecl, e.sube, e.rw,
                   h.subeadi AS sube_ad, h.bolgeadi,
                   pr.mus_no,
         --          pr.firm_lmt, pr.nkt_rsk, pr.gnakdi_rsk, pr.tplm_rsk, pr.prtfy_kod,
         --          pr.iptk_1,pr.iptk_2,pr.iptk_3, pr.iptk_exprt_1,pr.iptk_exprt_2,pr.iptk_exprt_3, pr.arac_rehni, pr.cek,pr.cek_mvdt_rehni,
         --          pr.firm_grnt, pr.hat_rehni, pr.rhn, pr.tmnt_senet, pr.tmnt_senet_mvdt_rehni, pr.mvdt_rehni,
         --          pr.clsm_skl_yeni,
                   ROW_NUMBER() OVER (PARTITION BY pr.kst_trh, pr.grid_no ORDER BY tplm_rsk DESC) AS sira_riske_gore
              FROM trfm.tmp_ecl_rwa_yeni_hist e
                   LEFT JOIN dm_infoman.portfoy_rapor pr ON 1=1
                                                         AND e.grid = pr.grid_no
                                                         AND e.tarih = pr.kst_trh
                                                         AND pr.kst_trh >= TO_DATE( '30.11.2016','DD.MM.YYYY')
                   LEFT JOIN extr.fs_bcekbolgem h ON 1=1 AND e.sube = h.sube
          )
    WHERE 1=1
          AND sira_riske_gore = 1
          and mus_no<>1760030;

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
END SP_PORTFOY_RAPORU;






PROCEDURE SP_PRTFY_RPR_KYT_DGSM  (p_tarih IN DATE DEFAULT trunc(sysdate-1) )
IS

   v_SqlCode          NUMBER (10);
   v_SqlCodeExp       VARCHAR2 (200);
   v_line_no          NUMBER;
   v_sp_name          VARCHAR2 (40) := 'SP_PRTFY_RPR_KYT_DGSM';
   v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
   v_tarih            DATE          := trunc(sysdate-1);

   v_partition_name   VARCHAR2(100);

BEGIN

    ETL.PKG_UTIL_LIB.PRC_LOG_BEGIN (g_module_name, g_package_name, g_owner, v_sp_name, v_etl_tarih, g_is_restartable);

    v_tarih := trunc(p_tarih);
    v_line_no := $$PLSQL_LINE;

    --DELETE FROM DM_INFOMAN.PRTFY_RPR_KYT_DGSM WHERE trh = v_tarih;
    v_partition_name := 'P_' || SUBSTR(TO_CHAR(v_tarih,'YYYYMMDD'),1,8);

    EXECUTE IMMEDIATE 'ALTER TABLE dm_infoman.PRTFY_RPR_KYT_DGSM TRUNCATE PARTITION ' || v_partition_name ;
    v_line_no := $$PLSQL_LINE;

    INSERT                                  /*+ APPEND */ INTO dm_infoman.PRTFY_RPR_KYT_DGSM
    SELECT a.kst_trh as trh,
           a.mus_no,
           a.ana_sube,
           6 as dgsm_grp_kod,
           CASE
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Yeni Devir/Yapýlandýrmadan Gelen'
               THEN 6101
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Yeni Devir/Önizlemeden Gelen'
               THEN 6102
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Yeni Devir/Ýzlemeden Gelen'
               THEN 6103
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Yeni Devir/Aktifden Gelen'
               THEN 6104
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kýsmi Kapama'
               THEN 6205
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/Yapýlandýrmaya Transfer'
               THEN 6206
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/Satýþ'
               THEN 6207
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/Önizlemeye Transfer'
               THEN 6208
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/Nakit Kapama'
               THEN 6209
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/izlemeye Transfer'
               THEN 6210
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/Aktiften Silme/write off'
               THEN 6211
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Kapama/Aktife Transfer'
               THEN 6212
               WHEN a.nkt_rsk_tkp_drm_1 = 'NPL-Bakiyesi Artan'
               THEN 6113
           END
               AS dgsm_kod,
           a.clsm_skl,
           a.onck_clsm_skl as pre_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr as pre_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm as pre_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk as pre_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk as pre_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar as pre_gckmeli_tutar,
           CASE WHEN a.nkt_rsk_tkp_drm_1 in ('NPL-Yeni Devir/Yapýlandýrmadan Gelen',
                'NPL-Yeni Devir/Önizlemeden Gelen',
                'NPL-Yeni Devir/Ýzlemeden Gelen',
                'NPL-Yeni Devir/Aktifden Gelen')
                THEN a.nkt_rsk
                WHEN a.nkt_rsk_tkp_drm_1 in 'NPL-Kýsmi Kapama'
                THEN a.onck_nakdi_rsk-a.nkt_rsk
                WHEN a.nkt_rsk_tkp_drm_1 in  (
                'NPL-Kapama/Yapýlandýrmaya Transfer',
                'NPL-Kapama/Satýþ',
                'NPL-Kapama/Önizlemeye Transfer',
                'NPL-Kapama/Nakit Kapama',
                'NPL-Kapama/izlemeye Transfer',
                'NPL-Kapama/Aktiften Silme/write off',
                'NPL-Kapama/Aktife Transfer')
                THEN a.onck_nakdi_rsk ELSE a.nkt_rsk-a.onck_nakdi_rsk
           END as dgsm_bky,--statu_degisim_bakiye
           sysdate as etl_trh,
           'NPL' as etl_job
      FROM dm_infoman.PORTFOY_RAPOR a
     WHERE a.nkt_rsk_tkp_drm_1 IN
               ('NPL-Yeni Devir/Yapýlandýrmadan Gelen',
                'NPL-Yeni Devir/Önizlemeden Gelen',
                'NPL-Yeni Devir/Ýzlemeden Gelen',
                'NPL-Yeni Devir/Aktifden Gelen',
                'NPL-Kýsmi Kapama',
                'NPL-Kapama/Yapýlandýrmaya Transfer',
                'NPL-Kapama/Satýþ',
                'NPL-Kapama/Önizlemeye Transfer',
                'NPL-Kapama/Nakit Kapama',
                'NPL-Kapama/izlemeye Transfer',
                'NPL-Kapama/Aktiften Silme/write off',
                'NPL-Kapama/Aktife Transfer',
                'NPL-Bakiyesi Artan')
           AND a.kst_trh =v_tarih-->= '31/12/2013'
           and a.mus_no<>1760030
  UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           4 as dgsm_grp_kod,
           CASE
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Yeni Devir/Ön Ýzlemeden Gelen'
               THEN
                   4101
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Yeni Devir/NPL den Gelen'
               THEN
                   4102
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Yeni Devir/Ýzlemeden Gelen'
               THEN
                   4103
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Yeni Devir/Aktifden Gelen'
               THEN
                   4104
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Önizlemeye Transfer'
               THEN
                   4205
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-NPL e Transfer'
               THEN
                   4206
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Kýsmý Kapama'
               THEN
                   4207
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Kapama'
               THEN
                   4208
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Ýzlemeye Transfer'
               THEN
                   4209
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Bakiyesi Artan'
               THEN
                   4110
               WHEN a.nkt_rsk_yplndrm_drm_1 = 'RS-Aktive Transfer'
               THEN
                   4211
           END
               AS change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           A.onck_gckmeli_tutar,
           CASE WHEN a.nkt_rsk_yplndrm_drm_1 in ('RS-Yeni Devir/Aktifden Gelen',
                'RS-Yeni Devir/Ýzlemeden Gelen',
                'RS-Yeni Devir/NPL den Gelen',
                'RS-Yeni Devir/Ön Ýzlemeden Gelen')
                THEN a.nkt_rsk
                WHEN a.nkt_rsk_tkp_drm_1 in 'RS-Kýsmý Kapama'
                THEN a.onck_nakdi_rsk-a.nkt_rsk
                WHEN a.nkt_rsk_yplndrm_drm_1 in ('RS-Aktive Transfer',
                'RS-Ýzlemeye Transfer',
                'RS-Kapama',
                'RS-NPL e Transfer',
                'RS-Önizlemeye Transfer')
                THEN a.onck_nakdi_rsk ELSE a.nkt_rsk-a.onck_nakdi_rsk
           END as statu_degisim_bakiye,
           sysdate as etl_trh,
           'RS' as etl_job
      FROM dm_infoman.portfoy_rapor a
     WHERE a.nkt_rsk_yplndrm_drm_1 IN
               ('RS-Aktive Transfer',
                'RS-Bakiyesi Artan',
                'RS-Ýzlemeye Transfer',
                'RS-Kapama',
                'RS-Kýsmý Kapama',
                'RS-NPL e Transfer',
                'RS-Önizlemeye Transfer',
                'RS-Yeni Devir/Aktifden Gelen',
                'RS-Yeni Devir/Ýzlemeden Gelen',
                'RS-Yeni Devir/NPL den Gelen',
                'RS-Yeni Devir/Ön Ýzlemeden Gelen')
           AND a.kst_trh =v_tarih-->= '31/12/2013'
  UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           3 as change_statu_grup,
           CASE
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Yeni Devir/Yapýlandýrmadan Gelen'
               THEN
                   3101
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Yeni Devir/Ön Ýzlemeden Gelen'
               THEN
                   3102
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Yeni Devir/NPL den Gelen'
               THEN
                   3103
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Yeni Devir/Aktif Gelen'
               THEN
                   3104
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Yapýlandýrmaya Transfer'
               THEN
                   3205
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-ÖnizlemeyeTransfer'
               THEN
                   3206
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-NPL e Transfer'
               THEN
                   3207
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Kýsmý Kapama'
               THEN
                   3208
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Kapama'
               THEN
                   3209
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Bakiyesi Artan'
               THEN
                   3110
               WHEN a.nkt_rsk_izlm_drm_1 = 'WL-Aktive Transfer'
               THEN
                   3211
           END
               AS change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar,
           CASE WHEN a.nkt_rsk_izlm_drm_1 in ('WL-Yeni Devir/Aktif Gelen',
                                            'WL-Yeni Devir/NPL den Gelen',
                                            'WL-Yeni Devir/Ön Ýzlemeden Gelen',
                                            'WL-Yeni Devir/Yapýlandýrmadan Gelen')
                THEN a.nkt_rsk
                WHEN a.nkt_rsk_tkp_drm_1 in 'WL-Kýsmý Kapama'
                THEN a.onck_nakdi_rsk-a.nkt_rsk
                WHEN a.nkt_rsk_izlm_drm_1 in ('WL-Aktive Transfer',
                                            'WL-Kapama',
                                            'WL-NPL e Transfer',
                                            'WL-ÖnizlemeyeTransfer',
                                            'WL-Yapýlandýrmaya Transfer')
                THEN a.onck_nakdi_rsk ELSE a.nkt_rsk-a.onck_nakdi_rsk
           END as statu_degisim_bakiye,
           sysdate as etl_trh,
           'WL' as etl_job
      FROM dm_infoman.portfoy_rapor a
     WHERE a.nkt_rsk_izlm_drm_1 IN
               ('WL-Aktive Transfer',
                'WL-Bakiyesi Artan',
                'WL-Kapama',
                'WL-Kýsmý Kapama',
                'WL-NPL e Transfer',
                'WL-ÖnizlemeyeTransfer',
                'WL-Yapýlandýrmaya Transfer',
                'WL-Yeni Devir/Aktif Gelen',
                'WL-Yeni Devir/NPL den Gelen',
                'WL-Yeni Devir/Ön Ýzlemeden Gelen',
                'WL-Yeni Devir/Yapýlandýrmadan Gelen')
           AND a.kst_trh =v_tarih-->= '31/12/2013'
           and a.mus_no<>1760030
  UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           2 as change_statu_grup,
           CASE
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Yeni Devir/Yapýlandýrmadan Gelen'
               THEN
                   2101
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Yeni Devir/NPL den Gelen'
               THEN
                   2102
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Yeni Devir/Aktifden Gelen'
               THEN
                   2103
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Yeni Devir/ Ýzlemeden Gelen'
               THEN
                   2104
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Yapýlandýrmaya Transfer'
               THEN
                   2205
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-NPL e Transfer'
               THEN
                   2206
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Kýsmý Kapama'
               THEN
                   2207
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Kapama'
               THEN
                   2208
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Ýzlemeye Transfer'
               THEN
                   2209
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Bakiyesi Artan'
               THEN
                   2110
               WHEN a.nkt_rsk_onzlm_drm_1 = 'WB-Aktive Transfer'
               THEN
                   2211
           END AS change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar,
           CASE WHEN a.nkt_rsk_onzlm_drm_1 in ('WB-Yeni Devir/ Ýzlemeden Gelen',
                'WB-Yeni Devir/Aktifden Gelen',
                'WB-Yeni Devir/NPL den Gelen',
                'WB-Yeni Devir/Yapýlandýrmadan Gelen')
                THEN a.nkt_rsk
                WHEN a.nkt_rsk_tkp_drm_1 in 'WB-Kýsmý Kapama'
                THEN a.onck_nakdi_rsk-a.nkt_rsk
                WHEN a.nkt_rsk_onzlm_drm_1 in ('WB-Aktive Transfer',
                'WB-Ýzlemeye Transfer',
                'WB-Kapama',
                'WB-NPL e Transfer',
                'WB-Yapýlandýrmaya Transfer')
                THEN a.onck_nakdi_rsk ELSE a.nkt_rsk-a.onck_nakdi_rsk
           END as statu_degisim_bakiye,
           sysdate as etl_trh,
           'WB' as etl_job
      FROM dm_infoman.portfoy_rapor a
     WHERE a.nkt_rsk_onzlm_drm_1 IN
               ('WB-Aktive Transfer',
                'WB-Bakiyesi Artan',
                'WB-Ýzlemeye Transfer',
                'WB-Kapama',
                'WB-Kýsmý Kapama',
                'WB-NPL e Transfer',
                'WB-Yapýlandýrmaya Transfer',
                'WB-Yeni Devir/ Ýzlemeden Gelen',
                'WB-Yeni Devir/Aktifden Gelen',
                'WB-Yeni Devir/NPL den Gelen',
                'WB-Yeni Devir/Yapýlandýrmadan Gelen')
           AND a.kst_trh =v_tarih-->= '31/12/2013'
           and   a.mus_no<>1760030
  UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           1 as change_statu_grup,
           CASE
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Yeni Devir/Yapýlandýrmadan Gelen'
               THEN
                   1101
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Yeni Devir/Önizlemeden Gelen'
               THEN
                   1102
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Yeni Devir/NPL den Gelen'
               THEN
                   1103
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Yeni Devir/ Ýzlemeden Gelen'
               THEN
                   1104
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Yapýlandýrmaya Transfer'
               THEN
                   1205
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Önizlemeye Devir'
               THEN
                   1206
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-NPL e Transfer'
               THEN
                   1207
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Kýsmý Kapama'
               THEN
                   1208
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Kapama'
               THEN
                   1209
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Ýzlemeye Transfer'
               THEN
                   1210
               WHEN a.nkt_rsk_aktf_drm_1 = 'ACT-Bakiyesi Artan'
               THEN
                   1111
           END AS change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar,
           CASE WHEN a.nkt_rsk_aktf_drm_1 in ('ACT-Yeni Devir/ Ýzlemeden Gelen',
                'ACT-Yeni Devir/NPL den Gelen',
                'ACT-Yeni Devir/Önizlemeden Gelen',
                'ACT-Yeni Devir/Yapýlandýrmadan Gelen')
                THEN a.nkt_rsk
                WHEN a.nkt_rsk_tkp_drm_1 in 'ACT-Kýsmý Kapama'
                THEN a.onck_nakdi_rsk-a.nkt_rsk
                WHEN a.nkt_rsk_aktf_drm_1 in (
                'ACT-Ýzlemeye Transfer',
                'ACT-Kapama',
                'ACT-NPL e Transfer',
                'ACT-Önizlemeye Devir',
                'ACT-Yapýlandýrmaya Transfer')
                THEN a.onck_nakdi_rsk ELSE a.nkt_rsk-a.onck_nakdi_rsk
           END as statu_degisim_bakiye,
           sysdate as etl_trh,
           'ACT' as etl_job
      FROM dm_infoman.portfoy_rapor a
     WHERE a.nkt_rsk_aktf_drm_1 IN
               ('ACT-Bakiyesi Artan',
                'ACT-Ýzlemeye Transfer',
                'ACT-Kapama',
                'ACT-Kýsmý Kapama',
                'ACT-NPL e Transfer',
                'ACT-Önizlemeye Devir',
                'ACT-Yapýlandýrmaya Transfer',
                'ACT-Yeni Devir/ Ýzlemeden Gelen',
                'ACT-Yeni Devir/NPL den Gelen',
                'ACT-Yeni Devir/Önizlemeden Gelen',
                'ACT-Yeni Devir/Yapýlandýrmadan Gelen')
           AND a.kst_trh =v_tarih-->= '31/12/2013'
           and   a.mus_no<>1760030
     UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           7 as change_statu_grup,
           CASE WHEN (a.onck_clsm_skl=2 and a.clsm_skl=3) THEN 23
                WHEN (a.onck_clsm_skl=3 and a.clsm_skl=2) THEN 32
                WHEN (a.onck_clsm_skl=2 and a.clsm_skl=4) THEN 24
                WHEN (a.onck_clsm_skl=4 and a.clsm_skl=2) THEN 42
                WHEN (a.onck_clsm_skl=2 and a.clsm_skl=5) THEN 25
                WHEN (a.onck_clsm_skl=5 and a.clsm_skl=2) THEN 52
                WHEN (a.onck_clsm_skl=3 and a.clsm_skl=4) THEN 34
                WHEN (a.onck_clsm_skl=4 and a.clsm_skl=3) THEN 43
                WHEN (a.onck_clsm_skl=3 and a.clsm_skl=5) THEN 35
                WHEN (a.onck_clsm_skl=5 and a.clsm_skl=3) THEN 53
                WHEN (a.onck_clsm_skl=4 and a.clsm_skl=5) THEN 45
                WHEN (a.onck_clsm_skl=5 and a.clsm_skl=4) THEN 54
                WHEN (a.onck_clsm_skl=1 and a.clsm_skl=2) THEN 12
                WHEN (a.onck_clsm_skl=1 and a.clsm_skl=3) THEN 13
                WHEN (a.onck_clsm_skl=1 and a.clsm_skl=4) THEN 14
                WHEN (a.onck_clsm_skl=1 and a.clsm_skl=5) THEN 15
           END as change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar,
           a.nkt_rsk-a.onck_nakdi_rsk as degisim_bakiye,
           sysdate as etl_trh,
           'Çalýþma Þekli' as etl_job
      FROM dm_infoman.portfoy_rapor a
     WHERE a.kst_trh =v_tarih-->='31/12/2013'
           and a.clsm_skl<>a.onck_clsm_skl
           and   a.mus_no<>1760030
   UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           8 as change_statu_grup,
           CASE WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=2) THEN 12
                WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=3) THEN 13
                WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=4) THEN 14
                WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=5) THEN 15
                WHEN (a.onck_yakn_gzlm_drm=1 and a.yakn_gzlm_drm=6) THEN 16
                WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=1) THEN 21
                WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=3) THEN 23
                WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=4) THEN 24
                WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=5) THEN 25
                WHEN (a.onck_yakn_gzlm_drm=2 and a.yakn_gzlm_drm=6) THEN 26
                WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=1) THEN 31
                WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=2) THEN 32
                WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=4) THEN 34
                WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=5) THEN 35
                WHEN (a.onck_yakn_gzlm_drm=3 and a.yakn_gzlm_drm=6) THEN 36
                WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=1) THEN 41
                WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=2) THEN 42
                WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=3) THEN 43
                WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=5) THEN 45
                WHEN (a.onck_yakn_gzlm_drm=4 and a.yakn_gzlm_drm=6) THEN 46
                WHEN (a.onck_yakn_gzlm_drm=5 and a.yakn_gzlm_drm=1) THEN 51
                WHEN (a.onck_yakn_gzlm_drm=5 and a.yakn_gzlm_drm=2) THEN 52
                WHEN (a.onck_yakn_gzlm_drm=5 and a.yakn_gzlm_drm=3) THEN 53
                WHEN (a.onck_yakn_gzlm_drm=5 and a.yakn_gzlm_drm=4) THEN 54
                WHEN (a.onck_yakn_gzlm_drm=5 and a.yakn_gzlm_drm=6) THEN 56
                WHEN (a.onck_yakn_gzlm_drm=6 and a.yakn_gzlm_drm=1) THEN 61
                WHEN (a.onck_yakn_gzlm_drm=6 and a.yakn_gzlm_drm=2) THEN 62
                WHEN (a.onck_yakn_gzlm_drm=6 and a.yakn_gzlm_drm=3) THEN 63
                WHEN (a.onck_yakn_gzlm_drm=6 and a.yakn_gzlm_drm=4) THEN 64
                WHEN (a.onck_yakn_gzlm_drm=6 and a.yakn_gzlm_drm=5) THEN 65
           END as change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar,
           a.nkt_rsk-a.onck_nakdi_rsk as degisim_bakiye,
           sysdate as etl_trh,
           'Yakýn Gözlem Statu' as etl_job
      FROM dm_infoman.PORTFOY_RAPOR a
     WHERE a.kst_trh=v_tarih-->='31/12/2013'
           and a.onck_yakn_gzlm_drm<>a.yakn_gzlm_drm
           and a.onck_yakn_gzlm_drm in (1,2,3,4,5,6) and a.yakn_gzlm_drm in (1,2,3,4,5,6)
           and   a.mus_no<>1760030
  UNION ALL
    SELECT a.kst_trh,
           a.mus_no,
           a.ana_sube,
           9 as change_statu_grup,
           CASE WHEN (SUBSTR(a.onck_rsk_ktgr,1,1)='C' and SUBSTR(a.rsk_ktgr,1,1)='M') THEN 12
                WHEN (SUBSTR(a.onck_rsk_ktgr,1,1)='M' and SUBSTR(a.rsk_ktgr,1,1)='C') THEN 21
                WHEN (SUBSTR(a.onck_rsk_ktgr,1,1)='C' and SUBSTR(a.rsk_ktgr,1,1)='R') THEN 13
                WHEN (SUBSTR(a.onck_rsk_ktgr,1,1)='R' and SUBSTR(a.rsk_ktgr,1,1)='C') THEN 31
                WHEN (SUBSTR(a.onck_rsk_ktgr,1,1)='M' and SUBSTR(a.rsk_ktgr,1,1)='R') THEN 23
                WHEN (SUBSTR(a.onck_rsk_ktgr,1,1)='R' and SUBSTR(a.rsk_ktgr,1,1)='M') THEN 32
           END as change_statu_kod,
           a.clsm_skl,
           a.onck_clsm_skl,
           a.rsk_ktgr,
           a.onck_rsk_ktgr,
           a.yakn_gzlm_drm,
           a.onck_yakn_gzlm_drm,
           a.sktr,
           a.brm_kod,
           a.nkt_rsk,
           a.onck_nakdi_rsk,
           a.gnakdi_rsk,
           a.tplm_rsk,
           a.onck_tplm_rsk,
           a.npl_nkt_rsk,
           a.npl_gnakdi_rsk,
           a.npl_tplm_rsk,
           a.gckmeli_tutar,
           a.onck_gckmeli_tutar,
           a.nkt_rsk-a.onck_nakdi_rsk as degisim_bakiye,
           sysdate as etl_trh,
           'Risk Kategori' as etl_job
      FROM dm_infoman.PORTFOY_RAPOR a
     WHERE a.kst_trh=v_tarih-->='31/12/2013'
     and   a.mus_no<>1760030
           and SUBSTR(a.rsk_ktgr,1,1)<>SUBSTR(A.onck_rsk_ktgr,1,1);
    COMMIT;
    v_line_no:= $$PLSQL_LINE;

    --analyze table
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object (p_ObjectName=> 'PRTFY_RPR_KYT_DGSM',
                                                       p_SubObjectName=> v_partition_name,
                                                       p_SubObjectName2=> NULL,
                                                       p_OperationType=> 'at',
                                                       p_SqlCode=> v_sqlcode,
                                                       p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
   v_line_no:= $$PLSQL_LINE;

-- END LOG
ETL.PKG_UTIL_LIB.prc_log_end;

DBMS_APPLICATION_INFO.set_module(NULL,NULL);

EXCEPTION WHEN OTHERS THEN
  v_SqlCode := SQLCODE;
  v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

  --FAILURE LOG
  etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

  RAISE;

END SP_PRTFY_RPR_KYT_DGSM;



PROCEDURE SP_IKTS_DATAMART (p_tarih IN DATE DEFAULT trunc(sysdate-1)) IS

v_tarih             DATE;
v_sqlcode           NUMBER   (10);
v_sqlcodeexp        VARCHAR2 (200);
v_sp_name           VARCHAR2 (40) := 'SP_IKTS_DATAMART';
v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
v_line_no           NUMBER;


BEGIN

    ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

    v_tarih := trunc(p_tarih);


--alttaki data bir kereye mahsus oluþturulmuþtur.

--  trfm.pkg_trfm_util_lib.prc_utl_object ('TMP_NPL_SATIS', NULL,  NULL, 'tt',  v_sqlcode,  v_sqlcodeexp);

--INSERT                                  /*+ APPEND */ INTO trfm.tmp_npl_satis

--select TO_DATE('30/04/2014','dd/mm/yyyy') tarih,f.ilk7,t.calisma_sekli, SUM(thp_390) as npl_satis_tahsilat,SUM(thp_17) as npl_satis,
--sysdate as etl_trh
--from
--(
--    select fistarih,fisno,fissicil,islsube, a.acik1,
--    MAX(CASE WHEN SUBSTR(kmhtutar,1,2)=17  and bakod='A' THEN ilk7 ELSE 0 END) as ilk7,
--    SUM(CASE WHEN kmhtutar='2900000' and bakod='A' THEN tutar ELSE 0 END) as thp_290,
--    SUM(CASE WHEN kmhtutar='3908000' and bakod='B' THEN tutar ELSE 0 END) as thp_390,
--    SUM(CASE WHEN SUBSTR(kmhtutar,1,2)=17  and bakod='A' THEN tutar ELSE 0 END) as thp_17,
--    SUM(CASE WHEN SUBSTR(kmhtutar,1,2)=88  and bakod='B' THEN tutar ELSE 0 END) as thp_88
--    from extr.fs_hrktdet_sg a
--    where
--    fistarih='22/04/2014'
--    and a.durum=0
--    group by
--    fistarih,fisno,fissicil,islsube,a.acik1
--    having
--    SUM(CASE WHEN SUBSTR(kmhtutar,1,2)=17  and bakod='A' THEN tutar ELSE 0 END)<>0
--) f, extr.fs_musteri_master t
--where
--(thp_390=thp_17 or thp_17=thp_88) and
--f.ilk7=t.musteri_no and t.calisma_sekli in (2,3,4,5)
--group by fistarih,f.ilk7,t.calisma_sekli;

--commit;



----------------------------------------------------------------------------------------------------------------

trfm.pkg_trfm_util_lib.prc_utl_object ('TMP_IKTS_THSL', NULL,  NULL, 'tt',  v_sqlcode,  v_sqlcodeexp);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

v_line_no := $$PLSQL_LINE;

INSERT                                  /*+ APPEND */ INTO trfm.TMP_IKTS_THSL

SELECT  trh,
        mus_no,
        SUM(thsl_tutar) as thsl_tutar,
        SUM(msrf_tutar) as msrf_tutar,
        SUM(anpr_tutar) as anpr_tutar,
        SUM(faiz_tutar) as faiz_tutar,
        SUM(bsmv_tutar) as bsmv_tutar,
        SUM(mtd_thsl_tutar) as mtd_thsl_tutar,
        SUM(mtd_msrf_tutar) as mtd_msrf_tutar,
        SUM(mtd_anpr_tutar) as mtd_anpr_tutar,
        SUM(mtd_faiz_tutar) as mtd_faiz_tutar,
        SUM(mtd_bsmv_tutar) as mtd_bsmv_tutar,
        SUM(ytd_thsl_tutar) as ytd_thsl_tutar,
        SUM(ytd_msrf_tutar) as ytd_msrf_tutar,
        SUM(ytd_anpr_tutar) as ytd_anpr_tutar,
        SUM(ytd_faiz_tutar) as ytd_faiz_tutar,
        SUM(ytd_bsmv_tutar) as ytd_bsmv_tutar,
        SUM(ltd_thsl_tutar) as ltd_thsl_tutar,
        SUM(ltd_msrf_tutar) as ltd_msrf_tutar,
        SUM(ltd_anpr_tutar) as ltd_anpr_tutar,
        SUM(ltd_faiz_tutar) as ltd_faiz_tutar,
        SUM(ltd_bsmv_tutar) as ltd_bsmv_tutar,
        sysdate as etl_trh
  FROM  ( SELECT  v_tarih as trh,
                  musteri as mus_no,
                  SUM(CASE WHEN fistarih = v_tarih THEN tahsilat_tutar ELSE 0 END) as thsl_tutar,
                  SUM(CASE WHEN fistarih = v_tarih THEN masraf_tutar ELSE 0 END) as msrf_tutar,
                  SUM(CASE WHEN fistarih = v_tarih THEN anapara_tutar ELSE 0 END) as anpr_tutar,
                  SUM(CASE WHEN fistarih = v_tarih THEN faiz_tutar ELSE 0 END) as faiz_tutar,
                  SUM(CASE WHEN fistarih = v_tarih THEN bsmv_tutar ELSE 0 END) as bsmv_tutar,

                  SUM(CASE WHEN fistarih between trunc(v_tarih,'mm') and v_tarih THEN tahsilat_tutar ELSE 0 END) as mtd_thsl_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'mm') and v_tarih THEN masraf_tutar ELSE 0 END) as mtd_msrf_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'mm') and v_tarih THEN anapara_tutar ELSE 0 END) as mtd_anpr_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'mm') and v_tarih THEN faiz_tutar ELSE 0 END) as mtd_faiz_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'mm') and v_tarih THEN bsmv_tutar ELSE 0 END) as mtd_bsmv_tutar,

                  SUM(CASE WHEN fistarih between trunc(v_tarih,'yy') and v_tarih THEN tahsilat_tutar ELSE 0 END) as ytd_thsl_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'yy') and v_tarih THEN masraf_tutar ELSE 0 END) as ytd_msrf_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'yy') and v_tarih THEN anapara_tutar ELSE 0 END) as ytd_anpr_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'yy') and v_tarih THEN faiz_tutar ELSE 0 END) as ytd_faiz_tutar,
                  SUM(CASE WHEN fistarih between trunc(v_tarih,'yy') and v_tarih THEN bsmv_tutar ELSE 0 END) as ytd_bsmv_tutar,

                  SUM(CASE WHEN fistarih<=v_tarih THEN tahsilat_tutar ELSE 0 END) as ltd_thsl_tutar,
                  SUM(CASE WHEN fistarih<=v_tarih THEN masraf_tutar ELSE 0 END) as ltd_msrf_tutar,
                  SUM(CASE WHEN fistarih<=v_tarih THEN anapara_tutar ELSE 0 END) as ltd_anpr_tutar,
                  SUM(CASE WHEN fistarih<=v_tarih THEN faiz_tutar  ELSE 0 END) as ltd_faiz_tutar,
                  SUM(CASE WHEN fistarih<=v_tarih THEN bsmv_tutar  ELSE 0 END) as ltd_bsmv_tutar
            FROM  extr.FS_RSK_MAHSUP_TAHSILAT
            where musteri<>1760030
        GROUP BY  musteri

      UNION ALL

    ---protokol tahsilatlarý
          SELECT  v_tarih as trh,
                  musteri as mus_no,
                  SUM(CASE WHEN a.hestur='MT' and bakod='B' and fistarih=v_tarih THEN tutar_tl ELSE 0 END) as thsl_tutar,
                  SUM(CASE WHEN a.hestur=b.hestur and a.hestip=b.hestip and bakod='A' and fistarih = v_tarih THEN tutar_tl ELSE 0 END) as msrf_tutar,
                  SUM(CASE WHEN b.hestur is null and b.hestip is null and a.sinif='C' and a.hestur<> 'MT' and fistarih=v_tarih THEN tutar_tl ELSE 0 END) as anpr_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=5 and a.hestur='0' and bakod='A' and fistarih= v_tarih THEN tutar_tl ELSE 0 END) as faiz_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=3 and a.hestur='0' and bakod='A' and fistarih= v_tarih THEN tutar_tl ELSE 0 END) as bsmv_tutar,

                  SUM(CASE WHEN a.hestur='MT' and bakod='B' and fistarih between trunc(v_tarih,'mm') and v_tarih THEN tutar_tl ELSE 0 END) as mtd_thsl_tutar,
                  SUM(CASE WHEN a.hestur=b.hestur and a.hestip=b.hestip and bakod='A' and fistarih between trunc(v_tarih,'mm') and v_tarih THEN tutar_tl ELSE 0 END) as mtd_msrf_tutar,
                  SUM(CASE WHEN b.hestur is null and b.hestip is null and a.sinif='C' and a.hestur<> 'MT' and fistarih between trunc(v_tarih,'mm') and v_tarih THEN tutar_tl ELSE 0 END) as mtd_anpr_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=5 and a.hestur='0' and bakod='A' and fistarih between trunc(v_tarih,'mm') and v_tarih THEN tutar_tl ELSE 0 END) as mtd_faiz_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=3 and a.hestur='0' and bakod='A' and fistarih between trunc(v_tarih,'mm') and v_tarih THEN tutar_tl ELSE 0 END) as mtd_bsmv_tutar,

                  SUM(CASE WHEN a.hestur='MT' and bakod='B' and fistarih between trunc(v_tarih,'yy') and v_tarih THEN tutar_tl ELSE 0 END) as ytd_thsl_tutar,
                  SUM(CASE WHEN a.hestur=b.hestur and a.hestip=b.hestip and bakod='A' and fistarih between trunc(v_tarih,'yy') and v_tarih THEN tutar_tl ELSE 0 END) as ytd_msrf_tutar,
                  SUM(CASE WHEN b.hestur is null and b.hestip is null and a.sinif='C' and a.hestur<> 'MT' and fistarih between trunc(v_tarih,'yy') and v_tarih THEN tutar_tl ELSE 0 END) as ytd_anpr_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=5 and a.hestur='0' and bakod='A' and fistarih between trunc(v_tarih,'yy') and v_tarih THEN tutar_tl ELSE 0 END) as ytd_faiz_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=3 and a.hestur='0' and bakod='A' and fistarih between trunc(v_tarih,'yy') and v_tarih THEN tutar_tl ELSE 0 END) as ytd_bsmv_tutar,

                  SUM(CASE WHEN a.hestur='MT' and bakod='B' and fistarih<=v_tarih THEN tutar_tl ELSE 0 END) as ltd_thsl_tutar,
                  SUM(CASE WHEN a.hestur=b.hestur and a.hestip=b.hestip and bakod='A' and fistarih<=v_tarih  THEN tutar_tl ELSE 0 END) as ltd_msrf_tutar,
                  SUM(CASE WHEN b.hestur is null and b.hestip is null and a.sinif='C' and a.hestur<> 'MT' and fistarih<=v_tarih   THEN tutar_tl ELSE 0 END) as ltd_anpr_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=5 and a.hestur='0' and bakod='A' and fistarih<=v_tarih  THEN tutar_tl ELSE 0 END) as ltd_faiz_tutar,
                  SUM(CASE WHEN SUBSTR(a.ilk7,1,1)=3 and a.hestur='0' and bakod='A' and fistarih<=v_tarih THEN tutar_tl ELSE 0 END) as ltd_bsmv_tutar
            FROM  extr.FS_PROTOKOL_TAKSIT_ODEME_DETAY a,
                  (SELECT hestur,hestip
                     FROM extr.fs_hestip    --bankdb.HESTIP@fsbcv
                    WHERE hestur='TS' and durum=0 and aciklama like '%(174%') b
           WHERE  a.hestip=b.hestip(+) and
                  a.hestur=b.hestur(+)
                  and musteri<>1760030
        GROUP BY  musteri

      UNION ALL

    ---boss npl tahsilat
          SELECT  v_tarih as trh,
                  TO_NUMBER(SUBSTR(cari_hesap_no,2,8)) as mus_no,
                  SUM(CASE WHEN islem_tarihi = v_tarih THEN tahsilat_tutar ELSE 0 END) as thsl_tutar,
                  SUM(CASE WHEN islem_tarihi = v_tarih THEN masraf_tutar ELSE 0 END) as msrf_tutar,
                  SUM(CASE WHEN islem_tarihi = v_tarih THEN anapara_tutar ELSE 0 END) as anpr_tutar,
                  SUM(CASE WHEN islem_tarihi = v_tarih THEN faiz_tutar ELSE 0 END) as faiz_tutar,
                  SUM(CASE WHEN islem_tarihi = v_tarih THEN bsmv_tutar ELSE 0 END) as bsmv_tutar,

                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'mm') and v_tarih THEN tahsilat_tutar ELSE 0 END) as mtd_thsl_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'mm') and v_tarih THEN masraf_tutar ELSE 0 END) as mtd_msrf_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'mm') and v_tarih THEN anapara_tutar ELSE 0 END) as mtd_anpr_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'mm') and v_tarih THEN faiz_tutar ELSE 0 END) as mtd_faiz_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'mm') and v_tarih THEN bsmv_tutar ELSE 0 END) as mtd_bsmv_tutar,

                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'yy') and v_tarih THEN tahsilat_tutar ELSE 0 END) as ytd_thsl_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'yy') and v_tarih THEN masraf_tutar ELSE 0 END) as ytd_msrf_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'yy') and v_tarih THEN anapara_tutar ELSE 0 END) as ytd_anpr_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'yy') and v_tarih THEN faiz_tutar ELSE 0 END) as ytd_faiz_tutar,
                  SUM(CASE WHEN islem_tarihi between trunc(v_tarih,'yy') and v_tarih THEN bsmv_tutar ELSE 0 END) as ytd_bsmv_tutar,

                  SUM(CASE WHEN islem_tarihi <= v_tarih THEN tahsilat_tutar ELSE 0 END) as ltd_thsl_tutar,
                  SUM(CASE WHEN islem_tarihi <= v_tarih THEN masraf_tutar ELSE 0 END) as ltd_msrf_tutar,
                  SUM(CASE WHEN islem_tarihi <= v_tarih THEN anapara_tutar ELSE 0 END) as ltd_anpr_tutar,
                  SUM(CASE WHEN islem_tarihi <= v_tarih THEN faiz_tutar ELSE 0 END) as ltd_faiz_tutar,
                  SUM(CASE WHEN islem_tarihi <= v_tarih THEN bsmv_tutar ELSE 0 END) as ltd_bsmv_tutar

            FROM  extr.OY_OY_KAT_MAHSUP_TAHSILAT a
            where TO_NUMBER(SUBSTR(cari_hesap_no,2,8))<>1760030
        GROUP BY  TO_NUMBER(SUBSTR(cari_hesap_no,2,8))

      UNION ALL

    ---npl satis
          SELECT  v_tarih as trh,
                  mus_no,
                  SUM(CASE WHEN trh = v_tarih THEN npl_sats_thsl ELSE 0 END) as thsl_tutar,
                  0 as msrf_tutar,
                  SUM(CASE WHEN trh = v_tarih THEN npl_sats_thsl ELSE 0 END) as anpr_tutar,
                  0 as faiz_tutar,
                  0 as bsmv_tutar,

                  SUM(CASE WHEN trh between trunc(v_tarih,'mm') and v_tarih THEN npl_sats_thsl ELSE 0 END) as mtd_thsl_tutar,
                  0 as mtd_msrf_tutar,
                  SUM(CASE WHEN trh between trunc(v_tarih,'mm') and v_tarih THEN npl_sats_thsl ELSE 0 END) as mtd_anpr_tutar,
                  0 as mtd_faiz_tutar,
                  0 as mtd_bsmv_tutar,

                  SUM(CASE WHEN trh between trunc(v_tarih,'yy') and v_tarih THEN npl_sats_thsl ELSE 0 END) as ytd_thsl_tutar,
                  0 as ytd_msrf_tutar,
                  SUM(CASE WHEN trh between trunc(v_tarih,'yy') and v_tarih THEN npl_sats_thsl ELSE 0 END) as ytd_anpr_tutar,
                  0 as ytd_faiz_tutar,
                  0 as ytd_bsmv_tutar,

                  SUM(CASE WHEN trh<= v_tarih THEN npl_sats_thsl ELSE 0 END) as ltd_thsl_tutar,
                  0 as ltd_msrf_tutar,
                  SUM(CASE WHEN trh<= v_tarih THEN npl_sats_thsl ELSE 0 END) as ltd_anpr_tutar,
                  0 as ltd_faiz_tutar,
                  0 as ltd_bsmv_tutar
            FROM  trfm.TMP_NPL_SATIS
            where mus_no<>1760030
        GROUP BY  MUS_NO

        ) f,
        extr.FS_MUSTERI_MASTER t
 WHERE  f.mus_no=t.musteri_no
        and t.calisma_sekli in (2,3,4,5)
  GROUP BY f.trh,f.mus_no;

COMMIT;
v_line_no := $$PLSQL_LINE;

----------------------------------------------------------------------------------------------------------------

trfm.pkg_trfm_util_lib.prc_utl_object ('TMP_IKTS', NULL,  NULL, 'tt',  v_sqlcode,  v_sqlcodeexp);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

 v_line_no := $$PLSQL_LINE;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_IKTS
SELECT  mus.tarih as kst_trh,
        mus.mus_no,
        a.gm_raf_yil as raf_yil,
        a.gm_raf_no as raf_no,
        a.ihtar_tarihi as ihtr_trh,
        a.ihtar_statu_kodu as ihtr_drm_kod,
        a.ihtar_nakit_risk as ihtr_nkt_rsk,
        a.ihtar_gayri_nakit_risk as ihtr_gnakdi_rsk,
        a.ihtar_toplam_risk as ihtr_tplm_rsk,
        a.atanan_nakit_risk as atnn_nkt_rsk,
        a.atanan_gayri_nakit_risk as atnn_gnakdi_rsk,
        a.atanan_toplam_risk as atnn_tplm_rsk,
        a.guncel_nakit_risk as gncl_nkt_rsk,
        a.guncel_gayri_nakit_risk as gncl_gnakdi_rsk,
        a.guncel_toplam_risk as gncl_tplm_rsk,
        a.sorumlu_avukat_no as srmlu_avkt_no,
        sor.ad as srmlu_avkt_ad,
        sor.soyad as srmlu_avkt_soyad,
        decode(sor.avukat_tip,2,'BD',1,'BI') as srmlu_avkt_tip,
        a.izleyen_avukat_no as izlyn_avkt_no,
        iz.ad as izlyn_avkt_ad,
        iz.soyad as izlyn_avkt_soyad,
        decode(iz.avukat_tip,2,'BD',1,'BI') as izlyn_avkt_tip,
        a.atama_tarihi as atama_trh,
        a.hukuk_devir_tarihi as hkk_dvr_trh,
        a.takip_statu_kodu as tkp_drm_kod,
        trunc (v_tarih - a.ihtar_tarihi) as ihtr_gun_adet,
        a.portfoy_sicili as prtfy_scl,
        CAST(NULL AS VARCHAR2(100 BYTE)) as rvp,
        CAST(NULL AS NUMBER(1)) as avkt_sure,
        CAST(NULL AS NUMBER(10,2)) as nkt_karslk_bky,
        CAST(NULL AS NUMBER(10,2)) as gnakdi_karslk_bky,
        CAST(NULL AS NUMBER(10,2)) as tplm_karslk_bky,
        CAST(NULL AS NUMBER(1)) as idr_knn_tkp,
        CAST(NULL AS NUMBER(6)) as dsy_yas,
        CAST(NULL AS DATE) as wrtof_trh,
        CAST(NULL AS VARCHAR2(4 BYTE)) as ktgr,
        CAST(NULL AS NUMBER(5,2)) as indrm_oran,
        CAST(NULL AS NUMBER(5,2)) as skor_tplm,
        CAST(NULL AS NUMBER(5,2)) as skor_kpm_trh,
        CAST(NULL AS NUMBER(5,2)) as skor_thsl_kblyt,
        CAST(NULL AS NUMBER(5,2)) as skor_thmn_thsl_oran,
        CAST(NULL AS NUMBER(5,2)) as skor_kfl_adet,
        CAST(NULL AS NUMBER(5,2)) as skor_ozl_hkki_drm,
        CAST(NULL AS NUMBER(5,2)) as skor_dsy_yas,
        CAST(NULL AS NUMBER(5,2)) as skor_eslstrm_oran,
        CAST(NULL AS NUMBER(5,2)) as skor_hcz_tsrf_ipt,
        CAST(NULL AS NUMBER(20,2)) as indrm_bky,
        CAST(NULL AS NUMBER(20,2)) as kmpn_thsl,
        t.hkk_dsy_adet,
        t.acik_hkk_dsy_adet,
        t.kpl_hkk_dsy_adet,
        NVL(s.thsl_tutar,0) thsl_tutar,
        NVL(s.msrf_tutar,0) msrf_tutar,
        NVL(s.anpr_tutar,0) anpr_tutar,
        NVL(s.faiz_tutar,0) faiz_tutar,
        NVL(s.bsmv_tutar,0) bsmv_tutar,
        NVL(s.mtd_thsl_tutar,0) mtd_thsl_tutar,
        NVL(s.mtd_msrf_tutar,0) mtd_msrf_tutar,
        NVL(s.mtd_anpr_tutar,0) mtd_anpr_tutar,
        NVL(s.mtd_faiz_tutar,0) mtd_faiz_tutar,
        NVL(s.mtd_bsmv_tutar,0) mtd_bsmv_tutar,
        NVL(s.ytd_thsl_tutar,0) ytd_thsl_tutar,
        NVL(s.ytd_msrf_tutar,0) ytd_msrf_tutar,
        NVL(s.ytd_anpr_tutar,0) ytd_anpr_tutar,
        NVL(s.ytd_faiz_tutar,0) ytd_faiz_tutar,
        NVL(s.ytd_bsmv_tutar,0) ytd_bsmv_tutar,
        NVL(s.ltd_thsl_tutar,0) ltd_thsl_tutar,
        NVL(s.ltd_msrf_tutar,0) ltd_msrf_tutar,
        NVL(s.ltd_anpr_tutar,0) ltd_anpr_tutar,
        NVL(s.ltd_faiz_tutar,0) ltd_faiz_tutar,
        NVL(s.ltd_bsmv_tutar,0) ltd_bsmv_tutar,
        NVL(npl.npl_sats_thsl,0) npl_sats_thsl,
        NVL(npl.ytd_npl_sats_thsl,0) ytd_npl_sats_thsl,
        NVL(npl.ltd_npl_sats_thsl,0) ltd_npl_sats_thsl,
        NVL(npl.npl_sats,0) npl_sats,
        NVL(npl.ytd_npl_sats,0) ytd_npl_sats,
        NVL(npl.ltd_npl_sats,0) ltd_npl_sats,
        CASE WHEN sor.avukat_tip=2 and NVL(a.izleyen_avukat_no,0)<>0  THEN a.izleyen_avukat_no
             WHEN NVL(a.sorumlu_avukat_no,0)=0 THEN a.izleyen_avukat_no
             ELSE a.sorumlu_avukat_no
        END as rpr_avkt_no,
        CASE WHEN sor.avukat_tip=2 and NVL(a.izleyen_avukat_no,0)<>0  THEN iz.ad
             WHEN NVL(a.sorumlu_avukat_no,0)=0 THEN iz.ad ELSE sor.ad
        END as rpr_avkt_ad,
        CASE WHEN sor.avukat_tip=2 and NVL(a.izleyen_avukat_no,0)<>0  THEN iz.soyad
             WHEN NVL(sorumlu_avukat_no,0)=0 THEN iz.soyad
             ELSE sor.soyad
        END as rpr_avkt_soyad,
        CASE WHEN sor.avukat_tip=2 and NVL(a.izleyen_avukat_no,0)<>0  THEN DECODE(iz.avukat_tip,2,'BD',1,'BI')
             WHEN NVL(a.sorumlu_avukat_no,0)=0 THEN DECODE(iz.avukat_tip,2,'BD',1,'BI')
             ELSE DECODE(sor.avukat_tip,2,'BD',1,'BI')
        END as rpr_avkt_tip,
        mus.ana_sube,
        sysdate as etl_trh,
        v_sp_name as etl_job,
        NVL(npl.mtd_npl_sats_thsl,0) as mtd_npl_sats_thsl,
        NVL(npl.mtd_npl_sats,0) as mtd_npl_sats,
        pt.ys_sicil_no as rvp_scl_no
  FROM  (SELECT DISTINCT d.ilk7 as mus_no, to_date(v_tarih,'dd/mm/yyyy') tarih, mm.ana_sube, mm.calisma_sekli
           FROM extr.FS_DUNPLDET_SG d,
                extr.FS_MUSTERI_MASTER mm
          WHERE 1=1
                and d.ana in (170,172,174,176,350)
                and d.ilk7=mm.musteri_no
                and mm.calisma_sekli in (2,3,4,5)
         UNION
         SELECT DISTINCT h.musteri_no as mus_no, to_date(v_tarih,'dd/mm/yyyy') tarih, mm.ana_sube, mm.calisma_sekli
           FROM extr.FS_HUKUK_MASTER h,
                extr.FS_MUSTERI_MASTER mm
          WHERE h.musteri_no = mm.MUSTERI_NO
        ) mus
        LEFT JOIN extr.FS_HUKUK_MASTER a ON mus.mus_no=a.musteri_no
        LEFT JOIN extr.FS_AVUKAT_TANIM sor ON a.sorumlu_avukat_no=sor.avukat_no
        LEFT JOIN extr.FS_AVUKAT_TANIM iz ON a.izleyen_avukat_no=iz.avukat_no
--        LEFT JOIN extr.FS_HUKUK_DOSYA_TABLE b ON mus.mus_no=b.musteri_no
        LEFT JOIN (SELECT musteri_no,
                        count(dosya_id) as hkk_dsy_adet,
                        SUM(CASE WHEN status='A' THEN 1 ELSE 0 END) as acik_hkk_dsy_adet,
                        SUM(CASE WHEN status='K' THEN 1 ELSE 0 END) as kpl_hkk_dsy_adet
                   FROM extr.FS_DOSYA_MASTER
                  GROUP BY musteri_no
                ) t ON mus.mus_no=t.musteri_no
        LEFT JOIN trfm.TMP_IKTS_THSL s ON mus.mus_no=s.mus_no and s.trh=v_tarih
        LEFT JOIN (  SELECT v_tarih as trh,
                            mus_no,
                            SUM(CASE WHEN trh = v_tarih THEN npl_sats_thsl ELSE 0 END) as npl_sats_thsl,
                            SUM(CASE WHEN trh between trunc(v_tarih,'yy') and v_tarih THEN npl_sats_thsl ELSE 0 END) as ytd_npl_sats_thsl,
                            SUM(CASE WHEN trh<= v_tarih THEN npl_sats_thsl ELSE 0 END) as ltd_npl_sats_thsl,
                            SUM(CASE WHEN trh = v_tarih THEN npl_sats ELSE 0 END) as npl_sats,
                            SUM(CASE WHEN trh between trunc(v_tarih,'yy') and v_tarih THEN npl_sats ELSE 0 END) as ytd_npl_sats,
                            SUM(CASE WHEN trh<= v_tarih THEN npl_sats ELSE 0 END) as ltd_npl_sats,
                            SUM(CASE WHEN trh between trunc(v_tarih,'mm') and v_tarih THEN npl_sats_thsl ELSE 0 END) as mtd_npl_sats_thsl,
                            SUM(CASE WHEN trh between trunc(v_tarih,'mm') and v_tarih THEN npl_sats ELSE 0 END) as mtd_npl_sats
                       FROM --trfm.TMP_NPL_SATIS        --22.12.2015 tarihinde alttaki kýsým ile deðiþtirildi. Kerem KURTÝÞ. Ýlteriþ MUTLU
                            (   SELECT NVL(a.trh,b.trh) as trh,
                                       NVL(a.MUS_NO,b.mus_no) as mus_no,
                                       SUM(NVL(a.npl_sats_thsl,0)+NVL(b.npl_sats_thsl,0) ) as npl_sats_thsl,
                                       SUM(NVL(a.npl_sats,0)+NVL(b.npl_sats,0) ) as npl_sats
                                  FROM trfm.TMP_NPL_SATIS a
                                       FULL JOIN   (  SELECT ml.fistarih as trh, ml.musteri as mus_no,
                                                             SUM (
                                                                  CASE WHEN ml.bakod =  'A' and ml.ilk7 = 3929990 THEN -tutar
                                                                       WHEN ml.bakod <> 'A' and ml.ilk7 = 3929990 THEN tutar
                                                                            END
                                                                 ) as npl_sats_thsl,
                                                             SUM (
                                                                  CASE WHEN ml.bakod =  'A' and ml.ilk7 = 8820090 THEN -tutar
                                                                       WHEN ml.bakod <> 'A' and ml.ilk7 = 8820090 THEN tutar
                                                                            END
                                                                 ) as npl_sats
                                                        FROM extr.FS_MUHASEBE_LOG_KURUMSAL ml
                                                       WHERE 1 = 1
                                                         AND (   (ml.ilk7 = 3929990 AND ml.ek_bilgi = 'SATIS')
                                                              OR (ml.ilk7 = 8820090 AND ml.ek_bilgi = 'ZARAR'))
                                                         AND ml.sinif = 'A'
                                                    GROUP BY ml.fistarih, ml.musteri
                                                    ) b ON a.mus_no = b.MUS_NO
                              GROUP BY NVL(a.trh,b.trh), NVL(a.mus_no,b.mus_no)
                            )
                   GROUP BY mus_no
                  ) npl ON mus.mus_no=npl.mus_no and mus.tarih=npl.trh
        INNER JOIN extr.FS_BCEKBOLGEM d ON mus.ana_sube  = d.sube
        LEFT JOIN extr.FS_PORTFOY_TANIM pt ON pt.bolge_kod = d.bolum
                                              and mus.calisma_sekli = (CASE WHEN pt.segment_sahiplik_kod IN (1,2,3) THEN 4
                                                                            WHEN pt.segment_sahiplik_kod IN (4,5,6) THEN 5
                                                                            WHEN pt.segment_sahiplik_kod IN (7,8,9) THEN 2
                                                                            WHEN pt.segment_sahiplik_kod IN (10,11,12) THEN 3
                                                                       END)
                                              --and pt.status=1 --en günceli almak içindir.Geriye dönük çalýþýr olabilmesi için alttaki koda geçildi.
                                              and mus.tarih >= pt.gorev_baslangic_tarihi
                                              and mus.tarih <= NVL(pt.gorev_bitis_tarihi-1,mus.tarih )
                                              and pt.segment_sahiplik_kod in ( 2,10,5,7)
                                              where mus.mus_no<>1760030;

COMMIT;

v_line_no := $$PLSQL_LINE;

trfm.pkg_trfm_util_lib.prc_utl_object ('TMP_IKTS_RSK_BILG', NULL,  NULL, 'tt',  v_sqlcode,  v_sqlcodeexp);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO trfm.TMP_IKTS_RSK_BILG
SELECT  a.kst_trh, a.mus_no, a.raf_yil, a.raf_no, a.ihtr_trh, a.ihtr_drm_kod, a.ihtr_nkt_rsk, a.ihtr_gnakdi_rsk,
        a.ihtr_tplm_rsk, a.atnn_nkt_rsk, a.atnn_gnakdi_rsk, a.atnn_tplm_rsk, a.gncl_nkt_rsk, a.gncl_gnakdi_rsk,
        a.gncl_tplm_rsk, a.srmlu_avkt_no, a.srmlu_avkt_ad, a.srmlu_avkt_soyad, a.srmlu_avkt_tip, a.izlyn_avkt_no,
        a.izlyn_avkt_ad, a.izlyn_avkt_soyad, a.izlyn_avkt_tip, a.atama_trh, a.hkk_dvr_trh, a.tkp_drm_kod, a.ihtr_gun_adet,
        a.prtfy_scl, a.rvp, a.avkt_sure, a.nkt_karslk_bky, a.gnakdi_karslk_bky, a.tplm_karslk_bky, a.idr_knn_tkp,
        a.dsy_yas, a.wrtof_trh, a.ktgr, a.indrm_oran, a.skor_tplm, a.skor_kpm_trh, a.skor_thsl_kblyt,
        a.skor_thmn_thsl_oran, a.skor_kfl_adet, a.skor_ozl_hkki_drm, a.skor_dsy_yas, a.skor_eslstrm_oran, a.skor_hcz_tsrf_ipt,
        a.indrm_bky, a.kmpn_thsl, a.hkk_dsy_adet, a.acik_hkk_dsy_adet, a.kpl_hkk_dsy_adet, a.thsl_tutar, a.msrf_tutar, a.anpr_tutar,
        a.faiz_tutar, a.bsmv_tutar, a.mtd_thsl_tutar, a.mtd_msrf_tutar, a.mtd_anpr_tutar, a.mtd_faiz_tutar, a.mtd_bsmv_tutar,
        a.ytd_thsl_tutar, a.ytd_msrf_tutar, a.ytd_anpr_tutar, a.ytd_faiz_tutar, a.ytd_bsmv_tutar, a.ltd_thsl_tutar, a.ltd_msrf_tutar,
        a.ltd_anpr_tutar, a.ltd_faiz_tutar, a.ltd_bsmv_tutar, a.npl_sats_thsl, a.ytd_npl_sats_thsl, a.ltd_npl_sats_thsl, a.npl_sats,
        a.ytd_npl_sats, a.ltd_npl_sats, a.rpr_avkt_no, a.rpr_avkt_ad, A.rpr_avkt_soyad, A.rpr_avkt_tip,
        b.yakn_gzlm_drm as yakn_gzlm_drm,
        b.tkp_acls_trh,
        TO_CHAR(b.tkp_acls_trh,'mmyyyy') as tkp_acls_dnm,
        b.npl_nkt_rsk as nkt_rsk,
        c.npl_nkt_rsk as onck_nakdi_rsk,
        b.npl_gnakdi_rsk + (CASE WHEN b.yakn_gzlm_drm in (5,6) THEN b.cek_thht ELSE 0 END) as gnakdi_rsk,
        (c.npl_gnakdi_rsk + (CASE WHEN c.yakn_gzlm_drm in (5,6) THEN c.cek_thht ELSE 0 END)) as onck_gnakdi_rsk,
        b.npl_tplm_rsk  as tplm_rsk,
        c.npl_tplm_rsk as onck_tplm_rsk,
        zz.npl_nkt_rsk as npl_nkt_rsk_onck_yil_son,
        zz.npl_gnakdi_rsk as npl_gnakdi_rsk_onck_yil_son,
        zz.npl_tplm_rsk as npl_tplm_rsk_onck_yil_son,
        CASE WHEN b.npl_tplm_rsk>c.npl_tplm_rsk THEN (b.npl_tplm_rsk-c.npl_tplm_rsk) ELSE 0 END as bky_art_tplm_rsk,
        CASE WHEN b.npl_nkt_rsk>c.npl_nkt_rsk  THEN (b.npl_nkt_rsk-c.npl_nkt_rsk) ELSE 0 END as bky_art_nkt_rsk,
        CASE WHEN (b.npl_gnakdi_rsk + (CASE WHEN b.yakn_gzlm_drm in (5,6) THEN b.cek_thht ELSE 0 END))
                   >(c.npl_gnakdi_rsk + (CASE WHEN c.yakn_gzlm_drm in (5,6) THEN c.cek_thht ELSE 0 END))
             THEN ((b.npl_gnakdi_rsk + (CASE WHEN b.yakn_gzlm_drm in (5,6) THEN b.cek_thht ELSE 0 END))-(c.npl_gnakdi_rsk + (CASE WHEN c.yakn_gzlm_drm in (5,6) THEN c.cek_thht ELSE 0 END)))
             ELSE 0 END as bky_art_gnakdi_rsk,
        a.ana_sube,
        sysdate as etl_trh,
        v_sp_name as etl_job,
        a.mtd_npl_sats_thsl,
        a.mtd_npl_sats,
        a.rvp_scl_no
  FROM  trfm.TMP_IKTS a, --trfm.IKTS_DM_TMP a,
        dm_infoman.PORTFOY_RAPOR b,
        dm_infoman.PORTFOY_RAPOR c,
        dm_infoman.PORTFOY_RAPOR zz
 WHERE  1=1
        and a.mus_no=b.mus_no(+)
        and a.mus_no=c.mus_no (+)
        and a.mus_no=zz.mus_no(+)
        --and a.tarih(+)= v_tarih           a nýn içinde tek gün datasý olmasý sebebi ile comment lendi.
        and b.kst_trh (+)= v_tarih
        and c.kst_trh (+)= v_tarih-1
        and zz.kst_trh(+)=trunc(v_tarih,'yy')-1
        and a.mus_no<>1760030;


COMMIT;


v_line_no := $$PLSQL_LINE;
DELETE FROM dm_infoman.IKTS_DM  WHERE trunc(kst_trh) = trunc(v_tarih);
v_line_no := $$PLSQL_LINE;

INSERT                                  /*+ APPEND */ INTO dm_infoman.IKTS_DM
SELECT  t.kst_trh,
        t.mus_no,
        t.raf_yil,
        t.raf_no,
        s.ihtr_trh,
        t.ihtr_drm_kod,
        t.ihtr_nkt_rsk,
        t.ihtr_gnakdi_rsk,
        t.ihtr_tplm_rsk,
        t.atnn_nkt_rsk,
        t.atnn_gnakdi_rsk,
        t.atnn_tplm_rsk,
        t.gncl_nkt_rsk,
        t.gncl_gnakdi_rsk,
        t.gncl_tplm_rsk,
        t.srmlu_avkt_no,
        t.srmlu_avkt_ad,
        t.srmlu_avkt_soyad,
        t.srmlu_avkt_tip,
        t.izlyn_avkt_no,
        t.izlyn_avkt_ad,
        t.izlyn_avkt_soyad,
        t.izlyn_avkt_tip,
        t.atama_trh,
        TO_CHAR(t.atama_trh,'MMYYYY') as atama_dnm,
        t.hkk_dvr_trh,
        t.tkp_drm_kod,
        trunc (v_tarih - s.ihtr_trh) as ihtr_gun_adet, --t.ihtar_gun_sayisi,
        t.prtfy_scl,
        t.rvp,
        t.avkt_sure,
        t.nkt_karslk_bky,
        t.gnakdi_karslk_bky,
        t.tplm_karslk_bky,
        t.idr_knn_tkp,
        t.dsy_yas,
        t.wrtof_trh,
        t.ktgr,
        t.indrm_oran,
        t.skor_tplm,
        t.skor_kpm_trh,
        t.skor_thsl_kblyt,
        t.skor_thmn_thsl_oran,
        t.skor_kfl_adet,
        t.skor_ozl_hkki_drm,
        t.skor_dsy_yas,
        t.skor_eslstrm_oran,
        t.skor_hcz_tsrf_ipt,
        t.indrm_bky,
        t.kmpn_thsl,
        t.hkk_dsy_adet,
        t.acik_hkk_dsy_adet,
        t.kpl_hkk_dsy_adet,
        t.thsl_tutar,
        t.msrf_tutar,
        t.anpr_tutar,
        t.faiz_tutar,
        t.bsmv_tutar,
        t.mtd_thsl_tutar,
        t.mtd_msrf_tutar,
        t.mtd_anpr_tutar,
        t.mtd_faiz_tutar,
        t.mtd_bsmv_tutar,
        t.ytd_thsl_tutar,
        t.ytd_msrf_tutar,
        t.ytd_anpr_tutar,
        t.ytd_faiz_tutar,
        t.ytd_bsmv_tutar,
        t.ltd_thsl_tutar,
        t.ltd_msrf_tutar,
        t.ltd_anpr_tutar,
        t.ltd_faiz_tutar,
        t.ltd_bsmv_tutar,
        t.npl_sats_thsl,
        t.ytd_npl_sats_thsl,
        t.ltd_npl_sats_thsl,
        t.npl_sats,
        t.ytd_npl_sats,
        t.ltd_npl_sats,
        t.rpr_avkt_no,
        t.rpr_avkt_ad,
        t.rpr_avkt_soyad,
        t.rpr_avkt_tip,
        t.nkt_rsk,
        t.onck_nakdi_rsk,
        t.gnakdi_rsk,
        t.onck_gnakdi_rsk,
        t.tplm_rsk,
        t.onck_tplm_rsk,
        t.npl_nkt_rsk_onck_yil_son,
        t.npl_gnakdi_rsk_onck_yil_son,
        t.npl_tplm_rsk_onck_yil_son,
        NVL(t.bky_art_tplm_rsk,0) as bky_art_tplm_rsk,
        NVL(t.bky_art_nkt_rsk,0) as bky_art_nkt_rsk,
        NVL(t.bky_art_gnakdi_rsk,0) as bky_art_gnakdi_rsk,
        NVL(k.mtd_bky_art_tplm_rsk,0) as mtd_bky_art_tplm_rsk,
        NVL(k.ytd_bky_art_tplm_rsk,0) as ytd_bky_art_tplm_rsk,
        NVL(k.ltd_bky_art_tplm_rsk,0) as ltd_bky_art_tplm_rsk,
        NVL(k.mtd_bky_art_nkt_rsk,0) as mtd_bky_art_nkt_rsk,
        NVL(k.ytd_bky_art_nkt_rsk,0) as ytd_bky_art_nkt_rsk,
        NVL(k.ltd_bky_art_nkt_rsk,0) as ltd_bky_art_nkt_rsk,
        NVL(k.mtd_bky_art_gnakdi_rsk,0) as mtd_bky_art_gnakdi_rsk,
        NVL(k.ytd_bky_art_gnakdi_rsk,0) as ytd_bky_art_gnakdi_rsk,
        NVL(k.ltd_bky_art_gnakdi_rsk,0) as ltd_balance_inc_gnrisk,
        sysdate as etl_trh,
        y.hukuki_durum_kodu as hkki_drm_kod,
        DECODE(y.hukuki_durum_kodu,1,'Ýflas/Konkordoto',2,'Ýflas Ertelemesi',3,'Hukuken Faal/Aktif',4,'Hukuken Faal/Pasif',5,'Hukuken Faal Deðil') as gncl_hkki_drm, --25.03.2015 tarihinde eklendi.
        trunc(s.tblg_serh_trh) as tblg_serh_trh,
        t.ana_sube,
        t.mtd_npl_sats_thsl,
        t.mtd_npl_sats,
        t.rvp_scl_no
  FROM  trfm.TMP_IKTS_RSK_BILG t,
        (SELECT v_tarih as trh,
                mus_no,
                SUM(CASE WHEN i.kst_trh = v_tarih THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_tplm_rsk ELSE 0 END) ELSE 0 END) as bky_art_tplm_rsk,
                SUM(CASE WHEN i.kst_trh between trunc(v_tarih,'mm') and v_tarih THEN i.bky_art_tplm_rsk ELSE 0 END) as mtd_bky_art_tplm_rsk,
                SUM(CASE WHEN i.kst_trh between trunc(v_tarih,'yy') and v_tarih
                         THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_tplm_rsk ELSE 0 END) ELSE 0 END) as ytd_bky_art_tplm_rsk,
                SUM(CASE WHEN i.kst_trh<=v_tarih THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_tplm_rsk ELSE 0 END) ELSE 0 END) as ltd_bky_art_tplm_rsk,
                SUM(CASE WHEN i.kst_trh = v_tarih THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_nkt_rsk ELSE 0 END) ELSE 0 END) as bky_art_nkt_rsk,
                SUM(CASE WHEN i.kst_trh between trunc(v_tarih,'mm') and v_tarih THEN i.bky_art_nkt_rsk ELSE 0 END) as mtd_bky_art_nkt_rsk,
                SUM(CASE WHEN i.kst_trh between trunc(v_tarih,'yy') and v_tarih
                         THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_nkt_rsk ELSE 0 END) ELSE 0 END) as ytd_bky_art_nkt_rsk,
                SUM(CASE WHEN i.kst_trh<=v_tarih THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_nkt_rsk ELSE 0 END) ELSE 0 END) as ltd_bky_art_nkt_rsk,
                SUM(CASE WHEN i.kst_trh = v_tarih THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_gnakdi_rsk ELSE 0 END) ELSE 0 END) as bky_art_gnakdi_rsk,
                SUM(CASE WHEN i.kst_trh between trunc(v_tarih,'mm') and v_tarih THEN i.bky_art_gnakdi_rsk ELSE 0 END) as mtd_bky_art_gnakdi_rsk,
                SUM(CASE WHEN i.kst_trh between trunc(v_tarih,'yy') and v_tarih
                         THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_gnakdi_rsk ELSE 0 END) ELSE 0 END) as ytd_bky_art_gnakdi_rsk,
                SUM(CASE WHEN i.kst_trh<=v_tarih THEN (CASE WHEN i.atama_trh<=v_tarih THEN i.bky_art_gnakdi_rsk ELSE 0 END) ELSE 0 END) as ltd_bky_art_gnakdi_rsk
           FROM trfm.TMP_IKTS_RSK_BILG i
          GROUP BY mus_no
        ) k,
        extr.FS_HUKUKI_DURUM_MASTER y,  --risktakip.hukuki_durum_master@fsbcv
        (SELECT musteri_no,
                MIN(CASE WHEN ihtar_statu_kodu='TSD' THEN islem_tarihi END) as tblg_serh_trh,
                MIN(CASE WHEN ihtar_statu_kodu='IHTC' THEN islem_tarihi END) as ihtr_trh
           FROM extr.FS_TAKIP_STATU_TARIHCE a
          WHERE a.ihtar_statu_kodu in ('IHTC','TSD')
          GROUP BY musteri_no  ) s
 WHERE  1=1
        and t.mus_no=k.mus_no(+)
        and t.kst_trh(+)=v_tarih
        and k.mus_no=y.musteri_no(+)
        and y.durum(+)='A'
        and k.mus_no=s.musteri_no(+)
        and t.mus_no<>1760030;

COMMIT;
v_line_no := $$PLSQL_LINE;

ETL.PKG_UTIL_LIB.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

         v_SqlCode := SQLCODE;
         v_SqlCodeExp := substr (SQLERRM (v_SqlCode), 1, 400);
         etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

        RAISE;
 END SP_IKTS_DATAMART;








PROCEDURE SP_AVKT_PRFRMNS  (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
IS

    v_SqlCode          NUMBER (10);
    v_SqlCodeExp       VARCHAR2 (200);
    v_line_no          NUMBER;
    v_sp_name          VARCHAR2 (40) := 'SP_AVKT_PRFRMNS';
    v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
    v_tarih            DATE := TRUNC(SYSDATE-1);
    v_partition_name   VARCHAR2(100);

BEGIN
    ETL.PKG_UTIL_LIB.PRC_LOG_BEGIN (g_module_name, g_package_name, g_owner, v_sp_name, v_etl_tarih,g_is_restartable);

    v_tarih := trunc(p_tarih);
    v_line_no := $$PLSQL_LINE;

    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_MHSP_THSL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

    INSERT                                  /*+ APPEND */ INTO TRFM.TMP_MHSP_THSL
       SELECT mt.fistarih AS trh,
              mt.musteri as mus_no,
              SUM (mt.tahsilat_tutar) AS thsl_tutar,
              SUM (mt.masraf_tutar) AS msrf_tutar,
              SUM (mt.anapara_tutar) AS anpr_tutar,
              SUM (mt.faiz_tutar) AS faiz_tutar,
              SUM (mt.bsmv_tutar) AS bsmv_tutar,
              sysdate as etl_trh,
              v_sp_name as etl_job,
              NVL(od.kgf_tutar_tl,0) AS kgf_tutar_tl
         FROM extr.fs_rsk_mahsup_tahsilat mt
              LEFT JOIN (  SELECT musteri, fistarih,
                                  SUM(tutar_tl) AS kgf_tutar_tl
                             FROM extr.fs_mahsup_odeme_detay
                            WHERE 1=1
                                  AND tahsilat_kaynagi IN ('46','47')
                                  AND hestur IN ('TS','TT')
                                  AND fistarih = v_tarih
                         GROUP BY musteri,fistarih
                        ) od ON od.musteri = mt.musteri  AND od.fistarih = mt.fistarih
        WHERE 1=1
              AND mt.fistarih= v_tarih
              and mt.musteri <>1760030
     GROUP BY mt.fistarih, mt.musteri, kgf_tutar_tl;
COMMIT;

v_line_no := $$PLSQL_LINE;
-----------------------------------PROTOKOL TAHSÝLAT ---------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PRTKL_THSL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_PRTKL_THSL
    SELECT a.fistarih AS trh,
           musteri as mus_no,
           SUM (CASE WHEN a.hestur = 'MT' AND bakod = 'B' THEN tutar_tl
                     ELSE 0
                END) AS thsl_tutar,
           SUM (CASE WHEN a.hestur = b.hestur AND a.hestip = b.hestip AND bakod = 'A'
                     THEN tutar_tl
                     ELSE 0
                END) AS msrf_tutar,
           SUM (CASE WHEN b.hestur IS NULL AND b.hestip IS NULL AND a.sinif = 'C' AND a.hestur <> 'MT'
                   THEN tutar_tl
                   ELSE 0
                END) AS anpr_tutar,
           SUM (CASE WHEN SUBSTR (a.ilk7, 1, 1) = 5 AND a.hestur = '0' AND bakod = 'A'
                     THEN tutar_tl
                     ELSE 0
                END) AS faiz_tutar,
           SUM (CASE WHEN SUBSTR (a.ilk7, 1, 1) = 3 AND a.hestur = '0' AND bakod = 'A'
                   THEN tutar_tl
                   ELSE 0
               END) AS bsmv_tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM extr.FS_PROTOKOL_TAKSIT_ODEME_DETAY a,
           (SELECT hestur, hestip
              FROM extr.FS_HESTIP --bankdb.hestip@fsbcv
             WHERE hestur = 'TS' AND durum = 0 AND aciklama LIKE '%(174%') b
     WHERE 1=1
           AND a.hestip = b.hestip(+)
           AND a.hestur = b.hestur(+)
           AND a.fistarih(+)=v_tarih
           and musteri<>1760030
    GROUP BY a.fistarih, musteri;
    COMMIT;
v_line_no := $$PLSQL_LINE;
------------------------------------------BOSS TAHSÝLAT ------------------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_BOSS_THSL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_BOSS_THSL
    SELECT islem_tarihi AS trh,
           TO_NUMBER (SUBSTR (cari_hesap_no, 2, 8)) AS mus_no,
           SUM (tahsilat_tutar) AS thsl_tutar,
           SUM (masraf_tutar) AS msrf_tutar,
           SUM (anapara_tutar) AS anpr_tutar,
           SUM (faiz_tutar) AS faiz_tutar,
           SUM (bsmv_tutar) AS bsmv_tutar,
           sysdate etl_trh,
           v_sp_name as etl_job
      FROM extr.OY_OY_KAT_MAHSUP_TAHSILAT
     WHERE islem_tarihi=v_tarih
     and TO_NUMBER (SUBSTR (cari_hesap_no, 2, 8))<>1760030
     GROUP BY islem_tarihi, TO_NUMBER (SUBSTR (cari_hesap_no, 2, 8));
    COMMIT;

v_line_no := $$PLSQL_LINE;
-------------------------------------------GECÝCÝ HESAP TAHSÝLAT --------------------------------------

--TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GECC_HSP_THSL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
--INSERT                                  /*+ APPEND */ INTO TRFM.TMP_GECC_HSP_THSL
--    SELECT t.fistarih tarih,
--           MAX (
--               CASE
--                   WHEN SUBSTR (kmhtutar, 1, 2) = 17 AND bakod = 'A'
--                   THEN
--                       ilk7
--                   ELSE
--                       0
--               END)
--               AS musteri,
--           SUM (
--               CASE
--                   WHEN kmhtutar = 3929990 AND bakod = 'B' THEN tutar
--                   ELSE 0
--               END)
--               tahsilat_tutar,
--           0 AS masraf_tutar,
--           SUM (
--               CASE
--                   WHEN kmhtutar = 3929990 AND bakod = 'B' THEN tutar
--                   ELSE 0
--               END)
--               AS anapara_tutar,
--           0 AS faiz_tutar,
--           0 AS bsmv_tutar,
--           sysdate as etl_trh,
--           v_sp_name as etl_job
--      FROM (SELECT DISTINCT a.fistarih,
--                            a.fissicil,
--                            a.fisno,
--                            a.islsube
--              FROM extr.fs_hrktdet_sg a
--             WHERE     a.fistarih=v_tarih
--                   AND kmhtutar = 3929990
--                   AND bakod = 'B'
--                   AND durum = 0
--            INTERSECT
--            SELECT DISTINCT a.fistarih,
--                            a.fissicil,
--                            a.fisno,
--                            a.islsube
--              FROM extr.fs_hrktdet_sg a
--             WHERE     a.fistarih=v_tarih
--                   AND SUBSTR (kmhtutar, 1, 2) = 17
--                   AND bakod = 'A'
--                   AND durum = 0) k,
--           extr.fs_hrktdet_sg t
--     WHERE     k.fistarih = t.fistarih
--           AND k.fissicil = t.fissicil
--           AND k.fisno = t.fisno
--           AND k.islsube = t.islsube
--    GROUP BY t.fistarih;
--    COMMIT;
--v_line_no := $$PLSQL_LINE;
------------------------------------------------UNION TAHSÝLATLAR------------------------------------

DELETE FROM TRFM.TMP_THSL_TUM WHERE trh = v_tarih;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_THSL_TUM
    SELECT trh,
           mus_no,
           SUM (thsl_tutar) AS thsl_tutar,
           SUM (msrf_tutar) AS msrf_tutar,
           SUM (anpr_tutar) AS anpr_tutar,
           SUM (faiz_tutar) AS faiz_tutar,
           SUM (bsmv_tutar) AS bsmv_tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job,
           SUM (kgf_tutar_tl) AS kgf_tutar_tl
      FROM (SELECT trh, mus_no, thsl_tutar, msrf_tutar, anpr_tutar, faiz_tutar, bsmv_tutar, kgf_tutar_tl FROM TRFM.TMP_MHSP_THSL
            UNION ALL
            SELECT trh, mus_no, thsl_tutar, msrf_tutar, anpr_tutar, faiz_tutar, bsmv_tutar, 0 AS kgf_tutar_tl FROM TRFM.TMP_PRTKL_THSL
            UNION ALL
            SELECT trh, mus_no, thsl_tutar, msrf_tutar, anpr_tutar, faiz_tutar, bsmv_tutar, 0 AS kgf_tutar_tl FROM TRFM.TMP_BOSS_THSL
            --UNION ALL
            --SELECT * FROM TRFM.TMP_GECC_HSP_THSL
           )
           where mus_no<>1760030
    GROUP BY trh, mus_no;
    COMMIT;
v_line_no := $$PLSQL_LINE;
-------------------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_THSL_OZT',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_THSL_OZT
    SELECT b.kst_trh as kst_trh,
           b.mus_no as mus_no,
           SUM(CASE WHEN a.trh > b.atama_trh
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) AS dvr_sonrs_thsl_ltd,
           SUM(CASE WHEN a.trh BETWEEN b.atama_trh AND ADD_MONTHS (b.atama_trh, 1)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) AS dvr_sonrs_thsl_ilk_1_ay,
           SUM(CASE WHEN a.trh BETWEEN b.atama_trh AND ADD_MONTHS (b.atama_trh, 3)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) AS dvr_sonrs_thsl_ilk_3_ay,
           SUM(CASE WHEN a.trh BETWEEN b.atama_trh AND ADD_MONTHS (b.atama_trh, 6)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END)AS dvr_sonrs_thsl_ilk_6_ay,
           SUM(CASE WHEN a.trh BETWEEN b.atama_trh AND ADD_MONTHS (b.atama_trh, 9)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) AS dvr_sonrs_thsl_ilk_9_ay,
           SUM(CASE WHEN a.trh BETWEEN b.atama_trh AND ADD_MONTHS (b.atama_trh, 12)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) AS dvr_sonrs_thsl_ilk_12_ay,
           SUM(CASE WHEN a.trh BETWEEN b.atama_trh AND ADD_MONTHS (b.atama_trh, 24)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) AS dvr_sonrs_thsl_ilk_24_ay,
           SUM(CASE WHEN b.atama_trh IS NULL OR a.trh <= b.atama_trh
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) as dvr_oncs_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    WHEN b.atama_trh IS NULL  AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                    ELSE 0
               END) as mtd_dvr_sonrs_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh  AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                   THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                   WHEN b.atama_trh IS NULL   AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                   THEN (a.anpr_tutar - a.kgf_tutar_tl) + a.msrf_tutar
                   ELSE 0
               END) as ytd_dvr_sonrs_thsl,
           sysdate as etl_trh,
           v_sp_name as etl_job,
           SUM(CASE WHEN a.trh > b.atama_trh
                    THEN a.faiz_tutar
                    ELSE 0
               END) AS dvr_sonrs_faiz_thsl_ltd,
           SUM(CASE WHEN b.atama_trh IS NULL OR a.trh <= b.atama_trh
                    THEN a.faiz_tutar
                    ELSE 0
               END) AS dvr_oncs_faiz_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN a.faiz_tutar
                    WHEN b.atama_trh IS NULL AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN a.faiz_tutar
                    ELSE 0
               END) AS mtd_dvr_sonrs_faiz_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                    THEN a.faiz_tutar
                    WHEN b.atama_trh IS NULL AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                    THEN a.faiz_tutar
                    ELSE 0
               END) AS ytd_dvr_sonrs_faiz_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh
                    THEN a.bsmv_tutar
                    ELSE 0
               END) AS dvr_sonrs_bsmv_thsl_ltd,
           SUM(CASE WHEN b.atama_trh IS NULL OR a.trh <= b.atama_trh
                    THEN a.bsmv_tutar
                    ELSE 0
               END) AS dvr_oncs_bsmv_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN a.bsmv_tutar
                    WHEN b.atama_trh IS NULL AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN a.bsmv_tutar
                    ELSE 0
               END) AS mtd_dvr_sonrs_bsmv_thsl,
           SUM(CASE WHEN a.trh > b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                    THEN a.bsmv_tutar
                    WHEN b.atama_trh IS NULL AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                    THEN a.bsmv_tutar
                    ELSE 0
               END) AS ytd_dvr_sonrs_bsmv_thsl,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) =1
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_1,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) IN (2,3)
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_3,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) IN (4,5,6)
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_6,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) IN (7,8,9)
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_9,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) IN (10,11,12)
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_12,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) BETWEEN 13 and 24
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_24,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh,'mm') AND b.kst_trh) and DECODE(CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh)),0,1,CEIL(MONTHS_BETWEEN(a.trh,b.atama_trh))) > 24
                    THEN a.msrf_tutar+(a.anpr_tutar - a.kgf_tutar_tl) ELSE 0 END) AS ay_24_ust
      FROM trfm.TMP_THSL_TUM a,
           dm_infoman.IKTS_DM b
     WHERE b.mus_no = a.mus_no(+)
     and  b.mus_no<>1760030
           AND b.kst_trh=v_tarih
    GROUP BY b.mus_no, b.kst_trh;
v_line_no := $$PLSQL_LINE;
---------------------------------------------------------------------------------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TKP_BKY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKP_BKY
    SELECT k.tkp_acls_trh,
           t.mus_no,
           t.npl_nkt_rsk AS tkp_nkt_rsk,
           t.npl_tplm_rsk AS tkp_tplm_rsk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT a.mus_no,
                   CASE
                       WHEN a.tkp_acls_trh <= TO_DATE ('31/12/2013', 'dd/mm/yyyy')
                       THEN TO_DATE ('31/12/2013', 'dd/mm/yyyy')
                       ELSE a.tkp_acls_trh
                   END AS tkp_acls_trh
              FROM dm_infoman.PORTFOY_RAPOR a
             WHERE a.tkp_acls_trh IS NOT NULL AND a.kst_trh =v_tarih
           ) k,
           dm_infoman.PORTFOY_RAPOR t
     WHERE 1=1
           AND k.mus_no = t.mus_no
           and t.mus_no<>1760030
           AND k.tkp_acls_trh = t.kst_trh;
 COMMIT;
v_line_no := $$PLSQL_LINE;
-------------------------------------------------------------------------------------------------------------------------------


TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TKP_DVR_BKY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_TKP_DVR_BKY
    SELECT k.kst_trh as trh,
           k.mus_no as mus_no,
           t.tkp_acls_trh,
           f.tkp_tplm_rsk as tkp_tplm_rsk,
           t.onck_ay_npl_tplm_rsk,
           t.onck_ay_npl_nkt_rsk,
           t.gncl_npl_nkt_rsk,
           t.gncl_npl_tplm_rsk,
           f.tkp_nkt_rsk,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT a.kst_trh as trh,
                   a.mus_no,
                   a.npl_nkt_rsk as gncl_npl_nkt_rsk,
                   a.npl_tplm_rsk as gncl_npl_tplm_rsk,
                   a.tkp_acls_trh,
                   NVL(b.npl_tplm_rsk,0) as onck_ay_npl_tplm_rsk,
                   NVL(b.npl_nkt_rsk,0) as onck_ay_npl_nkt_rsk
              FROM dm_infoman.PORTFOY_RAPOR a,
                   dm_infoman.PORTFOY_RAPOR b
             WHERE 1=1
                   and a.kst_trh(+)=v_tarih
                   and b.kst_trh(+)=trunc(to_date(v_tarih,'dd/mm/yyyy'),'MM')-1
                   and a.mus_no=b.mus_no(+)
           ) t,
           dm_infoman.IKTS_DM k,
           trfm.TMP_TKP_BKY f
     WHERE 1=1
           AND k.kst_trh=v_tarih
           AND t.mus_no = k.mus_no
           AND t.trh = k.kst_trh
           and k.mus_no<>1760030
           AND k.mus_no = f.mus_no(+);
COMMIT;
v_line_no := $$PLSQL_LINE;
-------------------------------------------------------------------------------------------------------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_BAL_INCR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_BAL_INCR
    SELECT b.kst_trh,
           b.mus_no,
           SUM ( CASE WHEN a.trh >= b.atama_trh AND a.yakn_gzlm_drm IN (5, 6)
                      THEN a.dgsm_bky
                      ELSE 0
               END) AS dvr_sonrs_bal_incr,
           SUM ( CASE WHEN a.trh >= b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh) AND a.yakn_gzlm_drm IN (5, 6)
                      THEN a.dgsm_bky
                      ELSE 0
                 END) AS mtd_dvr_sonrs_bal_incr,
           SUM ( CASE WHEN a.trh >= b.atama_trh AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh) AND a.yakn_gzlm_drm IN (5, 6)
                      THEN a.dgsm_bky
                      ELSE 0
                 END) AS ytd_dvr_sonrs_bal_incr,
           SUM ( CASE WHEN (b.atama_trh IS NULL OR a.trh < b.atama_trh) AND a.yakn_gzlm_drm IN (5, 6)
                      THEN a.dgsm_bky
                      ELSE 0
                 END) AS dvr_oncs_bal_incr,
           SUM ( CASE WHEN (b.atama_trh IS NULL OR a.trh < b.atama_trh)
                            AND (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                            AND a.yakn_gzlm_drm IN (5, 6)
                      THEN a.dgsm_bky
                      ELSE 0
                 END) AS mtd_dvr_oncs_bal_incr,
           SUM ( CASE WHEN (b.atama_trh IS NULL OR a.trh < b.atama_trh)
                            AND (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                            AND a.yakn_gzlm_drm IN (5, 6)
                       THEN a.dgsm_bky
                       ELSE 0
                  END) AS ytd_dvr_oncs_bal_incr,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM dm_infoman.PRTFY_RPR_KYT_DGSM a,
           (SELECT kst_trh, mus_no, atama_trh
              FROM dm_infoman.ikts_dm
             WHERE kst_trh=v_tarih) b
     WHERE 1=1
     and  b.mus_no<>1760030
           AND a.dgsm_kod IN (1111, 2110, 3110, 4110, 6113)
           AND b.mus_no = a.mus_no
  GROUP BY b.kst_trh, b.mus_no;
    COMMIT;

v_line_no := $$PLSQL_LINE;
    -----------------------------------------npl_satiþ ve write_off lar------------------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_WRITE_OFF_FIS_1',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_WRITE_OFF_FIS_1
    SELECT t.fistarih as fis_trh,
           t.fisno as fis_no,
           t.fissicil as fis_scl,
           t.islsube as islm_sube,
           MAX(CASE WHEN SUBSTR (t.kmhtutar, 1, 2) = 17 AND t.bakod = 'A'
                    THEN t.ilk7
                    ELSE 0
               END) AS mus,
           SUM(CASE WHEN t.kmhtutar = 8801310 AND t.bakod = 'B' THEN tutar
                    ELSE 0
               END) as tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT DISTINCT a.fistarih,
                            a.fissicil,
                            a.fisno,
                            a.islsube
              FROM extr.FS_HRKTDET_SG a
             WHERE     a.fistarih =v_tarih
                   AND a.kmhtutar = 8801310
                   AND a.bakod = 'B'
                   AND a.durum = 0
            INTERSECT
            SELECT DISTINCT b.fistarih,
                            b.fissicil,
                            b.fisno,
                            b.islsube
              FROM extr.FS_HRKTDET_SG b
             WHERE     b.fistarih  =v_tarih
                   AND SUBSTR (b.kmhtutar, 1, 2) = 17
                   AND b.bakod = 'A'
                   AND b.durum = 0) k,
           extr.FS_HRKTDET_SG t
     WHERE     k.fistarih = t.fistarih
           AND k.fissicil = t.fissicil
           AND k.fisno = t.fisno
           AND k.islsube = t.islsube
           AND t.fistarih = v_tarih
    GROUP BY t.fistarih,
             t.fisno,
             t.fissicil,
             t.islsube;
 COMMIT;

v_line_no := $$PLSQL_LINE;
                                                                                                   /*
TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_WRITE_OFF_FIS_2',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT INTO TRFM.TMP_WRITE_OFF_FIS_2
    SELECT t.fistarih as fis_trh,
           t.fisno as fis_no,
           t.fissicil as fis_scl,
           t.islsube as islm_sube,
           MAX(CASE WHEN SUBSTR (kmhtutar, 1, 2) = 17 AND bakod = 'A'
                    THEN ilk7
                    ELSE 0
               END) AS mus,
           SUM(CASE WHEN SUBSTR (kmhtutar, 1, 3) = 180 AND bakod = 'B'
                    THEN tutar
                    ELSE 0
               END) as tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT DISTINCT a.fistarih,
                            a.fissicil,
                            a.fisno,
                            a.islsube
              FROM extr.FS_HRKTDET_SG a
             WHERE     a.fistarih  =v_tarih
                   AND SUBSTR (kmhtutar, 1, 3) = 180
                   AND bakod = 'B'
                   AND durum = 0
            INTERSECT
            SELECT DISTINCT a.fistarih,
                            a.fissicil,
                            a.fisno,
                            a.islsube
              FROM extr.FS_HRKTDET_SG a
             WHERE     a.fistarih =v_tarih
                   AND SUBSTR (kmhtutar, 1, 2) = 17
                   AND bakod = 'A'
                   AND durum = 0) k,
           extr.FS_HRKTDET_SG t
     WHERE     k.fistarih = t.fistarih
           AND k.fissicil = t.fissicil
           AND k.fisno = t.fisno
           AND k.islsube = t.islsube
           AND t.fistarih = v_tarih
    GROUP BY t.fistarih,
             t.fisno,
             t.fissicil,
             t.islsube;
 COMMIT;

v_line_no := $$PLSQL_LINE;
*/

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_WRITE_OFF_FIS_3',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_WRITE_OFF_FIS_3
    SELECT t.fistarih as fis_trh,
           t.fisno as fis_no,
           t.fissicil as fis_scl,
           t.islsube as islm_sube,
           MAX (
               CASE WHEN SUBSTR (kmhtutar, 1, 2) = 17 AND bakod = 'A'
                    THEN ilk7
                    ELSE 0
               END) AS mus,
           SUM (
               CASE WHEN kmhtutar = 8820090 AND bakod = 'B' THEN tutar
                    ELSE 0
               END) as tutar,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT DISTINCT a.fistarih,
                            a.fissicil,
                            a.fisno,
                            a.islsube
              FROM extr.FS_HRKTDET_SG a
             WHERE     a.fistarih  =v_tarih
                   AND kmhtutar = 8820090
                   AND bakod = 'B'
                   AND durum = 0
            INTERSECT
            SELECT DISTINCT a.fistarih,
                            a.fissicil,
                            a.fisno,
                            a.islsube
              FROM extr.FS_HRKTDET_SG a
             WHERE     a.fistarih =v_tarih
                   AND SUBSTR (kmhtutar, 1, 2) = 17
                   AND bakod = 'A'
                   AND durum = 0) k,
           extr.FS_HRKTDET_SG t
     WHERE     k.fistarih = t.fistarih
           AND k.fissicil = t.fissicil
           AND k.fisno = t.fisno
           AND k.islsube = t.islsube
           AND t.fistarih = v_tarih
    GROUP BY t.fistarih,
             t.fisno,
             t.fissicil,
             t.islsube;
 COMMIT;
v_line_no := $$PLSQL_LINE;

DELETE FROM TRFM.TMP_WRITE_OFF_FIS_SON WHERE fis_trh = v_tarih;
COMMIT;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_WRITE_OFF_FIS_SON
    SELECT a.fis_trh,
           a.mus,
           SUM (a.tutar) as tutar,
           zz.statu_kodu as DRM_KOD,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM (SELECT fis_trh, fis_no, fis_scl, islm_sube, mus, tutar FROM TRFM.TMP_WRITE_OFF_FIS_1
            UNION
                                                                                                               /*SELECT fis_trh, fis_no, fis_scl, islm_sube, mus, tutar FROM TRFM.TMP_WRITE_OFF_FIS_2
            UNION*/
            SELECT fis_trh, fis_no, fis_scl, islm_sube, mus, tutar FROM TRFM.TMP_WRITE_OFF_FIS_3
           ) a,
           (SELECT DISTINCT musteri_no, statu_kodu
              FROM extr.OY_OY_KAT_KRM_BILGILERI
             WHERE statu_kodu IN ('WOFF', 'KTS', 'KTAC')) zz
     WHERE a.mus = zz.musteri_no
     and  a.mus<>1760030
  GROUP BY a.fis_trh, a.mus, zz.statu_kodu;
COMMIT;

v_line_no := $$PLSQL_LINE;
------------------------------------------------------------------------------------------------------

TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_NPL_SATS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_NPL_SATS
    SELECT b.kst_trh as trh,
           b.mus_no,
           a.drm_kod,
           MAX(a.fis_trh) AS aktif_silinme_trh,
           SUM(CASE WHEN a.fis_trh >= b.atama_trh AND a.drm_kod = 'WOFF'
                   THEN a.tutar
                   ELSE 0
               END) AS dvr_sonr_woff,
           SUM(CASE WHEN (a.fis_trh >= b.atama_trh AND a.drm_kod = 'WOFF')
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS mtd_dvr_sonr_woff,
           SUM(CASE WHEN (a.fis_trh >= b.atama_trh AND a.drm_kod = 'WOFF')
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS ytd_dvr_sonr_woff,
           SUM(CASE WHEN (b.atama_trh IS NULL OR a.fis_trh < b.atama_trh)
                          AND a.drm_kod = 'WOFF'
                   THEN a.tutar
                   ELSE 0
               END) AS dvr_oncesi_woff,
           SUM(CASE WHEN (b.atama_trh IS NULL OR a.fis_trh < b.atama_trh)
                         AND a.drm_kod = 'WOFF'
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS mtd_dvr_oncesi_woff,
           SUM(CASE WHEN (b.atama_trh IS NULL OR a.fis_trh < b.atama_trh)
                         AND a.drm_kod = 'WOFF'
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS ytd_dvr_oncesi_woff,
           SUM(CASE WHEN a.fis_trh >= b.atama_trh AND a.drm_kod <> 'WOFF'
                   THEN a.tutar
                   ELSE 0
               END) AS dvr_sonr_kts,
           SUM(CASE WHEN (a.fis_trh >= b.atama_trh AND a.drm_kod <> 'WOFF')
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS mtd_dvr_sonr_kts,
           SUM(CASE WHEN (a.fis_trh >= b.atama_trh AND a.drm_kod <> 'WOFF')
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS ytd_dvr_sonr_kts,
           SUM(CASE WHEN (b.atama_trh IS NULL OR a.fis_trh < b.atama_trh) AND a.drm_kod <> 'WOFF'
                   THEN a.tutar
                   ELSE 0
               END) AS dvr_oncesi_kts,
           SUM(CASE WHEN (b.atama_trh IS NULL OR a.fis_trh < b.atama_trh) AND a.drm_kod <> 'WOFF'
                         AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS mtd_dvr_oncesi_kts,
           SUM(CASE WHEN (b.atama_trh IS NULL OR a.fis_trh < b.atama_trh)
                        AND a.drm_kod <> 'WOFF'
                        AND (a.fis_trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                   THEN a.tutar
                   ELSE 0
               END) AS ytd_dvr_oncesi_kts,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM trfm.TMP_WRITE_OFF_FIS_SON a,
           dm_infoman.IKTS_DM b

     WHERE 1=1
           and a.mus = b.mus_no
           and b.kst_trh=v_tarih
           and b.mus_no<>1760030
    GROUP BY b.kst_trh, b.mus_no, a.drm_kod;
    COMMIT;
v_line_no := $$PLSQL_LINE;
    ------------------------------------------NPL_SATIS_TAHSILAT --------------------------------

DELETE FROM TRFM.TMP_NPL_SATS_THSL_1 WHERE trh = v_tarih;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_NPL_SATS_THSL_1
  SELECT f.fistarih as trh,
         f.ilk7 as mus_no,
         SUM(thp_390) as npl_sats_thsl,
         SUM(thp_17) as npl_sats,
         sysdate as etl_trh,
         v_sp_name as etl_job
    FROM (SELECT fistarih,fisno,fissicil,islsube,
                 MAX(CASE WHEN SUBSTR(kmhtutar,1,2)=17  and bakod='A' THEN ilk7 ELSE 0 END) as ilk7,
                 SUM(CASE WHEN kmhtutar='2900000' and bakod='A' THEN tutar ELSE 0 END) as thp_290,
                 SUM(CASE WHEN kmhtutar='3908000' and bakod='B' THEN tutar ELSE 0 END) as thp_390,
                 SUM(CASE WHEN SUBSTR(kmhtutar,1,2)=17  and bakod='A' THEN tutar ELSE 0 END) as thp_17,
                 SUM(CASE WHEN SUBSTR(kmhtutar,1,2)=88  and bakod='B' THEN tutar ELSE 0 END) as thp_88
            FROM extr.FS_HRKTDET_SG k
           WHERE (fistarih,fisno,fissicil,islsube) IN (SELECT DISTINCT fistarih,fisno,fissicil,islsube
                                                         FROM extr.FS_HRKTDET_SG a
                                                        WHERE (kmhtutar='3908000' or SUBSTR(kmhtutar,1,2)=88)
                                                              and fistarih=v_tarih
                                                              and a.durum=0
                                                      )
        GROUP BY fistarih,fisno,fissicil,islsube
          HAVING SUM(CASE WHEN SUBSTR(kmhtutar,1,2)=17  and bakod='A' THEN tutar ELSE 0 END)<>0
         ) f
   WHERE thp_390=thp_17 or thp_17=thp_88
   and  f.ilk7<>1760030
GROUP BY fistarih ,f.ilk7;
COMMIT;
v_line_no := $$PLSQL_LINE;




TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_NPL_SATS_THSL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;

INSERT                                  /*+ APPEND */ INTO TRFM.TMP_NPL_SATS_THSL
    SELECT b.kst_trh as trh,
           b.mus_no as mus_no,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh, 'mm') AND b.kst_trh)
                    THEN a.npl_sats_thsl
                    ELSE 0
               END) AS mtd_npl_sats_thsl,
           SUM(CASE WHEN (a.trh BETWEEN TRUNC (b.kst_trh, 'yy') AND b.kst_trh)
                    THEN a.npl_sats_thsl
                    ELSE 0
               END) AS ytd_npl_sats_thsl,
           sysdate as etl_trh,
           v_sp_name as etl_job
      FROM TRFM.TMP_NPL_SATS_THSL_1 a,
           (SELECT mus_no, kst_trh
              FROM dm_infoman.IKTS_DM
             WHERE kst_trh =v_tarih) b
     WHERE a.mus_no = b.mus_no
     and  b.mus_no<>1760030
  GROUP BY b.kst_trh, b.mus_no;

COMMIT;
v_line_no := $$PLSQL_LINE;
--------------------------------------------AVUKAT_PERFORMANS ------------------------------------------------------
-- ay sonu ve t-1 olarak tutulacak/saklanacak

--DELETE FROM dm_infoman.FS_AVKT_PRFRMNS_AYL WHERE kst_trh = v_tarih;

    v_partition_name := 'P_' || TO_CHAR(v_tarih,'YYYYMMDD');
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object ('FS_AVKT_PRFRMNS_AYL',v_partition_name,NULL,'tp',v_sqlcode,v_sqlcodeexp);
    IF V_SQLCODE<>0 THEN
        RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
    END IF;
v_line_no := $$PLSQL_LINE;

INSERT                                  /*+ APPEND */ INTO dm_infoman.FS_AVKT_PRFRMNS_AYL
 SELECT y.kst_trh, y.ay, y.yil, y.mus_no, y.tkp_acls_trh, y.drm_kod, y.aktf_slnme_trh, y.hkk_dsy_adet,
        y.acik_hkk_dsy_adet, y.kpl_hkk_dsy_adet, y.tkp_tplm_rsk, y.tkp_nkt_rsk, y.gncl_npl_tplm_rsk,
        y.gncl_npl_nkt_rsk, y.gncl_gnakdi_rsk, y.dvr_sonrs_gncl_nkt_rsk, y.dvr_sonrs_gncl_tplm_rsk,
        y.dvr_sonrs_gncl_gnakdi_rsk, y.dvr_bky_nkt_rsk, y.dvr_bky_tplm_rsk, y.rvp, y.rpr_avkt_no, y.rpr_avkt_ad,
        y.rpr_avkt_tip, y.atnm_trh, y.atnm_ay, y.atnm_yil, y.atnn_nkt_rsk, y.atnn_tplm_rsk,
        y.mvct_ay_yeni_atnm_nkt_rsk, y.mvct_ay_yeni_atnm_tplm_rsk, y.dvr_sonrs_thsl_ltd, y.dvr_sonrs_thsl_ilk_1_ay,
        y.dvr_sonrs_thsl_ilk_3_ay, y.dvr_sonrs_thsl_ilk_6_ay, y.dvr_sonrs_thsl_ilk_9_ay, y.dvr_sonrs_thsl_ilk_12_ay,
        y.dvr_sonrs_thsl_ilk_24_ay, y.dvr_oncs_thsl, y.mtd_dvr_sonrs_thsl, y.YTD_DVR_SONRS_THSL,
        y.dvr_sonrasi_balanceinc, y.mtd_dvrsonrasi_balanceinc, y.ytd_dvrsonrasi_balanceinc, y.dvr_oncesi_balanceinc,
        y.mtd_dvr_oncesi_balanceinc, y.ytd_dvr_oncesi_balanceinc, y.dvr_sonrasi_woff, y.mtd_dvr_sonrasi_woff,
        y.ytd_dvr_sonrasi_woff, y.dvr_oncesi_woff, y.mtd_dvr_oncesi_woff, y.ytd_dvr_oncesi_woff, y.dvr_sonrasi_nplsatis,
        y.mtd_dvr_sonrasi_nplsatis, y.ytd_dvr_sonrasi_nplsatis, y.dvr_oncesi_nplsatis, y.mtd_dvr_oncesi_nplsatis,
        y.ytd_dvr_oncesi_nplsatis, y.mtd_nplsatis_tah, y.ytd_nplsatis_tah,
        y.dvr_sonrs_gncl_nkt_rsk-(y.dvr_bky_nkt_rsk+y.mvct_ay_yeni_atnm_nkt_rsk+y.mtd_dvrsonrasi_balanceinc-y.mtd_dvr_sonrasi_woff-y.mtd_dvr_sonrasi_nplsatis-y.mtd_dvr_sonrs_thsl) as diger,
        sysdate as etl_trh,
        v_sp_name as etl_job,
        y.dvr_sonrs_faiz_thsl_ltd,
        y.dvr_oncs_faiz_thsl,
        y.mtd_dvr_sonrs_faiz_thsl,
        y.ytd_dvr_sonrs_faiz_thsl,
        y.iptk_exprt_1,
        y.arac_rehni,
        y.clsm_skl,
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_1_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_1_thsl*6)/100 ELSE 0 END +
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_3_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_3_thsl*6)/100 ELSE 0 END +
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_6_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_6_thsl*6)/100 ELSE 0 END +
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_9_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_9_thsl*6)/100 ELSE 0 END +
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_12_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_12_thsl*6)/100 ELSE 0 END+
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_24_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_24_thsl*6)/100 ELSE 0 END +
        CASE WHEN y.iptk_exprt_1>0 THEN (y.ay_24_ust_thsl*6)/100
             WHEN y.iptk_exprt_1=0 THEN (y.ay_24_ust_thsl*6)/100 ELSE 0 END +
        (y.mtd_dvr_sonrs_faiz_thsl*6)/100 +
        (y.mtd_dvr_sonrs_bsmv_thsl*6)/100 as vklt_ucrt,
        CEIL(MONTHS_BETWEEN (y.kst_trh,y.atnm_trh)) as dvr_sonrs_ay,
        y.dvr_sonrs_bsmv_thsl_ltd,
        y.dvr_oncs_bsmv_thsl,
        y.mtd_dvr_sonrs_bsmv_thsl,
        y.ytd_dvr_sonrs_bsmv_thsl,
        ay_1_thsl,
        ay_3_thsl,
        ay_6_thsl,
        ay_9_thsl,
        ay_12_thsl,
        ay_24_thsl,
        ay_24_ust_thsl,
        firm_grnt,
        firm_grnt_onck_ay
  FROM  (SELECT                                                                          /*+ LEADING (a) */
               TO_DATE (a.kst_trh, 'dd/mm/yyyy') as kst_trh,
               TO_CHAR (TO_DATE (a.kst_trh, 'dd/mm/yyyy'), 'MM') ay,
               TO_CHAR (TO_DATE (a.kst_trh, 'dd/mm/yyyy'), 'YYYY') yil,
               a.mus_no as mus_no,
               b.tkp_acls_trh,
               e.drm_kod,
               e.aktf_slnme_trh,
               NVL(a.hkk_dsy_adet,0) AS hkk_dsy_adet,
               NVL(a.acik_hkk_dsy_adet,0) AS acik_hkk_dsy_adet,
               NVL(a.kpl_hkk_dsy_adet,0) AS kpl_hkk_dsy_adet,
               NVL(b.tkp_tplm_rsk, 0) AS tkp_tplm_rsk,
               NVL(b.tkp_nkt_rsk, 0) AS tkp_nkt_rsk,
               NVL(b.gncl_npl_tplm_rsk, 0) as gncl_npl_tplm_rsk,
               NVL(b.gncl_npl_nkt_rsk, 0) as gncl_npl_nkt_rsk,
               NVL(a.gncl_gnakdi_rsk, 0) gncl_gnakdi_rsk,
               CASE WHEN a.atama_trh<=a.kst_trh THEN NVL (b.gncl_npl_nkt_rsk, 0)else 0 END as dvr_sonrs_gncl_nkt_rsk,
               CASE WHEN a.atama_trh<=a.kst_trh THEN NVL (b.gncl_npl_tplm_rsk, 0) ELSE 0 END as dvr_sonrs_gncl_tplm_rsk,
               CASE WHEN a.atama_trh<=a.kst_trh THEN NVL (a.gncl_gnakdi_rsk, 0)else 0 END as dvr_sonrs_gncl_gnakdi_rsk,
               NVL(CASE WHEN a.atama_trh < TRUNC (a.kst_trh, 'mm')
                        THEN b.onck_ay_npl_nkt_rsk
                        ELSE 0
                   END,0) AS dvr_bky_nkt_rsk,
               NVL(CASE WHEN a.atama_trh < TRUNC (a.kst_trh, 'mm')
                        THEN b.onck_ay_npl_tplm_rsk
                        ELSE 0
                   END,0) AS dvr_bky_tplm_rsk,
               a.rvp,
               a.rpr_avkt_no,
               a.rpr_avkt_ad || ' ' || a.rpr_avkt_soyad AS rpr_avkt_ad,
               DECODE (a.rpr_avkt_tip,  'BI', 'BI',  'BD', 'BD',  'IT') as rpr_avkt_tip,
               a.atama_trh as atnm_trh,
               TO_CHAR (TO_DATE (a.atama_trh, 'dd/mm/yyyy'), 'MM') atnm_ay,
               TO_CHAR (TO_DATE (a.atama_trh, 'dd/mm/yyyy'), 'YYYY') atnm_yil,
               a.atnn_nkt_rsk,
               a.atnn_tplm_rsk,
               CASE WHEN a.atama_trh BETWEEN TRUNC(a.kst_trh, 'mm') AND a.kst_trh
                    THEN a.atnn_nkt_rsk
                    ELSE 0
               END AS mvct_ay_yeni_atnm_nkt_rsk,
               CASE WHEN a.atama_trh BETWEEN TRUNC(a.kst_trh, 'mm') AND a.kst_trh
                    THEN a.atnn_tplm_rsk
                    ELSE 0
               END as mvct_ay_yeni_atnm_tplm_rsk,
               NVL(c.dvr_sonrs_thsl_ltd, 0) as dvr_sonrs_thsl_ltd,
               NVL(c.dvr_sonrs_thsl_ilk_1_ay, 0) as dvr_sonrs_thsl_ilk_1_ay,
               NVL(c.dvr_sonrs_thsl_ilk_3_ay, 0) as dvr_sonrs_thsl_ilk_3_ay,
               NVL(c.dvr_sonrs_thsl_ilk_6_ay, 0) as dvr_sonrs_thsl_ilk_6_ay,
               NVL(c.dvr_sonrs_thsl_ilk_9_ay, 0) as dvr_sonrs_thsl_ilk_9_ay,
               NVL(c.dvr_sonrs_thsl_ilk_12_ay, 0) as dvr_sonrs_thsl_ilk_12_ay,
               NVL(c.dvr_sonrs_thsl_ilk_24_ay, 0) as dvr_sonrs_thsl_ilk_24_ay,
               NVL(c.dvr_oncs_thsl, 0) as dvr_oncs_thsl,
               NVL(c.mtd_dvr_sonrs_thsl, 0) as mtd_dvr_sonrs_thsl,
               NVL(c.ytd_dvr_sonrs_thsl, 0) as ytd_dvr_sonrs_thsl,
               NVL(d.dvr_sonrs_bal_incr, 0) as dvr_sonrasi_balanceinc,
               NVL(d.mtd_dvr_sonrs_bal_incr, 0) AS mtd_dvrsonrasi_balanceinc,
               NVL(d.ytd_dvr_sonrs_bal_incr, 0) AS ytd_dvrsonrasi_balanceinc,
               NVL(d.dvr_oncs_bal_incr, 0) AS dvr_oncesi_balanceinc,
               NVL(d.mtd_dvr_oncs_bal_incr, 0) AS mtd_dvr_oncesi_balanceinc,
               NVL(d.ytd_dvr_oncs_bal_incr, 0) AS ytd_dvr_oncesi_balanceinc,
               NVL(e.dvr_sonrs_write_off, 0) AS dvr_sonrasi_woff,
               NVL(e.mtd_dvr_sonrs_write_off, 0) AS mtd_dvr_sonrasi_woff,
               NVL(e.ytd_dvr_sonrs_write_off, 0) AS ytd_dvr_sonrasi_woff,
               NVL(e.dvr_oncs_write_off, 0) AS dvr_oncesi_woff,
               NVL(e.mtd_dvr_oncs_write_off, 0) AS mtd_dvr_oncesi_woff,
               NVL(e.ytd_dvr_oncs_write_off, 0) AS ytd_dvr_oncesi_woff,
               NVL(e.dvr_sonrs_kst, 0) AS dvr_sonrasi_nplsatis,
               NVL(e.mtd_dvr_sonrs_kst, 0) AS mtd_dvr_sonrasi_nplsatis,
               NVL(e.ytd_dvr_sonrs_kst, 0) AS ytd_dvr_sonrasi_nplsatis,
               NVL(e.dvr_oncs_kst, 0) AS dvr_oncesi_nplsatis,
               NVL(e.mtd_dvr_oncs_kst, 0) AS mtd_dvr_oncesi_nplsatis,
               NVL(e.ytd_dvr_oncs_kst, 0) AS ytd_dvr_oncesi_nplsatis,
               NVL(k.mtd_npl_sats_thsl,0) AS mtd_nplsatis_tah,
               NVL(k.ytd_npl_sats_thsl,0) AS Ytd_nplsatis_tah,
               NVL(c.dvr_sonrs_faiz_thsl_ltd,0) as dvr_sonrs_faiz_thsl_ltd,
               NVL(c.dvr_oncs_faiz_thsl,0) as dvr_oncs_faiz_thsl,
               NVL(c.mtd_dvr_sonrs_faiz_thsl,0) as mtd_dvr_sonrs_faiz_thsl,
               NVL(c.ytd_dvr_sonrs_faiz_thsl,0) AS ytd_dvr_sonrs_faiz_thsl,
               NVL(f.iptk_exprt_1,0) AS iptk_exprt_1,
               NVL(f.arac_rehni,0) as arac_rehni,
               NVL(c.dvr_sonrs_bsmv_thsl_ltd,0) as dvr_sonrs_bsmv_thsl_ltd,
               NVL(c.dvr_oncs_bsmv_thsl,0) as dvr_oncs_bsmv_thsl,
               NVL(c.mtd_dvr_sonrs_bsmv_thsl,0) as mtd_dvr_sonrs_bsmv_thsl,
               NVL(c.ytd_dvr_sonrs_bsmv_thsl,0) as ytd_dvr_sonrs_bsmv_thsl,
               f.clsm_skl,
               NVL(c.ay_1,0) as ay_1_thsl,
               NVL(c.ay_3,0) as ay_3_thsl,
               NVL(c.ay_6,0) as ay_6_thsl,
               NVL(c.ay_9,0) as ay_9_thsl,
               NVL(c.ay_12,0) as ay_12_thsl,
               NVL(c.ay_24,0) as ay_24_thsl,
               NVL(c.ay_24_ust,0) as ay_24_ust_thsl,
               NVL(f.firm_grnt,0) as firm_grnt,
               NVL(y.firm_grnt,0) as firm_grnt_onck_ay
          FROM dm_infoman.IKTS_DM a
               LEFT JOIN TRFM.TMP_TKP_DVR_BKY b ON a.mus_no = b.mus_no AND a.kst_trh = b.trh
               LEFT JOIN TRFM.TMP_THSL_OZT c ON a.kst_trh = c.kst_trh AND a.mus_no = c.mus_no
               LEFT JOIN TRFM.TMP_BAL_INCR d ON a.kst_trh = d.trh AND a.mus_no = d.mus_no
               LEFT JOIN TRFM.TMP_NPL_SATS e ON a.kst_trh = e.trh AND a.mus_no = e.mus_no
               LEFT JOIN dm_infoman.PORTFOY_RAPOR f ON a.kst_trh = f.kst_trh AND a.mus_no = f.mus_no AND a.kst_trh = v_tarih
               LEFT JOIN dm_infoman.PORTFOY_RAPOR y ON y.kst_trh = trunc(v_tarih,'mm')-1 AND y.mus_no = a.mus_no
               LEFT JOIN TRFM.TMP_NPL_SATS_THSL k ON a.kst_trh = k.trh AND a.mus_no = k.mus_no
         WHERE 1=1
               and a.kst_trh =v_tarih
        ) y
        WHERE y.mus_no<>1760030;

COMMIT;

    v_line_no:= $$PLSQL_LINE;

    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object (p_ObjectName=> 'FS_AVKT_PRFRMNS_AYL',
                                                       p_SubObjectName=> v_partition_name,
                                                       p_SubObjectName2=> NULL,
                                                       p_OperationType=> 'at',
                                                       p_SqlCode=> v_sqlcode,
                                                       p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no:= $$PLSQL_LINE;



-- END LOG
ETL.PKG_UTIL_LIB.prc_log_end;

DBMS_APPLICATION_INFO.set_module(NULL,NULL);

EXCEPTION WHEN OTHERS THEN
  v_SqlCode := SQLCODE;
  v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

  --FAILURE LOG
  etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

  RAISE;

END SP_AVKT_PRFRMNS;






PROCEDURE SP_KRD_ANLZ (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) ) IS

    v_tarih            DATE;
    v_sqlcode          NUMBER   (10);
    v_sqlcodeexp       VARCHAR2 (200);
    v_sp_name          VARCHAR2 (40) := 'SP_KRD_ANLZ';
    v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
    v_line_no          NUMBER;
    v_partition_name   VARCHAR2(100);

BEGIN

    ETL.PKG_UTIL_LIB.PRC_LOG_BEGIN (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

    v_tarih := trunc(p_tarih);

    v_line_no := $$PLSQL_LINE;
    --DELETE FROM DM_INFOMAN.FS_KRD_ANLZ_GUN WHERE kst_trh = v_tarih;
    v_partition_name := 'P_' || SUBSTR(TO_CHAR(v_tarih,'YYYYMMDD'),1,8);

    EXECUTE IMMEDIATE 'ALTER TABLE dm_infoman.FS_KRD_ANLZ_GUN TRUNCATE PARTITION ' || v_partition_name ;
    v_line_no := $$PLSQL_LINE;

    INSERT                                  /*+ append */ INTO dm_infoman.FS_KRD_ANLZ_GUN
    SELECT  kst_trh,
            mus_no,
            ana_sube,
            clsm_skl,
            gckmeli_tutar,
            onck_yakn_gzlm_drm,
            onck_ay_yakn_gzlm_drm,
            tkp_acls_trh,
            thp_170,
            thp_172,
            thp_174,
            thp_176,
            thp_156,
            thp_158_159,
            cek_thht,
            nkt_rsk,
            gnakdi_rsk,
            tplm_rsk,
            cnli_nkt_rsk_gncl_kur,
            cnli_nkt_rsk,
            cnli_gnakdi_rsk,
            tplm_cnli_rsk,
            npl_tcr_krd,
            npl_tkst_arac_krd,
            npl_tkst_isyr_krd,
            npl_tkst_diger_krd,
            npl_kkr,
            npl_ovngt,
            npl_gnakdi,
            npl_diger,
            bddk_nkt_karslk,
            bddk_gnakdi_karslk,
            bddk_tplm_karslk,
            rtg,
            thsl_tutar,
            grp_lmt,
            grp_rsk,
            grp_kod_1,
            grp_lmt_1,
            grp_rsk_1,
            grp_kod_2,
            grp_lmt_2,
            grp_rsk_2,
            lmt_ynlm_vade,
            firm_lmt,
            bank_ciro,
            bank_trh,
            rati_ciro,
            rati_trh,
            tmnt_ytrsz_tutar,
            tkp_gun_adet,
            rttf,
            ihr_rttf_spot,
            ebnk_tl,
            spot,
            nkt_yntm,
            ovngt,
            senet_isknt,
            tkst_tcr,
            kmh,
            dvz_krd,
            ebnk_yp,
            dvz_endks_krd,
            tmnt_mktp_tl,
            tmnt_mktp_yp,
            akrdtf_tl,
            akrdtf_yp,
            kbl_krd_tl,
            kbl_krd_yp,
            diger_grntr_kflt_tl,
            diger_grntr_kflt_yp,
            blk_cek_tl,
            blk_cek_yp,
            brysl_kkr,
            krmsl_kkr,
            yipo,
            dvz_endks_krd_gncl_kur,
            iptk_exprt_3,
            iptk_exprt_2,
            iptk_exprt_1,
            iptk_3,
            iptk_2,
            iptk_1,
            firm_grnt,
            dvz_cek,
            cek,
            cek_mvdt_rehni,
            arac_rehni,
            hat_rehni,
            rhn,
            alck_tmlk,
            kflt,
            fnsmn_senet,
            tmnt_senet,
            tmnt_senet_mvdt_rehni,
            mvdt_rehni,
            onck_tplm_rsk,
            onck_ay_tplm_rsk,
            onck_ay_nakdi_rsk,
            onck_nakdi_rsk,
            tplm_memzuc_lmt,
            tplm_memzuc_rsk,
            memzuc_lmt_dolk_oran,
            tplm_memzuc_tkp_bky,
            tplm_memzuc_faiz_tahkuk,
            tplm_memzuc_bank_adet,
            son_ay_memzuc_art_oran,
            son_2_ay_memzuc_art_oran,
            son_3_ay_memzuc_art_oran,
            son_6_ay_memzuc_art_oran,
            son_12_ay_memzuc_art_oran,
            memzuc_dnm,
            en_son_yplndrm_trh,
            nkrd_gckme_tutar,
            kmh_gckme_tutar as kmh_gckme,
            skk_gckme_tutar as sirkt_kkr_gckme,
            gnakdi_krd_gckme_tutar as gnakdi_krd_gckme,
            onck_rsk_ktgr,
            onck_gckmeli_tutar,
            onck_bddk_tplm_karslk,
            onck_clsm_skl,
            krd_ynlm_vade,
            vds_tl,
            vds_yp_tl_karslk,
            vdl_tl,
            vdl_yp_tl_karslk,
            ilk_tblg_trh,
            son_tblg_trh,
            sysdate as etl_trh,
            v_sp_name as etl_job
      FROM  dm_infoman.PORTFOY_RAPOR A
     WHERE  kst_trh = v_tarih
     and mus_no<>1760030;

    COMMIT;
    v_line_no := $$PLSQL_LINE;

    --analyze table
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object (p_ObjectName=> 'FS_KRD_ANLZ_GUN',
                                                       p_SubObjectName=> v_partition_name,
                                                       p_SubObjectName2=> NULL,
                                                       p_OperationType=> 'at',
                                                       p_SqlCode=> v_sqlcode,
                                                       p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no:= $$PLSQL_LINE;


---------------------------------------------------------------------------------------
    --DELETE FROM DM_INFOMAN.DIM_KRD_ANLZ_GUN WHERE kst_trh = v_tarih;
    v_partition_name := 'P_' || SUBSTR(TO_CHAR(v_tarih,'YYYYMMDD'),1,8);

    EXECUTE IMMEDIATE 'ALTER TABLE dm_infoman.DIM_KRD_ANLZ_GUN TRUNCATE PARTITION ' || v_partition_name ;
    v_line_no := $$PLSQL_LINE;

    INSERT                                  /*+ append */ INTO dm_infoman.DIM_KRD_ANLZ_GUN
    SELECT  kst_trh,
            mus_no,
            isim_unvn,
            ana_sube,
            ana_sube_ad,
            bolge_ad,
            clsm_skl,
            verg_no,
            rsk_ktgr,
            tmslc_scl,
            tmslc_ad_soyad,
            brm_kod,
            gckme_gun_arlk,
            gckme_gun_adet,
            krd_sinif,
            grp_kod,
            grp_kod_acklm,
            clsn_adet,
            p as puan,
            boss_drm_kod,
            sktr,
            sktr_acklm,
            ing_sktr,
            ing_sktr_acklm_tr,
            ing_sktr_acklm_en,
            bank_sktr,
            bank_sktr_acklm,
            tcmb_kod,
            ing_sktr_krlm_1,
            ing_sktr_krlm_1_acklm,
            sktr_grp,
            yakn_gzlm_drm,
            onck_yakn_gzlm_drm,
            onck_ay_yakn_gzlm_drm,
            grid_no,
            ing_rtg_1,
            ing_rtg_2,
            ing_rtg_3,
            krnotu,
            gnclm_trh,
            tkp_acls_trh,
            rtg,
            ytk_svy,
            ytk_svy_acklm,
            lmt_ynlm_vade,
            firm_lmt,
            bank_ciro,
            bank_trh,
            rati_ciro,
            rati_trh,
            tkp_gun_adet,
            prtfy_kod,
            prtfy_sahibi_kod as prtfy_shp_kod,
            prtfy_sahibi_kod_acklm as prtfy_shp_acklm,
            tmnt_ytrlk,
            bhs_ytrlk,
            gkt_ytrlk,
            kfl_ytrlk,
            ozl_sart_ytrlk,
            ort_upuan,
            upuan_t_1 as upuan_1_gun_once,
            upuan_t_2 as upuan_2_gun_once,
            en_son_yplndrm_trh,
            onck_rsk_ktgr,
            onck_clsm_skl,
            odue_gun_adet,
            odue_grp,
            krd_ynlm_vade,
            ilk_tblg_trh,
            son_tblg_trh,
            sysdate as etl_trh,
            v_sp_name as etl_job,
            onck_15_gun_yakn_gzlm_drm,
            dj_f as dublejump_flag,
            ing_sktr_krlm_2,
            ing_sktr_krlm_2_acklm,
            ing_sktr_krlm_3,
            ing_sktr_krlm_3_acklm
       FROM dm_infoman.PORTFOY_RAPOR a
      WHERE a.kst_trh = v_tarih
      and mus_no<>1760030;

    COMMIT;
    v_line_no := $$PLSQL_LINE;

    --analyze table
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object (p_ObjectName=> 'DIM_KRD_ANLZ_GUN',
                                                       p_SubObjectName=> v_partition_name,
                                                       p_SubObjectName2=> NULL,
                                                       p_OperationType=> 'at',
                                                       p_SqlCode=> v_sqlcode,
                                                       p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no:= $$PLSQL_LINE;

-- END LOG
ETL.PKG_UTIL_LIB.prc_log_end;

DBMS_APPLICATION_INFO.set_module(NULL,NULL);

EXCEPTION WHEN OTHERS THEN
  v_SqlCode := SQLCODE;
  v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

  --FAILURE LOG
  etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

  RAISE;

END SP_KRD_ANLZ;







PROCEDURE SP_MEMZUC_GELEN_PORTFOY (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) ) IS

    v_tarih           DATE;
    v_sqlcode         NUMBER   (10);
    v_sqlcodeexp      VARCHAR2 (200);
    v_sp_name         VARCHAR2 (40) := 'SP_MEMZUC_GELEN_PORTFOY';
    v_etl_tarih       VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
    v_line_no         NUMBER;
    v_memzuc_gelen    trfm.tmp_memzuc_geln.dnm%TYPE;      --number(6)
    v_memzuc_gelen_1  trfm.tmp_memzuc_geln.dnm%TYPE;      --number(6)
    v_memzuc_gelen_2  trfm.tmp_memzuc_geln.dnm%TYPE;      --number(6)

    v_partition_name   VARCHAR2(100);
    -- sürekli en güncel son 3 memzuc donem hesaplanýyor.

BEGIN

    ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

    v_tarih := trunc(p_tarih);

    SELECT MAX(dnm) INTO v_memzuc_gelen
      FROM trfm.TMP_MEMZUC_GELN--ofsdata.MEMZUC_GELEN
     WHERE dnm <= TO_NUMBER(TO_CHAR(v_tarih,'YYYYMM'));
    v_line_no := $$PLSQL_LINE;

    DBMS_OUTPUT.PUT_LINE(v_memzuc_gelen);

    v_memzuc_gelen_1:= TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(v_memzuc_gelen,'YYYYMM'),-1),'YYYYMM'));
    v_memzuc_gelen_2:= TO_NUMBER(TO_CHAR(ADD_MONTHS(TO_DATE(v_memzuc_gelen,'YYYYMM'),-2),'YYYYMM'));


    --DELETE FROM dm_infoman.MEMZUC_GELN_PRTFY WHERE dnm BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(v_memzuc_gelen,'YYYYMM'),-2),'YYYYMM') AND v_memzuc_gelen;

    v_partition_name:= 'P_'||TO_CHAR(v_memzuc_gelen) ;

    DM_INFOMAN.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object ('MEMZUC_GELN_PRTFY',v_partition_name,NULL,'tp',v_sqlcode,v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;

    v_partition_name:= 'P_'||TO_CHAR(v_memzuc_gelen_1);

    DM_INFOMAN.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object ('MEMZUC_GELN_PRTFY',v_partition_name,NULL,'tp',v_sqlcode,v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;

    v_partition_name:= 'P_'||TO_CHAR(v_memzuc_gelen_2) ;

    DM_INFOMAN.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object ('MEMZUC_GELN_PRTFY',v_partition_name,NULL,'tp',v_sqlcode,v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no := $$PLSQL_LINE;

INSERT                                  /*+ APPEND */ INTO dm_infoman.MEMZUC_GELN_PRTFY
     SELECT                                /*+ use_hash(t k) */
            t.dnm,
            k.mus_no,
            k.clsm_skl,
            t.unvn, t.grp, t.grp_ad, t.ana_sube_kod,
            t.sube_ad, t.bolge_ad, t.prtfy_kod, t.verg_kmlk_no as vkn,
            CASE WHEN  t.rsk_kod in (133,132,131,130,121,120,103,102,101,100) THEN 'NAKDÝ KREDÝLER (YTL)'
                 WHEN  t.rsk_kod in (170,152,151,150) THEN 'NAKDÝ KREDÝLER (YP)'
                 WHEN  t.rsk_kod in (104,154) THEN 'YENÝLENEN VE ÝTFA PLANINA BAÐLANAN KREDÝLER (YTL/YP)'
                 WHEN  t.rsk_kod in (105,155) THEN 'TAZMÝN EDÝLEN GAYRÝNAKDÝ KREDÝ BEDELLERÝ (YTL/YP)'
                 WHEN  t.rsk_kod in (110,160,210,260) THEN 'YENÝDEN YAPILANDIRMA KAPSAMINDAKÝ KREDÝLER (YTL/YP)'
                 WHEN  t.rsk_kod in (200,201,203) THEN 'GAYRÝNAKDÝ KREDÝLER (YTL)'
                 WHEN  t.rsk_kod in (250,251,252,253,270) THEN 'GAYRÝNAKDÝ KREDÝLER (YP)'
                 WHEN  t.rsk_kod in (313,312,311,310,302,301,300) THEN 'TASFÝYE OLUNACAK ALACAKLAR (YTL)'
                 WHEN  t.rsk_kod in (350,351,352) THEN 'TASFÝYE OLUNACAK ALACAKLAR (YP)'
                 WHEN  t.rsk_kod in (400) THEN 'TAHVÝLLER'
                 WHEN  t.rsk_kod in (500) THEN 'FÝNANSMAN BONOSU'
                 WHEN  t.rsk_kod in (600,601) THEN 'FÝNANSAL KÝRALAMA BEDELLERÝ (YTL)'
                 WHEN  t.rsk_kod in (650) THEN 'FÝNANSAL KÝRALAMA BEDELLERÝ (YP)'
                 WHEN  t.rsk_kod in (660,661) THEN 'TAKÝPTEKÝ FÝNANSAL KÝRALAMA BEDELLERÝ (YTL)'
                 WHEN  t.rsk_kod in (670,671) THEN 'TAKÝPTEKÝ FÝNANSAL KÝRALAMA BEDELLERÝ (YP)'
                 WHEN  t.rsk_kod in (700,701,702) THEN 'FAKTORÝNG ALACAKLARI (YTL)'
                 WHEN  t.rsk_kod in (750,751) THEN 'FAKTORÝNG ALACAKLARI (YP)'
                 WHEN  t.rsk_kod in (760,761) THEN 'TAKÝPTEKÝ FAKTORÝNG ALACAKLARI (YTL)'
                 WHEN  t.rsk_kod in (770,771) THEN 'TAKÝPTEKÝ FAKTORÝNG ALACAKLARI (YP)'
            END as rsk_kod_acklm,
            SUM(CASE WHEN  t.rsk_kod in (313,312,311,310,302,301,300)
                     THEN ( t.kisa_vade+ t.orta_vade+ t.uzn_vade+ t.faiz+ t.tahkuk) ELSE 0
                END) as tkp_bky,
            SUM(t.lmt) as lmt,
            SUM(t.kisa_vade)+SUM( t.orta_vade)+SUM( t.uzn_vade)+SUM( t.faiz)+SUM( t.tahkuk) as tplm_memzuc_bky,
            MAX(t.bank_adet) as bank_adet,
            MAX(k.tplm_rsk) as tplm_rsk,
            t.rsk_kod,
            SUM(t.kisa_vade) as kisa_vade,
            SUM(t.orta_vade) as orta_vade,
            SUM(t.uzn_vade) as uzn_vade,
            SUM(t.faiz) as faiz,
            SUM(t.tahkuk) as tahkuk,
            TO_DATE(t.dnm,'yyyymm') as bslng_trh,
            LAST_DAY(to_date (t.dnm,'yyyymm')) as btis_trh,
            MAX(k.cnli_nkt_rsk_gncl_kur+k.thp_158_159+k.thp_156) as bank_nkt_rsk,
            MAX(k.cnli_gnakdi_rsk+k.cek_thht) as bank_gnakdi_rsk,
            MAX(k.firm_lmt) as bank_firm_limit,
            MAX(k.npl_nkt_rsk) as bank_npl_nkt_rsk,
            MAX(k.npl_gnakdi_rsk) as bank_npl_gnakdi_rsk,
            MAX(k.cnli_nkt_rsk_gncl_kur+k.thp_158_159+k.thp_156+k.cnli_gnakdi_rsk+k.cek_thht+k.npl_nkt_rsk+k.npl_gnakdi_rsk) as bank_tplm_rsk,
            k.ing_sktr,
            k.ing_sktr_acklm_tr,
            k.ing_sktr_acklm_en,
            k.ytk_svy,
            k.ytk_svy_acklm,
            k.rtg,
            k.krnotu,
            k.yakn_gzlm_drm,
            k.prtfy_shp_acklm,
            k.p,
            k.krd_ynlm_vade,
            MAX(k.sim_trh) as sim_trh,
            MAX(k.sim_ciro) as sim_ciro,
            MAX(k.bank_trh) as bank_trh,
            MAX(k.bank_ciro) as bank_ciro,
            k.mus_tip,
            sysdate as etl_trh,
            v_sp_name as etl_trh
      FROM  trfm.TMP_MEMZUC_GELN_PRTFY k,
            trfm.TMP_MEMZUC_GELN t
     WHERE  1=1
     and  k.mus_no<>1760030
            AND t.dnm = TO_CHAR(k.kst_trh,'yyyymm')
            and t.mus_no = k.mus_no
            and LPAD(TRIM(t.verg_kmlk_no),11,0)=k.verg_no
            AND t.dnm BETWEEN v_memzuc_gelen_2 AND v_memzuc_gelen
  GROUP BY  t.dnm,
            k.mus_no,
            k.clsm_skl,
            t.unvn,t.grp,grp_ad, t.ana_sube_kod, t.sube_ad, t.bolge_ad, t.prtfy_kod, t.verg_kmlk_no,
            CASE WHEN  t.rsk_kod in (133,132,131,130,121,120,103,102,101,100) THEN 'NAKDÝ KREDÝLER (YTL)'
                 WHEN  t.rsk_kod in (170,152,151,150) THEN 'NAKDÝ KREDÝLER (YP)'
                 WHEN  t.rsk_kod in (104,154) THEN 'YENÝLENEN VE ÝTFA PLANINA BAÐLANAN KREDÝLER (YTL/YP)'
                 WHEN  t.rsk_kod in (105,155) THEN 'TAZMÝN EDÝLEN GAYRÝNAKDÝ KREDÝ BEDELLERÝ (YTL/YP)'
                 WHEN  t.rsk_kod in (110,160,210,260) THEN 'YENÝDEN YAPILANDIRMA KAPSAMINDAKÝ KREDÝLER (YTL/YP)'
                 WHEN  t.rsk_kod in (200,201,203) THEN 'GAYRÝNAKDÝ KREDÝLER (YTL)'
                 WHEN  t.rsk_kod in (250,251,252,253,270) THEN 'GAYRÝNAKDÝ KREDÝLER (YP)'
                 WHEN  t.rsk_kod in (313,312,311,310,302,301,300) THEN 'TASFÝYE OLUNACAK ALACAKLAR (YTL)'
                 WHEN  t.rsk_kod in (350,351,352) THEN 'TASFÝYE OLUNACAK ALACAKLAR (YP)'
                 WHEN  t.rsk_kod in (400) THEN 'TAHVÝLLER'
                 WHEN  t.rsk_kod in (500) THEN 'FÝNANSMAN BONOSU'
                 WHEN  t.rsk_kod in (600,601) THEN 'FÝNANSAL KÝRALAMA BEDELLERÝ (YTL)'
                 WHEN  t.rsk_kod in (650) THEN 'FÝNANSAL KÝRALAMA BEDELLERÝ (YP)'
                 WHEN  t.rsk_kod in (660,661) THEN 'TAKÝPTEKÝ FÝNANSAL KÝRALAMA BEDELLERÝ (YTL)'
                 WHEN  t.rsk_kod in (670,671) THEN 'TAKÝPTEKÝ FÝNANSAL KÝRALAMA BEDELLERÝ (YP)'
                 WHEN  t.rsk_kod in (700,701,702) THEN 'FAKTORÝNG ALACAKLARI (YTL)'
                 WHEN  t.rsk_kod in (750,751) THEN 'FAKTORÝNG ALACAKLARI (YP)'
                 WHEN  t.rsk_kod in (760,761) THEN 'TAKÝPTEKÝ FAKTORÝNG ALACAKLARI (YTL)'
                 WHEN  t.rsk_kod in (770,771) THEN 'TAKÝPTEKÝ FAKTORÝNG ALACAKLARI (YP)'
            END,
            t.rsk_kod,
            k.ing_sktr,
            k.ing_sktr_acklm_tr,
            k.ing_sktr_acklm_en,
            k.ytk_svy,
            k.ytk_svy_acklm,
            k.rtg,
            k.krnotu,
            k.yakn_gzlm_drm,
            k.prtfy_shp_acklm,
            k.p,
            k.krd_ynlm_vade,
            k.mus_tip;
    COMMIT;

    v_line_no := $$PLSQL_LINE;
    dm_infoman.PKG_DM_INFOMAN_UTIL_LIB.prc_utl_object (p_ObjectName=> 'MEMZUC_GELN_PRTFY',
                                                       p_SubObjectName=> v_partition_name,
                                                       p_SubObjectName2=> NULL,
                                                       p_OperationType=> 'at',
                                                       p_SqlCode=> v_sqlcode,
                                                       p_SqlCodeExp=> v_sqlcodeexp);
    IF v_SqlCode<>0 THEN
        raise_application_error(-20001,TO_CHAR(v_SqlCode)||v_SqlCodeExp);
    END IF;
    v_line_no:= $$PLSQL_LINE;

-- END LOG
ETL.PKG_UTIL_LIB.prc_log_end;

DBMS_APPLICATION_INFO.set_module(NULL,NULL);

EXCEPTION WHEN OTHERS THEN
  v_SqlCode := SQLCODE;
  v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

  --FAILURE LOG
  etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

  RAISE;

END SP_MEMZUC_GELEN_PORTFOY;


PROCEDURE SF_NLS_DEGERLERINI_OUTPUTA_YAZ as
    --farklý ortamlardan çalýþtýrýldýðýnda, kod hata alabillyor. Bunu incelemek için private procedure oluþturuldu. Ýlteriþ MUTLU 02.11.2015

    v_sqlcode           NUMBER   (10);
    v_sqlcodeexp        VARCHAR2 (400);
    CURSOR nls_parameters IS
    SELECT parameter,value FROM sys.V_$NLS_PARAMETERS;
BEGIN
    FOR parametre_deger IN nls_parameters
    LOOP
        dbms_output.put_line( parametre_deger.parameter || CHR(9) || ':' || CHR(9) ||parametre_deger.value);    --chr(9): tab character
    END LOOP;


    EXCEPTION WHEN OTHERS THEN
        v_SqlCode := SQLCODE;
        v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
    RAISE;
END SF_NLS_DEGERLERINI_OUTPUTA_YAZ;



END PKG_PORTFOY_RAPORU;
/