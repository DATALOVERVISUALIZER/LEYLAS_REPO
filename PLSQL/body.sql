CREATE OR REPLACE PACKAGE BODY ETL.PKG_KKB_TZL AS

    --global variables:
    g_module_name      VARCHAR2 (100):= 'PKG_KKB_TZL';
    g_package_name     VARCHAR2 (40) := 'PKG_KKB_TZL';
    g_owner            VARCHAR2 (40) := 'ETL';
    g_is_restartable   NUMBER (1)    := 1;

    --Melike M., Cihan A., Ýlteriþ M., Kerem K., Burhan D.
    --07.11.2017

   PROCEDURE sp_main (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) ) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           varchar2 (40) := 'SP_MAIN';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 0;


    BEGIN

        etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

        v_tarih := NVL(p_tarih, TRUNC(SYSDATE-1));


        --grup 1: içindekiler  paralel çalýþabilir.
        v_line_no := 3;
        pkg_kkb_tzl.sp_trbgr_p1(v_tarih);
        v_line_no := 6;
        pkg_kkb_tzl.sp_trbip(v_tarih);
        v_line_no := 9;
        --grup 1: içindekiler  paralel çalýþabilir.



        pkg_kkb_tzl.sp_trbfc_trbic(v_tarih);
        v_line_no := 12;
        pkg_kkb_tzl.sp_trbac(v_tarih);
        v_line_no := 15;
        pkg_kkb_tzl.sp_trbgr_p2(v_tarih);
        v_line_no := 18;



        --grup 2: içindekiler paralel çalýþabilir.
        pkg_kkb_tzl.sp_trbef_txt(v_tarih);
        v_line_no := 21;
        pkg_kkb_tzl.sp_trbfc_txt(v_tarih);
        v_line_no := 24;
        pkg_kkb_tzl.sp_trbgr_txt(v_tarih);
        v_line_no := 27;
        pkg_kkb_tzl.sp_trbhf_txt(v_tarih);
        v_line_no := 30;
        pkg_kkb_tzl.sp_trbic_txt(v_tarih);
        v_line_no := 33;
        pkg_kkb_tzl.sp_trbfc_txt_krd(v_tarih);
        v_line_no := 36;
        pkg_kkb_tzl.sp_trbac_txt_krd(v_tarih);
        v_line_no := 39;
        pkg_kkb_tzl.sp_trbgr_txt_krd(v_tarih);
        v_line_no := 42;
        pkg_kkb_tzl.sp_trbic_txt_krd(v_tarih);
        v_line_no := 45;
        pkg_kkb_tzl.sp_trbip_txt_krd(v_tarih);
        v_line_no := 48;
        --grup 2: içindekiler  paralel çalýþabilir.




        --grup 3: içindekiler  paralel çalýþabilir.
        pkg_kkb_tzl.sp_trbgr_sonrs_trbfc_txt(v_tarih);
        v_line_no := 51;
        pkg_kkb_tzl.sp_trbgr_sonrs_trbic_txt(v_tarih);
        v_line_no := 54;
        pkg_kkb_tzl.sp_trbgr_sonrs_trbfc_txt_krd(v_tarih);
        v_line_no := 57;
        pkg_kkb_tzl.sp_trbgr_sonrs_trbic_txt_krd(v_tarih);
        v_line_no := 60;
        --grup 3: içindekiler  paralel çalýþabilir.



        pkg_kkb_tzl.sp_tkkb_rapor_gonderim_sorgu(v_tarih);
        v_line_no := 63;
        pkg_kkb_tzl.sp_kkb_export(v_tarih);
        v_line_no := 66;

    -- END LOG
    etl.pkg_util_lib.prc_log_end;

    DBMS_APPLICATION_INFO.set_module(NULL,NULL);

    EXCEPTION WHEN OTHERS THEN
      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

      --FAILURE LOG
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;

    END sp_main;

   PROCEDURE sp_trbgr_p1 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_P1';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 100;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
       IF V_SQLCODE<>0 THEN
           RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
       END IF;

      v_line_no:= 110;

         --Teminatlar için müþteri setini bulmak için;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_01
        SELECT v_tarih AS kst_trh,
               vt.musteri,
               mt.gercek_tuzel,
               mm.musteri_tip,
               CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                          OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                          OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                          OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                          OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                          OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                          OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                          OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                          OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                          OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                          OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                          OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                             THEN NULL
                                  ELSE mm.vergi_no
               END AS vergi_no,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_vortex_teklif vt,
               ofsdata.musteri_master_cs_hist mm,
               extr.fs_mustur mt
         WHERE 1 = 1
           AND vt.musteri = mm.musteri_no
           AND mm.musteri_tip = mt.tip
           AND vt.sube NOT IN (601, 602, 603, 604, 605, 550)
           AND mm.musteri_tip NOT IN (73, 80, 81, 82, 84, 85, 87, 88, 89, 91, 92, 93)
           AND mm.durum <> 9
           AND mm.tarih = v_tarih
           AND vt.geneltarih <= v_tarih;
                         /*AND NOT (
                    LENGTH (
                            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                          THEN NULL
                                               ELSE mm.vergi_no
                                                    END
                           ) = 11
                    AND mm.musteri_tip <> 14
                   )*/--;

       COMMIT;
       v_line_no:= 120;

       TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
       IF V_SQLCODE<>0 THEN
           RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
       END IF;

       v_line_no:= 130;

       INSERT               /*+ APPEND */ INTO trfm.TMP_TRBGR_02
        SELECT x.kst_trh,
               x.musteri,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM trfm.tmp_trbgr_01 x
               INNER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f k
                          ON     1 = 1
                             AND x.musteri_tip = k.musteri_tip
         WHERE 1 = 1
           AND TO_NUMBER (x.vergi_no) > 1111111
           AND CASE WHEN LENGTH (TO_NUMBER (x.vergi_no)) BETWEEN 7 AND 10 AND k.tckn_vkn = 'VKN' THEN etl.sf_ymus_vergicheck_to_number (x.vergi_no)
                    WHEN LENGTH (TO_NUMBER (x.vergi_no)) = 11 AND k.tckn_vkn = 'TCKN' THEN etl.sf_ymus_tckncheck_to_number (x.vergi_no)
                              END = 1;

      COMMIT;

      v_line_no:=140;

       v_line_no:= 150;
       TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_KFL_MUS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
       IF V_SQLCODE<>0 THEN
           RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
       END IF;

       v_line_no:= 160;
      --TRBFC/TRBIC'ye eklenecek kefil müþterileri bulan tablo:
       INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_kfl_mus
        SELECT v_tarih AS kst_trh,
               a.musteri,
               a.sube AS tmnt_refsube,
               a.reftur AS tmnt_reftur,
               a.refsirano AS tmnt_refsirano,
               (a.sube || a.reftur || p.id || '-' || a.refsirano) AS tmnt_referans,
               p.id temtur,
               p.tem_ad AS temtur_acklm,
               h.para,
               MAX (TO_DATE (h.fistarih, 'DD/MM/YYYY')) AS tmnt_alindigi_trh,
               a.kefil AS kefil_musteri_no,
               CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                          OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                          OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                          OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                          OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                          OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                          OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                          OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                          OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                          OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                          OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                          OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                             THEN NULL
                                  ELSE mm.vergi_no
                                       END AS kefil_musteri_vergi_no,
               mm.musteri_tip AS kefil_musteri_tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_teminatkefil a
               INNER JOIN extr.fs_teminathrkt h ON  1 = 1
                                                AND a.sube = (CASE WHEN h.refsube > 100 THEN h.refsube WHEN h.sube > 100 THEN h.sube END)
                                                AND a.reftur = h.reftur
                                                AND a.refsirano = h.refsirano
               INNER JOIN ofsdata.musteri_master_cs_hist mm ON  1 = 1
                                                            AND v_tarih = mm.tarih
                                                            AND a.kefil = mm.musteri_no
               INNER JOIN trfm.tmp_trbgr_02 x ON  1 = 1
                                               AND v_tarih = x.kst_trh
                                               AND a.kefil = x.musteri
               LEFT JOIN extr.fs_corp_lmt_coll_def p ON  1 = 1
                                                     AND 13 = p.id
                                                     AND 9 <> p.durum
         WHERE 1 = 1
               AND a.kurumsalsw = 'K'
               AND a.durum = 0
               AND a.tutar <> 0
               AND LAST_DAY (TO_DATE (h.fistarih, 'DD/MM/YYYY')) = v_tarih --Aylýk Bildirim
               --AND TO_DATE (h.fistarih, 'DD/MM/YYYY') BETWEEN ADD_MONTHS (v_tarih, -36)+1 AND v_tarih --Ýlk Bildirim
               AND h.durum = 0
               AND h.kurumsalsw = 'K'
               AND (CASE WHEN h.refsube > 100 THEN h.refsube WHEN h.sube > 100 THEN h.sube END) NOT IN (601, 602, 603, 604, 605, 550)
      GROUP BY a.musteri, a.sube, a.reftur, a.refsirano, (a.sube || a.reftur || p.id || '-' || a.refsirano),
               p.id, p.tem_ad, h.para, a.kefil,
               CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                          OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                          OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                          OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                          OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                          OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                          OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                          OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                          OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                          OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                          OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                          OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                             THEN NULL
                                  ELSE mm.vergi_no
                                       END,
               mm.musteri_tip;

      COMMIT;
      v_line_no:= 170;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_p1;


   PROCEDURE sp_trbip (p_tarih IN DATE DEFAULT TRUNC(sysdate-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBIP';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 200;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);
      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBIP_FCT_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 210;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbip_fct_01
     SELECT v_tarih AS kesit_tarihi,
            m.musteri AS musteri_no,
            CASE WHEN LENGTH (TRIM (
                                    CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                               OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                               OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                               OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                               OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                               OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                               OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                               OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                               OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                               OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                               OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                               OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                  THEN NULL
                                                       ELSE mm.vergi_no
                                                            END
                                   )) = 11 AND SUBSTR (TRIM (
                                                            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                                          THEN NULL
                                                                               ELSE mm.vergi_no
                                                                                    END
                                                            ), 1, 1) <> '0' THEN TRIM (
                                                                                      CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                                                                    THEN NULL
                                                                                                         ELSE mm.vergi_no
                                                                                                              END
                                                                                      ) END tck_no,
            CASE WHEN LENGTH (TRIM (
                                   CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                              OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                              OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                              OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                              OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                              OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                              OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                              OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                              OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                              OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                              OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                              OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                 THEN NULL
                                                      ELSE mm.vergi_no
                                                           END
                                   )) IN (9, 10) THEN TRIM (
                                                            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                                          THEN NULL
                                                                               ELSE mm.vergi_no
                                                                                    END
                                                           ) END vergi_no,
            mm.musteri_tip,
            mt.gercek_tuzel,
            (b.sube || b.reftur || b.refsirano) AS kredi_hesabi_ref_no,
            b.sube AS refsube,
            b.reftur,
            b.refsirano,
            TO_DATE (b.vadetarih, 'DD/MM/YYYY') AS odeme_vadesi,
            TO_DATE (b.odemetarih, 'DD/MM/YYYY') AS odemenin_yapildigi_tarih,
            (NVL (b.anapara, 0) + NVL (b.faiz, 0) + NVL (b.bsmv, 0)) AS odenmesi_gereken_tutar,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_bkrhrkt b
            INNER JOIN ofsdata.bkrmaster_aysonu m --Proda taþýnýrken extr.fs_bkrmaster olarak taþýnmalý
                       ON 1 = 1
                          AND m.sube = b.sube
                          AND m.reftur = b.reftur
                          AND m.refsirano = b.refsirano
            LEFT OUTER JOIN ofsdata.musteri_master_cs_hist mm
                            ON     1 = 1
                               AND v_tarih = mm.tarih
                               AND m.musteri = mm.musteri_no
            LEFT OUTER JOIN extr.fs_mustur mt
                            ON     1 = 1
                               AND mm.musteri_tip = mt.tip
      WHERE 1 = 1
            AND (
                     (b.durum = 0 AND TO_DATE (b.odemetarih, 'DD/MM/YYYY') = TO_DATE ('31/12/1899', 'DD/MM/YYYY') AND TO_DATE (b.vadetarih, 'DD/MM/YYYY') > v_tarih)
                  OR
                     (b.durum = 1 AND TO_DATE (b.odemetarih, 'DD/MM/YYYY') <= v_tarih)
                ) AND (NVL (b.anapara, 0) + NVL (b.faiz, 0) + NVL (b.bsmv, 0)) > 0;

      COMMIT;


      v_line_no:= 220;

      DELETE FROM prsn.kkb_trbip_fct
            WHERE 1=1
                  AND kesit_tarihi = v_tarih;
      COMMIT;
      v_line_no:= 230;

     INSERT               /*+ APPEND */ INTO prsn.kkb_trbip_fct
     SELECT b.kesit_tarihi, b.musteri_no, b.tck_no, b.vergi_no, b.musteri_tip, b.gercek_tuzel, b.kredi_hesabi_ref_no,
            b.refsube, b.reftur, b.refsirano, b.odeme_vadesi, b.odemenin_yapildigi_tarih, b.odenmesi_gereken_tutar,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbip_fct_01 b
            INNER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f k
                       ON     1 = 1
                          AND b.musteri_tip = k.musteri_tip
      WHERE 1 = 1
        AND CASE WHEN TO_NUMBER (b.vergi_no) > 1111111 AND k.tckn_vkn = 'VKN' THEN etl.sf_ymus_vergicheck_to_number (b.vergi_no)
                 WHEN TO_NUMBER (b.tck_no) > 10000000000 AND k.tckn_vkn = 'TCKN' THEN etl.sf_ymus_tckncheck_to_number (b.tck_no)
                      END = 1;

      COMMIT;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbip;


   PROCEDURE sp_trbfc_trbic (p_tarih IN DATE DEFAULT TRUNC(sysdate-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBFC_TRBIC';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 300;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_VORTEX_MUS_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 305;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_vortex_mus_01
     SELECT v_tarih AS kesit_tarihi,
            vt.musteri musteri_no, mt.gercek_tuzel, mm.musteri_tip,
            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                          THEN NULL
                               ELSE mm.vergi_no
            END vergi_no,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_vortex_teklif vt,
            ofsdata.musteri_master_cs_hist mm,
            extr.fs_mustur mt
      WHERE 1 = 1
            AND vt.musteri = mm.musteri_no
            AND mm.musteri_tip = mt.tip
            AND mm.musteri_tip NOT IN (73,80,81,82,84,85,87,88,89,91,92,93)
            AND vt.sube NOT IN (601,602,603,604,605,550)
            AND mm.durum <> 9
            AND mm.tarih = v_tarih
                          /*AND NOT (
                    LENGTH (
                            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                          THEN NULL
                                               ELSE mm.vergi_no
                                                    END
                           ) = 11
                    AND mm.musteri_tip <> 14)*/;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_VORTEX_MUS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 305;
     INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_vortex_mus
     SELECT o1.kesit_tarihi, o1.musteri_no, o1.vergi_no, o1.musteri_tip, o1.gercek_tuzel,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbfc_vortex_mus_01 o1
            INNER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f k
                       ON     1 = 1
                          AND o1.musteri_tip = k.musteri_tip
      WHERE 1 = 1
        AND TO_NUMBER (o1.vergi_no) > 1111111
        AND CASE WHEN LENGTH (TO_NUMBER (o1.vergi_no)) BETWEEN 7 AND 10 AND k.tckn_vkn = 'VKN' THEN etl.sf_ymus_vergicheck_to_number (o1.vergi_no)
                 WHEN LENGTH (TO_NUMBER (o1.vergi_no)) = 11 AND k.tckn_vkn = 'TCKN' THEN etl.sf_ymus_tckncheck_to_number (o1.vergi_no)
            END = 1;

      COMMIT;

      v_line_no:= 310;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_ILISKILI_MUS_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 315;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_iliskili_mus_01
     SELECT v_tarih AS kesit_tarihi,
            mi.musteri_no,
            mi.musteri_no2 AS iliskili_musteri_no,
            mt.gercek_tuzel AS iliskili_musteri_gercek_tuzel,
            mm.musteri_tip AS iliskili_musteri_tip,
            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                          THEN NULL
                               ELSE mm.vergi_no
                                    END iliskili_musteri_vergi_no,
            mi.iliski_kodu,
            mi.istirak_oran,
            mi.gecici_bastarih AS gecici_bastarih,
            CASE WHEN TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY') < TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY')
                      AND TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY') <> TO_DATE ('01/01/1900', 'DD/MM/YYYY')
                      THEN TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY')
                 WHEN TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY') = TO_DATE ('01/01/1900', 'DD/MM/YYYY')
                      THEN TO_DATE ('01/01/1900', 'DD/MM/YYYY')
                 ELSE TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY')
             END gecici_bittarih,
            --CASE WHEN
            --LEAST (CASE WHEN TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY') = TO_DATE ('01/01/1900', 'DD/MM/YYYY') THEN TO_DATE ('31/12/2099', 'DD/MM/YYYY') ELSE TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY') END, TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY'))
            --= TO_DATE ('31/12/2099', 'DD/MM/YYYY') AND GREATEST (TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY'), TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY')) BETWEEN TO_DATE ('01/01/1900', 'DD/MM/YYYY') + 1 AND TO_DATE ('31/12/2099', 'DD/MM/YYYY') - 1
            --THEN GREATEST (TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY'), TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY'))
            --ELSE LEAST (CASE WHEN TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY') = TO_DATE ('01/01/1900', 'DD/MM/YYYY') THEN TO_DATE ('31/12/2099', 'DD/MM/YYYY') ELSE TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY') END, TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY'))
            --END gecici_bastarih,
            --GREATEST (TO_DATE (mi.gecici_bastarih, 'DD/MM/YYYY'), TO_DATE (mi.gecici_bittarih, 'DD/MM/YYYY')) gecici_bittarih,
            sp.kodaciklama AS iliski_kod_acklm,
            fk.id AS iliski_kkb_kod,
            fk.value AS iliski_kkb_kod_acklm,SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_musteri_iliski mi
            INNER JOIN trfm.tmp_trbfc_vortex_mus t ON mi.musteri_no=t.musteri_no
            INNER JOIN ofsdata.musteri_master_cs_hist mm ON  1=1
                                                         AND mi.musteri_no2 = mm.musteri_no
                                                         AND mm.musteri_tip NOT IN (73,80,81,82,84,85,87,88,89,91,92,93)
                                                         AND mm.durum<>9
                                                         AND mm.tarih = v_tarih
            INNER JOIN extr.fs_mustur mt ON mm.musteri_tip = mt.tip
            INNER JOIN extr.fs_secimparam sp ON CASE WHEN mm.musteri_tip IN (14, 97) THEN 19001
                                                     WHEN mm.musteri_tip NOT IN (14, 97) AND mt.gercek_tuzel = 'T' THEN 19097
                                                     WHEN mt.gercek_tuzel = 'G' THEN 19098
                                                END = sp.secimtip
                                             AND TO_CHAR (mi.iliski_kodu) = sp.kod
            INNER JOIN prsn.prmfirmailiskikodu fk ON DECODE (sp.kodaciklama, 'FÝRMA - HÝSSEDAR', 1,
                                                                             'FÝRMA-HÝSSEDAR', 1,
                                                                             'FÝRMA - YÖNETÝCÝ', 3,
                                                                             'FÝRMA - KEFÝL', 4,
                                                                             'FÝRMA - ÝÞTÝRAK', 2
                                                            ) = TO_NUMBER (TRIM (fk.id))
      WHERE 1 = 1
            AND NOT (
                           mi.iliski_kodu = 7
                       AND mi.istirak_oran < 1
                     )
            AND mi.iliski_kodu NOT IN (1, 9, 10, 11, 16, 20)
            AND NOT (
                           TO_NUMBER (TRIM (fk.id)) = 2
                       AND LENGTH (
                                   CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                              OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                              OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                              OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                              OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                              OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                              OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                              OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                              OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                              OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                              OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                              OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                 THEN NULL
                                                      ELSE mm.vergi_no
                                                           END
                                  ) = 11
                      )
            AND NOT (
                            TO_NUMBER (TRIM (fk.id)) = 3
                        AND LENGTH (
                                    CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                               OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                               OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                               OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                               OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                               OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                               OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                               OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                               OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                               OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                               OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                               OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                  THEN NULL
                                                       ELSE mm.vergi_no
                                                            END
                                   ) < 11
                       )
             AND mi.musteri_no <> mi.musteri_no2
             AND t.vergi_no <> mm.vergi_no;

      COMMIT;
      v_line_no:= 320;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_ILISKILI_MUS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 325;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_iliskili_mus
     SELECT o2.kesit_tarihi,
            o2.musteri_no,
            o2.iliskili_musteri_no,
            o2.istirak_oran, o2.gecici_bastarih, o2.gecici_bittarih,
            o2.iliski_kkb_kod,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbfc_iliskili_mus_01 o2
            INNER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f k
                       ON     1 = 1
                          AND o2.iliskili_musteri_tip = k.musteri_tip
      WHERE 1 = 1
        AND TO_NUMBER (o2.iliskili_musteri_vergi_no) > 1111111
        AND CASE WHEN LENGTH (TO_NUMBER (o2.iliskili_musteri_vergi_no)) BETWEEN 7 AND 10 AND k.tckn_vkn = 'VKN' THEN etl.sf_ymus_vergicheck_to_number (o2.iliskili_musteri_vergi_no)
                 WHEN LENGTH (TO_NUMBER (o2.iliskili_musteri_vergi_no)) = 11 AND k.tckn_vkn = 'TCKN' THEN etl.sf_ymus_tckncheck_to_number (o2.iliskili_musteri_vergi_no)
                           END = 1;

      COMMIT;

   --TRBIC segmenti ile 02-Ýþtirak iliþkisi bildirilemez. TRBFC segmenti ile 03-Yönetici iliþkisi bildirilemez."

   ------

   --KEFÝL MÜÞTERÝ TABLOSU (TRBGR'de ilgili temp query'ler çalýþtýktan sonra kullanýlmalý)

      v_line_no:= 330;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_KKB_SIRKT_TIP',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 335;

      INSERT               /*+ APPEND */ INTO trfm.tmp_kkb_sirkt_tip
      SELECT               /*+ full(mm) */
             TO_DATE (m.tarih, 'DD/MM/YYYY') AS kst_trh,
             m.musteri_no,
             p.id AS sirket_tip_id,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
      FROM   ofsdata.musteri_master_cs_hist m,
             extr.fs_mustur mtr,
             extr.fs_sube s,
             extr.fs_musteri_vergidairesi mv,
             extr.fs_sirkettip srk,
             extr.fs_tsicmem tsmem,
             opr.prmfirmaturu p,
             extr.fs_musteri_master mm           --ts_mem_kod  OFSDATA.musteri_master_cs_hist içinde bulunmadýðý için historik tabloya gidilemedi.
      WHERE  1=1
             AND s.sube = m.ana_sube
             AND mm.vergid_kod = mv.vd_kod(+)
             AND m.musteri_tip = mtr.tip(+)
             AND mtr.tip = srk.sirkettip(+)
             AND p.lookupvalue(+) = mtr.tip
             AND tsmem.ticsicil (+)= mm.ts_mem_kod
             AND m.durum<>9
             AND m.tarih = v_tarih
             AND m.musteri_no = mm.musteri_no;

      COMMIT;


      v_line_no:= 340;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_ANA_MUS_SET_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 345;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_ana_mus_set_01
     SELECT DISTINCT
            a.kesit_tarihi,
            b.musteri_no,
            b.calisma_sekli,
            b.musteri_tip,
            CASE WHEN LENGTH (TRIM (
                                    CASE WHEN     UPPER (b.vergi_no) LIKE '%A%' OR UPPER (b.vergi_no) LIKE '%B%' OR UPPER (b.vergi_no) LIKE '%C%'
                                               OR UPPER (b.vergi_no) LIKE '%D%' OR UPPER (b.vergi_no) LIKE '%E%' OR UPPER (b.vergi_no) LIKE '%F%'
                                               OR UPPER (b.vergi_no) LIKE '%G%' OR UPPER (b.vergi_no) LIKE '%H%' OR UPPER (b.vergi_no) LIKE '%I%'
                                               OR UPPER (b.vergi_no) LIKE '%J%' OR UPPER (b.vergi_no) LIKE '%K%' OR UPPER (b.vergi_no) LIKE '%L%'
                                               OR UPPER (b.vergi_no) LIKE '%M%' OR UPPER (b.vergi_no) LIKE '%N%' OR UPPER (b.vergi_no) LIKE '%O%'
                                               OR UPPER (b.vergi_no) LIKE '%P%' OR UPPER (b.vergi_no) LIKE '%R%' OR UPPER (b.vergi_no) LIKE '%S%'
                                               OR UPPER (b.vergi_no) LIKE '%T%' OR UPPER (b.vergi_no) LIKE '%U%' OR UPPER (b.vergi_no) LIKE '%V%'
                                               OR UPPER (b.vergi_no) LIKE '%Y%' OR UPPER (b.vergi_no) LIKE '%Z%' OR UPPER (b.vergi_no) LIKE '%Ç%'
                                               OR UPPER (b.vergi_no) LIKE '%Ö%' OR UPPER (b.vergi_no) LIKE '%Ð%' OR UPPER (b.vergi_no) LIKE '%Þ%'
                                               OR UPPER (b.vergi_no) LIKE '%Ü%' OR UPPER (b.vergi_no) LIKE '%Ý%' OR UPPER (b.vergi_no) LIKE '%X%'
                                               OR UPPER (b.vergi_no) LIKE '%W%' OR UPPER (b.vergi_no) LIKE '%Q%' OR UPPER (b.vergi_no) LIKE '%,%'
                                               OR UPPER (b.vergi_no) LIKE '%-%' OR UPPER (b.vergi_no) LIKE '% %' OR UPPER (b.vergi_no) LIKE '%/%'
                                                  THEN NULL
                                                       ELSE b.vergi_no
                                                            END
                                   )) = 11 AND SUBSTR (TRIM (
                                                            CASE WHEN     UPPER (b.vergi_no) LIKE '%A%' OR UPPER (b.vergi_no) LIKE '%B%' OR UPPER (b.vergi_no) LIKE '%C%'
                                                                       OR UPPER (b.vergi_no) LIKE '%D%' OR UPPER (b.vergi_no) LIKE '%E%' OR UPPER (b.vergi_no) LIKE '%F%'
                                                                       OR UPPER (b.vergi_no) LIKE '%G%' OR UPPER (b.vergi_no) LIKE '%H%' OR UPPER (b.vergi_no) LIKE '%I%'
                                                                       OR UPPER (b.vergi_no) LIKE '%J%' OR UPPER (b.vergi_no) LIKE '%K%' OR UPPER (b.vergi_no) LIKE '%L%'
                                                                       OR UPPER (b.vergi_no) LIKE '%M%' OR UPPER (b.vergi_no) LIKE '%N%' OR UPPER (b.vergi_no) LIKE '%O%'
                                                                       OR UPPER (b.vergi_no) LIKE '%P%' OR UPPER (b.vergi_no) LIKE '%R%' OR UPPER (b.vergi_no) LIKE '%S%'
                                                                       OR UPPER (b.vergi_no) LIKE '%T%' OR UPPER (b.vergi_no) LIKE '%U%' OR UPPER (b.vergi_no) LIKE '%V%'
                                                                       OR UPPER (b.vergi_no) LIKE '%Y%' OR UPPER (b.vergi_no) LIKE '%Z%' OR UPPER (b.vergi_no) LIKE '%Ç%'
                                                                       OR UPPER (b.vergi_no) LIKE '%Ö%' OR UPPER (b.vergi_no) LIKE '%Ð%' OR UPPER (b.vergi_no) LIKE '%Þ%'
                                                                       OR UPPER (b.vergi_no) LIKE '%Ü%' OR UPPER (b.vergi_no) LIKE '%Ý%' OR UPPER (b.vergi_no) LIKE '%X%'
                                                                       OR UPPER (b.vergi_no) LIKE '%W%' OR UPPER (b.vergi_no) LIKE '%Q%' OR UPPER (b.vergi_no) LIKE '%,%'
                                                                       OR UPPER (b.vergi_no) LIKE '%-%' OR UPPER (b.vergi_no) LIKE '% %' OR UPPER (b.vergi_no) LIKE '%/%'
                                                                          THEN NULL
                                                                               ELSE b.vergi_no
                                                                                    END
                                                            ), 1, 1) <> '0' THEN TRIM (
                                                                                      CASE WHEN     UPPER (b.vergi_no) LIKE '%A%' OR UPPER (b.vergi_no) LIKE '%B%' OR UPPER (b.vergi_no) LIKE '%C%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%D%' OR UPPER (b.vergi_no) LIKE '%E%' OR UPPER (b.vergi_no) LIKE '%F%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%G%' OR UPPER (b.vergi_no) LIKE '%H%' OR UPPER (b.vergi_no) LIKE '%I%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%J%' OR UPPER (b.vergi_no) LIKE '%K%' OR UPPER (b.vergi_no) LIKE '%L%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%M%' OR UPPER (b.vergi_no) LIKE '%N%' OR UPPER (b.vergi_no) LIKE '%O%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%P%' OR UPPER (b.vergi_no) LIKE '%R%' OR UPPER (b.vergi_no) LIKE '%S%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%T%' OR UPPER (b.vergi_no) LIKE '%U%' OR UPPER (b.vergi_no) LIKE '%V%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%Y%' OR UPPER (b.vergi_no) LIKE '%Z%' OR UPPER (b.vergi_no) LIKE '%Ç%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%Ö%' OR UPPER (b.vergi_no) LIKE '%Ð%' OR UPPER (b.vergi_no) LIKE '%Þ%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%Ü%' OR UPPER (b.vergi_no) LIKE '%Ý%' OR UPPER (b.vergi_no) LIKE '%X%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%W%' OR UPPER (b.vergi_no) LIKE '%Q%' OR UPPER (b.vergi_no) LIKE '%,%'
                                                                                                 OR UPPER (b.vergi_no) LIKE '%-%' OR UPPER (b.vergi_no) LIKE '% %' OR UPPER (b.vergi_no) LIKE '%/%'
                                                                                                    THEN NULL
                                                                                                         ELSE b.vergi_no
                                                                                                              END
                                                                                      ) END tck_no,
            CASE WHEN LENGTH (TRIM (
                                   CASE WHEN     UPPER (b.vergi_no) LIKE '%A%' OR UPPER (b.vergi_no) LIKE '%B%' OR UPPER (b.vergi_no) LIKE '%C%'
                                              OR UPPER (b.vergi_no) LIKE '%D%' OR UPPER (b.vergi_no) LIKE '%E%' OR UPPER (b.vergi_no) LIKE '%F%'
                                              OR UPPER (b.vergi_no) LIKE '%G%' OR UPPER (b.vergi_no) LIKE '%H%' OR UPPER (b.vergi_no) LIKE '%I%'
                                              OR UPPER (b.vergi_no) LIKE '%J%' OR UPPER (b.vergi_no) LIKE '%K%' OR UPPER (b.vergi_no) LIKE '%L%'
                                              OR UPPER (b.vergi_no) LIKE '%M%' OR UPPER (b.vergi_no) LIKE '%N%' OR UPPER (b.vergi_no) LIKE '%O%'
                                              OR UPPER (b.vergi_no) LIKE '%P%' OR UPPER (b.vergi_no) LIKE '%R%' OR UPPER (b.vergi_no) LIKE '%S%'
                                              OR UPPER (b.vergi_no) LIKE '%T%' OR UPPER (b.vergi_no) LIKE '%U%' OR UPPER (b.vergi_no) LIKE '%V%'
                                              OR UPPER (b.vergi_no) LIKE '%Y%' OR UPPER (b.vergi_no) LIKE '%Z%' OR UPPER (b.vergi_no) LIKE '%Ç%'
                                              OR UPPER (b.vergi_no) LIKE '%Ö%' OR UPPER (b.vergi_no) LIKE '%Ð%' OR UPPER (b.vergi_no) LIKE '%Þ%'
                                              OR UPPER (b.vergi_no) LIKE '%Ü%' OR UPPER (b.vergi_no) LIKE '%Ý%' OR UPPER (b.vergi_no) LIKE '%X%'
                                              OR UPPER (b.vergi_no) LIKE '%W%' OR UPPER (b.vergi_no) LIKE '%Q%' OR UPPER (b.vergi_no) LIKE '%,%'
                                              OR UPPER (b.vergi_no) LIKE '%-%' OR UPPER (b.vergi_no) LIKE '% %' OR UPPER (b.vergi_no) LIKE '%/%'
                                                 THEN NULL
                                                      ELSE b.vergi_no
                                                           END
                                   )) IN (9, 10) THEN TRIM (
                                                            CASE WHEN     UPPER (b.vergi_no) LIKE '%A%' OR UPPER (b.vergi_no) LIKE '%B%' OR UPPER (b.vergi_no) LIKE '%C%'
                                                                       OR UPPER (b.vergi_no) LIKE '%D%' OR UPPER (b.vergi_no) LIKE '%E%' OR UPPER (b.vergi_no) LIKE '%F%'
                                                                       OR UPPER (b.vergi_no) LIKE '%G%' OR UPPER (b.vergi_no) LIKE '%H%' OR UPPER (b.vergi_no) LIKE '%I%'
                                                                       OR UPPER (b.vergi_no) LIKE '%J%' OR UPPER (b.vergi_no) LIKE '%K%' OR UPPER (b.vergi_no) LIKE '%L%'
                                                                       OR UPPER (b.vergi_no) LIKE '%M%' OR UPPER (b.vergi_no) LIKE '%N%' OR UPPER (b.vergi_no) LIKE '%O%'
                                                                       OR UPPER (b.vergi_no) LIKE '%P%' OR UPPER (b.vergi_no) LIKE '%R%' OR UPPER (b.vergi_no) LIKE '%S%'
                                                                       OR UPPER (b.vergi_no) LIKE '%T%' OR UPPER (b.vergi_no) LIKE '%U%' OR UPPER (b.vergi_no) LIKE '%V%'
                                                                       OR UPPER (b.vergi_no) LIKE '%Y%' OR UPPER (b.vergi_no) LIKE '%Z%' OR UPPER (b.vergi_no) LIKE '%Ç%'
                                                                       OR UPPER (b.vergi_no) LIKE '%Ö%' OR UPPER (b.vergi_no) LIKE '%Ð%' OR UPPER (b.vergi_no) LIKE '%Þ%'
                                                                       OR UPPER (b.vergi_no) LIKE '%Ü%' OR UPPER (b.vergi_no) LIKE '%Ý%' OR UPPER (b.vergi_no) LIKE '%X%'
                                                                       OR UPPER (b.vergi_no) LIKE '%W%' OR UPPER (b.vergi_no) LIKE '%Q%' OR UPPER (b.vergi_no) LIKE '%,%'
                                                                       OR UPPER (b.vergi_no) LIKE '%-%' OR UPPER (b.vergi_no) LIKE '% %' OR UPPER (b.vergi_no) LIKE '%/%'
                                                                          THEN NULL
                                                                               ELSE b.vergi_no
                                                                                    END
                                                           ) END vergi_no,
            c.gercek_tuzel,
            d.ts_no1 AS ticaret_sicil_no,
            d.vergid_kod AS vergi_dairesi_kod,
            e.aciklama AS vergi_dairesi,
            f.kurulus_tarih AS tescil_tarihi,
            f.sirket_tip AS firma_turu_ing,
            kst.sirket_tip_id AS firma_turu_kkb,
            b.ana_sube,
            g.ilkodu,
            b.isim_unvan,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM
            (
              SELECT kesit_tarihi, musteri_no FROM trfm.tmp_trbfc_vortex_mus
            UNION
              SELECT kesit_tarihi, iliskili_musteri_no AS musteri_no FROM trfm.tmp_trbfc_iliskili_mus
            UNION
              SELECT DISTINCT k.kst_trh AS kesit_tarihi, k.kefil_musteri_no AS musteri_no
                FROM trfm.tmp_trbgr_kfl_mus k
               WHERE 1 = 1
                     AND EXISTS (SELECT 1 FROM trfm.tmp_trbfc_vortex_mus a WHERE k.kst_trh = a.kesit_tarihi AND k.musteri = a.musteri_no )
            ) a
            INNER JOIN ofsdata.musteri_master_cs_hist B ON  1=1
                                                        AND a.musteri_no= b.musteri_no
                                                        AND a.kesit_tarihi = b.tarih
            LEFT JOIN extr.fs_mustur c ON b.musteri_tip=c.tip
            LEFT JOIN extr.fs_musteri_master d ON a.musteri_no = d.musteri_no --ts_no1  ofsdata.musteri_master_cs_hist içinde bulunmadýðý için historik tabloya gidilemedi.
            LEFT JOIN extr.fs_musteri_vergidairesi e ON d.vergid_kod = e.vd_kod
            LEFT JOIN extr.fs_musteri_tuzel f ON a.musteri_no= f.musteri_no
            LEFT JOIN extr.fs_sube g ON b.ana_sube =g.sube
            LEFT JOIN trfm.tmp_kkb_sirkt_tip kst ON  1=1
                                        AND a.musteri_no= kst.musteri_no
                                        AND a.kesit_tarihi = kst.kst_trh
                                               --LEFT JOIN prsn.prmililcekodlari H ---not:coklama oluyor,ilkodu bazýnda
                                               --ON G.ILKODU =TO_NUMBER(H.id1)
                                           --    WHERE a.musteri_no =7106613
      WHERE 1 = 1
            AND a.kesit_tarihi = v_tarih;

      COMMIT;
      v_line_no:= 350;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_ANA_MUS_SET',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 355;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_ana_mus_set
     SELECT o.kesit_tarihi, o.musteri_no, o.calisma_sekli, o.musteri_tip, o.tck_no, o.vergi_no, o.gercek_tuzel, o.ticaret_sicil_no,
            o.vergi_dairesi_kod, o.vergi_dairesi, o.tescil_tarihi, o.firma_turu_ing, o.firma_turu_kkb, o.ana_sube, o.ilkodu, o.isim_unvan,
            k.tckn_vkn AS kontrol_tckn_vkn_f,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbfc_ana_mus_set_01 o
            INNER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f k
                       ON     1 = 1
                          AND o.musteri_tip = k.musteri_tip
      WHERE 1 = 1
        AND CASE WHEN LENGTH (TO_NUMBER (o.vergi_no)) BETWEEN 7 AND 10 AND k.tckn_vkn = 'VKN' THEN etl.sf_ymus_vergicheck_to_number (o.vergi_no)
                 WHEN LENGTH (TO_NUMBER (o.tck_no)) = 11 AND k.tckn_vkn = 'TCKN' THEN etl.sf_ymus_tckncheck_to_number (o.tck_no)
                           END = 1;
      COMMIT;


      v_line_no:= 360;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_EV_ADRS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 365;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_ev_adrs
      SELECT kesit_tarihi, musteri_no, ev_mahalle, ev_il_kodu, ev_lokasyon, ev_cadde, ev_sokak, ev_binablok, ev_binadaireno,
             ev_daireno, ev_posta_kod, ev_il_aciklama, ev_ilce_aciklama, ev_ulke_aciklama, kkb_ev_il_ilce_kod, ev_adres, ulke,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM (
              SELECT d.kesit_tarihi, a.musteri_no,
                     ROW_NUMBER () OVER (PARTITION BY a.musteri_no ORDER BY a.refno DESC) AS sira,
                     a.mahalle AS ev_mahalle, a.il AS ev_il_kodu, a.lokasyon AS ev_lokasyon, a.cadde AS ev_cadde, a.sokak AS ev_sokak, a.binablok AS ev_býnablok,
                     a.binadaireno AS ev_býnadaireno, a.daireno AS ev_daireno, a.posta_kod AS ev_posta_kod, i.aciklama AS ev_il_aciklama, c.aciklama AS ev_ilce_aciklama,
                     u.aciklama AS ev_ulke_aciklama, --f.id2 AS kkb_ev_il_ilce_kod,
                     c.ilce AS kkb_ev_il_ilce_kod,
                     a.mahalle || ' ' || a.lokasyon || ' ' || a.cadde || ' ' || a.sokak || ' ' || a.binablok || ' ' || a.binadaireno || ' ' || a.daireno || ' ' ||
                     CASE WHEN LENGTH (a.posta_kod) = 5 THEN 'PK :' || a.posta_kod ELSE NULL END || ' ' || c.aciklama || ' ' || i.aciklama || ' ' || u.aciklama AS ev_adres,
                     a.ulke
                FROM trfm.tmp_trbfc_ana_mus_set d,
                     extr.fs_musteri_adres a,
                     extr.fs_il i,
                     extr.fs_ilce c,
                     extr.fs_ulke u--,
                     --prsn.prmililcekodlari f
               WHERE 1 = 1
                     AND d.musteri_no = a.musteri_no
                     AND d.kesit_tarihi = v_tarih
                     AND a.il = i.il (+)
                     AND a.ulke = u.ulke (+)
                     AND a.il = c.il (+)
                     AND a.ilce = c.ilce (+)
                     --AND c.il = TO_NUMBER (f.id1 (+))
                     --AND LPAD (c.ilce, 2, '0') = f.id2 (+)
                     AND a.durum = 0
                     --AND a.irt_adresisw = 'E'
                     AND a.adres_tur = 1
             )
       WHERE sira = 1;

       COMMIT;

      v_line_no:= 370;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_ISYR_ADRS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 375;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_isyr_adrs
      SELECT kesit_tarihi, musteri_no, isyeri_mahalle, isyeri_lokasyon, isyeri_cadde, isyeri_sokak, isyeri_binablok,
             isyeri_binadaireno, isyeri_daireno, isyeri_posta_kod, isyeri_il_kodu, isyeri_il_aciklama,
             isyeri_ilce_aciklama, isyeri_ulke_aciklama, kkb_isyeri_il_ilce_kod, isyeri_adres, ulke,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM (
              SELECT d.kesit_tarihi,
                     a.musteri_no,
                     ROW_NUMBER() OVER (PARTITION BY a.musteri_no ORDER BY a.refno DESC) AS sira,
                     a.mahalle AS isyeri_mahalle,
                     a.lokasyon AS isyeri_lokasyon,
                     a.cadde AS isyeri_cadde,
                     a.sokak AS isyeri_sokak,
                     a.binablok AS isyeri_binablok,
                     a.binadaireno AS isyeri_binadaireno,
                     a.daireno AS isyeri_daireno,
                     a.posta_kod AS isyeri_posta_kod,
                     a.il AS isyeri_il_kodu,
                     i.aciklama AS isyeri_il_aciklama,
                     c.aciklama AS isyeri_ilce_aciklama,
                     u.aciklama AS isyeri_ulke_aciklama,
                     --f.id2 AS kkb_isyeri_il_ilce_kod,
                     c.ilce AS kkb_isyeri_il_ilce_kod,
                     (a.mahalle|| ' '||a.lokasyon||' '||a.cadde||' '||a.sokak||' '||a.binablok||' '||a.binadaireno ||' '|| a.daireno || ' '
                      || CASE WHEN LENGTH(a.posta_kod) =5 THEN 'PK :'||a.posta_kod ELSE NULL END
                      ||' '||c.aciklama ||' '||i.aciklama ||' '||u.aciklama
                     ) AS isyeri_adres,
                     a.ulke
                FROM trfm.tmp_trbfc_ana_mus_set d,
                     extr.fs_musteri_adres a,
                     extr.fs_il i,
                     extr.fs_ilce c,
                     extr.fs_ulke u--,
                     --prsn.prmililcekodlari f
               WHERE 1 = 1
                     AND d.musteri_no =a.musteri_no
                     AND d.kesit_tarihi =v_tarih
                     AND a.il = i.il (+)
                     AND a.ulke = u.ulke (+)
                     AND a.il = c.il (+)
                     AND a.ilce = c.ilce (+)
                     --AND c.il = TO_NUMBER (f.id1 (+))
                     --AND c.aciklama = f.value (+)
                     AND a.durum = 0
                     --AND a.irt_adresisw = 'E'
                     AND a.adres_tur = 2
             )
       WHERE 1=1
             AND sira =1;

       COMMIT;

      v_line_no:= 380;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_TLFN_KOD',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

   ---telefon kodu
      v_line_no:= 385;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_tlfn_kod
     SELECT kesit_tarihi, musteri_no, ulke_kodu, SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih AS kesit_tarihi,
                      i.musteri_no,
                      TRIM(i.ulke_kodu) AS ulke_kodu,
                      ROW_NUMBER () OVER (PARTITION BY i.musteri_no ORDER BY DECODE (i.irtibat_tur,
                                                                                                    5, '1. sýra',
                                                                                                    3, '2. sýra',
                                                                                                    1, '3. sýra'--,
                                                                                                    --2, '4. sýra',
                                                                                                                 ),
                                                                                                                    i.refno
                                                                                                                           ) AS sira
                 FROM extr.fs_musteri_irtibat i
                WHERE 1 = 1
                  AND i.durum = 0
                  AND i.irtibat_tur IN (5, 3, 1              /*, 2*/)
                  AND TRIM (i.ulke_kodu) IS NOT NULL
            )
      WHERE 1 = 1
        AND sira = 1;

      COMMIT;

      v_line_no:= 390;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_TLFN_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 395;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_tlfn_01
     SELECT f.kesit_tarihi, f.sira, f.musteri_no, f.ulke_kodu, f.alan_kodu, f.numara, f.formatli_tel_no, f.tip,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (SELECT               /*+ parallel(mi 8) */
                    v_tarih AS kesit_tarihi,
                    ROW_NUMBER() OVER(PARTITION BY mi.musteri_no,mi.irtibat_tur ORDER BY mi.refno DESC, mi.updtarih DESC, mi.updzaman DESC, mi.sira_no) AS sira,
                    mi.musteri_no,
                    mi.ulke_kodu,
                    mi.alan_kodu,
                    mi.numara,
                    mi.ulke_kodu || mi.alan_kodu || TRIM(mi.numara) AS formatli_tel_no,
                    CASE mi.irtibat_tur WHEN 5 THEN 'Cep Tel'
                                        WHEN 3 THEN 'Ýþyeri Tel'
                                        WHEN 1 THEN 'Ev Tel'
                    END AS tip
               FROM extr.fs_musteri_irtibat mi
              WHERE 1 = 1
                    AND mi.durum = 0
                    AND mi.irtibat_tur IN (1,3,5)
                    AND mi.ulke_kodu <> 0
                    AND mi.alan_kodu <> 0
                    AND TRIM(mi.numara) NOT IN ('0', '1')
            ) f
      WHERE 1 = 1
            AND f.sira = 1;

      COMMIT;

      v_line_no:= 400;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_TLFN',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 405;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_tlfn
      SELECT t.kesit_tarihi, t.musteri_no, t.ulke_kodu, t.alan_kodu, t.numara, t.formatli_tel_no,
             ROW_NUMBER () OVER (PARTITION BY t.kesit_tarihi, t.musteri_no ORDER BY DECODE (t.tip, 'Cep Tel'        , 1,
                                                                                                   'Ýþyeri Tel'     , 2,
                                                                                                   'Ev Tel'         , 3
                                                                                           )
                                ) AS tel_tip_sira,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM trfm.tmp_trbfc_tlfn_01 t
       WHERE 1 = 1;

       COMMIT;

   ---eposta

      v_line_no:= 410;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_MAIL',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 415;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_mail
      SELECT v_tarih AS kesit_tarihi,
             musteri_no,
             mail,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM (
              SELECT DISTINCT a.musteri_no, a.mail
                FROM extr.fs_musteri_mail a
                     INNER JOIN (  SELECT musteri_no,
                                          MAX (refno) AS max_refno
                                     FROM extr.fs_musteri_mail
                                    WHERE 1=1
                                          AND durum = 0
                                 GROUP BY musteri_no
                                ) i ON  1=1
                                    AND a.musteri_no = i.musteri_no
                                    AND a.refno = i.max_refno
               WHERE a.durum = 0
             );

      COMMIT;



      v_line_no:= 420;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_WEB_ADRS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

   --WEB Adresi
      v_line_no:= 425;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_web_adrs
     SELECT v_tarih kst_trh,
            md.musteri_no,
            TRIM (md.web_adresi) AS web_adresi,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_musteri_detay md
      WHERE 1=1
            AND md.durum = 0
            AND TRIM (md.web_adresi) IS NOT NULL
            AND TRIM (md.web_adresi) <> '1';

      COMMIT;

      v_line_no:= 430;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 435;
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_01
        SELECT   /*+ USE_HASH(f,m)  */
             v_tarih AS kesit_tarihi,
             f.musteri_no,
             CASE WHEN m.musteri_tip = 14 THEN NVL (f.donem_calisan_sayisi, 1) ELSE NVL (f.donem_calisan_sayisi, NULL) END AS donem_calisan_sayisi,
             f.ciro,
             0 AS ciro_para_kodu,
             EXTRACT (YEAR FROM f.tarih) AS yil,
             EXTRACT (MONTH FROM f.tarih) AS ay,
             m.musteri_tip,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
            FROM
                (select a.*,
                row_number() over (partition by musteri_no order by tarih desc, sira_no desc) sira
                from extr.fs_musteri_tuzel_mali  a
                                            WHERE 1 = 1
                                                  AND durum = 0
                                                  AND donem_calisan_sayisi > 0
                                                 -- and musteri_no=8242674
                                    ) f
                     LEFT JOIN ofsdata.MUSTERI_MASTER_CS_HIST m ON  1 = 1 AND f.musteri_no = m.musteri_no  AND '30/10/2017' = m.tarih
                                    where f.sira=1;

         COMMIT;



   --SELECT mt.musteri_no, mt.faaliyet_konusu FROM extr.fs_musteri_tuzel mt
   --inner join  kkb_finansman_konusu b ON a.faaliyet_konusu= mt.faaliyet_konusu;---edizden destek



      v_line_no:= 440;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_FIRM_GRP_KOD',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 445;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_firm_grp_kod
      SELECT v_tarih AS kesit_tarihi,
             mg.musteri_no,
             CASE WHEN mg.grup <= 999 THEN mg.grup ELSE NULL END AS grup,
             SUBSTR(g.aciklama, 1, 30) AS firma_grup_kodu,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
              --INTO RetVal.KFGRKD, RetVal.KFGRAD
        FROM extr.fs_musteri_grup mg,
             extr.fs_grup g
       WHERE 1 = 1
             --AND mg.musteri_no = arg_musteri
             AND g.grup = mg.grup
             AND mg.durum = 0
             AND g.gruptip = 3
             AND g.gruptur = 'K'
             AND mg.sira_no = 1;
      COMMIT;


   --RÝSK GRUP KODU

      v_line_no:= 450;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_RISK_GRP_KOD',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 455;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_risk_grp_kod
     SELECT v_tarih AS kesit_tarihi,
            ilk7 AS musteri_no,
            NVL(MAX(kod),0) AS risk_kod,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
                  --into ln_riskkod
        FROM (
               SELECT DISTINCT ilk7, 5 AS kod
                 FROM extr.fs_hplandet_sg
                WHERE 1 = 1
                  AND ana = 176
                  AND durum = 0
                  AND sinif = 'C'
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
            UNION
               SELECT DISTINCT ilk7, 5 AS kod
                 FROM extr.fs_eskiplan_sg
                WHERE 1 = 1
                  AND ana = 176
                  AND durum = 0
                  AND sinif = 'C'
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
            UNION
               SELECT ilk7, 4 kod
                 FROM extr.fs_hplandet_sg
                WHERE 1 = 1
               AND ana = 172
                  AND durum = 0
                  AND sinif = 'C'
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
            UNION
               SELECT ilk7, 4 AS kod
                 FROM extr.fs_eskiplan_sg
                WHERE 1 = 1
               AND ana = 172
                  AND durum = 0
                  AND sinif = 'C'
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
            UNION
               SELECT ilk7, 3 AS kod
                 FROM extr.fs_hplandet_sg
                WHERE 1 = 1
                  AND ana = 170
                  AND durum = 0
                  AND sinif = 'C'
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
            UNION
               SELECT ilk7, 3 AS kod
                 FROM extr.fs_eskiplan_sg
                WHERE 1 = 1
                  AND ana = 170
                  AND durum = 0
                  AND sinif = 'C'
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
            )
   GROUP BY ilk7;

      COMMIT;


   ---Risk Grup Kodu Sebebi :null

      v_line_no:= 460;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_MN_ACLS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 465;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_mn_acls_trh
     SELECT kst_trh, tip, ana, musteri_no,
            MIN (min_actarih) AS min_actarih,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih AS kst_trh,
                      DECODE (ana, 170, 'Grup 3', 172, 'Grup 4', 176, 'Grup 5') AS tip,
                      ana,
                      ilk7 AS musteri_no,
                      MIN (TRUNC (actarih)) AS min_actarih --06.12.2016
                 FROM extr.fs_hplandet_sg
                WHERE 1 = 1
                  AND sinif = 'C'
                  AND ana IN (170, 172, 176)
                  AND durum = 0
                  AND TRUNC (actarih) <= v_tarih
                  --AND ilk7 = 11342335
             GROUP BY DECODE (ana, 170, 'Grup 3', 172, 'Grup 4', 176, 'Grup 5'), ana, ilk7
             UNION ALL
               SELECT v_tarih AS kst_trh,
                      DECODE (ana, 170, 'Grup 3', 172, 'Grup 4', 176, 'Grup 5') AS tip,
                      ana,
                      ilk7 AS musteri_no,
                      MIN (TRUNC (actarih)) AS min_actarih --06.12.2016
                 FROM extr.fs_eskiplan_sg
                WHERE 1 = 1
                  AND sinif = 'C'
                  AND ana IN (170, 172, 176)
                  AND durum = 0
                  AND TRUNC (actarih) <= v_tarih
                  --AND ilk7 = 11342335
             GROUP BY DECODE (ana, 170, 'Grup 3', 172, 'Grup 4', 176, 'Grup 5'), ana, ilk7
            )
      WHERE 1 = 1
   GROUP BY kst_trh, tip, ana, musteri_no;

      COMMIT;

      v_line_no:= 470;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_MN_ACLS_BKY',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 475;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_mn_acls_bky
     SELECT kst_trh, tip, ana, musteri_no, min_actarih,
            SUM (takip_bakiye) AS takip_bakiye,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT m.kst_trh, m.tip, m.ana, m.musteri_no, m.min_actarih,
                      (
                         h.borc1 - h.alac1 + h.borc2 - h.alac2 + h.borc3 - h.alac3 + h.borc4 - h.alac4 + h.borc5 - h.alac5 + h.borc6 - h.alac6
                       + h.borc7 - h.alac7 + h.borc8 - h.alac8 + h.borc9 - h.alac9 + h.borc10 - h.alac10 + h.borc11 - h.alac11 + h.borc12 - h.alac12
                      ) takip_bakiye
                 FROM trfm.tmp_trbfc_mn_acls_trh m
                      INNER JOIN extr.fs_hplandet_sg h
                                     ON     1 = 1
                                        AND m.kst_trh = v_tarih
                                        AND m.ana = h.ana
                                        AND m.musteri_no = h.ilk7
                                        AND m.min_actarih = TRUNC (h.actarih)
                                        AND h.durum = 0
                                        AND h.sinif = 'C'
                WHERE 1 = 1
             UNION ALL
               SELECT m.kst_trh, m.tip, m.ana, m.musteri_no, m.min_actarih,
                      (
                         h.borc1 - h.alac1 + h.borc2 - h.alac2 + h.borc3 - h.alac3 + h.borc4 - h.alac4 + h.borc5 - h.alac5 + h.borc6 - h.alac6
                       + h.borc7 - h.alac7 + h.borc8 - h.alac8 + h.borc9 - h.alac9 + h.borc10 - h.alac10 + h.borc11 - h.alac11 + h.borc12 - h.alac12
                      ) takip_bakiye
                 FROM trfm.tmp_trbfc_mn_acls_trh m
                      INNER JOIN extr.fs_eskiplan_sg h
                                     ON     1 = 1
                                        AND m.kst_trh = v_tarih
                                        AND m.ana = h.ana
                                        AND m.musteri_no = h.ilk7
                                        AND m.min_actarih = TRUNC (h.actarih)
                                        AND h.durum = 0
                                        AND h.sinif = 'C'
                WHERE 1 = 1
            )
      WHERE 1 = 1
        AND takip_bakiye <> 0
   GROUP BY kst_trh, tip, ana, musteri_no, min_actarih;

      COMMIT;


      v_line_no:= 480;

   ---3.Gruba Alýnma Tarihi

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_GRP_ALNM_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 485;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_grp_alnm_01
       SELECT v_tarih AS kst_trh,
              ilk7 AS musteri_no,
              MIN (TRUNC(actarih)) AS min_actarih,
              ana,
              'GRUP3_ALINMA_TARIHI' AS tip,
              SYSDATE AS etl_trh,
              v_sp_name AS etl_job
         FROM extr.fs_hplandet_sg
        WHERE 1 = 1
              AND sinif = 'C'
              AND durum = 0
              AND ana = 170
              AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
     GROUP BY ilk7, ana
   UNION ALL
       SELECT v_tarih AS kst_trh,
              ilk7 AS musteri_no,
              MIN (TRUNC(actarih)) AS min_actarih,
              ana,
              'GRUP3_ALINMA_TARIHI' AS tip,
              SYSDATE AS etl_trh,
              v_sp_name AS etl_job
         FROM extr.fs_eskiplan_sg
        WHERE 1 = 1
              AND sinif = 'C'
              AND durum = 0
              AND ana = 170
              AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
     GROUP BY ilk7, ana
   UNION ALL
       SELECT v_tarih AS kst_trh,
              ilk7 AS musteri_no,
              MIN (TRUNC(actarih)) AS min_actarih,
              ana,
              'GRUP4_ALINMA_TARIHI' AS tip,
              SYSDATE AS etl_trh,
              v_sp_name AS etl_job
         FROM extr.fs_hplandet_sg
        WHERE 1 = 1
              AND sinif = 'C'
              AND durum = 0
              AND ana = 172
              AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
     GROUP BY ilk7, ana
   UNION ALL
       SELECT v_tarih AS kst_trh,
              ilk7 AS musteri_no,
              MIN (TRUNC(actarih)) AS min_actarih,
              ana,
              'GRUP4_ALINMA_TARIHI' AS  tip,
              SYSDATE AS etl_trh,
              v_sp_name AS etl_job
         FROM extr.fs_eskiplan_sg
        WHERE 1 = 1
              AND sinif = 'C'
              AND durum = 0
              AND ana = 172
              AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
     GROUP BY ilk7, ana
   UNION ALL
       SELECT v_tarih AS kst_trh,
              ilk7 musteri_no,
              MIN (TRUNC(actarih)) AS min_actarih,
              ana,
              'GRUP5_ALINMA_TARIHI' AS tip,
              SYSDATE AS etl_trh,
              v_sp_name AS etl_job
         FROM extr.fs_hplandet_sg
        WHERE 1 = 1
              AND sinif = 'C'
              AND durum = 0
              AND ana = 176
              AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
     GROUP BY ilk7, ana
   UNION ALL
       SELECT v_tarih AS kst_trh,
              ilk7 AS musteri_no,
              MIN (TRUNC(actarih)) AS min_actarih,
              ana,
              'GRUP5_ALINMA_TARIHI' AS tip,
              SYSDATE AS etl_trh,
              v_sp_name AS etl_job
         FROM extr.fs_eskiplan_sg
        WHERE 1 = 1
              AND sinif = 'C'
              AND durum = 0
              AND ana = 176
              AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
     GROUP BY ilk7, ana;

   COMMIT;

      v_line_no:= 490;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_GRP_ALNM',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 495;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_grp_alnm
        SELECT kst_trh, musteri_no, ana, tip,
               MIN (min_actarih) AS min_actarih,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM trfm.tmp_trbfc_grp_alnm_01 f
         WHERE 1 = 1
      GROUP BY kst_trh, musteri_no, ana, tip;

      COMMIT;

                 /*
   DROP TABLE trbfc_fct_tmp_10_3;     --
   CREATE TABLE trbfc_fct_tmp_10_3 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
     SELECT x.kst_trh, x.min_actarih, x.musteri_no, x.tip, x.ana,
            SUM (CASE WHEN g.borc <> 0 THEN g.borc WHEN mab.takip_bakiye <> 0 THEN mab.takip_bakiye END) takip_ttr
       FROM tmp_trbfc_grp_alnm x
            LEFT JOIN extr.fs_gunluk_hplandet_sg g
                            ON     1 = 1
                               AND x.min_actarih = g.tarih
                               AND x.musteri_no = g.ilk7
                               AND x.ana = g.ana
                               AND g.sinif = 'C'
                               AND g.durum = 0
                               AND g.borc <> 0
            LEFT JOIN tmp_trbfc_mn_acls_bky mab
                            ON     1 = 1
                               AND x.kst_trh = mab.kst_trh
                               AND x.ana = mab.ana
                               AND x.musteri_no = mab.musteri_no
      WHERE 1 = 1
            AND (CASE WHEN g.borc <> 0 THEN g.borc WHEN mab.takip_bakiye <> 0 THEN mab.takip_bakiye END) <> 0
   GROUP BY x.kst_trh, x.min_actarih, x.musteri_no, x.tip, x.ana;
   GRANT SELECT ON trbfc_fct_tmp_10_3 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
   --SELECT * FROM tmp_trbfc_grp_alnm x;
   --SELECT * FROM extr.fs_gunluk_hplandet_sg g;
   --SELECT * FROM tmp_trbfc_mn_acls_bky mab;
   --SELECT * FROM trbfc_fct_tmp_10_3;
   */

      v_line_no:= 500;
           ---- Limit deðerleri union all yapýlalcak.

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_LMT',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 505;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_lmt
      SELECT v_tarih AS kesit_tarihi,
             l.limitkodu AS musteri_no,
             l.tllimit,'Nakit Limit' AS tip,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM prsn.corp_limit_vw l
       WHERE 1 = 1
             AND l.tur = 'GE.NA'
             AND l.limittipi=6
   UNION ALL
      SELECT v_tarih AS kesit_tarihi,
             l.limitkodu AS musteri_no,
             l.tllimit,'GayriNakit Limit' AS tip,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM prsn.corp_limit_vw l
       WHERE 1 = 1
             AND l.tur = 'GE.GN'
             AND l.limittipi=6
   UNION ALL
      SELECT v_tarih AS kesit_tarihi,
             l.limitkodu AS musteri_no,
             l.tllimit,'Firma Genel Limiti'as tip,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM prsn.corp_limit_vw l
       WHERE 1 = 1
             AND l.tur = 'GE'
             AND l.limittipi=6;

      COMMIT;


      v_line_no:= 510;
           ---- Limit deðerleri union all yapýlalcak.

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_GRP_LMT_RSK',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 515;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_grp_lmt_rsk
      SELECT v_tarih AS kesit_tarihi,
             g.musteri_no,
             vw.limitkodu AS grup,
             tllimit AS tutar,
             'Grup Limiti' AS tip,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM prsn.corp_limit_vw vw
             INNER JOIN extr.fs_musteri_grup g
                       ON     1 = 1
                          AND vw.limitkodu = g.grup
                          AND g.durum = 0
                          AND g.sira_no = 1
             INNER JOIN extr.fs_grup p
                       ON     1 = 1
                          AND p.grup = g.grup
                          AND p.gruptur = 'K'
                          AND p.gruptip = 3
       WHERE 1=1
             AND vw.limittipi = 5
             AND vw.tur = 'GE'
   UNION ALL
      SELECT v_tarih AS kesit_tarihi,
             g.musteri_no,
             vw.limitkodu AS grup,
             (vw.giris - vw.cikis + vw.bloke) AS tutar,
             'Grup Riski' AS tip,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM extr.fs_corp_risk_vw vw
             INNER JOIN extr.fs_musteri_grup g
                       ON     1 = 1
                          AND vw.limitkodu = g.grup
                          AND g.durum = 0
                          AND g.sira_no = 1
             INNER JOIN extr.fs_grup p
                       ON     1 = 1
                          AND p.grup = g.grup
                          AND p.gruptur = 'K'
                          AND p.gruptip = 3
       WHERE 1=1
             AND vw.limittipi = 5
             AND vw.tur = 'GE';

      COMMIT;

      v_line_no:= 520;
           ---- Limit deðerleri union all yapýlalcak.

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_FNSMN_KOD',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 525;

    ---Finansman Konusu Kodu
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_fnsmn_kod
     SELECT v_tarih AS kesit_tarihi,
            mm.musteri_no,
            mm.sektor,
            NVL (
                 DECODE (
                         SUBSTR (s.tcmbkod, 1, 3), 'JAB', 'JD',
                                                   'ZZ', 'DIE',
                                                   SUBSTR (s.tcmbkod, 1, 3)
                        ),
                           'DIE'
                ) AS finansman_konusu_kodu,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM ofsdata.musteri_master_cs_hist mm
            LEFT OUTER JOIN extr.fs_sektor s
                            ON     1 = 1
                               AND mm.sektor = s.sektor
            LEFT OUTER JOIN trfm.tmp_fnsmn_konu t
                            ON     1 = 1
                               AND SUBSTR (s.tcmbkod, 1, 3) = t.finansman_konusu_kod
      WHERE 1 = 1
            AND mm.tarih = v_tarih;

      COMMIT;

      v_line_no:= 530;
           ---- Limit deðerleri union all yapýlalcak.

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_GNL_RVZ_VADE_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 535;

   ------------

   --Genel Revize Vadesi
      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_gnl_rvz_vade_01
     SELECT v_tarih AS kesit_tarihi,
            musteri,
            MAX (kredi_yenileme_vadesi) AS genel_revize_vadesi ,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_vortex_teklif
      WHERE 1=1
            AND sonkayit IN ('E', 'I')
   GROUP BY musteri;

      COMMIT;

      v_line_no:= 540;
      ---- Limit deðerleri union all yapýlalcak.

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_GNL_RVZ_VADE_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 545;

   --Genel Revize Vadesi (ikinci yol)

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_gnl_rvz_vade_02
     SELECT v_tarih AS kst_trh, musteri,
            MAX (TRUNC(kredi_yenileme_vadesi)) AS genel_revize_vadesi,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_teklif
      WHERE 1 = 1
        AND sonkayit IN ('E', 'I')
        --AND musteri = 19819135
   GROUP BY musteri;

      COMMIT;

      v_line_no:= 550;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_SON_RVZ_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 555;

      -----Son Revize Tarihi:

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_son_rvz_trh
     SELECT v_tarih AS kesit_tarihi,
            a.musteri AS musteri_no,
            MAX (TRUNC(a.tebtarih)) AS son_revize_tarihi,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_teklif a
      WHERE a.sonkayit IN ('E', 'I')
   GROUP BY a.musteri;

      COMMIT;

      v_line_no:= 560;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_WEB_STSI',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 565;
   ---WebSitesi

    INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_web_stsi
   SELECT v_tarih AS kesit_tarihi,
          TRIM (md.web_adresi) AS web_sitesi,
          md.musteri_no,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM extr.fs_musteri_detay md
    WHERE 1=1
          AND TRIM (md.web_adresi) IS NOT NULL
          AND md.durum = 0;

      COMMIT;

      v_line_no:= 570;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBFC_MN_HSP_ACLS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 575;

   --Üye ile çalýþmaya baþladýðý tarih

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbfc_mn_hsp_acls_trh
     SELECT kst_trh,
            musteri_no,
            MIN (min_hsp_acls_trh) AS min_hsp_acls_trh,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih AS kst_trh,
                      ilk7 AS musteri_no,
                      MIN (TO_DATE (actarih, 'DD/MM/YYYY')) AS min_hsp_acls_trh
                 FROM extr.fs_hplandet_sg
                WHERE 1 = 1
                  AND sinif = 'C'
                  AND durum = 0
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
             GROUP BY ilk7
             UNION ALL
               SELECT v_tarih AS kst_trh,
                      ilk7 AS musteri_no,
                      MIN (TO_DATE (actarih, 'DD/MM/YYYY')) AS min_hsp_acls_trh
                 FROM extr.fs_eskiplan_sg
                WHERE 1 = 1
                  AND sinif = 'C'
                  AND durum = 0
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
             GROUP BY ilk7
            )
      WHERE 1 = 1
   GROUP BY kst_trh, musteri_no;

      COMMIT;

      v_line_no:= 580;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_KKB_MSLK_PRMTR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 585;

      INSERT               /*+ APPEND */ INTO trfm.tmp_kkb_mslk_prmtr
     SELECT DISTINCT
            gk.is_meslek AS meslek_ing_kod,
            m.ad AS meslek_ing_kod_acklm,
            k.id AS meslek_kkb_kod,
            k.value AS meslek_kkb_kod_acklm,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_musteri_gercek gk
            INNER JOIN      extr.fs_musteri_meslek m
                            ON     1 = 1
                               AND gk.is_meslek = m.kod
            LEFT JOIN prsn.prmmeslekkodlari k
                            ON     1 = 1
                               AND DECODE (m.ad,
                                                 'KENDÝ ÝÞÝ/ÝÞYERÝ SAHÝBÝ / ESNAF', ' Isletme ',
                                                 'AVUKAT', 'Avukat ',
                                                 'ÇÝFTÇÝ', 'Diger',
                                                 'DANIÞMAN', 'Diger',
                                                 'DENETÇÝ/MÜFETTÝÞ', 'Müfettis ',
                                                 'DOKTOR/DÝÞ HEKÝMÝ', 'Doktor ',
                                                 'ECZACI', ' Eczaci ',
                                                 'GAZETECÝ / MEDYA ÇALIÞANI', 'Gazetecilik',
                                                 'HAKÝM/SAVCI', 'Hukuk ',
                                                 'HEMÞÝRE', ' Hemsire ',
                                                 'ÝÞÇÝ', 'Diger',
                                                 'MEMUR', 'Memurluk ',
                                                 'MÝMAR/MÜHENDÝS', ' Mimarlik ',
                                                 'MÜDÜR/MÜDÜR YARDIMCISI', 'Diger',
                                                 'OPERASYON/FÝNANS/ÝDARÝ ÝÞLER (YÖNETMEN, ÞEF, UZMAN, YETKÝLÝ)', 'Diger',
                                                 'ÖÐRETÝM GÖREVLÝSÝ/AKADEMÝSYEN', 'Akademisyen ',
                                                 'ÖÐRETMEN', ' Egitim ',
                                                 'PÝLOT/KAPTAN', 'Diger',
                                                 'POLÝS', 'Polis ',
                                                 'REKLAMCI/HALKLA ÝLÝÞKÝLER UZMANI', ' Halkla Iliskiler ve Tanitim ',
                                                 'SANATÇI/YAZAR', 'Yazar ',
                                                 'PAZARLAMA (YÖNETMEN, ÞEF, UZMAN, YETKÝLÝ)', 'Diger',
                                                 'SEKRETER', 'Sekreterlik ',
                                                 'SUBAY / ASTSUBAY', 'Memurluk ',
                                                 'SPORCU/ANTRENÖR', 'Diger',
                                                 'ÞOFÖR', 'Diger',
                                                 'TEKNÝK PERSONEL', 'Teknisyen ',
                                                 'ÜST DÜZEY YÖNETÝCÝ', 'Diger',
                                                 'GÜVENLÝK GÖREVLÝSÝ', 'Diger',
                                                 'UZMAN ÇAVUÞ', 'Memurluk ',
                                                 'SATIÞ TEMSÝLCÝSÝ', ' Halkla Iliskiler ve Tanitim ',
                                                 'MUHASEBECÝ/MALÝ MÜÞAVÝR', 'Muhasebeci ',
                                                 'PROGRAMCI/ANALÝST/YAZILIMCI', ' Bilgisayar Mühendisligi ',
                                                 'EMLAKÇI /GAYRÝMENKUL UZMANI', ' Emlakçilik ',
                                                 'NOTER', 'Noter ',
                                                 'DÝÐER', 'Diger',
                                                 'Diger'
                                          ) = k.value
      WHERE 1 = 1;

      COMMIT;

      v_line_no:= 590;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_KKB_EGTM_PRMTR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:= 595;

      INSERT               /*+ APPEND */ INTO trfm.tmp_kkb_egtm_prmtr
     SELECT DISTINCT
            gk.egitim AS egitim_ing_kod,
            e.kodaciklama AS egitim_ing_kod_acklm,
            ked.id AS egitim_kkb_kod,
            ked.value AS egitim_kkb_kod_acklm,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_musteri_gercek gk
            INNER JOIN extr.fs_secimparam e
                       ON  1 = 1
                       AND TO_CHAR (gk.egitim) = e.kod
                       AND e.secimtip = 219
            LEFT JOIN prsn.prmegitimdurumu ked
                      ON 1 = 1
                      AND DECODE (e.kodaciklama,
                                                 'ÝLKOKUL', 'Ilkokul mezunu',
                                                 'ORTA', 'Ilkögretim mezunu',
                                                 'LÝSE', 'Lise mezunu',
                                                 'ÜNÝVERSÝTE', 'Lisans (Üniversite)',
                                                 'Y.LÝSANS', 'Yüksek lisans',
                                                 'DÝPLOMASIZ', 'Diger',
                                                 'YÜKSEKOKUL', 'Ön lisans',
                                                 'Diger'
                                 ) = ked.value
      WHERE 1 = 1;

      COMMIT;

      v_line_no:= 600;






















      DELETE FROM prsn.kkb_trbfc_trbic_fct WHERE 1=1 AND kesit_tarihi = v_tarih;

      COMMIT;

      v_line_no:=605;

   -----Konsolidasyon-----

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_trbic_fct
     SELECT a.kesit_tarihi, a.ana_sube, a.calisma_sekli, a.firma_turu_ing, a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.ilkodu, a.isim_unvan, a.musteri_no, a.musteri_tip, a.tck_no,
            LPAD ('00'
                  || CASE WHEN a.tck_no IS NOT NULL THEN '6'
                          WHEN a.vergi_no IS NOT NULL THEN '5'
                          WHEN a.tck_no IS NULL AND a.vergi_no IS NULL THEN (
                                                                             CASE WHEN a.gercek_tuzel='G' THEN '6'
                                                                                  WHEN a.gercek_tuzel ='T' THEN '5'
                                                                             END
                                                                            )
                     END
                  || '000000'
                  || CASE WHEN a.tck_no IS NOT NULL THEN NULL
                          WHEN LENGTH (a.vergi_no) = 10 THEN '0'
                          WHEN LENGTH (a.vergi_no) = 9 THEN '00'
                     END
                  || CASE WHEN a.tck_no IS NULL AND a.vergi_no IS NULL THEN '           '
                          ELSE NVL (TO_CHAR (a.tck_no), TO_CHAR (a.vergi_no))
                     END
                  , 20, ' ') AS kayit_referans_numarasi, --bu kýsým bu query'de firma künye için yazýldý
            a.tescil_tarihi, a.ticaret_sicil_no, a.vergi_dairesi_kod, a.vergi_dairesi, a.vergi_no, b.ev_mahalle, b.ev_lokasyon, b.ev_cadde, b.ev_sokak, b.ev_binablok,
            b.ev_binadaireno, b.ev_daireno, b.ev_posta_kod, b.ev_il_aciklama, b.ev_ilce_aciklama, b.ev_ulke_aciklama, b.kkb_ev_il_ilce_kod, b.ev_adres, b.ev_il_kodu,
            b.ulke AS ev_ulke_kodu, c.isyeri_mahalle, c.isyeri_lokasyon, c.isyeri_cadde, c.isyeri_sokak, c.isyeri_binablok, c.isyeri_binadaireno, c.isyeri_daireno,
            c.isyeri_posta_kod, c.isyeri_il_kodu, c.isyeri_il_aciklama, c.isyeri_ilce_aciklama, c.isyeri_ulke_aciklama, c.kkb_isyeri_il_ilce_kod, c.isyeri_adres,
            c.ulke AS isyeri_ulke_kodu,
            --D.ULKE_KODU,
            --NVL (NVL (b.ulke, c.ulke), d.ulke_kodu) ulke_kodu,
            NVL (b.ulke, c.ulke) AS ulke_kodu,
            NVL (b.ev_ulke_aciklama, c.isyeri_ulke_aciklama) AS ulke_aciklama,
            e1.ulke_kodu AS ev_tel_ulke_kodu, e1.alan_kodu AS ev_tel_alan_kodu, e1.numara AS ev_tel_numara, e1.formatli_tel_no  ev_tel_formatlý_tel_no,
            e2.ulke_kodu AS isyeri_tel_ulke_kodu, e2.alan_kodu AS isyeri_tel_alan_kodu, e2.numara AS isyeri_tel_numara, e2.formatli_tel_no AS isyeri_tel_formatlý_tel_no,
            e3.ulke_kodu AS cep_tel_ulke_kodu, e3.alan_kodu AS cep_tel_alan_kodu, e3.numara AS cep_tel_numara, e3.formatli_tel_no AS cep_tel_formatlý_tel_no,
            --ft_1.formatli_tel_no_1,
            --ft_2.formatli_tel_no_2,
            CASE WHEN e3.formatli_tel_no IS NOT NULL THEN e3.ulke_kodu
                 WHEN e2.formatli_tel_no IS NOT NULL THEN e2.ulke_kodu
                 WHEN e1.formatli_tel_no IS NOT NULL THEN e1.ulke_kodu
                      END formatli_tel_no_1_ulke,
            CASE WHEN e3.formatli_tel_no IS NOT NULL THEN e3.alan_kodu
                 WHEN e2.formatli_tel_no IS NOT NULL THEN e2.alan_kodu
                 WHEN e1.formatli_tel_no IS NOT NULL THEN e1.alan_kodu
                      END formatli_tel_no_1_bolge,
            CASE WHEN e3.formatli_tel_no IS NOT NULL THEN e3.numara
                 WHEN e2.formatli_tel_no IS NOT NULL THEN e2.numara
                 WHEN e1.formatli_tel_no IS NOT NULL THEN e1.numara
                      END formatli_tel_no_1_tln_no,
            CASE WHEN e3.formatli_tel_no IS NOT NULL THEN e3.formatli_tel_no
                 WHEN e2.formatli_tel_no IS NOT NULL THEN e2.formatli_tel_no
                 WHEN e1.formatli_tel_no IS NOT NULL THEN e1.formatli_tel_no
                      END formatli_tel_no_1,
            CASE WHEN e3.formatli_tel_no IS NOT NULL AND e2.formatli_tel_no IS NOT NULL THEN e2.formatli_tel_no
                 WHEN e3.formatli_tel_no IS NOT NULL AND e1.formatli_tel_no IS NOT NULL THEN e1.formatli_tel_no
                 WHEN e3.formatli_tel_no IS NULL AND e2.formatli_tel_no IS NOT NULL AND e1.formatli_tel_no IS NOT NULL THEN e1.formatli_tel_no
                 WHEN e3.formatli_tel_no IS NULL AND e2.formatli_tel_no IS NOT NULL AND e1.formatli_tel_no IS NULL THEN NULL
                 WHEN e3.formatli_tel_no IS NULL AND e2.formatli_tel_no IS NULL THEN NULL
                      END formatli_tel_no_2,
            f.mail,
            wa.web_adresi,
            g.donem_calisan_sayisi,
            g.yil AS ciro_yili,
            g.ay ciro_ayi,
            g.ciro AS ciro_tutari,
            g.ciro_para_kodu,
            h.grup,
            h.firma_grup_kodu,
            NVL(j.risk_kod, 1) AS risk_kod,
            g3.min_actarih AS min_actarih_grup3,
            g4.min_actarih AS min_actarih_grup4,
            g5.min_actarih AS min_actarih_grup5,
            --K.TIP AS grup_tipi,
            ln.tllimit AS tllimit_nakit,
            lgn.tllimit AS tllimit_gayrinakit,
            lg.tllimit AS tllimit_nakit_genel,
            --L.TIP,
            mgl.grup AS grup_limiti_kodu ,
            mgl.tutar AS grup_limit,
            mgr.grup AS grup_riski_kodu,
            mgr.tutar AS grup_risk,
            --M.TIP   tip_grup,
            CASE WHEN n.genel_revize_vadesi >= TO_DATE ('01/01/1980', 'DD/MM/YYYY') THEN n.genel_revize_vadesi ELSE n2.genel_revize_vadesi END genel_revize_vadesi,
            DECODE (
                    o.finansman_konusu_kodu,
                                             'JAA', 'JAF',
                                             o.finansman_konusu_kodu
                   ) AS finansman_konusu_kodu,
            p.son_revize_tarihi,
            r.web_sitesi,
            s.min_hsp_acls_trh AS uye_clsm_trh,
            --Sadece TRBIC için olan tablo join'leri
            gk.isim1 AS isim,
            gk.isim2 AS ikinci_isim,
            gk.soyisim AS soyad,
            CASE WHEN TO_DATE (gk.dogum_tarihi, 'DD/MM/YYYY') = TO_DATE ('01/01/1900', 'DD/MM/YYYY') THEN NULL ELSE TO_DATE (gk.dogum_tarihi, 'DD/MM/YYYY') END AS dogum_tarihi,
            k1.kimlik_kod AS kimlik_kod_1,
            s1.kodaciklama AS kimlik_kod_acklm_1,
            k1.seri_no AS kimlik_kod_1_seri_no,
            k2.kimlik_kod AS kimlik_kod_2,
            s2.kodaciklama AS kimlik_kod_acklm_2,
            k2.seri_no AS kimlik_kod_2_seri_no,
            k3.kimlik_kod AS kimlik_kod_3,
            s3.kodaciklama AS kimlik_kod_acklm_3,
            k3.seri_no AS kimlik_kod_3_seri_no,
            k4.kimlik_kod AS kimlik_kod_4,
            s4.kodaciklama AS kimlik_kod_acklm_4,
            k4.seri_no AS kimlik_kod_4_seri_no,
            gk.uyruk,
            DECODE (gk.uyruk, '1', 792, NULL) AS uyruk_kodu,
            m.kod AS meslek_ing_kod,
            m.ad AS meslek_ing_kod_acklm,
            kmp.meslek_kkb_kod,
            kmp.meslek_kkb_kod_acklm,
            gk.egitim AS egitim_ing_kod,
            e.kodaciklama AS egitim_ing_kod_acklm,
            kep.egitim_kkb_kod,
            kep.egitim_kkb_kod_acklm,
            --CASE WHEN a.firma_turu = 2 AND a.musteri_tip = 16 THEN 98 ELSE mt.sirket_tip END sirket_tip,
            mt.sirket_tip AS sirket_tip_ing,
            --CASE WHEN a.firma_turu = 2 AND a.musteri_tip = 16 THEN 'DÝÐER' ELSE mtsp.kodaciklama END sirket_tip_acklm
            mtsp.kodaciklama AS sirket_tip_acklm_ing,
            a.firma_turu_kkb AS sirket_tip_kkb,
            kft_prm.firma_turu_aciklama AS sirket_tip_acklm_kkb,
            mt.firma_merkez_il,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbfc_ana_mus_set a
            LEFT JOIN trfm.tmp_trbfc_ev_adrs b
                                 ON  a.musteri_no =b.musteri_no
                                AND a.kesit_tarihi =b.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_isyr_adrs c
                                 ON    a.musteri_no =c.musteri_no
                                 and a.kesit_tarihi =c.kesit_tarihi
   --         LEFT JOIN tmp_trbfc_tlfn_kod d
   --                              ON    a.musteri_no =d.musteri_no
   --                              and a.kesit_tarihi =d.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_tlfn_01 e1
                                 ON    a.musteri_no =e1.musteri_no
                                 and a.kesit_tarihi =e1.kesit_tarihi
                                 and e1.tip ='Ev Tel'
            LEFT JOIN trfm.tmp_trbfc_tlfn_01 e2
                                 ON    a.musteri_no =e2.musteri_no
                                 and a.kesit_tarihi =e2.kesit_tarihi
                                 and e2.tip ='Ýþyeri Tel'
            LEFT JOIN trfm.tmp_trbfc_tlfn_01 e3
                                 ON    a.musteri_no =e3.musteri_no
                                 and a.kesit_tarihi =e3.kesit_tarihi
                                 and e3.tip ='Cep Tel'
            LEFT JOIN trfm.tmp_trbfc_mail f
                                 ON   a.musteri_no =f.musteri_no
                                 and a.kesit_tarihi =f.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_01 g
                                 ON  a.musteri_no =g.musteri_no
                                 and a.kesit_tarihi =g.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_firm_grp_kod h
                                 ON    a.musteri_no =h.musteri_no
                                 and a.kesit_tarihi =h.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_risk_grp_kod j
                                 ON    a.musteri_no =j.musteri_no
                                 and a.kesit_tarihi =j.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_grp_alnm g3
                                 ON    a.musteri_no =g3.musteri_no
                                 and a.kesit_tarihi =g3.kst_trh
                                 and g3.tip = 'GRUP3_ALINMA_TARIHI'
            LEFT JOIN trfm.tmp_trbfc_grp_alnm g4
                                 ON    a.musteri_no =g4.musteri_no
                                 and a.kesit_tarihi =g4.kst_trh
                                 and g4.tip = 'GRUP4_ALINMA_TARIHI'
            LEFT JOIN trfm.tmp_trbfc_grp_alnm g5
                                 ON    a.musteri_no =g5.musteri_no
                                 and a.kesit_tarihi =g5.kst_trh
                                 and g5.tip = 'GRUP5_ALINMA_TARIHI'
            LEFT JOIN trfm.tmp_trbfc_lmt ln
                                 ON    a.musteri_no =ln.musteri_no
                                 and a.kesit_tarihi =ln.kesit_tarihi
                                 and ln.tip = 'Nakit Limit'
            LEFT JOIN trfm.tmp_trbfc_lmt lgn
                                 ON    a.musteri_no =lgn.musteri_no
                                 and a.kesit_tarihi =lgn.kesit_tarihi
                                 and lgn.tip = 'GayriNakit Limit'
            LEFT JOIN trfm.tmp_trbfc_lmt lg
                                 ON    a.musteri_no =lg.musteri_no
                                 and a.kesit_tarihi =lg.kesit_tarihi
                                 and lg.tip = 'Firma Genel Limiti'
            LEFT JOIN trfm.tmp_trbfc_grp_lmt_rsk mgl
                                 ON    a.musteri_no =mgl.musteri_no
                                 and a.kesit_tarihi =mgl.kesit_tarihi
                                 and mgl.tip = 'Grup Limiti'
            LEFT JOIN trfm.tmp_trbfc_grp_lmt_rsk mgr
                                 ON    a.musteri_no =mgr.musteri_no
                                 and a.kesit_tarihi =mgr.kesit_tarihi
                                 and mgr.tip = 'Grup Riski'
            LEFT JOIN trfm.tmp_trbfc_gnl_rvz_vade_01 n
                                 ON    a.musteri_no =n.musteri
                                 and a.kesit_tarihi =n.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_gnl_rvz_vade_02 n2
                                 ON    a.musteri_no =n2.musteri
                                 and a.kesit_tarihi =n2.kst_trh
            LEFT JOIN trfm.tmp_trbfc_fnsmn_kod o
                                 ON    a.musteri_no =o.musteri_no
                                 and a.kesit_tarihi =o.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_son_rvz_trh p
                                 ON    a.musteri_no =p.musteri_no
                                 and a.kesit_tarihi =p.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_web_stsi r
                                 ON    a.musteri_no =r.musteri_no
                                 and a.kesit_tarihi =r.kesit_tarihi
            LEFT JOIN trfm.tmp_trbfc_mn_hsp_acls_trh s
                                 ON a.musteri_no =s.musteri_no
                                 and a.kesit_tarihi =s.kst_trh
   --Sadece TRBIC için olan tablo join'leri
            LEFT JOIN extr.fs_musteri_gercek gk
                            ON     1 = 1
                               AND a.musteri_no = gk.musteri_no
            LEFT JOIN (
                               SELECT musteri_no, kimlik_kod, seri_no,
                                      ROW_NUMBER () OVER (PARTITION BY musteri_no ORDER BY DECODE (kimlik_kod, 'NC', 1,
                                                                                                               'SB', 2,
                                                                                                               'PS', 3,
                                                                                                               'KK', 4,
                                                                                                               'IT', 5,
                                                                                                               'AK', 6,
                                                                                                               'EC', 7,
                                                                                                               'DG', 8,
                                                                                                               9
                                                                                                  )
                                                         ) sira_no
                                 FROM extr.fs_musteri_kimlik
                                WHERE 1 = 1
                            ) k1
                            ON     1 = 1
                               AND a.musteri_no = k1.musteri_no
                               AND k1.sira_no = 1
            LEFT JOIN extr.fs_secimparam s1
                            ON     1 = 1
                               AND k1.kimlik_kod = s1.kod
                               AND s1.secimtip = 2054
            LEFT JOIN (
                               SELECT musteri_no, kimlik_kod, seri_no,
                                      ROW_NUMBER () OVER (PARTITION BY musteri_no ORDER BY DECODE (kimlik_kod, 'NC', 1,
                                                                                                               'SB', 2,
                                                                                                               'PS', 3,
                                                                                                               'KK', 4,
                                                                                                               'IT', 5,
                                                                                                               'AK', 6,
                                                                                                               'EC', 7,
                                                                                                               'DG', 8,
                                                                                                               9
                                                                                                  )
                                                         ) sira_no
                                 FROM extr.fs_musteri_kimlik
                                WHERE 1 = 1
                            ) k2
                            ON     1 = 1
                               AND a.musteri_no = k2.musteri_no
                               AND k2.sira_no = 2
            LEFT JOIN extr.fs_secimparam s2
                            ON     1 = 1
                               AND k2.kimlik_kod = s2.kod
                               AND s2.secimtip = 2054
            LEFT JOIN (
                               SELECT musteri_no, kimlik_kod, seri_no,
                                      ROW_NUMBER () OVER (PARTITION BY musteri_no ORDER BY DECODE (kimlik_kod, 'NC', 1,
                                                                                                               'SB', 2,
                                                                                                               'PS', 3,
                                                                                                               'KK', 4,
                                                                                                               'IT', 5,
                                                                                                               'AK', 6,
                                                                                                               'EC', 7,
                                                                                                               'DG', 8,
                                                                                                               9
                                                                                                  )
                                                         ) sira_no
                                 FROM extr.fs_musteri_kimlik
                                WHERE 1 = 1
                            ) k3
                            ON     1 = 1
                               AND a.musteri_no = k3.musteri_no
                               AND k3.sira_no = 3
            LEFT JOIN extr.fs_secimparam s3
                            ON     1 = 1
                               AND k3.kimlik_kod = s3.kod
                               AND s3.secimtip = 2054
            LEFT JOIN (
                               SELECT musteri_no, kimlik_kod, seri_no,
                                      ROW_NUMBER () OVER (PARTITION BY musteri_no ORDER BY DECODE (kimlik_kod, 'NC', 1,
                                                                                                               'SB', 2,
                                                                                                               'PS', 3,
                                                                                                               'KK', 4,
                                                                                                               'IT', 5,
                                                                                                               'AK', 6,
                                                                                                               'EC', 7,
                                                                                                               'DG', 8,
                                                                                                               9
                                                                                                  )
                                                         ) sira_no
                                 FROM extr.fs_musteri_kimlik
                                WHERE 1 = 1
                            ) k4
                            ON     1 = 1
                               AND a.musteri_no = k4.musteri_no
                               AND k4.sira_no = 4
            LEFT JOIN extr.fs_secimparam s4
                            ON     1 = 1
                               AND k4.kimlik_kod = s4.kod
                               AND s4.secimtip = 2054
            LEFT JOIN extr.fs_musteri_meslek m
                            ON     1 = 1
                               AND gk.is_meslek = m.kod
            LEFT JOIN trfm.tmp_kkb_mslk_prmtr kmp
                            ON     1 = 1
                               AND m.ad = kmp.meslek_ing_kod_acklm
            LEFT JOIN extr.fs_secimparam e
                            ON     1 = 1
                               AND TO_CHAR (gk.egitim) = e.kod
                               AND e.secimtip = 219
            LEFT JOIN trfm.tmp_kkb_egtm_prmtr kep
                            ON     1 = 1
                               AND e.kodaciklama = kep.egitim_ing_kod_acklm
            LEFT JOIN extr.fs_musteri_tuzel mt
                            ON     1 = 1
                               AND a.musteri_no = mt.musteri_no
            LEFT JOIN extr.fs_secimparam mtsp
                            ON     1 = 1
                               AND TO_CHAR (mt.sirket_tip) = mtsp.kod
                               AND mtsp.secimtip = 2063
            LEFT JOIN trfm.tmp_trbfc_web_adrs wa
                            ON     1 = 1
                               AND a.kesit_tarihi = wa.kst_trh
                               AND a.musteri_no = wa.musteri_no
            LEFT JOIN trfm.tmp_trbfc_tlfn ft_1 --trbfc_tmp_formatli_tel_1 ft_1
                            ON     1 = 1
                               AND a.kesit_tarihi = ft_1.kesit_tarihi
                               AND a.musteri_no = ft_1.musteri_no
                               AND ft_1.tel_tip_sira = 1
            LEFT JOIN trfm.tmp_trbfc_tlfn ft_2 --trbfc_tmp_formatli_tel_2 ft_2
                            ON     1 = 1
                               AND a.kesit_tarihi = ft_2.kesit_tarihi
                               AND a.musteri_no = ft_2.musteri_no
                               AND ft_2.tel_tip_sira = 2
            LEFT JOIN trfm.tmp_kkb_firm_tur kft_prm
                            ON     1 = 1
                               AND a.firma_turu_kkb = kft_prm.firma_turu_kod
      WHERE 1 = 1
        --AND a.gercek_tuzel = 'T'
            ;
--   GRANT SELECT ON trbfc_trbic_fct TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
   --SELECT * FROM tmp_trbfc_ana_mus_set a;
   --SELECT * FROM trbfc_trbic_fct;
      COMMIT;

      v_line_no:=610;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbfc_trbic;


   PROCEDURE sp_trbac (p_tarih IN DATE DEFAULT TRUNC(sysdate-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBAC';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 700;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_ITH_DIM_RSK_THP_NO',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=705;

      INSERT               /*+ APPEND */ INTO trfm.tmp_ith_dim_rsk_thp_no
     SELECT DISTINCT v_tarih kst_trh, k.dosya_tip, k.sube, k.reftur, k.nitelik, k.refsirano, k.musteri, k.durum, k.acilistarih, k.acilistutar, --koda eklendi (Kerem)
                     m.brisk_ilk7 AS risk_thp_no, m.program, m.teyitkodu, m.aval, m.para, m.iliski, m.teminatkodu, m.vadetur, m.masraf_aval,--koda eklendi (Kerem)
                     SYSDATE AS etl_trh,
                     v_sp_name AS etl_job
       FROM extr.fs_ithmuhparam m,
            (
               SELECT 'Risk giriþi yapýlmýþ açýk dosyalar' dosya_tip, --koda eklendi (Kerem)
                      k.sube, k.reftur, k.nitelik, k.refsirano, k.musteri, k.durum, k.acilistarih, k.acilistutar, k.teminatkod, k.para, k.aval, k.teyit,
                      s.ilkodu, mm.iliski
                 FROM extr.fs_ithmaster k,
                      extr.fs_sube s,
                      extr.fs_musteri_master mm
                WHERE 1 = 1
                  --AND LAST_DAY (TO_DATE (k.acilistarih, 'DD/MM/YYYY')) = v_tarih --koddan çýkarýldý (Kerem)
                  AND (
                           k.reftur IN ('LC', 'AL')
                        OR (k.reftur = 'AC' AND k.aval = 1 AND k.policegiristutar > 0)
                      )
                  AND k.durum NOT IN (7, 9, 11, 10)
                  AND k.musteri = mm.musteri_no
                  AND k.sube = s.sube
                  AND k.refsirano > 0 --koda eklendi (Kerem)
                  AND NOT (k.sube = 144 AND k.reftur = 'LC' AND k.refsirano = 500000) --koda eklendi (Kerem) dummy kayýt koddan çýkarýldý
             UNION ALL
               SELECT 'Kapalý dosyalar' dosya_tip, --koda eklendi (Kerem)
                      k.sube, k.reftur, k.nitelik, k.refsirano, k.musteri, k.durum, k.acilistarih, k.acilistutar, k.teminatkod, k.para, k.aval, k.teyit,
                      s.ilkodu, mm.iliski
                 FROM extr.fs_ithmaster k,
                      extr.fs_sube s,
                      extr.fs_musteri_master mm,
                      extr.fs_ithhrkt h
                WHERE 1 = 1
                  --AND LAST_DAY (TO_DATE (k.acilistarih, 'DD/MM/YYYY')) = v_tarih --koddan çýkarýldý (Kerem)
                  AND (
                           k.reftur IN ('LC', 'AL')
                        OR (k.reftur = 'AC' AND k.aval = 1 AND k.policegiristutar > 0)
                      )
                  AND k.durum = 7
                  AND k.musteri = mm.musteri_no
                  AND k.sube = s.sube
                  AND k.sube = h.sube
                  AND k.reftur = h.reftur
                  AND k.refsirano = h.refsirano
                  AND h.kayittip = 8
                  AND h.durum <> 9
                  --AND h.islemtarihi >= onceki_rapor_tarih --v_gecis_tarihi--sonra ayrý dosya gönderilecek --koddan çýkarýldý (Kerem)
                  AND TO_DATE (h.islemtarihi, 'DD/MM/YYYY') >= TO_DATE ('21/07/2003', 'DD/MM/YYYY') --v_gecis_tarihi
                  AND TO_DATE (h.islemtarihi, 'DD/MM/YYYY') <= v_tarih --koda eklendi (Kerem)
             UNION ALL
               SELECT 'Devredilmiþ dosyalar' dosya_tip, --koda eklendi (Kerem)
                      k.sube, k.reftur, k.nitelik, k.refsirano, k.musteri, k.durum, k.acilistarih, k.acilistutar, k.teminatkod, k.para, k.aval, k.teyit,
                      s.ilkodu, mm.iliski
                 FROM extr.fs_ithmaster k,
                      extr.fs_sube s,
                      extr.fs_musteri_master mm,
                      extr.fs_eskiyenireferans e
                WHERE 1 = 1
                  --AND LAST_DAY (TO_DATE (k.acilistarih, 'DD/MM/YYYY')) = v_tarih --koddan çýkarýldý (Kerem)
                  AND (
                           k.reftur IN ('LC', 'AL')
                        OR (k.reftur = 'AC' AND k.aval = 1 AND k.policegiristutar > 0)
                      )
                  AND k.durum = 10
                  AND k.musteri = mm.musteri_no
                  AND k.sube = s.sube
                  AND k.sube = e.eski_sube
                  AND k.reftur = e.eski_reftur
                  AND k.refsirano = e.eski_refsirano
                  --AND LAST_DAY (TO_DATE (e.updtarih, 'DD/MM/YYYY')) = v_tarih --v_gecis_tarihi--sonra ayrý dosya gönderilecek --koddan çýkarýldý (Kerem)
                  AND TO_DATE (e.updtarih, 'DD/MM/YYYY') >= TO_DATE ('21/07/2003', 'DD/MM/YYYY') --koda eklendi (Kerem) bu kriter olmadan kod çalýþýnca sorgu hata alýyor ('25/05/2001' sonrasý)
                  AND TO_DATE (e.updtarih, 'DD/MM/YYYY') <= v_tarih --koda eklendi (Kerem)
            ) k
      WHERE 1 = 1
        AND m.program = DECODE (k.reftur, 'AC', 'ITH105', 'ITH102')
        AND m.reftur = k.reftur
        AND m.refnit = k.nitelik
        AND (m.teyitkodu = k.teyit OR m.teyitkodu = 'T')
        AND (m.aval = k.aval OR m.aval = 'T')
        AND m.para = CASE WHEN k.para = 0 THEN 0 ELSE 1 END
        AND (m.iliski = k.iliski OR m.iliski = 99)
        AND (m.teminatkodu = k.teminatkod OR m.teminatkodu = 99)
        AND (m.vadetur = 99)
        AND (m.masraf_aval = 99)
        AND TO_DATE (k.acilistarih, 'DD/MM/YYYY') <= v_tarih;

      COMMIT;

      v_line_no:=710;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKP_TRH_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=715;
      --3.Gruba Alýnma Tarihi

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkp_trh_01
        SELECT v_tarih AS kst_trh,
               ilk7 AS musteri_no,
               MIN(TRUNC(actarih)) AS min_actarih,
               ana,
               'GRUP3_ALINMA_TARIHI' AS tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_hplandet_sg
         WHERE 1 = 1
               AND sinif = 'C'
               AND durum = 0
               AND ana = 170
               AND TRUNC(actarih)<= v_tarih
      GROUP BY ilk7, ana
   UNION ALL
        SELECT v_tarih AS kst_trh,
               ilk7 AS musteri_no,
               MIN(TRUNC(actarih)) AS min_actarih,
               ana,
               'GRUP3_ALINMA_TARIHI' AS tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_eskiplan_sg
         WHERE 1 = 1
               AND sinif = 'C'
               AND durum = 0
               AND ana = 170
               AND TRUNC(actarih)<= v_tarih
      GROUP BY ilk7, ana
   UNION ALL
        SELECT v_tarih AS kst_trh,
               ilk7 AS musteri_no,
               MIN(TRUNC(actarih)) AS min_actarih,
               ana,
               'GRUP4_ALINMA_TARIHI' AS tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_hplandet_sg
         WHERE 1 = 1
               AND sinif = 'C'
               AND durum = 0
               AND ana = 172
               AND TRUNC(actarih)<= v_tarih
      GROUP BY ilk7, ana
   UNION ALL
        SELECT v_tarih AS kst_trh,
               ilk7 AS musteri_no,
               MIN(TRUNC(actarih)) AS min_actarih,
               ana,
               'GRUP4_ALINMA_TARIHI' AS tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_eskiplan_sg
         WHERE 1 = 1
           AND sinif = 'C'
           AND durum = 0
           AND ana = 172
           AND TRUNC(actarih)<= v_tarih
      GROUP BY ilk7, ana
   UNION ALL
        SELECT v_tarih AS kst_trh,
               ilk7 AS musteri_no,
               MIN(TRUNC(actarih)) AS min_actarih,
               ana,
               'GRUP5_ALINMA_TARIHI' AS tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_hplandet_sg
         WHERE 1 = 1
           AND sinif = 'C'
           AND durum = 0
           AND ana = 176
           AND TRUNC(actarih)<= v_tarih
      GROUP BY ilk7, ana
   UNION ALL
        SELECT v_tarih AS kst_trh,
               ilk7 AS musteri_no,
               MIN(TRUNC(actarih)) AS MIN_ACTARIH,
               ana,
               'GRUP5_ALINMA_TARIHI' AS tip,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM extr.fs_eskiplan_sg
         WHERE 1 = 1
           AND sinif = 'C'
           AND durum = 0
           AND ana = 176
           AND TRUNC(actarih)<= v_tarih
      GROUP BY ilk7, ana;

      COMMIT;

      v_line_no:=720;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKP_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=725;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkp_trh
        SELECT kst_trh, musteri_no, ana, tip,
               MIN (min_actarih) AS min_actarih,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM trfm.tmp_trbac_tkp_trh_01 f
         WHERE 1 = 1
      GROUP BY kst_trh, musteri_no, ana, tip;

      COMMIT;

      v_line_no:=730;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKP_TUTAR_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=735;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkp_tutar_01
     SELECT v_tarih AS kst_trh,
            x.min_actarih, x.musteri_no, x.tip, x.ana,
            SUM (g.borc) AS takip_ttr,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbac_tkp_trh x,
            extr.fs_gunluk_hplandet_sg g
      WHERE 1 = 1
        AND x.min_actarih = g.tarih (+)
        AND x.musteri_no = g.ilk7 (+)
        AND x.ana = g.ana (+)
        AND 'C' = g.sinif (+)
        AND 0 = g.durum (+)
        AND 0 <> g.borc (+)
   GROUP BY x.min_actarih, x.musteri_no, x.tip, x.ana;

      COMMIT;

      v_line_no:=740;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKP_TUTAR_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=745;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkp_tutar_02
      SELECT f.kst_trh, f.min_actarih, f.musteri_no, f.tip, f.ana,
            NVL (f.takip_ttr, p.tkp_acls_tutar_170) AS takip_ttr,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbac_tkp_tutar_01 f
            LEFT JOIN dm_infoman.portfoy_rapor p ON  1 = 1
                                                 AND p.kst_trh = v_tarih
                                                 AND p.kst_trh = f.kst_trh
                                                 AND p.mus_no = f.musteri_no
      WHERE 1 = 1
            AND f.ana = 170
   UNION ALL
     SELECT f.kst_trh, f.min_actarih, f.musteri_no, f.tip, f.ana, f.takip_ttr,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbac_tkp_tutar_01 f
      WHERE 1 = 1
        AND f.ana <> 170;

      COMMIT;

      v_line_no:=750;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKP_TUTAR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=755;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkp_tutar
        SELECT a.kst_trh, a.min_actarih, a.musteri_no, a.tip, a.ana,
               SUM (CASE WHEN a.takip_ttr <> 0 THEN a.takip_ttr WHEN mab.takip_bakiye <> 0 THEN mab.takip_bakiye END) AS takip_ttr,
               SYSDATE AS etl_trh,
               v_sp_name AS etl_job
          FROM trfm.tmp_trbac_tkp_tutar_02 a
               LEFT OUTER JOIN trfm.tmp_trbfc_mn_acls_bky mab
                               ON     1 = 1
                                  AND a.kst_trh = mab.kst_trh
                                  AND a.ana = mab.ana
                                  AND a.musteri_no = mab.musteri_no
         WHERE 1 = 1
           --AND (CASE WHEN a.takip_ttr <> 0 THEN a.takip_ttr WHEN mab.takip_bakiye <> 0 THEN mab.takip_bakiye END) <> 0
      GROUP BY a.kst_trh, a.min_actarih, a.musteri_no, a.tip, a.ana;

      COMMIT;

      v_line_no:=760;




              /*
--PROCEDURE get_kararname_kod(arg_sube number ,arg_musteri number,arg_kkod  out number ,arg_riskgrup out number ) is     grup_gecis_tarih date;        ln_riskkod number;
DROP TABLE tmp_trbac_krrnme_kod_01;    --tmp_trbac_krrnme_kod_01
CREATE TABLE tmp_trbac_krrnme_kod_01 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT kst_trh, sube, musteri_no, ana,
         NVL (MAX (kod), 0) AS risk_kod
    FROM (
          SELECT v_tarih AS kst_trh,
                 sube, ilk7 AS musteri_no, ana,
                 CASE ana WHEN 170 THEN 3
                          WHEN 172 THEN 4
                          WHEN 176 THEN 5
                 END AS kod
            FROM extr.fs_hplandet_sg
           WHERE 1 = 1
                 AND sinif = 'C'
                 AND durum = 0
                 AND ana IN (170,172,176)
                 AND TRUNC(actarih)<= v_tarih
        GROUP BY sube, ilk7, ana
     UNION ALL
          SELECT v_tarih kst_trh,
                 sube, ilk7 musteri_no, ana,
                 CASE ana WHEN 170 THEN 3
                          WHEN 172 THEN 4
                          WHEN 176 THEN 5
                 END AS kod
            FROM extr.fs_eskiplan_sg
           WHERE 1 = 1
                 AND sinif = 'C'
                 AND durum = 0
                 AND ana IN (170,172,176)
                 AND TRUNC(actarih)<= v_tarih
        GROUP BY sube, ilk7, ana
         )
   WHERE 1 = 1
GROUP BY kst_trh, sube, musteri_no, ana;
GRANT SELECT ON tmp_trbac_krrnme_kod_01 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
--SELECT * FROM tmp_trbac_krrnme_kod_01;

DROP TABLE tmp_trbac_krrnme_kod;    --tmp_trbac_krrnme_kod
CREATE TABLE tmp_trbac_krrnme_kod PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT f.kst_trh, f.sube, f.musteri_no, f.ana, f.risk_kod,
         CASE WHEN f.risk_kod <> 0 THEN f.risk_kod
                   ELSE 1
                        END risk_grup,
         CASE WHEN f.risk_kod <> 0 THEN 1
                   ELSE 2
                        END kararname_kod --kkod
    FROM tmp_trbac_krrnme_kod_01 f
   WHERE 1 = 1;
GRANT SELECT ON tmp_trbac_krrnme_kod TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
--SELECT * FROM tmp_trbac_krrnme_kod;
*/

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_KKB_TKP_MUS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=765;

      INSERT               /*+ APPEND */ INTO trfm.tmp_kkb_tkp_mus
     SELECT kst_trh, musteri_no,
            MAX (tkp_thp_no) AS max_tkp_thp_no,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih AS kst_trh, ilk7 AS  musteri_no,
                      TO_NUMBER (LPAD (ana, 3, '0') || LPAD (alt, 2, '0') || tali1 || tali2) AS tkp_thp_no
                 FROM extr.fs_hplandet_sg
                WHERE 1 = 1
                  AND sinif = 'C'
                  AND durum = 0
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
                  AND TO_NUMBER (LPAD (ana, 3, '0')) IN (170, 172, 176)
             UNION ALL
               SELECT v_tarih AS kst_trh, ilk7 AS musteri_no,
                      TO_NUMBER (LPAD (ana, 3, '0') || LPAD (alt, 2, '0') || tali1 || tali2) tkp_thp_no
                 FROM extr.fs_eskiplan_sg
                WHERE 1 = 1
                  AND sinif = 'C'
                  AND durum = 0
                  AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
                  AND TO_NUMBER (LPAD (ana, 3, '0')) IN (170, 172, 176)
            )
      WHERE 1 = 1
   GROUP BY kst_trh, musteri_no;

      COMMIT;
      v_line_no:=770;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_SON_KLNDRM_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=775;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_son_klndrm_trh
     SELECT               /*+ parallel(a 8) */
            v_tarih AS kst_trh,
            a.sube, a.sinif, a.ilk7, a.hestur, a.ekno,
            MAX (a.fistarih) AS son_kullndrm_trh,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_faizhar a
      WHERE 1 = 1
            AND a.borctoplam>0
            and a.hestur = 'KT'
            AND a.sinif = 'C'
            AND a.fistarih <= v_tarih
   GROUP BY a.sube, a.sinif, a.ilk7, a.hestur, a.ekno;

      COMMIT;
      v_line_no:=780;



--
--DROP TABLE trbac_fct_tmp_11;
--CREATE TABLE trbac_fct_tmp_11 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
--  SELECT v_tarih AS kst_trh,
--         h.sube, h.reftur, h.refsirano,
--         MAX (h.vadetarihi) AS ld_vadetarihi
--    FROM extr.fs_ithhrkt
--   WHERE 1 = 1
--     AND h.durum IN (0,1) -- Açýk vadeler + ödemesi yapýlmýþ olanlar
--     AND h.kayittip IN (1, 7)
--     AND h.islemtarihi <= v_tarih
--GROUP BY h.sube, h.reftur, h.refsirano;
--GRANT SELECT ON trbac_fct_tmp_11 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
----SELECT * FROM trbac_fct_tmp_11;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TMEK_HSP_KPNS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=785;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tmek_hsp_kpns_trh
     SELECT v_tarih AS kst_trh,
            m.refsube, m.reftur, m.refsirano,
            MAX (h.fistarih) AS mx_fistarih,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_temmekhrkt h,
            extr.fs_temmekmas m
      WHERE 1 = 1
        AND h.refsube = m.refsube
        AND h.reftur = m.reftur
        AND h.refsirano = m.refsirano
        AND m.durum IN (3, 4)
        AND h.hrkttur IN (4, 6)
        AND h.fistarih <= v_tarih
   GROUP BY m.refsube, m.reftur, m.refsirano;

      COMMIT;
      v_line_no:=790;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_HSP_KPNS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=795;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_hsp_kpns_trh
     SELECT v_tarih AS kst_trh,
            t.sube, h.sinif, t.kmhilk7, h.hestur, t.krdekno,
            MAX (TO_DATE (h.updtarih, 'DD/MM/YYYY')) AS ld_date,
            DECODE (
                    CASE WHEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') > TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                              THEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') ELSE TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                                   END,
                                        TO_DATE ('31/12/1899', 'DD/MM/YYYY'), NULL,
                                        TO_DATE ('01/01/1900', 'DD/MM/YYYY'), NULL,
                                        CASE WHEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') > TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                                                  THEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') ELSE TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                                                       END
                   ) AS kmh_kapanis_trh
       FROM ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t,
            extr.fs_sube s,
            extr.fs_gunluk_hplandet_sg h,
            extr.fs_kmhmas_detay d
      WHERE 1 = 1
            AND t.sube = s.sube
            AND t.sube = h.sube
            AND t.kmhilk7 = h.ilk7
            AND t.sube=d.sube
            AND t.kmhilk7=d.kmhilk7
            AND t.tip=d.tip
            AND h.hestur = 'KR'
            AND d.krekno = h.ekno
            AND t.krdekno!=0
            AND h.sinif = 'C'
            AND h.durum = 0
            AND t.tip in(21,22,25,26,27,28)
            AND h.tarih = v_tarih
   GROUP BY t.sube, h.sinif, t.kmhilk7, h.hestur, t.krdekno,
            DECODE (
                    CASE WHEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') > TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                              THEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') ELSE TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                                   END,
                                        TO_DATE ('31/12/1899', 'DD/MM/YYYY'), NULL,
                                        TO_DATE ('01/01/1900', 'DD/MM/YYYY'), NULL,
                                        CASE WHEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') > TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                                                  THEN TO_DATE (t.idaritakiptar, 'DD/MM/YYYY') ELSE TO_DATE (t.krdkapamatar, 'DD/MM/YYYY')
                                                       END
                   );

      COMMIT;
      v_line_no:=800;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_ITH_HSP_KPNS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=805;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_ith_hsp_kpns_trh
     SELECT v_tarih AS kst_trh,
            h.sube, h.reftur, h.refsirano,
            TO_DATE (h.fistarih, 'DD/MM/YYYY') AS rkhskt,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_ithhrkt h,
            extr.fs_ithmaster m
      WHERE 1 = 1
        AND h.sube = m.sube
        AND h.reftur = m.reftur
        AND h.refsirano = m.refsirano
        AND h.durum <> 9
        AND h.kayittip = 8
        AND m.durum = 7
        AND h.fistarih <= v_tarih;

      COMMIT;
      v_line_no:=810;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_ITH_DVR_HSP_KPNS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=815;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_ith_dvr_hsp_kpns_trh
     SELECT v_tarih AS kst_trh,
            d.eski_sube AS refsube,
            d.eski_reftur AS reftur,
            d.eski_refsirano AS refsirano,
            MAX (TRUNC(d.updtarih)) AS devir_max_updtarih,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_eskiyenireferans d,
            extr.fs_ithmaster m
      WHERE 1 = 1
        AND d.eski_sube = m.sube
        AND d.eski_reftur = m.reftur
        AND d.eski_refsirano = TO_CHAR (m.refsirano)
        AND TO_DATE (d.updtarih, 'DD/MM/YYYY') <= v_tarih
        AND m.durum = 10 --devir
        --AND d.eski_sube = 104 AND d.eski_reftur = 'LC' AND d.eski_refsirano = 10015
   GROUP BY d.eski_sube, d.eski_reftur, d.eski_refsirano;

      COMMIT;
      v_line_no:=820;

              /*
DROP TABLE trbac_fct_tmp_15;
CREATE TABLE trbac_fct_tmp_15 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT kst_trh,
         ilk7 AS musteri_no,
         NVL (MAX (kod), 0) AS ln_riskkod
    FROM (
           SELECT DISTINCT
                  h.tarih AS kst_trh,
                  ilk7,
                  CASE ana WHEN 170 THEN 3
                           WHEN 172 THEN 4
                           WHEN 176 THEN 5
                  END AS kod
             FROM extr.fs_gunluk_hplandet_sg h
            WHERE 1 = 1
                  AND tarih = v_tarih
                  AND ana IN (170, 172, 176)
                  AND durum = 0
         )
GROUP BY kst_trh, ilk7;
GRANT SELECT ON trbac_fct_tmp_15 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
--SELECT * FROM trbac_fct_tmp_15;
*/




      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_DVR_BLG',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=825;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_dvr_blg
   SELECT kst_trh, yeni_sube, yeni_reftur, yeni_refsirano, eski_sube, eski_reftur, eski_refsirano, updtarih, aylik_ilk_bildirim_f,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM (
           SELECT v_tarih AS kst_trh,
                  yeni_sube, yeni_reftur, yeni_refsirano, eski_sube, eski_reftur, eski_refsirano,
                  TO_DATE (updtarih, 'DD/MM/YYYY') AS updtarih,
                  CASE WHEN TO_DATE (updtarih, 'DD/MM/YYYY') = v_tarih THEN 'Aylýk'
                            ELSE 'Ýlk'
                                 END aylik_ilk_bildirim_f,
                  ROW_NUMBER () OVER (PARTITION BY yeni_sube, yeni_reftur, yeni_refsirano
                                      ORDER BY updtarih DESC, updzaman DESC, eski_sube DESC, eski_reftur DESC, eski_refsirano DESC) sira
             FROM extr.fs_eskiyenireferans
            WHERE 1 = 1
              --AND TO_DATE (updtarih, 'DD/MM/YYYY')) = v_tarih
              AND LAST_DAY (TO_DATE (updtarih, 'DD/MM/YYYY')) = v_tarih --aylýk bildirim
              --AND TO_DATE (updtarih, 'DD/MM/YYYY') BETWEEN  ADD_MONTHS (v_tarih, -36)+1 AND v_tarih  --ilk bildirim
              AND yeni_sube NOT IN (0)
          )
    WHERE sira = 1;
       COMMIT;
      v_line_no:=830;

              /*DROP TABLE trbac_nkrd_koti;
CREATE TABLE trbac_nkrd_koti nologging AS
  SELECT v_tarih kst_trh, 'NKRD' tip, a.sube, a.reftur, a.refsirano, a.kotasyonsirano, b.kotno, b.tur,
         CASE WHEN b.tur IN (2, 4) THEN 'SPOT'
              WHEN b.tur IN (3, 9) THEN 'Rotatif'
                   END nkrd_kotasyon_kredi_turu
    FROM extr.fs_krdmaster a, extr.fs_kotasyon b
   WHERE 1 = 1
     AND a.kotasyonsirano = b.kotno
     AND a.acilistarih <= v_tarih
     AND b.tur IN (2, 4, 3, 9);
GRANT SELECT ON trbac_nkrd_koti TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
--SELECT * FROM trbac_nkrd_koti;*/




      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_GVNC_ODM_EMIR_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=835;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_gvnc_odm_emir_01
     SELECT v_tarih AS kst_trh,
            i.alici_musteri_no AS musteri_no,
            a.musteri_vkn_tckn,
            a.musteri_unvan,
            i.id AS tps_odeme_emri_id,
            i.odeme_id AS tps_odeme_emri_odeme_id,
            i.odeme_guid AS tps_odeme_emri_odeme_guid,
            i.aciklama AS tps_odeme_emri_aciklama,
            k.tahakkuk_id AS tps_kom_tah_tahakkuk_id,               /*k.komisyon_id tps_kom_tah_komisyon_id, p.komisyon_id tps_kom_prm_komisyon_id,*/
            i.taksit_tutar, --Anapara (TUTAR1)
            i.toplam_tutar,
            i.odeme_vade_tarihi,
            i.kayit_tarih,
            i.durum AS tps_odeme_emri_durum,
            SUM (NVL (k.toplam_tutar, 0)) AS toplam_alinan_tutar,
            SUM (CASE WHEN LAST_DAY (TO_DATE (k.tahsilat_tarihi, 'DD/MM/YYYY')) = v_tarih THEN NVL (k.toplam_tahsil_tutar, 0) ELSE 0 END) AS toplam_tahsil_tutar,
            SUM (NVL (k.toplam_tahsil_tutar, 0)) AS toplam_tahsil_tutar_2,
            SUM (NVL (k.gecikme_tutar, 0)) AS gecikme_tutar,
            SUM (NVL (k.gecikme_tutar, 0) * 0.005) AS gecikme_bsmv,
            MAX (NVL (TO_NUMBER (p.tahsilat_periyod), 0)) AS tahsilat_periyod,
            MAX (NVL (TO_NUMBER (p.tahsilat_periyod), 0)) || ' AYLIK' AS tahsilat_periyod_aciklama,
            MAX (TO_DATE (k.guncelleme_tarih, 'DD/MM/YYYY')) AS kom_thslt_guncelleme_tarih,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_tps_odeme_emri i
            INNER JOIN      extr.fs_tps_alici_tanim a
                            ON     1 = 1
                               AND a.musteri_no = i.alici_musteri_no
            LEFT JOIN extr.fs_tps_komisyon_tahsilat k
                            ON     1 = 1
                               AND k.tahakkuk_id = i.id
                               AND k.komisyon_param_tip = 'ISK'
                               AND k.durum = 1
                               AND k.musteri_tip = 'A'
                               AND TO_DATE (k.tahsilat_tarihi, 'DD/MM/YYYY') <= v_tarih
            LEFT JOIN extr.fs_tps_komisyon_parametre p
                            ON     1 = 1
                               AND k.komisyon_param_id = p.komisyon_id
      WHERE 1 = 1
        AND i.durum IN ('ISKN', 'ACTV')
        --AND LAST_DAY (TO_DATE (i.odeme_vade_tarihi, 'DD/MM/YYYY')) >= v_tarih --------Aylýk Bildirim Query'si
        AND LAST_DAY (TO_DATE (i.odeme_vade_tarihi, 'DD/MM/YYYY')) >= ADD_MONTHS (v_tarih, -36) -------Ýlk Bildirim Query'si
        AND LAST_DAY (TO_DATE (i.kayit_tarih, 'DD/MM/YYYY')) <= v_tarih
   GROUP BY i.alici_musteri_no, a.musteri_vkn_tckn, a.musteri_unvan, i.id, i.odeme_id, i.odeme_guid, i.aciklama,
            k.tahakkuk_id,               /*k.komisyon_id, p.komisyon_id, */i.taksit_tutar, i.toplam_tutar, i.odeme_vade_tarihi, i.kayit_tarih, i.durum
   UNION ALL
     SELECT v_tarih kst_trh, i.alici_musteri_no musteri_no, a.musteri_vkn_tckn, a.musteri_unvan, i.id tps_odeme_emri_id,
            i.odeme_id tps_odeme_emri_odeme_id, i.odeme_guid tps_odeme_emri_odeme_guid, i.aciklama tps_odeme_emri_aciklama,
            k.tahakkuk_id tps_kom_tah_tahakkuk_id,               /*k.komisyon_id tps_kom_tah_komisyon_id, p.komisyon_id tps_kom_prm_komisyon_id,*/
            i.taksit_tutar, --Anapara (TUTAR1)
            i.toplam_tutar, TO_DATE (i.odeme_vade_tarihi, 'DD/MM/YYYY') odeme_vade_tarihi,
            TO_DATE (i.kayit_tarih, 'DD/MM/YYYY') kayit_tarih, i.durum tps_odeme_emri_durum,
            SUM (NVL (k.toplam_tutar, 0)) toplam_alinan_tutar,
            SUM (NVL (k.toplam_tahsil_tutar, 0)) toplam_tahsil_tutar,
            SUM (NVL (k.toplam_tahsil_tutar, 0)) toplam_tahsil_tutar_2,
            SUM (NVL (k.gecikme_tutar, 0)) gecikme_tutar,
            SUM (NVL (k.gecikme_tutar, 0) * 0.005) gecikme_bsmv,
            MAX (NVL (TO_NUMBER (p.tahsilat_periyod), 0)) tahsilat_periyod,
            MAX (NVL (TO_NUMBER (p.tahsilat_periyod), 0)) || ' AYLIK' tahsilat_periyod_aciklama,
            MAX (TO_DATE (k.guncelleme_tarih, 'DD/MM/YYYY')) kom_thslt_guncelleme_tarih,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_tps_odeme_emri i
            INNER JOIN      extr.fs_tps_alici_tanim a
                            ON     1 = 1
                               AND a.musteri_no = i.alici_musteri_no
            LEFT JOIN extr.fs_tps_komisyon_tahsilat k
                            ON     1 = 1
                               AND k.tahakkuk_id = i.id
                               AND k.komisyon_param_tip = 'ISK'
                               AND k.durum = 1
                               AND k.musteri_tip = 'A'
                               AND TO_DATE (k.tahsilat_tarihi, 'DD/MM/YYYY') <= v_tarih
                               AND TO_DATE (k.guncelleme_tarih, 'DD/MM/YYYY') <= v_tarih
                               AND LAST_DAY (TO_DATE (k.tahsilat_tarihi, 'DD/MM/YYYY')) = v_tarih
            LEFT JOIN extr.fs_tps_komisyon_parametre p
                            ON     1 = 1
                               AND k.komisyon_param_id = p.komisyon_id
      WHERE 1 = 1
        AND i.durum IN ('THSL', 'IPTL')
        AND LAST_DAY (TO_DATE (i.odeme_vade_tarihi, 'DD/MM/YYYY')) >= v_tarih --------Aylýk Bildirim Query'si
        --AND LAST_DAY (TO_DATE (i.odeme_vade_tarihi, 'DD/MM/YYYY')) >= ADD_MONTHS (v_tarih, -36) -------Ýlk Bildirim Query'si
        AND LAST_DAY (TO_DATE (i.kayit_tarih, 'DD/MM/YYYY')) <= v_tarih
   GROUP BY i.alici_musteri_no, a.musteri_vkn_tckn, a.musteri_unvan, i.id, i.odeme_id, i.odeme_guid, i.aciklama,
            k.tahakkuk_id,               /*k.komisyon_id, p.komisyon_id, */i.taksit_tutar, i.toplam_tutar, i.odeme_vade_tarihi, i.kayit_tarih, i.durum;

      COMMIT;
      v_line_no:=840;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_GVNC_ODM_EMIR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=845;

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_gvnc_odm_emir
     SELECT g.kst_trh, g.musteri_no, g.musteri_vkn_tckn, g.musteri_unvan, g.tps_odeme_emri_id, g.tps_odeme_emri_odeme_id,
            g.tps_odeme_emri_odeme_guid, g.tps_odeme_emri_aciklama, g.tps_kom_tah_tahakkuk_id, g.taksit_tutar, g.toplam_tutar,
            g.odeme_vade_tarihi, g.kayit_tarih,
            CASE WHEN g.kayit_tarih <= ADD_MONTHS (v_tarih, -1) THEN 'Ýlk'
                      ELSE 'Aylýk'
                           END aylik_ilk_bildirim_f,
            g.kayit_tarih AS ilk_kullandirim_trh, --rkilkk
            --g.odeme_vade_tarihi son_kullandirim_trh, --rksonk
            g.kayit_tarih AS son_kullandirim_trh, --rksonk
            CASE WHEN g.tps_odeme_emri_durum NOT IN ('ACTV', 'ISKN') THEN g.odeme_vade_tarihi ELSE NULL END AS hsp_kapanis_trh,
            (g.odeme_vade_tarihi - v_tarih) AS vade_gun, --rkvade
            g.tps_odeme_emri_durum, g.toplam_alinan_tutar, g.toplam_tahsil_tutar, g.toplam_tahsil_tutar_2,
            g.gecikme_tutar, g.gecikme_bsmv, g.tahsilat_periyod, g.tahsilat_periyod_aciklama, g.kom_thslt_guncelleme_tarih,
            0 AS para,
            949 AS kkb_doviz_kodu, --rkdvkd
            mm.ana_sube, --rksbkd
            s.ilkodu, --rksbil
            CASE WHEN g.tps_odeme_emri_durum IN ('ACTV', 'ISKN') THEN 1 ELSE 2 END hesap_durum_kodu, --rkhsod
            --9780304 thp_no, --rkkebr
            --1181101 thp_no, --rkkebr
            9800304 AS thp_no, --rkkebr
            0 AS ulke_kodu, --rkmhul
            g.taksit_tutar AS tutar1, --Anapara
            0 AS tutar2,
            (g.toplam_tahsil_tutar - (g.gecikme_tutar + g.gecikme_bsmv)) AS tutar3, --Komisyon
            --NULL tutar4, --Bu kolon üretilmedi => [1]: ORA-01723: sýfýr uzunluklu sütunlara izin verilmez
            --NULL tutar5,  --Bu kolon üretilmedi => [1]: ORA-01723: sýfýr uzunluklu sütunlara izin verilmez
            0 AS tutar6,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbac_gvnc_odm_emir_01 g
            LEFT JOIN ofsdata.musteri_master_cs_hist mm
                            ON     1 = 1
                               AND g.musteri_no = mm.musteri_no
                               AND g.kst_trh = mm.tarih
            LEFT JOIN extr.fs_sube s
                            ON     1 = 1
                               AND mm.ana_sube = s.sube
      WHERE 1 = 1
        AND NOT (
                     g.tps_odeme_emri_durum NOT IN ('ACTV', 'ISKN')
                 AND g.odeme_vade_tarihi > v_tarih
                );

      COMMIT;
      v_line_no:=850;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_MEMZUC_151_152',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=855;


--Memzuçtaki risk kodu 151 ve 152'leri KKB'ye dahil ettik (ING'nin aracý olduðu ödemeler - 151 aracý ve kefil olduðumuz krediler, 152 aracý olup kefil olmadýðýmýz krediler)

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_memzuc_151_152
     SELECT g.tarih kst_trh, g.sube, g.sinif, g.ilk7, g.hestur, g.ekno, g.para, g.durum, g.altdurum,
            TO_NUMBER (LPAD (g.ana, 3, '0') || LPAD (g.alt, 2, '0') || g.tali1 || g.tali2) AS thp_no,
            g.karakter, g.vade, g.valor, g.borc, g.alac,
            CASE WHEN g.karakter = 'A' THEN g.alac - g.borc ELSE g.borc - g.alac END AS bakiye,
            TO_DATE (h.actarih, 'DD/MM/YYYY') AS actarih,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_gunluk_hplandet_sg g
            INNER JOIN extr.fs_hplandet_sg h
                              ON  1 = 1
                              AND g.sube = h.sube
                              AND g.sinif = h.sinif
                              AND g.ilk7 = h.ilk7
                              AND g.hestur = h.hestur
                              AND g.ekno = h.ekno
            INNER JOIN extr.fs_riskparam_tcmb p
                              ON 1 = 1
                              AND TO_NUMBER (LPAD (g.ana, 3, '0') || LPAD (g.alt, 2, '0') || g.tali1 || g.tali2) = TO_NUMBER (LPAD (p.ana, 3, '0') || LPAD (p.alt, 2, '0') || p.tali1 || p.tali2)
      WHERE 1 = 1
        AND g.durum = 0
        AND g.tarih = v_tarih
        AND g.borc - g.alac <> 0
        AND p.riskkodu IN (151, 152); --TO_NUMBER (LPAD (g.ana, 3, '0') || LPAD (g.alt, 2, '0') || g.tali1 || g.tali2) IN (9610200, 9999801, 9999800, 9999810, 9999820, 9999802)

      COMMIT;
      v_line_no:=860;



      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_FCT_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=865;


      INSERT               /*+ APPEND */ INTO  trfm.tmp_trbac_fct_01
     SELECT v_tarih kst_trh,
            'TKRD' tip,
            b.sube AS refsube,
            b.reftur,
            b.refnitelik,
            b.refsirano,
            CAST(NULL AS NUMBER) AS kmh_mt_ekno,
            CAST(NULL AS NUMBER) AS kmh_kr_ekno,
            b.musteri AS musteri_no,
            TO_NUMBER (LPAD (h.ana, 3, '0') || LPAD (h.alt, 2, '0') || h.tali1 || h.tali2) AS thp_no,
            102 AS kredi_turu_kod,
            'Taksitli Ticari Kredi' AS kredi_turu_acklm,
            b.para,
            CAST(NULL AS NUMBER) AS kullandirim_doviz_kodu,
            b.acilistarih AS ilk_kullandirim_tarihi,
            -- bh.vade son_kullandýrma_tarihi,
            b.acilistarih AS son_kullandýrma_tarihi,
            b.kreditutar AS acilis_ilk_kullandirim_tutari,
            CASE WHEN h.vade IS NOT NULL AND h.vade >= TO_DATE('01/01/2000','dd/mm/yyyy') THEN h.vade ELSE bh.vade END vade_tarihi,
            '000' AS muhatap_ulke_kodu,
            CAST(NULL AS VARCHAR2(69 BYTE)) AS muhatap,
            --NULL muhattap_vergi_kimlik_no,
            --NULL muhattap_tc_kimlik_no--,
            CASE WHEN b.durum IN (6, 7, 8, 9, 10, 11, 98) AND b.kapanistarih > TO_DATE ('01/01/1900', 'DD/MM/YYYY')
                      THEN b.kapanistarih ELSE NULL END hsp_kapanis_trh,
              (e.eski_sube || e.eski_reftur || e.eski_refsirano) devir_oncesi_ref,
              e.updtarih devir_trh,
              koti.kotno kotasyon_no,
              koti.tur kotasyon_tur,
              'H' devirden_onceki_eski_ref_mi,
            CASE WHEN b.kapanistarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
                      ELSE 'Ýlk'
            END AS aylik_ilk_bildirim_f,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ b
            INNER JOIN extr.fs_sube s ON 1=1 AND b.sube = s.sube
            INNER JOIN extr.fs_gunluk_hplandet_sg h ON 1= 1
                                                      AND b.reftur IN ('TT', 'TD')
                                                      AND b.musteri = h.ilk7
                                                      AND b.krdhestur = h.hestur
                                                      AND b.krdekno = h.ekno
                                                      AND h.sube = b.sube
                                                      AND H.SINIF= 'C'
                                                      AND h.durum = 0
            INNER JOIN trfm.tmp_trbfc_ana_mus_set m ON 1=1
                                           AND v_tarih = m.kesit_tarihi
                                           AND b.musteri = m.musteri_no
            INNER JOIN (
                          SELECT sube,reftur,refsirano ,MAX (vadetarih) vade
                            FROM extr.fs_bkrhrkt
                           WHERE 1=1
                                 AND TO_DATE (odemetarih, 'DD/MM/YYYY') <= v_tarih
                                 AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
                        GROUP BY sube,reftur,refsirano
                       ) bh ON  1 = 1
                            AND b.sube = bh.sube
                            and b.reftur = bh.reftur
                            and b.refsirano = bh.refsirano
            LEFT JOIN extr.fs_kotasyon koti ON b.kotasyonno = koti.kotno
            LEFT JOIN trfm.tmp_trbac_dvr_blg e ON  1=1
                                          and b.sube=e.yeni_sube
                                          and b.reftur=e.yeni_reftur
                                          and b.refsirano=e.yeni_refsirano
    WHERE   (   (b.durum IN (3, 93))
                      OR (    b.durum IN (6, 7, 8, 9, 10, 11, 98)
                   AND b.kapanistarih =v_tarih) --aylýk Bildirim
                   --AND b.kapanistarih >= LAST_DAY (ADD_MONTHS (v_tarih, -36)+1) ) --ilk Bildirim
                      OR (    b.durum IN (6)
                          AND b.kapanistarih > TO_DATE ('01/01/2005', 'dd/mm/yyyy')))
            AND v_tarih = h.tarih

            AND b.acilistarih <= v_tarih
            --AND v_tarih >= TO_DATE (koti.isltarih (+), 'DD/MM/YYYY')
            --
                          /*  --Ýlk bildirim
            AND NVL (CASE WHEN b.durum IN (6, 7, 8, 9, 10, 11, 98)
                               AND TO_DATE (b.kapanistarih, 'DD/MM/YYYY') > TO_DATE ('01/01/1900', 'DD/MM/YYYY')
                          THEN TO_DATE (b.kapanistarih, 'DD/MM/YYYY')
                          ELSE NULL END,
                     v_tarih) >= ADD_MONTHS (v_tarih, -36)+1  ;
            */
            --
              --Aylýk bildirim
            AND LAST_DAY (NVL (CASE WHEN b.durum IN (6, 7, 8, 9, 10, 11, 98)
                               AND TO_DATE (b.kapanistarih, 'DD/MM/YYYY') > TO_DATE ('01/01/1900', 'DD/MM/YYYY')
                          THEN TO_DATE (b.kapanistarih, 'DD/MM/YYYY')
                          ELSE NULL END,
                     v_tarih)) = v_tarih;

      COMMIT;
      v_line_no:=870;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_fct_01
     SELECT               /*+ parallel(koti 12) */
            v_tarih kst_trh,
            'NKRD' tip,
            k.sube refsube,
            k.reftur,
            k.refnitelik,
            k.refsirano,
            CAST(NULL AS NUMBER) AS kmh_mt_ekno,
            CAST(NULL AS NUMBER) AS kmh_kr_ekno,
            k.musteri AS musteri_no,
            TO_NUMBER (LPAD (h.ana, 3, '0') || LPAD (h.alt, 2, '0') || h.tali1 || h.tali2) thp_no,
            CASE WHEN k.kreditur IN (1, 2, 20, 24, 41, 42) THEN 103
                 WHEN k.kreditur = 5 THEN 107
                 WHEN k.kreditur = 3 THEN 108
                 WHEN k.kreditur = 9 THEN 115
                 WHEN koti.tur IN (2, 4) THEN 103
                 WHEN koti.tur IN (3, 9) THEN 108
                 WHEN k.kreditur IN (4, 7, 8, 10) THEN 103
            END AS kredi_turu_kod,
            CASE WHEN k.kreditur IN (1, 2, 20, 24, 41, 42) THEN 'Spot/Overnight'
                 WHEN k.kreditur = 5 THEN 'Iskonto/Istirak'
                 WHEN k.kreditur = 3 THEN 'BCH/Rotatif'
                 WHEN k.kreditur = 9 THEN 'Exim Kredileri'
                 WHEN koti.tur IN (2, 4) THEN 'Spot/Overnight'
                 WHEN koti.tur IN (3, 9) THEN 'BCH/Rotatif'
                 WHEN k.kreditur IN (4, 7, 8, 10) THEN 'Spot/Overnight'
            END AS kredi_turu_acklm,
            k.para,
            CASE WHEN k.kreditur = 4 THEN k.para ELSE NULL END kullandirim_doviz_kodu,
            k.acilistarih  ilk_kullandirim_tarihi,
             -- kullandirim_tarihi  son_kullandýrma_tarihi ,
--                          (  SELECT MAX (difnotarih)
--                         FROM cutl.krdhrkt kh
--                        WHERE     k.sube = kh.sube
--                              AND k.reftur = kh.reftur
--                              AND k.refsirano = kh.refsirano
--                              AND kh.harekettip = 2
--                              AND (kh.durum = 0 OR (kh.durum = 9 AND kh.updprogram = 'DEVR04'))
--                     GROUP BY k.sube,
--                              k.reftur,
--                              k.refsirano,
--                              kh.harekettip)
--                       maxkullandirim_tarih
            kh.max_difnotarihi  son_kullandýrma_tarihi,
            k.kreditutar  acilis_ilk_kullandirim_tutari,
            k.vade vade_tarihi,
            '000' AS muhatap_ulke_kodu,
            CAST(NULL AS VARCHAR2(69 BYTE)) AS muhatap,
                --NULL muhattap_vergi_kimlik_no,
                --NULL muhattap_tc_kimlik_no,
            CASE WHEN k.durum = 4 THEN k.kapanistarih ELSE NULL END hsp_kapanis_trh,
            (e.eski_sube || e.eski_reftur || e.eski_refsirano) devir_oncesi_ref,
            e.updtarih devir_trh,
            k.kotasyonsirano kotasyon_no,
            koti.tur kotasyon_tur,
            'H' devirden_onceki_eski_ref_mi,
            CASE WHEN k.kapanistarih >= LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
                 ELSE 'Ýlk'
            END aylik_ilk_bildirim_f,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM ofsdata.krdmaster_aysonu              /*extr.fs_krdmaster tablosu proda atýlacak*/ k, extr.fs_sube s ,extr.fs_gunluk_hplandet_sg h,
            trfm.tmp_trbfc_ana_mus_set m,
            (
               SELECT sube, reftur,refsirano ,MAX (difnotarih) AS max_difnotarihi
                 FROM extr.fs_krdhrkt
                WHERE 1=1
                      AND harekettip = 2
                      AND (durum = 0 OR (durum = 9 AND updprogram = 'DEVR04'))
                      AND difnotarih <= v_tarih
             GROUP BY sube,reftur,refsirano
            )kh,
            trfm.tmp_trbac_dvr_blg e,
            extr.fs_kotasyon koti
      WHERE (   (k.durum = 2)
                   OR (k.acilistarih >= LAST_DAY (ADD_MONTHS (v_tarih, -1)) AND k.durum = 4)
                   OR (    --k.kapanistarih >= LAST_DAY (ADD_MONTHS (v_tarih, -36)+1) --Ýlk Bildirim
                             LAST_DAY (TO_DATE (k.kapanistarih, 'DD/MM/YYYY')) >= v_tarih --Aylýk Bildirim
                       AND k.durum = 4
                       AND k.acilistarih <= LAST_DAY (ADD_MONTHS (v_tarih, -1))))
            AND k.sube = s.sube
            and k.sube = h.sube
            AND k.musteri = h.ilk7
            AND k.hestur = h.hestur
            AND k.ekno = h.ekno
            AND 'C'= h.sinif
            AND 0 = h.durum
            AND k.hestur != 'KD'
            AND k.sube = kh.sube
            AND k.reftur = kh.reftur
            AND k.refsirano = kh.refsirano
            AND v_tarih = h.tarih
            AND v_tarih = m.kesit_tarihi
            AND k.musteri = m.musteri_no
            and k.sube=e.yeni_sube (+)
            and k.reftur=e.yeni_reftur (+)
            and k.refsirano=e.yeni_refsirano (+)
            AND k.acilistarih <= v_tarih
            --AND v_tarih >= TO_DATE (koti.isltarih (+), 'DD/MM/YYYY')
            AND k.kotasyonsirano = koti.kotno (+)
            --AND NVL (CASE WHEN k.durum = 4 THEN k.kapanistarih ELSE NULL END, v_tarih) >= ADD_MONTHS (v_tarih, -36)+1 --ilk bildirim.
            AND LAST_DAY(NVL (CASE WHEN k.durum = 4 THEN k.kapanistarih ELSE NULL END, v_tarih)) =v_tarih; --aylýk bildirim.

      COMMIT;
      v_line_no:=875;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_fct_01
   SELECT kst_trh, tip, refsube, reftur, refnitelik, refsirano, kmh_mt_ekno, kmh_kr_ekno, musteri_no, thp_no, kredi_turu_kod, kredi_turu_acklm, para, kullandirim_doviz_kodu,
          ilk_kullandirim_tarihi, son_kullandirma_tarihi, acilis_ilk_kullandirim_tutari, vade_tarihi, muhatap_ulke_kodu, muhatap, hsp_kapanis_trh, devir_oncesi_ref, devir_trh,
          kotasyon_no, kotasyon_tur, devirden_onceki_eski_ref_mi, aylik_ilk_bildirim_f,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM (
           SELECT DISTINCT
                  v_tarih AS kst_trh,
                  'TMEK' AS tip,
                  t.refsube AS refsube,
                  t.reftur,
                  t.refnit AS refnitelik,
                  t.refsirano,
                  CAST(NULL AS NUMBER) AS kmh_mt_ekno,
                  CAST(NULL AS NUMBER) AS kmh_kr_ekno,
                  t.musteri AS musteri_no,
                  TO_NUMBER (LPAD (h.ana, 3, '0') || LPAD (h.alt, 2, '0') || h.tali1 || h.tali2) thp_no,
                  CASE WHEN t.reftur <> 'HG' THEN 111
                       WHEN t.reftur = 'HG' THEN 112
                       WHEN h.ana = 158 THEN 113
                  END kredi_turu_kod,
                  CASE WHEN t.reftur <> 'HG' THEN 'TEMINAT MEKTUBU'
                       WHEN t.reftur = 'HG' THEN 'HARICI GARANTILER'
                       WHEN h.ana = 158 THEN 'TAZMIN OLAN GAYRINAKDI KREDI BEDELLERI'
                  END kredi_turu_acklm,
                  t.para,
                  CAST(NULL AS NUMBER) AS kullandirim_doviz_kodu,
                  --t.vertarih ilk_kullandirim_tarihi,
                  CASE WHEN TO_DATE (t.vertarih, 'DD/MM/YYYY') < TO_DATE ('01/01/1995', 'DD/MM/YYYY') THEN TO_DATE (t.fistarih, 'DD/MM/YYYY') ELSE TO_DATE (t.vertarih, 'DD/MM/YYYY') END ilk_kullandirim_tarihi,
                  --t.vertarih son_kullandýrma_tarihi,
                  CASE WHEN TO_DATE (t.vertarih, 'DD/MM/YYYY') < TO_DATE ('01/01/1995', 'DD/MM/YYYY') THEN TO_DATE (t.fistarih, 'DD/MM/YYYY') ELSE TO_DATE (t.vertarih, 'DD/MM/YYYY') END son_kullandýrma_tarihi,
                  t.tutar AS acilis_ilk_kullandirim_tutari,
                  t.vade AS vade_tarihi,
                  '000' muhatap_ulke_kodu,
                  CAST(NULL AS VARCHAR2(69 BYTE)) AS muhatap,
                       --NULL muhattap_vergi_kimlik_no,
                       --NULL muhattap_tc_kimlik_no
                       i.mx_fistarih hsp_kapanis_trh,
                  (e.eski_sube || e.eski_reftur || e.eski_refsirano) AS devir_oncesi_ref,
                  e.updtarih AS devir_trh,
                  CAST(NULL AS NUMBER) AS kotasyon_no,
                  CAST(NULL AS NUMBER) AS kotasyon_tur,
                  'H' AS devirden_onceki_eski_ref_mi,
                  --CASE WHEN hk.fistarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
                  --          ELSE 'Ýlk'
                  --               END aylik_ilk_bildirim_f
                  'Ýlk' AS aylik_ilk_bildirim_f
             FROM extr.fs_temmekmas t,
                  extr.fs_sube s,
                  extr.fs_gunluk_hplandet_sg h,
                  trfm.tmp_trbfc_ana_mus_set m,
                  extr.fs_temmekhrkt hk,
                  trfm.tmp_trbac_tmek_hsp_kpns_trh i,
                  trfm.tmp_trbac_dvr_blg e
            WHERE 1=1
                  AND t.refsube = s.sube
                  AND t.refsube = h.sube
                  AND t.musteri = h.ilk7
                  AND t.refsube = hk.refsube
                  AND t.reftur = hk.reftur
                  AND t.refsirano = hk.refsirano
                  AND h.hestur = 'TA'
                  AND t.taekno = h.ekno
                  AND h.sinif = 'C'
                  AND h.durum = 0
                  AND (   (t.durum = 2)
                         OR (    t.durum IN (3, 4)
                             AND (    hk.hrkttur IN (4, 6)
                                  AND hk.durum <> 9
                                  --AND hk.fistarih >= LAST_DAY (ADD_MONTHS (v_tarih, -36)+1))  --ilk bildirim
                                  AND LAST_DAY(hk.fistarih) = v_tarih) --aylýk bildirim
                         OR (    t.durum IN (3, 4)
                             AND (    hk.hrkttur IN (4, 6)
                                  AND hk.durum <> 9
                                  AND t.updprogram = 'TEMUPD')))
                  AND t.mektupbas IS NULL)
                  AND v_tarih = i.kst_trh (+)
                  AND t.refsube = i.refsube (+)
                  AND t.reftur = i.reftur (+)
                  AND t.refsirano = i.refsirano (+)
                  AND v_tarih = h.tarih
                  AND v_tarih = m.kesit_tarihi
                  AND t.musteri = m.musteri_no
                  and t.refsube=e.yeni_sube (+)
                  and t.reftur=e.yeni_reftur (+)
                  and t.refsirano=e.yeni_refsirano (+)
                  AND t.vertarih <= v_tarih
                  --AND NVL (i.mx_fistarih, v_tarih) >= ADD_MONTHS (v_tarih, -36)+1  --ilk bildirim
                  AND LAST_DAY(NVL (i.mx_fistarih, v_tarih)) = v_tarih  --aylýk bildirim
        UNION
           SELECT DISTINCT
                  v_tarih kst_trh,
                  'TMEK' AS tip,
                  t.refsube refsube,
                  t.reftur,
                  t.refnit refnitelik,
                  t.refsirano,
                  CAST(NULL AS NUMBER) AS kmh_mt_ekno,
                  CAST(NULL AS NUMBER) AS kmh_kr_ekno,
                  t.musteri musteri_no,
                  TO_NUMBER (LPAD (h.ana, 3, '0') || LPAD (h.alt, 2, '0') || h.tali1 || h.tali2) thp_no,
                  CASE WHEN t.reftur <> 'HG' THEN 111
                       WHEN t.reftur = 'HG' THEN 112
                       WHEN h.ana = 158 THEN 113
                  END kredi_turu_kod,
                  CASE WHEN t.reftur <> 'HG' THEN 'TEMINAT MEKTUBU'
                       WHEN t.reftur = 'HG' THEN 'HARICI GARANTILER'
                       WHEN h.ana = 158 THEN 'TAZMIN OLAN GAYRINAKDI KREDI BEDELLERI'
                  END kredi_turu_acklm,
                  t.para,
                  CAST(NULL AS NUMBER) kullandirim_doviz_kodu,
                  --t.vertarih ilk_kullandirim_tarihi,
                  CASE WHEN TO_DATE (t.vertarih, 'DD/MM/YYYY') < TO_DATE ('01/01/1995', 'DD/MM/YYYY') THEN TO_DATE (t.fistarih, 'DD/MM/YYYY') ELSE TO_DATE (t.vertarih, 'DD/MM/YYYY') END ilk_kullandirim_tarihi,
                  --t.vertarih son_kullandýrma_tarihi,
                  CASE WHEN TO_DATE (t.vertarih, 'DD/MM/YYYY') < TO_DATE ('01/01/1995', 'DD/MM/YYYY') THEN TO_DATE (t.fistarih, 'DD/MM/YYYY') ELSE TO_DATE (t.vertarih, 'DD/MM/YYYY') END son_kullandýrma_tarihi,
                  t.tutar acilis_ilk_kullandirim_tutari,
                  t.vade vade_tarihi,
                  '000' AS muhatap_ulke_kodu,
                  CAST(NULL AS VARCHAR2(69 BYTE)) muhatap,
                         --NULL muhattap_vergi_kimlik_no,
                         --NULL muhattap_tc_kimlik_no
                  i.mx_fistarih hsp_kapanis_trh,
                  (e.eski_sube || e.eski_reftur || e.eski_refsirano) devir_oncesi_ref,
                  e.updtarih AS devir_trh,
                  CAST(NULL AS NUMBER) AS kotasyon_no,
                  CAST(NULL AS NUMBER) AS kotasyon_tur,
                  'H' AS devirden_onceki_eski_ref_mi,
                  --CASE WHEN hk.fistarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
                  --          ELSE 'Ýlk'
                  --               END aylik_ilk_bildirim_f
                  'Ýlk' aylik_ilk_bildirim_f
            FROM extr.fs_temmekmas t,
                 extr.fs_sube s,
                 extr.fs_gunluk_hplandet_sg h,
                 trfm.tmp_trbfc_ana_mus_set m,
                 extr.fs_temmekhrkt hk,
                 trfm.tmp_trbac_tmek_hsp_kpns_trh i,
                 trfm.tmp_trbac_dvr_blg e
           WHERE 1=1
                 AND t.refsube = s.sube
                 AND t.refsube = h.sube
                 AND t.musteri = h.ilk7
                 AND t.refsube = hk.refsube
                 AND t.reftur = hk.reftur
                 AND t.refsirano = hk.refsirano
                 AND h.hestur = 'TA'
                 AND t.taekno = h.ekno
                 AND h.sinif = 'C'
                 AND h.durum = 0
                 AND (   (t.durum = 2)
                      OR (    t.durum IN (3, 4)
                          AND (    hk.hrkttur IN (4, 6)
                               AND hk.durum <> 9
                               --AND hk.fistarih >= LAST_DAY (ADD_MONTHS (v_tarih, -36)+1) --ilk bildirim
                               AND LAST_DAY(hk.fistarih) = v_tarih --aylýk bildirim
                               )
                         )
                      OR (    t.durum IN (3, 4)
                          AND (    hk.hrkttur IN (4, 6)
                               AND hk.durum <> 9
                               AND t.updprogram = 'TEMUPD')))
                 AND t.mektupbas IS NULL
                 AND v_tarih = i.kst_trh (+)
                 AND t.refsube = i.refsube (+)
                 AND t.reftur = i.reftur (+)
                 AND t.refsirano = i.refsirano (+)
                 AND v_tarih = h.tarih
                 AND v_tarih = m.kesit_tarihi
                 AND t.musteri = m.musteri_no
                 and t.refsube=e.yeni_sube (+)
                 and t.reftur=e.yeni_reftur (+)
                 and t.refsirano=e.yeni_refsirano (+)
                 AND t.vertarih <= v_tarih
                 AND hk.fistarih <= v_tarih
                 --AND NVL (i.mx_fistarih, v_tarih) >= ADD_MONTHS (v_tarih, -36)+1    --ilk bildirim
                 AND LAST_DAY(NVL (i.mx_fistarih, v_tarih)) = v_tarih    --aylýk bildirim
          );

      COMMIT;
      v_line_no:=880;

INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_fct_01
  SELECT v_tarih kst_trh,
         'KMH' tip,
         t.sube refsube,
         'KT' reftur,
         CAST(NULL AS VARCHAR2(2 BYTE)) refnitelik,
         t.krdekno AS refsirano, --KMH_KT_EKNO
         t.kmhekno AS kmh_mt_ekno,
         d.krekno AS kmh_kr_ekno,
         t.kmhilk7 AS musteri_no,
         TO_NUMBER(TRIM (TO_CHAR (h.ana, 'FM009') || TO_CHAR (h.alt, 'FM09') || h.tali1 || h.tali2)) thp,
         CASE WHEN t.tip IN (25, 26, 27, 28) THEN 105
              WHEN t.tip IN (21, 22) THEN 105
                   END kredi_turu_kod,
         CASE WHEN t.tip IN (25, 26, 27, 28) THEN 'DBS_Nakit'
              WHEN t.tip IN (21, 22) THEN 'Ticari KMH'
                   END kredi_turu_acklm,
         h.para,
         CAST(NULL AS NUMBER) AS kullandirim_doviz_kodu,
         --t.girtarih ilk_kullandirim_tarihi,
         CASE WHEN TO_DATE (t.girtarih, 'DD/MM/YYYY') < TO_DATE ('01/01/1995', 'DD/MM/YYYY') THEN TO_DATE (h2.actarih, 'DD/MM/YYYY') ELSE TO_DATE (t.girtarih, 'DD/MM/YYYY') END ilk_kullandirim_tarihi,
         skt.son_kullndrm_trh AS son_kullandýrma_tarihi,
         t.kmhkrdkul AS acilis_ilk_kullandirim_tutari,
         t.tahakkuktarihi AS vade_tarihi,
         '000' AS muhatap_ulke_kodu,
         CAST(NULL AS VARCHAR2(69 BYTE)) AS muhatap,
         --NULL muhattap_vergi_kimlik_no,
         --NULL muhattap_tc_kimlik_no
         --GREATEST (TO_DATE (h.updtarih, 'DD/MM/YYYY'), NVL (l.ld_date, TO_DATE ('01/01/1900', 'DD/MM/YYYY'))) hsp_kapanis_trh,
         TO_DATE (l.kmh_kapanis_trh, 'DD/MM/YYYY') AS hsp_kapanis_trh,
         CAST(NULL AS VARCHAR2(70 BYTE)) devir_oncesi_ref,
         CAST(NULL AS DATE) AS devir_trh,
         CAST(NULL AS NUMBER) AS kotasyon_no,
         CAST(NULL AS NUMBER) AS kotasyon_tur,
         'H' devirden_onceki_eski_ref_mi,
         CASE WHEN TO_DATE (l.kmh_kapanis_trh, 'DD/MM/YYYY') > LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
          ELSE 'Ýlk'
               END aylik_ilk_bildirim_f,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_sube s
         INNER JOIN ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t
                    ON 1 = 1
                    AND t.sube = s.sube
         INNER JOIN extr.fs_gunluk_hplandet_sg h
                    ON 1 = 1
                    AND v_tarih = h.tarih
                    AND t.sube = h.sube
                    AND t.kmhilk7 = h.ilk7
                    AND h.hestur = 'KT'
                    AND t.krdekno = h.ekno
                    AND h.sinif = 'C'
                    AND h.durum = 0
         INNER JOIN extr.fs_hplandet_sg h2
                    ON 1 = 1
                    AND t.sube = h2.sube
                    AND t.kmhilk7 = h2.ilk7
                    AND h2.hestur = 'KT'
                    AND t.krdekno = h2.ekno
                    AND h2.sinif = 'C'
                    AND h2.durum = 0
         INNER JOIN trfm.tmp_trbfc_ana_mus_set m
                    ON 1 = 1
                    AND v_tarih = m.kesit_tarihi
                    AND t.kmhilk7 = m.musteri_no
         LEFT JOIN trfm.tmp_trbac_son_klndrm_trh skt
                    ON  1 = 1
                    AND v_tarih = skt.kst_trh
                    AND t.sube = skt.sube
                    AND h.sinif = skt.sinif
                    AND t.kmhilk7 = skt.ilk7
                    AND h.hestur = skt.hestur
                    AND t.krdekno = skt.ekno
         LEFT JOIN trfm.tmp_trbac_kmh_hsp_kpns_trh l
                    ON  1 = 1
                    AND v_tarih = l.kst_trh
                    AND t.sube = l.sube
                    AND h.sinif = l.sinif
                    AND t.kmhilk7 = l.kmhilk7
                    AND h.hestur = l.hestur
                    AND t.krdekno = l.krdekno
         LEFT JOIN extr.fs_kmhmas_detay d
                    ON  1 = 1
                    AND d.sube = t.sube
                    AND d.kmhilk7 = t.kmhilk7
                    AND d.tip = t.tip
   WHERE 1 = 1
         AND t.krdekno != 0
         AND t.tip IN (21, 22, 25, 26, 27, 28)
         AND t.girtarih <= v_tarih
         AND t.sondurum NOT IN (0, 5, 9)
         --AND NVL (TO_DATE (l.kmh_kapanis_trh, 'DD/MM/YYYY'), v_tarih) >= ADD_MONTHS (v_tarih, -36)+1 --ilk bildirim.
         AND LAST_DAY(NVL (TO_DATE (l.kmh_kapanis_trh, 'DD/MM/YYYY'), v_tarih)) = v_tarih --aylýk bildirim.
 ;

      COMMIT;
      v_line_no:=890;


INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_fct_01
SELECT kst_trh, tip, refsube, reftur, refnitelik, refsirano, kmh_mt_ekno, kmh_kr_ekno, musteri_no, thp_no, kredi_turu_kod, kredi_turu_acklm, para, kullandirim_doviz_kodu,
       ilk_kullandirim_tarihi, son_kullandirma_tarihi, acilis_ilk_kullandirim_tutari, vade_tarihi, muhatap_ulke_kodu, muhatap, hsp_kapanis_trh, devir_oncesi_ref, devir_trh,
       kotasyon_no, kotasyon_tur, devirden_onceki_eski_ref_mi, aylik_ilk_bildirim_f,
       SYSDATE AS etl_trh,
       v_sp_name AS etl_job
  FROM (
        SELECT DISTINCT v_tarih AS kst_trh,
               'ITH' AS tip,
               k.sube AS refsube,
               k.reftur,
               k.nitelik AS refnitelik,
               k.refsirano,
               CAST(NULL AS NUMBER) AS kmh_mt_ekno,
               CAST(NULL AS NUMBER) AS kmh_kr_ekno,
               k.musteri AS musteri_no,
               t.risk_thp_no AS thp_no,
               CASE WHEN k.reftur IN ('LC', 'AL') THEN 106
                    WHEN k.reftur IN ('AC') THEN 114
               END AS kredi_turu_kod,
               CASE WHEN k.reftur IN ('LC', 'AL') THEN 'Akreditif'
                    WHEN k.reftur IN ('AC') THEN 'Aval/Kabul Kredileri'
               END AS kredi_turu_acklm,
               k.para,
               CAST(NULL AS NUMBER) AS kullandirim_doviz_kodu,
               k.acilistarih AS ilk_kullandirim_tarihi,
               k.acilistarih AS son_kullandýrma_tarihi,---fonksiyon kullanýlýyor  Burhan bakacak
               k.acilistutar AS acilis_ilk_kullandirim_tutari ,---edize sorulacak
                             /*CASE WHEN k.akreditifvade < NVL (v.ld_vadetarihi, TO_DATE('01/01/2003','DD/MM/YYYY')) THEN (NVL (v.ld_vadetarihi, TO_DATE('01/01/2003','DD/MM/YYYY')) - k.acilistarih)
                         ELSE k.akreditifvade - k.acilistarih
                              END */
               CASE WHEN k.reftur = 'AC' and k.aval = '1' THEN k.dosyavade ELSE k.akreditifvade END AS vade_tarihi,
               k.lehdarulke AS muhatap_ulke_kodu, --Burhan fonksiyon üzerinde çalýþacak --get_kkb_ulkelookup2 (ln_ulke_kod,ithmaster_rec.lehdarulke) muhatap_ulke_kodu,---bu kýsýma burhan bakacak fonksiyon kullanýlabiliyor mu, @fsbcv ile ?
               k.lehdaradi||' '||k.lehdarsoyadi AS muhatap,
                 --NULL muhattap_vergi_kimlik_no,
                 --NULL muhattap_tc_kimlik_no,
               j.rkhskt AS hsp_kapanis_trh,
               (e.eski_sube || e.eski_reftur || e.eski_refsirano) AS devir_oncesi_ref,
               e.updtarih AS devir_trh,
               CAST(NULL AS NUMBER) AS kotasyon_no,
               CAST(NULL AS NUMBER) AS kotasyon_tur,
               'H' AS devirden_onceki_eski_ref_mi,
               CASE WHEN k.acilistarih >=  LAST_DAY (ADD_MONTHS (v_tarih, -36)) THEN 'Ýlk'
                    ELSE 'Aylýk'
               END aylik_ilk_bildirim_f
          FROM extr.fs_ithmaster k,
               extr.fs_sube s ,
               ofsdata.musteri_master_cs_hist mm,
                             /*trbac_fct_tmp_11 v, */
               trfm.tmp_trbfc_ana_mus_set m,
               trfm.tmp_trbac_ith_hsp_kpns_trh j,
               trfm.tmp_trbac_dvr_blg e,
               trfm.tmp_ith_dim_rsk_thp_no t
         WHERE 1 = 1
              --AND k.acilistarih >=  ADD_MONTHS (v_tarih, -36)+1      --ilk bildirim
               AND LAST_DAY(TO_DATE(k.acilistarih,'DD/MM/YYYY')) =  v_tarih   --aylýk bildirim
               AND (k.reftur IN ('LC', 'AL') OR (k.reftur = 'AC' AND k.aval = 1 and k.policegiristutar>0))
               AND k.durum NOT IN (7, 9, 11, 10)
               and k.musteri = mm.musteri_no
               AND k.sube = s.sube
                             /*AND k.sube = v.sube (+)
               AND k.reftur = v.reftur (+)
               AND k.refsirano = v.refsirano (+)
               AND v_tarih = v.kst_trh (+)*/
               AND v_tarih = m.kesit_tarihi
               AND v_tarih = mm.tarih
               AND k.musteri = m.musteri_no
               AND k.sube = j.sube (+)
               AND k.reftur = j.reftur (+)
               AND k.refsirano = j.refsirano (+)
               AND v_tarih = j.kst_trh (+)
               and k.sube=e.yeni_sube (+)
               --and b.bankakod=e.yeni_banka (+)
               and k.reftur=e.yeni_reftur (+)
               and k.refsirano=e.yeni_refsirano (+)
               AND k.acilistarih <= v_tarih
               AND k.sube = t.sube (+)
               AND k.reftur = t.reftur (+)
               AND k.refsirano = t.refsirano (+)
               AND v_tarih = t.kst_trh (+)
               --AND NVL (j.rkhskt, v_tarih) >= ADD_MONTHS (v_tarih, -36)+1    --ilk bildirim
               AND LAST_DAY(NVL (j.rkhskt, v_tarih)) = v_tarih    --aylýk bildirim
      UNION
        SELECT DISTINCT v_tarih kst_trh,
               'ITH' AS tip,
               k.sube AS refsube,
               k.reftur,
               k.nitelik AS refnitelik,
               k.refsirano,
               CAST(NULL AS NUMBER) AS kmh_mt_ekno,
               CAST(NULL AS NUMBER) AS kmh_kr_ekno,
               k.musteri AS musteri_no,
               t.risk_thp_no AS thp,
               CASE WHEN k.reftur IN ('LC', 'AL') THEN 106
                    WHEN k.reftur IN ('AC') THEN 114
                         END AS kredi_turu_kod,
               CASE WHEN k.reftur IN ('LC', 'AL') THEN 'Akreditif'
                    WHEN k.reftur IN ('AC') THEN 'Aval/Kabul Kredileri'
                         END AS kredi_turu_acklm,
               k.para,
               CAST(NULL AS NUMBER) AS kullandirim_doviz_kodu,
               k.acilistarih AS ilk_kullandirim_tarihi,
               k.acilistarih AS son_kullandýrma_tarihi,
               k.acilistutar AS acilis_ilk_kullandirim_tutari ,---edize sorulacak
                             /*CASE WHEN k.akreditifvade < NVL (v.ld_vadetarihi, TO_DATE('01/01/2003','DD/MM/YYYY')) THEN (NVL (v.ld_vadetarihi, TO_DATE('01/01/2003','DD/MM/YYYY')) - k.acilistarih)
                         ELSE k.akreditifvade - k.acilistarih
                              END*/
               CASE WHEN k.reftur = 'AC' and k.aval = '1' THEN k.dosyavade ELSE k.akreditifvade END AS vade_tarihi,
               k.lehdarulke AS muhatap_ulke_kodu, --Burhan fonksiyon üzerinde çalýþacak  -- get_kkb_ulkelookup2 (ln_ulke_kod,ithmaster_rec.lehdarulke) muhatap_ulke_kodu,
               k.lehdaradi||' '||k.lehdarsoyadi AS muhatap,
               --NULL muhattap_vergi_kimlik_no,
               --NULL muhattap_tc_kimlik_no,
               j.rkhskt AS hsp_kapanis_trh,
               (e.eski_sube || e.eski_reftur || e.eski_refsirano) AS devir_oncesi_ref,
               e.updtarih AS devir_trh,
               CAST(NULL AS NUMBER) AS kotasyon_no,
               CAST(NULL AS NUMBER) AS kotasyon_tur,
               'H' devirden_onceki_eski_ref_mi,
               CASE WHEN h.islemtarihi > LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
                         ELSE 'Ýlk'
               END aylik_ilk_bildirim_f
          FROM extr.fs_ithmaster k,
               extr.fs_sube s,
               ofsdata.musteri_master_cs_hist mm,
               extr.fs_ithhrkt h,
                             /*trbac_fct_tmp_11 v, */
               trfm.tmp_trbfc_ana_mus_set m,
               trfm.tmp_trbac_ith_hsp_kpns_trh j,
               trfm.tmp_trbac_dvr_blg e,
               trfm.tmp_ith_dim_rsk_thp_no t
         WHERE 1=1
               AND k.acilistarih>= TO_DATE ('21/07/2003', 'DD/MM/YYYY') --LAST_DAY (ADD_MONTHS (v_tarih, -1))--'01/01/2006'
               AND (k.reftur IN ('LC', 'AL')
                 OR  (k.reftur = 'AC'
                  AND k.aval = 1  AND k.policegiristutar>0))
               AND k.durum IN (7)
               AND k.musteri = mm.musteri_no
               AND k.sube = s.sube
               AND k.sube=h.sube
               AND k.reftur=h.reftur
               AND k.refsirano=h.refsirano
               AND h.kayittip=8
               AND h.durum<>9
               --AND h.islemtarihi >= ADD_MONTHS (v_tarih, -36)+1  --ilk bildirim
               AND LAST_DAY(TO_DATE(h.islemtarihi, 'DD/MM/YYYY')) = v_tarih  --aylýk bildirim
               AND v_tarih = m.kesit_tarihi
               AND v_tarih = mm.tarih
               AND k.musteri = m.musteri_no
                             /*AND k.sube = v.sube (+)
               AND k.reftur = v.reftur (+)
               AND k.refsirano = v.refsirano (+)
               AND v_tarih = v.kst_trh (+)*/
               AND k.sube = j.sube (+)
               AND k.reftur = j.reftur (+)
               AND k.refsirano = j.refsirano (+)
               AND v_tarih = j.kst_trh (+)
               AND k.sube=e.yeni_sube (+)
               --and b.bankakod=e.yeni_banka (+)
               AND k.reftur=e.yeni_reftur (+)
               AND k.refsirano=e.yeni_refsirano (+)
               AND k.acilistarih <= v_tarih
               AND k.sube = t.sube (+)
               AND k.reftur = t.reftur (+)
               AND k.refsirano = t.refsirano (+)
               AND v_tarih = t.kst_trh (+)
               AND h.islemtarihi <> v_tarih
               AND TO_DATE (h.islemtarihi, 'DD/MM/YYYY') >= TO_DATE ('21/07/2003', 'DD/MM/YYYY') --v_gecis_tarihi
               --AND NVL (j.rkhskt, v_tarih) >= ADD_MONTHS (v_tarih, -36)+1 --ilk bildirim.
               AND LAST_DAY(NVL (j.rkhskt, v_tarih)) = v_tarih --aylýk bildirim.

               --v_gecis_tarihi--sonra ayrý dosya gönderilecek
         UNION

        SELECT v_tarih kst_trh,
               'ITH' tip,
               k.sube AS refsube,
               k.reftur,
               k.nitelik AS refnitelik,
               k.refsirano,
               CAST(NULL AS NUMBER) AS kmh_mt_ekno,
               CAST(NULL AS NUMBER) AS kmh_kr_ekno,
               k.musteri musteri_no,
               t.risk_thp_no thp,
               CASE WHEN k.reftur IN ('LC', 'AL') THEN 106
                    WHEN k.reftur IN ('AC') THEN 114
                         END kredi_turu_kod,
               CASE WHEN k.reftur IN ('LC', 'AL') THEN 'Akreditif'
                    WHEN k.reftur IN ('AC') THEN 'Aval/Kabul Kredileri'
                         END kredi_turu_acklm,
               k.para,
               CAST(NULL AS NUMBER) AS kullandirim_doviz_kodu,
               k.acilistarih AS ilk_kullandirim_tarihi,
               k.acilistarih AS son_kullandýrma_tarihi,
               k.acilistutar AS acilis_ilk_kullandirim_tutari ,
                             /*CASE WHEN k.akreditifvade < NVL (v.ld_vadetarihi, TO_DATE('01/01/2003','DD/MM/YYYY')) THEN (NVL (v.ld_vadetarihi, TO_DATE('01/01/2003','DD/MM/YYYY')) - k.acilistarih)
                         ELSE k.akreditifvade - k.acilistarih
                                 END*/
               CASE WHEN k.reftur = 'AC' and k.aval = '1' THEN k.dosyavade ELSE k.akreditifvade END AS vade_tarihi,
               k.lehdarulke AS muhatap_ulke_kodu , --Burhan fonksiyon üzerinde çalýþacak       --get_kkb_ulkelookup2 (ln_ulke_kod,ithmaster_rec.lehdarulke) muhatap_ulke_kodu,
               k.lehdaradi||' '||k.lehdarsoyadi AS muhatap,
               --NULL muhattap_vergi_kimlik_no,
               --NULL muhattap_tc_kimlik_no
               ---fonksiyon kullanýlýyor  Burhan bakacak --bankdb.f_ith_thp_hesap (DECODE (k.reftur, 'AC', 'ITH105', 'ITH102'), k.reftur, k.nitelik, k.teyit, k.aval, k.para, mm.iliski, k.teminatkod, 99, 99, 0, 1) thp,
               NVL (j.rkhskt, j_dvr.devir_max_updtarih) AS hsp_kapanis_trh,
               (e.eski_sube || e.eski_reftur || e.eski_refsirano) AS devir_oncesi_ref,
               e.updtarih AS devir_trh,
               CAST(NULL AS NUMBER) AS kotasyon_no,
               CAST(NULL AS NUMBER) AS kotasyon_tur,
               'H' AS devirden_onceki_eski_ref_mi,
               CASE WHEN e.updtarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)) THEN 'Aylýk'
                    ELSE 'Ýlk'
               END aylik_ilk_bildirim_f
          FROM extr.fs_ithmaster k,
               extr.fs_sube s,
               ofsdata.musteri_master_cs_hist mm,
               trfm.tmp_trbac_dvr_blg e,
                             /*extr.fs_banka b, trbac_fct_tmp_11 v, */
               trfm.tmp_trbfc_ana_mus_set m,
               trfm.tmp_trbac_ith_hsp_kpns_trh j,
               trfm.tmp_ith_dim_rsk_thp_no t,
               trfm.tmp_trbac_ith_dvr_hsp_kpns_trh j_dvr
         WHERE k.acilistarih>= TO_DATE ('21/07/2003', 'DD/MM/YYYY')--LAST_DAY (ADD_MONTHS (v_tarih, -1))
               AND (k.reftur IN ('LC', 'AL')
               OR  (k.reftur = 'AC'
               AND k.aval = 1  and k.policegiristutar>0))
               AND k.durum IN (10)
               AND k.musteri = mm.musteri_no
               AND mm.tarih = v_tarih
               AND k.sube = s.sube
               and k.sube=e.yeni_sube (+)
               --and b.bankakod=e.yeni_banka (+)
               and k.reftur=e.yeni_reftur (+)
               and k.refsirano=e.yeni_refsirano (+)
               --v_gecis_tarihi--sonra ayrý dosya gönderilecek                                                                               "
                             /*AND k.sube = v.sube (+)
               AND k.reftur = v.reftur (+)
               AND k.refsirano = v.refsirano (+)
               AND v_tarih = v.kst_trh (+)*/
               AND v_tarih = m.kesit_tarihi
               AND k.musteri = m.musteri_no
               AND k.sube = j.sube (+)
               AND k.reftur = j.reftur (+)
               AND k.refsirano = j.refsirano (+)
               AND k.sube = j_dvr.refsube (+)
               AND k.reftur = j_dvr.reftur (+)
               AND k.refsirano = j_dvr.refsirano (+)
               AND k.acilistarih <= v_tarih
               AND v_tarih = j_dvr.kst_trh (+)
               AND v_tarih = j.kst_trh (+)
               AND k.sube = t.sube (+)
               AND k.reftur = t.reftur (+)
               AND k.refsirano = t.refsirano (+)
               AND v_tarih = t.kst_trh (+)              -- Not: fonksiyonlu olanlar insert edimedi
               --AND NVL (NVL (j.rkhskt, j_dvr.devir_max_updtarih), v_tarih) >= ADD_MONTHS (v_tarih, -36)+1  --ilk bildirim.
               AND LAST_DAY(COALESCE (j.rkhskt, j_dvr.devir_max_updtarih, v_tarih)) = v_tarih  --aylýk bildirim.
      );

      COMMIT;
      v_line_no:=900;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_fct_01
  SELECT g.kst_trh, 'GVNC' AS tip, g.ana_sube AS refsube, NULL reftur, NULL refnitelik, tps_odeme_emri_id refsirano, NULL kmh_mt_ekno, NULL kmh_kr_ekno, g.musteri_no,
         g.thp_no, 104 kredi_turu_kod, 'DBS_Gayrinakit' kredi_turu_acklm, g.para, NULL kullandirim_doviz_kodu, g.ilk_kullandirim_trh ilk_kullandirim_tarihi,
         g.son_kullandirim_trh son_kullandirma_tarihi, NULL acilis_ilk_kullandirim_tutari, g.odeme_vade_tarihi vade_tarihi, NULL muhatap_ulke_kodu,
         NULL muhatap, g.hsp_kapanis_trh hsp_kapanis_trh, NULL devir_oncesi_ref, NULL devir_trh, NULL kotasyon_no, NULL kotasyon_tur,
         'H' devirden_onceki_eski_ref_mi, g.aylik_ilk_bildirim_f,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_gvnc_odm_emir g
         INNER JOIN trfm.tmp_trbfc_ana_mus_set m
                    ON 1 = 1
                    AND g.kst_trh = m.kesit_tarihi
                    AND g.musteri_no = m.musteri_no
   WHERE 1 = 1
     AND g.kst_trh = v_tarih
     --AND NVL (g.hsp_kapanis_trh, v_tarih) >= ADD_MONTHS (v_tarih, -36)+1    --ilk bildirim.
     AND LAST_DAY(NVL(g.hsp_kapanis_trh, v_tarih)) = v_tarih    --aylýk bildirim.
         ;
COMMIT;
      v_line_no:=905;

--MEMZUC 151 ve 152 Riskkodlarý
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_fct_01
  SELECT m.kst_trh, 'MMZC' tip, sube refsube, hestur reftur, CAST(NULL AS VARCHAR2(2 BYTE)) AS refnitelik, ekno AS refsirano, CAST(NULL AS NUMBER) AS kmh_mt_ekno, CAST(NULL AS NUMBER) AS kmh_kr_ekno,
         m.ilk7 AS musteri_no, 9610200 AS thp_no, 112 AS  kredi_turu_kod, 'Harici Garantiler' kredi_turu_acklm, m.para, CAST(NULL AS NUMBER)  AS kullandirim_doviz_kodu, m.actarih ilk_kullandirim_tarihi,
         m.actarih son_kullandirma_tarihi, CAST(NULL AS NUMBER) acilis_ilk_kullandirim_tutari, m.vade vade_tarihi, NULL muhatap_ulke_kodu,
         NULL muhatap, NULL hsp_kapanis_trh, NULL devir_oncesi_ref, NULL devir_trh, NULL kotasyon_no, NULL kotasyon_tur,
         'H' devirden_onceki_eski_ref_mi, 'Ýlk' aylik_ilk_bildirim_f,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_memzuc_151_152 m
   WHERE 1 = 1
     AND m.kst_trh = v_tarih;

      COMMIT;
      v_line_no:=910;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_DNM_SON_GCKME',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=915;

   INSERT               /*+ APPEND */ INTO  trfm.tmp_trbac_kmh_dnm_son_gckme
   SELECT tarih, ilk7, sube, sinif, mt_ekno, kt_ekno, gecikme_gun,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM extr.fs_tuzel_kmh_musteri_gecikme
    WHERE 1=1
          AND tarih = v_tarih
          AND sondurum NOT IN (0, 5, 9);

      COMMIT;

      v_line_no:=920;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_DNM_ICI_GCKME',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=925;

      INSERT               /*+ APPEND */ INTO  trfm.tmp_trbac_kmh_dnm_ici_gckme
      SELECT v_tarih AS kst_trh, ilk7, sube, sinif, mt_ekno, kt_ekno, MAX(gecikme_gun) AS max_gecikme_gun,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM extr.fs_tuzel_kmh_musteri_gecikme
       WHERE 1=1
             AND tarih BETWEEN TRUNC(v_tarih,'MM') AND v_tarih
             AND sondurum NOT IN (0, 5, 9)
    GROUP BY ilk7, sube, sinif, mt_ekno, kt_ekno;

      COMMIT;

      v_line_no:=930;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_DNM_IC_SON_GCKM',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=935;
      --tkrd  Dönem Sonu Gecikme Gün Sayýsý

      INSERT               /*+ APPEND */ INTO  trfm.tmp_trbac_tkrd_dnm_ic_son_gckm
  SELECT v_tarih kst_trh,
         'TKRD' AS tip,
         a.sube,
         a.reftur,
         a.refsirano,
         a.donem_sonu_gecikme,
         b.donemici_enbuyuk_gecikme,
         a.musteri,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (  SELECT v_tarih AS kst_trh, sube, reftur, refsirano,
                   MAX (tarih) - MAX (vadetarih) + 1 AS donem_sonu_gecikme, musteri
              FROM extr.fs_tkrd_gecikme_bilgi
             WHERE 1 = 1
                   AND tarih = v_tarih
          GROUP BY sube, reftur, refsirano, musteri
         ) a
         INNER JOIN (
                       SELECT v_tarih AS kst_trh, sube, reftur, refsirano,
                              MAX (tarih - vadetarih) + 1 AS donemici_enbuyuk_gecikme, musteri
                         FROM extr.fs_tkrd_gecikme_bilgi
                        WHERE 1 = 1
                              and LAST_DAY (tarih) = v_tarih
                     GROUP BY sube, reftur, refsirano, musteri
                    ) b
                    ON     1 = 1
                       and a.kst_trh = b.kst_trh
                       and a.sube = b.sube
                       and a.reftur = b.reftur
                       and a.refsirano = b.refsirano
                       and a.musteri = b.musteri

   WHERE 1 = 1
     AND a.kst_trh = v_tarih;

      COMMIT;

      v_line_no:=940;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_NKRD_DNM_SON_GCKME',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=945;

   ---nkrd--donem_sonu_gecikme

      INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_nkrd_dnm_son_gckme
     SELECT kst_trh, 'NKRD' AS tip,sube,reftur,refsirano,MAX(donem_sonu_gecikme) AS donem_sonu_gecikme,musteri,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih AS kst_trh,'NKRD_Q1' AS tip,sube,reftur,refsirano,
                      NVL(MAX(tarih - vade + 1),0) AS donem_sonu_gecikme,musteri
                 FROM extr.fs_kredi_bilgi
                WHERE 1=1
                      AND kullanimtutar - geriodenen > 0
                      AND vade < tarih
                      AND tarih = v_tarih
             GROUP BY sube,reftur,refsirano,musteri
           UNION ALL
               SELECT v_tarih AS kst_trh,'NKRD_Q2' AS tip,sube,reftur,refsirano,
                      NVL(MAX(tarih - odeme_tarihi) + 1,0) AS donem_sonu_gecikme,musteri
                 FROM extr.fs_krd_ana_para_odeme
                WHERE 1 = 1
                      AND odeme_tarihi < tarih
                      AND tarih = v_tarih
             GROUP BY sube,reftur,refsirano,musteri
           UNION ALL
               SELECT v_tarih AS kst_trh,'NKRD_Q3' AS tip,sube,reftur,refsirano,
                      NVL(MAX (tarih - tahakkuk_tarih) + 1,0) AS donem_sonu_gecikme,musteri
                 FROM extr.fs_krd_tahakkuk_tahsilat
                WHERE 1=1
                      AND tahakkuk_tarih < tarih
                      AND tarih = v_tarih
             GROUP BY sube,reftur,refsirano,musteri
            )
   GROUP BY kst_trh, sube ,reftur,refsirano,musteri;

      COMMIT;

      v_line_no:=950;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_NKRD_DNM_ICI_GCKME',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=955;
 ---nkrd--donemici_enbuyuk_gecikme

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_nkrd_dnm_ici_gckme
     SELECT kst_trh, 'NKRD' AS tip,sube ,reftur,refsirano, MAX(donemici_enbuyuk_gecikme) AS donemici_enbuyuk_gecikme,musteri,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
                SELECT v_tarih AS kst_trh,'NKRD_Q1' tip,sube,reftur,refsirano ,NVL(MAX(tarih - vade + 1),0) AS  donemici_enbuyuk_gecikme,musteri
                  FROM extr.fs_kredi_bilgi
                 WHERE 1=1
                       AND kullanimtutar - geriodenen > 0
                       AND vade < tarih
                       AND  LAST_DAY (tarih) = v_tarih
              GROUP BY sube ,reftur,refsirano,musteri
            UNION ALL
                SELECT v_tarih AS kst_trh,'NKRD_Q2' tip,sube,reftur,refsirano ,NVL(MAX(tarih - odeme_tarihi) + 1,0) AS donemici_enbuyuk_gecikme,musteri
                  FROM extr.fs_krd_ana_para_odeme
                 WHERE 1=1
                       AND odeme_tarihi < tarih
                       AND  LAST_DAY (tarih) = v_tarih
              GROUP BY sube ,reftur,refsirano,musteri
            UNION ALL
                SELECT v_tarih AS kst_trh,'NKRD_Q3' tip,sube,reftur,refsirano , NVL(MAX (tarih - tahakkuk_tarih) + 1,0) AS donemici_enbuyuk_gecikme,musteri
                  FROM extr.fs_krd_tahakkuk_tahsilat
                 WHERE 1=1
                       AND tahakkuk_tarih < tarih
                       AND LAST_DAY (tarih) = v_tarih
              GROUP BY sube ,reftur,refsirano,musteri
            )
   GROUP BY kst_trh,sube ,reftur,refsirano,musteri;

      COMMIT;

      v_line_no:=960;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TMEK_DNM_SON_GCKME',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=965;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tmek_dnm_son_gckme
     SELECT tarih AS kst_trh,
            'TMEK' AS tip,
            refsube,
            reftur,
            refsirano,
            MAX(tarih-sonkomtahtarih) +1 AS donem_sonu_gecikme,
            musteri,
            devkomtutar,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_temmek_odenmeyen_komisyon     ---OFSDATA.TEMMEK_ODENMEYEN_KOMISYON  ---extr ye alýnacak
      WHERE tarih = v_tarih
            AND durum = 2
   GROUP BY tarih,refsube,reftur,refsirano,musteri,devkomtutar;

      COMMIT;

      v_line_no:=970;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TMEK_DNM_IC_GCKME',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=975;
   ----------tmek--donemici_enbuyuk_gecikme

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tmek_dnm_ic_gckme
     SELECT v_tarih AS kst_trh,
            'TMEK' AS tip,
            refsube,
            reftur,
            refsirano,
            MAX(tarih-sonkomtahtarih) +1 AS donemici_enbuyuk_gecikme,
            musteri,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_temmek_odenmeyen_komisyon -----extr ye alýnacak
      WHERE LAST_DAY (tarih) = v_tarih
            AND durum = 2
   GROUP BY refsube, reftur, refsirano, musteri;

      COMMIT;

      v_line_no:=980;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR1_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=985;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar1_01
   SELECT v_tarih AS kst_trh,
          b.sube refsube,
          b.reftur,
          b.refsirano,
          b.musteri musteri_no,
          b.kreditutar,
          b.odenentutar,
          b.musteri,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ b,
          extr.fs_sube s,
          extr.fs_gunluk_hplandet_sg h,
          (  SELECT sube,reftur,refsirano ,MAX (vadetarih) vade
               FROM extr.fs_bkrhrkt
              WHERE TO_DATE (odemetarih, 'DD/MM/YYYY') <= v_tarih
                    AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
           GROUP BY sube,reftur,refsirano
          ) bh
    WHERE (   (b.durum IN (3, 93))
               OR (    b.durum IN (6, 7, 8, 9, 10, 11, 98)
                       AND b.kapanistarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)) )--pd_onceki_rapor_tarih)               /*or (b.durum in(6,7,8,9,10,11,98) and b.updprogram in('DEVR99','DEVR30'))*/
                   OR (    b.durum IN (6)
                       AND b.kapanistarih > TO_DATE ('01/01/2005', 'dd/mm/yyyy')))
           AND b.sube = s.sube
           AND b.reftur IN ('TT', 'TD')
           AND b.musteri = h.ilk7
           AND b.krdhestur = h.hestur
           AND b.krdekno = h.ekno
           AND h.sube = b.sube
           AND H.SINIF= 'C'
           AND h.durum = 0
           AND  B.SUBE = BH.SUBE
           AND B.REFTUR = BH.REFTUR
           AND B.REFSIRANO = BH.REFSIRANO
           AND v_tarih = h.tarih;

      COMMIT;

      v_line_no:=990;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR1_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=995;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar1_02
    SELECT DISTINCT
           v_tarih AS kst_trh,
           t.refsube AS refsube,
           t.reftur,
           t.refsirano,
           t.musteri AS musteri_no,
           t.tutar,
           t.cikistutar,
           SYSDATE AS etl_trh,
           v_sp_name AS etl_job
           --NULL muhattap_vergi_kimlik_no,
           --NULL muhattap_tc_kimlik_no
      FROM extr.fs_temmekmas t,
           extr.fs_sube s,
           extr.fs_gunluk_hplandet_sg h,
           extr.fs_temmekhrkt hk
     WHERE 1=1
           AND t.refsube = s.sube
           AND t.refsube = h.sube
           AND t.musteri = h.ilk7
           AND t.refsube = hk.refsube
           AND t.reftur = hk.reftur
           AND t.refsirano = hk.refsirano
           AND v_tarih = h.tarih
           AND h.hestur = 'TA'
           AND t.taekno = h.ekno
           AND h.sinif = 'C'
           AND h.durum = 0
           AND (   (t.durum = 2)
                OR (    t.durum IN (3, 4)
                    AND (    hk.hrkttur IN (4, 6)
                         AND hk.durum <> 9
                         AND hk.fistarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)))
                OR (    t.durum IN (3, 4)
                    AND (    hk.hrkttur IN (4, 6)
                         AND hk.durum <> 9
                         AND t.updprogram = 'TEMUPD')))
           AND t.mektupbas IS NULL)
           AND hk.fistarih <= v_tarih;

      COMMIT;

      v_line_no:=1000;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR1_03',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1005;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar1_03
  SELECT v_tarih AS kst_trh,
         t.sube AS refsube,
         t.kmhhestur AS reftur,
         t.kmhekno AS refsirano,
         t.kmhilk7 AS musteri_no,---- fonksiyondaki kolonlar eklenecek
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_sube s,
         ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t,
         extr.fs_gunluk_hplandet_sg h
   WHERE 1=1
         AND t.sube = s.sube
         AND t.sube = h.sube
         AND t.kmhilk7 = h.ilk7
         AND h.hestur = 'KT'
         AND t.krdekno = h.ekno
         AND t.krdekno != 0
         AND h.sinif = 'C'
         AND h.durum = 0
         AND t.tip IN (21, 22, 25, 26, 27, 28)
         AND v_tarih = h.tarih;

      COMMIT;

      v_line_no:=1010;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR1_04',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1015;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar1_04
   SELECT v_tarih AS kst_trh,
          k.sube AS refsube,
          k.reftur,
          k.refsirano,
          k.musteri AS musteri_no,
          k.durum,
          k.acilistutar,
          k.faiz,
          k.opsiyontutar,
          k.transfertutar,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM extr.fs_ithmaster k,
          extr.fs_sube s ,
          ofsdata.musteri_master_cs_hist mm
    WHERE k.acilistarih >=  LAST_DAY (ADD_MONTHS (v_tarih, -1))
          AND (k.reftur IN ('LC', 'AL') OR (k.reftur = 'AC' AND k.aval = 1 and k.policegiristutar>0))
          AND k.durum NOT IN (7, 9, 11, 10)
          AND k.musteri = mm.musteri_no
          AND mm.tarih = v_tarih
          AND k.sube = s.sube
 UNION ALL
   SELECT v_tarih kst_trh,
          k.sube refsube,
          k.reftur,
          k.refsirano,
          k.musteri AS musteri_no,
          k.durum,
          k.acilistutar,
          k.faiz,
          k.opsiyontutar,
          k.transfertutar,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM extr.fs_ithmaster k,
          extr.fs_sube s,
          ofsdata.musteri_master_cs_hist mm,
          extr.fs_ithhrkt h
    WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))--'01/01/2006'
          AND (k.reftur IN ('LC', 'AL')
                 OR  (k.reftur = 'AC'
                  AND k.aval = 1  and k.policegiristutar>0))
          AND k.durum IN (7)
          AND k.musteri = mm.musteri_no
          AND mm.tarih = v_tarih
          AND k.sube = s.sube
          AND k.sube=h.sube
          AND k.reftur=h.reftur
          AND k.refsirano=h.refsirano
          AND h.kayittip=8
          AND h.durum<>9
          AND h.islemtarihi <= v_tarih
          and h.islemtarihi>=LAST_DAY (ADD_MONTHS (v_tarih, -1))
               --v_gecis_tarihi--sonra ayrý dosya gönderilecek
 UNION ALL
   SELECT v_tarih kst_trh,
          k.sube refsube,
          k.reftur,
          k.refsirano,
          k.musteri musteri_no,
          k.durum,
          k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM extr.fs_ithmaster k,
          extr.fs_sube s,
          ofsdata.musteri_master_cs_hist mm,
          extr.fs_eskiyenireferans e,
          extr.fs_banka b
    WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))
          AND (   k.reftur IN ('LC', 'AL')
               OR (    k.reftur = 'AC'
                   AND k.aval = 1
                   AND k.policegiristutar>0)
              )
          AND k.durum IN (10)
          AND k.musteri = mm.musteri_no
          AND mm.tarih = v_tarih
          AND k.sube = s.sube
          AND s.sube=e.eski_sube
          AND b.bankakod=e.eski_banka
          AND k.sube=e.eski_sube
          AND k.reftur=e.eski_reftur
          AND k.refsirano=e.eski_refsirano
          and e.updtarih>=LAST_DAY (ADD_MONTHS (v_tarih, -1));

      COMMIT;

      v_line_no:=1020;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR1',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1025;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar1
 SELECT kst_trh, tip, refsube, reftur, refsirano, musteri_no, tutar1,
        SYSDATE AS etl_trh,
        v_sp_name AS etl_job
  FROM  (
         SELECT a.kst_trh,
                a.tip,
                a.refsube,
                a.reftur,
                a.refsirano,
                a.musteri_no,
                  NVL (c.kreditutar, 0) - NVL (c.odenentutar, 0)
                + -- DECODE((NVL(x.tahakkuk,0)-NVL(x.tahsilat,0)<0,  )
                  NVL (x.kullanimtutar, 0) - NVL (x.geriodenen, 0)--,
                  + (NVL (z.tutar, 0) - NVL (z.cikistutar, 0))
                + 0 --- (retval.RKTU02 := get_anapara_riski(kmh_rec.sube,kmh_rec.kmhilk7,kmh_rec.krdekno,kmh_rec.hestur,                  /*TO_DATE('27/05/2014','dd/mm/yyyy')*/TRUNC(RAPORTARIH-1));--16.05.2014*EG--gunluk_hpplandet_sg için -2 olodu ++
                + CASE
                      WHEN r.durum IN (7, 10)
                      THEN
                          0
                      WHEN r.durum = 0
                      THEN
                            NVL (r.acilistutar, 0)
                          + NVL (r.faiz, 0)
                          + NVL (r.opsiyontutar, 0)
                          - NVL (r.transfertutar, 0)
                      ELSE
                          0
                  END
                    AS tutar1
           FROM trfm.tmp_trbac_fct_01 a
                LEFT JOIN prsn.kkb_trbfc_trbic_fct b
                    ON     1 = 1
                       AND a.kst_trh = b.kesit_tarihi
                       AND a.musteri_no = b.musteri_no
                LEFT JOIN trfm.tmp_trbac_tutar1_01 c
                    ON     1 = 1
                       AND a.kst_trh = c.kst_trh
                       AND a.refsube = c.refsube
                       AND a.reftur = c.reftur
                       AND a.refsirano = c.refsirano
                       AND a.musteri_no = c.musteri_no
                LEFT JOIN ofsdata.krdmaster_aysonu              /*extr.fs_krdmaster tablosu proda atýlacak*/ x
                    ON     1 = 1
                       AND a.kst_trh = v_tarih
                       AND a.refsube = x.sube
                       AND a.reftur = x.reftur
                       AND a.refsirano = x.refsirano
                       and a.musteri_no =x.musteri ----sorulacak
                LEFT JOIN trfm.tmp_trbac_tutar1_02 z
                    ON     1 = 1
                       AND a.kst_trh = z.kst_trh
                       AND a.refsube = z.refsube
                       AND a.reftur = z.reftur
                       AND a.refsirano = z.refsirano
                       AND a.musteri_no = z.musteri_no
                LEFT JOIN trfm.tmp_trbac_tutar1_03 y
                    ON     1 = 1
                       AND a.kst_trh = y.kst_trh
                       AND a.refsube = y.refsube
                       AND a.reftur = y.reftur
                       AND a.refsirano = y.refsirano
                       AND a.musteri_no = y.musteri_no
                LEFT JOIN trfm.tmp_trbac_tutar1_04 r
                       --v_gecis_tarihi--sonra ayrý dosya gönderilecek
                   ON     1 = 1
                      AND a.kst_trh = r.kst_trh
                      AND a.refsube = r.refsube
                      AND a.reftur = r.reftur
                      AND a.refsirano = r.refsirano
                      AND a.musteri_no = r.musteri_no
        )
  WHERE 1=1
        AND tutar1<>0;

      COMMIT;

      v_line_no:=1030;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_DIGER_TUTAR1_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1035;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_diger_tutar1_01
     SELECT v_tarih AS kst_trh,
            k.sube AS refsube,
            k.reftur,
            k.refsirano,
            k.musteri AS musteri_no,
            k.durum,
            k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_ithmaster k,
            extr.fs_sube s,
            ofsdata.musteri_master_cs_hist mm
      WHERE 1=1
            AND k.acilistarih >=  LAST_DAY (ADD_MONTHS (v_tarih, -1))
            AND (k.reftur IN ('LC', 'AL') OR (k.reftur = 'AC' AND k.aval = 1 and k.policegiristutar>0))
            AND  k.durum NOT IN (7, 9, 11, 10)
            AND  k.musteri = mm.musteri_no
            AND mm.tarih = v_tarih
            AND k.sube = s.sube
   UNION ALL
     SELECT v_tarih kst_trh,
            k.sube refsube,
            k.reftur,
            k.refsirano,
            k.musteri musteri_no,
            k.durum,
            k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_ithmaster k,
            extr.fs_sube s,
            ofsdata.musteri_master_cs_hist mm,
            extr.fs_ithhrkt h
      WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))--'01/01/2006'
            AND (k.reftur IN ('LC', 'AL')
              OR  (k.reftur = 'AC'
               AND k.aval = 1  and k.policegiristutar>0))
            AND k.durum IN (7)
            AND k.musteri = mm.musteri_no
            AND mm.tarih = v_tarih
            AND k.sube = s.sube
            AND k.sube=h.sube
            AND k.reftur=h.reftur
            AND k.refsirano=h.refsirano
            AND h.kayittip=8
            AND h.durum<>9
            AND h.islemtarihi>=LAST_DAY (ADD_MONTHS (v_tarih, -1))
            AND h.islemtarihi <= v_tarih
                  --v_gecis_tarihi--sonra ayrý dosya gönderilecek
   UNION ALL
     SELECT
            v_tarih kst_trh,
            k.sube refsube,
            k.reftur,
            k.refsirano,
            k.musteri musteri_no,
            k.durum,
            k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_ithmaster k,
            extr.fs_sube s,
            ofsdata.musteri_master_cs_hist mm,
            extr.fs_eskiyenireferans e,
            extr.fs_banka b
      WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))
            AND (k.reftur IN ('LC', 'AL')
                  OR  (k.reftur = 'AC'
                  AND k.aval = 1  and k.policegiristutar>0)
                )
            AND k.durum IN (10)
            AND k.musteri = mm.musteri_no
            AND mm.tarih = v_tarih
            AND k.sube = s.sube
            and s.sube=e.eski_sube
            and b.bankakod=e.eski_banka
            and k.sube=e.eski_sube
            and k.reftur=e.eski_reftur
            and k.refsirano=e.eski_refsirano
            and e.updtarih >= LAST_DAY (ADD_MONTHS (v_tarih, -1));

      COMMIT;

      v_line_no:=1040;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_DIGER_TUTAR1',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1045;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_diger_tutar1
   SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no, t.tutar1,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM (
           SELECT a.kst_trh, a.refsube, a.reftur, a.refsirano, a.musteri_no,
                  NVL(c.anapara,0)
                  -- DECODE((NVL(x.tahakkuk,0)-NVL(x.tahsilat,0)<0,  )
                                /*CASE WHEN NVL(x.tahakkuk,0)- (NVL(x.tahsilat,0)+NVL(faizkomisyon,0) +NVL(gecikme,0))<0 THEN NVL(x.kullanimtutar,0)-NVL(x.geriodenen,0)
                       WHEN   NVL(x.tahakkuk,0)- (NVL(x.tahsilat,0)+NVL(faizkomisyon,0) +NVL(gecikme,0))>=0 THEN     (NVL(x.kullanimtutar,0)-NVL(x.geriodenen,0)) + (NVL(x.tahakkuk,0)-(NVL(x.tahsilat,0)+NVL(x.faizkomisyon,0) +NVL(x.gecikme,0)))  ELSE 0 END*/
                  + NVL (x.kullanimtutar, 0) - NVL (x.geriodenen, 0)
                  + (NVL(z.tutar,0)-NVL(z.cikistutar,0))
                  + 0 --- (retval.RKTU02 := get_anapara_riski(kmh_rec.sube,kmh_rec.kmhilk7,kmh_rec.krdekno,kmh_rec.hestur,                  /*TO_DATE('27/05/2014','dd/mm/yyyy')*/TRUNC(RAPORTARIH-1));--16.05.2014*EG--gunluk_hpplandet_sg için -2 oldu ++ retval.RKTU20 := get_odenmeyenkredi_tutari(kmh_rec.sube,kmh_rec.kmhilk7,kmh_rec.krdekno);--16.05.2014*EG)
                  +
                  CASE WHEN r.durum IN (7,10 ) THEN 0
                       WHEN r.durum=0 THEN NVL(r.acilistutar,0) + NVL(r.faiz,0) + NVL(r.opsiyontutar,0) - NVL(r.transfertutar,0)
                            ELSE 0
                  END AS tutar1
             FROM trfm.tmp_trbac_fct_01 a
                  LEFT JOIN prsn.kkb_trbfc_trbic_fct b ON  1 = 1
                                               AND a.kst_trh = b.kesit_tarihi
                                               AND a.musteri_no = b.musteri_no
                  LEFT JOIN (
                               SELECT v_tarih kst_trh,  ----faiz ve komisyon eklenmeli mi ? ediz
                                      sube, reftur, refsirano,
                                      SUM (NVL (anapara, 0)) anapara
                                 FROM extr.fs_bkrhrkt
                                WHERE 1 = 1
                                      AND reftur IN ('TT', 'TD')
                                      AND durum = 0
                                      AND odemetarih <= v_tarih
                                      AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
                             GROUP BY sube, reftur, refsirano
                            ) c ON 1 = 1
                               AND a.kst_trh = c.kst_trh
                               AND a.refsube = c.sube
                               AND a.reftur = c.reftur
                               AND a.refsirano = c.refsirano
                  LEFT JOIN (
                               SELECT v_tarih kesit_tarihi,k.sube,k.reftur,k.refsirano,h.tahakkuk ,t.tahsilat,t.faizkomisyon,t.gecikme,k.kullanimtutar,k.geriodenen
                                 FROM ofsdata.krdmaster_aysonu              /*extr.fs_krdmaster tablosu proda atýlacak*/ k
                                      LEFT JOIN (
                                                   SELECT sube,reftur,refsirano,
                                                          NVL (TRUNC (SUM (NVL (bsmv, 0))
                                                                    + SUM (NVL (kkdf, 0))
                                                                    + SUM (NVL (faiz, 0))
                                                                    + SUM (NVL (komisyon1, 0))
                                                                    + SUM (NVL (komisyonbsmv1, 0))
                                                                    + SUM (NVL (komisyon2, 0))
                                                                    + SUM (NVL (komisyonbsmv2, 0))
                                                                    + SUM (NVL (bsmvozel, 0))), 0)
                                                          tahakkuk
                                                     FROM extr.fs_reftahakkuk
                                                    WHERE 1=1
                                                          --   AND tarih > cd_gecis_tarihi  -----cd_gecis_tarihi nedir,ediz e sorulacak
                                                          AND tarih <= v_tarih
                                                 GROUP BY sube,reftur,refsirano
                                                ) h
                                                ON     1=1
                                                   and k.sube=h.sube
                                                   and k.reftur =h.reftur
                                                   and k.refsirano =h.refsirano
                                      LEFT JOIN (
                                                   SELECT sube,reftur,refsirano,
                                                          NVL (TRUNC (SUM (NVL (t.faiz, 0))
                                                                      + SUM (NVL (t.faiz_bsmv, 0))
                                                                      + SUM (NVL (t.faiz_kkdf, 0))
                                                                      + SUM (NVL (t.kom1, 0))
                                                                      + SUM (NVL (t.kom1_bsmv, 0))
                                                                      + SUM (NVL (t.kom2, 0))
                                                                      + SUM (NVL (t.kom2_bsmv, 0))
                                                                      + SUM (NVL (t.bsmvozel, 0))), 0) AS tahsilat,
                                                          NVL (TRUNC (SUM (NVL (t.faiz, 0)) + SUM (NVL (t.kom1, 0)) + SUM (NVL (t.gecikme, 0))), 0) AS faizkomisyon,
                                                          NVL (TRUNC (SUM (NVL (t.gecikme, 0)) + SUM (NVL (t.gecikme_bsmv, 0)) + SUM (NVL (t.gecikme_kkdf, 0))), 0) AS gecikme
                                                     FROM extr.fs_krd_tahsilat_detay t
                                                    WHERE      t.durum = 0
                                                          ---- AND t.fistarih > cd_gecis_tarihi) ---edize sorulacak
                                                      AND fistarih <= v_tarih
                                                 GROUP BY sube,reftur,refsirano
                                                )t
                                                ON 1=1
                                                   and k.sube=t.sube
                                                   and k.reftur =t.reftur
                                                   and k.refsirano =t.refsirano
                            ) x ON  1=1
                                AND a.kst_trh=x.kesit_tarihi
                                AND a.refsube = x.sube
                                AND a.reftur = x.reftur
                                AND a.refsirano = x.refsirano
                  LEFT JOIN (
                             SELECT DISTINCT
                                    v_tarih AS kst_trh,
                                    t.refsube refsube,
                                    t.reftur,
                                    t.refsirano,
                                    t.musteri musteri_no,
                                    t.tutar,
                                    t.cikistutar
                                    --NULL muhattap_vergi_kimlik_no,
                                    --NULL muhattap_tc_kimlik_no
                               FROM extr.fs_temmekmas t,
                                    extr.fs_sube s,
                                    extr.fs_gunluk_hplandet_sg h,
                                    extr.fs_temmekhrkt hk
                              WHERE 1=1
                                    AND t.refsube = s.sube
                                    AND t.refsube = h.sube
                                    AND t.musteri = h.ilk7
                                    AND v_tarih = h.tarih
                                    AND t.refsube = hk.refsube
                                    AND t.reftur = hk.reftur
                                    AND t.refsirano = hk.refsirano
                                    AND h.hestur = 'TA'
                                    AND t.taekno = h.ekno
                                    AND h.sinif = 'C'
                                    AND h.durum = 0
                                    AND hk.fistarih <= v_tarih
                                    AND (   (t.durum = 2)
                                        OR (    t.durum IN (3, 4)
                                            AND (    hk.hrkttur IN (4, 6)
                                                 AND hk.durum <> 9
                                                 AND hk.fistarih > LAST_DAY (ADD_MONTHS (v_tarih, -1)))
                                        OR (    t.durum IN (3, 4)
                                            AND (    hk.hrkttur IN (4, 6)
                                                 AND hk.durum <> 9
                                                 AND t.updprogram = 'TEMUPD')))
                                   AND t.mektupbas IS NULL)
                            ) z ON  1=1
                                AND a.kst_trh = z.kst_trh
                                AND a.refsube = z.refsube
                                AND a.reftur = z.reftur
                                AND a.refsirano = z.refsirano
                  LEFT JOIN ( SELECT v_tarih kst_trh,
                                     t.sube refsube,
                                     t.kmhhestur reftur,
                                     t.kmhekno   refsirano,
                                     t.kmhilk7  musteri_no ---- fonksiyondaki kolonlar eklenecek
                                FROM extr.fs_sube s,
                                     ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t ,
                                     extr.fs_gunluk_hplandet_sg h
                               WHERE 1=1
                                     AND t.sube = s.sube
                                     AND t.sube = h.sube
                                     AND t.kmhilk7 = h.ilk7
                                     AND h.hestur = 'KT'
                                     AND t.krdekno = h.ekno
                                     AND v_tarih = h.tarih
                                     AND t.krdekno != 0
                                     AND h.sinif = 'C'
                                     AND h.durum = 0
                                     AND t.tip IN (21, 22, 25, 26, 27, 28)
                            ) y ON 1=1
                                AND a.kst_trh=y.kst_trh
                                AND a.refsube = y.refsube
                                AND a.reftur = y.reftur
                                AND a.refsirano = y.refsirano
                                AND A.musteri_no=y.musteri_no
                  LEFT JOIN trfm.tmp_trbac_diger_tutar1_01 r
                               --v_gecis_tarihi--sonra ayrý dosya gönderilecek
                               ON 1=1
                            AND a.kst_trh=r.kst_trh
                            AND a.refsube = r.refsube
                            AND a.reftur = r.reftur
                            AND a.refsirano = r.refsirano
          ) t
    WHERE 1=1
          and t.tutar1<>0;

      COMMIT;

      v_line_no:=1050;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR2_RESKNT',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1055;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar2_resknt
  SELECT rd.tarih,
         DECODE (rd.hesaptur,
                              14,  'NKRD',
                              16,  'TKRD',
                              130, 'KMH'
                                         ) AS tip,
         rd.hesaptur, rd.sube, rd.sinif, rd.ilk7, rd.hestur, rd.ekno, rd.para,
         rd.duzgunfaiz,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_reeskont_detay rd
   WHERE 1 = 1
     AND rd.tarih = v_tarih
     AND rd.hesaptur IN (14, 16, 130)
     AND rd.durum = 0
     AND rd.duzgunfaiz <> 0;

      COMMIT;

      v_line_no:=1060;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1065;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_01
                /*SELECT v_tarih kst_trh,  ----faiz ve komisyon eklenmeli mi ? ediz
           sube, reftur, refsirano,
           SUM (NVL (anapara, 0)) anapara,
           SUM (b.faiz) faiz

      FROM extr.fs_bkrhrkt b
     WHERE 1 = 1
       AND reftur IN ('TT', 'TD')
       AND durum = 0
       AND odemetarih <= v_tarih
       AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
  GROUP BY sube, reftur, refsirano;*/
 SELECT v_tarih AS kst_trh,
        CASE WHEN t.katkipayi_ilk7! = m.musteri THEN 0 --TRUNC(SUM(NVL (komisyon, 0)))
             ELSE NVL(TRUNC(m.aciliskomisyon),0)
        END AS ln_rktu01_acilis_kom, --rktu21 tutar21
        t.katkipayi_vade, t.sube, t.reftur, t.refsirano, m.musteri,
        SYSDATE AS etl_trh,
        v_sp_name AS etl_job
   FROM extr.fs_tkrd_detay t
        INNER JOIN ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ m
                   ON t.sube = m.sube
                   AND t.reftur = m.reftur
                   AND t.refsirano = m.refsirano
   WHERE 1 = 1
        --AND t.sube = 305 AND t.reftur = 'TT' AND t.refsirano = 5
        AND t.katkipayi_vade <= v_tarih
        AND t.katkipayi_tahsiltarih IS NULL;

      COMMIT;

      v_line_no:=1070;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('tmp_trbac_tutar3_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1075;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_02
   SELECT v_tarih AS kst_trh,b.sube,b.reftur,b.refsirano,b.ln_rktu01_acilis_kom,t.musteri ,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
     FROM ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ t,
          trfm.tmp_trbac_tutar3_01 b
    WHERE 1=1
          AND t.sube = b.sube(+)
          AND t.reftur = b.reftur(+)
          AND t.refsirano = b.refsirano(+);

      COMMIT;

      v_line_no:=1080;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3_03',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1085;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_03
     SELECT rt.sube,rt.reftur,rt.refsirano,
            SUM (NVL (rt.bsmv, 0)) bsmv,
            SUM (NVL (rt.kkdf, 0)) kkdf,
            SUM (NVL (rt.faiz, 0)) faiz,
            SUM (NVL (rt.komisyon1, 0)) komisyon1,
            SUM (NVL (rt.komisyonbsmv1, 0)) komisyonbsmv1,
            SUM (NVL (rt.komisyon2, 0)) komisyon2,
            SUM (NVL (rt.komisyonbsmv2, 0)) komisyonbsmv2,
            SUM (NVL (rt.bsmvozel, 0)) bsmvozel,
            NVL (
                   TRUNC (
                        SUM (NVL (rt.bsmv, 0))
                      + SUM (NVL (rt.kkdf, 0))
                      + SUM (NVL (rt.faiz, 0))
                      + SUM (NVL (rt.komisyon1, 0))
                      + SUM (NVL (rt.komisyonbsmv1, 0))
                      + SUM (NVL (rt.komisyon2, 0))
                      + SUM (NVL (rt.komisyonbsmv2, 0))
                      + SUM (NVL (rt.bsmvozel, 0))),
                   0)
                   tahakkuk,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_reftahakkuk rt
            LEFT JOIN extr.fs_krd_tahsilat_devir ktd ON ktd.sube=rt.sube and ktd.reftur=rt.reftur and ktd.refsirano=rt.refsirano
      WHERE 1=1
            --   AND tarih > cd_gecis_tarihi  -----cd_gecis_tarihi nedir,ediz e sorulacak
            AND TO_DATE (rt.tarih, 'DD/MM/YYYY') <= v_tarih
            and rt.tarih > (CASE WHEN ktd.sube IS NOT NULL THEN TO_DATE ('29/10/2003', 'DD/MM/YYYY') ELSE TO_DATE ('31/12/2004', 'DD/MM/YYYY') END)
   GROUP BY rt.sube,rt.reftur,rt.refsirano;

      COMMIT;

      v_line_no:=1090;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3_04',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1095;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_04
     SELECT t.sube, t.reftur, t.refsirano,
            SUM (t.faiz) AS faiz,
            SUM (t.faiz_bsmv) AS faiz_bsmv,
            SUM (t.kom1) AS kom1,
            SUM (t.kom1_bsmv) AS kom1_bsmv,
            SUM (t.kom2) AS kom2,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_krd_tahsilat_detay t
            LEFT JOIN extr.fs_krd_tahsilat_devir ktd ON  1=1
                                                     AND ktd.sube=t.sube
                                                     AND ktd.reftur=t.reftur
                                                     AND ktd.refsirano=t.refsirano
      WHERE 1 = 1
            --AND (t.sube) = 229
            --AND (t.reftur) = 'TK'
            --AND (t.refsirano) = 23214
            AND t.durum = 0
            AND TO_DATE (t.fistarih, 'DD/MM/YYYY') <= v_tarih
            AND t.fistarih > (CASE WHEN ktd.sube IS NOT NULL THEN TO_DATE ('29/10/2003', 'DD/MM/YYYY') ELSE TO_DATE ('31/12/2004', 'DD/MM/YYYY') END)
   GROUP BY t.sube, t.reftur, t.refsirano;

      COMMIT;

      v_line_no:=1100;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3_05',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1105;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_05
 SELECT v_tarih AS  kesit_tarihi, k.sube, k.reftur, k.refsirano, k.kullanimtutar, k.geriodenen,
        h.bsmv, h.kkdf, h.faiz, h.komisyon1, h.komisyonbsmv1, h.komisyon2, h.komisyonbsmv2, h.bsmvozel,
        t.faiz AS faiz_t, t.faiz_bsmv AS faiz_bsmv_t, t.kom1 AS kom1_t, t.kom1_bsmv AS kom1_bsmv_t, t.kom2 AS kom2_t,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
   FROM ofsdata.krdmaster_aysonu              /*extr.fs_krdmaster tablosu proda atýlacak*/ k
        LEFT JOIN trfm.tmp_trbac_tutar3_03 h
                      ON 1=1
                      and k.sube=h.sube
                      and k.reftur =h.reftur
                      and k.refsirano =h.refsirano
        LEFT JOIN trfm.tmp_trbac_tutar3_04 t
                      ON 1=1
                      and k.sube=t.sube
                      and k.reftur =t.reftur
                      and k.refsirano =t.refsirano;

      COMMIT;

      v_line_no:=1110;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3_06',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1115;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_06
   SELECT v_tarih kst_trh,
          t.sube AS refsube,
          t.kmhhestur AS reftur,
          t.kmhekno AS refsirano,
          t.kmhilk7 AS musteri_no,---- fonksiyondaki kolonlar eklenecek
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
     FROM extr.fs_sube s,
          ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t ,
          extr.fs_gunluk_hplandet_sg h
    WHERE 1=1
          AND t.sube = s.sube
          AND t.sube = h.sube
          AND t.kmhilk7 = h.ilk7
          AND h.hestur = 'KT'
          AND t.krdekno = h.ekno
          AND t.krdekno != 0
          AND h.sinif = 'C'
          AND h.durum = 0
          AND t.tip IN (21, 22, 25, 26, 27, 28)
          AND v_tarih = h.tarih;

      COMMIT;

      v_line_no:=1120;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3_07',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1125;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3_07
  SELECT v_tarih kst_trh,
         k.sube AS refsube,
         k.reftur,
         k.refsirano,
         k.musteri AS musteri_no,
         k.durum,
         k.transfertutar,
         k.opsiyontutar,
         k.faiz,
         k.acilistutar,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_ithmaster k,
         extr.fs_sube s ,
         ofsdata.musteri_master_cs_hist mm
   WHERE k.acilistarih >=  LAST_DAY (ADD_MONTHS (v_tarih, -1))
     AND (k.reftur IN ('LC', 'AL') OR (k.reftur = 'AC' AND k.aval = 1 and k.policegiristutar>0))
     AND k.durum NOT IN (7, 9, 11, 10)
     and k.musteri = mm.musteri_no
     AND mm.tarih = v_tarih
     AND k.sube = s.sube
 UNION ALL
   SELECT
         v_tarih kst_trh,
         k.sube refsube,
         k.reftur,
         k.refsirano,
         k.musteri musteri_no,
         k.durum,
         k.transfertutar,
         k.opsiyontutar,
         k.faiz,
         k.acilistutar,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_ithmaster k,
         extr.fs_sube s,
         ofsdata.musteri_master_cs_hist mm,
         extr.fs_ithhrkt h
   WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))--'01/01/2006'
         AND (k.reftur IN ('LC', 'AL')
           OR  (k.reftur = 'AC'
            AND k.aval = 1  and k.policegiristutar>0))
         AND k.durum IN (7)
         AND k.musteri = mm.musteri_no
         AND mm.tarih = v_tarih
         AND k.sube = s.sube
         and k.sube=h.sube
         and k.reftur=h.reftur
         and k.refsirano=h.refsirano
         and h.kayittip=8
         and h.durum<>9
         AND h.islemtarihi <= v_tarih
         and h.islemtarihi>=LAST_DAY (ADD_MONTHS (v_tarih, -1))
               --v_gecis_tarihi--sonra ayrý dosya gönderilecek
 UNION ALL
  SELECT v_tarih kst_trh,
         k.sube refsube,
         k.reftur,
         k.refsirano,
         k.musteri musteri_no,
         k.durum,
         k.transfertutar,
         k.opsiyontutar,
         k.faiz,
         k.acilistutar,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_ithmaster k,
         extr.fs_sube s,
         ofsdata.musteri_master_cs_hist mm,
         extr.fs_eskiyenireferans e,
         extr.fs_banka b
   WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))
         AND (k.reftur IN ('LC', 'AL')
         OR  (k.reftur = 'AC'
         AND k.aval = 1  and k.policegiristutar>0))
         AND k.durum IN (10)
         AND k.musteri = mm.musteri_no
         AND mm.tarih = v_tarih
         AND k.sube = s.sube
         and s.sube=e.eski_sube
         and b.bankakod=e.eski_banka
         and k.sube=e.eski_sube
         and k.reftur=e.eski_reftur
         and k.refsirano=e.eski_refsirano
         and e.updtarih>=LAST_DAY (ADD_MONTHS (v_tarih, -1));

      COMMIT;

      v_line_no:=1130;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR3',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1135;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar3
 SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no, t.tutar3,
        SYSDATE AS etl_trh,
        v_sp_name AS etl_job
   FROM (
         SELECT a.kst_trh, a.refsube, a.reftur, a.refsirano, a.musteri_no,
                NVL(c.ln_rktu01_acilis_kom,0)
                + (NVL (x.komisyon1, 0) + NVL (x.komisyonbsmv1, 0)) - (NVL (x.kom1_t, 0) + NVL (x.kom1_bsmv_t, 0))
                --NVL (x.faiz, 0) - NVL (x.faiz_t, 0)
                --+(NVL(z.tutar,0)-NVL(z.cikistutar,0)) --->tutar 3 için ediz donus yapacak
                + 0 --- rtku11+rtku10  fonksiyonlarýný arat paket de  ln_kmhkalanTutar mesela bu
                + CASE WHEN r.durum IN (7,10 ) THEN 0
                       WHEN r.durum=0 THEN NVL(r.acilistutar,0) + NVL(r.faiz,0) + NVL(r.opsiyontutar,0) - NVL(r.transfertutar,0)
                       ELSE 0
                  END AS tutar3
           FROM trfm.tmp_trbac_fct_01 a
                LEFT JOIN prsn.kkb_trbfc_trbic_fct b ON  1 = 1
                                             AND a.kst_trh = b.kesit_tarihi
                                             AND a.musteri_no = b.musteri_no
                LEFT JOIN trfm.tmp_trbac_tutar3_02 c ON  1 = 1
                                                AND a.kst_trh = c.kst_trh
                                                AND a.refsube = c.sube
                                                AND a.reftur = c.reftur
                                                AND a.refsirano = c.refsirano
                                                and a.musteri_no =c.musteri
                LEFT JOIN trfm.tmp_trbac_tutar3_05 x ON  1 = 1
                                                AND a.kst_trh=x.kesit_tarihi
                                                AND a.refsube = x.sube
                                                AND a.reftur = x.reftur
                                                AND a.refsirano = x.refsirano
                LEFT JOIN trfm.tmp_trbac_tutar3_06 y ON  1=1
                                                AND a.kst_trh=y.kst_trh
                                                AND a.refsube = y.refsube
                                                AND a.reftur = y.reftur
                                                AND a.refsirano = y.refsirano
                                                AND A.musteri_no=y.musteri_no
                LEFT JOIN trfm.tmp_trbac_tutar3_07 r ON  1=1
                      --v_gecis_tarihi--sonra ayrý dosya gönderilecek
                                                AND a.kst_trh=r.kst_trh
                                                AND a.refsube = r.refsube
                                                AND a.reftur = r.reftur
                                                AND a.refsirano = r.refsirano
        ) t
  WHERE 1=1
        AND t.tutar3<>0;

      COMMIT;

      v_line_no:=1140;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_TUTAR4',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1145;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_tutar4
   SELECT v_tarih AS kst_trh,
          km.sube,
          km.reftur,
          km.refsirano,
          NVL(tmp01.rktu04,0) AS tkrd_tutar4,--+NVL(tmp02.rktu04_komisyon,0)+NVL(tmp03.rktu04_acilis_faiz,0)+NVL(tmp04.rktu04_thsl_edlms_acls_faiz,0)+NVL(tmp05.fat_kom_tutar,0)+NVL(tmp05.pesin_komisyon_tutar,0)+NVL(tmp05.gercekkomisyon,0) tkrd_tutar4
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ km
          LEFT JOIN (
                       SELECT v_tarih AS kst_trh,
                              sube,t.reftur,t.refsirano,
                              NVL(TRUNC(SUM(NVL(t.anapara,0)) + SUM(NVL(t.faiz,0))+SUM(NVL(t.gecikme,0))),0) AS RKTU04     --þimdiye kadar TOPLAM ödenmesi gereken ve ödenen BORÇ tutarý
                         FROM extr.fs_bkrhrkt t
                        WHERE vadetarih< v_tarih
                              AND TO_DATE (t.odemetarih, 'DD/MM/YYYY') <= v_tarih
                              AND TO_DATE (t.updtarih, 'DD/MM/YYYY') <= v_tarih
                              and durum = 1
                     GROUP BY t.sube,t.reftur,t.refsirano
                    ) tmp01 ON  1 = 1
                            and km.sube = tmp01.sube
                            and km.reftur = tmp01.reftur
                            and km.refsirano = tmp01.refsirano
                            and v_tarih = tmp01.kst_trh
          LEFT JOIN (
                     SELECT v_tarih kst_trh,z.sube,z.reftur,z.refsirano, z.musteri,
                            CASE WHEN t.katkipayi_ilk7!= z.musteri THEN 0 --TRUNC(SUM(NVL (komisyon, 0)))
                                 ELSE NVL(TRUNC(z.aciliskomisyon),0)
                            END AS rktu04_komisyon --    retval.rktu12 --komisyon
                       FROM extr.fs_tkrd_detay t ,
                            ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ z
                      WHERE 1=1
                            AND t.sube=z.sube
                            AND t.reftur =z.reftur
                            AND t.refsirano =z.refsirano
                            AND t.katkipayi_tahsiltarih <v_tarih
                            AND t.katkipayi_tahsiltarih >ADD_MONTHS (v_tarih,-1)
                    ) tmp02 ON 1 = 1
                            and km.sube = tmp02.sube
                            and km.reftur = tmp02.reftur
                            and km.refsirano = tmp02.refsirano
                            and v_tarih = tmp02.kst_trh
          LEFT JOIN (
                     SELECT v_tarih kst_trh,a.sube,a.reftur,a.refsirano,NVL (TRUNC (a.acilis_faiz), 0) AS rktu04_acilis_faiz
                       FROM extr.fs_tkrd_detay a
                      WHERE a.acilis_faiz_secim = 'A'
                    )  tmp03 ON 1 = 1
                             and km.sube = tmp03.sube
                             and km.reftur = tmp03.reftur
                             and km.refsirano = tmp03.refsirano
                             and v_tarih = tmp03.kst_trh
          LEFT JOIN (
                     SELECT v_tarih kst_trh,b.sube,b.reftur,b.refsirano,NVL (TRUNC (a.acilis_faiz), 0) rktu04_thsl_edlms_acls_faiz
                       FROM extr.fs_tkrd_detay a,
                            extr.fs_bkrhrkt b
                      WHERE 1=1
                            AND b.sube = a.sube
                            AND b.reftur = a.reftur
                            AND b.refsirano = a.refsirano
                            AND a.acilis_faiz_secim = 'T'
                            AND b.taksitno = 1
                            AND b.durum =1                                     -- ilk vade tarihi..
                            AND TO_DATE (b.odemetarih, 'DD/MM/YYYY') <= v_tarih
                            AND TO_DATE (b.updtarih, 'DD/MM/YYYY') <= v_tarih
                    ) tmp04 ON  1 = 1
                            and km.sube = tmp04.sube
                            and km.reftur = tmp04.reftur
                            and km.refsirano = tmp04.refsirano
                            and v_tarih = tmp04.kst_trh
          LEFT JOIN (
                     SELECT v_tarih kst_trh,a.sube,a.reftur,a.refsirano,a.fat_kom_tutar,a.pesin_komisyon_tutar,a.gercekkomisyon
                       FROM extr.fs_tkrd_detay a,
                            ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ z
                      WHERE 1=1
                            AND a.sube=z.sube
                            AND a.reftur =z.reftur
                            AND a.refsirano =z.refsirano
                   ) tmp05 ON 1 = 1
                           and km.sube = tmp05.sube
                           and km.reftur = tmp05.reftur
                           and km.refsirano = tmp05.refsirano
                           and v_tarih = tmp05.kst_trh
    WHERE 1=1;

      COMMIT;

      v_line_no:=1150;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_NKRD_TUTAR4',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1155;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_nkrd_tutar4
   SELECT v_tarih kesit_tarihi,k.sube,k.reftur,k.refsirano,h.tahakkuk ,t.tahsilat,t.faizkomisyon,t.gecikme,k.kullanimtutar,k.geriodenen,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM ofsdata.krdmaster_aysonu               /*extr.fs_krdmaster tablosu proda atýlacak*/ k
          LEFT JOIN (  SELECT sube,reftur,refsirano,
                              NVL (
                                    TRUNC (
                                         SUM (NVL (bsmv, 0))
                                       + SUM (NVL (kkdf, 0))
                                       + SUM (NVL (faiz, 0))
                                       + SUM (NVL (komisyon1, 0))
                                       + SUM (NVL (komisyonbsmv1, 0))
                                       + SUM (NVL (komisyon2, 0))
                                       + SUM (NVL (komisyonbsmv2, 0))
                                       + SUM (NVL (bsmvozel, 0))),
                                    0)
                                    tahakkuk
                         FROM extr.fs_reftahakkuk
                        WHERE 1=1
                              --   AND tarih > cd_gecis_tarihi  -----cd_gecis_tarihi nedir,ediz e sorulacak
                     GROUP BY sube,reftur,refsirano
                    ) h ON 1=1
                        and k.sube=h.sube
                        and k.reftur =h.reftur
                        and k.refsirano =h.refsirano

          LEFT JOIN (  SELECT sube,reftur,refsirano,
                              NVL (
                                   TRUNC (
                                            SUM (NVL (t.faiz, 0))
                                          + SUM (NVL (t.faiz_bsmv, 0))
                                          + SUM (NVL (t.faiz_kkdf, 0))
                                          + SUM (NVL (t.kom1, 0))
                                          + SUM (NVL (t.kom1_bsmv, 0))
                                          + SUM (NVL (t.kom2, 0))
                                          + SUM (NVL (t.kom2_bsmv, 0))
                                          + SUM (NVL (t.bsmvozel, 0))),
                                       0) AS tahsilat,
                              NVL (
                                       TRUNC (
                                          SUM (NVL (t.faiz, 0)) + SUM (NVL (t.kom1, 0)) + SUM (NVL (t.gecikme, 0))),
                                       0) AS faizkomisyon,
                              NVL (
                                   TRUNC (
                                            SUM (NVL (t.gecikme, 0))
                                          + SUM (NVL (t.gecikme_bsmv, 0))
                                          + SUM (NVL (t.gecikme_kkdf, 0))),
                                       0) AS gecikme
                         FROM extr.fs_krd_tahsilat_detay t
                        WHERE t.durum = 0
                              ---- AND t.fistarih > cd_gecis_tarihi) ---edize sorulacak
                     GROUP BY sube,reftur,refsirano
                    ) t ON 1=1
                        and k.sube=t.sube
                        and k.reftur =t.reftur
                        and k.refsirano =t.refsirano
    WHERE 1=1;

      COMMIT;

      v_line_no:=1160;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR4',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1165;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar4
  SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no, t.tutar4,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (
          SELECT a.kst_trh, a.refsube, a.reftur, a.refsirano, a.musteri_no,
                 NVL(fb.tkrd_tutar4,0)
                 +
                 --NVL(n.tahsilat,0) + NVL(n.gecikme,0)
                 NVL (n.kullanimtutar, 0) - NVL (n.geriodenen, 0)
                 +NVL(tm.tmek_tutar4,0)--tmek
                 +0 --      retval.RKTU04 := retval.RKTU14+retval.RKTU15;
                 +
                 NVL(CASE WHEN r.durum IN (7,10 ) THEN 0
                          WHEN r.durum=0 THEN NVL(r.acilistutar,0) + NVL(r.faiz,0) + NVL(r.opsiyontutar,0) - NVL(r.transfertutar,0)
                          ELSE 0
                     END,0) AS tutar4
            FROM trfm.tmp_trbac_fct_01 a
                 LEFT JOIN prsn.kkb_trbfc_trbic_fct b
                           ON  1 = 1
                           AND a.kst_trh = b.kesit_tarihi
                           AND a.musteri_no = b.musteri_no
                 LEFT JOIN trfm.tmp_trbac_tkrd_tutar4 fb
                           ON  1=1
                           AND a.kst_trh=fb.kst_trh
                           AND a.refsube = fb.sube
                           AND a.reftur = fb.reftur
                           AND a.refsirano = fb.refsirano
                 LEFT JOIN trfm.tmp_trbac_nkrd_tutar4 n
                           ON  1=1
                           AND a.kst_trh=n.kesit_tarihi
                           AND a.refsube = n.sube
                           AND a.reftur = n.reftur
                           AND a.refsirano = n.refsirano
                 ---------------------tmek---------------
                 LEFT JOIN (  SELECT v_tarih AS kst_trh,th.refsube,th.reftur,th.refsirano, SUM (NVL (th.tutar, 0)) + SUM (NVL (th.gecfaiztut, 0)) AS tmek_tutar4
                               FROM extr.fs_temmekhrkt th
                              WHERE 1=1
                                    AND th.hrkttur IN (7, 4, 6, 10, 5)
                                    AND th.durum != 9
                                    AND th.fistarih <= v_tarih
                           GROUP BY refsube,reftur,refsirano
                           ) tm ON  1=1
                                AND a.kst_trh=tm.kst_trh
                                AND a.refsube = tm.refsube
                                AND a.reftur = tm.reftur
                                AND a.refsirano = tm.refsirano

                     ---kmh                      retval.RKTU04 := retval.RKTU14+retval.RKTU15;
               --       left join

               --         ( SELECT
               --                      v_tarih kst_trh,
               --
               --                       t.sube refsube,
               --                       t.kmhhestur reftur,
               --                       t.kmhekno   refsirano,
               --                       t.kmhilk7  musteri_no ---- fonksiyondaki kolonlar eklenecek
               --               FROM extr.fs_sube s, ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t , extr.fs_hplandet_sg h
               --              WHERE     t.sube = s.sube
               --                                         AND t.sube = h.sube
               --                                        AND t.kmhilk7 = h.ilk7
               --                                         AND h.hestur = 'KT'
               --                                         AND t.krdekno = h.ekno
               --                    AND t.krdekno != 0
               --                    AND h.sinif = 'C'
               --                    AND t.tip IN (21, 22, 25, 26, 27, 28))y
               --
               --                     ON 1=1
               --                            AND  a.kst_trh=y.kst_trh
               --                            AND   a.refsube = y.refsube
               --                            AND a.reftur = y.reftur
               --                            AND a.refsirano = y.refsirano

                 LEFT JOIN (

                              SELECT v_tarih AS kst_trh,
                                     k.sube AS refsube,
                                     k.reftur,
                                     k.refsirano,
                                     k.musteri AS musteri_no,
                                     k.durum,
                                     k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar
                                FROM extr.fs_ithmaster k,
                                     extr.fs_sube s ,
                                     ofsdata.musteri_master_cs_hist mm
                               WHERE k.acilistarih >=  LAST_DAY (ADD_MONTHS (v_tarih, -1))
                                     AND (k.reftur IN ('LC', 'AL') OR (k.reftur = 'AC' AND k.aval = 1 and k.policegiristutar>0))
                                     AND  k.durum NOT IN (7, 9, 11, 10)
                                     and  k.musteri = mm.musteri_no
                                     AND mm.tarih = v_tarih
                                     AND k.sube = s.sube

                              UNION ALL

                              SELECT v_tarih AS kst_trh,
                                     k.sube AS refsube,
                                     k.reftur,
                                     k.refsirano,
                                     k.musteri AS musteri_no,
                                     k.durum,
                                     k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar
                                FROM extr.fs_ithmaster k,
                                     extr.fs_sube s,
                                     ofsdata.musteri_master_cs_hist mm,
                                     extr.fs_ithhrkt h
                               WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))--'01/01/2006'
                                     AND (k.reftur IN ('LC', 'AL')
                                       OR  (k.reftur = 'AC'
                                        AND k.aval = 1  and k.policegiristutar>0))
                                     AND k.durum IN (7)
                                     AND k.musteri = mm.musteri_no
                                     AND mm.tarih = v_tarih
                                     AND k.sube = s.sube
                                     and k.sube=h.sube
                                     and k.reftur=h.reftur
                                     and k.refsirano=h.refsirano
                                     and h.kayittip=8
                                     and h.durum<>9
                                     AND h.islemtarihi <= v_tarih
                                     and h.islemtarihi>=LAST_DAY (ADD_MONTHS (v_tarih, -1))

                                             --v_gecis_tarihi--sonra ayrý dosya gönderilecek
                              UNION ALL

                              SELECT v_tarih kst_trh,
                                     k.sube refsube,
                                     k.reftur,
                                     k.refsirano,
                                     k.musteri musteri_no,
                                     k.durum,
                                     k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar
                                FROM extr.fs_ithmaster k,
                                     extr.fs_sube s,
                                     ofsdata.musteri_master_cs_hist mm,
                                     extr.fs_eskiyenireferans e,
                                     extr.fs_banka b
                                WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))
                                      AND (k.reftur IN ('LC', 'AL')
                                      OR  (k.reftur = 'AC'
                                      AND k.aval = 1  and k.policegiristutar>0))
                                      AND k.durum IN (10)
                                      AND k.musteri = mm.musteri_no
                                      AND mm.tarih = v_tarih
                                      AND k.sube = s.sube
                                      and s.sube=e.eski_sube
                                      and b.bankakod=e.eski_banka
                                      and k.sube=e.eski_sube
                                      and k.reftur=e.eski_reftur
                                      and k.refsirano=e.eski_refsirano
                                      and e.updtarih>=LAST_DAY (ADD_MONTHS (v_tarih, -1))
                           ) r
                              --v_gecis_tarihi--sonra ayrý dosya gönderilecek
                                  ON 1=1
                               AND a.kst_trh=r.kst_trh
                               AND a.refsube = r.refsube
                               AND a.reftur = r.reftur
                               AND a.refsirano = r.refsirano
                   ) t
  WHERE 1=1
        AND t.tutar4<>0;

      COMMIT;

      v_line_no:=1170;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_TUTAR5_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1175;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_tutar5_01
     SELECT v_tarih AS kst_trh,
            b.sube,b.reftur,b.refsirano,
            NVL (TRUNC (SUM (NVL (b.gecikme, 0))), 0) AS tkrd_gecikme,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_bkrhrkt b
      WHERE 1=1
            and odemetarih <= v_tarih
            AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
            and durum = 1
            AND NVL (b.gecikme, 0) <> 0
   GROUP BY sube,reftur,refsirano;

      COMMIT;

      v_line_no:=1180;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_TUTAR5_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1185;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_tutar5_02
     SELECT v_tarih AS kst_trh,sube,reftur,refsirano,
            NVL(TRUNC (SUM (NVL (faiz, 0))),0) AS tkrd_faiz,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_bkrhrkt
      WHERE 1=1
            AND durum = 0
            AND vadetarih < v_tarih
            AND NVL (faiz, 0) <> 0
            AND TO_DATE (odemetarih, 'DD/MM/YYYY') <= v_tarih
            AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
   GROUP BY sube,reftur,refsirano;

      COMMIT;

      v_line_no:=1190;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_TUTAR5_03',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1195;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_tutar5_03
     SELECT v_tarih AS kst_trh,
            b.sube,b.reftur,b.refsirano ,
            SUM (NVL (TRUNC (a.acilis_faiz), 0)) AS tkrd_acilis_faiz,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_tkrd_detay a,
            extr.fs_bkrhrkt b
      WHERE b.sube = a.sube
            AND b.reftur = a.reftur
            AND b.refsirano = a.refsirano
            AND a.acilis_faiz_secim = 'T'
            AND b.taksitno = 1
            AND b.durum =0
            AND NVL (TRUNC (a.acilis_faiz), 0) <> 0
            AND TO_DATE (b.odemetarih, 'DD/MM/YYYY') <= v_tarih
            AND TO_DATE (b.updtarih, 'DD/MM/YYYY') <= v_tarih
   GROUP BY b.sube,b.reftur,b.refsirano;

      COMMIT;

      v_line_no:=1190;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TMEK_TUTAR5',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1195;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tmek_tutar5
     SELECT v_tarih AS kst_trh,
            th.refsube,th.reftur,th.refsirano,
            SUM (NVL (th.gecfaiztut, 0)) AS tmek_tutar4,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_temmekhrkt th
      WHERE 1=1
            AND th.hrkttur =7
            AND th.durum != 9
            AND NVL (th.gecfaiztut, 0) <> 0
            AND th.fistarih <= v_tarih
   GROUP BY refsube,reftur,refsirano;

      COMMIT;

      v_line_no:=1200;
              /*
drop table tmp_trbac_tutar5_tmp_05;
create table tmp_trbac_tutar5_tmp_05 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING as
SELECT kst_trh, refsube, reftur, refsirano, musteri_no, tutar4
  FROM tmp_trbac_tutar4
 WHERE NVL (tutar4, 0) <> 0;
grant SELECT ON tmp_trbac_tutar5_tmp_05 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
*/

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TUTAR5',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1205;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tutar5
  SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no, t.tutar5,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (
           SELECT a.kst_trh, a.refsube, a.reftur, a.refsirano, a.musteri_no,
                  NVL(vv.tkrd_faiz,0)+NVL(tt.tkrd_acilis_faiz,0)- NVL(tmp01.tkrd_gecikme,0)--Tkrd
                  +
                  0 --nkrd ÝÇÝN EDÝZDEN TARÝF BEKLENÝYOR
                  +NVL(tm.tmek_tutar4,0)--tmek

                  +0 --      retval.RKTU04 := retval.RKTU14+retval.RKTU15;
                  +0---dim eksik
                  AS tutar5
             FROM trfm.tmp_trbac_fct_01 a
                   /*             LEFT JOIN trbfc_trbic_fct b
                                  ON     1 = 1
                                     AND a.kst_trh = b.kesit_tarihi
                                     AND a.musteri_no = b.musteri_no
      */
                  --tkrd---
                  /*              LEFT JOIN tmp_trbac_tutar5_tmp_05 dd --TUTAR4ü aldýðýmýz tablo
                            ON     1 = 1
                           and a.kst_trh = dd.kst_trh
                           and a.refsube = dd.refsube
                           and a.reftur = dd.reftur
                           and a.refsirano = dd.refsirano
                           and a.musteri_no =dd.musteri_no
    */
                  LEFT JOIN trfm.tmp_trbac_tkrd_tutar5_01 tmp01
                            ON 1 = 1
                           and a.refsube = tmp01.sube
                           and a.reftur = tmp01.reftur
                           and a.refsirano = tmp01.refsirano
                           and v_tarih = tmp01.kst_trh
                    ----Tkrd
                  LEFT JOIN trfm.tmp_trbac_tkrd_tutar5_02 vv
                           ON 1=1
                           and a.refsube = vv.sube
                           and a.reftur = vv.reftur
                           and a.refsirano = vv.refsirano
                           and v_tarih = vv.kst_trh
                  LEFT JOIN trfm.tmp_trbac_tkrd_tutar5_03 tt
                           ON 1=1
                           and a.refsube = tt.sube
                           and a.reftur = tt.reftur
                           and a.refsirano = tt.refsirano
                           and v_tarih = tt.kst_trh
                  ------- tmek-------
                  LEFT JOIN trfm.tmp_trbac_tmek_tutar5 tm
                           ON 1=1
                           AND      a.kst_trh=tm.kst_trh
                           AND      a.refsube = tm.refsube
                           AND      a.reftur = tm.reftur
                           AND      a.refsirano = tm.refsirano
         ) t
   WHERE 1=1
         and t.tutar5<>0;

      COMMIT;

      v_line_no:=1210;


--      -----kmh----
--       left join
--
--         ( SELECT
--                      v_tarih kst_trh,
--
--                       t.sube refsube,
--                       t.kmhhestur reftur,
--                       t.kmhekno   refsirano,
--                       t.kmhilk7  musteri_no ---- fonksiyondaki kolonlar eklenecek
--               FROM extr.fs_sube s, ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t , extr.fs_hplandet_sg h
--              WHERE     t.sube = s.sube
--                                         AND t.sube = h.sube
--                                        AND t.kmhilk7 = h.ilk7
--                                         AND h.hestur = 'KT'
--                                         AND t.krdekno = h.ekno
--                    AND t.krdekno != 0
--                    AND h.sinif = 'C'
--                    AND t.tip IN (21, 22, 25, 26, 27, 28))y
--
--                     ON 1=1
--                            AND  a.kst_trh=y.kst_trh
--                            AND   a.refsube = y.refsube
--                            AND a.reftur = y.reftur
--                            AND a.refsirano = y.refsirano
--
--
--
--    left join
--
--(
--SELECT
--                      v_tarih kst_trh,
--k.sube refsube,
--k.reftur,
--k.refsirano,
--k.musteri musteri_no,
--k.durum,
--k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar
--  FROM extr.fs_ithmaster k, extr.fs_sube s ,extr.fs_musteri_master mm
-- WHERE k.acilistarih >=  LAST_DAY (ADD_MONTHS (v_tarih, -1))
--   AND (k.reftur IN ('LC', 'AL') OR (k.reftur = 'AC' AND k.aval = 1 and k.policegiristutar>0))
--   AND  k.durum NOT IN (7, 9, 11, 10)
--   and  k.musteri = mm.musteri_no
--   AND k.sube = s.sube
--
--  union all
--
--   SELECT
--       v_tarih kst_trh,
--        k.sube refsube,
--        k.reftur,
--        k.refsirano,
--        k.musteri musteri_no,
--        k.durum,
--k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar
--         FROM extr.fs_ithmaster k, extr.fs_sube s, extr.fs_musteri_master mm, extr.fs_ithhrkt h
--             WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))--'01/01/2006'
--               AND (k.reftur IN ('LC', 'AL')
--                 OR  (k.reftur = 'AC'
--                  AND k.aval = 1  and k.policegiristutar>0))
--               AND k.durum IN (7)
--               AND k.musteri = mm.musteri_no
--               AND k.sube = s.sube
--               and k.sube=h.sube
--               and k.reftur=h.reftur
--               and k.refsirano=h.refsirano
--               and h.kayittip=8
--               and h.durum<>9
--               and h.islemtarihi>=LAST_DAY (ADD_MONTHS (v_tarih, -1))
--
--               --v_gecis_tarihi--sonra ayrý dosya gönderilecek
--         UNION ALL
--
--          SELECT
--                v_tarih kst_trh,
--
--                    k.sube refsube,
--                    k.reftur,
--                    k.refsirano,
--                    k.musteri musteri_no,
--                    k.durum,
--                  k.acilistutar, k.faiz , k.opsiyontutar , k.transfertutar
--         FROM extr.FS_ITHMASTER k, extr.fs_sube s, extr.fs_musteri_master mm, extr.fs_eskiyenireferans e,extr.fs_banka b
--             WHERE k.acilistarih>= LAST_DAY (ADD_MONTHS (v_tarih, -1))
--               AND (k.reftur IN ('LC', 'AL')
--               OR  (k.reftur = 'AC'
--               AND k.aval = 1  and k.policegiristutar>0))
--               AND k.durum IN (10)
--               AND k.musteri = mm.musteri_no
--               AND k.sube = s.sube
--               and s.sube=e.eski_sube
--              and b.bankakod=e.eski_banka
--               and k.sube=e.eski_sube
--               and k.reftur=e.eski_reftur
--               and k.refsirano=e.eski_refsirano
--               and e.updtarih>=LAST_DAY (ADD_MONTHS (v_tarih, -1))) r
--               --v_gecis_tarihi--sonra ayrý dosya gönderilecek
--                               ON 1=1
--                            AND  a.kst_trh=r.kst_trh
--                            AND   a.refsube = r.refsube
--                            AND a.reftur = r.reftur
--                            AND a.refsirano = r.refsirano;
--   commit;
--
--grant SELECT ON tmp_trbac_tutar5 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
   ---

--DELETE tmp_trbac_tutar5
--WHERE NVL (tutar5, 0) = 0;
--COMMIT;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_TUTAR4_TUTAR5',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1215;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_tutar4_tutar5
     SELECT kst_trh, tip, sube, reftur, refsirano,
            SUM (tkrd_rktu19_tutar4) AS tkrd_rktu19_tutar4,
            SUM (tkrd_rktu20_tutar5) AS tkrd_rktu20_tutar5,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih kst_trh, 'TKRD' tip, sube, reftur, refsirano,
                      SUM (NVL (anapara, 0)) tkrd_rktu19_tutar4,
                      SUM (NVL (faiz, 0)) tkrd_rktu20_tutar5
                 FROM extr.fs_bkrhrkt
                WHERE 1 = 1
                  AND durum = 0
                  AND TO_DATE (vadetarih, 'DD/MM/YYYY') <= v_tarih
                  --AND TO_DATE (odemetarih, 'DD/MM/YYYY') <= v_tarih
                  AND TO_DATE (odemetarih, 'DD/MM/YYYY') = TO_DATE ('31/12/1899', 'DD/MM/YYYY')
                  AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
                  --AND sube = 687 AND reftur = 'TT' AND refsirano = 373
             GROUP BY sube, reftur, refsirano
                           /*UNION ALL
             --UNION'un bu kýsmý ayýn 1'inden sonra programýn çalýþtýrýlmasýnda o süre içinde DURUM kolonu 1'e dönen referanslar için Ediz ile eklenmiþtir (KK)
               SELECT v_tarih kst_trh, 'TKRD' tip, sube, reftur, refsirano,
                      SUM (NVL (anapara, 0)) tkrd_rktu19_tutar4,
                      SUM (NVL (faiz, 0)) tkrd_rktu20_tutar5
                 FROM extr.fs_bkrhrkt
                WHERE 1 = 1
                  AND durum = 1
                  AND TO_DATE (vadetarih, 'DD/MM/YYYY') <= v_tarih
                  AND TO_DATE (odemetarih, 'DD/MM/YYYY') > v_tarih
                  AND LAST_DAY (TO_DATE (odemetarih, 'DD/MM/YYYY')) = LAST_DAY (ADD_MONTHS (v_tarih, +1))
                  --AND sube = 687 AND reftur = 'TT' AND refsirano = 373
             GROUP BY sube, reftur, refsirano*/
            )
   GROUP BY kst_trh, tip, sube, reftur, refsirano;

      COMMIT;

      v_line_no:=1220;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_TUTAR6',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1225;
--------------TUTAR-6------------------------
--TKRD---

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_tutar6
     SELECT LAST_DAY (tarih) AS kst_trh,tip,sube,reftur,refsirano, MAX (tutar) AS tkrd_tutar6,musteri,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
              SELECT tarih,'TKRD' AS tip,sube,reftur,refsirano, SUM (tutar) AS tutar,musteri
                FROM extr.fs_tkrd_gecikme_bilgi
               WHERE 1=1
                     AND last_day(tarih) =v_tarih
            GROUP BY tarih,sube,reftur,refsirano,musteri
            )
   GROUP BY LAST_DAY (tarih),tip,sube,reftur,refsirano,musteri;

      COMMIT;

      v_line_no:=1230;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_NKRD_TUTAR6',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1235;
--------nkrd tutar6----

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_nkrd_tutar6
     SELECT kst_trh, tip,sube,reftur,refsirano, SUM(tutar) AS nkrd_tutar,musteri,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
              SELECT LAST_DAY (tarih) AS kst_trh, tip, sube, reftur, refsirano, MAX (tutar) AS tutar, musteri
                FROM (
                      SELECT   tarih,'NKRD'tip,sube,reftur,refsirano, SUM (NVL((kullanimtutar-geriodenen),0)) AS tutar,musteri
                        FROM extr.fs_kredi_bilgi a
                       WHERE     kullanimtutar - geriodenen > 0
                             AND vade < tarih
                             AND last_day(tarih) =v_tarih
                      GROUP BY tarih,sube,reftur,refsirano,musteri
                     )
            GROUP BY LAST_DAY(tarih), tip,sube,reftur,refsirano,musteri

            UNION ALL

              SELECT LAST_DAY (tarih) AS kst_trh,tip,sube,reftur,refsirano, MAX (tutar) AS nkrd_tutar6,musteri
                FROM
                     (  SELECT tarih,'NKRD'tip,sube,reftur,refsirano, SUM (tutar) tutar,musteri
                          FROM extr.fs_krd_ana_para_odeme
                         WHERE odeme_tarihi < tarih
                               AND last_day(tarih) =v_tarih
                      GROUP BY tarih,sube,reftur,refsirano,musteri
                     )
            GROUP BY LAST_DAY (tarih),tip,sube,reftur,refsirano,musteri

            UNION ALL

              SELECT LAST_DAY (tarih) AS kst_trh, tip,sube,reftur,refsirano, MAX (tutar) AS tutar,musteri
                FROM (
                        SELECT tarih,'NKRD'tip,sube,reftur,refsirano,  SUM(tahakkuk_tutar-tahsilat_tutar) tutar,musteri
                          FROM extr.fs_krd_tahakkuk_tahsilat
                         WHERE tahakkuk_tarih < tarih
                               AND last_day(tarih) =v_tarih
                      GROUP BY tarih,sube,reftur,refsirano,musteri
                     )
            GROUP BY LAST_DAY (tarih), tip,sube,reftur,refsirano,musteri
            )
   GROUP BY kst_trh, tip,sube,reftur,refsirano,musteri;

      COMMIT;

      v_line_no:=1240;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TMEK_TUTAR6',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1245;
--------tmek tutar6----

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tmek_tutar6
     SELECT LAST_DAY(tarih) AS kst_trh,
            reftur,
            refsube,
            refsirano,
            SUM(devkomtutar) AS tmek_tutar6,
            musteri,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_temmek_odenmeyen_komisyon          ---ofsdata.temmek_odenmeyen_komisyon---extr alýancak
      WHERE LAST_DAY(tarih) =v_tarih
            AND durum = 2
   GROUP BY LAST_DAY(tarih),refsube,reftur,refsirano,musteri;

      COMMIT;

      v_line_no:=1250;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_TUTAR6',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1255;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_tutar6
  SELECT kst_trh, tarih, musteri_no, sube, sinif, mt_ekno, kt_ekno, kr_ekno,
         gecikme_gun, anaparayuzde_kalantahsilat, faiz_kalantahsilat, kkdf_kalantahsilat, bsmv_kalantahsilat, kmh_tutar6,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (
            SELECT LAST_DAY (tarih) kst_trh, tarih, ilk7 musteri_no, sube, sinif, mt_ekno, kt_ekno, kr_ekno,
                   gecikme_gun, anaparayuzde_kalantahsilat, faiz_kalantahsilat, kkdf_kalantahsilat, bsmv_kalantahsilat,
                   NVL (anaparayuzde_kalantahsilat, 0) + NVL (faiz_kalantahsilat, 0) + NVL (kkdf_kalantahsilat, 0) + NVL (bsmv_kalantahsilat, 0) kmh_tutar6,
                   ROW_NUMBER () OVER (PARTITION BY LAST_DAY (tarih), ilk7, sube, sinif, mt_ekno, kt_ekno, kr_ekno
                                                    ORDER BY NVL (anaparayuzde_kalantahsilat, 0) + NVL (faiz_kalantahsilat, 0) + NVL (kkdf_kalantahsilat, 0) + NVL (bsmv_kalantahsilat, 0) DESC,
                                                             gecikme_gun DESC, tarih DESC) sira
              FROM extr.fs_tuzel_kmh_musteri_gecikme
             WHERE 1 = 1
               --AND ilk7 = 8535500
               AND sinif = 'C'
               AND LAST_DAY (TO_DATE (tarih, 'DD/MM/YYYY')) = v_tarih
               AND (
                        NVL (anaparayuzde_kalantahsilat, 0) <> 0
                     OR NVL (faiz_kalantahsilat, 0) <> 0
                     OR NVL (kkdf_kalantahsilat, 0) <> 0
                     OR NVL (bsmv_kalantahsilat, 0) <> 0
                   )
         )
   WHERE 1 = 1
     AND sira = 1;

      COMMIT;

      v_line_no:=1260;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_TUTAR_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1265;
--KMH

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_tutar_01
     SELECT v_tarih AS kst_trh,
            sube, hestur, ilk7, ekno,
            NVL(SUM(faiz_kalantahsilat+bsmv_kalantahsilat+kkdf_kalantahsilat),0) AS odenmeyen_kredi_tutari,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_krtahakkuk
      WHERE 1 = 1
        AND tarih <= v_tarih
   GROUP BY sube, hestur, ilk7, ekno;

      COMMIT;

      v_line_no:=1270;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('tmp_trbac_kmh_tutar3_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1275;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_tutar3_01
     SELECT v_tarih AS kst_trh,
            b.sube, b.sinif, b.ilk7, b.hestur, b.ekno,
            SUM (NVL (b.anaparayuzde, 0)) AS anaparayuzde,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_krtahakkuk b
      WHERE 1 = 1
        AND b.sinif = 'C'
        AND b.tarih <= v_tarih
        AND NVL (b.anaparayuzde, 0) <> 0
   GROUP BY b.sube, b.sinif, b.ilk7, b.hestur, b.ekno;

      COMMIT;

      v_line_no:=1280;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_TUTAR3_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1285;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_tutar3_02
  SELECT a.kst_trh, a.refsube, a.reftur, a.refsirano, a.musteri_no,
         NVL (kalan_toplam, 0) + NVL (faiz_toplam, 0) AS kmh_faiz_tutari,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_fct_01 a
         LEFT OUTER JOIN (
                            SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no,
                                   SUM (NVL (d.faiz_kalantahsilat, 0) + NVL (d.bsmv_kalantahsilat, 0) + NVL (d.kkdf_kalantahsilat, 0)) AS kalan_toplam
                              FROM extr.fs_krtahakkuk d,
                                   trfm.tmp_trbac_fct_01 t
                             WHERE 1 = 1
                               AND t.kst_trh = v_tarih
                               AND d.tarih <= LAST_DAY (ADD_MONTHS (t.kst_trh, - 2))
                               --AND d.sube = t.refsube AND d.ilk7 = t.musteri_no AND d.ekno = t.refsirano
                               AND t.refsube = d.sube
                               AND t.refsirano = d.ekno
                               AND t.musteri_no = d.ilk7
                               AND NVL (d.faiz_kalantahsilat, 0) + NVL (d.bsmv_kalantahsilat, 0) + NVL (d.kkdf_kalantahsilat, 0) <> 0
                               AND t.tip = 'KMH'
                          GROUP BY t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no
                         ) b
                         ON 1 = 1
                            AND a.kst_trh = b.kst_trh
                            AND a.refsube = b.refsube
                            AND a.reftur = b.reftur
                            AND a.refsirano = b.refsirano
                            AND a.musteri_no = b.musteri_no
         LEFT OUTER JOIN (
                            SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano,t.musteri_no,
                                   SUM(NVL (d.faiz, 0) + NVL (d.bsmv, 0)) faiz_toplam
                              FROM extr.fs_krtahakkuk d,
                                   trfm.tmp_trbac_fct_01 t
                             WHERE 1 = 1
                               AND t.kst_trh = v_tarih
                               AND d.tarih BETWEEN last_day(add_months(t.kst_trh,-2)) + 1 and last_day(add_months(t.kst_trh,-1))
                               AND t.refsube =d.sube
                               AND t.refsirano =d.ekno
                               AND t.musteri_no =d.ilk7
                               AND NVL (d.faiz, 0)+NVL (d.bsmv, 0) <> 0
                               AND t.tip = 'KMH'
                          GROUP BY t.kst_trh, t.refsube, t.reftur, t.refsirano,t.musteri_no
                         ) c
                         ON 1 = 1
                            AND a.kst_trh = c.kst_trh
                            AND A.refsube = c.refsube
                            AND A.reftur = c.reftur
                            and a.refsirano = c.refsirano
                            and a.musteri_no =c.musteri_no
   WHERE 1 = 1
     AND NVL (kalan_toplam, 0) + NVL (faiz_toplam, 0) <> 0
     AND a.tip = 'KMH';

      COMMIT;

      v_line_no:=1290;
              /*
DROP TABLE tmp_kmh_trbac_tutar_03;
CREATE TABLE tmp_kmh_trbac_tutar_03 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT  t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no,
         NVL (a.alac, 0) alac
    FROM tmp_trbac_fct_01 t
         INNER JOIN extr.fs_gunluk_hplandet_sg a
                         ON     1 = 1
                            AND LAST_DAY (ADD_MONTHS (t.kst_trh, - 1)) = a.tarih
                            AND t.refsube = a.sube
                            AND 'C' = a.sinif
                            AND t.musteri_no = a.ilk7
                            AND t.reftur = a.hestur
                            AND t.refsirano = a.ekno
                            AND a.durum = 0
   WHERE 1 = 1
     AND t.tip = 'KMH'
     AND NVL (a.alac, 0) <> 0;
GRANT SELECT ON tmp_kmh_trbac_tutar_03 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;

DROP TABLE tmp_kmh_trbac_tutar_04;
CREATE TABLE tmp_kmh_trbac_tutar_04 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no,
         NVL (b.alac, 0) alac
    FROM tmp_trbac_fct_01 t
         INNER JOIN extr.fs_gunluk_hplandet_sg b
                         ON     1 = 1
                            AND t.kst_trh = b.tarih
                            AND t.refsube = b.sube
                            AND 'C' = b.sinif
                            AND t.musteri_no = b.ilk7
                            AND t.reftur = b.hestur
                            AND t.refsirano = b.ekno
                            AND b.durum = 0
   WHERE 1 = 1
     AND t.tip = 'KMH'
     AND NVL (b.alac, 0) <> 0;
GRANT SELECT ON tmp_kmh_trbac_tutar_04 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;

DROP TABLE tmp_kmh_trbac_tutar_07;
CREATE TABLE tmp_kmh_trbac_tutar_07 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no,
         NVL (a.alac, 0) alac
    FROM tmp_trbac_fct_01 t
         INNER JOIN extr.fs_gunluk_hplandet_sg a
                         ON     1 = 1
                            AND LAST_DAY (ADD_MONTHS (t.kst_trh, - 1)) = a.tarih
                            AND t.refsube = a.sube
                            AND 'C' = a.sinif
                            AND t.musteri_no = a.ilk7
                            AND 'KR' = a.hestur
                            AND t.kmh_kr_ekno = a.ekno
                            AND a.durum = 0
   WHERE 1 = 1
     AND t.tip = 'KMH'
     AND NVL (a.alac, 0) <> 0;
GRANT SELECT ON tmp_kmh_trbac_tutar_07 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;

DROP TABLE tmp_kmh_trbac_tutar_08;
CREATE TABLE tmp_kmh_trbac_tutar_08 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
  SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no,
         NVL (b.alac, 0) alac
    FROM tmp_trbac_fct_01 t
         INNER JOIN extr.fs_gunluk_hplandet_sg b
                         ON     1 = 1
                            AND t.kst_trh = b.tarih
                            AND t.refsube = b.sube
                            AND 'C' = b.sinif
                            AND t.musteri_no = b.ilk7
                            AND 'KR' = b.hestur
                            AND t.kmh_kr_ekno = b.ekno
                            AND b.durum = 0
   WHERE 1 = 1
     AND t.tip = 'KMH'
     AND NVL (b.alac, 0) <> 0;
GRANT SELECT ON tmp_kmh_trbac_tutar_08 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;

*/


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_TUTAR4',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1295;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_tutar4
  SELECT f.kst_trh, f.tip, f.refsube, f.musteri_no, f.reftur, f.refsirano, f.kmh_kr_ekno,
         NVL (t.anaparayuzde_kalantahsilat, 0) AS anaparayuzde_kalantahsilat,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_fct_01 f
         INNER JOIN (
                       SELECT v_tarih AS kst_trh,
                              sube, sinif, ilk7, hestur, ekno,
                          SUM (NVL (anaparayuzde_kalantahsilat, 0)) AS anaparayuzde_kalantahsilat
                         FROM extr.fs_krtahakkuk
                        WHERE 1 = 1
                          AND tarih <= v_tarih
                          AND NVL (anaparayuzde_kalantahsilat, 0) <> 0
                     GROUP BY sube, sinif, ilk7, hestur, ekno
                    ) t
                    ON     1 = 1
                       AND f.kst_trh = t.kst_trh
                       AND f.refsube = t.sube
                       AND 'C' = t.sinif
                       AND f.musteri_no = t.ilk7
                       AND f.reftur = t.hestur
                       AND f.refsirano = t.ekno
   WHERE 1 = 1;

      COMMIT;
      v_line_no:=1300;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_TUTAR',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1305;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_tutar
  SELECT t.kst_trh, t.refsube, t.reftur, t.refsirano, t.musteri_no,
         NVL (a.odenmeyen_kredi_tutari, 0) AS odenmeyen_kredi_tutari,
                       /*NVL (a.odenmeyen_kredi_tutari, 0) +*/ NVL (CASE WHEN t.reftur = 'KR' THEN 0 ELSE c.borc - c.alac END, 0) AS kmh_tutar1,
         NVL (CASE WHEN t.reftur = 'KR' THEN 0 ELSE c.borc - c.alac END, 0) AS kmh_tutar2,
         NVL (b.anaparayuzde, 0) AS anaparayuzde,
         NVL (d.kmh_faiz_tutari, 0) AS kmh_faiz_tutari,
         NVL (b.anaparayuzde, 0) + NVL (d.kmh_faiz_tutari, 0) AS kmh_tutar3,
         NVL (f3.anaparayuzde_kalantahsilat, 0) AS kmh_tutar4,
         --(NVL (e.alac, 0) - NVL (f.alac, 0) + NVL (e2.alac, 0) - NVL (f2.alac, 0)) kmh_tutar5
         NVL (a.odenmeyen_kredi_tutari, 0) AS kmh_tutar5,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_fct_01 t
         LEFT OUTER JOIN trfm.tmp_trbac_kmh_tutar_01 A
                         ON     1 = 1
                            AND t.refsube=a.sube
                            AND t.reftur = a.hestur
                            AND t.musteri_no=a.ilk7
                            AND t.refsirano=a.ekno
                            AND t.kst_trh = a.kst_trh
         LEFT OUTER JOIN trfm.tmp_trbac_kmh_tutar3_01 b
                         ON     1 = 1
                            AND b.sube = t.refsube
                            AND b.sinif = 'C'
                            AND b.ilk7 = t.musteri_no
                            AND b.hestur = t.reftur
                            AND b.ekno = t.refsirano
                            AND b.kst_trh = t.kst_trh
         LEFT OUTER JOIN extr.fs_gunluk_hplandet_sg c
                         ON     1 = 1
                            AND c.sube=t.refsube
                            AND c.sinif = 'C'
                            AND c.ilk7 =t.musteri_no
                            AND c.hestur =t.reftur
                            AND c.ekno=t.refsirano
                            AND c.tarih =t.kst_trh
                            AND c.durum = 0
         LEFT OUTER JOIN trfm.tmp_trbac_kmh_tutar3_02 d
                         ON     1 = 1
                            AND t.kst_trh = d.kst_trh
                            AND t.refsube=d.refsube
                            AND t.reftur = d.reftur
                            AND t.refsirano=d.refsirano
                            AND t.musteri_no=d.musteri_no
                  /*     LEFT OUTER JOIN tmp_kmh_trbac_tutar_03 e
                         ON     1 = 1
                            AND T.KST_TRH = e.kst_trh
                            AND T.REFSUBE=e.refsube
                            AND t.reftur = e.reftur
                            AND T.REFSIRANO=e.refsirano
                            AND T.MUSTERI_NO=e.musteri_no
         LEFT OUTER JOIN tmp_kmh_trbac_tutar_04 f
                         ON     1 = 1
                            AND T.KST_TRH = f.kst_trh
                            AND T.REFSUBE=f.refsube
                            AND t.reftur = f.reftur
                            AND T.REFSIRANO=f.refsirano
                            AND T.MUSTERI_NO=f.musteri_no
         LEFT OUTER JOIN tmp_kmh_trbac_tutar_07 e2
                         ON     1 = 1
                            AND T.KST_TRH = e2.kst_trh
                            AND T.REFSUBE=e2.refsube
                            AND t.reftur = e2.reftur
                            AND T.REFSIRANO=e2.refsirano
                            AND T.MUSTERI_NO=e2.musteri_no
         LEFT OUTER JOIN tmp_kmh_trbac_tutar_08 f2
                         ON     1 = 1
                            AND T.KST_TRH = f2.kst_trh
                            AND T.REFSUBE=f2.refsube
                            AND t.reftur = f2.reftur
                            AND T.REFSIRANO=f2.refsirano
                            AND T.MUSTERI_NO=f2.musteri_no
      */
         LEFT OUTER JOIN trfm.tmp_trbac_kmh_tutar4 f3
                         ON     1 = 1
                            AND t.kst_trh = f3.kst_trh
                            AND t.refsube = f3.refsube
                            AND t.musteri_no = f3.musteri_no
                            AND t.reftur = f3.reftur
                            AND t.refsirano = f3.refsirano
   WHERE 1 = 1
     AND t.tip = 'KMH'
     AND (
              NVL (a.odenmeyen_kredi_tutari, 0) <> 0
           OR NVL (CASE WHEN t.reftur = 'KR' THEN 0 ELSE c.borc - c.alac END, 0) <> 0
           OR NVL (b.anaparayuzde, 0) + NVL (d.kmh_faiz_tutari, 0) <> 0
           OR NVL (f3.anaparayuzde_kalantahsilat, 0) <> 0
           --OR NVL (e.alac, 0) - NVL (f.alac, 0) <> 0
         )
     AND t.kst_trh = v_tarih;

      COMMIT;
      v_line_no:=1310;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_TKRD_HSP_OZL_DRM_KOD',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1315;
--RKHSOD --HESAP ÖZEL DRM KD
--TKRD

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_tkrd_hsp_ozl_drm_kod

              /*   if bkrd_rec.durum in(3,93) THEN
        if NVL(retval.RKTU19,0)>0 THEN
            retval.RKHSOD := 2; --aktif gecikmede
        elsif NVL(retval.RKTU18,0)=0 THEN
            if retval.RKRSGK NOT in(3,4,5) THEN
                retval.RKHSOD := 1;
            ELSE
                retval.RKHSOD:=99;
            END if;
        elsif  NVL(retval.RKTU20,0) >0 THEN
           retval.RKHSOD := 7; --ödenmemiþ faiz borcu var
        elsif     NVL(retval.RKTU21,0) >0 THEN
           retval.RKHSOD := 8; --ödenmemiþ komisyon borcu var
        END if;
    elsif  bkrd_rec.durum in(6,7,8,9,10,11,98) THEN
          retval.RKHSOD:=3; --kapalý
    END if;*/

  SELECT v_tarih kst_trh, 'TKRD' tip,
         x.sube, x.reftur, x.refsirano, x.musteri, x.durum,
         CASE WHEN NVL (q.musteri_no, 0) > 0 THEN 1 ELSE 0 END musteri_takip_f, --RKRSGK kodundaki gibi 3, 4 ve 5 risk kodlarýný aldým
         y.rktu19, --tutar19
         y.rktu20, --tutar20
         z.rktu21, --tutar21
         (NVL (y.rktu19, 0) + NVL (y.rktu20, 0) + NVL (z.rktu21, 0)) rktu18, --retval.RKTU18 := NVL(retval.RKTU19,0) + NVL(retval.RKTU20,0)+ NVL(retval.RKTU21,0)
         CASE               /*WHEN x.durum IN (3, 93) AND NVL (y.rktu19, 0) > 0 THEN 1 --aktif gecikmede
              WHEN x.durum IN (3, 93) AND NVL (y.rktu19, 0) <= 0 AND (NVL (y.rktu19, 0) + NVL (y.rktu20, 0) + NVL (z.rktu21, 0)) = 0 AND CASE WHEN NVL (q.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
              WHEN x.durum IN (3, 93) AND NVL (y.rktu19, 0) <= 0 AND (NVL (y.rktu19, 0) + NVL (y.rktu20, 0) + NVL (z.rktu21, 0)) = 0 AND CASE WHEN NVL (q.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 1 THEN 1
              WHEN x.durum NOT IN (3, 93) AND NVL (y.rktu20, 0) > 0 THEN 1 --ödenmemiþ faiz borcu var
              WHEN x.durum NOT IN (3, 93) AND NVL (y.rktu20, 0) <= 0 AND NVL (z.rktu21, 0) > 0 THEN 1 --ödenmemiþ komisyon borcu var
              WHEN x.durum IN (6, 7, 8, 9, 10, 11, 98) THEN 2 --kapalý*/
              WHEN x.durum IN (0, 1, 2, 3) THEN 1
              WHEN x.durum IN (10, 11, 92, 98, 99) THEN 2
              WHEN x.durum IN (4, 5, 6, 7, 8, 9) THEN 3
                   ELSE 2
         END tkrd_rkhsod, --hesap Özel drm kd
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ x
         LEFT OUTER JOIN (
                            SELECT v_tarih kst_trh,
                                   sube, reftur, refsirano,
                                   SUM (NVL (anapara, 0)) rktu19,
                                   SUM (NVL (faiz, 0)) rktu20
                              FROM extr.fs_bkrhrkt
                             WHERE 1 = 1
                               --AND sube = bkrd_rec.sube
                               --AND reftur = bkrd_rec.reftur
                               --AND refsirano = bkrd_rec.refsirano
                               AND durum = 0
                               AND vadetarih < v_tarih
                               AND TO_DATE (odemetarih, 'DD/MM/YYYY') <= v_tarih
                               AND TO_DATE (updtarih, 'DD/MM/YYYY') <= v_tarih
                               AND (
                                        NVL (anapara, 0) <> 0
                                     OR NVL (faiz, 0) <> 0
                                   )
                          GROUP BY sube, reftur, refsirano
                         ) y
                         ON     1 = 1
                            AND v_tarih = y.kst_trh
                            AND x.sube = y.sube
                            AND x.reftur = y.reftur
                            AND x.refsirano = y.refsirano
         LEFT OUTER JOIN (
                            SELECT v_tarih kst_trh,
                                   t.sube, t.reftur, t.refsirano,
                                   CASE WHEN t.katkipayi_ilk7 <> b.musteri THEN 0
                                             ELSE b.aciliskomisyon
                                                  END rktu21 --ln_rktu01_acilis_kom
                              FROM extr.fs_tkrd_detay t,
                                   ofsdata.bkrmaster_aysonu              /*extr.fs_bkrmaster tablosu proda atýlacak*/ b
                             WHERE 1 = 1
                               --AND t.sube = bkrd_rec.sube
                               --AND t.reftur = bkrd_rec.reftur
                               --AND t.refsirano = bkrd_rec.refsirano
                               AND t.sube = b.sube
                               AND t.reftur = b.reftur
                               AND t.refsirano = b.refsirano
                               AND t.katkipayi_vade < v_tarih
                               AND t.katkipayi_tahsiltarih IS NULL
                               AND b.acilistarih <= v_tarih
                               AND CASE WHEN t.katkipayi_ilk7 <> b.musteri THEN 0
                                             ELSE b.aciliskomisyon
                                                  END <> 0
                         ) z
                         ON     1 = 1
                            AND v_tarih = z.kst_trh
                            AND x.sube = z.sube
                            AND x.reftur = z.reftur
                            AND x.refsirano = z.refsirano
         LEFT JOIN (SELECT DISTINCT kst_trh, musteri_no FROM trfm.tmp_trbac_tkp_tutar) q
                         ON     1 = 1
                            AND v_tarih = q.kst_trh
                            AND x.musteri = q.musteri_no
   WHERE 1 = 1
     AND x.acilistarih <= v_tarih;
     --AND (NVL (y.rktu19, 0) + NVL (y.rktu20, 0) + NVL (z.rktu21, 0)) <> 0

      COMMIT;
      v_line_no:=1320;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_HSP_OZL_DRM_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1325;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_hsp_ozl_drm_01
     SELECT k.kst_trh, k.tip, k.musteri_no, k.refsube, k.reftur, k.refsirano,
            k.kmh_mt_ekno, k.kmh_kr_ekno, km.sondurum,
            MAX (TO_DATE (hkt.updtarih, 'DD/MM/YYYY')) max_updtarih_hkt,
            MAX (TO_DATE (ekt.updtarih, 'DD/MM/YYYY')) max_updtarih_ekt,
            MAX (TO_DATE (hkr.updtarih, 'DD/MM/YYYY')) max_updtarih_hkr,
            MAX (TO_DATE (ekr.updtarih, 'DD/MM/YYYY')) max_updtarih_ekr,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbac_fct_01 k
            INNER JOIN ofsdata.kmhmas_aysonu km
                            ON     1 = 1
                               AND k.refsube = km.sube
                               AND k.musteri_no = km.kmhilk7
                               AND k.refsirano = km.krdekno
                               AND km.sondurum IN (4, 9)
            INNER JOIN extr.fs_hplandet_sg hkt
                            ON     1 = 1
                               AND k.refsube = hkt.sube
                               AND 'C' = hkt.sinif
                               AND k.musteri_no = hkt.ilk7
                               AND 'KT' = hkt.hestur
                               AND k.refsirano = hkt.ekno
                               AND 0 = hkt.durum
                               AND 0 =   hkt.borc1 - hkt.alac1 + hkt.borc2 - hkt.alac2 + hkt.borc3 - hkt.alac3 + hkt.borc4 - hkt.alac4
                                       + hkt.borc5 - hkt.alac5 + hkt.borc6 - hkt.alac6 + hkt.borc7 - hkt.alac7 + hkt.borc8 - hkt.alac8
                                       + hkt.borc9 - hkt.alac9 + hkt.borc10 - hkt.alac10 + hkt.borc11 - hkt.alac11 + hkt.borc12 - hkt.alac12
            INNER JOIN extr.fs_eskiplan_sg ekt
                            ON     1 = 1
                               AND k.refsube = ekt.sube
                               AND 'C' = ekt.sinif
                               AND k.musteri_no = ekt.ilk7
                               AND 'KT' = ekt.hestur
                               AND k.refsirano = ekt.ekno
                               AND 0 = ekt.durum
                               AND 0 =   ekt.borc1 - ekt.alac1 + ekt.borc2 - ekt.alac2 + ekt.borc3 - ekt.alac3 + ekt.borc4 - ekt.alac4
                                       + ekt.borc5 - ekt.alac5 + ekt.borc6 - ekt.alac6 + ekt.borc7 - ekt.alac7 + ekt.borc8 - ekt.alac8
                                       + ekt.borc9 - ekt.alac9 + ekt.borc10 - ekt.alac10 + ekt.borc11 - ekt.alac11 + ekt.borc12 - ekt.alac12
            INNER JOIN extr.fs_hplandet_sg hkr
                            ON     1 = 1
                               AND k.refsube = hkr.sube
                               AND 'C' = hkr.sinif
                               AND k.musteri_no = hkr.ilk7
                               AND 'KR' = hkr.hestur
                               AND k.kmh_kr_ekno = hkr.ekno
                               AND 0 = hkr.durum
                               AND 0 =   hkr.borc1 - hkr.alac1 + hkr.borc2 - hkr.alac2 + hkr.borc3 - hkr.alac3 + hkr.borc4 - hkr.alac4
                                       + hkr.borc5 - hkr.alac5 + hkr.borc6 - hkr.alac6 + hkr.borc7 - hkr.alac7 + hkr.borc8 - hkr.alac8
                                       + hkr.borc9 - hkr.alac9 + hkr.borc10 - hkr.alac10 + hkr.borc11 - hkr.alac11 + hkr.borc12 - hkr.alac12
            INNER JOIN extr.fs_eskiplan_sg ekr
                            ON     1 = 1
                               AND k.refsube = ekr.sube
                               AND 'C' = ekr.sinif
                               AND k.musteri_no = ekr.ilk7
                               AND 'KR' = ekr.hestur
                               AND k.kmh_kr_ekno = ekr.ekno
                               AND 0 = ekr.durum
                               AND 0 =   ekr.borc1 - ekr.alac1 + ekr.borc2 - ekr.alac2 + ekr.borc3 - ekr.alac3 + ekr.borc4 - ekr.alac4
                                       + ekr.borc5 - ekr.alac5 + ekr.borc6 - ekr.alac6 + ekr.borc7 - ekr.alac7 + ekr.borc8 - ekr.alac8
                                       + ekr.borc9 - ekr.alac9 + ekr.borc10 - ekr.alac10 + ekr.borc11 - ekr.alac11 + ekr.borc12 - ekr.alac12
      WHERE 1 = 1
        AND k.tip = 'KMH'
        AND (hkt.updtarih IS NOT NULL OR ekt.updtarih IS NOT NULL)
        AND (hkr.updtarih IS NOT NULL OR ekr.updtarih IS NOT NULL)
   GROUP BY k.kst_trh, k.tip, k.musteri_no, k.refsube, k.reftur, k.refsirano,
         k.kmh_mt_ekno, k.kmh_kr_ekno, km.sondurum;

      COMMIT;
      v_line_no:=1330;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_HSP_OZL_DRM_02',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1335;

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_hsp_ozl_drm_02
  SELECT GREATEST (
                   NVL (k.max_updtarih_hkt, TO_DATE ('01/01/1900', 'DD/MM/YYYY')),
                   NVL (k.max_updtarih_ekt, TO_DATE ('01/01/1900', 'DD/MM/YYYY')),
                   NVL (k.max_updtarih_hkr, TO_DATE ('01/01/1900', 'DD/MM/YYYY')),
                   NVL (k.max_updtarih_ekr, TO_DATE ('01/01/1900', 'DD/MM/YYYY'))
                  ) AS kmh_hsp_kpns_trh,
         k.kst_trh,
         k.refsube,
         k.reftur,
         k.refsirano,
         k.musteri_no,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_kmh_hsp_ozl_drm_01 k
   WHERE 1 = 1;

      COMMIT;
      v_line_no:=1340;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_KMH_HSP_OZL_DRM',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1345;
--RKHSOD --HESAP ÖZEL DRM KD
--KMH

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_kmh_hsp_ozl_drm

              /*     if (retval.Rktu01>0 and retval.rkhsod is NULL and retval.rkrsgk NOT in(3,4,5)) THEN retval.rkhsod:=1;
       END if;
        if (kmh_rec.durum=1 and kmh_rec.kmhkrdkul=0 and  retval.rkhsod is null) THEN retval.rkhsod := 3;

       if (retval.Rktu01>0 and retval.rkhsod is NULL and retval.rkrsgk NOT in(3,4,5))  THEN
            retval.rkhsod:=1;
       END if;

        if (kmh_rec.durum=1 and kmh_rec.kmhkrdkul=0 and  retval.rkhsod is null) THEN
          retval.rkhsod := 3;
          retval.rkhskt := GREATEST(kmh_rec.updtarih2,NVL(ld_krupd_tarih,NULL_TARIH));
        END if;

         if ( retval.rkhsod is NULL and retval.rkrsgk =1)  THEN retval.rkhsod:=1;
       END if;*/

  SELECT a.kst_trh,a.refsube, a.reftur, a.musteri_no,a.kmh_mt_ekno,a.refsirano,
         km.oncdurum, km.sondurum, km.kmhkrdkul,
         t1.tutar1, --RKTU02
         kmhttr.odenmeyen_kredi_tutari, --RKTU20     CASE WHEN odenmeyen_kredi_tutari <> 0 THEN rkhsod = 7 END
         NVL (t1.tutar1, 0) + NVL (kmhttr.odenmeyen_kredi_tutari, 0) rktu01, --retval.RKTU01 := retval.RKTU02 + retval.RKTU20;
         z.kmh_ld_krupd_tarih, --ld_date
         CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END musteri_takip_f,
              /*
         CASE WHEN km.sondurum IN (1, 2) THEN 1
              WHEN km.sondurum = 3 THEN 3
              WHEN km.sondurum IN (4, 9) THEN 2
              --WHEN NVL (t1.tutar1, 0) + NVL (kmhttr.odenmeyen_kredi_tutari, 0) > 0 AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
              --WHEN km.sondurum = 1 AND km.kmhkrdkul = 0 THEN 2
              --WHEN NVL (t1.tutar1, 0) + NVL (kmhttr.odenmeyen_kredi_tutari, 0) > 0 AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
              --WHEN CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
                   ELSE NULL
                        END kmh_rkhsod
*/
         CASE WHEN z.kmh_hsp_kpns_trh IS NOT NULL THEN 2 ELSE 1 END kmh_rkhsod,
         z.kmh_hsp_kpns_trh,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_fct_01 a
         LEFT OUTER JOIN trfm.tmp_trbac_tutar1 t1
                         ON     1 = 1
                            AND a.kst_trh = t1.kst_trh
                            AND a.refsube = t1.refsube
                            AND a.reftur = t1.reftur
                            AND a.refsirano = t1.refsirano
                            AND a.musteri_no = t1.musteri_no
                            AND a.tip = 'KMH'
         LEFT OUTER JOIN trfm.tmp_trbac_kmh_tutar kmhttr
                         ON     1 = 1
                            AND a.kst_trh = kmhttr.kst_trh
                            AND a.refsube = kmhttr.refsube
                            AND a.reftur = kmhttr.reftur
                            AND a.refsirano = kmhttr.refsirano
                            AND a.musteri_no = kmhttr.musteri_no
                            AND a.tip = 'KMH'
         LEFT OUTER JOIN (
                            SELECT h.tarih kst_trh, h.sube, h.sinif, h.ilk7 musteri_no, t.kmhhestur mt_hestur, t.kmhekno mt_ekno, 'KT' kt_hestur, t.krdekno kt_ekno, h.hestur kr_hestur, h.ekno kr_ekno,
                                   MAX (TO_DATE (h.updtarih, 'DD/MM/YYYY')) kmh_ld_krupd_tarih --ld_date
                              FROM ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t,
                                   extr.fs_sube s,
                                   extr.fs_gunluk_hplandet_sg h,
                                   extr.fs_kmhmas_detay d
                             WHERE 1 = 1
                               AND t.sube = h.sube
                               AND 'C' = h.sinif
                               AND t.kmhilk7 = h.ilk7
                               AND 'KR' = h.hestur
                               AND d.krekno = h.ekno
                               AND 0 = h.durum
                               AND v_tarih = h.tarih
                               AND t.sube = s.sube
                               AND t.sube = d.sube
                               AND t.kmhilk7 = d.kmhilk7
                               AND t.tip = d.tip
                               AND t.krdekno <> 0
                               AND t.tip IN (21, 22, 25, 26, 27, 28)
                          GROUP BY h.tarih, h.sube, h.sinif, h.ilk7, t.kmhhestur, t.kmhekno, t.krdekno, h.hestur, h.ekno
                         ) z
                         ON     1 = 1
                            AND a.kst_trh = z.kst_trh
                            AND a.refsube = z.sube
                            AND a.reftur = z.kt_hestur
                            AND a.refsirano = z.kt_ekno
                            AND a.musteri_no = z.musteri_no
                            AND a.tip = 'KMH'
         LEFT OUTER JOIN (SELECT DISTINCT kst_trh, musteri_no FROM trfm.tmp_trbac_tkp_tutar) w
                         ON     1 = 1
                            AND a.kst_trh = w.kst_trh
                            AND a.musteri_no = w.musteri_no
                            AND a.tip = 'KMH'
         LEFT OUTER JOIN ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ km
                         ON     1 = 1
                            AND a.refsube = km.sube
                            AND a.musteri_no = km.kmhilk7
                            AND a.reftur = 'KT'
                            AND a.refsirano = km.krdekno
                            AND a.tip = 'KMH'
         LEFT OUTER JOIN trfm.tmp_trbac_kmh_hsp_ozl_drm_02 z
                         ON     1 = 1
                            AND a.kst_trh = z.kst_trh
                            AND a.refsube = z.refsube
                            AND a.reftur = z.reftur
                            AND a.refsirano = z.refsirano
                            AND a.musteri_no = z.musteri_no
                            AND a.tip = 'KMH'
   WHERE 1 = 1
     AND a.tip = 'KMH';

      COMMIT;
      v_line_no:=1350;

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBAC_NKRD_HSP_OZL_DRM_KOD',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1355;
--RKHSOD --HESAP ÖZEL DRM KD
--NKRD

   INSERT               /*+ APPEND */ INTO trfm.tmp_trbac_nkrd_hsp_ozl_drm_kod


--  if krdmaster_rec.durum = 2 THEN
--      if retval.RKTU19>0 THEN                    /**/
--          retval.RKHSOD := 2; --aktif gecikmede
--      elsif    NVL(retval.RKTU18,0)=0 THEN
--          if retval.RKRSGK NOT in(3,4,5) THEN
--              retval.RKHSOD := 1; --aktif sorunsuz
--          ELSE
--              retval.RKHSOD:=99;
--            END if;
--       elsif     NVL(retval.RKTU20,0) >0 THEN
--         retval.RKHSOD := 7; --ödenmemiþ faiz borcu var
--      elsif     NVL(retval.RKTU21,0) >0 THEN
--         retval.RKHSOD := 8; --ödenmemiþ komisyon borcu var
--      END if;
--  elsif  krdmaster_rec.durum = 4 THEN
--      retval.RKHSOD := 3; --kapalý
--  END if;

  SELECT v_tarih AS kst_trh,
         CASE WHEN k.yeni_kul_durum = 3 THEN NULL ELSE (CASE WHEN k.vade <= v_tarih THEN (CASE WHEN NVL (kad.ln_gecikmis_anapara, 0) = 0 THEN NVL (k.kullanimtutar, 0) - NVL (k.geriodenen, 0) ELSE NVL (kad.ln_gecikmis_anapara, 0) END) ELSE 0 END) END rktu19,
         (CASE WHEN (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) < 0 THEN 0 ELSE (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) END) AS rktu20,
         (NVL (rt.ln_komisyon, 0) - NVL (tt.t_komisyon, 0)) AS rktu21,
         CASE WHEN k.yeni_kul_durum = 3
              THEN (CASE WHEN (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) < 0 THEN 0 ELSE (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) END)
              ELSE (CASE WHEN k.yeni_kul_durum = 3 THEN NULL ELSE (CASE WHEN k.vade <= v_tarih THEN (CASE WHEN NVL (kad.ln_gecikmis_anapara, 0) = 0 THEN NVL (k.kullanimtutar, 0) - NVL (k.geriodenen, 0) ELSE NVL (kad.ln_gecikmis_anapara, 0) END) ELSE 0 END) END)
                   + (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0))
                   + (NVL (rt.ln_komisyon, 0) - NVL (tt.t_komisyon, 0))
         END AS rktu18,
--         CASE WHEN k.durum = 4 THEN 3
--              WHEN k.durum = 2 AND CASE WHEN k.yeni_kul_durum = 3 THEN NULL ELSE (CASE WHEN k.vade <= v_tarih THEN (CASE WHEN NVL (kad.ln_gecikmis_anapara, 0) = 0 THEN NVL (k.kullanimtutar, 0) - NVL (k.geriodenen, 0) ELSE NVL (kad.ln_gecikmis_anapara, 0) END) ELSE 0 END) END > 0 THEN 2 --rktu19
--              WHEN k.durum = 2 AND NVL (CASE WHEN     k.yeni_kul_durum = 3 THEN NULL ELSE (CASE WHEN k.vade <= v_tarih THEN (CASE WHEN NVL (kad.ln_gecikmis_anapara, 0) = 0 THEN NVL (k.kullanimtutar, 0) - NVL (k.geriodenen, 0) ELSE NVL (kad.ln_gecikmis_anapara, 0) END) ELSE 0 END) END,0) <= 0
--                                                  AND CASE WHEN k.yeni_kul_durum = 3 THEN (CASE WHEN (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) < 0 THEN 0 ELSE (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) END)
--                                                      ELSE CASE WHEN k.yeni_kul_durum = 3 THEN NULL ELSE (CASE WHEN k.vade <= v_tarih THEN (CASE WHEN NVL (kad.ln_gecikmis_anapara, 0) = 0 THEN NVL (k.kullanimtutar, 0) - NVL (k.geriodenen, 0) ELSE NVL (kad.ln_gecikmis_anapara, 0) END) ELSE 0 END) END               /*rktu19*/ + (CASE WHEN (rt.ln_faiz - tt.t_faiz) < 0 THEN 0 ELSE (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) END) + (NVL (rt.ln_komisyon, 0) - NVL (tt.t_komisyon, 0))
--                                                           END = 0 --rktu18
--                   AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
--              WHEN CASE WHEN k.yeni_kul_durum = 3 THEN (CASE WHEN (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) < 0 THEN 0 ELSE (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) END)
--                                  ELSE CASE WHEN k.yeni_kul_durum = 3 THEN NULL ELSE (CASE WHEN k.vade <= v_tarih THEN (CASE WHEN NVL (kad.ln_gecikmis_anapara, 0) = 0 THEN NVL (k.kullanimtutar, 0) - NVL (k.geriodenen, 0) ELSE NVL (kad.ln_gecikmis_anapara, 0) END) ELSE 0 END) END               /*rktu19*/ + (CASE WHEN (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) < 0 THEN 0 ELSE (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) END) + (NVL (rt.ln_komisyon, 0) - NVL (tt.t_komisyon, 0))
--                                       END
--                                               = 0 --rktu18
--                   AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 1 THEN 3
--              WHEN (NVL (rt.ln_faiz, 0) - NVL (tt.t_faiz, 0)) > 0 THEN 7
--              WHEN (NVL (rt.ln_komisyon, 0) - NVL (tt.t_komisyon, 0)) > 0 THEN 8
         CASE WHEN k.durum IN (0, 1, 2, 3) THEN 1
              WHEN k.durum IN (4, 9) THEN 2
                   ELSE 2
         END rkhsod,
         k.yeni_kul_durum, k.vade, k.kullanimtutar,k.geriodenen,k.durum,k.sube,k.reftur,k.refsirano, k.musteri,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM ofsdata.krdmaster_aysonu               /*extr.fs_krdmaster tablosu proda atýlacak*/ k
         LEFT OUTER JOIN (
                            SELECT v_tarih kst_trh, sube, reftur, refsirano,
                                   SUM (NVL (faiz, 0)) ln_faiz, --rktu20, --ln_faiz
                                   SUM (NVL (komisyon1, 0)) ln_komisyon --rktu21 --ln_komisyon
                              FROM extr.fs_reftahakkuk
                             WHERE 1 = 1
                               --AND sube = arg_sube
                               --AND reftur = arg_reftur
                               --AND refsirano = arg_refsirano
                               AND tarih <= v_tarih
                               AND (
                                        NVL (faiz, 0) <> 0
                                     OR NVL (komisyon1, 0) <> 0
                                   )
                          GROUP BY sube, reftur, refsirano
                          --SELECT * FROM extr.fs_reftahakkuk;
                         ) rt
                         ON     1 = 1
                            AND k.sube = rt.sube
                            AND k.reftur = rt.reftur
                            AND k.refsirano = rt.refsirano
                            AND v_tarih = rt.kst_trh
         LEFT OUTER JOIN (
                            SELECT v_tarih kst_trh, sube, reftur, refsirano,
                                   NVL (TRUNC (SUM (NVL (tutar, 0) - NVL (odenen_tutar, 0))), 0) ln_gecikmis_anapara
                              FROM extr.fs_krd_anapara_daginik
                             WHERE 1 = 1
                               --AND sube = 434 AND reftur = 'DK' AND refsirano = 366
                               AND tutar <> odenen_tutar
                               AND TO_DATE (tarih, 'DD/MM/YYYY') < v_tarih
                               AND durum <> 9
                               AND NVL (tutar, 0) - NVL (odenen_tutar, 0) <> 0
                          GROUP BY sube, reftur, refsirano
                          --SELECT * FROM extr.fs_krd_anapara_daginik;
                         ) kad
                         ON     1 = 1
                            AND k.sube = kad.sube
                            AND k.reftur = kad.reftur
                            AND k.refsirano = kad.refsirano
                            AND v_tarih = kad.kst_trh
         LEFT OUTER JOIN (
                            SELECT v_tarih AS kst_trh,
                                   sube, reftur, refsirano,
                                   NVL (SUM (kom1), 0) AS t_komisyon,
                                   NVL (SUM (faiz), 0) AS t_faiz
                              FROM extr.fs_krd_tahsilat_detay
                             WHERE 1 = 1
                               AND durum = 0
                               AND TO_DATE (fistarih, 'DD/MM/YYYY') > TO_DATE ('21/07/2003', 'DD/MM/YYYY')
                               AND TO_DATE (fistarih, 'DD/MM/YYYY') <= v_tarih
                               AND (NVL (faiz, 0) <> 0 OR NVL (faiz, 0) <> 0)
                          GROUP BY sube, reftur, refsirano
                         ) tt
                         ON     1 = 1
                            AND v_tarih = tt.kst_trh
                            AND k.sube = tt.sube
                            AND k.reftur = tt.reftur
                            AND k.refsirano = tt.refsirano
         LEFT OUTER JOIN (SELECT DISTINCT kst_trh, musteri_no FROM trfm.tmp_trbac_tkp_tutar) w
                         ON     1 = 1
                            AND v_tarih = w.kst_trh
                            AND k.musteri = w.musteri_no
   WHERE 1 = 1;
     --AND k.sube || k.reftur || k.refsirano = '222TK672'

   COMMIT;
   v_line_no:=1360;


--SELECT * FROM ofsdata.krdmaster_aysonu              /*extr.fs_krdmaster tablosu proda atýlacak*/ k;
--SELECT * FROM tmp_trbac_nkrd_hsp_ozl_drm_kod;

--TMEK için Hesap Özel Durum Kodu 3

              /*--DIM için Hesap Özel Durum Kodu
         CASE WHEN ithmaster.durum <> 7 AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
              WHEN ithmaster.durum <> 7 AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 1 THEN 99
              WHEN ithmaster.durum = 0 THEN 1
              WHEN ithmaster.durum = 10 THEN 3
              WHEN ithmaster.durum = 7 THEN 3
                   END ith_rkhsod*/









----KMH Hesap Kapanýþ Tarihi hesaplama;
----get_updtarihfor_kr (kmh_rec.kmhilk7)
--DROP TABLE get_updtarihfor_kr_tmp01;
--CREATE TABLE get_updtarihfor_kr_tmp01 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
--  SELECT v_tarih kst_trh,
--         sube, sinif, ilk7, hestur, ekno,
--         MAX (max_updtarih) ld_date
--    FROM (
--            SELECT sube, sinif, ilk7, hestur, ekno,
--                   MAX (TRUNC (updtarih)) max_updtarih
--              FROM extr.fs_hplandet_sg
--             WHERE 1 = 1
--               AND sinif = 'C'
--               AND durum = 0
--               AND hestur = 'KR'
--               AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
--          GROUP BY sube, sinif, ilk7, hestur, ekno
--          UNION ALL
--            SELECT sube, sinif, ilk7, hestur, ekno,
--                   MAX (TRUNC (updtarih)) max_updtarih
--              FROM extr.fs_eskiplan_sg
--             WHERE 1 = 1
--               AND sinif = 'C'
--               AND durum = 0
--               AND hestur = 'KR'
--               AND TO_DATE (actarih, 'DD/MM/YYYY') <= v_tarih
--          GROUP BY sube, sinif, ilk7, hestur, ekno
--         )
--GROUP BY sube, sinif, ilk7, hestur, ekno;
--GRANT SELECT ON get_updtarihfor_kr_tmp01 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
----SELECT * FROM extr.fs_hplandet_sg;
----SELECT * FROM extr.fs_eskiplan_sg;
----SELECT * FROM get_updtarihfor_kr_tmp01;


              /*         LEFT OUTER JOIN get_updtarihfor_kr_tmp02 kmh_hkt
                         ON     1 = 1
                            AND a.kst_trh = kmh_hkt.kst_trh
                            AND a.musteri_no = kmh_hkt.musteri_no
                            AND a.refsube = kmh_hkt.refsube
                            AND a.reftur = kmh_hkt.reftur
                            AND a.refsirano = kmh_hkt.refsirano
                            AND a.tip = kmh_hkt.tip
                            AND a.kmh_mt_ekno = kmh_hkt.kmh_mt_ekno
                            AND a.kmh_kr_ekno = kmh_hkt.kmh_kr_ekno*/

--
--DROP TABLE get_updtarihfor_kr_tmp02;
--CREATE TABLE get_updtarihfor_kr_tmp02 PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
--  SELECT CASE WHEN NVL (d1.durum, d2.durum) = 1 AND m.kmhkrdkul = 0 AND a.kmh_rkhsod IS NULL
--                   THEN GREATEST (TO_DATE (m.updtarih, 'DD/MM/YYYY'), TO_DATE (k.ld_date, 'DD/MM/YYYY'))
--         END kmh_hsp_kpns_trh_,
--         a.kst_trh, a.refsube, a.reftur, a.musteri_no, a.kmh_mt_ekno, a.refsirano
--    FROM tmp_trbac_kmh_hsp_ozl_drm a
--         INNER JOIN     ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ m
--                             ON     1 = 1
--                                AND a.refsube = m.sube
--                                AND 'C' = m.kmhsinif
--                                AND a.musteri_no = m.kmhilk7
--                                AND 'MT' = m.kmhhestur
--                                AND a.kmh_mt_ekno = m.kmhekno
--                                AND a.refsirano = m.krdekno
--         LEFT OUTER JOIN (
--                            SELECT h.kst_trh, h.sube, h.sinif, h.ilk7, t.kmhhestur, t.kmhekno,
--                                   --h.hestur kr_hestur, h.ekno kr_ekno,
--                                   MAX (h.ld_date) ld_date
--                              FROM ofsdata.kmhmas_aysonu              /*extr.fs_kmhmas tablosu proda atýlacak*/ t,
--                                   extr.fs_sube s,
--                                   get_updtarihfor_kr_tmp01 h,
--                                   extr.fs_kmhmas_detay d
--                             WHERE 1 = 1
--                               AND t.sube = s.sube
--                               AND t.sube = h.sube
--                               AND 'C' = h.sinif
--                               AND t.kmhilk7 = h.ilk7
--                               AND 'KR'= h.hestur
--                               AND d.krekno = h.ekno
--                               AND t.tip = d.tip
--                               AND t.sube = d.sube
--                               AND t.kmhilk7 = d.kmhilk7
--                               AND t.tip IN (21, 22, 25, 26, 27, 28)
--                               AND t.krdekno <> 0
--                          GROUP BY h.kst_trh, h.sube, h.sinif, h.ilk7, t.kmhhestur, t.kmhekno
--                                   --,h.hestur kr_hestur, h.ekno kr_ekno
--                          ) k
--                             ON     1 = 1
--                                AND a.kst_trh = k.kst_trh
--                                AND m.sube = k.sube
--                                AND m.kmhsinif = k.sinif
--                                AND m.kmhilk7 = k.ilk7
--                                AND m.kmhhestur = k.kmhhestur
--                                AND m.kmhekno = k.kmhekno
--                                AND TO_DATE (k.ld_date, 'DD/MM/YYYY') <> TO_DATE ('31/12/1899', 'DD/MM/YYYY')
--                                AND TO_DATE (k.ld_date, 'DD/MM/YYYY') <> TO_DATE ('01/01/1900', 'DD/MM/YYYY')
--         LEFT OUTER JOIN extr.fs_hplandet_sg d1
--                             ON     1 = 1
--                                AND m.sube = d1.sube
--                                AND m.kmhsinif = d1.sinif
--                                AND m.kmhilk7 = d1.ilk7
--                                AND m.kmhhestur = d1.hestur
--                                AND m.kmhekno = d1.ekno
--                                AND 0 = d1.durum
--         LEFT OUTER JOIN extr.fs_eskiplan_sg d2
--                             ON     1 = 1
--                                AND m.sube = d2.sube
--                                AND m.kmhsinif = d2.sinif
--                                AND m.kmhilk7 = d2.ilk7
--                                AND m.kmhhestur = d2.hestur
--                                AND m.kmhekno = d2.ekno
--                                AND 2016 = d2.yil
--                                AND 0 = d2.durum
--   WHERE 1 = 1;
--GRANT SELECT ON get_updtarihfor_kr_tmp02 TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
----SELECT * FROM tmp_trbac_kmh_hsp_ozl_drm a;
----SELECT * FROM extr.fs_kmhmas m;
----SELECT * FROM extr.fs_sube s;
----SELECT * FROM get_updtarihfor_kr_tmp01 h;
----SELECT * FROM extr.fs_hplandet_sg d1;
----SELECT * FROM extr.fs_eskiplan_sg d2;
----SELECT * FROM get_updtarihfor_kr_tmp02;
--



























      DELETE FROM prsn.kkb_trbac_fct WHERE 1=1 AND kst_trh = v_tarih;
      COMMIT;
      v_line_no:=1365;

   INSERT               /*+ APPEND */ INTO prsn.kkb_trbac_fct
  SELECT               /*+ parallel (16) */
         a.kst_trh,
         a.tip,
         a.musteri_no,
         b.tck_no,
         b.vergi_no,
         tft1.gercek_tuzel,
         tft1.musteri_tip,
         b.ilkodu sube_merkez_ilkodu,
         CASE WHEN a.tip IN ('NKRD', 'TKRD', 'TMEK', 'ITH', 'KMH', 'MMZC') THEN a.refsube ELSE b.ana_sube END sube_eft_kodu,
         CASE WHEN tkp_m.musteri_no IS NULL THEN a.thp_no ELSE tkp_m.max_tkp_thp_no END thp_no,
         a.refsube,
         a.reftur,
         a.refnitelik,
         a.refsirano,
         a.kmh_mt_ekno,
         a.kmh_kr_ekno,
         CASE WHEN tkp_m.musteri_no IS NULL THEN a.kredi_turu_kod ELSE 900 END kredi_turu_kod,
         CASE WHEN tkp_m.musteri_no IS NULL THEN a.kredi_turu_acklm ELSE 'Tasfiye Olunacak Alacaklar' END kredi_turu_acklm,
         --a.para doviz_kodu,
         CASE WHEN krdmstr.kreditur = 4 THEN 0 ELSE a.para END doviz_kodu, --DEK ler TL
         a.kullandirim_doviz_kodu,
         a.ilk_kullandirim_tarihi,
         CASE WHEN a.son_kullandirma_tarihi < a.ilk_kullandirim_tarihi THEN a.ilk_kullandirim_tarihi
              WHEN a.son_kullandirma_tarihi IS NULL AND a.ilk_kullandirim_tarihi IS NOT NULL THEN a.ilk_kullandirim_tarihi
                   ELSE a.son_kullandirma_tarihi
         END son_kullandirma_tarihi,
         --CASE WHEN a.son_kullandirma_tarihi < a.ilk_kullandirim_tarihi THEN NULL ELSE a.son_kullandirma_tarihi END son_kullandirma_tarihi,
         --a.acilis_ilk_kullandirim_tutari,
         CASE WHEN krdmstr.kreditur = 4 THEN a.acilis_ilk_kullandirim_tutari * dfd.d_alis / dfd.katsayi ELSE a.acilis_ilk_kullandirim_tutari END acilis_ilk_kullandirim_tutari, --DEK ler TL ye çevrildi
         a.vade_tarihi,
         a.muhatap_ulke_kodu,
         a.muhatap,
         CASE WHEN a.tip = 'KMH' THEN kmh_hodk.kmh_hsp_kpns_trh ELSE a.hsp_kapanis_trh END hsp_kapanis_trh,
         a.devir_oncesi_ref,
         a.devir_trh,
         a.devirden_onceki_eski_ref_mi,
         g3.min_actarih grup3_alinma_trh,
         g3.takip_ttr grup3_alinma_tutari,
         g4.min_actarih grup4_alinma_trh,
         g4.takip_ttr grup4_alinma_tutari,
         g5.min_actarih grup5_alinma_trh,
         g5.takip_ttr grup5_alinma_tutari,
         CASE WHEN a.tip = 'KMH' THEN gkmh.gecikme_gun
              ELSE COALESCE (p2.donem_sonu_gecikme, p3.donem_sonu_gecikme, p5.donem_sonu_gecikme)
         END AS donem_sonu_gecikme,
         CASE WHEN a.tip = 'KMH' THEN gkmh2.max_gecikme_gun
              ELSE COALESCE (p2.donemici_enbuyuk_gecikme, p4.donemici_enbuyuk_gecikme, p6.donemici_enbuyuk_gecikme)
         END AS donemici_enbuyuk_gecikme,
         CASE WHEN a.tip IN ('TKRD', 'NKRD', 'KMH') THEN COALESCE (tkrd_hodk.tkrd_rkhsod, nkrd_hodk.rkhsod, kmh_hodk.kmh_rkhsod)
              WHEN a.tip = 'TMEK' AND tmas.durum IN (2, 0, 1)               /*AND g3.min_actarih IS NULL AND g4.min_actarih IS NULL AND g5.min_actarih IS NULL*/ THEN 1
              --WHEN a.tip = 'TMEK' AND tmas.durum = 2 AND (g3.min_actarih IS NOT NULL OR g4.min_actarih IS NOT NULL OR g5.min_actarih IS NOT NULL) THEN 3
              WHEN a.tip = 'TMEK' AND tmas.durum IN (3, 4, 99, 5, 9) THEN 2
              WHEN a.tip = 'ITH' THEN (CASE WHEN im.durum = 10 THEN 2
                                            WHEN im.durum <> 7 AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 0 THEN 1
                                            WHEN im.durum <> 7 AND CASE WHEN NVL (w.musteri_no, 0) > 0 THEN 1 ELSE 0 END = 1 THEN 3
                                            WHEN im.durum = 0 THEN 1
                                            WHEN im.durum = 7 THEN 2
                                                 END
                                      )
              WHEN a.tip = 'GVNC' THEN gvnc.hesap_durum_kodu
              WHEN a.tip = 'MMZC' THEN 1
         END hesabin_ozel_durum_kodu,
         CASE WHEN a.tip = 'MMZC' THEN mmzc.bakiye
              WHEN krdmstr.kreditur = 4 THEN (
                                              CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip = 'TKRD' THEN t1.tutar1 ELSE NVL (COALESCE (dt1.tutar1, kmhttr.kmh_tutar1, gvnc.tutar1), 0) END) END
                                             )
                                             * dfd.d_alis / dfd.katsayi
                   ELSE (
                         CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip = 'TKRD' THEN t1.tutar1 ELSE NVL (COALESCE (dt1.tutar1, kmhttr.kmh_tutar1, gvnc.tutar1), 0) END) END
                        )
                        END tutar1,
         CASE WHEN krdmstr.kreditur = 4 THEN (
                                              CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (rees.duzgunfaiz) END
                                             )
                                             * dfd.d_alis / dfd.katsayi
                   ELSE (
                         CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (rees.duzgunfaiz) END
                        )
                        END tutar2,
         CASE WHEN krdmstr.kreditur = 4 THEN (
                                              CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip = 'ITH' THEN 0 WHEN a.tip = 'KMH' THEN NULL WHEN a.tip='TMEK' THEN p5.devkomtutar WHEN NVL (t3.tutar3, 0) = 0 THEN NULL ELSE NVL (COALESCE (t3.tutar3, gvnc.tutar3), 0) END) END
                                             )
                                             * dfd.d_alis / dfd.katsayi
                   ELSE (
                         CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip = 'ITH' THEN 0 WHEN a.tip = 'KMH' THEN NULL WHEN a.tip='TMEK' THEN p5.devkomtutar WHEN NVL (t3.tutar3, 0) = 0 THEN NULL ELSE NVL (COALESCE (t3.tutar3, gvnc.tutar3), 0) END) END
                        )
                        END tutar3,
         CASE WHEN krdmstr.kreditur = 4 THEN (
                                              CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip IN ('TMEK', 'ITH') THEN 0 WHEN nkrd_hodk.sube IS NOT NULL THEN nkrd_hodk.rktu19 WHEN a.tip = 'TKRD' THEN t4_5.tkrd_rktu19_tutar4 ELSE NVL (NVL (t4.tutar4, kmhttr.kmh_tutar4), 0) END) END
                                             )
                                             * dfd.d_alis / dfd.katsayi
                   ELSE (
                         CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip IN ('TMEK', 'ITH') THEN 0 WHEN nkrd_hodk.sube IS NOT NULL THEN nkrd_hodk.rktu19 WHEN a.tip = 'TKRD' THEN t4_5.tkrd_rktu19_tutar4 ELSE NVL (NVL (t4.tutar4, kmhttr.kmh_tutar4), 0) END) END
                        )
                        END tutar4,
         CASE WHEN krdmstr.kreditur = 4 THEN (
                                              CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip = 'TMEK' THEN 0 WHEN a.tip = 'TKRD' THEN t4_5.tkrd_rktu20_tutar5 WHEN NVL (COALESCE (t5.tutar5, kmhttr.kmh_tutar5), 0) = 0 THEN NULL ELSE NVL (COALESCE (t5.tutar5, kmhttr.kmh_tutar5), 0) END) END
                                             )
                                             * dfd.d_alis / dfd.katsayi
                   ELSE (
                         CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (CASE WHEN a.tip = 'TMEK' THEN 0 WHEN a.tip = 'TKRD' THEN t4_5.tkrd_rktu20_tutar5 WHEN NVL (COALESCE (t5.tutar5, kmhttr.kmh_tutar5), 0) = 0 THEN NULL ELSE NVL (COALESCE (t5.tutar5, kmhttr.kmh_tutar5), 0) END) END
                        )
                        END tutar5,
         CASE WHEN krdmstr.kreditur = 4 THEN (
                                              CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (NVL (COALESCE (p7.tkrd_tutar6, p8.nkrd_tutar, p9.tmek_tutar6, kmh_tut6.kmh_tutar6), 0)) END
                                             )
                                             * dfd.d_alis / dfd.katsayi
                   ELSE (
                         CASE WHEN a.devir_oncesi_ref IS NOT NULL OR a.hsp_kapanis_trh IS NOT NULL THEN 0 ELSE (NVL (COALESCE (p7.tkrd_tutar6, p8.nkrd_tutar, p9.tmek_tutar6, kmh_tut6.kmh_tutar6), 0)) END
                        )
                        END tutar6,
         a.kotasyon_no,
         a.kotasyon_tur,
         krdmstr.kreditur krdmaster_kreditur, --4 olanlar DEK
         krdmstr.durum krdmaster_durum,
         a.aylik_ilk_bildirim_f,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbac_fct_01 a
         INNER JOIN trfm.tmp_trbfc_vortex_mus tft1
                         ON     1 = 1
                            AND a.kst_trh = tft1.kesit_tarihi
                            AND a.musteri_no = tft1.musteri_no
         LEFT JOIN prsn.kkb_trbfc_trbic_fct b
                         ON     1 = 1
                            AND a.kst_trh = b.kesit_tarihi
                            AND a.musteri_no = b.musteri_no
         LEFT JOIN extr.fs_fdoviz dfd
                             ON 1=1
                            AND a.kst_trh = dfd.tarih
                            AND a.para = dfd.para
                            AND 1 = dfd.kurtipi
         LEFT JOIN trfm.tmp_trbac_diger_tutar1 dt1
                             ON 1=1
                            AND a.kst_trh = dt1.kst_trh
                            AND a.refsube = dt1.refsube
                            AND a.reftur = dt1.reftur
                            AND a.refsirano = dt1.refsirano
                            and a.musteri_no =dt1.musteri_no
         LEFT JOIN trfm.tmp_trbac_tutar1 t1
                             ON 1=1
                            AND a.kst_trh = t1.kst_trh
                            AND a.refsube = t1.refsube
                            AND a.reftur = t1.reftur
                            AND a.refsirano = t1.refsirano
                            and a.musteri_no =t1.musteri_no
         LEFT JOIN trfm.tmp_trbac_tutar3 t3
                             ON 1=1
                            AND a.kst_trh = t3.kst_trh
                            AND a.refsube = t3.refsube
                            AND a.reftur = t3.reftur
                            AND a.refsirano = t3.refsirano
                            AND a.musteri_no =t3.musteri_no
         LEFT JOIN trfm.tmp_trbac_tutar4 t4
                             ON 1=1
                            AND a.kst_trh = t4.kst_trh
                            AND a.refsube = t4.refsube
                            AND a.reftur = t4.reftur
                            AND a.refsirano = t4.refsirano
                            and a.musteri_no =t4.musteri_no
         LEFT JOIN trfm.tmp_trbac_tutar5 t5
                             ON 1=1
                            AND a.kst_trh = t5.kst_trh
                            AND a.refsube = t5.refsube
                            AND a.reftur = t5.reftur
                            AND a.refsirano = t5.refsirano
                            and a.musteri_no =t5.musteri_no
         LEFT JOIN trfm.tmp_trbac_tkrd_dnm_ic_son_gckm p2
                               ON 1=1
                            AND a.kst_trh = p2.kst_trh
                            AND a.refsube = p2.sube
                            AND a.reftur = p2.reftur
                            AND a.refsirano = p2.refsirano
                            and a.musteri_no =p2.musteri

         LEFT JOIN trfm.tmp_trbac_nkrd_dnm_son_gckme p3
                               ON 1=1
                            AND a.kst_trh = p3.kst_trh
                            AND a.refsube = p3.sube
                            AND a.reftur = p3.reftur
                            AND a.refsirano = p3.refsirano
                            and a.musteri_no =p3.musteri

         LEFT JOIN trfm.tmp_trbac_nkrd_dnm_ici_gckme  p4
                               ON 1=1
                            AND a.kst_trh = p4.kst_trh
                            AND a.refsube = p4.sube
                            AND a.reftur = p4.reftur
                            AND a.refsirano = p4.refsirano
                            AND a.musteri_no =p4.musteri

         LEFT JOIN trfm.tmp_trbac_tmek_dnm_son_gckme p5
                               ON 1=1
                            AND a.kst_trh = p5.kst_trh
                            AND a.refsube = p5.refsube
                            AND a.reftur = p5.reftur
                            AND a.refsirano = p5.refsirano
                            and a.musteri_no =p5.musteri

         LEFT JOIN trfm.tmp_trbac_tmek_dnm_ic_gckme p6
                               ON 1=1
                            AND a.kst_trh = p6.kst_trh
                            AND a.refsube = p6.refsube
                            AND a.reftur = p6.reftur
                            AND a.refsirano = p6.refsirano
                            and a.musteri_no =p6.musteri

         LEFT JOIN trfm.tmp_trbac_tkrd_tutar6 p7
                               ON 1=1
                            AND a.kst_trh = p7.kst_trh
                            AND a.refsube = p7.sube
                            AND a.reftur = p7.reftur
                            AND a.refsirano = p7.refsirano
                            AND a.musteri_no =p7.musteri

         LEFT JOIN trfm.tmp_trbac_nkrd_tutar6 p8
                               ON 1=1
                            AND a.kst_trh = p8.kst_trh
                            AND a.refsube = p8.sube
                            AND a.reftur = p8.reftur
                            AND a.refsirano = p8.refsirano
                            and a.musteri_no =p8.musteri

         LEFT JOIN trfm.tmp_trbac_tmek_tutar6 p9
                               ON 1=1
                            AND a.kst_trh = p9.kst_trh
                            AND a.refsube = p9.refsube
                            AND a.reftur = p9.reftur
                            AND a.refsirano = p9.refsirano
                            and a.musteri_no =p9.musteri

         LEFT JOIN trfm.tmp_trbac_kmh_tutar kmhttr
                               ON 1 = 1
                            AND a.kst_trh = kmhttr.kst_trh
                            AND a.refsube = kmhttr.refsube
                            AND a.reftur = kmhttr.reftur
                            AND a.refsirano = kmhttr.refsirano
                            and a.musteri_no = kmhttr.musteri_no

         LEFT JOIN trfm.tmp_trbac_tkp_tutar g3
                         ON     1 = 1
                            AND a.kst_trh = g3.kst_trh
                            AND a.musteri_no = g3.musteri_no
                            AND 'GRUP3_ALINMA_TARIHI' = g3.tip
                            --AND a.kst_trh = LAST_DAY (g3.min_actarih)

         LEFT JOIN trfm.tmp_trbac_tkp_tutar g4
                         ON     1 = 1
                            AND a.kst_trh = g4.kst_trh
                            AND a.musteri_no = g4.musteri_no
                            AND 'GRUP4_ALINMA_TARIHI' = g4.tip
                            --AND a.kst_trh = LAST_DAY (g4.min_actarih)

         LEFT JOIN trfm.tmp_trbac_tkp_tutar g5
                         ON     1 = 1
                            AND a.kst_trh = g5.kst_trh
                            AND a.musteri_no = g5.musteri_no
                            AND 'GRUP5_ALINMA_TARIHI' = g5.tip
                            --AND a.kst_trh = LAST_DAY (g5.min_actarih)

         LEFT JOIN trfm.tmp_trbac_tkrd_hsp_ozl_drm_kod tkrd_hodk
                         ON     1 = 1
                            AND a.kst_trh = tkrd_hodk.kst_trh
                            AND a.musteri_no = tkrd_hodk.musteri
                            AND a.refsube = tkrd_hodk.sube
                            AND a.reftur = tkrd_hodk.reftur
                            AND a.refsirano = tkrd_hodk.refsirano
                            AND a.tip = 'TKRD'

         LEFT JOIN trfm.tmp_trbac_nkrd_hsp_ozl_drm_kod nkrd_hodk
                         ON     1 = 1
                            AND a.kst_trh = nkrd_hodk.kst_trh
                            AND a.musteri_no = nkrd_hodk.musteri
                            AND a.refsube = nkrd_hodk.sube
                            AND a.reftur = nkrd_hodk.reftur
                            AND a.refsirano = nkrd_hodk.refsirano
                            AND a.tip = 'NKRD'

         LEFT JOIN trfm.tmp_trbac_kmh_hsp_ozl_drm kmh_hodk
                         ON     1 = 1
                            AND a.kst_trh = kmh_hodk.kst_trh
                            AND a.musteri_no = kmh_hodk.musteri_no
                            AND a.refsube = kmh_hodk.refsube
                            AND a.reftur = kmh_hodk.reftur
                            AND a.refsirano = kmh_hodk.refsirano
                            AND a.tip = 'KMH'

         LEFT JOIN extr.fs_ithmaster im
                         ON     1 = 1
                            --AND a.kst_trh = v_tarih
                            AND a.refsube = im.sube
                            AND a.reftur = im.reftur
                            AND a.refsirano = im.refsirano
                            AND a.tip = 'ITH'
                            AND v_tarih >= TO_DATE (im.acilistarih, 'DD/MM/YYYY')

         LEFT JOIN extr.fs_temmekmas tmas
                         ON     1 = 1
                            --AND a.kst_trh = v_tarih
                            AND a.refsube = tmas.refsube
                            AND a.reftur = tmas.reftur
                            AND a.refsirano = tmas.refsirano
                            AND a.tip = 'TMEK'

         LEFT JOIN (SELECT DISTINCT kst_trh, musteri_no FROM trfm.tmp_trbac_tkp_tutar) w
                         ON     1 = 1
                            AND a.kst_trh = w.kst_trh
                            AND a.musteri_no = w.musteri_no
                            AND a.tip = 'ITH'

         LEFT JOIN trfm.tmp_trbac_kmh_tutar6 kmh_tut6
                         ON     1 = 1
                            AND a.kst_trh = kmh_tut6.kst_trh
                            AND a.musteri_no = kmh_tut6.musteri_no
                            AND a.refsube = kmh_tut6.sube
                            AND a.reftur = 'KT'
                            AND a.refsirano = kmh_tut6.kt_ekno
                            AND a.tip = 'KMH'

         LEFT JOIN trfm.tmp_trbac_gvnc_odm_emir gvnc
                         ON     1 = 1
                            AND a.kst_trh = gvnc.kst_trh
                            AND a.musteri_no = gvnc.musteri_no
                            AND a.refsube = gvnc.ana_sube
                            AND a.refsirano = gvnc.tps_odeme_emri_id
                            AND a.tip = 'GVNC'

         LEFT JOIN ofsdata.krdmaster_aysonu              /*extr.fs_krdmaster tablosu proda atýlacak*/ krdmstr
                         ON     1 = 1
                            AND a.refsube = krdmstr.sube
                            AND a.reftur = krdmstr.reftur
                            AND a.refsirano = krdmstr.refsirano
                            AND a.tip = 'NKRD'

         LEFT JOIN trfm.tmp_trbac_tkrd_tutar4_tutar5 t4_5
                         ON     1 = 1
                            AND a.refsube = t4_5.sube
                            AND a.reftur = t4_5.reftur
                            AND a.refsirano = t4_5.refsirano
                            AND a.tip = t4_5.tip
                            AND a.kst_trh = t4_5.kst_trh

              /*         LEFT OUTER JOIN get_updtarihfor_kr_tmp02 kmh_hkt
                         ON     1 = 1
                            AND a.kst_trh = kmh_hkt.kst_trh
                            AND a.musteri_no = kmh_hkt.musteri_no
                            AND a.refsube = kmh_hkt.refsube
                            AND a.reftur = kmh_hkt.reftur
                            AND a.refsirano = kmh_hkt.refsirano
                            AND a.tip = kmh_hkt.tip
                            AND a.kmh_mt_ekno = kmh_hkt.kmh_mt_ekno
                            AND a.kmh_kr_ekno = kmh_hkt.kmh_kr_ekno*/

         LEFT JOIN trfm.tmp_trbac_tutar2_resknt rees
                         ON     1 = 1
                            AND a.kst_trh = rees.tarih
                            AND a.tip = rees.tip
                            AND CASE WHEN a.tip IN ('TKRD', 'NKRD') THEN a.refsube || '-' || a.reftur || '-' || a.refsirano
                                     WHEN a.tip = 'KMH' THEN a.refsube || '-' || 'C' || '-' || a.musteri_no || '-' || a.reftur || '-' || a.refsirano
                                          END
                                              =
                                                CASE WHEN rees.hesaptur IN (14, 16) THEN rees.sube || '-' || rees.hestur || '-' || rees.ilk7
                                                     WHEN rees.hesaptur = 130 THEN rees.sube || '-' || rees.sinif || '-' || rees.ilk7 || '-' || rees.hestur || '-' || rees.ekno
                                                          END

         LEFT JOIN trfm.tmp_kkb_tkp_mus tkp_m
                         ON     1 = 1
                            AND a.kst_trh = tkp_m.kst_trh
                            AND a.musteri_no = tkp_m.musteri_no


         LEFT JOIN trfm.tmp_trbac_kmh_dnm_son_gckme gkmh
                        ON 1 = 1
                            AND a.kst_trh = gkmh.tarih
                            AND a.musteri_no = gkmh.ilk7
                            AND a.refsube = gkmh.sube
                            AND a.refsirano = gkmh.kt_ekno
                            AND a.tip = 'KMH'
         LEFT JOIN trfm.tmp_trbac_kmh_dnm_ici_gckme gkmh2
                         ON 1 = 1
                            AND a.kst_trh = gkmh2.kst_trh
                            AND a.musteri_no = gkmh2.ilk7
                            AND a.refsube = gkmh2.sube
                            AND a.refsirano = gkmh2.kt_ekno
                            AND a.tip = 'KMH'
         LEFT JOIN trfm.tmp_trbac_memzuc_151_152 mmzc
                        ON 1 = 1
                            AND a.kst_trh = mmzc.kst_trh
                            AND a.musteri_no = mmzc.ilk7
                            AND a.refsube = mmzc.sube
                            AND a.reftur = mmzc.hestur
                            AND a.refsirano = mmzc.ekno
                            AND a.tip = 'MMZC'
   WHERE 1 = 1;

      COMMIT;
      v_line_no:=1370;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbac;


   PROCEDURE sp_trbgr_p2 (p_tarih IN DATE DEFAULT TRUNC(sysdate-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_P2';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 1500;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_03',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1505;

      --Kefil adet ve kefalet tutarlarýný bulmak için; (müþteri & fiþno bazýnda)
     INSERT               /*+ APPEND */ INTO  trfm.tmp_trbgr_03
     SELECT v_tarih kst_trh, a.musteri, a.gktno,
            a.sube AS tmnt_refsube, a.reftur tmnt_reftur, a.refsirano AS tmnt_refsirano,
            (a.sube || a.reftur || p.id || '-' || a.refsirano) AS tmnt_referans,
            p.id temtur,
            p.tem_ad AS temtur_acklm,
            h.para,
            MAX (TRUNC (h.fistarih)) AS tmnt_alindigi_trh,
            a.kefil AS kefil_musteri_no,
            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                          THEN NULL
                               ELSE mm.vergi_no
                                    END kefil_musteri_vergi_no,
            mm.musteri_tip AS kefil_musteri_tip,
            SUM (a.tutar) AS kefalet_tutar,
            b.krdtur, b.krdsube, b.krdreftur, b.krdrefnit, b.krdrefsirano,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_teminatkefil a
            INNER JOIN extr.fs_teminathrkt h ON  1 = 1
                                             AND a.sube = (CASE WHEN h.refsube > 100 THEN h.refsube WHEN h.sube > 100 THEN h.sube END)
                                             AND a.reftur = h.reftur
                                             AND a.refsirano = h.refsirano
            INNER JOIN ofsdata.musteri_master_cs_hist mm ON  1 = 1
                                                         AND v_tarih = mm.tarih
                                                         AND a.kefil = mm.musteri_no
            INNER JOIN trfm.tmp_trbgr_02 x ON  1 = 1
                                            AND v_tarih = x.kst_trh
                                            AND a.kefil = x.musteri
            LEFT JOIN extr.fs_corp_lmt_coll_def p ON  1 = 1
                                                  AND 13 = p.id
                                                  AND 9 <> p.durum
            LEFT JOIN (SELECT sube,musteri, temtur, para, temreftur, temrefsirano, krdtur, krdsube, krdreftur, krdrefnit, krdrefsirano, durum
                         FROM extr.fs_temkrdbagla ib
                        WHERE 1=1
                              AND EXISTS (SELECT 1
                                            FROM prsn.kkb_trbac_fct i
                                           WHERE 1=1
                                                 AND i.refsube || i.reftur || i.refsirano  = ib.krdsube || ib.krdreftur || ib.krdrefsirano
                                                 AND i.kst_trh =  v_tarih)
                      ) b ON  1 = 1
                          AND h.musteri = b.musteri
                          AND h.para = b.para
                          AND p.id = b.temtur
                          AND (CASE WHEN h.refsube > 100 THEN h.refsube WHEN h.sube > 100 THEN h.sube END) = b.sube
                          AND h.reftur = b.temreftur
                          AND h.refsirano = b.temrefsirano
                          AND 0 = b.durum
      WHERE 1 = 1
            AND a.kurumsalsw = 'K'
            AND a.durum = 0
            AND a.tutar <> 0
            AND LAST_DAY (TO_DATE (h.fistarih, 'DD/MM/YYYY')) = v_tarih --Aylýk Bildirim
            --AND TO_DATE (h.fistarih, 'DD/MM/YYYY') BETWEEN ADD_MONTHS (v_tarih, -36)+1 AND v_tarih --Ýlk Bildirim
            AND h.durum = 0
            AND h.kurumsalsw = 'K'
            AND (CASE WHEN h.refsube > 100 THEN h.refsube WHEN h.sube > 100 THEN h.sube END) NOT IN (601, 602, 603, 604, 605, 550)
   GROUP BY a.musteri, a.gktno, a.sube, a.reftur, a.refsirano, (a.sube || a.reftur || p.id || '-' || a.refsirano),
            p.id, p.tem_ad, h.para, a.kefil,
            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                          THEN NULL
                               ELSE mm.vergi_no
                                    END,
            mm.musteri_tip, b.krdtur, b.krdsube, b.krdreftur, b.krdrefnit, b.krdrefsirano;

   COMMIT;

      v_line_no:=1510;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_04',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1515;


   --Teminat hareketleri (kefalet ve çek haricindeki) için;
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_04
  SELECT h.kst_trh, h.musteri, h.refsube, h.reftur, h.refsirano, h.temtur, p.tem_ad temtur_acklm, h.para, h.tutar,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (
            SELECT v_tarih AS kst_trh,
                   CASE WHEN refsube = 0 AND sube > 0 THEN sube ELSE refsube END AS refsube,
                   musteri, reftur, refsirano, temtur, para, --sube, fisno, krdreftur, krdrefsirano
                   SUM ((3 - 2 * isltur) * tutar) AS tutar
              FROM extr.fs_teminathrkt
             WHERE 1 = 1
               AND LAST_DAY (TO_DATE (fistarih, 'DD/MM/YYYY')) = v_tarih --aylýk bildirim
               --AND TO_DATE (fistarih, 'DD/MM/YYYY') BETWEEN ADD_MONTHS (v_tarih, -36)+1 AND v_tarih --ilk bildirim
               AND durum = 0
               AND kurumsalsw = 'K'
               AND sube NOT IN (601, 602, 603, 604, 605, 550)
               AND temtur NOT IN (13, --kefil
                                  10, 11) --çek
          GROUP BY CASE WHEN refsube = 0 AND sube > 0 THEN sube ELSE refsube END,
                   musteri, reftur, refsirano, para, temtur--, sube, fisno, krdreftur, krdrefsirano
            HAVING SUM ((3 - 2 * isltur) * tutar) > 0
         ) h
         LEFT OUTER JOIN extr.fs_corp_lmt_coll_def p
                         ON     1 = 1
                            AND h.temtur = p.id
                            AND 9 <> p.durum
   WHERE 1 = 1
     AND h.tutar <> 0;

   COMMIT;

      v_line_no:=1520;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_05',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1525;


   --Teminat referansýný (kefalet ve çek haricindeki) kredi referansýyla baðladýk;
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_05
  SELECT t.kst_trh, t.musteri, t.refsube tmnt_refsube, TRIM (t.reftur) AS tmnt_reftur, t.refsirano tmnt_refsirano, t.temtur, t.temtur_acklm,
         (t.refsube || t.reftur || t.temtur || '-' || t.refsirano) AS tmnt_referans,
         t.para, t.tutar, b.krdtur, b.krdsube, b.krdreftur, b.krdrefnit, b.krdrefsirano,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbgr_04 t
         LEFT OUTER JOIN extr.fs_temkrdbagla b
                         ON     1 = 1
                            AND t.musteri = b.musteri
                            AND t.para = b.para
                            AND t.temtur = b.temtur
                            AND t.refsube = b.sube
                            AND t.reftur = b.temreftur
                            AND t.refsirano = b.temrefsirano
                            AND 0 = b.durum
   WHERE 1 = 1;

   COMMIT;

      v_line_no:=1530;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_CEK_TMNT',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1535;


   --Çek bilgilerini bulmak için;
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_cek_tmnt
  SELECT t.kst_trh, t.musteri, t.sube AS cek_tmnt_refsube, 'CK' AS cek_tmnt_reftur, t.musteri AS cek_tmnt_refsirano,
         (t.sube || 'CK' || t.musteri) tmnt_referans, t.temtur, p.tem_ad temtur_acklm, t.para, t.adet,
         t.tutar AS cek_tutar_orj, (t.tutar * f.d_alis / f.katsayi) AS cek_tutar_tl,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (
            SELECT kst_trh, sube, musteri, para, temtur, adet, tutar
              FROM (
                      SELECT v_tarih kst_trh, sube, musteri, para, temtur,
                             SUM(3 - 2 * isltur) AS adet,
                             SUM ((3 - 2 * isltur) * tutar) AS tutar
                        FROM extr.fs_teminathrkt
                       WHERE 1 = 1
                         AND LAST_DAY (TO_DATE (fistarih, 'DD/MM/YYYY')) = v_tarih --aylýk bildirim
                         --AND TO_DATE (fistarih, 'DD/MM/YYYY') BETWEEN ADD_MONTHS (v_tarih, -36)+1 AND v_tarih --ilk bildirim
                         AND durum = 0
                         AND kurumsalsw = 'K'
                         AND sube NOT IN (601, 602, 603, 604, 605, 550)
                         AND temtur IN (10, 11)
                    GROUP BY sube, musteri, para, temtur
                   )
             WHERE 1 = 1
               AND tutar > 0
         ) t
         INNER JOIN extr.fs_fdoviz f ON  1 = 1
                                     AND t.kst_trh = f.tarih
                                     AND t.para = f.para
                                     AND 2 = f.kurtipi
         LEFT JOIN extr.fs_corp_lmt_coll_def p ON  1 = 1
                                               AND t.temtur = p.id
                                               AND 9 <> p.durum
   WHERE 1 = 1;

   COMMIT;

      v_line_no:=1540;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_06',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1545;


   --Teminat Alýþ Tarihi (kefil ve çek harici)
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_06
     SELECT v_tarih AS kst_trh,
            sube, musteri, reftur, refsirano, temtur,
            MAX (TO_DATE (girtarih, 'DD/MM/YYYY')) AS tmnt_alis_trh,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_teminathrkt
      WHERE 1 = 1
        AND durum = 0
        AND isltur = 1
        AND LAST_DAY (TO_DATE (fistarih, 'DD/MM/YYYY')) = v_tarih --aylýk bildirim
        --AND TO_DATE (fistarih, 'DD/MM/YYYY') BETWEEN ADD_MONTHS (v_tarih, -36)+1 AND v_tarih --ilk bildirim
        AND TO_DATE (girtarih, 'DD/MM/YYYY') <= v_tarih
   GROUP BY sube, musteri, reftur, refsirano, temtur;

   COMMIT;

      v_line_no:=1550;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_TMNT_CEK_ALIS_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1555;


   --Teminat Alýþ Tarihi (çek)
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_tmnt_cek_alis_trh
     SELECT v_tarih AS kst_trh,
            t1.sube, t1.reftur, t1.refsirano,
            MIN (TO_DATE (fistarih, 'DD/MM/YYYY')) AS tmnt_alis_trh,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM extr.fs_teminathrkt t1
      WHERE 1 = 1
        AND t1.durum = 0
        AND t1.kurumsalsw = 'K'
        AND t1.isltur = 1
        AND t1.temtur IN (10, 11)
        AND TO_DATE (t1.girtarih, 'DD/MM/YYYY') <= v_tarih
        AND NOT EXISTS (
                          SELECT 1
                            FROM extr.fs_teminathrkt
                           WHERE 1 = 1
                             AND durum = 0
                             AND kurumsalsw = 'K'
                             AND isltur = 2
                             AND temtur IN (10, 11)
                             AND t1.sube = sube
                             AND t1.reftur = reftur
                             AND t1.refsirano = refsirano
                       )
   GROUP BY t1.sube, t1.reftur, t1.refsirano;

   COMMIT;

      v_line_no:=1560;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_TMNT_CEK_DGRLM_TRH',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1565;


   --Son deðerleme tarihi (çek)
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_tmnt_cek_dgrlm_trh
     SELECT kst_trh, musteri, MAX (vade) AS son_degerleme_trh,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM (
               SELECT v_tarih kst_trh, musteri, MAX (TO_DATE (tahtarih, 'DD/MM/YYYY')) AS vade
                 FROM extr.fs_takas
                WHERE 1 = 1
                  AND TO_DATE (tahtarih, 'DD/MM/YYYY') <= v_tarih
             GROUP BY musteri
             UNION ALL
               SELECT v_tarih kst_trh, musteri, MAX (tahtarih) AS vade
                 FROM extr.fs_takasyp
                WHERE 1 = 1
                  AND TO_DATE (tahtarih, 'DD/MM/YYYY') <= v_tarih
             GROUP BY musteri
             UNION ALL
               SELECT               /*+ full(sn) parallel(8) */
            v_tarih kst_trh, musteri, MAX (vade) AS vade
                 FROM extr.fs_sntmas sn
                WHERE 1 = 1
                  AND TO_DATE (vade, 'DD/MM/YYYY') <= v_tarih
             GROUP BY musteri
            )
   GROUP BY kst_trh, musteri;

   COMMIT;

      v_line_no:=1570;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_PYSA_EXPRT_DIGER_BN',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1575;


   --Piyasa Ekspertiz Deðeri - Bono (temtur 2 için) - Function Get_piyasa_degeri(arg_teminattur number,arg_musteri number,arg_sube number,arg_reftur varchar2,arg_refsirano number) return number
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_pysa_exprt_diger_bn
  SELECT bf.tarih AS kst_trh,
         'Bono (temtur 2 için)' AS tip,
         ms.isincode, ms.musteri, ms.gerceklesmeno, bf.fiyat, ms.menkulbloke,
         (bf.fiyat * ms.menkulbloke / 100) AS piyasa_ekspertiz_degeri,
         ms.islemsube, ms.fissube, ms.referansno, ms.reftur, ms.refnit, ms.refsirano,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_bonofiyat bf,
         extr.fs_mnkhrktaktif ms
   WHERE 1 = 1
     AND bf.isincode = ms.isincode
     AND bf.islemtip = 3
     AND bf.tarih = v_tarih
     AND TO_DATE (ms.islemtarihi, 'DD/MM/YYYY') <= v_tarih
     AND bf.fiyat * ms.menkulbloke > 0;
     --AND ms.musteri = arg_musteri
     --AND ms.gerceklesmeno = arg_refsirano

   COMMIT;

      v_line_no:=1580;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_PYSA_EXPRT_DIGER_FON',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1585;


   --Piyasa Ekspertiz Deðeri - Teminat Fon (temtur 33, 34, 35 için) - Function Get_piyasa_degeri(arg_teminattur number,arg_musteri number,arg_sube number,arg_reftur varchar2,arg_refsirano number) return number
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_pysa_exprt_diger_fon
  SELECT ff.tarih AS kst_trh,
         'Teminat Fon (temtur 33, 34, 35 için)' AS tip,
         tf.fonno, tf.kurumsalsw, tf.durum, tf.adet, tf.sube, tf.musteri, tf.reftur, tf.refnit, tf.refsirano,
         (ff.alim * tf.adet) AS piyasa_ekspertiz_degeri,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_teminatfon tf,
         (
            SELECT tarih, alim, fonno
              FROM (
                      SELECT x.tarih, x.alim, x.fonno,
                             ROW_NUMBER () OVER (PARTITION BY x.tarih, x.fonno ORDER BY x.updtarih DESC, x.updzaman DESC, x.zaman2 DESC, x.zaman1 DESC) sira
                        FROM extr.fs_fonfiyat x
                       WHERE 1 = 1
                   )
             WHERE 1 = 1
               AND sira = 1
         ) ff
   WHERE 1 = 1
     AND tf.fonno = ff.fonno
     AND ff.tarih = v_tarih
     AND TO_DATE (tf.fistarih, 'DD/MM/YYYY') <= v_tarih
     AND tf.kurumsalsw = 'K'
     AND tf.durum = 0
     AND ff.alim * tf.adet <> 0;
     --AND tf.sube = arg_sube
     --AND tf.musteri = arg_musteri
     --AND tf.reftur = arg_reftur
     --AND tf.refsirano = arg_refsirano

   COMMIT;

      v_line_no:=1590;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_PYSA_EXPRT_DIGER_IPT',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1595;


   --Piyasa Ekspertiz Deðeri - Teminat Ýpotek (temtur 12 için) - Function Get_piyasa_degeri(arg_teminattur number,arg_musteri number,arg_sube number,arg_reftur varchar2,arg_refsirano number) return number
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_pysa_exprt_diger_ipt
  SELECT v_tarih AS kst_trh,
         'Teminat Ýpotek (temtur 12 için)' AS tip,
         i.sube,
         i.musteri,
         i.reftur,
         i.refsirano,
         i.ekspertut AS piyasa_ekspertiz_degeri,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM extr.fs_temipotek i
   WHERE 1 = 1
     AND i.durum = 0
     AND i.kurumsalsw = 'K'
     AND TO_DATE (i.fistarih, 'DD/MM/YYYY') <= v_tarih
     AND i.ekspertut <> 0;
     --AND i.sube = arg_sube
     --AND i.musteri = arg_musteri
     --AND i.reftur = arg_reftur
     --AND i.refsirano = arg_refsirano

   COMMIT;

      v_line_no:=1600;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_MUS_ILISKI_01',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1610;


   --Kefil müþteri numaralarýný bulabilmek için (TRBAC ve TRBIC segment'lerini besleyecek, TRBGR'de kullanýlmayacak);
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_mus_iliski_01
  SELECT i.kst_trh, i.ana_musteri_no, i.kefil_musteri_no,
         CASE WHEN     UPPER (j.vergi_no) LIKE '%A%' OR UPPER (j.vergi_no) LIKE '%B%' OR UPPER (j.vergi_no) LIKE '%C%'
                    OR UPPER (j.vergi_no) LIKE '%D%' OR UPPER (j.vergi_no) LIKE '%E%' OR UPPER (j.vergi_no) LIKE '%F%'
                    OR UPPER (j.vergi_no) LIKE '%G%' OR UPPER (j.vergi_no) LIKE '%H%' OR UPPER (j.vergi_no) LIKE '%I%'
                    OR UPPER (j.vergi_no) LIKE '%J%' OR UPPER (j.vergi_no) LIKE '%K%' OR UPPER (j.vergi_no) LIKE '%L%'
                    OR UPPER (j.vergi_no) LIKE '%M%' OR UPPER (j.vergi_no) LIKE '%N%' OR UPPER (j.vergi_no) LIKE '%O%'
                    OR UPPER (j.vergi_no) LIKE '%P%' OR UPPER (j.vergi_no) LIKE '%R%' OR UPPER (j.vergi_no) LIKE '%S%'
                    OR UPPER (j.vergi_no) LIKE '%T%' OR UPPER (j.vergi_no) LIKE '%U%' OR UPPER (j.vergi_no) LIKE '%V%'
                    OR UPPER (j.vergi_no) LIKE '%Y%' OR UPPER (j.vergi_no) LIKE '%Z%' OR UPPER (j.vergi_no) LIKE '%Ç%'
                    OR UPPER (j.vergi_no) LIKE '%Ö%' OR UPPER (j.vergi_no) LIKE '%Ð%' OR UPPER (j.vergi_no) LIKE '%Þ%'
                    OR UPPER (j.vergi_no) LIKE '%Ü%' OR UPPER (j.vergi_no) LIKE '%Ý%' OR UPPER (j.vergi_no) LIKE '%X%'
                    OR UPPER (j.vergi_no) LIKE '%W%' OR UPPER (j.vergi_no) LIKE '%Q%' OR UPPER (j.vergi_no) LIKE '%,%'
                    OR UPPER (j.vergi_no) LIKE '%-%' OR UPPER (j.vergi_no) LIKE '% %' OR UPPER (j.vergi_no) LIKE '%/%'
                       THEN NULL
                            ELSE j.vergi_no
                                 END kefil_musteri_vergi_no,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM (
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil1 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil1
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil2 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil2
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil3 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil3
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil4 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil4
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil5 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil5
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil6 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil6
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil7 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil7
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil8 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil8
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil9 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil9
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil10 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil10
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil11 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil11
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil12 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil12
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil13 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil13
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil14 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil14
            WHERE 1 = 1
         UNION
           SELECT DISTINCT k.kst_trh, k.musteri AS ana_musteri_no, g.kefil15 AS kefil_musteri_no
             FROM trfm.tmp_trbgr_03 k
                  INNER JOIN      extr.fs_gktmas g
                                  ON     1 = 1
                                     AND LAST_DAY (TO_DATE (g.fistarih, 'DD/MM/YYYY')) = v_tarih
                                     AND k.musteri = g.musteri
                                     AND k.gktno = g.gktno
                                     AND 0 = g.durum
                                     AND 0 < g.kefil15
            WHERE 1 = 1
         ) i
         LEFT OUTER JOIN ofsdata.musteri_master_cs_hist j
                         ON     1 = 1
                            AND i.kst_trh = j.tarih
                            AND i.kefil_musteri_no = j.musteri_no
   WHERE 1 = 1;

   COMMIT;

      v_line_no:=1600;


      TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_TRBGR_MUS_ILISKI',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
      IF V_SQLCODE<>0 THEN
         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
      END IF;

      v_line_no:=1610;


   --Kefil müþteri numaralarýný bulabilmek için (TRBAC ve TRBIC segment'lerini besleyecek, TRBGR'de kullanýlmayacak);
   INSERT               /*+ APPEND */ INTO trfm.tmp_trbgr_mus_iliski
  SELECT kst_trh, ana_musteri_no, kefil_musteri_no, kefil_musteri_vergi_no,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
    FROM trfm.tmp_trbgr_mus_iliski_01
   WHERE 1 = 1
     AND TO_NUMBER (kefil_musteri_vergi_no) > 1111111
     AND CASE WHEN kefil_musteri_vergi_no IS NOT NULL AND LENGTH (LPAD (kefil_musteri_vergi_no, 10, '0')) = 10 THEN etl.sf_ymus_vergicheck_to_number (kefil_musteri_vergi_no)
                   WHEN LENGTH (kefil_musteri_vergi_no) = 11 THEN etl.sf_ymus_tckncheck_to_number (kefil_musteri_vergi_no)
                        END = 1;
   COMMIT;

   v_line_no:=1615;


   DELETE FROM prsn.kkb_trbgr_fct WHERE 1=1 AND kesit_tarihi = v_tarih;
   COMMIT;
   v_line_no:=1620;
   --Kefil ve Çek Harici
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_fct
     SELECT f.kesit_tarihi,
            'Kefil ve Çek Harici' AS teminat_cesidi,
            f.musteri_no,
            f.kayit_referans_numarasi AS kayit_referans_numarasi_tmnt,
            f.tck_no,
            f.vergi_no,
            f.gercek_tuzel,
            f.musteri_tip,
            f.ilkodu AS sube_ilkodu,
            f.ana_sube AS sube_eft_kodu,
            t.tmnt_refsube,
            t.tmnt_reftur,
            t.tmnt_refsirano,
            t.tmnt_referans,
            t.temtur AS teminat_turu_kodu_ing,
            t.temtur_acklm AS teminat_turu_acklm_ing,
            t.para AS teminat_doviz_kodu,
            t.tutar AS teminat_degeri,
            t.krdsube,
            t.krdreftur,
            t.krdrefnit,
            t.krdrefsirano,
            f.tck_no AS mm_tck_no,
            f.vergi_no AS mm_vergi_no,
            i.tmnt_alis_trh AS tmnt_alindigi_trh,--GUNCELLEME TO_CHAR
            CAST(NULL AS DATE) AS son_degerleme_trh,
            NVL (NVL (p1.piyasa_ekspertiz_degeri, p2.piyasa_ekspertiz_degeri), p3.piyasa_ekspertiz_degeri) AS piyasa_ekspertiz_degeri,
            1 AS teminat_aktif_pasif_kodu,
            0 AS cek_senet_adedi,
            0 AS kefil_adet,
            0 AS kefalet_miktari,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbfc_trbic_fct f
            INNER JOIN trfm.tmp_trbgr_05 t
                            ON     1 = 1
                               AND f.kesit_tarihi = t.kst_trh
                               AND f.musteri_no = t.musteri
            INNER JOIN trfm.tmp_trbfc_vortex_mus o1
                            ON     1 = 1
                               AND f.kesit_tarihi = o1.kesit_tarihi
                               AND f.musteri_no = o1.musteri_no
            LEFT JOIN trfm.tmp_trbgr_06 i
                            ON     1 = 1
                               AND f.kesit_tarihi = i.kst_trh
                               AND f.musteri_no = i.musteri
                               AND t.tmnt_refsube = i.sube
                               AND t.tmnt_reftur = i.reftur
                               AND t.tmnt_refsirano = i.refsirano
            LEFT JOIN trfm.tmp_trbgr_pysa_exprt_diger_bn p1
                            ON     1 = 1
                               AND f.kesit_tarihi = p1.kst_trh
                               AND f.musteri_no = p1.musteri
                               AND t.tmnt_refsirano = p1.gerceklesmeno
                               AND t.temtur = 2
            LEFT JOIN trfm.tmp_trbgr_pysa_exprt_diger_fon p2
                            ON     1 = 1
                               AND f.kesit_tarihi = p2.kst_trh
                               AND f.musteri_no = p2.musteri
                               AND t.tmnt_refsube = p2.sube
                               AND t.tmnt_reftur = p2.reftur
                               AND t.tmnt_refsirano = p2.refsirano
                               AND t.temtur IN (33, 34, 35)
            LEFT JOIN trfm.tmp_trbgr_pysa_exprt_diger_ipt p3
                            ON     1 = 1
                               AND f.kesit_tarihi = p3.kst_trh
                               AND f.musteri_no = p3.musteri
                               AND t.tmnt_refsube = p3.sube
                               AND t.tmnt_reftur = p3.reftur
                               AND t.tmnt_refsirano = p3.refsirano
                               AND t.temtur = 12
      WHERE 1 = 1
            AND f.kesit_tarihi = v_tarih

   UNION ALL

   --Kefiller
     SELECT f.kesit_tarihi,
            'Kefalet' AS teminat_cesidi,
            f.musteri_no,
            f.kayit_referans_numarasi AS kayit_referans_numarasi_tmnt,
            f.tck_no,
            f.vergi_no,
            f.gercek_tuzel,
            f.musteri_tip,
            f.ilkodu AS sube_ilkodu,
            f.ana_sube AS sube_eft_kodu,
            t.tmnt_refsube,
            t.tmnt_reftur,
            t.tmnt_refsirano,
            t.tmnt_referans,
            t.temtur AS teminat_turu_kodu_ing,
            t.temtur_acklm AS teminat_turu_acklm_ing,
            t.para AS teminat_doviz_kodu,
            SUM (t.kefalet_tutar) AS teminat_degeri,
            CAST(NULL AS NUMBER) AS krdsube,
            CAST(NULL AS VARCHAR2(2 BYTE)) AS krdreftur,
            CAST(NULL AS VARCHAR2(2 BYTE)) AS krdrefnit,
            CAST(NULL AS NUMBER) AS krdrefsirano,
            f.tck_no AS mm_tck_no,
            f.vergi_no AS mm_vergi_no,
            t.tmnt_alindigi_trh,
            CAST(NULL AS DATE) AS son_degerleme_trh,
            CAST(NULL AS NUMBER) AS piyasa_ekspertiz_degeri,
            1 AS teminat_aktif_pasif_kodu,
            0 AS cek_senet_adedi,
            COUNT (*) AS kefil_adet,
            SUM (t.kefalet_tutar) AS kefalet_miktari,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbfc_trbic_fct f
            INNER JOIN trfm.tmp_trbgr_03 t ON  1 = 1
                                       AND f.kesit_tarihi = t.kst_trh
                                       AND f.musteri_no = t.musteri
            INNER JOIN trfm.tmp_trbfc_vortex_mus o1 ON  1 = 1
                                               AND f.kesit_tarihi = o1.kesit_tarihi
                                               AND f.musteri_no = o1.musteri_no
      WHERE 1 = 1
            AND f.kesit_tarihi = v_tarih
   GROUP BY f.kesit_tarihi, f.musteri_no, f.kayit_referans_numarasi, f.tck_no, f.vergi_no, f.gercek_tuzel,
            f.musteri_tip, f.ilkodu, f.ana_sube, t.tmnt_refsube, t.tmnt_reftur, t.tmnt_refsirano,
            t.tmnt_referans, t.temtur, t.temtur_acklm, t.para, f.tck_no, f.vergi_no, t.tmnt_alindigi_trh

   UNION ALL

   --Çekler
     SELECT f.kesit_tarihi,
            'Çek' AS teminat_cesidi,
            f.musteri_no,
            f.kayit_referans_numarasi AS kayit_referans_numarasi_tmnt,
            f.tck_no,
            f.vergi_no,
            f.gercek_tuzel,
            f.musteri_tip,
            f.ilkodu AS sube_ilkodu,
            f.ana_sube AS sube_eft_kodu,
            t.cek_tmnt_refsube AS tmnt_refsube,
            t.cek_tmnt_reftur AS tmnt_reftur,
            t.cek_tmnt_refsirano AStmnt_refsirano,
            t.tmnt_referans,
            t.temtur AS teminat_turu_kodu_ing,
            t.temtur_acklm AS teminat_turu_acklm_ing,
            t.para teminat_doviz_kodu,
            t.cek_tutar_tl AS teminat_degeri,
            CAST(NULL AS NUMBER) AS krdsube,
            CAST(NULL AS VARCHAR2(2 BYTE)) AS krdreftur,
            CAST(NULL AS VARCHAR2(2 BYTE)) AS krdrefnit,
            CAST(NULL AS NUMBER) AS krdrefsirano,
            f.tck_no AS tck_no,
            f.vergi_no AS vergi_no,
            i.tmnt_alis_trh AS tmnt_alindigi_trh,
            c.son_degerleme_trh ,
            CAST(NULL AS NUMBER) AS piyasa_ekspertiz_degeri,
            1 AS teminat_aktif_pasif_kodu,
            t.adet AS cek_senet_adedi,
            0 AS kefil_adet,
            0 AS kefalet_miktari,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbfc_trbic_fct f
            INNER JOIN trfm.tmp_trbgr_cek_tmnt t ON  1 = 1
                                            AND f.kesit_tarihi = t.kst_trh
                                            AND f.musteri_no = t.musteri
            INNER JOIN trfm.tmp_trbfc_vortex_mus o1 ON  1 = 1
                                               AND f.kesit_tarihi = o1.kesit_tarihi
                                               AND f.musteri_no = o1.musteri_no
            LEFT JOIN trfm.tmp_trbgr_tmnt_cek_alis_trh i ON  1 = 1
                                                    AND f.kesit_tarihi = i.kst_trh
                                                    AND t.cek_tmnt_refsube = i.sube
                                                    AND t.cek_tmnt_reftur = i.reftur
                                                    AND t.cek_tmnt_refsirano = i.refsirano
            LEFT JOIN trfm.tmp_trbgr_tmnt_cek_dgrlm_trh c ON  1 = 1
                                                     AND f.kesit_tarihi = c.kst_trh
                                                     AND t.musteri = c.musteri
      WHERE 1 = 1
            AND f.kesit_tarihi = v_tarih;

   COMMIT;

   v_line_no:=1625;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_p2;


   PROCEDURE sp_trbef_txt (p_tarih IN DATE DEFAULT TRUNC(sysdate-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBEF_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 1700;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      --TRBEF

      DELETE FROM prsn.kkb_trbef_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      INSERT INTO prsn.kkb_trbef_txt
      (kesit_tarihi, rezerv_alan_1, segment_turu, versiyon_numarasi, uye_kodu, veri_turu_kodu_firma, veri_turu_kodu_kredi, veri_turu_kodu_teminat, rezerv_alan_2, etl_trh, etl_job)
      VALUES (v_tarih,
              RPAD(' ', 27,' '),
              'TRBEF',
              '02',
              '00099',
              10,
              30,
              32,
              RPAD(' ', 1259,' '),
              SYSDATE,
              v_sp_name
             );
      COMMIT;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbef_txt;


   PROCEDURE sp_trbfc_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBFC_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 1800;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbfc_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=1810;

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_txt
     SELECT a.kesit_tarihi, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn AS kontrol_tckn_vkn_f,
            a.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
            '10' AS veri_turu_kunye,
            '30' AS veri_turu_kredi,
            '10' AS veri_turu_teminat,
            '00099' AS uye_Kodu,
            a.kayit_referans_numarasi, --bu kýsým bu query'de firma künye için yazýldý
            'TRBFC' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            '10'
            ||
            '00099'
            ||
            a.kayit_referans_numarasi
            AS tuzel_kisi_ref_no,
            LPAD(a.ilkodu,3,0) AS sube_merkez_il_kodu,
            LPAD(NVL(a.ana_sube,99999),5,0)    sube_eft_kodu,
            RPAD(REPLACE(SUBSTR(a.isim_unvan,1,LENGTH(a.isim_unvan)),CHR(26),' '),100,' ') AS unvan,
            NVL(RPAD(COALESCE(a.isyeri_adres,a.ev_adres),120,' '),'                                                                                                                        ') AS adres,
            --RPAD(NVL(REPLACE(REPLACE(A.isyeri_adres,CHR(10),' '),CHR(13),' ') ,REPLACE(REPLACE(A.ev_adres,CHR(10),' '),CHR(13),' ')),120,' ') ADRES,
            NVL(LPAD(COALESCE(a.isyeri_il_kodu,a.ev_il_kodu),3,0),999) AS  adres_il_kodu,
            NVL(LPAD(i.ilce,2,0),99) AS adres_ilce_kodu,
            --NVL(LPAD(COALESCE(a.isyeri_ilce_aciklama,a.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,
            LPAD(NVL(u.id,'999'),3,'0')  ulke_kodu,---ulkelerin uyusmasý için parametre tablosuna ihtiyac var
            CASE WHEN a.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(a.ticaret_sicil_no),'                                ') END AS ticaret_sicil_numarasi,
            '                '        mersis_numarasi,
            '                    '    ticaret_odasi,
            '999'                     ticaret_tescil_il_kodu,
            '99'                      ticaret_tescil_merkezi_kodu,
            LPAD(NVL(a.vergi_dairesi,'                    '),20,' ') AS vergi_dairesi,
            NVL(DECODE(a.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(a.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            --NVL (LPAD (TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
            LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
            '00' AS firma_iliski_kodu,
            '                           ' AS ilsk_ndn_olan_grc_tzl_refno,
            RPAD(' ', 100,' ') AS ilsk_ndn_olan_grc_unvan,
            '0' AS kredi_iliski_kodu,
            '00000000' AS ilsk_baslangic_tarihi,
            '00000000' AS ilsk_bitis_tarihi,
            ' ' AS ilsk_gostergesi,
            '00000' AS ortaklýk_hisse_orani,
            NVL(LPAD(COALESCE(a.isyeri_posta_kod ,a.ev_posta_kod),10,'  '), '          ') AS adres_posta_kod,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,

            LPAD (NVL (a.web_adresi, '                                                  '), 50, ' ') AS web_adresi,
            LPAD(NVL(a.mail,'                                                  '),50,' ') AS e_posta,
            NVL (TO_CHAR (a.uye_clsm_trh, 'yyyymmdd'), 99999999) AS uye_calisma_baslama_tarih ,
            LPAD(NVL(a.donem_calisan_sayisi,0),10,0) AS calisan_sayisi ,
            RPAD(NVL(kfk.finansman_konusu_kod,'999') ,3,' ') AS finansman_konusu_kodu,
            LPAD(NVL(a.firma_grup_kodu,'          '),10,' ') AS firma_grup_kodu,

            CASE WHEN A.ciro_tutari<0 OR a.ciro_tutari IS NULL THEN 999
                 ELSE 792
            END AS ciro_doviz_kodu,

            CASE WHEN a.ciro_tutari<0 THEN '               '
            ELSE NVL(LPAD(ROUND(TO_CHAR(a.ciro_tutari),0),15,'0'),'               ') END AS ciro_tutari,

            LPAD(NVL(a.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(a.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(a.min_actarih_grup3,'yyyymmdd'), '00000000') AS grup3_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup4,'yyyymmdd'), '00000000') AS grup4_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup5,'yyyymmdd'), '00000000') AS grup5_alinma_tarihi,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0),15,'0'),'               ') END nakit_limit,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0),15,'0'),'               ') END gayrinakit_limit,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0),15,'0'),'               ') END firma_genel_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0),15,'0'),'               ') END grup_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0),15,'0'),'               ') END grup_riski,

            LPAD(NVL(TO_CHAR(a.genel_revize_vadesi,'yyyymmdd'),'99999999'),8,' ') AS genel_revize_vadesi,
            NVL(TO_CHAR(a.son_revize_tarihi,'yyyymmdd'), 99999999) AS son_revize_tarihi,
            RPAD(' ', 407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbfc_trbic_fct a
            INNER JOIN trfm.tmp_trbfc_vortex_mus b ON  1=1
                                              AND a.musteri_no=b.musteri_no
                                              AND a.kesit_tarihi =b.kesit_tarihi
            LEFT JOIN extr.fs_ilce i ON  1=1
                                     AND LPAD (a.ev_il_kodu, 3, 0) =LPAD(i.il,3,0)
                                     AND a.ev_ilce_aciklama = i.aciklama
            LEFT JOIN prsn.prmulkekodu u ON a.isyeri_ulke_kodu= SUBSTR (TRIM (u.value), LENGTH (TRIM (u.value)) - 2, 2)
                          /*left join prsn.prmfirmaturu ft
            ON DECODE (a.sirket_tip_acklm, 'ANONÝM', '04',
                                           'ADÝ', '1',
                                           'KOMANDÝT', '02',
                                           'LÝMÝTED', '06',
                                           'KOLLEKTÝF', '05',
                                           'KOOPERATÝF', '20',
                                           'BELÝRTÝLMEMÝÞ', '99',
                                           'ASKERÝ BÝRLÝK', '34',
                                           'ÞÝRKET DEÐÝL (ASKERÝ)', '98',
                                           'ÞÝRKET DEÐÝL (SÝVÝL)', '98',
                                           '99')
                                     = TO_NUMBER (TRIM (ft.id))*/
            LEFT JOIN trfm.tmp_fnsmn_konu kfk ON a.finansman_konusu_kodu = kfk.finansman_konusu_kod
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf ON a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            AND a.kesit_tarihi = v_tarih;

      COMMIT;
      v_line_no:=1820;

   ---iliþkili musteriler
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_txt
     SELECT a.kesit_tarihi, a.calisma_sekli, a.ana_sube, a.gercek_tuzel,
            vtf.tckn_vkn AS kontrol_tckn_vkn_f,
            b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
            '10' AS veri_turu_kunye,
            '30' AS veri_turu_kredi,
            '10' AS veri_turu_teminat,
            '00099' AS uye_Kodu,
            b.kayit_referans_numarasi, --bu kýsým bu query'de firma künye için yazýldý
            'TRBFC' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            '10'
            ||
            '00099'
            ||
            a.kayit_referans_numarasi
            AS tuzel_kisi_ref_no,
            LPAD(a.ilkodu,3,0) AS sube_merkez_il_kodu,
            LPAD(NVL(a.ana_sube,99999),5,0) AS sube_eft_kodu,
            RPAD(REPLACE(SUBSTR(a.isim_unvan,1,LENGTH(a.isim_unvan)),CHR(26),' '),100,' ') AS unvan,

            NVL(RPAD(COALESCE( a.isyeri_adres,a.ev_adres),120,' '),'                                                                                                                        ') AS adres,
            --RPAD(NVL(REPLACE(REPLACE(A.isyeri_adres,CHR(10),' '),CHR(13),' ') ,REPLACE(REPLACE(A.ev_adres,CHR(10),' '),CHR(13),' ')),120,' ') ADRES,
            NVL(LPAD(COALESCE(a.isyeri_il_kodu,a.ev_il_kodu),3,0),999) AS  adres_il_kodu,

            NVL(LPAD(i.ilce,2,0),99) AS adres_ilce_kodu,
            --NVL(LPAD(COALESCE(a.isyeri_ilce_aciklama,a.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,-------uyusmayan ilçe kodlarý var .

            LPAD (NVL (NVL (u.id, u2.id), '999'), 3, '0') AS ulke_kodu, ----ulkelerin uyusmasý için parametre tablosuna ihtiyac var

            CASE WHEN a.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(a.ticaret_sicil_no),'                                ') END AS ticaret_sicil_numarasi,

            '                ' AS mersis_numarasi,
            '                    ' AS ticaret_odasi,
            '999' AS ticaret_tescil_il_kodu,
            '99' AS ticaret_tescil_merkezi_kodu,
            LPAD(NVL(a.vergi_dairesi,'                    '),20,' ') AS vergi_dairesi,
            NVL(DECODE(a.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(a.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            --NVL (LPAD (TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
            LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
            LPAD(NVL (TRIM(c.iliski_kkb_kod), '99'),2,'0') AS firma_iliski_kodu,
            '10' || '00099' || LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') AS ilsk_ndn_olan_grc_tzl_refno,

            --LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') ilsk_ndn_olan_grc_unvan,
            LPAD(REPLACE(SUBSTR(b.isim_unvan,1,LENGTH(b.isim_unvan)),CHR(26),' '),100,' ') AS ilsk_ndn_olan_grc_unvan,

            '0' kredi_iliski_kodu,
            --DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999')) ilsk_baslangic_tarihi,
            CASE WHEN DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'))
                      >
                      DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'))
                      THEN '99999999'
                           ELSE DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'))
                                END ilsk_baslangic_tarihi,
            --DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999')) ilsk_bitis_tarihi,
            CASE WHEN DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'))
                      >
                      DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'))
                      THEN '99999999'
                           ELSE DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'))
                                END ilsk_bitis_tarihi,
            CASE WHEN a.kesit_tarihi BETWEEN c.gecici_bastarih and c.gecici_bittarih THEN '1' ELSE '0' END ilsk_gostergesi,
            LPAD (NVL (ROUND (c.istirak_oran * 100, 0), '00000'), 5, '0') ortaklýk_hisse_orani,
            NVL(LPAD(COALESCE(a.isyeri_posta_kod ,a.ev_posta_kod),10,'  '), '          ') AS adres_posta_kod,


            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,

            LPAD (NVL (a.web_adresi, '                                                  '), 50, '  ') AS web_adresi,
            LPAD(NVL(a.mail,'                                                  '),50,'  ') AS e_posta,
            NVL (TO_CHAR (a.uye_clsm_trh, 'yyyymmdd'), 99999999) uye_calisma_baslama_tarih ,
            LPAD(NVL(a.donem_calisan_sayisi,0),10,0) AS calisan_sayisi ,
            RPAD(NVL(kfk.finansman_konusu_kod,'999') ,3,' ') AS finansman_konusu_kodu,
            LPAD(NVL(a.firma_grup_kodu,'          '),10,' ') AS firma_grup_kodu,

            CASE WHEN a.ciro_tutari<0 OR a.ciro_tutari IS NULL THEN 999
            ELSE 792 END AS ciro_doviz_kodu,

            CASE WHEN a.ciro_tutari<0 THEN '               '
            ELSE NVL(LPAD(ROUND(TO_CHAR(a.ciro_tutari),0),15,'0'),'               ') END AS ciro_tutari,

            LPAD(NVL(a.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(a.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(a.min_actarih_grup3,'yyyymmdd'), '00000000') grup3_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup4,'yyyymmdd'), '00000000') grup4_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup5,'yyyymmdd'), '00000000') grup5_alinma_tarihi,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0),15,'0'),'               ') END nakit_limit,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0),15,'0'),'               ') END gayrinakit_limit,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0),15,'0'),'               ') END firma_genel_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0),15,'0'),'               ') END grup_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0),15,'0'),'               ') END grup_riski,

            LPAD(NVL(TO_CHAR(a.genel_revize_vadesi,'yyyymmdd'),'99999999'),8,' ') AS genel_revize_vadesi,
            NVL(TO_CHAR(a.son_revize_tarihi,'yyyymmdd'), 99999999) AS son_revize_tarihi,
            RPAD(' ', 407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbfc_vortex_mus d
            INNER JOIN trfm.tmp_trbfc_iliskili_mus c ON  1=1
                                              AND d.musteri_no=c.musteri_no
                                              and d.kesit_tarihi =c.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct a ON  1=1
                                          AND c.iliskili_musteri_no=a.musteri_no
                                          and c.kesit_tarihi =a.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct b ON 1=1 AND c.musteri_no=b.musteri_no
                                                 and c.kesit_tarihi =b.kesit_tarihi
            LEFT JOIN extr.fs_ilce i ON  1=1
                                     AND LPAD (a.ev_il_kodu, 3, 0) =LPAD(i.il,3,0)
                                     and a.ev_ilce_aciklama = i.aciklama
            LEFT JOIN prsn.prmulkekodu u  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
                                         ON a.isyeri_ulke_kodu= SUBSTR (TRIM (u.value), LENGTH (TRIM (u.value)) - 2, 2)
            LEFT JOIN prsn.prmulkekodu u2 ON a.ev_ulke_kodu= SUBSTR (TRIM (u2.value), LENGTH (TRIM (u2.value)) - 2, 2)
                          /*left join prsn.prmfirmaturu ft
            ON DECODE (a.sirket_tip_acklm, 'ANONÝM', '04',
                                           'ADÝ', '1',
                                           'KOMANDÝT', '02',
                                           'LÝMÝTED', '06',
                                           'KOLLEKTÝF', '05',
                                           'KOOPERATÝF', '20',
                                           'BELÝRTÝLMEMÝÞ', '99',
                                           'ASKERÝ BÝRLÝK', '34',
                                           'ÞÝRKET DEÐÝL (ASKERÝ)', '98',
                                           'ÞÝRKET DEÐÝL (SÝVÝL)', '98',
                                           '99')
                                     = TO_NUMBER (TRIM (ft.id))*/
            LEFT JOIN trfm.tmp_fnsmn_konu kfk ON  1=1
                                                       AND a.finansman_konusu_kodu = kfk.finansman_konusu_kod
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf ON  1 = 1
                                                             AND a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
           --AND a.gercek_tuzel = 'T';
           --AND vtf.tckn_vkn = 'VKN'
           AND vtf.trbfc_trbic_f = 'TRBFC';
   --AND  (REGEXP_SUBSTR(isyeri_adres,CHR(10)) IS NOT NULL
   --               OR  REGEXP_SUBSTR(isyeri_adres,CHR(13)) IS NOT NULL)
   --      OR
   --             (REGEXP_SUBSTR(ev_adres,CHR(10)) IS NOT NULL
   --               OR  REGEXP_SUBSTR(ev_adres,CHR(13)) IS NOT NULL);
   COMMIT;

      v_line_no:=1830;

   ------Teminat dosyasýnda kefil gözüken fakat musteri_iliski tablosunda kefil iliþkili gözükmediðinden tabloya yansýmayan varsa 4 firma iliþki kodlu olarak insert edilir;
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_txt
   SELECT a.kesit_tarihi, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn AS kontrol_tckn_vkn_f,
          b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
          '10' AS veri_turu_kunye,
          '30' AS veri_turu_kredi,
          '10' AS veri_turu_teminat,
          '00099' AS uye_Kodu,
          b.kayit_referans_numarasi, --bu kýsým bu query'de firma künye için yazýldý
          'TRBFC' AS Segment_Turu,
          '02' AS Versiyon_Numarasi,
          '10'
          ||
          '00099'
          ||
          a.kayit_referans_numarasi
          AS tuzel_kisi_ref_no,
          LPAD(a.ilkodu,3,0) AS sube_merkez_il_kodu,
          LPAD(NVL(a.ana_sube,99999),5,0)    sube_eft_kodu,
          RPAD(REPLACE(SUBSTR(a.isim_unvan,1,LENGTH(a.isim_unvan)),CHR(26),' '),100,' ') AS unvan,

          NVL(RPAD(COALESCE( a.isyeri_adres,a.ev_adres),120,' '),'                                                                                                                        ') AS adres,
          --RPAD(NVL(REPLACE(REPLACE(A.isyeri_adres,CHR(10),' '),CHR(13),' ') ,REPLACE(REPLACE(A.ev_adres,CHR(10),' '),CHR(13),' ')),120,' ') ADRES,

          NVL(LPAD(COALESCE(a.isyeri_il_kodu,a.ev_il_kodu),3,0),999) AS adres_il_kodu,

          NVL(LPAD(i.ilce,2,0),99) AS adres_ilce_kodu,
          --NVL(LPAD(COALESCE(a.isyeri_ilce_aciklama,a.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,

          LPAD (NVL (NVL (u.id, u2.id), '999'), 3, '0') AS ulke_kodu,

          CASE WHEN a.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.ticaret_sicil_no)),0),32,0)
          ELSE NVL(TO_CHAR(a.ticaret_sicil_no),'                                ') END  ticaret_sicil_numarasi,

          '                '        mersis_numarasi,
          '                    '    ticaret_odasi,
          '999'                     ticaret_tescil_il_kodu,
          '99'                      ticaret_tescil_merkezi_kodu,
          LPAD(NVL(a.vergi_dairesi,'                    '),20,' ') AS vergi_dairesi,
          NVL(DECODE(a.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(a.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
          a.sirket_tip_ing,
          a.sirket_tip_acklm_ing,
          --NVL (LPAD (TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
          LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
          NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
          '04' AS firma_iliski_kodu,
          '10' || '00099' || LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') ilsk_ndn_olan_grc_tzl_refno,
          --LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') ilsk_ndn_olan_grc_unvan,
          LPAD(REPLACE(SUBSTR(b.isim_unvan,1,LENGTH(b.isim_unvan)),CHR(26),' '),100,' ') ilsk_ndn_olan_grc_unvan,
          '0' AS kredi_iliski_kodu,
          '00000000' AS ilsk_baslangic_tarihi,
          '00000000' AS ilsk_bitis_tarihi,
          '1' AS ilsk_gostergesi,
          '00000' AS ortaklýk_hisse_orani,
          NVL(LPAD(COALESCE(a.isyeri_posta_kod ,a.ev_posta_kod),10,'  '), '          ') AS adres_posta_kod,
          LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
          LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
          LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
          LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
          LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,

          LPAD (NVL (a.web_adresi, '                                                  '), 50, '  ') AS web_adresi,
          LPAD(NVL(a.mail,'                                                  '),50,'  ') AS e_posta,
          NVL (TO_CHAR (a.uye_clsm_trh, 'yyyymmdd'), 99999999) AS uye_calisma_baslama_tarih ,
          LPAD(NVL(a.donem_calisan_sayisi,0),10,0) AS calisan_sayisi ,
          RPAD(NVL(kfk.finansman_konusu_kod,'999') ,3,' ') AS finansman_konusu_kodu,
          LPAD(NVL(a.firma_grup_kodu,'          '),10,' ') AS firma_grup_kodu,

          CASE WHEN a.ciro_tutari<0 OR a.ciro_tutari IS NULL THEN 999
          ELSE 792 END ciro_doviz_kodu,

          CASE WHEN a.ciro_tutari<0 THEN '               '
          ELSE NVL(LPAD(ROUND(TO_CHAR(a.ciro_tutari),0),15,'0'),'               ') END ciro_tutari,

          LPAD(NVL(a.ciro_yili,9999),4,' ') AS ciro_yili,
          LPAD(NVL(a.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
          '                              ' AS risk_grup_kodu_sebebi,
          NVL(TO_CHAR(a.min_actarih_grup3,'yyyymmdd'), '00000000') grup3_alinma_tarihi,---incelenebilir
          NVL(TO_CHAR(a.min_actarih_grup4,'yyyymmdd'), '00000000') grup4_alinma_tarihi,
          NVL(TO_CHAR(a.min_actarih_grup5,'yyyymmdd'), '00000000') grup5_alinma_tarihi,

          CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0) = 0 THEN '               '
               ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0),15,'0'),'               ') END nakit_limit,
          CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0) = 0 THEN '               '
               ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0),15,'0'),'               ') END gayrinakit_limit,

          CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0) = 0 THEN '               '
               ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0),15,'0'),'               ') END firma_genel_limiti,

          CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0) = 0 THEN '               '
               ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0),15,'0'),'               ') END grup_limiti,
          CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0) = 0 THEN '               '
               ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0),15,'0'),'               ') END grup_riski,

          LPAD(NVL(TO_CHAR(a.genel_revize_vadesi,'yyyymmdd'),'99999999'),8,' ') AS genel_revize_vadesi,
          NVL(TO_CHAR(a.son_revize_tarihi,'yyyymmdd'), 99999999) son_revize_tarihi,
          RPAD(' ', 407,' ') AS rezerv_alan1,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM trfm.tmp_trbfc_vortex_mus d
          INNER JOIN (
                       SELECT k.ana_musteri_no, k.kst_trh, k.kefil_musteri_no
                         FROM trfm.tmp_trbgr_mus_iliski k
                        WHERE 1 = 1
                          AND k.kst_trh = v_tarih
                          AND (k.ana_musteri_no, k.kefil_musteri_no) NOT IN (
                                                                               SELECT musteri_no, iliskili_musteri_no
                                                                                 FROM trfm.tmp_trbfc_iliskili_mus
                                                                                WHERE 1 = 1
                                                                                  AND kesit_tarihi = v_tarih
                                                                                  AND iliski_kkb_kod = '4'
                                                                            )
                     ) c ON d.musteri_no=c.ana_musteri_no
                            and d.kesit_tarihi =c.kst_trh
         INNER JOIN prsn.kkb_trbfc_trbic_fct a
                    ON  1=1
                    AND c.kefil_musteri_no = a.musteri_no
                    and c.kst_trh = a.kesit_tarihi
         INNER JOIN prsn.kkb_trbfc_trbic_fct b
                    ON  1=1
                    AND c.ana_musteri_no=b.musteri_no
                    and c.kst_trh =b.kesit_tarihi
         LEFT JOIN extr.fs_ilce i
                   ON 1=1
                   AND LPAD (a.ev_il_kodu, 3, 0) =LPAD(i.il,3,0)
                   and a.ev_ilce_aciklama = i.aciklama
         LEFT JOIN prsn.prmulkekodu u  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
                   ON  1=1
                   AND a.isyeri_ulke_kodu= SUBSTR (TRIM (u.value), LENGTH (TRIM (u.value)) - 2, 2)
         LEFT JOIN prsn.prmulkekodu u2
                   ON 1=1
                   AND a.ev_ulke_kodu= SUBSTR (TRIM (u2.value), LENGTH (TRIM (u2.value)) - 2, 2)
                       /*left join prsn.prmfirmaturu ft
         ON DECODE (a.sirket_tip_acklm, 'ANONÝM', '04',
                                        'ADÝ', '1',
                                        'KOMANDÝT', '02',
                                        'LÝMÝTED', '06',
                                        'KOLLEKTÝF', '05',
                                        'KOOPERATÝF', '20',
                                        'BELÝRTÝLMEMÝÞ', '99',
                                        'ASKERÝ BÝRLÝK', '34',
                                        'ÞÝRKET DEÐÝL (ASKERÝ)', '98',
                                        'ÞÝRKET DEÐÝL (SÝVÝL)', '98',
                                        '99')
                                  = TO_NUMBER (TRIM (ft.id))*/
         LEFT JOIN trfm.tmp_fnsmn_konu kfk
                   ON 1=1
                   AND a.finansman_konusu_kodu = kfk.finansman_konusu_kod
         LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                   ON  1 = 1
                   AND a.musteri_tip = vtf.musteri_tip
   WHERE 1 = 1
         --AND a.gercek_tuzel = 'T';
         --AND vtf.tckn_vkn = 'VKN'
         AND vtf.trbfc_trbic_f = 'TRBFC';
   --AND  (REGEXP_SUBSTR(isyeri_adres,CHR(10)) IS NOT NULL
   --               OR  REGEXP_SUBSTR(isyeri_adres,CHR(13)) IS NOT NULL)
   --      OR
   --             (REGEXP_SUBSTR(ev_adres,CHR(10)) IS NOT NULL
   --               OR  REGEXP_SUBSTR(ev_adres,CHR(13)) IS NOT NULL);
   COMMIT;

      v_line_no:=1840;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbfc_txt;


   PROCEDURE sp_trbgr_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 1900;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbgr_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=1910;

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_txt
     SELECT b.kesit_tarihi, b.teminat_cesidi, b.musteri_no, b.tck_no, b.vergi_no, b.musteri_tip, b.gercek_tuzel,
            vtf.tckn_vkn kontrol_tckn_vkn_f, b.tmnt_refsube, b.tmnt_reftur, b.tmnt_refsirano,
            b.tmnt_referans, b.teminat_turu_kodu_ing, b.teminat_turu_acklm_ing, b.teminat_doviz_kodu,
            CASE WHEN b.krdreftur IS NOT NULL AND b.krdrefsirano IS NOT NULL
                      THEN DECODE (
                                   b.krdreftur,
                                                'AC',     'ITH',
                                                'AL',     'ITH',
                                                'DE',     'NKRD',
                                                'DK',     'NKRD',
                                                'HG',     'TMEK',
                                                'KT',     'KMH',
                                                'LC',     'ITH',
                                                'TD',     'TKRD',
                                                'TK',     'NKRD',
                                                'TM',     'TMEK',
                                                'TT',     'TKRD',
                                                'TY',     'TMEK'
                                  )
                 WHEN b.krdreftur IS NULL AND b.krdrefsirano IS NOT NULL
                      THEN 'GVNC'
                           ELSE NULL
                                END tip,
            b.krdsube, b.krdreftur, b.krdrefnit, b.krdrefsirano,
            CASE WHEN b.krdreftur = 'KT' THEN b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano
                      ELSE b.krdsube || b.krdreftur || b.krdrefsirano
                           END krd_referans,
            '30' AS veri_turu_kredi,
            '10' AS veri_turu_teminat,
            '00099' uye_kodu,
            NVL (
                 CASE WHEN b.krdreftur = 'KT' THEN LPAD (b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano, 20, '0')
                      WHEN b.krdreftur <> 'KT' AND b.krdreftur IS NOT NULL THEN LPAD (b.krdsube || b.krdreftur || b.krdrefsirano, 20, '0')
                           ELSE LPAD (b.kayit_referans_numarasi_tmnt, 20, '0')
                                END
                 , '00000000000000000000') kayit_referans_numarasi_krd,
            b.kayit_referans_numarasi_tmnt,
            'TRBGR' Segment_Turu,
            '02' Versiyon_Numarasi,
            LPAD (NVL (TO_CHAR (b.sube_ilkodu), '   '), 3, 0) AS sube_merkez_ilkodu,
            LPAD(NVL(b.sube_eft_kodu,99999),5,0) AS sube_eft_kodu,
            '32' || '00099' ||
            LPAD (NVL (b.tmnt_referans, '00000000000000000000'), 20, '0') teminat_referans_numarasi,
            CASE WHEN b.krdsube || b.krdreftur || b.krdrefsirano IS NOT NULL THEN (
            '30' || '00099' ||
            NVL (
                 CASE WHEN b.krdreftur = 'KT' THEN LPAD (b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano, 20, '0')
                      WHEN b.krdreftur <> 'KT' AND b.krdreftur IS NOT NULL THEN LPAD (b.krdsube || b.krdreftur || b.krdrefsirano, 20, '0')
                           ELSE LPAD (b.kayit_referans_numarasi_tmnt, 20, '0')
                                END
                 , '00000000000000000000')
            )
            ELSE '                           ' END kredi_hesabi_referans_numarasi,
            --CASE WHEN b.vergi_no IS NOT NULL THEN '10' WHEN b.tck_no IS NOT NULL THEN '20' END
            '10'
            || '00099' || '00' ||
            CASE WHEN b.tck_no IS NOT NULL THEN '6'
                 WHEN b.vergi_no IS NOT NULL THEN '5'
                 WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN
                 (
                 CASE WHEN b.GERCEK_TUZEL='G' THEN '6'
                  ELSE '5'
                  END
                 )
                      END
            || '000000'
            ||
            CASE WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN '00000000000'
                 WHEN b.tck_no IS NOT NULL THEN b.tck_no
                 WHEN b.vergi_no IS NOT NULL THEN  '0'||b.vergi_no
            END tuzel_gercek_ref_no_kredi,
            --CASE WHEN b.vergi_no IS NOT NULL THEN '10' WHEN b.tck_no IS NOT NULL THEN '20' END
            '10' || '00099' || '00' ||
            CASE WHEN b.tck_no IS NOT NULL THEN '6'
                 WHEN b.vergi_no IS NOT NULL THEN '5'
                 WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN
                 (
                 CASE WHEN b.GERCEK_TUZEL='G' THEN '6'
                  ELSE '5'
                  END
                 )
              END
            || '000000'
            ||
            CASE WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN '00000000000'
              WHEN b.tck_no IS NOT NULL THEN b.tck_no
              WHEN b.vergi_no IS NOT NULL THEN  '0'||b.vergi_no
             END tuzel_gercek_ref_no_teminat,
            --LPAD(NVL(c.id,99),2,0) teminat_turu_kodu,
            LPAD (
                  CASE WHEN b.teminat_turu_kodu_ing = 47 THEN '28'
                       WHEN b.teminat_turu_kodu_ing = 56 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 59 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 12 THEN '27'
                       WHEN b.teminat_turu_kodu_ing = 57 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 22 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 47 THEN '28'
                       WHEN b.teminat_turu_kodu_ing = 51 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 52 THEN '44'
                       WHEN b.teminat_turu_kodu_ing = 56 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 57 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 59 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 10 THEN '29'
                       WHEN b.teminat_turu_kodu_ing = 11 THEN '29'
                       WHEN b.teminat_turu_kodu_ing = 32 THEN '11'
                       WHEN b.teminat_turu_kodu_ing = 51 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 52 THEN '44'
                       WHEN c.id IS NOT NULL THEN c.id
                            END,
                  2,
                  '0'
                 ) teminat_turu_kodu,
            LPAD(ROUND(b.teminat_degeri,0),15,0) AS teminat_degeri,
            CASE WHEN b.tmnt_alindigi_trh IS NOT NULL  THEN  SUBSTR(b.tmnt_alindigi_trh,7,4)||SUBSTR(b.tmnt_alindigi_trh,4,2)||SUBSTR(b.tmnt_alindigi_trh,1,2)
            ELSE '99999999' END tmnt_alindigi_trh,
            NVL(TO_CHAR(b.son_degerleme_trh,'yyyymmdd') ,99999999 )son_degerleme_trh,
            LPAD(NVL(t.id1 ,999),3,0) doviz_kodu,
            CASE WHEN b.piyasa_ekspertiz_degeri  IS NOT NULL THEN LPAD(ROUND(b.piyasa_ekspertiz_degeri,0),15,0)
            ELSE '000000000000000' END  piyasa_ekspertiz_degeri,
            1 teminat_aktif_pasif_kodu,
            CASE WHEN b.cek_senet_adedi IS NOT NULL THEN  LPAD(b.cek_senet_adedi,6,0)
            ELSE '000000' END cek_senet_adedi,
            CASE WHEN c.id <> 45 OR b.kefil_adet IS NULL THEN '00' ELSE LPAD (b.kefil_adet, 2, '0') END kefil_adet,
            CASE WHEN b.kefalet_miktari  IS NOT NULL THEN LPAD(ROUND(b.kefalet_miktari,0),15,0) ELSE NULL END kefalet_miktari,
            RPAD(' ', 967,' ') AS  rezerv_alan_1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbgr_fct b
            LEFT OUTER JOIN prsn.prmteminatturu c
                            ON     1 = 1
                               AND b.teminat_turu_kodu_ing = c.lookupvalue
            LEFT OUTER JOIN extr.fs_para p
                            ON     1 = 1
                               AND b.teminat_doviz_kodu = p.para
            LEFT OUTER JOIN prsn.prmdovizkodlari t
                            ON     1 = 1
                               AND DECODE (p.swift_kisaad, 'TRY', 'TRL', p.swift_kisaad) = t.id2
            LEFT OUTER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                            ON     1 = 1
                               AND b.musteri_tip = vtf.musteri_tip
            LEFT OUTER JOIN (SELECT DISTINCT (i.refsube || i.reftur || i.refsirano) AS referans
                               FROM prsn.kkb_trbac_fct i
                              WHERE i.kst_trh = v_tarih
                            ) rf
                            ON  1=1
                            AND rf.referans = CASE WHEN b.krdreftur = 'KT' THEN b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano
                                                   ELSE b.krdsube || b.krdreftur || b.krdrefsirano
                                              END
      WHERE 1 = 1
        AND b.kesit_tarihi = v_tarih
        AND (
                 rf.referans IS NOT NULL
              OR (
                  CASE WHEN b.krdreftur = 'KT' THEN b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano
                            ELSE b.krdsube || b.krdreftur || b.krdrefsirano
                                 END
                 ) IS NULL
            );

      COMMIT;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_txt;


   PROCEDURE sp_trbhf_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBHF_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2000;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbhf_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2010;

      INSERT INTO prsn.kkb_trbhf_txt
      (KESIT_TARIHI, REZERV_ALAN_1, SEGMENT_TURU, VERSIYON_NUMARASI, UYE_KODU, VERI_TURU_KODU_FIRMA, VERI_TURU_KODU_KREDI,
       VERI_TURU_KODU_TEMINAT, BILDIRIM_DONEMI, BILDIRIM_TARIHI, REZERV_ALAN_2, REZERV_ALAN_3, ETL_TRH, ETL_JOB)
      VALUES ( v_tarih,
               RPAD(' ', 27,' '),
               'TRBHF',
               '02',
               '00099',
               10,
               30,
               32,
               TO_NUMBER (TO_CHAR (v_tarih, 'YYYYMM')),
               TO_NUMBER (TO_CHAR (v_tarih, 'YYYYMMDD')),
               0,
               RPAD(' ', 1244,' '),
              SYSDATE,
              v_sp_name
             );
      COMMIT;



   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbhf_txt;


   PROCEDURE sp_trbic_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBIC_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2100;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbic_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2110;

   ---Ýliskili Musteriler---
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbic_txt
     SELECT a.kesit_tarihi, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
            '10' veri_turu_kunye,
            '30' veri_turu_kredi,
            '10' veri_turu_teminat,
            '00099' uye_kodu,
            b.kayýt_referans_numarasi,
            'TRBIC' Segment_Turu,
            '02' Versiyon_Numarasi,
            '20'
            ||'00099'
            ||'00'||
            CASE WHEN a.tck_no IS NOT NULL THEN '6' ELSE '0' END
            ||
            '000000'
            ||
            COALESCE(a.tck_no,'00000000000')  gercek_kisi_ref_no,
            LPAD(NVL(a.ana_sube,99999),5,0) sube_eft_kodu,
            LPAD(NVL(a.ilkodu,999),3,0) sube_merkez_il_kodu,
            LPAD(NVL (TRIM(c.iliski_kkb_kod), '99'),2,'0') AS firma_iliski_kodu,
            LPAD(NVL(a.isim,'               '),15,' ') AS isim,
            LPAD(NVL(a.ikinci_isim,'               '),15,' ') AS ikinci_isim,
            LPAD(NVL(a.ikinci_isim,'               '),30,' ') AS soyad,
            NVL(TO_CHAR (a.dogum_tarihi, 'YYYYMMDD'),'99999999') AS dogum_tarihi,

            COALESCE(d1.kimlik_turu_kodu,9) AS kimlik_kod_1,
            LPAD(COALESCE(a.kimlik_kod_1_seri_no, '                    '),20,' ') kimlik_no_1,
            COALESCE(d2.kimlik_turu_kodu,9) AS kimlik_kod_2,
            LPAD(COALESCE(a.kimlik_kod_2_seri_no,'                    '),20,' ') kimlik_no_2,
            COALESCE(d3.kimlik_turu_kodu,9) AS kimlik_kod_3,
            LPAD(COALESCE(a.kimlik_kod_3_seri_no,'                    '),20,' ') kimlik_no_3,
            COALESCE(d4.kimlik_turu_kodu,9) AS kimlik_kod_4,
            LPAD(COALESCE(a.kimlik_kod_4_seri_no,'                    '),20,' ') kimlik_no_4,

            LPAD(COALESCE(a.isyeri_adres,'                                                                                                                        '),120,' ') AS is_adresi,
            LPAD(COALESCE(TO_CHAR (a.isyeri_il_kodu),'999'),3,'0') AS is_adresi_il_kodu,

            NVL(LPAD(bi.ilce,2,0),'99') is_adresi_ilce_kodu,
            --LPAD (COALESCE(bi.ilce_kodu,'99'), 2, 0) AS is_adresi_ilce_kodu,--kkb

            NVL (LPAD(COALESCE(a.ev_adres,''),120,' '), '                                                                                                                        ') AS ev_adresi,

            LPAD(COALESCE(TO_CHAR (a.ev_il_kodu),'999'),3,0) AS ev_adresi_il_kodu,

            NVL(LPAD(bi.ilce,2,0),99) AS ev_adresi_ilce_kodu,--kkb

            LPAD(COALESCE(TO_CHAR (a.uyruk_kodu),'999'),3,0) AS uyruk,
            '10'
            ||
            '00099'
            ||
            LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') ilsk_ndn_olan_grc_tzl_refno,
            LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') ilsk_ndn_olan_grc_unvan,
            '0' AS kredi_iliski_kodu,
            DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD'), '99999999')) ilsk_baslangic_tarihi,
            DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999')) ilsk_bitis_tarihi,
            CASE WHEN c.gecici_bastarih IS NULL OR c.gecici_bittarih IS NULL THEN '0' ELSE (CASE WHEN   a.kesit_tarihi BETWEEN c.gecici_bastarih  and c.gecici_bittarih THEN '1' ELSE '0' END) END  ilsk_gostergesi,
            LPAD (NVL (ROUND (c.istirak_oran * 100, 0), '00000'), 5, '0') ortaklýk_hisse_orani,
            NVL (LPAD (b.isim_unvan, 30, ' '), '                              ') unvan,
            '9' AS imza_yetkisi_kodu,
            LPAD(COALESCE(a.ev_posta_kod,'          '),10,' ') AS ev_adresi_posta_kodu,
            LPAD(COALESCE(a.isyeri_posta_kod,'          '),10,' ') AS is_adresi_posta_kodu,


            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,

            LPAD(COALESCE(TO_CHAR (a.ev_tel_formatlý_tel_no),'                ') ,16,' ') AS ev_tel_formatlý_tel_no,
            LPAD(COALESCE(TO_CHAR (a.cep_tel_formatlý_tel_no),'                ') ,16,' ') AS cep_tel_formatlý_tel_no,
            LPAD(COALESCE(a.mail,'                                                  '),50,' ') AS e_posta,
            --LPAD(NVL(d.lookupvalue,99),2,' ') AS meslek_kodu,----lookup value deðelreri guncel deðil edizlerin guncellemesi gerekiyor.
            --LPAD(NVL(d.value,null),30,' ')     AS meslek
            LPAD (COALESCE (a.meslek_kkb_kod, '99'), 2, ' ') AS meslek_kodu,
            LPAD (COALESCE (a.meslek_kkb_kod_acklm, '                                  '), '30', ' ') AS meslek,
            LPAD (COALESCE (a.egitim_kkb_kod, '99'), 2, ' ') AS egitim_durumu_kodu,
            LPAD (COALESCE (a.egitim_kkb_kod_acklm, '                                  '), '30', ' ') AS egitim_durumu,
            RPAD(' ', 461,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
      FROM  trfm.tmp_trbfc_vortex_mus d
            INNER JOIN trfm.tmp_trbfc_iliskili_mus c ON d.musteri_no=c.musteri_no
                                              and d.kesit_tarihi =c.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct a ON c.iliskili_musteri_no=a.musteri_no
                                          and c.kesit_tarihi =a.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct b ON c.musteri_no=b.musteri_no
                                          and c.kesit_tarihi =b.kesit_tarihi

            LEFT JOIN extr.fs_ilce bi ON  1=1
                                      AND LPAD (a.ev_il_kodu, 3, 0) =LPAD(bi.il,3,0)
                                      and a.ev_ilce_aciklama = bi.aciklama


            LEFT JOIN trfm.tmp_kkb_kmlk_tur d1 ON
                        CASE WHEN a.kimlik_kod_1='SB' THEN 2
                             WHEN a.kimlik_kod_1='NC'  THEN 3
                             WHEN a.kimlik_kod_1 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                             WHEN a.kimlik_kod_1 IS NULL THEN 9
                        END = d1.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d2 ON
                        CASE WHEN a.kimlik_kod_2='SB' THEN 2
                             WHEN a.kimlik_kod_2='NC'  THEN 3
                             WHEN a.kimlik_kod_2 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                             WHEN a.kimlik_kod_2 IS NULL THEN 9
                        END = d2.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d3 ON
                        CASE WHEN a.kimlik_kod_3='SB' THEN 2
                             WHEN a.kimlik_kod_3='NC'  THEN 3
                             WHEN a.kimlik_kod_3 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                             WHEN a.kimlik_kod_3 IS NULL THEN 9
                        END = d3.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d4 ON
                        CASE WHEN a.kimlik_kod_4='SB' THEN 2
                             WHEN a.kimlik_kod_4='NC'  THEN 3
                             WHEN a.kimlik_kod_4 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                             WHEN a.kimlik_kod_4 IS NULL THEN 9
                        END = d4.kimlik_turu_kodu

            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                                     ON     1 = 1
                                        AND a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
           --AND a.gercek_tuzel = 'G';
           --AND vtf.tckn_vkn = 'TCKN'
           AND vtf.trbfc_trbic_f = 'TRBIC';

   COMMIT;
   v_line_no:=2115;
   ---------------------------------------------

   --Teminat dosyasýnda kefil gözüken fakat musteri_iliski tablosunda kefil iliþkili gözükmediðinden tabloya yansýmayan varsa 4 firma iliþki kodlu olarak insert edilir;
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbic_txt
     SELECT a.kesit_tarihi, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
            '10' AS veri_turu_kunye,
            '30' AS veri_turu_kredi,
            '10' AS veri_turu_teminat,
            '00099' AS uye_kodu,
            b.kayýt_referans_numarasi,
            'TRBIC' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            '20'
            ||'00099'
            ||'00'||
            CASE WHEN a.tck_no IS NOT NULL THEN '6' ELSE '0' END
            ||
            '000000'
            ||
            COALESCE(a.tck_no,'00000000000') AS gercek_kisi_ref_no,
            LPAD(NVL(a.ana_sube,99999),5,0) AS sube_eft_kodu,
            LPAD(NVL(a.ilkodu,999),3,0) AS sube_merkez_il_kodu,
            '04' AS firma_iliski_kodu,
            LPAD(NVL(a.isim,'               '),15,' ') AS isim,
            LPAD(NVL(a.ikinci_isim,'               '),15,' ') AS ikinci_isim,
            LPAD(NVL(a.ikinci_isim,'               '),30,' ') AS soyad,
            NVL(TO_CHAR (a.dogum_tarihi, 'YYYYMMDD'),'99999999')as dogum_tarihi,
            COALESCE(d1.kimlik_turu_kodu,9) AS kimlik_kod_1,
            LPAD(COALESCE(a.kimlik_kod_1_seri_no,'                    '),20,' ') AS kimlik_no_1,
            COALESCE(d2.kimlik_turu_kodu,9) AS kimlik_kod_2,
            LPAD(COALESCE(a.kimlik_kod_2_seri_no,'                    '),20,' ') AS kimlik_no_2,
            COALESCE(d3.kimlik_turu_kodu,9) AS kimlik_kod_3,
            LPAD(COALESCE(a.kimlik_kod_3_seri_no,'                    '),20,' ') AS kimlik_no_3,
            COALESCE(d4.kimlik_turu_kodu,9) AS kimlik_kod_4,
            LPAD(COALESCE(a.kimlik_kod_4_seri_no,'                    '),20,' ') AS kimlik_no_4,
            LPAD(COALESCE(a.isyeri_adres,'                                                                                                                        '),120,' ') AS is_adresi,
            LPAD(COALESCE(TO_CHAR (a.isyeri_il_kodu),'999'),3,'0') AS is_adresi_il_kodu,
            NVL(LPAD(bi.ilce,2,0),99) AS is_adresi_ilce_kodu,--kkb
            NVL (LPAD(COALESCE(a.ev_adres,''),120,' '), '                                                                                                                        ') AS ev_adresi,
            LPAD(COALESCE(TO_CHAR (a.ev_il_kodu),'999'),3,0) AS ev_adresi_il_kodu,
            NVL(LPAD(bi.ilce,2,0),99) AS ev_adresi_ilce_kodu,--kkb
            LPAD(COALESCE(TO_CHAR (a.uyruk_kodu),'999'),3,0) AS uyruk,
            '10'
            ||
            '00099'
            ||
            LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') AS ilsk_ndn_olan_grc_tzl_refno,
            LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') AS ilsk_ndn_olan_grc_unvan,
            '0' AS kredi_iliski_kodu,
            '99999999' AS ilsk_baslangic_tarihi,
            '99999999' AS ilsk_bitis_tarihi,
            '1' AS ilsk_gostergesi,
            '00000' AS ortaklýk_hisse_orani,
            NVL (LPAD (b.isim_unvan, 30, ' '), '                              ') AS unvan,
            '9' AS imza_yetkisi_kodu,
            LPAD(COALESCE(a.ev_posta_kod,'          '),10,' ') AS ev_adresi_posta_kodu,
            LPAD(COALESCE(a.isyeri_posta_kod,'          '),10,' ') AS is_adresi_posta_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,
            LPAD(COALESCE(TO_CHAR (a.ev_tel_formatlý_tel_no),'                ') ,16,' ') AS ev_tel_formatlý_tel_no,
            LPAD(COALESCE(TO_CHAR (a.cep_tel_formatlý_tel_no),'                ') ,16,' ') AS cep_tel_formatlý_tel_no,
            LPAD(COALESCE(a.mail,'                                                  '),50,' ') AS e_posta,
            --LPAD(NVL(d.lookupvalue,99),2,' ') AS meslek_kodu,----lookup value deðelreri guncel deðil edizlerin guncellemesi gerekiyor.
            --LPAD(NVL(d.value,null),30,' ')     AS meslek
            LPAD (COALESCE (a.meslek_kkb_kod, '99'), 2, ' ') AS meslek_kodu,
            LPAD (COALESCE (a.meslek_kkb_kod_acklm, '                                  '), '30', ' ') AS meslek,
            LPAD (COALESCE (a.egitim_kkb_kod, '99'), 2, ' ') AS egitim_durumu_kodu,
            LPAD (COALESCE (a.egitim_kkb_kod_acklm, '                                  '), '30', ' ') AS egitim_durumu,
            RPAD(' ', 461,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
      FROM  trfm.tmp_trbfc_vortex_mus d
            INNER JOIN (
                          SELECT k.kst_trh, k.ana_musteri_no, k.kefil_musteri_no
                            FROM trfm.tmp_trbgr_mus_iliski k
                           WHERE 1 = 1
                             AND k.kst_trh = v_tarih
                             AND (k.ana_musteri_no, k.kefil_musteri_no) NOT IN (
                                                                                  SELECT musteri_no, iliskili_musteri_no
                                                                                    FROM trfm.tmp_trbfc_iliskili_mus
                                                                                   WHERE 1 = 1
                                                                                     AND kesit_tarihi = v_tarih
                                                                                     AND iliski_kkb_kod = '4'
                                                                               )
                       ) c ON 1=1
                          AND d.musteri_no=c.ana_musteri_no
                          AND d.kesit_tarihi =c.kst_trh
            INNER JOIN prsn.kkb_trbfc_trbic_fct a ON c.kefil_musteri_no=a.musteri_no
                                         and c.kst_trh =a.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct b ON c.ana_musteri_no=b.musteri_no
                                         and c.kst_trh =b.kesit_tarihi
            LEFT JOIN extr.fs_ilce bi ON LPAD(a.ev_il_kodu, 3, 0) = LPAD(bi.il,3,0)
                                       and a.ev_ilce_aciklama = bi.aciklama
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d1 ON
                         CASE WHEN a.kimlik_kod_1='SB' THEN 2
                              WHEN a.kimlik_kod_1='NC' THEN 3
                              WHEN a.kimlik_kod_1 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                              WHEN a.kimlik_kod_1 IS NULL THEN 9
                         END = d1.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d2 ON
                        CASE WHEN a.kimlik_kod_2='SB' THEN 2
                             WHEN a.kimlik_kod_2='NC'  THEN 3
                             WHEN a.kimlik_kod_2 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                             WHEN a.kimlik_kod_2 IS NULL THEN 9
                        END = d2.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d3 ON
                        CASE WHEN a.kimlik_kod_3='SB' THEN 2
                             WHEN a.kimlik_kod_3='NC'  THEN 3
                             WHEN a.kimlik_kod_3 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                             WHEN a.kimlik_kod_3 IS NULL THEN 9
                        END = d3.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d4 ON
                      CASE WHEN a.kimlik_kod_4='SB' THEN 2
                           WHEN a.kimlik_kod_4='NC'  THEN 3
                           WHEN a.kimlik_kod_4 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                           WHEN a.kimlik_kod_4 IS NULL THEN 9
                      END = d4.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                                  ON     1 = 1
                                     AND a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            --AND a.gercek_tuzel = 'G';
            --AND vtf.tckn_vkn = 'TCKN'
            AND vtf.trbfc_trbic_f = 'TRBIC';

   COMMIT;
   v_line_no:=2120;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbic_txt;




   PROCEDURE sp_trbfc_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBFC_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2200;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbfc_txt_krd WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2210;

   INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_txt_krd
     SELECT a.kesit_tarihi, f.tip, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            a.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no, f.refsube, f.reftur, f.refsirano,
            f.aylik_ilk_bildirim_f,
            '30' AS veri_turu,
            '00099' AS uye_Kodu,
            --LPAD (f.refsube || f.reftur || f.refsirano || CASE WHEN TO_CHAR (f.tip) = 'KMH' THEN TO_CHAR (f.musteri_no) ELSE NULL END, 20, ' ') kayit_referans_numarasi, -----------------------------02/01/2017
            LPAD (CASE WHEN f.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (f.refsube) || TO_CHAR (f.reftur) || TO_CHAR (f.refsirano)
                       WHEN f.tip IN ('KMH', 'MMZC') THEN f.refsube || f.musteri_no || f.reftur || f.refsirano
                       ELSE NULL
                  END, 20, '0') AS kayit_referans_numarasi,
            'TRBFC' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            '10' || '00099' || a.kayit_referans_numarasi AS tuzel_kisi_ref_no,
            LPAD(a.ilkodu,3,0) AS sube_merkez_il_kodu,
            LPAD(NVL(TO_CHAR (a.ana_sube), '99999'),5,'0') AS sube_eft_kodu,
            RPAD(REPLACE(SUBSTR(a.isim_unvan,1,LENGTH(a.isim_unvan)),CHR(26),' '),100,' ') AS unvan,
            NVL (RPAD(COALESCE( a.isyeri_adres,a.ev_adres),120,' '), LPAD(' ',120,' ') ) AS adres  ,
            NVL(LPAD(COALESCE(a.isyeri_il_kodu,a.ev_il_kodu),3,0),999) AS  adres_il_kodu,
            --NVL(LPAD(i.ilce,2,0),99) adres_ilce_kodu,
            NVL(LPAD(COALESCE(a.kkb_isyeri_il_ilce_kod,a.kkb_ev_il_ilce_kod),2,'0'),99) AS  adres_ilce_kodu,
            --NVL(LPAD(COALESCE(a.isyeri_ilce_aciklama,a.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,-------uyusmayan ilçe kodlarý var edize sorulacak.
            LPAD(NVL(u.id,'999'),3,'0') AS ulke_kodu,----ulkelerin uyusmasý için parametre tablosuna ihtiyac var
            CASE WHEN a.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(a.ticaret_sicil_no),'                                ') END AS ticaret_sicil_numarasi,
            '                ' AS mersis_numarasi,
            '                    ' AS ticaret_odasý,
            DECODE(a.firma_merkez_il, NULL, '999', 0, '999', LPAD(a.firma_merkez_il,3,'0')) AS ticaret_tescil_il_kodu,
            '99' AS ticaret_tescil_merkezi_kodu,
            LPAD(NVL(a.vergi_dairesi,'                    '),20,' ') AS vergi_dairesi,
            NVL(DECODE(a.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(a.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
            '00' AS firma_iliski_kodu,
            '                           ' ilsk_ndn_olan_grc_tzl_refno,
            LPAD(' ',100,' ') AS ilsk_ndn_olan_grc_unvan,
            '1' AS kredi_iliski_kodu, --ana müþteri 1
            '00000000' AS ilsk_baslangic_tarihi,
            '00000000' AS ilsk_bitis_tarihi,
            ' ' AS ilsk_gostergesi,
            '00000' AS ortaklýk_hisse_orani,
            NVL (LPAD(COALESCE(a.isyeri_posta_kod ,a.ev_posta_kod),10,' '), '          ') AS adres_posta_kod,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,
            NVL (LPAD (a.web_adresi, 50, ' '), '                                                  ') web_adresi,
            NVL (LPAD(a.mail,50,' '), '                                                  ') AS e_posta,
            NVL (TO_CHAR (a.uye_clsm_trh, 'yyyymmdd'), 99999999) AS uye_calisma_baslama_tarih ,
            LPAD(NVL(a.donem_calisan_sayisi,0),10,0) AS calisan_sayisi ,
            RPAD(NVL(kfk.finansman_konusu_kod,'999') ,3,' ') AS finansman_konusu_kodu,
            LPAD(NVL(a.firma_grup_kodu,'          '),10,' ') AS firma_grup_kodu,
            CASE WHEN a.ciro_tutari<0 OR a.ciro_tutari IS NULL THEN 999
                 ELSE 949 --792
            END AS ciro_doviz_kodu,
            CASE WHEN a.ciro_tutari<0 THEN '               '
                 ELSE NVL(LPAD(ROUND(TO_CHAR(a.ciro_tutari),0),15,'0'),'               ')
            END AS ciro_tutari,
            LPAD(NVL(a.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(a.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(a.min_actarih_grup3,'yyyymmdd'), '00000000') grup3_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup4,'yyyymmdd'), '00000000') grup4_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup5,'yyyymmdd'), '00000000') grup5_alinma_tarihi,
            CASE WHEN a.tllimit_nakit IS NOT NULL AND a.tllimit_nakit<>0 THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0),15,'0')
                 ELSE NVL(LPAD(TO_CHAR(a.tllimit_nakit),15,'0'),'               ')
            END  nakit_limit,
            CASE WHEN a.tllimit_gayrinakit IS NOT NULL AND a.tllimit_gayrinakit<>0 THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0),15,'0')
                 ELSE NVL(LPAD(TO_CHAR(a.tllimit_gayrinakit),15,'0'),'               ')
            END AS gayrinakit_limit,
            CASE WHEN a.tllimit_nakit_genel IS NOT NULL AND a.tllimit_nakit_genel<>0 THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0),15,'0')
                 ELSE NVL(LPAD(TO_CHAR(a.tllimit_nakit_genel),15,'0'),'               ')
            END firma_genel_limiti,
            CASE WHEN a.grup_limit IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0),15,'0')
                 ELSE NVL(LPAD(TO_CHAR(a.grup_limit),15,'0'),'               ')
            END AS grup_limiti,
            CASE WHEN a.grup_risk IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0),15,'0')
                 ELSE NVL(LPAD(TO_CHAR(a.grup_risk),'0'),'               ')
            END AS grup_riski,
            LPAD(NVL(TO_CHAR(a.genel_revize_vadesi,'yyyymmdd'),'99999999'),8,' ') AS genel_revize_vadesi,
            NVL(TO_CHAR(a.son_revize_tarihi,'yyyymmdd'), 99999999) AS son_revize_tarihi,
            LPAD(' ',407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbfc_trbic_fct a
            INNER JOIN trfm.tmp_trbfc_vortex_mus b ON  1=1
                                              AND a.musteri_no=b.musteri_no
                                              AND a.kesit_tarihi = b.kesit_tarihi
            INNER JOIN prsn.kkb_trbac_fct f ON  1=1
                                    AND a.kesit_tarihi = f.kst_trh
                                    AND a.musteri_no = f.musteri_no
                          /*LEFT JOIN extr.fs_ilce i ON  1=1
                                     AND LPAD (a.ev_il_kodu, 3, 0) = LPAD(i.il,3,0)
                                     AND a.ev_ilce_aciklama = i.aciklama*/
            LEFT JOIN prsn.prmulkekodu u ON a.isyeri_ulke_kodu= SUBSTR (TRIM (u.value), LENGTH (TRIM (u.value)) - 2, 2)
            LEFT JOIN trfm.tmp_fnsmn_konu kfk ON  1=1
                                                       AND a.finansman_konusu_kodu = kfk.finansman_konusu_kod
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf ON  1=1
                                                             AND a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            AND a.kesit_tarihi = v_tarih;
            --AND a.gercek_tuzel = 'T';
            --AND vtf.tckn_vkn = 'VKN'
            --AND vtf.trbfc_trbic_f = 'TRBFC'

   COMMIT;
   v_line_no:=2220;



   ---iliþkili musteriler
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_txt_krd
     SELECT a.kesit_tarihi, f.tip, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn AS kontrol_tckn_vkn_f,
            b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
            f.refsube, f.reftur, f.refsirano, f.aylik_ilk_bildirim_f,
            '30' AS veri_turu,
            '00099' AS uye_Kodu,
            --LPAD (f.refsube || f.reftur || f.refsirano || CASE WHEN TO_CHAR (f.tip) = 'KMH' THEN TO_CHAR (f.musteri_no) ELSE NULL END, 20, ' ') kayit_referans_numarasi, -----------------------------02/01/2017
            LPAD (CASE WHEN f.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (f.refsube) || TO_CHAR (f.reftur) || TO_CHAR (f.refsirano)
                       WHEN f.tip IN ('KMH', 'MMZC') THEN f.refsube || f.musteri_no || f.reftur || f.refsirano
                       ELSE NULL
                  END, 20, '0') AS kayit_referans_numarasi,
            'TRBFC' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            '10' || '00099' || a.kayit_referans_numarasi AS tuzel_kisi_ref_no,
            NVL(LPAD(a.ilkodu,3,0), '   ') AS sube_merkez_il_kodu,
            LPAD(NVL (TO_CHAR (a.ana_sube), '99999'), 5, '0') AS sube_eft_kodu,
            NVL(RPAD(a.isim_unvan,100,' '), '                                                                                                    ') AS unvan,
            NVL(RPAD(COALESCE( a.isyeri_adres,a.ev_adres),120,' '), '                                                                                                                        ') AS adres  ,
            NVL(LPAD(COALESCE(a.isyeri_il_kodu,a.ev_il_kodu),3,0),999) AS  adres_il_kodu,
            --NVL(LPAD(i.ilce,2,0),99) adres_ilce_kodu,
            NVL(LPAD(COALESCE(a.kkb_isyeri_il_ilce_kod,a.kkb_ev_il_ilce_kod),2,'0'),99) AS  adres_ilce_kodu,
            --NVL(LPAD(COALESCE(a.isyeri_ilce_aciklama,a.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,-------uyusmayan ilçe kodlarý var edize sorulacak.
            LPAD(NVL(u.id,'999'),3,'0')  ulke_kodu,----ulkelerin uyusmasý için parametre tablosuna ihtiyac var
            CASE WHEN a.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(a.ticaret_sicil_no),'                                ') END  ticaret_sicil_numarasi,
            '                '     AS mersis_numarasi,
            '                    ' AS ticaret_odasý,
            DECODE(a.firma_merkez_il, NULL, '999', 0, '999', LPAD(a.firma_merkez_il,3,'0'))     AS ticaret_tescil_il_kodu,
            '99'                   AS ticaret_tescil_merkezi_kodu,
            NVL (LPAD(a.vergi_dairesi,20,' '), '                    ') AS vergi_dairesi,
            NVL(DECODE(a.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(a.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            --NVL (LPAD (TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
            LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
            LPAD(NVL (TRIM(c.iliski_kkb_kod), '99'),2,'0') AS firma_iliski_kodu,
            '10' || '00099' || LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') ilsk_ndn_olan_grc_tzl_refno,
            LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') ilsk_ndn_olan_grc_unvan,
            '1' AS kredi_iliski_kodu,
            --DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999')) ilsk_baslangic_tarihi,
            CASE WHEN DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'))
                      >
                      DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'))
                      THEN '99999999'
                           ELSE DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'))
                                END ilsk_baslangic_tarihi,
            --DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999')) ilsk_bitis_tarihi,
            CASE WHEN DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD') ,'99999999'))
                      >
                      DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'))
                      THEN '99999999'
                           ELSE DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'))
                                END ilsk_bitis_tarihi,
            LPAD (CASE WHEN c.gecici_bastarih IS NULL OR gecici_bittarih IS NULL THEN 0 ELSE (CASE WHEN a.kesit_tarihi BETWEEN c.gecici_bastarih  AND c.gecici_bittarih THEN 1 ELSE 0 END) END, 1, '0') ilsk_gostergesi,
            LPAD (NVL (ROUND (c.istirak_oran * 100, 0), '00000'), 5, '0') ortaklýk_hisse_orani,
            NVL (LPAD(COALESCE(a.isyeri_posta_kod ,a.ev_posta_kod),10,' '), '          ') AS adres_posta_kod,

                          /*NVL(LPAD(COALESCE(a.isyeri_tel_ulke_kodu,a.ev_tel_ulke_kodu,a.cep_tel_ulke_kodu ),4,0),'    ') AS  tlf_ulke_kodu,   ---NVL (x,null)??????

            NVL(LPAD(COALESCE(a.isyeri_tel_alan_kodu,a.ev_tel_alan_kodu,a.cep_tel_alan_kodu) ,3,0),'   ') AS  tlf_bolge_kodu,  ---NVL (x,null)??????

            NVL(LPAD(COALESCE(a.isyeri_tel_numara,a.ev_tel_numara,a.cep_tel_numara) ,9,0),'         ') AS  tlf_numarasi,  ---NVL (x,null)??????

            NVL(LPAD(COALESCE(a.isyeri_tel_formatlý_tel_no,a.ev_tel_formatlý_tel_no,a.cep_tel_formatlý_tel_no) ,16,0),'                ') AS  formatli_telefon_numarasi,  ---NVL (x,null)??????*/

            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,
            NVL (LPAD (a.web_adresi, 50, ' '), '                                                  ') AS web_adresi,
            NVL (LPAD(a.mail,50,' '), '                                                  ') AS e_posta,
            NVL (TO_CHAR (a.uye_clsm_trh, 'yyyymmdd'), 99999999) AS uye_calisma_baslama_tarih ,
            LPAD(NVL( a.donem_calisan_sayisi ,0),10,' ') AS calisan_sayisi,
            RPAD(NVL(kfk.finansman_konusu_kod,'999') ,3,' ') AS finansman_konusu_kodu,
            NVL (LPAD(a.firma_grup_kodu,10,' '), '          ') AS firma_grup_kodu,
            LPAD(NVL(a.ciro_para_kodu,999),3,0) AS ciro_doviz_kodu,
            CASE WHEN a.ciro_tutari  IS NOT NULL
                 THEN LPAD(TO_CHAR(ROUND(a.ciro_tutari,0)),15,'0')
                 ELSE NVL(TO_CHAR(a.ciro_tutari),'               ')
            END AS ciro_tutari,
            LPAD(NVL(a.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(a.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(a.min_actarih_grup3,'yyyymmdd'), '00000000') AS grup3_alinma_tarihi,---incelenebilir
            NVL(TO_CHAR(a.min_actarih_grup4,'yyyymmdd'), '00000000') AS grup4_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup5,'yyyymmdd'), '00000000') AS grup5_alinma_tarihi,
            CASE WHEN a.tllimit_nakit IS NOT NULL AND a.tllimit_nakit<>0 THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0),15,'0')
            ELSE NVL(TO_CHAR(a.tllimit_nakit),'               ') END AS nakit_limit,
            CASE WHEN a.tllimit_gayrinakit IS NOT NULL AND a.tllimit_gayrinakit<>0 THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0),15,'0')
            ELSE NVL(TO_CHAR(a.tllimit_gayrinakit),'               ') END AS gayrinakit_limit,

            CASE WHEN a.tllimit_nakit_genel IS NOT NULL AND a.tllimit_nakit_genel<>0 THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0),15,'0')
            ELSE NVL(TO_CHAR(a.tllimit_nakit_genel),'               ') END AS firma_genel_limiti,

            CASE WHEN a.grup_limit IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0),15,'0')
            ELSE NVL(TO_CHAR(a.grup_limit),'               ') END AS grup_limiti,

            CASE WHEN a.grup_risk IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0),15,'0')
            ELSE NVL(TO_CHAR(a.grup_risk),'               ') END AS grup_riski,
            LPAD(NVL(TO_CHAR(a.genel_revize_vadesi,'yyyymmdd'),'99999999'),8,' ') AS genel_revize_vadesi,
            NVL(TO_CHAR(a.son_revize_tarihi,'yyyymmdd'), 99999999) AS son_revize_tarihi,
            RPAD(' ', 407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM trfm.tmp_trbfc_vortex_mus d
            INNER JOIN trfm.tmp_trbfc_iliskili_mus c ON  1=1
                                                     AND d.musteri_no = c.musteri_no
                                                     and d.kesit_tarihi = c.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct a ON 1=1
                                          AND c.iliskili_musteri_no = a.musteri_no
                                          AND c.kesit_tarihi = a.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct b ON  1=1
                                          AND c.musteri_no = b.musteri_no
                                          AND c.kesit_tarihi = b.kesit_tarihi
            INNER JOIN prsn.kkb_trbac_fct f ON  1 = 1
                                    AND f.kst_trh = b.kesit_tarihi
                                    AND f.musteri_no = b.musteri_no
                          /*LEFT JOIN extr.fs_ilce i ON  1=1
                                     AND LPAD (a.ev_il_kodu, 3, 0) =LPAD(i.il,3,0)
                                     AND a.ev_ilce_aciklama = i.aciklama*/
            LEFT JOIN prsn.prmulkekodu u  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
                                          ON a.isyeri_ulke_kodu= SUBSTR (TRIM (u.value), LENGTH (TRIM (u.value)) - 2, 2)
                          /*left join prsn.prmfirmaturu ft
            ON DECODE (a.sirket_tip_acklm, 'ANONÝM', '04',
                                           'ADÝ', '1',
                                           'KOMANDÝT', '02',
                                           'LÝMÝTED', '06',
                                           'KOLLEKTÝF', '05',
                                           'KOOPERATÝF', '20',
                                           'BELÝRTÝLMEMÝÞ', '99',
                                           'ASKERÝ BÝRLÝK', '34',
                                           'ÞÝRKET DEÐÝL (ASKERÝ)', '98',
                                           'ÞÝRKET DEÐÝL (SÝVÝL)', '98',
                                           '99')
                                     = TO_NUMBER (TRIM (ft.id))*/
            LEFT JOIN trfm.tmp_fnsmn_konu kfk ON 1=1
                                                       AND a.finansman_konusu_kodu = kfk.finansman_konusu_kod
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf ON  1 = 1
                                                             AND a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            --AND a.gercek_tuzel = 'T';
            --AND vtf.tckn_vkn = 'VKN'
            AND vtf.trbfc_trbic_f = 'TRBFC';

   COMMIT;

   v_line_no:=2230;





   ------Teminat dosyasýnda kefil gözüken fakat musteri_iliski tablosunda kefil iliþkili gözükmediðinden tabloya yansýmayan varsa 4 firma iliþki kodlu olarak insert edilir;
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbfc_txt_krd
     SELECT a.kesit_tarihi, f.tip, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
            f.refsube, f.reftur, f.refsirano, f.aylik_ilk_bildirim_f,
            '30' veri_turu,
            '00099' uye_Kodu,
            --LPAD (f.refsube || f.reftur || f.refsirano || CASE WHEN TO_CHAR (f.tip) = 'KMH' THEN TO_CHAR (f.musteri_no) ELSE NULL END, 20, ' ') kayit_referans_numarasi, -----------------------------02/01/2017
            LPAD (CASE WHEN f.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (f.refsube) || TO_CHAR (f.reftur) || TO_CHAR (f.refsirano) WHEN f.tip IN ('KMH', 'MMZC') THEN f.refsube || f.musteri_no || f.reftur || f.refsirano ELSE NULL END, 20, '0') kayit_referans_numarasi,
            'TRBFC' Segment_Turu,
            '02' Versiyon_Numarasi,
            '10'
            ||
            '00099'
            ||
            a.kayit_referans_numarasi
            AS tuzel_kisi_ref_no,
            NVL (LPAD(a.ilkodu,3,0), '   ') AS sube_merkez_il_kodu,
            LPAD (NVL (TO_CHAR (a.ana_sube), '99999'), 5, '0') sube_eft_kodu,
            NVL (RPAD(a.isim_unvan,100,' '), '                                                                                                    ') AS unvan,

            NVL (RPAD(COALESCE( a.isyeri_adres,a.ev_adres),120,' '), '                                                                                                                        ') AS adres  ,
            NVL(LPAD(COALESCE(a.isyeri_il_kodu,a.ev_il_kodu),3,0),999) AS  adres_il_kodu,


            --NVL(LPAD(i.ilce,2,0),99) adres_ilce_kodu,
            NVL(LPAD(COALESCE(a.kkb_isyeri_il_ilce_kod,a.kkb_ev_il_ilce_kod),2,'0'),99) AS  adres_ilce_kodu,
            --NVL(LPAD(COALESCE(a.isyeri_ilce_aciklama,a.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,-------uyusmayan ilçe kodlarý var edize sorulacak.

            NVL (LPAD (u.id, 3, ' '), '   ') ulke_kodu,----ulkelerin uyusmasý için parametre tablosuna ihtiyac var

            CASE WHEN a.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(a.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(a.ticaret_sicil_no),'                                ') END  ticaret_sicil_numarasi,

            '                '        mersis_numarasi,
            '                    '    ticaret_odasý,
            '999'                     ticaret_tescil_il_kodu,
            '99'                      ticaret_tescil_merkezi_kodu,
            NVL (LPAD(a.vergi_dairesi,20,' '), '                    ') AS vergi_dairesi,
            NVL(DECODE(a.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(a.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            --NVL (LPAD (TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
            LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') firma_turu_acklm_kkb,
            '1' firma_iliski_kodu,
            '10'||'00099'|| LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') AS ilsk_ndn_olan_grc_tzl_refno,
            LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') AS ilsk_ndn_olan_grc_unvan,
            '0' AS krd_iliski_kodu,
            '00000000' AS ilsk_baslangic_tarihi,
            '00000000' AS ilsk_bitis_tarihi,
            '1' AS ilsk_gostergesi,
            '00000' AS ortaklýk_hisse_orani,
            NVL (LPAD(COALESCE(a.isyeri_posta_kod ,a.ev_posta_kod),10,' '), '          ') AS adres_posta_kod,

                          /*NVL(LPAD(COALESCE(a.isyeri_tel_ulke_kodu,a.ev_tel_ulke_kodu,a.cep_tel_ulke_kodu ),4,0),'    ') AS  tlf_ulke_kodu,   ---NVL (x,null)??????

            NVL(LPAD(COALESCE(a.isyeri_tel_alan_kodu,a.ev_tel_alan_kodu,a.cep_tel_alan_kodu) ,3,0),'   ') AS  tlf_bolge_kodu,  ---NVL (x,null)??????

            NVL(LPAD(COALESCE(a.isyeri_tel_numara,a.ev_tel_numara,a.cep_tel_numara) ,9,0),'         ') AS  tlf_numarasi,  ---NVL (x,null)??????

            NVL(LPAD(COALESCE(a.isyeri_tel_formatlý_tel_no,a.ev_tel_formatlý_tel_no,a.cep_tel_formatlý_tel_no) ,16,0),'                ') AS  formatli_telefon_numarasi,  ---NVL (x,null)??????*/

            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,
            NVL (LPAD (a.web_adresi, 50, ' '), '                                                  ') AS web_adresi,
            NVL (LPAD(a.mail,50,' '), '                                                  ') AS e_posta,
            NVL (TO_CHAR (a.uye_clsm_trh, 'yyyymmdd'), 99999999) uye_calisma_baslama_tarih ,
            LPAD(NVL( a.donem_calisan_sayisi ,0),10,' ') AS calisan_sayisi,
            RPAD(NVL(kfk.finansman_konusu_kod,'999') ,3,' ') AS finansman_konusu_kodu,
            NVL (LPAD(a.firma_grup_kodu,10,' '), '          ') AS firma_grup_kodu,
            LPAD(NVL(a.ciro_para_kodu,999),3,0) AS ciro_doviz_kodu,
            CASE WHEN a.ciro_tutari<0 THEN '               '
                 ELSE NVL(LPAD(ROUND(TO_CHAR(a.ciro_tutari),0),15,'0'),'               ')
            END AS ciro_tutari,
            LPAD(NVL(a.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(a.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(a.min_actarih_grup3,'yyyymmdd'), '00000000') AS grup3_alinma_tarihi,---incelenebilir
            NVL(TO_CHAR(a.min_actarih_grup4,'yyyymmdd'), '00000000') AS grup4_alinma_tarihi,
            NVL(TO_CHAR(a.min_actarih_grup5,'yyyymmdd'), '00000000') AS grup5_alinma_tarihi,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit)),0),15,'0'),'               ') END AS nakit_limit,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_gayrinakit)),0),15,'0'),'               ') END AS gayrinakit_limit,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.tllimit_nakit_genel)),0),15,'0'),'               ') END AS firma_genel_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_limit)),0),15,'0'),'               ') END AS grup_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(a.grup_risk)),0),15,'0'),'               ') END AS grup_riski,
            LPAD(NVL(TO_CHAR(a.genel_revize_vadesi,'yyyymmdd'),'99999999'),8,' ') AS genel_revize_vadesi,
            NVL(TO_CHAR(a.son_revize_tarihi,'yyyymmdd'), 99999999) AS son_revize_tarihi,
            LPAD(' ',407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
      FROM  trfm.tmp_trbfc_vortex_mus d
            INNER JOIN (
                          SELECT k.kst_trh, k.ana_musteri_no, k.kefil_musteri_no
                            FROM trfm.tmp_trbgr_mus_iliski k
                           WHERE 1 = 1
                             AND k.kst_trh = v_tarih
                             AND (k.ana_musteri_no, k.kefil_musteri_no) NOT IN (
                                                                                  SELECT fc.musteri_no, fc.iliskili_musteri_no
                                                                                    FROM trfm.tmp_trbfc_iliskili_mus fc
                                                                                   WHERE 1 = 1
                                                                                     AND fc.kesit_tarihi = v_tarih
                                                                                     AND fc.iliski_kkb_kod = '4'
                                                                               )
                       ) c
                                                        ON d.musteri_no = c.ana_musteri_no
                                                        and d.kesit_tarihi = c.kst_trh
            INNER JOIN prsn.kkb_trbfc_trbic_fct a ON  1=1
                                          AND c.kefil_musteri_no = a.musteri_no
                                          AND c.kst_trh = a.kesit_tarihi
            INNER JOIN prsn.kkb_trbfc_trbic_fct b ON  1=1
                                          AND c.ana_musteri_no = b.musteri_no
                                          AND c.kst_trh = b.kesit_tarihi
            INNER JOIN prsn.kkb_trbac_fct f -----------------------------02/01/2017
                                     ON     1 = 1 -----------------------------02/01/2017
                                        AND f.kst_trh = b.kesit_tarihi -----------------------------02/01/2017
                                        AND f.musteri_no = b.musteri_no -----------------------------02/01/2017
                          /*LEFT JOIN extr.fs_ilce i ON 1=1
                                        AND LPAD (a.ev_il_kodu, 3, 0) =LPAD(i.il,3,0)
                                        AND a.ev_ilce_aciklama = i.aciklama*/
            LEFT JOIN prsn.prmulkekodu u  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
                                          ON a.isyeri_ulke_kodu= SUBSTR (TRIM (u."VALUE"), LENGTH (TRIM (u."VALUE")) - 2, 2)
            LEFT JOIN trfm.tmp_fnsmn_konu kfk ON  1=1
                                                       AND a.finansman_konusu_kodu = kfk.finansman_konusu_kod
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf ON  1=1
                                                             AND a.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            --AND a.gercek_tuzel = 'T';
            --AND vtf.tckn_vkn = 'VKN'
            AND vtf.trbfc_trbic_f = 'TRBFC';

   COMMIT;
   v_line_no:=2240;



   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbfc_txt_krd;


   PROCEDURE sp_trbac_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBAC_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2300;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbac_txt_krd WHERE 1=1 AND kst_trh = v_tarih;
      COMMIT;

      v_line_no:=2310;

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbac_txt_krd
      SELECT a.kst_trh, a.tip, a.musteri_no, a.tck_no, a.vergi_no, a.musteri_tip, a.gercek_tuzel,
             vtf.tckn_vkn AS kontrol_tckn_vkn_f,
             a.thp_no, a.refsube, a.reftur, a.refnitelik, a.refsirano, a.kmh_mt_ekno, a.doviz_kodu, a.kotasyon_no, a.aylik_ilk_bildirim_f,
             '30' AS veri_turu,
             '00099' AS uye_kodu,
             LPAD (
                   (
                    CASE WHEN a.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (a.refsube) || TO_CHAR (a.reftur) || TO_CHAR (a.refsirano)
                         WHEN a.TIP IN ('KMH', 'MMZC') THEN a.refsube || a.musteri_no || a.reftur || a.refsirano ELSE NULL END
                   ),
                      20,
                      '0'
                  ) AS kayit_referans_no,
             'TRBAC' AS Segment_Turu,
             '02' AS Versiyon_Numarasi,
                '30'
             || '00099'
             || LPAD (
                      (
                       CASE WHEN a.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (a.refsube) || TO_CHAR (a.reftur) || TO_CHAR (a.refsirano)
                            WHEN a.TIP IN ('KMH', 'MMZC') THEN a.refsube || a.musteri_no || a.reftur || a.refsirano ELSE NULL END
                      ),
                         20,
                         '0'
                     ) AS kredi_hesap_ref_no,
                --CASE WHEN TO_CHAR (a.vergi_no) IS NOT NULL THEN '10' WHEN TO_CHAR (a.tck_no) IS NOT NULL THEN '20' ELSE '  ' END
                '10'
             || '00099'
             || '00'
             || LPAD (CASE WHEN TO_CHAR (a.tck_no) IS NOT NULL THEN '6' WHEN TO_CHAR (a.vergi_no) IS NOT NULL THEN '5' ELSE ' ' END
             || '000000'
             || NVL (TO_CHAR (a.tck_no), '0' || TO_CHAR (a.vergi_no)), 18, 0)
                AS tuzel_gercek_ref_no,
             LPAD (NVL (TO_CHAR (a.sube_merkez_ilkodu), '000'), 3, 0) AS sube_merkez_ilkodu,
             LPAD (NVL (TO_CHAR (a.sube_eft_kodu), '     '), 5, 0) AS sube_eft_kodu,
             CASE WHEN a.thp_no IS NULL THEN '000' WHEN a.thp_no IS NOT NULL THEN SUBSTR (LPAD (TO_CHAR (a.thp_no), 7, '0'), 1, 3) END AS defteri_kebir_hsp_no,
             LPAD (NVL (a.kredi_turu_kod, '000'), 3, '0') AS kredi_turu_kod,
             a.doviz_kodu AS doviz_kodu_ing,
             NVL (LPAD (t1.id1, 3, '0'), '   ') AS doviz_kodu_kkb,
             a.kullandirim_doviz_kodu AS kullandirim_doviz_kodu_ing,
             NVL (LPAD (t2.id1, 3, '0'), '   ') AS kullandirim_doviz_kodu_kkb,
             NVL (TO_CHAR (a.ilk_kullandirim_tarihi, 'yyyymmdd'), '00000000') AS ilk_kullandirim_tarihi,
             NVL (TO_CHAR (a.son_kullandirma_tarihi, 'yyyymmdd'), '00000000') AS son_kullandirim_tarihi,
             LPAD(NVL(TO_CHAR(ROUND(a.acilis_ilk_kullandirim_tutari,0)),'               '),15,0) AS acilis_ilk_kullandirim_tutari,
             NVL (TO_CHAR (a.vade_tarihi, 'yyyymmdd'), '00000000') vade_tarihi,
             CASE WHEN a.tip = 'ITH' THEN LPAD (NVL (TO_CHAR (u.id), '999'), 3, '0') ELSE '000' END AS muhatap_ulke_kodu,
             LPAD (NVL (TO_CHAR (a.muhatap), ' '), 100, ' ') AS muhatap,
             '0000000000' AS muhatap_vkn,
             '00000000000' AS muhatap_tckn,
             CASE WHEN a.hsp_kapanis_trh IS NULL THEN '00000000' ELSE TO_CHAR (a.hsp_kapanis_trh, 'yyyymmdd') END hesap_kapanis_tarihi, --Not-1: Kredi hesabý açýk ise (Hesabýn Özel Durum Kodu=1) bu alana 0 (8 adet sýfýr) kodlanmalýdýr.
             CASE WHEN a.grup3_alinma_tutari IS NULL THEN '000000000000000'
                  WHEN LAST_DAY (a.grup3_alinma_trh) = a.kst_trh AND a.grup3_alinma_tutari <> 0 THEN LPAD (TO_CHAR (ROUND (TO_NUMBER (a.grup3_alinma_tutari), 0)), 15, '0')
                  WHEN LAST_DAY (a.grup3_alinma_trh) = a.kst_trh AND a.grup3_alinma_tutari IS NULL THEN LPAD (a.grup3_alinma_tutari, 15, ' ')
                       ELSE '000000000000000'
                            END grup3_alinma_tutari, --Eðer kredi hesabý 3.gruba alýnmamýþ ise 0, 3.gruba alýnmýþ olmasýna raðmen, bu gruba alýnma tutarý bilinmiyor ise bu alana boþluk kodlanmalýdýr.
             CASE WHEN a.grup4_alinma_tutari IS NULL THEN '000000000000000'
                  WHEN LAST_DAY (a.grup4_alinma_trh) = a.kst_trh AND a.grup4_alinma_tutari <> 0 THEN LPAD (TO_CHAR (ROUND (TO_NUMBER (a.grup4_alinma_tutari), 0)), 15, '0')
                  WHEN LAST_DAY (a.grup4_alinma_trh) = a.kst_trh AND a.grup4_alinma_tutari IS NULL THEN LPAD (a.grup4_alinma_tutari, 15, ' ')
                       ELSE '000000000000000'
                            END grup4_alinma_tutari, --Eðer kredi hesabý 4.gruba alýnmamýþ ise 0, 4.gruba alýnmýþ olmasýna raðmen, bu gruba alýnma tutarý bilinmiyor ise bu alana boþluk kodlanmalýdýr.
             CASE WHEN a.grup5_alinma_tutari IS NULL THEN '000000000000000'
                  WHEN LAST_DAY (a.grup5_alinma_trh) = a.kst_trh AND a.grup5_alinma_tutari <> 0 THEN LPAD (TO_CHAR (ROUND (TO_NUMBER (a.grup5_alinma_tutari), 0)), 15, '0')
                  WHEN LAST_DAY (a.grup5_alinma_trh) = a.kst_trh AND a.grup5_alinma_tutari IS NULL THEN LPAD (a.grup5_alinma_tutari, 15, ' ')
                       ELSE '000000000000000'
                            END grup5_alinma_tutari, --Eðer kredi hesabý 5.gruba alýnmamýþ ise 0, 5.gruba alýnmýþ olmasýna raðmen, bu gruba alýnma tutarý bilinmiyor ise bu alana boþluk kodlanmalýdýr.
             CASE WHEN TO_CHAR (a.donem_sonu_gecikme) IS NULL THEN '0000' ELSE LPAD (TO_CHAR (a.donem_sonu_gecikme), 4, '0') END donem_sonu_gecikme,
             CASE WHEN TO_CHAR (a.donemici_enbuyuk_gecikme) IS NULL THEN '0000' ELSE LPAD (TO_CHAR (a.donemici_enbuyuk_gecikme), 4, '0') END AS donemici_enbuyuk_gecikme,
             LPAD (NVL (a.hesabin_ozel_durum_kodu, '00'), 2, '0') hesabin_ozel_durum_kodu,
             CASE WHEN LAST_DAY (a.devir_trh) = a.kst_trh THEN (CASE WHEN a.devir_oncesi_ref IS NOT NULL THEN '30'||'00099'||LPAD (a.devir_oncesi_ref, 20, '0') ELSE RPAD(' ', 27,' ') END ) ELSE RPAD(' ', 27,' ') END AS kredi_eski_hsp_no,
             CASE WHEN a.hsp_kapanis_trh IS NOT NULL THEN '000000000000000' WHEN TO_CHAR(a.tutar1) IS NULL THEN '000000000000000' ELSE LPAD (ROUND (TO_NUMBER (a.tutar1), 0), 15, 0) END AS tutar1,
             CASE WHEN a.hsp_kapanis_trh IS NOT NULL THEN '000000000000000' WHEN TO_CHAR(a.tutar2) IS NULL THEN '000000000000000' ELSE LPAD (ROUND (TO_NUMBER (a.tutar2), 0), 15, 0) END AS tutar2,
             CASE WHEN a.hsp_kapanis_trh IS NOT NULL THEN '000000000000000' WHEN TO_CHAR(a.tutar3) IS NULL THEN '000000000000000' ELSE LPAD (TRUNC (TO_NUMBER (a.tutar3), 0), 15, 0) END AS tutar3,
             CASE WHEN a.hsp_kapanis_trh IS NOT NULL THEN '000000000000000' WHEN TO_CHAR(a.tutar4) IS NULL THEN '000000000000000' ELSE LPAD (TRUNC (TO_NUMBER (a.tutar4), 0), 15, 0) END AS tutar4,
             CASE WHEN a.hsp_kapanis_trh IS NOT NULL THEN '000000000000000' WHEN TO_CHAR(a.tutar5) IS NULL THEN '000000000000000' ELSE LPAD (TRUNC (TO_NUMBER (a.tutar5), 0), 15, 0) END AS tutar5,
             CASE WHEN a.hsp_kapanis_trh IS NOT NULL THEN '000000000000000' WHEN TO_CHAR(a.tutar6) IS NULL THEN '000000000000000' ELSE LPAD (ROUND (TO_NUMBER (a.tutar6), 0), 15, 0) END AS tutar6,
             ' ' AS odeme_plani_durum_kodu,
             RPAD(' ',848,' ') AS rezerv_alan,
             SYSDATE AS etl_trh,
             v_sp_name AS etl_job
        FROM prsn.kkb_trbac_fct a
             LEFT OUTER JOIN extr.fs_para p1
                             ON     1 = 1
                                AND a.doviz_kodu = p1.para
             LEFT OUTER JOIN prsn.prmdovizkodlari t1
                             ON     1 = 1
                                AND DECODE (p1.swift_kisaad, 'TRY', 'TRL', p1.swift_kisaad) = t1.id2
             LEFT OUTER JOIN extr.fs_para p2
                             ON     1 = 1
                                AND a.kullandirim_doviz_kodu = p2.para
             LEFT OUTER JOIN prsn.prmdovizkodlari t2
                             ON     1 = 1
                                AND DECODE (p2.swift_kisaad, 'TRY', 'TRL', p2.swift_kisaad) = t2.id2
             LEFT OUTER JOIN prsn.prmulkekodu u
                             ON     1 = 1
                                AND TO_CHAR (a.muhatap_ulke_kodu) = SUBSTR (TRIM (u.value), LENGTH (TRIM (u.value)) - 2, 2)
             LEFT OUTER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                             ON     1 = 1
                               AND a.musteri_tip = vtf.musteri_tip
       WHERE 1 = 1
             AND a.kst_trh = v_tarih;

       COMMIT;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbac_txt_krd;


   PROCEDURE sp_trbgr_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2400;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbgr_txt_krd WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2410;

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_txt_krd
     SELECT b.kesit_tarihi, b.teminat_cesidi, b.musteri_no, b.tck_no, b.vergi_no,
            b.musteri_tip, b.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            b.tmnt_refsube, b.tmnt_reftur, b.tmnt_refsirano,
            b.tmnt_referans, b.teminat_turu_kodu_ing, b.teminat_turu_acklm_ing, b.teminat_doviz_kodu,
            CASE WHEN b.krdreftur IS NOT NULL AND b.krdrefsirano IS NOT NULL
                      THEN DECODE (
                                   b.krdreftur,
                                                'AC',     'ITH',
                                                'AL',     'ITH',
                                                'DE',     'NKRD',
                                                'DK',     'NKRD',
                                                'HG',     'TMEK',
                                                'KT',     'KMH',
                                                'LC',     'ITH',
                                                'TD',     'TKRD',
                                                'TK',     'NKRD',
                                                'TM',     'TMEK',
                                                'TT',     'TKRD',
                                                'TY',     'TMEK'
                                  )
                 WHEN b.krdreftur IS NULL AND b.krdrefsirano IS NOT NULL
                      THEN 'GVNC'
                           ELSE NULL
                                END tip,
            b.krdsube, b.krdreftur, b.krdrefnit, b.krdrefsirano,
            CASE WHEN b.krdreftur <> 'KT' THEN (b.krdsube || b.krdreftur || b.krdrefsirano)
                      ELSE b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano
                           END krd_referans,
            'Kredi ile baðlantili' AS krd_birebir_iliskili_tmnt_f,
            '30' AS veri_turu_kredi,
            '32' AS veri_turu_teminat,
            '00099' AS uye_kodu,
            LPAD (NVL (
                       CASE WHEN b.krdreftur <> 'KT' THEN b.krdsube || b.krdreftur || b.krdrefsirano
                                 ELSE b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano
                                      END
                                         , '00000000000000000000'), 20, '0') kayit_referans_numarasi_krd,
            b.kayit_referans_numarasi_tmnt,
            'TRBGR' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            LPAD (NVL (TO_CHAR (b.sube_ilkodu), '   '), 3, 0) AS sube_merkez_ilkodu,
            LPAD(NVL(b.sube_eft_kodu,99999),5,0) AS sube_eft_kodu,
            --LPAD (NVL (b.tmnt_referans, '000000000000000000000000000'), 27, '0') teminat_referans_numarasi,
            '32' || '00099' || LPAD (NVL (b.tmnt_referans, '00000000000000000000'), 20, '0') AS teminat_referans_numarasi,
            '30' || '00099' ||
            LPAD (NVL (
                       CASE WHEN b.krdreftur <> 'KT' THEN b.krdsube || b.krdreftur || b.krdrefsirano
                                 ELSE b.krdsube || b.musteri_no || b.krdreftur || b.krdrefsirano
                                      END
                                         , '00000000000000000000'), 20, '0') AS kredi_hesabi_referans_numarasi,
            --CASE WHEN b.vergi_no IS NOT NULL THEN '10' WHEN b.tck_no IS NOT NULL THEN '20' END
            '10' || '00099' || '00' ||
            CASE WHEN b.tck_no IS NOT NULL THEN '6'
                 WHEN b.vergi_no IS NOT NULL THEN '5'
                 WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN
                 (
                 CASE WHEN b.gercek_tuzel='G' THEN '6'
                  ELSE '5'
                  END
                 )
                      END
            || '000000'
            ||
            CASE WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN '00000000000'
              WHEN b.tck_no IS NOT NULL THEN b.tck_no
              WHEN b.vergi_no IS NOT NULL THEN  '0'||b.vergi_no END tuzel_gercek_ref_no_kredi,
             '10'
            || '00099' || '00' ||
            CASE WHEN b.tck_no IS NOT NULL THEN '6'
                 WHEN b.vergi_no IS NOT NULL THEN '5'
                 WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN
                 (
                 CASE WHEN b.gercek_tuzel='G' THEN '6'
                  ELSE '5'
                  END
                 )
              END
            || '000000'
            ||
            CASE WHEN b.tck_no IS NULL AND b.vergi_no IS NULL THEN '00000000000'
              WHEN b.tck_no IS NOT NULL THEN b.tck_no
              WHEN b.vergi_no IS NOT NULL THEN  '0'||b.vergi_no
             END tuzel_gercek_ref_no_teminat,

            --LPAD(NVL(c.id,99),2,0) teminat_turu_kodu,
            LPAD (
                  CASE WHEN b.teminat_turu_kodu_ing = 47 THEN '28'
                       WHEN b.teminat_turu_kodu_ing = 56 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 59 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 12 THEN '27'
                       WHEN b.teminat_turu_kodu_ing = 57 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 22 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 47 THEN '28'
                       WHEN b.teminat_turu_kodu_ing = 51 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 52 THEN '44'
                       WHEN b.teminat_turu_kodu_ing = 56 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 57 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 59 THEN '31'
                       WHEN b.teminat_turu_kodu_ing = 10 THEN '29'
                       WHEN b.teminat_turu_kodu_ing = 11 THEN '29'
                       WHEN b.teminat_turu_kodu_ing = 32 THEN '11'
                       WHEN b.teminat_turu_kodu_ing = 51 THEN '50'
                       WHEN b.teminat_turu_kodu_ing = 52 THEN '44'
                       WHEN c.id IS NOT NULL THEN c.id
                            END,
                  2,
                  '0'
                 ) teminat_turu_kodu,

            LPAD(ROUND(b.teminat_degeri,0),15,0) teminat_degeri,

            CASE WHEN b.tmnt_alindigi_trh IS NOT NULL
                 THEN  SUBSTR(b.tmnt_alindigi_trh,7,4)||SUBSTR(b.tmnt_alindigi_trh,4,2)||SUBSTR(b.tmnt_alindigi_trh,1,2)
                 ELSE '99999999'
            END AS tmnt_alindigi_trh,
            NVL(TO_CHAR(b.son_degerleme_trh,'yyyymmdd') ,99999999 )son_degerleme_trh,
            LPAD(NVL(t.id1 ,999),3,0) doviz_kodu,
            CASE WHEN b.piyasa_ekspertiz_degeri IS NOT NULL
                 THEN LPAD(ROUND(b.piyasa_ekspertiz_degeri,0),15,0)
                 ELSE '000000000000000'
            END AS piyasa_ekspertiz_degeri,
            1 AS teminat_aktif_pasif_kodu,
            CASE WHEN b.cek_senet_adedi IS NOT NULL THEN LPAD(b.cek_senet_adedi,6,0)
                 ELSE '000000' END cek_senet_adedi,
            CASE WHEN c.id <> 45 OR b.kefil_adet IS NULL THEN '00' ELSE LPAD (b.kefil_adet, 2, '0') END kefil_adet,
            CASE WHEN b.kefalet_miktari IS NOT NULL THEN LPAD(ROUND(b.kefalet_miktari,0),15,0) ELSE NULL END kefalet_miktari,
            RPAD(' ', 967,' ') rezerv_alan_1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbgr_fct b
            INNER JOIN      prsn.kkb_trbac_fct af
                            ON     1 = 1
                               AND b.krdsube = af.refsube
                               AND b.krdreftur = af.reftur
                               AND b.krdrefsirano = af.refsirano
            LEFT OUTER JOIN prsn.prmteminatturu c
                            ON     1 = 1
                               AND b.teminat_turu_kodu_ing = c.lookupvalue
            LEFT OUTER JOIN extr.fs_para p
                            ON     1 = 1
                               AND b.teminat_doviz_kodu = p.para
            LEFT OUTER JOIN prsn.prmdovizkodlari t
                            ON     1 = 1
                               AND DECODE (p.swift_kisaad, 'TRY', 'TRL', p.swift_kisaad) = t.id2
            LEFT OUTER JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                            ON     1 = 1
                               AND b.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
        AND b.kesit_tarihi = v_tarih
        AND b.krdsube || b.krdreftur || b.krdrefnit || b.krdrefsirano IS NOT NULL
        AND b.krdrefsirano > 0;

      COMMIT;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_txt_krd;


   PROCEDURE sp_trbic_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBIC_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2500;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbic_txt_krd WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2510;

   ---Ýliskili Musteriler---
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbic_txt_krd
   SELECT a.kesit_tarihi, f.tip, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn AS kontrol_tckn_vkn_f,
          b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
          f.refsube, f.reftur, f.refsirano, f.aylik_ilk_bildirim_f,
         '30' AS veri_turu,
         '00099' AS uye_kodu,
         --LPAD (f.refsube || f.reftur || f.refsirano || CASE WHEN TO_CHAR (f.tip) = 'KMH' THEN TO_CHAR (f.musteri_no) ELSE NULL END, 20, ' ') kayit_referans_numarasi,
         LPAD (CASE WHEN f.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (f.refsube) || TO_CHAR (f.reftur) || TO_CHAR (f.refsirano) WHEN f.tip IN ('KMH', 'MMZC') THEN f.refsube || f.musteri_no || f.reftur || f.refsirano ELSE NULL END, 20, '0') kayit_referans_numarasi,
         'TRBIC' AS Segment_Turu,
         '02' AS Versiyon_Numarasi,
         '20'
         ||'00099'
         ||'00'||
         CASE WHEN a.tck_no IS NOT NULL THEN '6' ELSE '0' END
         ||
         '000000'
         ||
         COALESCE(a.tck_no,'00000000000')  gercek_kisi_ref_no,
         LPAD(NVL(a.ana_sube,99999),5,0) sube_eft_kodu,
         LPAD(NVL(a.ilkodu,999),3,0) sube_merkez_il_kodu,
         LPAD(NVL (TRIM(c.iliski_kkb_kod), '99'),2,'0') AS firma_iliski_kodu,
         NVL (LPAD(a.isim,15,' '), '               ') AS isim,
         NVL (LPAD(a.ikinci_isim,15,' '), '               ') AS ikinci_isim,
         NVL (LPAD(a.soyad,30,' '), '                              ') AS soyad,
         NVL(TO_CHAR (a.dogum_tarihi, 'YYYYMMDD'),'99999999') AS dogum_tarihi,

         COALESCE(d1.kimlik_turu_kodu,9) AS kimlik_kod_1,
         LPAD(COALESCE(a.kimlik_kod_1_seri_no,'                    '),20,' ') kimlik_no_1,
         COALESCE(d2.kimlik_turu_kodu,9) AS kimlik_kod_2,
         LPAD(COALESCE(a.kimlik_kod_2_seri_no,'                    '),20,' ') kimlik_no_2,
         COALESCE(d3.kimlik_turu_kodu,9) AS kimlik_kod_3,
         LPAD(COALESCE(a.kimlik_kod_3_seri_no,'                    '),20,' ') kimlik_no_3,
         COALESCE(d4.kimlik_turu_kodu,9) AS kimlik_kod_4,
         LPAD(COALESCE(a.kimlik_kod_4_seri_no,'                    '),20,' ') kimlik_no_4,

         LPAD(COALESCE(a.isyeri_adres,'                                                                                                                        '),120,' ') AS is_adresi,
         LPAD(COALESCE(TO_CHAR (a.isyeri_il_kodu),'999'),3,'0') AS is_adresi_il_kodu,

         --LPAD (COALESCE(bi.ilce_kodu,'99'), 2, 0) AS is_adresi_ilce_kodu
         --NVL(LPAD(bi.ilce,2,0),99) is_adresi_ilce_kodu,
         LPAD(COALESCE(TO_CHAR (a.kkb_isyeri_il_ilce_kod),'99'),2,'0') AS is_adresi_ilce_kodu,

         NVL (LPAD(COALESCE(a.ev_adres,''),120,' '), '                                                                                                                        ') AS ev_adresi,

         LPAD(COALESCE(TO_CHAR (a.ev_il_kodu),'999'),3,0) AS ev_adresi_il_kodu,

         --NVL(LPAD(bi.ilce,2,0),99)  ev_adresi_ilce_kodu,
         LPAD(COALESCE(TO_CHAR (a.kkb_ev_il_ilce_kod),'99'),2,'0') AS ev_adresi_ilce_kodu,

         LPAD(COALESCE(TO_CHAR (a.uyruk_kodu),'999'),3,0) AS uyruk,
         '10'
         ||
         '00099'
         ||
         LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') ilsk_ndn_olan_grc_tzl_refno,
         LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') ilsk_ndn_olan_grc_unvan,
         '0' AS kredi_iliski_kodu,
         DECODE (NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bastarih, 'YYYYMMDD'), '99999999')) ilsk_baslangic_tarihi,
         DECODE (NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999'), '19000101', '99999999', NVL (TO_CHAR (c.gecici_bittarih, 'YYYYMMDD'), '99999999')) ilsk_bitis_tarihi,
         CASE WHEN c.gecici_bastarih IS NULL OR c.gecici_bittarih IS NULL THEN '0' ELSE (CASE WHEN a.kesit_tarihi BETWEEN c.gecici_bastarih  and c.gecici_bittarih THEN '1' ELSE '0' END) END ilsk_gostergesi,
         LPAD (NVL (ROUND (c.istirak_oran * 100, 0), '00000'), 5, '0') ortaklýk_hisse_orani,
         NVL (LPAD (b.isim_unvan, 30, ' '), '                              ') unvan,
         '9' imza_yetkisi_kodu,
         LPAD(COALESCE(a.ev_posta_kod,'          '),10,' ') AS ev_adresi_posta_kodu,
         LPAD(COALESCE(a.isyeri_posta_kod,'          '),10,' ') AS is_adresi_posta_kodu,

                       /*LPAD(COALESCE(TO_CHAR (a.isyeri_tel_ulke_kodu),TO_CHAR (a.ev_tel_ulke_kodu),TO_CHAR (a.cep_tel_ulke_kodu),'    '),4,' ')as  tlf_ulke_kodu,
         LPAD(COALESCE(TO_CHAR (a.isyeri_tel_alan_kodu),TO_CHAR (a.ev_tel_alan_kodu),TO_CHAR (a.cep_tel_alan_kodu),'   ') ,3,' ') AS  tlf_bolge_kodu,
         LPAD(COALESCE(TO_CHAR (a.isyeri_tel_numara),TO_CHAR (a.ev_tel_numara),TO_CHAR (a.cep_tel_numara),'         ') ,9,' ') AS  tlf_numarasi,
         LPAD(COALESCE(TO_CHAR (a.isyeri_tel_formatlý_tel_no),TO_CHAR (a.ev_tel_formatlý_tel_no),TO_CHAR (a.cep_tel_formatlý_tel_no),'                ') ,16,' ') AS  formatli_telefon_numarasi,*/

         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') tlf_ulke_kodu,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') tlf_bolge_kodu,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') tlf_numarasi,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') formatli_telefon_numarasi_1,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') formatli_telefon_numarasi_2,
         LPAD(COALESCE(a.ev_tel_formatlý_tel_no,'                ') ,16,' ') AS ev_tel_formatlý_tel_no,
         LPAD(COALESCE(a.cep_tel_formatlý_tel_no,'                ') ,16,' ') AS cep_tel_formatlý_tel_no,
         LPAD(COALESCE(a.mail,'                                                  '),50,' ') AS e_posta,
         --LPAD(NVL(d.lookupvalue,99),2,' ') AS meslek_kodu,----lookup value deðelreri guncel deðil edizlerin guncellemesi gerekiyor.
         --LPAD(NVL(d.value,null),30,' ')     AS meslek
         LPAD (COALESCE (a.meslek_kkb_kod, '99'), 2, ' ') AS meslek_kodu,
         LPAD (COALESCE (a.meslek_kkb_kod_acklm, '                              '), '30', ' ') AS meslek,
         LPAD (COALESCE (a.egitim_kkb_kod, '99'), 2, ' ') AS egitim_durumu_kodu,
         LPAD (COALESCE (a.egitim_kkb_kod_acklm, '                              '), '30', ' ') AS egitim_durumu,
         RPAD(' ', 461,' ')  AS rezerv_alan1,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
   FROM  trfm.tmp_trbfc_vortex_mus d
         INNER JOIN trfm.tmp_trbfc_iliskili_mus c
                                                     ON d.musteri_no=c.musteri_no
                                                     and d.kesit_tarihi =c.kesit_tarihi
         INNER JOIN prsn.kkb_trbfc_trbic_fct a
                                                     ON c.iliskili_musteri_no=a.musteri_no
                                                     and c.kesit_tarihi =a.kesit_tarihi
         INNER JOIN prsn.kkb_trbfc_trbic_fct b
                                                     ON c.musteri_no=b.musteri_no
                                                     and c.kesit_tarihi =b.kesit_tarihi
         INNER JOIN prsn.kkb_trbac_fct f
                            ON     1 = 1
                               AND f.kst_trh = b.kesit_tarihi
                               AND f.musteri_no = b.musteri_no
                       /*LEFT JOIN extr.fs_ilce bi
                  ON  LPAD (a.ev_il_kodu, 3, 0) =LPAD(bi.il,3,0)
                  and a.ev_ilce_aciklama = bi.aciklama */
                                /*LEFT JOIN prsn.prmmeslekkodlari e
                  ON a.meslek_kod =e.id ---eslesmeyen kayýtlar var prsn deki tablo ile keremk arasýndaki meslek kodlarý uyusmuyor,
                  LEFT JOIN prsn.prmegitimdurumu f
                  ON a.egitim_kod =f.id*/---eslesmeyen kayýtlar var prsn deki tablo ile keremk arasýndaki egitim  kodlarý uyusmuyor
         LEFT JOIN trfm.tmp_kkb_kmlk_tur d1 ON
                      CASE WHEN a.kimlik_kod_1='SB' THEN 2
                           WHEN a.kimlik_kod_1='NC'  THEN 3
                           wheN a.kimlik_kod_1 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_1 IS NULL THEN 8
                      END = d1.kimlik_turu_kodu
         LEFT JOIN trfm.tmp_kkb_kmlk_tur d2 ON
                     CASE WHEN a.kimlik_kod_2='SB' THEN 2
                     WHEN a.kimlik_kod_2='NC'  THEN 3
                     WHEN a.kimlik_kod_2 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_2 IS NULL THEN 8
                     END = d2.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_kmlk_tur d3 ON
                     CASE WHEN a.kimlik_kod_3='SB' THEN 2
                     WHEN a.kimlik_kod_3='NC'  THEN 3
                     WHEN a.kimlik_kod_3 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_3 IS NULL THEN 8
                     END = d3.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_kmlk_tur d4 ON
                     CASE WHEN a.kimlik_kod_4='SB' THEN 2
                          WHEN a.kimlik_kod_4='NC' THEN 3
                          WHEN a.kimlik_kod_4 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_4 IS NULL THEN 8
                     END = d4.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                            ON     1 = 1
                               AND a.musteri_tip = vtf.musteri_tip
    WHERE 1 = 1
        --AND a.gercek_tuzel = 'G';
        --AND vtf.tckn_vkn = 'TCKN'
        AND vtf.trbfc_trbic_f = 'TRBIC';

   COMMIT;
   v_line_no:=2510;







   ------Teminat dosyasýnda kefil gözüken fakat musteri_iliski tablosunda kefil iliþkili gözükmediðinden tabloya yansýmayan varsa 4 firma iliþki kodlu olarak insert edilir;
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbic_txt_krd
   SELECT a.kesit_tarihi, f.tip, a.calisma_sekli, a.ana_sube, a.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
          b.musteri_no ana_musteri_no, a.musteri_no, a.musteri_tip, a.tck_no, a.vergi_no,
          f.refsube, f.reftur, f.refsirano, f.aylik_ilk_bildirim_f,
          '30' AS veri_turu,
          '00099' AS uye_kodu,
          --LPAD (f.refsube || f.reftur || f.refsirano || CASE WHEN TO_CHAR (f.tip) = 'KMH' THEN TO_CHAR (f.musteri_no) ELSE NULL END, 20, ' ') kayit_referans_numarasi,
          LPAD (CASE WHEN f.tip NOT IN ('KMH', 'MMZC') THEN TO_CHAR (f.refsube) || TO_CHAR (f.reftur) || TO_CHAR (f.refsirano) WHEN f.tip IN ('KMH', 'MMZC') THEN f.refsube || f.musteri_no || f.reftur || f.refsirano ELSE NULL END, 20, '0') kayit_referans_numarasi,
          'TRBIC' AS Segment_Turu,
          '02' Versiyon_Numarasi,
          '20'
          ||'00099'
          ||'00'||
          CASE WHEN a.tck_no IS NOT NULL THEN '6' ELSE '0' END
          ||
          '000000'
          ||
          COALESCE(a.tck_no,'00000000000') AS gercek_kisi_ref_no,
          LPAD(NVL(a.ana_sube,99999),5,0) AS sube_eft_kodu,
          LPAD(NVL(a.ilkodu,999),3,0) AS sube_merkez_il_kodu,
          '04' AS firma_iliski_kodu,
         NVL (LPAD(a.isim,15,' '), '               ') AS isim,
         NVL (LPAD(a.ikinci_isim,15,' '), '               ') AS ikinci_isim,
         NVL (LPAD(a.soyad,30,' '), '                              ') AS soyad,
         NVL(TO_CHAR (a.dogum_tarihi, 'YYYYMMDD'),'99999999') AS dogum_tarihi,

         COALESCE(d1.kimlik_turu_kodu,9) AS kimlik_kod_1,
         LPAD(COALESCE(a.kimlik_kod_1_seri_no,'                    '),20,' ') AS kimlik_no_1,
         COALESCE(d2.kimlik_turu_kodu,9) AS kimlik_kod_2,
         LPAD(COALESCE(a.kimlik_kod_2_seri_no,'                    '),20,' ') AS kimlik_no_2,
         COALESCE(d3.kimlik_turu_kodu,9) AS kimlik_kod_3,
         LPAD(COALESCE(a.kimlik_kod_3_seri_no,'                    '),20,' ') AS kimlik_no_3,
         COALESCE(d4.kimlik_turu_kodu,9) AS kimlik_kod_4,
         LPAD(COALESCE(a.kimlik_kod_4_seri_no,'                    '),20,' ') AS kimlik_no_4,

         LPAD(COALESCE(a.isyeri_adres,'                                                                                                                        '),120,' ') AS is_adresi,
         LPAD(COALESCE(TO_CHAR (a.isyeri_il_kodu),'999'),3,'0') AS is_adresi_il_kodu,

         --NVL(LPAD(bi.ilce,2,0),99) AS is_adresi_ilce_kodu,--kkb
         LPAD(COALESCE(TO_CHAR (a.kkb_isyeri_il_ilce_kod),'99'),2,'0') AS is_adresi_ilce_kodu,

         NVL (LPAD(COALESCE(a.ev_adres,''),120,' '), '                                                                                                                        ') AS ev_adresi,

         LPAD(COALESCE(TO_CHAR (a.ev_il_kodu),'999'),3,0) AS ev_adresi_il_kodu,

         --NVL(LPAD(bi.ilce,2,0),99) AS ev_adresi_ilce_kodu,--kkb
         LPAD(COALESCE(TO_CHAR (a.kkb_ev_il_ilce_kod),'99'),2,'0') AS ev_adresi_ilce_kodu,

         LPAD(COALESCE(TO_CHAR (a.uyruk_kodu),'999'),3,0) AS uyruk,
         '10'
         ||
         '00099'
         ||
         LPAD (NVL (b.kayit_referans_numarasi, '                    '), 20, ' ') AS ilsk_ndn_olan_grc_tzl_refno,
         LPAD(NVL(b.isim_unvan,'                                                                                                    '),100,' ') AS ilsk_ndn_olan_grc_unvan,
         '0' AS kredi_iliski_kodu,
         '99999999' AS ilsk_baslangic_tarihi,
         '99999999' AS ilsk_bitis_tarihi,
         '1' AS ilsk_gostergesi,
         '00000' AS ortaklýk_hisse_orani,
         NVL (LPAD (b.isim_unvan, 30, ' '), '                              ') AS unvan,
         '9' AS imza_yetkisi_kodu,
         LPAD(COALESCE(a.ev_posta_kod,'          '),10,' ') AS ev_adresi_posta_kodu,
         LPAD(COALESCE(a.isyeri_posta_kod,'          '),10,' ') AS is_adresi_posta_kodu,

                       /*LPAD(COALESCE(TO_CHAR (a.isyeri_tel_ulke_kodu),TO_CHAR (a.ev_tel_ulke_kodu),TO_CHAR (a.cep_tel_ulke_kodu),'    '),4,' ')as  tlf_ulke_kodu,
         LPAD(COALESCE(TO_CHAR (a.isyeri_tel_alan_kodu),TO_CHAR (a.ev_tel_alan_kodu),TO_CHAR (a.cep_tel_alan_kodu),'   ') ,3,' ') AS  tlf_bolge_kodu,
         LPAD(COALESCE(TO_CHAR (a.isyeri_tel_numara),TO_CHAR (a.ev_tel_numara),TO_CHAR (a.cep_tel_numara),'         ') ,9,' ') AS  tlf_numarasi,
         LPAD(COALESCE(TO_CHAR (a.isyeri_tel_formatlý_tel_no),TO_CHAR (a.ev_tel_formatlý_tel_no),TO_CHAR (a.cep_tel_formatlý_tel_no),'                ') ,16,' ') AS  formatli_telefon_numarasi,*/

         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_ulke), '    '), 4, ' ') tlf_ulke_kodu,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_bolge), '   '), 3, ' ') tlf_bolge_kodu,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1_tln_no), '         '), 9, ' ') tlf_numarasi,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_1), '                '), 16, ' ') formatli_telefon_numarasi_1,
         LPAD (NVL (TO_CHAR (a.formatli_tel_no_2), '                '), 16, ' ') formatli_telefon_numarasi_2,

         LPAD(COALESCE(a.ev_tel_formatlý_tel_no,'                ') ,16,' ') AS ev_tel_formatlý_tel_no,
         LPAD(COALESCE(a.cep_tel_formatlý_tel_no,'                ') ,16,' ') AS cep_tel_formatlý_tel_no,
         LPAD(COALESCE(a.mail,'                                                  '),50,' ') AS e_posta,
         --LPAD(NVL(d.lookupvalue,99),2,' ') AS meslek_kodu,----lookup value deðelreri guncel deðil edizlerin guncellemesi gerekiyor.
         --LPAD(NVL(d.value,null),30,' ')     AS meslek
         LPAD (COALESCE (a.meslek_kkb_kod, '99'), 2, ' ') AS meslek_kodu,
         LPAD (COALESCE (a.meslek_kkb_kod_acklm, '                              '), '30', ' ') AS meslek,
         LPAD (COALESCE (a.egitim_kkb_kod, '99'), 2, ' ') AS egitim_durumu_kodu,
         LPAD (COALESCE (a.egitim_kkb_kod_acklm, '                              '), '30', ' ') AS egitim_durumu,
         RPAD(' ', 461,' ') AS rezerv_alan1,
         SYSDATE AS etl_trh,
         v_sp_name AS etl_job
   FROM  trfm.tmp_trbfc_vortex_mus d
         INNER JOIN (
                       SELECT k.kst_trh, k.ana_musteri_no, k.kefil_musteri_no
                         FROM trfm.tmp_trbgr_mus_iliski k
                        WHERE 1 = 1
                          AND k.kst_trh = v_tarih
                          AND (k.ana_musteri_no, k.kefil_musteri_no) NOT IN (
                                                                               SELECT musteri_no, iliskili_musteri_no
                                                                                 FROM trfm.tmp_trbfc_iliskili_mus
                                                                                WHERE 1 = 1
                                                                                  AND kesit_tarihi = v_tarih
                                                                                  AND iliski_kkb_kod = '4'
                                                                            )
                    ) c
                                                     ON d.musteri_no=c.ana_musteri_no
                                                     and d.kesit_tarihi =c.kst_trh
         INNER JOIN prsn.kkb_trbfc_trbic_fct a
                                                     ON c.kefil_musteri_no=a.musteri_no
                                                     and c.kst_trh =a.kesit_tarihi
         INNER JOIN prsn.kkb_trbfc_trbic_fct b
                                                     ON c.ana_musteri_no=b.musteri_no
                                                     and c.kst_trh =b.kesit_tarihi
         INNER JOIN prsn.kkb_trbac_fct f
                            ON     1 = 1
                               AND f.kst_trh = b.kesit_tarihi
                               AND f.musteri_no = b.musteri_no
                       /*LEFT JOIN extr.fs_ilce bi
                  ON  LPAD (a.ev_il_kodu, 3, 0) =LPAD(bi.il,3,0)
                  and a.ev_ilce_aciklama = bi.aciklama */
                       /*LEFT JOIN prsn.prmmeslekkodlari e
         ON a.meslek_kod =e.id ---eslesmeyen kayýtlar var prsn deki tablo ile keremk arasýndaki meslek kodlarý uyusmuyor,
         LEFT JOIN prsn.prmegitimdurumu f
         ON a.egitim_kod =f.id*/---eslesmeyen kayýtlar var prsn deki tablo ile keremk arasýndaki egitim  kodlarý uyusmuyor
         LEFT JOIN trfm.tmp_kkb_kmlk_tur d1 ON
                     CASE WHEN a.kimlik_kod_1='SB' THEN 2
                     WHEN a.kimlik_kod_1='NC'  THEN 3
                     WHEN a.kimlik_kod_1 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_1 IS NULL THEN 8
                     END = d1.kimlik_turu_kodu
         LEFT JOIN trfm.tmp_kkb_kmlk_tur d2 ON
                     CASE WHEN a.kimlik_kod_2='SB' THEN 2
                     WHEN a.kimlik_kod_2='NC'  THEN 3
                     WHEN a.kimlik_kod_2 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_2 IS NULL THEN 8
                     END = d2.kimlik_turu_kodu
         LEFT JOIN trfm.tmp_kkb_kmlk_tur d3 ON
                     CASE WHEN a.kimlik_kod_3='SB' THEN 2
                     WHEN a.kimlik_kod_3='NC'  THEN 3
                     WHEN a.kimlik_kod_3 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_3 IS NULL THEN 8
                     END = d3.kimlik_turu_kodu
         LEFT JOIN trfm.tmp_kkb_kmlk_tur d4 ON
                     CASE WHEN a.kimlik_kod_4='SB' THEN 2
                     WHEN a.kimlik_kod_4='NC'  THEN 3
                     WHEN a.kimlik_kod_4 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR a.kimlik_kod_4 IS NULL THEN 8
                     END = d4.kimlik_turu_kodu
         LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                     ON  1 = 1
                     AND a.musteri_tip = vtf.musteri_tip
    WHERE 1 = 1
        --AND a.gercek_tuzel = 'G';
        --AND vtf.tckn_vkn = 'TCKN'
        AND vtf.trbfc_trbic_f = 'TRBIC';

   COMMIT;
   v_line_no:=2520;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbic_txt_krd;


   PROCEDURE sp_trbip_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBIP_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2600;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbip_txt_krd WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2610;

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbip_txt_krd
     SELECT b.kesit_tarihi, f.tip, b.musteri_no,
            CASE WHEN LENGTH (TRIM (
                                    CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                               OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                               OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                               OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                               OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                               OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                               OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                               OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                               OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                               OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                               OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                               OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                  THEN NULL
                                                       ELSE mm.vergi_no
                                                            END
                                   )) = 11 AND SUBSTR (TRIM (
                                                            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                                          THEN NULL
                                                                               ELSE mm.vergi_no
                                                                                    END
                                                            ), 1, 1) <> '0' THEN TRIM (
                                                                                      CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                                                                                 OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                                                                    THEN NULL
                                                                                                         ELSE mm.vergi_no
                                                                                                              END
                                                                                      ) END tck_no,
            CASE WHEN LENGTH (TRIM (
                                   CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                              OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                              OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                              OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                              OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                              OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                              OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                              OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                              OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                              OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                              OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                              OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                 THEN NULL
                                                      ELSE mm.vergi_no
                                                           END
                                   )) IN (9, 10) THEN TRIM (
                                                            CASE WHEN     UPPER (mm.vergi_no) LIKE '%A%' OR UPPER (mm.vergi_no) LIKE '%B%' OR UPPER (mm.vergi_no) LIKE '%C%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%D%' OR UPPER (mm.vergi_no) LIKE '%E%' OR UPPER (mm.vergi_no) LIKE '%F%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%G%' OR UPPER (mm.vergi_no) LIKE '%H%' OR UPPER (mm.vergi_no) LIKE '%I%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%J%' OR UPPER (mm.vergi_no) LIKE '%K%' OR UPPER (mm.vergi_no) LIKE '%L%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%M%' OR UPPER (mm.vergi_no) LIKE '%N%' OR UPPER (mm.vergi_no) LIKE '%O%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%P%' OR UPPER (mm.vergi_no) LIKE '%R%' OR UPPER (mm.vergi_no) LIKE '%S%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%T%' OR UPPER (mm.vergi_no) LIKE '%U%' OR UPPER (mm.vergi_no) LIKE '%V%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Y%' OR UPPER (mm.vergi_no) LIKE '%Z%' OR UPPER (mm.vergi_no) LIKE '%Ç%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ö%' OR UPPER (mm.vergi_no) LIKE '%Ð%' OR UPPER (mm.vergi_no) LIKE '%Þ%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%Ü%' OR UPPER (mm.vergi_no) LIKE '%Ý%' OR UPPER (mm.vergi_no) LIKE '%X%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%W%' OR UPPER (mm.vergi_no) LIKE '%Q%' OR UPPER (mm.vergi_no) LIKE '%,%'
                                                                       OR UPPER (mm.vergi_no) LIKE '%-%' OR UPPER (mm.vergi_no) LIKE '% %' OR UPPER (mm.vergi_no) LIKE '%/%'
                                                                          THEN NULL
                                                                               ELSE mm.vergi_no
                                                                                    END
                                                           ) END vergi_no,
            b.musteri_tip, b.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            b.refsube, b.reftur, b.refsirano, f.aylik_ilk_bildirim_f,
            '30'||'00099'|| LPAD (b.kredi_hesabi_ref_no, 20, '0') AS veri_etiketi,
            'TRBIP' AS Segment_Turu,
            '02' AS Versiyon_Numarasi,
            --LPAD (b.kredi_hesabi_ref_no, 27, '0')
            '30'
             || '00099'
             || LPAD (
                (CASE WHEN f.tip NOT IN ('KMH', 'MMZC')  THEN  TO_CHAR(f.refsube)
                 || TO_CHAR(f.reftur)
                 || TO_CHAR(f.refsirano)
                 WHEN f.TIP IN ('KMH', 'MMZC') THEN f.REFSUBE||f.MUSTERI_NO||f.REFTUR||f.refsirano ELSE NULL  END),
                20,
                '0') AS kredi_hesabi_ref_no,
            '                           ' AS rezerv_alan_1,
            LPAD (TO_CHAR (b.odeme_vadesi, 'YYYYMMDD'), 8, '0') AS odeme_vadesi,
            CASE WHEN b.odemenin_yapildigi_tarih = '31/12/1899' THEN '00000000' ELSE LPAD (TO_CHAR (b.odemenin_yapildigi_tarih, 'YYYYMMDD'), 8, '0') END AS odemenin_yapildigi_tarih,
            LPAD(ROUND(b.odenmesi_gereken_tutar,0), 15,'0') AS odenmesi_gereken_tutar,
            RPAD(' ', 1181,' ') AS rezerv_alan_2,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
       FROM prsn.kkb_trbip_fct b
            INNER JOIN prsn.kkb_trbac_fct f ON  1 = 1
                                    AND b.kesit_tarihi = f.kst_trh
                                    AND b.musteri_no = f.musteri_no
                                    AND b.refsube = f.refsube
                                    AND b.reftur = f.reftur
                                    AND b.refsirano = f.refsirano
            LEFT JOIN ofsdata.musteri_master_cs_hist mm ON  1 = 1
                                                        AND b.kesit_tarihi = mm.tarih
                                                        AND b.musteri_no = mm.musteri_no
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf ON  1 = 1
                                                             AND b.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            AND b.kesit_tarihi = v_tarih;

      COMMIT;
      v_line_no:=2615;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbip_txt_krd;


   PROCEDURE sp_trbgr_sonrs_trbfc_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_SONRS_TRBFC_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2700;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbgr_sonrs_trbfc_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2710;
      INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_sonrs_trbfc_txt
     SELECT kfl_fct.kesit_tarihi,
            gf.tmnt_refsube, gf.tmnt_reftur, gf.tmnt_refsirano,
            (gf.tmnt_refsube || gf.tmnt_reftur || gf.temtur || '-' || gf.tmnt_refsirano) AS tmnt_referans,
            kfl_fct.calisma_sekli, kfl_fct.ana_sube, kfl_fct.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            a.musteri_no ana_musteri_no, kfl_fct.musteri_no, kfl_fct.musteri_tip, kfl_fct.tck_no, kfl_fct.vergi_no,
            '10' AS veri_turu,
            '00099' AS uye_Kodu,
            a.kayit_referans_numarasi, --bu kýsým bu query'de firma künye için yazýldý
            'TRBFC' Segment_Turu,
            '02' Versiyon_Numarasi,
            ('10' || '00099' || kfl_fct.kayit_referans_numarasi) AS tzl_kisi_ref_no,
            LPAD(kfl_fct.ilkodu,3,0) AS sube_merkez_il_kodu,
            LPAD(NVL(a.ana_sube,99999),5,0) AS sube_eft_kodu,
            RPAD(kfl_fct.isim_unvan,100,' ') AS unvan,

            CASE WHEN kfl_fct.isyeri_adres IS NULL OR kfl_fct.ev_adres IS NULL
                 THEN '                                                                                                                        '
                 ELSE RPAD(COALESCE( kfl_fct.isyeri_adres,kfl_fct.ev_adres),120,' ') END AS adres,
            NVL(LPAD(COALESCE(kfl_fct.isyeri_il_kodu,kfl_fct.ev_il_kodu),3,0),999) AS adres_il_kodu,

            --NVL(LPAD(i.ilce,2,0),99) adres_ilce_kodu,
            --NVL(LPAD(COALESCE(kfl_fct.isyeri_ilce_kodu,kfl_fct.ev_ilce_kodu),2,'0'),'99') AS adres_ilce_kodu,
            NVL(LPAD(COALESCE(kfl_fct.kkb_isyeri_il_ilce_kod,kfl_fct.kkb_ev_il_ilce_kod),2,'0'),'99') AS adres_ilce_kodu,
            --NVL(LPAD(COALESCE(kfl_fct.isyeri_ilce_aciklama,kfl_fct.ev_ilce_aciklama),2,0),99) AS adres_ilce_kodu,-------uyusmayan ilçe kodlarý var edize sorulacak.


            CASE WHEN kfl_fct.ulke_kodu IN ('TR', '90', '792') THEN '792'
            ELSE '999' END AS ulke_kodu,----ulkelerin uyusmasý için parametre tablosuna ihtiyac var

            CASE WHEN kfl_fct.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(kfl_fct.ticaret_sicil_no),'                                ') END  ticaret_sicil_numarasi,




            '                ' AS mersis_numarasi,
            '                    ' AS ticaret_odasý,
            '999' AS ticaret_tescil_il_kodu,
            '99' AS ticaret_tescil_merkezi_kodu,
            CASE WHEN kfl_fct.vergi_dairesi IS NULL THEN '                    ' ELSE LPAD(kfl_fct.vergi_dairesi,20,' ') END vergi_dairesi,
            NVL(DECODE(kfl_fct.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(kfl_fct.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            --CASE WHEN kfl_fct.firma_turu IS NULL THEN ' ' ELSE TO_CHAR (kfl_fct.firma_turu) END firma_turu,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            --NVL (LPAD(TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
            LPAD(NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
            '04' AS firma_iliski_kodu,
            --NVL (LPAD(a.kayit_referans_numarasi, 27, ' '), '                           ') ilsk_ndn_olan_grc_tzl_refno,
            '32' || '00099' || LPAD(NVL (a.kayit_referans_numarasi, '                    '), 20, ' ') ilsk_ndn_olan_grc_tzl_refno,
            LPAD(NVL (a.isim_unvan, '                                                                                                    '), 100, ' ') AS ilsk_ndn_olan_grc_unvan,
            '0' AS kredi_iliski_kodu,
            '00000000' AS ilsk_baslangic_tarihi,
            '00000000' AS ilsk_bitis_tarihi,
            '1' AS ilsk_gostergesi,
            '00000' AS ortaklýk_hisse_orani,

            CASE WHEN kfl_fct.isyeri_posta_kod IS NULL AND kfl_fct.ev_posta_kod IS NULL THEN '          ' ELSE LPAD(COALESCE(kfl_fct.isyeri_posta_kod ,kfl_fct.ev_posta_kod),10,' ') END adres_posta_kod,

                          /*CASE WHEN kfl_fct.isyeri_tel_ulke_kodu IS NULL AND kfl_fct.ev_tel_ulke_kodu IS NULL AND kfl_fct.cep_tel_ulke_kodu IS NULL THEN '0000' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_ulke_kodu,kfl_fct.ev_tel_ulke_kodu,kfl_fct.cep_tel_ulke_kodu ),4,'0'),null) END tlf_ulke_kodu,   ---NVL (x,null)??????

            CASE WHEN kfl_fct.isyeri_tel_alan_kodu IS NULL AND kfl_fct.ev_tel_alan_kodu IS NULL AND kfl_fct.cep_tel_alan_kodu IS NULL THEN '000' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_alan_kodu,kfl_fct.ev_tel_alan_kodu,kfl_fct.cep_tel_alan_kodu) ,3,'0'),null) END tlf_bolge_kodu,  ---NVL (x,null)??????

            CASE WHEN kfl_fct.isyeri_tel_numara IS NULL AND kfl_fct.ev_tel_numara IS NULL AND kfl_fct.cep_tel_numara IS NULL THEN '         ' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_numara,kfl_fct.ev_tel_numara,kfl_fct.cep_tel_numara) ,9,' '),null) END tlf_numarasi,  ---NVL (x,null)??????

            CASE WHEN kfl_fct.isyeri_tel_formatlý_tel_no IS NULL AND kfl_fct.ev_tel_formatlý_tel_no IS NULL AND kfl_fct.cep_tel_formatlý_tel_no IS NULL
                 THEN '                ' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_formatlý_tel_no,kfl_fct.ev_tel_formatlý_tel_no,kfl_fct.cep_tel_formatlý_tel_no) ,16,'0'),null) END formatli_telefon_numarasi,  ---NVL (x,null)??????*/

            LPAD(NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
            LPAD(NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
            LPAD(NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
            LPAD(NVL (TO_CHAR (kfl_fct.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
            LPAD(NVL (TO_CHAR (kfl_fct.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,

            CASE WHEN kfl_fct.web_adresi IS NULL THEN '                                                  ' ELSE LPAD(kfl_fct.web_adresi, 50, ' ') END AS web_adresi,
            CASE WHEN kfl_fct.mail IS NULL THEN '                                                  ' ELSE LPAD(kfl_fct.mail,50,' ') END AS e_posta,
            '00000000' AS uye_calisma_baslama_tarih ,
            LPAD(NVL(kfl_fct.donem_calisan_sayisi,0),10,0) AS calisan_sayisi ,
            RPAD(NVL(kfl_fct.finansman_konusu_kodu,'999') ,3,' ') AS finansman_konusu_kodu,
            CASE WHEN kfl_fct.firma_grup_kodu IS NULL THEN '          ' ELSE LPAD(kfl_fct.firma_grup_kodu,10,' ') END firma_grup_kodu,

            CASE WHEN kfl_fct.CIRO_TUTARI<0 OR kfl_fct.CIRO_TUTARI IS NULL THEN 999
            ELSE 792 END CIRO_DOVIZ_KODU,


            CASE WHEN kfl_fct.ciro_tutari<0 THEN '               '
            ELSE NVL(LPAD(ROUND(TO_CHAR(kfl_fct.ciro_tutari),0),15,'0'),'               ') END ciro_tutari,

            LPAD(NVL(kfl_fct.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(kfl_fct.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(kfl_fct.min_actarih_grup3,'yyyymmdd'), '00000000') AS grup3_alinma_tarihi,
            NVL(TO_CHAR(kfl_fct.min_actarih_grup4,'yyyymmdd'), '00000000') AS grup4_alinma_tarihi,
            NVL(TO_CHAR(kfl_fct.min_actarih_grup5,'yyyymmdd'), '00000000') AS grup5_alinma_tarihi,


            --
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit)),0),15,'0'),'               ') END NAKIT_LIMIT,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_gayrinakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_gayrinakit)),0),15,'0'),'               ') END GAYRINAKIT_LIMIT,
             CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit_genel)),0) = 0 THEN '               '
             ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit_genel)),0),15,'0'),'               ') END firma_genel_limiti,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_limit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_limit)),0),15,'0'),'               ') END GRUP_LIMITI,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_risk)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_risk)),0),15,'0'),'               ') END GRUP_RISKI,

            CASE WHEN kfl_fct.genel_revize_vadesi IS NULL THEN '00000000' ELSE NVL(TO_CHAR(kfl_fct.genel_revize_vadesi,'yyyymmdd'), '00000000') END genel_revize_vadesi,
            NVL(TO_CHAR(kfl_fct.son_revize_tarihi,'yyyymmdd'), '99999999') son_revize_tarihi,
            RPAD(' ', 407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
      FROM  prsn.kkb_trbfc_trbic_fct a
            --INNER JOIN kkb_ref_bazli_kefil_n gf
            INNER JOIN trfm.tmp_trbgr_03 gf
                     ON a.musteri_no = gf.musteri
                     AND a.kesit_tarihi = gf.kst_trh
            --INNER JOIN tmp_trbgr_mus_iliski ana_must
                  --ON a.musteri_no = ana_must.ana_musteri_no
                  --AND a.kesit_tarihi = ana_must.kst_trh
            INNER JOIN prsn.kkb_trbfc_trbic_fct kfl_fct
                     ON gf.kefil_musteri_no = kfl_fct.musteri_no
                     AND gf.kst_trh = kfl_fct.kesit_tarihi
                          /*LEFT JOIN extr.fs_ilce i
                  ON  LPAD(a.ev_il_kodu, 3, 0) =LPAD(i.il,3,0)
                  and a.ev_ilce_aciklama = i.aciklama*/
            --left join kkb_ulke  c  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
                --on a.ulke_kodu=c.ulke_kodu
                          /*left join prsn.prmfirmaturu ft
            ON DECODE (kfl_fct.sirket_tip_acklm, 'ANONÝM', '04',
                                     'ADÝ', '1',
                                     'KOMANDÝT', '02',
                                     'LÝMÝTED', '06',
                                     'KOLLEKTÝF', '05',
                                     'KOOPERATÝF', '20',
                                     'BELÝRTÝLMEMÝÞ', '99',
                                     'ASKERÝ BÝRLÝK', '34',
                                     'ÞÝRKET DEÐÝL (ASKERÝ)', '98',
                                     'ÞÝRKET DEÐÝL (SÝVÝL)', '98',
                                     '99')
                               = TO_NUMBER (TRIM (ft.id))*/
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                            ON     1 = 1
                               AND kfl_fct.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            --AND kfl_fct.gercek_tuzel = 'T';
            --AND vtf.tckn_vkn = 'VKN'
            AND vtf.trbfc_trbic_f = 'TRBFC'
            AND a.kesit_tarihi = v_tarih;

      COMMIT;



   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_sonrs_trbfc_txt;


   PROCEDURE sp_trbgr_sonrs_trbic_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_SONRS_TRBIC_TXT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2800;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbgr_sonrs_trbic_txt WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2810;
   ----Ana musteriler----
   INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_sonrs_trbic_txt
   SELECT kfl_fct.kesit_tarihi,
          gf.tmnt_refsube, gf.tmnt_reftur, gf.tmnt_refsirano,
          (gf.tmnt_refsube || gf.tmnt_reftur || gf.temtur || '-' || gf.tmnt_refsirano) AS tmnt_referans,
          kfl_fct.ana_sube, kfl_fct.calisma_sekli, kfl_fct.gercek_tuzel, vtf.tckn_vkn AS kontrol_tckn_vkn_f,
          a.musteri_no ana_musteri_no, kfl_fct.musteri_no, kfl_fct.musteri_tip, kfl_fct.tck_no, kfl_fct.vergi_no,
          '10' AS veri_turu,
          '00099' AS uye_kodu,
          a.kayýt_referans_numarasi,
          'TRBIC' Segment_Turu,
          '02' Versiyon_Numarasi,
          '20'
          ||'00099'
          ||'00'||
          CASE WHEN kfl_fct.tck_no IS NOT NULL THEN '6' ELSE '0' END
          ||
          '000000'
          ||
          COALESCE(kfl_fct.tck_no,'00000000000') AS gercek_kisi_ref_no,
          LPAD(NVL(kfl_fct.ana_sube,99999),5,0) AS sube_eft_kodu,
          LPAD(NVL(kfl_fct.ilkodu,999),3,0) AS sube_merkez_il_kodu,
          '04' AS firma_iliski_kodu,
          LPAD(NVL(kfl_fct.isim,'               '),15,' ') AS isim,
          LPAD(NVL(kfl_fct.ikinci_isim,'               '),15,' ') AS ikinci_isim,
          LPAD(NVL(kfl_fct.ikinci_isim,'               '),30,' ') AS soyad,
          NVL(TO_CHAR (kfl_fct.dogum_tarihi, 'YYYYMMDD'),'99999999') AS dogum_tarihi,

--          COALESCE(d1.kimlik_turu_kodu,9) AS kimlik_kod_1,
--          NVL (LPAD(COALESCE(d1.kimlik_turu_aciklama,NULL),20,' '), '                    ') AS kimlik_no_1,
--          COALESCE(d2.kimlik_turu_kodu,9) AS kimlik_kod_2,
--          NVL (LPAD(COALESCE(d2.kimlik_turu_aciklama,NULL),20,' '), '                    ') AS kimlik_no_2,
--          COALESCE(d3.kimlik_turu_kodu,9) AS kimlik_kod_3,
--          NVL (LPAD(COALESCE(d3.kimlik_turu_aciklama,NULL),20,' '), '                    ') AS kimlik_no_3,
--          COALESCE(d4.kimlik_turu_kodu,9) AS kimlik_kod_4,
--          NVL (LPAD(COALESCE(d4.kimlik_turu_aciklama,NULL),20,' '), '                    ') AS kimlik_no_4,

        coalesce(d1.kimlik_turu_kodu,9) as kimlik_kod_1,
        NVL (lpad(coalesce(kfl_fct.KIMLIK_KOD_1_SERI_NO,NULL),20,' '), '                    ') kimlik_no_1,
        coalesce(d2.kimlik_turu_kodu,9) as kimlik_kod_2,
        NVL (lpad(coalesce(kfl_fct.KIMLIK_KOD_2_SERI_NO,NULL),20,' '), '                    ') kimlik_no_2,
        coalesce(d3.kimlik_turu_kodu,9) as kimlik_kod_3,
        NVL (lpad(coalesce(kfl_fct.KIMLIK_KOD_3_SERI_NO,NULL),20,' '), '                    ') kimlik_no_3,
        coalesce(d4.kimlik_turu_kodu,9) as kimlik_kod_4,
        NVL (lpad(coalesce(kfl_fct.KIMLIK_KOD_4_SERI_NO,NULL),20,' '), '                    ') kimlik_no_4,


          NVL (LPAD(COALESCE(kfl_fct.isyeri_adres,NULL),120,' '), '                                                                                                                        ') AS is_adresi,
          LPAD(COALESCE(kfl_fct.isyeri_il_kodu,999),3,0) AS is_adresi_il_kodu,

          --NVL(LPAD(bi.ilce,2,0),99) AS is_adresi_ilce_kodu,--kkb
          LPAD(COALESCE(TO_CHAR(kfl_fct.kkb_isyeri_il_ilce_kod),'99'),2,'0') AS is_adresi_ilce_kodu,

          NVL (LPAD(COALESCE(kfl_fct.ev_adres,NULL),120,' '), '                                                                                                                        ')  AS ev_adresi,
          LPAD(COALESCE(kfl_fct.ev_il_kodu,999),3,'0') AS ev_adresi_il_kodu,

          --NVL(LPAD(bi.ilce,2,0),99) AS ev_adresi_ilce_kodu,
          LPAD(COALESCE(TO_CHAR(kfl_fct.kkb_ev_il_ilce_kod),'99'),2,'0') AS ev_adresi_ilce_kodu,
          --LPAD (COALESCE(i.ilce_kodu,'99'), 2, 0) AS ev_adresi_ilce_kodu,--kkb

          LPAD(COALESCE(TO_CHAR (kfl_fct.uyruk_kodu),'999'),3,0) AS uyruk,

          NVL (LPAD (a.kayit_referans_numarasi, 27, ' '), '                           ') AS ilsk_ndn_olan_grc_tzl_refno,
          LPAD (NVL (a.isim_unvan, '                                                                                                    '), 100, ' ') ilsk_ndn_olan_grc_unvan,
          '0' AS kredi_iliski_kodu,
          '99999999' AS ilsk_baslangic_tarihi,
          '99999999' AS ilsk_bitis_tarihi,
          '1' AS ilsk_gostergesi,
          '     ' AS ortaklýk_hisse_orani,
          '                              ' AS unvan,
          '9' AS imza_yetkisi_kodu,
          NVL (LPAD(COALESCE(kfl_fct.ev_posta_kod,NULL),10,' '), '          ') AS ev_adresi_posta_kodu,
          NVL (LPAD(COALESCE(kfl_fct.isyeri_posta_kod,NULL),10,' '), '          ') AS is_adresi_posta_kodu,

          --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_ulke_kodu,kfl_fct.ev_tel_ulke_kodu,kfl_fct.cep_tel_ulke_kodu,null),4,' '), '    ') AS  tlf_ulke_kodu,
          --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_alan_kodu,kfl_fct.ev_tel_alan_kodu,kfl_fct.cep_tel_alan_kodu,null) ,3,' '), '   ')  AS  tlf_bolge_kodu,
          --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_numara,kfl_fct.ev_tel_numara,kfl_fct.cep_tel_numara,null) ,9,' '), '         ')  AS  tlf_numarasi,
          --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_formatlý_tel_no,kfl_fct.ev_tel_formatlý_tel_no,kfl_fct.cep_tel_formatlý_tel_no,null) ,16,' '), '                ') AS  formatli_telefon_numarasi,

          LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_ulke), '    '), 4, ' ') AS tlf_ulke_kodu,
          LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_bolge), '   '), 3, ' ') AS tlf_bolge_kodu,
          LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_tln_no), '         '), 9, ' ') AS tlf_numarasi,
          LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1), '                '), 16, ' ') AS formatli_telefon_numarasi_1,
          LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_2), '                '), 16, ' ') AS formatli_telefon_numarasi_2,

          NVL (LPAD(COALESCE(kfl_fct.ev_tel_formatlý_tel_no,NULL) ,16,' '), '                ') AS ev_tel_formatlý_tel_no,
          NVL (LPAD(COALESCE(kfl_fct.cep_tel_formatlý_tel_no,NULL) ,16,' '), '                ') AS cep_tel_formatlý_tel_no,
          NVL (LPAD(COALESCE(kfl_fct.mail,null),50,' '), '                                                  ') AS e_posta,
          --LPAD(NVL(d.lookupvalue,99),2,' ') AS meslek_kodu,----lookup value deðelreri guncel deðil edizlerin guncellemesi gerekiyor.
          --LPAD(NVL(d.value,null),30,' ')     AS meslek

          NVL (LPAD(COALESCE(kfl_fct.meslek_kkb_kod,'99'),2,' '), '  ') AS meslek_kodu,
          NVL (LPAD(COALESCE(kfl_fct.meslek_kkb_kod_acklm ,NULL),'30',' '), '                              ')     AS meslek,

          NVL (LPAD(COALESCE(kfl_fct.egitim_kkb_kod,'99'),2,' '), '  ') AS egitim_durumu_kodu,
          NVL (LPAD(COALESCE(kfl_fct.egitim_kkb_kod_acklm ,NULL),'30',' '), '                              ')  AS egitim_durumu,
          RPAD(' ', 461,' ') AS rezerv_alan1,
          SYSDATE AS etl_trh,
          v_sp_name AS etl_job
     FROM prsn.kkb_trbfc_trbic_fct a
          --INNER JOIN kkb_ref_bazli_kefil_n gf ---------------------------------------------------
          INNER JOIN trfm.tmp_trbgr_03 gf ---------------------------------------------------
               ON a.musteri_no = gf.musteri ---------------------------------------------------
               AND a.kesit_tarihi = gf.kst_trh ---------------------------------------------------
               --INNER JOIN tmp_trbgr_mus_iliski ana_must ---------------------------------------------------
               --ON a.musteri_no = ana_must.ana_musteri_no ---------------------------------------------------
               --AND a.kesit_tarihi = ana_must.kst_trh ---------------------------------------------------
          INNER JOIN prsn.kkb_trbfc_trbic_fct kfl_fct ---------------------------------------------------
               ON gf.kefil_musteri_no = kfl_fct.musteri_no ---------------------------------------------------
               AND gf.kst_trh = kfl_fct.kesit_tarihi ---------------------------------------------------
                        /*LEFT JOIN extr.fs_ilce bi
               ON  LPAD (a.ev_il_kodu, 3, 0) =LPAD(bi.il,3,0)
               and a.ev_ilce_aciklama = bi.aciklama   */
               --left join kkb_ulke  c  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
               --on a.ulke_kodu=c.ulke_kodu


          LEFT JOIN trfm.tmp_kkb_kmlk_tur d1 ON
                     CASE WHEN kfl_fct.kimlik_kod_1='SB' THEN 2
                     WHEN kfl_fct.kimlik_kod_1='NC'  THEN 3
                     WHEN kfl_fct.kimlik_kod_1 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                     WHEN kfl_fct.kimlik_kod_1 IS NULL THEN 9
                     END = d1.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_kmlk_tur d2 ON
                     CASE WHEN kfl_fct.kimlik_kod_2='SB' THEN 2
                     WHEN kfl_fct.kimlik_kod_2='NC'  THEN 3
                     WHEN kfl_fct.kimlik_kod_2 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                     WHEN kfl_fct.kimlik_kod_2 IS NULL THEN 9
                     END = d2.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_kmlk_tur d3 ON
                     CASE WHEN kfl_fct.kimlik_kod_3='SB' THEN 2
                     WHEN kfl_fct.kimlik_kod_3='NC'  THEN 3
                     WHEN kfl_fct.kimlik_kod_3 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                     WHEN kfl_fct.kimlik_kod_3 IS NULL THEN 9
                     END = d3.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_kmlk_tur d4 ON
                     CASE WHEN kfl_fct.kimlik_kod_4='SB' THEN 2
                     WHEN kfl_fct.kimlik_kod_4='NC'  THEN 3
                     WHEN kfl_fct.kimlik_kod_4 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') THEN 8
                     WHEN kfl_fct.kimlik_kod_4 IS NULL THEN 9
                     END = d4.kimlik_turu_kodu
          LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                            ON     1 = 1
                               AND kfl_fct.musteri_tip = vtf.musteri_tip
   WHERE 1 = 1
        --AND kfl_fct.gercek_tuzel = 'G';
        --AND vtf.tckn_vkn = 'TCKN'
        AND vtf.trbfc_trbic_f = 'TRBIC'
        AND a.kesit_tarihi = v_tarih;

   COMMIT;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_sonrs_trbic_txt;



   PROCEDURE sp_trbgr_sonrs_trbfc_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_SONRS_TRBFC_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 2900;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbgr_sonrs_trbfc_txt_krd WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=2910;

      INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_sonrs_trbfc_txt_krd
     SELECT kfl_fct.kesit_tarihi, kfl_fct.calisma_sekli, kfl_fct.ana_sube, kfl_fct.gercek_tuzel, vtf.tckn_vkn AS kontrol_tckn_vkn_f,
            kfl_fct.musteri_no ana_musteri_no, kfl_fct.musteri_no, kfl_fct.musteri_tip, kfl_fct.tck_no, kfl_fct.vergi_no,
            g.tmnt_refsube, g.tmnt_reftur, g.tmnt_refsirano, g.tmnt_referans, g.teminat_turu_kodu_ing, g.teminat_turu_acklm_ing,
            CASE WHEN g.krdreftur IS NOT NULL AND g.krdrefsirano IS NOT NULL
                      THEN DECODE (
                                   g.krdreftur,
                                                'AC',     'ITH',
                                                'AL',     'ITH',
                                                'DE',     'NKRD',
                                                'DK',     'NKRD',
                                                'HG',     'TMEK',
                                                'KT',     'KMH',
                                                'LC',     'ITH',
                                                'TD',     'TKRD',
                                                'TK',     'NKRD',
                                                'TM',     'TMEK',
                                                'TT',     'TKRD',
                                                'TY',     'TMEK'
                                  )
                 WHEN g.krdreftur IS NULL AND g.krdrefsirano IS NOT NULL
                      THEN 'GVNC'
                           ELSE NULL
                                END tip,
            g.krdsube, g.krdreftur, g.krdrefnit, g.krdrefsirano, g.krd_referans,
            g.teminat_doviz_kodu, g.teminat_cesidi, g.krd_birebir_iliskili_tmnt_f,
            '30' AS veri_turu,
            '00099' AS uye_Kodu,
            g.kayit_referans_numarasi_krd, --bu kýsým bu query'de firma künye için yazýldý
            'TRBFC' Segment_Turu,
            '02' AS Versiyon_Numarasi,
            ('10' || '00099' || kfl_fct.kayit_referans_numarasi) AS tzl_kisi_ref_no,
            LPAD(kfl_fct.ilkodu,3,0) AS sube_merkez_il_kodu,
            LPAD(NVL(kfl_fct.ana_sube,99999),5,0) AS sube_eft_kodu,
            RPAD(kfl_fct.isim_unvan,100,' ') AS unvan,
            CASE WHEN kfl_fct.isyeri_adres IS NULL OR kfl_fct.ev_adres IS NULL
                 THEN '                                                                                                                        '
                 ELSE RPAD(COALESCE( kfl_fct.isyeri_adres,kfl_fct.ev_adres),120,' ')
            END AS adres,
            NVL(LPAD(COALESCE(kfl_fct.isyeri_il_kodu,kfl_fct.ev_il_kodu),3,0),999) AS adres_il_kodu,
            --NVL(LPAD(i.ilce,2,0),99) AS adres_ilce_kodu,
            NVL(LPAD(COALESCE(kfl_fct.kkb_isyeri_il_ilce_kod,kfl_fct.kkb_ev_il_ilce_kod),2,'0'),'99') AS adres_ilce_kodu,
            --NVL(LPAD(COALESCE(kfl_fct.isyeri_ilce_aciklama,kfl_fct.ev_ilce_aciklama),2,0),99) AS  adres_ilce_kodu,-------uyusmayan ilçe kodlarý var edize sorulacak.
            CASE WHEN kfl_fct.ulke_kodu IN ('TR', '90', '792') THEN '792'
            ELSE '999' END AS ulke_kodu,----ulkelerin uyusmasý için parametre tablosuna ihtiyac var
            CASE WHEN kfl_fct.ticaret_sicil_no IS NOT NULL THEN LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.ticaret_sicil_no)),0),32,0)
            ELSE NVL(TO_CHAR(kfl_fct.ticaret_sicil_no),'                                ') END  ticaret_sicil_numarasi,
            '                '        mersis_numarasi,
            '                    '    ticaret_odasý,
            '999'                     ticaret_tescil_il_kodu,
            '99'                      ticaret_tescil_merkezi_kodu,
            CASE WHEN kfl_fct.vergi_dairesi IS NULL THEN '                    ' ELSE LPAD(kfl_fct.vergi_dairesi,20,' ') END vergi_dairesi,
            NVL(DECODE(kfl_fct.tescil_tarihi,TO_CHAR(TO_DATE ('01/01/1900', 'DD/MM/YYYY'),'yyyymmdd'),NULL,TO_CHAR(TO_CHAR(kfl_fct.tescil_tarihi,'yyyymmdd'))),'99999999') AS kurulus_tarihi,
            --CASE WHEN kfl_fct.firma_turu IS NULL THEN ' ' ELSE TO_CHAR (kfl_fct.firma_turu) END firma_turu,
            a.sirket_tip_ing,
            a.sirket_tip_acklm_ing,
            --NVL (LPAD (TRIM (ft.id), 2, '0'), '99') firma_turu_kkb,
            LPAD (NVL (a.sirket_tip_kkb, '98'), 2, '0') AS firma_turu_kkb,
            NVL (a.sirket_tip_acklm_kkb, 'DÝÐER') AS firma_turu_acklm_kkb,
            '04' firma_iliski_kodu,
            --NVL (LPAD (a.kayit_referans_numarasi, 27, ' '), '                           ') ilsk_ndn_olan_grc_tzl_refno,
            '10' || '00099' || LPAD (NVL (g.kayit_referans_numarasi_krd, '                    '), 20, ' ') AS ilsk_ndn_olan_grc_tzl_refno,
            LPAD (NVL (kfl_fct.isim_unvan, RPAD(' ', 407,' ') ), 100, ' ') AS ilsk_ndn_olan_grc_unvan,
            '3' AS kredi_iliski_kodu,
            '00000000' AS ilsk_baslangic_tarihi,
            '00000000' AS ilsk_bitis_tarihi,
            '1' AS ilsk_gostergesi,
            '00000' AS ortaklýk_hisse_orani,

            CASE WHEN kfl_fct.isyeri_posta_kod IS NULL AND kfl_fct.ev_posta_kod IS NULL THEN '          ' ELSE LPAD(COALESCE(kfl_fct.isyeri_posta_kod ,kfl_fct.ev_posta_kod),10,' ') END adres_posta_kod,

                          /*CASE WHEN kfl_fct.isyeri_tel_ulke_kodu IS NULL AND kfl_fct.ev_tel_ulke_kodu IS NULL AND kfl_fct.cep_tel_ulke_kodu IS NULL THEN '0000' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_ulke_kodu,kfl_fct.ev_tel_ulke_kodu,kfl_fct.cep_tel_ulke_kodu ),4,'0'),null) END tlf_ulke_kodu,   ---NVL (x,null)??????

            CASE WHEN kfl_fct.isyeri_tel_alan_kodu IS NULL AND kfl_fct.ev_tel_alan_kodu IS NULL AND kfl_fct.cep_tel_alan_kodu IS NULL THEN '000' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_alan_kodu,kfl_fct.ev_tel_alan_kodu,kfl_fct.cep_tel_alan_kodu) ,3,'0'),null) END tlf_bolge_kodu,  ---NVL (x,null)??????

            CASE WHEN kfl_fct.isyeri_tel_numara IS NULL AND kfl_fct.ev_tel_numara IS NULL AND kfl_fct.cep_tel_numara IS NULL THEN '         ' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_numara,kfl_fct.ev_tel_numara,kfl_fct.cep_tel_numara) ,9,' '),null) END tlf_numarasi,  ---NVL (x,null)??????

            CASE WHEN kfl_fct.isyeri_tel_formatlý_tel_no IS NULL AND kfl_fct.ev_tel_formatlý_tel_no IS NULL AND kfl_fct.cep_tel_formatlý_tel_no IS NULL THEN '                ' ELSE NVL(LPAD(COALESCE(kfl_fct.isyeri_tel_formatlý_tel_no,kfl_fct.ev_tel_formatlý_tel_no,kfl_fct.cep_tel_formatlý_tel_no) ,16,'0'),null) END formatli_telefon_numarasi,  ---NVL (x,null)??????*/

            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_ulke), '    '), 4, ' ') tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_bolge), '   '), 3, ' ') tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_tln_no), '         '), 9, ' ') tlf_numarasi,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1), '                '), 16, ' ') formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_2), '                '), 16, ' ') formatli_telefon_numarasi_2,

            CASE WHEN kfl_fct.web_adresi IS NULL THEN '                                                  ' ELSE LPAD (kfl_fct.web_adresi, 50, ' ') END AS web_adresi,
            CASE WHEN kfl_fct.mail IS NULL THEN RPAD(' ', 50,' ') ELSE LPAD(kfl_fct.mail,50,' ') END AS e_posta,
            '00000000' uye_calisma_baslama_tarih ,----ediz bey destek
            LPAD(NVL(kfl_fct.donem_calisan_sayisi,0),10,0) AS calisan_sayisi ,
            LPAD(NVL(kfl_fct.finansman_konusu_kodu,999) ,3,' ') finansman_konusu_kodu,
            CASE WHEN kfl_fct.firma_grup_kodu IS NULL THEN '          ' ELSE LPAD(kfl_fct.firma_grup_kodu,10,' ') END firma_grup_kodu,


            CASE WHEN kfl_fct.CIRO_TUTARI<0 OR kfl_fct.CIRO_TUTARI IS NULL THEN 999
            ELSE 792 END CIRO_DOVIZ_KODU,

            CASE WHEN kfl_fct.ciro_tutari<0 THEN '               '
            ELSE NVL(LPAD(ROUND(TO_CHAR(kfl_fct.ciro_tutari),0),15,'0'),'               ') END ciro_tutari,


            LPAD(NVL(kfl_fct.ciro_yili,9999),4,' ') AS ciro_yili,
            LPAD(NVL(kfl_fct.risk_kod,NULL),1,' ' ) AS risk_grup_kodu,
            '                              ' AS risk_grup_kodu_sebebi,
            NVL(TO_CHAR(kfl_fct.min_actarih_grup3,'yyyymmdd'), '00000000') grup3_alinma_tarihi,---incelenebilir
            NVL(TO_CHAR(kfl_fct.min_actarih_grup4,'yyyymmdd'), '00000000') grup4_alinma_tarihi,
            NVL(TO_CHAR(kfl_fct.min_actarih_grup5,'yyyymmdd'), '00000000') grup5_alinma_tarihi,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit)),0),15,'0'),'               ') END nakit_limit,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_gayrinakit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_gayrinakit)),0),15,'0'),'               ') END gayrinakit_limit,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit_genel)),0) = 0 THEN '               '
                  ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.tllimit_nakit_genel)),0),15,'0'),'               ') END firma_genel_limiti,

            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_limit)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_limit)),0),15,'0'),'               ') END grup_limiti,
            CASE WHEN  ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_risk)),0) = 0 THEN '               '
                 ELSE  NVL(LPAD(ROUND(TO_NUMBER(TO_CHAR(kfl_fct.grup_risk)),0),15,'0'),'               ') END grup_riski,


            CASE WHEN kfl_fct.genel_revize_vadesi IS NULL THEN '00000000' ELSE NVL(TO_CHAR(kfl_fct.genel_revize_vadesi,'yyyymmdd'), '00000000') END genel_revize_vadesi,
            NVL(TO_CHAR(kfl_fct.son_revize_tarihi,'yyyymmdd'), '99999999') son_revize_tarihi,
            RPAD(' ', 407,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
      FROM  prsn.kkb_trbfc_trbic_fct a
            --INNER JOIN tmp_trbgr_mus_iliski ana_must
            INNER JOIN trfm.tmp_trbgr_03 ana_must ON  1=1
                                                    AND a.musteri_no = ana_must.musteri
                                                    AND a.kesit_tarihi = ana_must.kst_trh
            INNER JOIN prsn.kkb_trbfc_trbic_fct kfl_fct ON  1=1
                                                 AND ana_must.kefil_musteri_no = kfl_fct.musteri_no
                                                 AND ana_must.kst_trh = kfl_fct.kesit_tarihi
            INNER JOIN prsn.kkb_trbgr_txt_krd g ON  1 = 1
                                         AND kfl_fct.kesit_tarihi = g.kesit_tarihi
                                         AND kfl_fct.musteri_no = g.musteri_no
                          /*LEFT JOIN extr.fs_ilce i ON  1=1
                                     AND LPAD(a.ev_il_kodu, 3, 0) = LPAD(i.il,3,0)
                                     AND a.ev_ilce_aciklama = i.aciklama*/
                  --left join kkb_ulke  c  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
                  --on a.ulke_kodu=c.ulke_kodu
                                /*left join prsn.prmfirmaturu ft
                  ON DECODE (kfl_fct.sirket_tip_acklm, 'ANONÝM', '04',
                                        'ADÝ', '1',
                                        'KOMANDÝT', '02',
                                        'LÝMÝTED', '06',
                                        'KOLLEKTÝF', '05',
                                        'KOOPERATÝF', '20',
                                        'BELÝRTÝLMEMÝÞ', '99',
                                        'ASKERÝ BÝRLÝK', '34',
                                        'ÞÝRKET DEÐÝL (ASKERÝ)', '98',
                                        'ÞÝRKET DEÐÝL (SÝVÝL)', '98',
                                        '99')
                                  = TO_NUMBER (TRIM (ft.id))*/
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                            ON     1 = 1
                               AND kfl_fct.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
        --AND kfl_fct.gercek_tuzel = 'T'
        --AND vtf.tckn_vkn = 'VKN'
        AND vtf.trbfc_trbic_f = 'TRBFC'
        AND g.teminat_turu_kodu = '45' --Kefalet
        AND a.kesit_tarihi=v_tarih;

      COMMIT;

   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_sonrs_trbfc_txt_krd;

   PROCEDURE sp_trbgr_sonrs_trbic_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TRBGR_SONRS_TRBIC_TXT_KRD';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 3000;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);

      DELETE FROM prsn.kkb_trbgr_sonrs_trbic_txt_krd WHERE 1=1 AND kesit_tarihi = v_tarih;
      COMMIT;

      v_line_no:=3010;

   ----Ana musteriler----
      INSERT               /*+ APPEND */ INTO prsn.kkb_trbgr_sonrs_trbic_txt_krd
     SELECT kfl_fct.kesit_tarihi, kfl_fct.ana_sube, kfl_fct.calisma_sekli, kfl_fct.gercek_tuzel, vtf.tckn_vkn kontrol_tckn_vkn_f,
            kfl_fct.musteri_no ana_musteri_no, kfl_fct.musteri_no, kfl_fct.musteri_tip, kfl_fct.tck_no, kfl_fct.vergi_no,
            g.tmnt_refsube, g.tmnt_reftur, g.tmnt_refsirano, g.tmnt_referans, g.teminat_turu_kodu_ing, g.teminat_turu_acklm_ing,
            CASE WHEN g.krdreftur IS NOT NULL AND g.krdrefsirano IS NOT NULL
                      THEN DECODE (
                                   g.krdreftur,
                                                'AC',     'ITH',
                                                'AL',     'ITH',
                                                'DE',     'NKRD',
                                                'DK',     'NKRD',
                                                'HG',     'TMEK',
                                                'KT',     'KMH',
                                                'LC',     'ITH',
                                                'TD',     'TKRD',
                                                'TK',     'NKRD',
                                                'TM',     'TMEK',
                                                'TT',     'TKRD',
                                                'TY',     'TMEK'
                                  )
                 WHEN g.krdreftur IS NULL AND g.krdrefsirano IS NOT NULL
                      THEN 'GVNC'
                           ELSE NULL
                                END tip,
            g.krdsube, g.krdreftur, g.krdrefnit, g.krdrefsirano, g.krd_referans,
            g.teminat_doviz_kodu, g.teminat_cesidi, g.krd_birebir_iliskili_tmnt_f,
            '30' veri_turu,
            '00099' uye_kodu,
            g.kayýt_referans_numarasi_krd,
            'TRBIC' Segment_Turu,
            '02' Versiyon_Numarasi,
            '20'
            ||'00099'
            ||'00'||
            CASE WHEN kfl_fct.tck_no IS NOT NULL THEN '6' ELSE '0' END
            ||
            '000000'
            ||
            COALESCE(kfl_fct.tck_no,'00000000000')  gercek_kisi_ref_no,
            LPAD(NVL(a.ana_sube,99999),5,0) sube_eft_kodu,
            LPAD(NVL(a.ilkodu,999),3,0) sube_merkez_il_kodu,
            '04' firma_iliski_kodu,
            LPAD(kfl_fct.isim,15,' ') AS isim,
            NVL (LPAD(kfl_fct.ikinci_isim,15,' '), '               ') AS ikinci_isim,
            NVL (LPAD(kfl_fct.soyad,30,' '), '                              ') AS soyad,
            NVL(TO_CHAR (kfl_fct.dogum_tarihi, 'YYYYMMDD'),'99999999') AS dogum_tarihi,

            COALESCE(d1.kimlik_turu_kodu,9) AS kimlik_kod_1,
            NVL (LPAD(COALESCE(d1.kimlik_turu_aciklama,NULL),20,' '), '                    ') kimlik_no_1,
            COALESCE(d2.kimlik_turu_kodu,9) AS kimlik_kod_2,
            NVL (LPAD(COALESCE(d2.kimlik_turu_aciklama,NULL),20,' '), '                    ') kimlik_no_2,
            COALESCE(d3.kimlik_turu_kodu,9) AS kimlik_kod_3,
            NVL (LPAD(COALESCE(d3.kimlik_turu_aciklama,NULL),20,' '), '                    ') kimlik_no_3,
            COALESCE(d4.kimlik_turu_kodu,9) AS kimlik_kod_4,
            NVL (LPAD(COALESCE(d4.kimlik_turu_aciklama,NULL),20,' '), '                    ') kimlik_no_4,

            NVL (LPAD(COALESCE(kfl_fct.isyeri_adres,NULL),120,' '), '                                                                                                                        ') AS is_adresi,
            LPAD(COALESCE(kfl_fct.isyeri_il_kodu,999),3,0) AS is_adresi_il_kodu,

            --NVL(LPAD(bi.ilce,2,0),99) AS is_adresi_ilce_kodu,
            LPAD(COALESCE(TO_CHAR(kfl_fct.kkb_isyeri_il_ilce_kod),'99'),2,'0') AS is_adresi_ilce_kodu,

            NVL (LPAD(COALESCE(a.ev_adres,''),120,' '), '                                                                                                                        ') AS ev_adresi,

            LPAD(COALESCE(TO_CHAR (a.ev_il_kodu),'999'),3,0) AS ev_adresi_il_kodu,

            --NVL(LPAD(bi.ilce,2,0),99) ev_adresi_ilce_kodu,
            LPAD(COALESCE(TO_CHAR (a.kkb_ev_il_ilce_kod),'99'),2,'0') AS ev_adresi_ilce_kodu,

            LPAD(COALESCE(TO_CHAR (a.uyruk_kodu),'999'),3,0) AS uyruk,
            '10'
            ||
            '00099'
            ||
            LPAD (NVL (g.kayýt_referans_numarasi_krd, '                    '), 20, ' ') ilsk_ndn_olan_grc_tzl_refno,
            LPAD (NVL (kfl_fct.isim_unvan, '                                                                                                    '), 100, ' ') ilsk_ndn_olan_grc_unvan,
            '0' kredi_iliski_kodu,
            '99999999' ilsk_baslangic_tarihi,
            '99999999' ilsk_bitis_tarihi,
            '1' ilsk_gostergesi,
            '     'ortaklýk_hisse_orani,
            '                              ' unvan,
            '9' imza_yetkisi_kodu,
            NVL (LPAD(COALESCE(kfl_fct.ev_posta_kod,NULL),10,' '), '          ') AS ev_adresi_posta_kodu,
            NVL (LPAD(COALESCE(kfl_fct.isyeri_posta_kod,NULL),10,' '), '          ') AS is_adresi_posta_kodu,

            --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_ulke_kodu,kfl_fct.ev_tel_ulke_kodu,kfl_fct.cep_tel_ulke_kodu,null),4,' '), '    ') AS  tlf_ulke_kodu,
            --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_alan_kodu,kfl_fct.ev_tel_alan_kodu,kfl_fct.cep_tel_alan_kodu,null) ,3,' '), '   ')  AS  tlf_bolge_kodu,
            --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_numara,kfl_fct.ev_tel_numara,kfl_fct.cep_tel_numara,null) ,9,' '), '         ')  AS  tlf_numarasi,
            --NVL (LPAD(COALESCE(kfl_fct.isyeri_tel_formatlý_tel_no,kfl_fct.ev_tel_formatlý_tel_no,kfl_fct.cep_tel_formatlý_tel_no,NULL) ,16,' '), '                ') AS  formatli_telefon_numarasi,

            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_ulke), '    '), 4, ' ') tlf_ulke_kodu,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_bolge), '   '), 3, ' ') tlf_bolge_kodu,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1_tln_no), '         '), 9, ' ') tlf_numarasi,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_1), '                '), 16, ' ') formatli_telefon_numarasi_1,
            LPAD (NVL (TO_CHAR (kfl_fct.formatli_tel_no_2), '                '), 16, ' ') formatli_telefon_numarasi_2,

            NVL (LPAD(COALESCE(kfl_fct.ev_tel_formatlý_tel_no,NULL) ,16,' '), '                ') AS ev_tel_formatlý_tel_no,
            NVL (LPAD(COALESCE(kfl_fct.cep_tel_formatlý_tel_no,NULL) ,16,' '), '                ') AS cep_tel_formatlý_tel_no,
            NVL (LPAD(COALESCE(kfl_fct.mail,NULL),50,' '), '                                                  ') AS e_posta,
            --LPAD(NVL(d.lookupvalue,99),2,' ') AS meslek_kodu,----lookup value deðelreri guncel deðil edizlerin guncellemesi gerekiyor.
            --LPAD(NVL(d.value,NULL),30,' ')     AS meslek

            NVL (LPAD(COALESCE(kfl_fct.meslek_kkb_kod,'99'),2,' '), '  ') AS meslek_kodu,
            NVL (LPAD(COALESCE(kfl_fct.meslek_kkb_kod_acklm ,NULL),'30',' '), '                              ')     AS meslek,

            NVL (LPAD(COALESCE(kfl_fct.egitim_kkb_kod,'99'),2,' '), '  ') AS egitim_durumu_kodu,
            NVL (LPAD(COALESCE(kfl_fct.egitim_kkb_kod_acklm ,NULL),'30',' '), '                              ')  AS egitim_durumu,
            RPAD(' ', 461,' ') AS rezerv_alan1,
            SYSDATE AS etl_trh,
            v_sp_name AS etl_job
      FROM  prsn.kkb_trbfc_trbic_fct a
            --INNER JOIN tmp_trbgr_mus_iliski ana_must
            INNER JOIN trfm.tmp_trbgr_03 ana_must
                       ON  1=1
                       AND a.musteri_no = ana_must.musteri
                       AND a.kesit_tarihi = ana_must.kst_trh
            INNER JOIN prsn.kkb_trbfc_trbic_fct kfl_fct
                       ON  1=1
                       AND ana_must.kefil_musteri_no = kfl_fct.musteri_no
                       AND ana_must.kst_trh = kfl_fct.kesit_tarihi
            INNER JOIN prsn.kkb_trbgr_txt_krd g
                       ON  1 = 1
                       AND kfl_fct.kesit_tarihi = g.kesit_tarihi
                       AND kfl_fct.musteri_no = g.musteri_no
                          /*LEFT JOIN extr.fs_ilce bi
                     ON  LPAD (a.ev_il_kodu, 3, 0) =LPAD(bi.il,3,0)
                     and a.ev_ilce_aciklama = bi.aciklama*/
            --left join kkb_ulke  c  --ulkelerin uyusmasý için parametre tablosuna ihtiyac var
            --on a.ulke_kodu=c.ulke_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d1
                      ON  1=1
                      AND CASE WHEN kfl_fct.kimlik_kod_1='SB' THEN 2
                               WHEN kfl_fct.kimlik_kod_1='NC'  THEN 3
                               WHEN kfl_fct.kimlik_kod_1 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR kfl_fct.kimlik_kod_1 IS NULL THEN 8
                          END = d1.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d2
                      ON  1=1
                      AND CASE WHEN kfl_fct.kimlik_kod_2='SB' THEN 2
                               WHEN kfl_fct.kimlik_kod_2='NC'  THEN 3
                               WHEN kfl_fct.kimlik_kod_2 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR kfl_fct.kimlik_kod_2 IS NULL THEN 8
                          END = d2.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d3
                      ON  1=1
                      AND CASE WHEN kfl_fct.kimlik_kod_3='SB' THEN 2
                               WHEN kfl_fct.kimlik_kod_3='NC'  THEN 3
                               WHEN kfl_fct.kimlik_kod_3 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR kfl_fct.kimlik_kod_3 IS NULL THEN 8
                          END = d3.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_kmlk_tur d4
                      ON  1=1
                      AND CASE WHEN kfl_fct.kimlik_kod_4='SB' THEN 2
                               WHEN kfl_fct.kimlik_kod_4='NC'  THEN 3
                               WHEN kfl_fct.kimlik_kod_4 IN ( 'PS', 'KK','IT', 'AK', 'E', 'EC', 'DG') OR kfl_fct.kimlik_kod_1 IS NULL THEN 8
                          END = d4.kimlik_turu_kodu
            LEFT JOIN trfm.tmp_kkb_mus_tip_vkn_tckn_f vtf
                      ON  1 = 1
                      AND kfl_fct.musteri_tip = vtf.musteri_tip
      WHERE 1 = 1
            --AND kfl_fct.gercek_tuzel = 'G'
            --AND vtf.tckn_vkn = 'TCKN'
            AND vtf.trbfc_trbic_f = 'TRBIC'
            AND g.teminat_turu_kodu = '45'
            AND a.kesit_tarihi = v_tarih;

      COMMIT;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_trbgr_sonrs_trbic_txt_krd;


   PROCEDURE sp_tkkb_rapor_gonderim_sorgu (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_TKKB_RAPOR_GONDERIM_SORGU';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 3100;


   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);
              /*
   DROP TABLE kkb_musteri_exclude; --Sýrrý Gültop'un tarifine göre eklendi
   CREATE TABLE kkb_musteri_exclude PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING AS
     SELECT DISTINCT kst_trh, musteri_no
       FROM (
               SELECT f.kst_trh, TO_NUMBER (f.vergi_no) vergi_no, TO_NUMBER (f.tck_no) tck_no, f.musteri_no,
                      SUM (NVL (f.tutar1, 0)) tutar1, SUM (NVL (f.tutar2, 0)) tutar2, SUM (NVL (f.tutar3, 0)) tutar3,
                      SUM (NVL (f.tutar4, 0)) tutar4, SUM (NVL (f.tutar5, 0)) tutar5
                 FROM trbac_txt_krd f
                WHERE 1 = 1
                  AND (    (
                                f.musteri_tip IN (13)
                            AND LENGTH (TO_NUMBER (f.vergi_no)) < 10
                           )
                        OR
                           (
                                f.musteri_tip IN (11, 12, 14)
                            AND LENGTH (TO_NUMBER (f.tck_no)) < 11
                           )
                      )
             GROUP BY f.kst_trh, TO_NUMBER (f.vergi_no), TO_NUMBER (f.tck_no), f.musteri_no
            )
      WHERE 1 = 1
        AND tutar1 = 0
        AND tutar2 = 0
        AND tutar3 = 0
        AND tutar4 = 0
        AND tutar5 = 0;
   GRANT SELECT ON kkb_musteri_exclude TO r_ofsdata, r_krd_sas, arzuh, selenc, ozlemo;
   --SELECT * FROM trbac_txt_krd f;
   --SELECT * FROM kkb_musteri_exclude;
*/
   --------------------------------------------------------------------------------

                 /*KUNYE VERI DOSYASI    SEGMENT ACIKLAMASI
   TRBHF                   Baþlangýç Bilgileri Bildirim Segmenti
   TRBFC                   Firma Künye Bilgileri Bildirim Segmenti (müþteri tüzelse)
   TRBIC                   Gerçek Kiþi Bilgileri Bildirim Segmenti (müþteri gerçekse)
   TRBEF                   Sonuç Bilgileri Bildirim Segmenti*/

   --KUNYE VERI DOSYASI

   DELETE FROM prsn.kkb_tzl_01_kunye_veri WHERE 1=1 AND kst_trh = v_tarih;
      COMMIT;

      v_line_no:=3110;

   INSERT               /*+ APPEND */ INTO prsn.kkb_tzl_01_kunye_veri
     SELECT               /*+parallel(x,32) */ ROW_NUMBER () OVER (PARTITION BY x.kst_trh ORDER BY x.kst_trh,
                                                                DECODE (x.tablo_adi,
                                                                                     'trbhf_txt',                     1,
                                                                                     'trbef_txt',                     3,
                                                                                                                      2
                                                                       ),
                                                                CASE WHEN f.kayit_referans_numarasi IS NOT NULL THEN 1 WHEN i.kayit_referans_numarasi IS NOT NULL THEN 2 ELSE 3 END,
                                                                x.kayit_referans_numarasi,
                                                                CASE WHEN x.musteri_no = x.ana_musteri_no THEN 1 ELSE 2 END,
                                                                DECODE (firma_iliski_kodu,
                                                                                           NULL,                       1,
                                                                                           '00',                       2,
                                                                                           '01',                       3,
                                                                                           '02',                       4,
                                                                                           '03',                       5,
                                                                                           '04',                       6,
                                                                                           '06',                       7,
                                                                                           '99',                       8,
                                                                                                                       9
                                                                       )
                                                                ) sira,
            x.kst_trh, 'Künye Veri Dosyasý' dosya_turu, segment_turu, ana_musteri_no, x.musteri_no, vergi_no, tck_no,
            musteri_tip, gercek_tuzel, kontrol_tckn_vkn_f, firma_iliski_kodu, x.kayit_referans_numarasi, tuzel_kisi_ref_no, gercek_kisi_ref_no,
            tablo_adi, kkb_txt
       FROM (

     SELECT TO_DATE (TO_DATE (a.bildirim_tarihi, 'YYYYMMDD'), 'DD/MM/YYYY') kst_trh, a.segment_turu, NULL ana_musteri_no,
            NULL musteri_no, NULL vergi_no, NULL tck_no, NULL musteri_tip, NULL gercek_tuzel, NULL kontrol_tckn_vkn_f,
            NULL firma_iliski_kodu, NULL kayit_referans_numarasi, NULL tuzel_kisi_ref_no, NULL gercek_kisi_ref_no, 'trbhf_txt' tablo_adi,
            (a.rezerv_alan_1 || a.segment_turu || a.versiyon_numarasi || a.uye_kodu || a.veri_turu_kodu_firma || a.bildirim_donemi ||
            a.bildirim_tarihi || a.rezerv_alan_2 || a.rezerv_alan_3) kkb_txt
       FROM prsn.kkb_trbhf_txt a
      WHERE 1 = 1
        AND TO_CHAR (TO_DATE (TO_DATE (a.bildirim_tarihi, 'YYYYMMDD'), 'DD/MM/YYYY'), 'YYYYMMDD') = TO_CHAR (v_tarih, 'YYYYMMDD')
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip, a.gercek_tuzel,
            a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, a.kayit_referans_numarasi, a.tuzel_kisi_ref_no, NULL gercek_kisi_ref_no, 'trbfc_txt' tablo_adi,
            (a.veri_turu_kunye || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.tuzel_kisi_ref_no ||
            a.sube_merkez_il_kodu || a.sube_eft_kodu || a.unvan || a.adres || a.adres_il_kodu || a.adres_ilce_kodu || a.ulke_kodu ||
            a.ticaret_sicil_numarasi || a.mersis_numarasi || a.ticaret_odasi || a.ticaret_tescil_il_kodu || a.ticaret_tescil_merkezi_kodu ||
            a.vergi_dairesi || a.kurulus_tarihi || a.firma_turu_kkb || a.firma_iliski_kodu || a.ilsk_ndn_olan_grc_tzl_refno ||
            a.ilsk_ndn_olan_grc_unvan || a.kredi_iliski_kodu || a.ilsk_baslangic_tarihi || a.ilsk_bitis_tarihi || a.ilsk_gostergesi ||
            a.ortaklik_hisse_orani || a.adres_posta_kod || a.tlf_ulke_kodu || a.tlf_bolge_kodu || a.tlf_numarasi ||
            a.formatli_telefon_numarasi_2 || a.web_adresi || a.e_posta || a.uye_calisma_baslama_tarih || a.calisan_sayisi ||
            a.finansman_konusu_kodu || a.firma_grup_kodu || a.ciro_doviz_kodu || a.ciro_tutari || a.ciro_yili || a.risk_grup_kodu ||
            a.risk_grup_kodu_sebebi || a.grup3_alinma_tarihi || a.grup4_alinma_tarihi || a.grup5_alinma_tarihi || a.nakit_limit ||
            a.gayrinakit_limit || a.firma_genel_limiti || a.grup_limiti || a.grup_riski || a.genel_revize_vadesi || a.son_revize_tarihi ||
            a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbfc_txt a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
        AND a.firma_iliski_kodu NOT IN ('04', '03')
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip, a.gercek_tuzel,
            a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, a.kayit_referans_numarasi, NULL tuzel_kisi_ref_no, a.gercek_kisi_ref_no, 'trbic_txt' tablo_adi,
            (a.veri_turu_kunye || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.gercek_kisi_ref_no ||
            a.sube_eft_kodu || a.sube_merkez_il_kodu || a.firma_iliski_kodu || a.isim || a.ikinci_isim || a.soyad || a.dogum_tarihi ||
            a.kimlik_kod_1 || a.kimlik_no_1 || a.kimlik_kod_2 || a.kimlik_no_2 || a.kimlik_kod_3 || a.kimlik_no_3 || a.kimlik_kod_4 ||
            a.kimlik_no_4 || a.is_adresi || a.is_adresi_il_kodu || a.is_adresi_ilce_kodu || a.ev_adresi || a.ev_adresi_il_kodu ||
            a.ev_adresi_ilce_kodu || a.uyruk || a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.unvan || a.imza_yetkisi_kodu || a.kredi_iliski_kodu ||
            a.ev_adresi_posta_kodu || a.is_adresi_posta_kodu || a.tlf_ulke_kodu || a.tlf_bolge_kodu ||
            a.tlf_numarasi ||               /*a.formatli_telefon_numarasi_2 || */a.ev_tel_formatli_tel_no || a.cep_tel_formatli_tel_no || a.e_posta ||
            a.meslek_kodu || a.meslek || a.egitim_durumu_kodu || a.egitim_durumu || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbic_txt a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
        AND a.firma_iliski_kodu NOT IN ('04', '02')
   UNION ALL
     SELECT v_tarih kst_trh, a.segment_turu, NULL ana_musteri_no, NULL musteri_no, NULL vergi_no, NULL tck_no,
            NULL musteri_tip, NULL gercek_tuzel, NULL kontrol_tckn_vkn_f, NULL firma_iliski_kodu, NULL kayit_referans_numarasi,
            NULL tuzel_kisi_ref_no, NULL gercek_kisi_ref_no, 'trbef_txt' tablo_adi,
            (a.rezerv_alan_1 || a.segment_turu || a.versiyon_numarasi || a.uye_kodu || a.veri_turu_kodu_firma || a.rezerv_alan_2) kkb_txt
       FROM prsn.kkb_trbef_txt a
      WHERE 1 = 1
            AND a.kesit_tarihi = v_tarih
            ) x
            LEFT OUTER JOIN (SELECT DISTINCT kesit_tarihi kst_trh, kayit_referans_numarasi FROM prsn.kkb_trbfc_txt WHERE musteri_no = ana_musteri_no AND kesit_tarihi = v_tarih) f
                            ON     1 = 1
                               AND x.kst_trh = f.kst_trh
                               AND x.kayit_referans_numarasi = f.kayit_referans_numarasi
            LEFT OUTER JOIN (SELECT DISTINCT kesit_tarihi kst_trh, kayit_referans_numarasi FROM prsn.kkb_trbic_txt WHERE musteri_no = ana_musteri_no AND kesit_tarihi = v_tarih) i
                            ON     1 = 1
                               AND x.kst_trh = i.kst_trh
                               AND x.kayit_referans_numarasi = i.kayit_referans_numarasi
      WHERE 1 = 1
                      /*AND (
                 x.ana_musteri_no NOT IN (SELECT musteri_no FROM kkb_musteri_exclude)
              OR x.ana_musteri_no IS NULL
            )*/;


   COMMIT;
   v_line_no:=3125;
   --------------------------------------------------------------------------------

                 /*KREDI VERI DOSYASI    SEGMENT ACIKLAMASI
   TRBHF                   Baþlangýç Bilgileri Bildirim Segmenti
   TRBAC                   Kredi Hesap Bilgileri Bildirim Segmenti
   TRBFC                   Firma Künye Bilgileri Bildirim Segmenti (müþteri tüzelse)
   TRBIC                   Gerçek Kiþi Bilgileri Bildirim Segmenti (müþteri gerçekse)
   --TRBHG                   Kredi Geçmiþ Ödeme Performansý Bilgileri Bildirim Segmenti
   TRBIP                   Kredi Geri Ödeme Bilgileri Bildirim Segmenti.
   TRBGR                   Teminat-Ödeme Aracý Bilgileri Bildirim Segmenti
   TRBFC                   Firma Künye Bilgileri Bildirim Segmenti (teminatý kefilse ve tüzelse)
   TRBIC                   Gerçek Kiþi Bilgileri Bildirim Segmenti (teminatý kefilse ve gerçekse)
   TRBEF                   Sonuç Bilgileri Bildirim Segmenti*/

   --KREDI VERI DOSYASI

   DELETE FROM prsn.kkb_tzl_02_kredi_veri_ayl WHERE 1=1 AND kst_trh = v_tarih;
   COMMIT;
   v_line_no:=3120;

   INSERT               /*+ APPEND */ INTO prsn.kkb_tzl_02_kredi_veri_ayl
     SELECT               /*+parallel(x,32) */ ROW_NUMBER () OVER (PARTITION BY x.kst_trh ORDER BY x.kst_trh,
                                                                DECODE (x.tablo_adi,
                                                                                     'trbhf_txt',                     1,
                                                                                     'trbef_txt',                     3,
                                                                                                                      2
                                                                       ),
                                                                referans,
                                                                CASE WHEN f.musteri_no > 0 THEN 1 WHEN i.musteri_no > 0 THEN 2 ELSE 3 END,
                                                                x.musteri_no,
                                                                DECODE (tablo_adi,
                                                                                       'trbhf_txt',                     1,
                                                                                       'trbac_txt_kredi',                     2,
                                                                                       'trbfc_txt',                     3,
                                                                                       'trbfc_txt_kredi',               4,
                                                                                       'trbic_txt',                     5,
                                                                                       'trbic_txt_kredi',               6,
                                                                                       'trbhg_txt',                     7,
                                                                                       'trbhg_txt_kredi',               8,
                                                                                       'trbip_txt',                     9,
                                                                                       'trbip_txt_kredi',               10,
                                                                                       'trbgr_txt',                     11,
                                                                                       'trbgr_txt_kredi',               12,
                                                                                       'trbgr_sonrasi_trbfc_txt',       13,
                                                                                       'trbgr_sonrasi_trbfc_txt_kredi', 14,
                                                                                       'trbgr_sonrasi_trbic_txt',       15,
                                                                                       'trbgr_sonrasi_trbic_txt_kredi', 16,
                                                                                       'trbef_txt',                     17
                                                                      ),
                                                                DECODE (firma_iliski_kodu,
                                                                                           NULL,                      1,
                                                                                          '00',                       2,
                                                                                          '01',                       3,
                                                                                          '02',                       4,
                                                                                          '03',                       5,
                                                                                          '04',                       6,
                                                                                          '06',                       7,
                                                                                          '99',                       8,
                                                                                                                      9
                                                                       ),
                                                                x.musteri_no, ana_musteri_no
                                                                ) sira,
            x.kst_trh, 'Kredi Veri Dosyasý' dosya_turu, segment_turu, ana_musteri_no, x.musteri_no, vergi_no, tck_no,
            musteri_tip, gercek_tuzel, kontrol_tckn_vkn_f, firma_iliski_kodu, tip, refsube, reftur, refsirano, referans,
            kayit_referans_numarasi, kredi_hesap_ref_no, tuzel_kisi_ref_no, gercek_kisi_ref_no, tmnt_referans, teminat_cesidi,
            teminat_turu_kodu, teminat_turu_kodu_ing, teminat_turu_acklm_ing, tablo_adi, kkb_txt
       FROM (

     SELECT TO_DATE (TO_DATE (a.bildirim_tarihi, 'YYYYMMDD'), 'DD/MM/YYYY') kst_trh, a.segment_turu, NULL ana_musteri_no,
            NULL musteri_no, NULL vergi_no, NULL tck_no, NULL musteri_tip, NULL gercek_tuzel, NULL kontrol_tckn_vkn_f,
            NULL firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur, NULL refsirano, NULL referans,
            NULL kayit_referans_numarasi, NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no, NULL gercek_kisi_ref_no,
            NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing,
            NULL teminat_turu_acklm_ing, 'trbhf_txt' tablo_adi,
            (a.rezerv_alan_1 || a.segment_turu || a.versiyon_numarasi || a.uye_kodu || a.veri_turu_kodu_kredi || a.bildirim_donemi ||
            a.bildirim_tarihi || a.rezerv_alan_2 || a.rezerv_alan_3) kkb_txt
       FROM prsn.kkb_trbhf_txt a
      WHERE 1 = 1
        AND TO_CHAR (TO_DATE (TO_DATE (a.bildirim_tarihi, 'YYYYMMDD'), 'DD/MM/YYYY'), 'YYYYMMDD') = TO_CHAR (v_tarih, 'YYYYMMDD')
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kst_trh, a.segment_turu, a.musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip, a.gercek_tuzel,
            a.kontrol_tckn_vkn_f, '00' firma_iliski_kodu, a.tip, a.refsube, a.reftur, a.refsirano,
            a.refsube || a.reftur || a.refsirano || CASE WHEN a.tip IN ('KMH', 'MMZC') THEN '-' || a.musteri_no END referans,
            a.kayit_referans_no kayit_referans_numarasi, a.kredi_hesap_ref_no, a.tuzel_gercek_ref_no tuzel_kisi_ref_no,
            NULL gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu,
            NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, 'trbac_txt_kredi' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_no || a.segment_turu || a.versiyon_numarasi ||
            a.kredi_hesap_ref_no || a.tuzel_gercek_ref_no || a.sube_merkez_ilkodu || a.sube_eft_kodu || a.defteri_kebir_hsp_no ||
            a.kredi_turu_kod || a.doviz_kodu_kkb || a.kullandirim_doviz_kodu_kkb || a.ilk_kullandirim_tarihi || a.son_kullandirim_tarihi ||
            a.acilis_ilk_kullandirim_tutari || a.vade_tarihi || a.muhatap_ulke_kodu || a.muhatap || a.muhatap_vkn || a.muhatap_tckn ||
            a.hesap_kapanis_tarihi || a.grup3_alinma_tutari || a.grup4_alinma_tutari || a.grup5_alinma_tutari || a.donem_sonu_gecikme ||
            a.donemici_enbuyuk_gecikme || a.hesabin_ozel_durum_kodu || a.kredi_eski_hsp_no || a.tutar1 || a.tutar2 || a.tutar3 ||
            a.tutar4 || a.tutar5 || a.tutar6 || a.odeme_plani_durum_kodu || a.rezerv_alan) kkb_txt
       FROM prsn.kkb_trbac_txt_krd a
      WHERE 1 = 1
        AND a.kst_trh = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, a.tip, a.refsube, a.reftur, a.refsirano,
            a.refsube || a.reftur || a.refsirano || CASE WHEN a.tip IN ('KMH', 'MMZC') THEN '-' || a.ana_musteri_no END referans,
            a.kayit_referans_numarasi, NULL kredi_hesap_ref_no, a.tuzel_kisi_ref_no,
            NULL gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu,
            NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, 'trbfc_txt_kredi' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.tuzel_kisi_ref_no ||
            a.sube_merkez_il_kodu || a.sube_eft_kodu || a.unvan || a.adres || a.adres_il_kodu || a.adres_ilce_kodu || a.ulke_kodu ||
            a.ticaret_sicil_numarasi || a.mersis_numarasi || a.ticaret_odasi || a.ticaret_tescil_il_kodu ||
            a.ticaret_tescil_merkezi_kodu || a.vergi_dairesi || a.kurulus_tarihi || a.firma_turu_kkb || a.firma_iliski_kodu ||
            a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.kredi_iliski_kodu || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.adres_posta_kod || a.tlf_ulke_kodu ||
            a.tlf_bolge_kodu || a.tlf_numarasi || a.formatli_telefon_numarasi_2 || a.web_adresi || a.e_posta ||
            a.uye_calisma_baslama_tarih || a.calisan_sayisi || a.finansman_konusu_kodu || a.firma_grup_kodu || a.ciro_doviz_kodu ||
            a.ciro_tutari || a.ciro_yili || a.risk_grup_kodu || a.risk_grup_kodu_sebebi || a.grup3_alinma_tarihi ||
            a.grup4_alinma_tarihi || a.grup5_alinma_tarihi || a.nakit_limit || a.gayrinakit_limit || a.firma_genel_limiti ||
            a.grup_limiti || a.grup_riski || a.genel_revize_vadesi || a.son_revize_tarihi || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbfc_txt_krd a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
        AND a.firma_iliski_kodu = '00'
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, a.tip, a.refsube, a.reftur, a.refsirano,
            a.refsube || a.reftur || a.refsirano || CASE WHEN a.tip IN ('KMH', 'MMZC') THEN '-' || a.ana_musteri_no END referans,
            a.kayit_referans_numarasi, NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no,
            a.gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu,
            NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, 'trbic_txt_kredi' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.gercek_kisi_ref_no ||
            a.sube_eft_kodu || a.sube_merkez_il_kodu || a.firma_iliski_kodu || a.isim || a.ikinci_isim || a.soyad || a.dogum_tarihi ||
            a.kimlik_kod_1 || a.kimlik_no_1 || a.kimlik_kod_2 || a.kimlik_no_2 || a.kimlik_kod_3 || a.kimlik_no_3 || a.kimlik_kod_4 ||
            a.kimlik_no_4 || a.is_adresi || a.is_adresi_il_kodu || a.is_adresi_ilce_kodu || a.ev_adresi || a.ev_adresi_il_kodu ||
            a.ev_adresi_ilce_kodu || a.uyruk || a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.unvan || a.imza_yetkisi_kodu || a.kredi_iliski_kodu ||
            a.ev_adresi_posta_kodu || a.is_adresi_posta_kodu || a.tlf_ulke_kodu || a.tlf_bolge_kodu || a.tlf_numarasi ||
                          /*a.formatli_telefon_numarasi_2 || */a.ev_tel_formatli_tel_no || a.cep_tel_formatli_tel_no || a.e_posta || a.meslek_kodu ||
            a.meslek || a.egitim_durumu_kodu || a.egitim_durumu || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbic_txt_krd a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
        AND a.firma_iliski_kodu = '00'
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, '00' firma_iliski_kodu, a.tip, a.refsube, a.reftur, a.refsirano,
            a.refsube || a.reftur || a.refsirano || CASE WHEN a.tip IN ('KMH', 'MMZC') THEN '-' || a.musteri_no END referans,
            LPAD (
                  CASE WHEN a.tip IN ('KMH', 'MMZC') THEN a.refsube || a.musteri_no || a.reftur || a.refsirano
                            ELSE a.refsube || a.reftur || a.refsirano
                                 END,
                                      20, '0'
                 ) kayit_referans_numarasi,
            a.kredi_hesabi_ref_no kredi_hesap_ref_no, NULL tuzel_kisi_ref_no,
            NULL gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu,
            NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, 'trbip_txt_kredi' tablo_adi,
            (a.veri_etiketi || a.segment_turu || a.versiyon_numarasi || a.kredi_hesabi_ref_no || a.rezerv_alan_1 || a.odeme_vadesi ||
            a.odemenin_yapildigi_tarih || a.odenmesi_gereken_tutar || a.rezerv_alan_2) kkb_txt
       FROM prsn.kkb_trbip_txt_krd a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, '00' firma_iliski_kodu, a.tip, a.krdsube refsube, a.krdreftur reftur, a.krdrefsirano refsirano,
            a.krd_referans referans, a.kayit_referans_numarasi_krd kayit_referans_numarasi, a.kredi_hesabi_referans_numarasi kredi_hesap_ref_no,
            CASE WHEN a.vergi_no IS NOT NULL THEN a.tuzel_gercek_ref_no_teminat ELSE NULL END tuzel_kisi_ref_no,
            CASE WHEN a.tck_no IS NOT NULL THEN a.tuzel_gercek_ref_no_teminat ELSE NULL END gercek_kisi_ref_no,
            a.tmnt_referans, a.teminat_cesidi, a.teminat_turu_kodu, a.teminat_turu_kodu_ing,
            a.teminat_turu_acklm_ing, 'trbgr_txt_kredi' tablo_adi,
            (a.veri_turu_kredi || a.uye_kodu || a.kayit_referans_numarasi_krd || a.segment_turu || a.versiyon_numarasi ||
            a.sube_merkez_ilkodu || a.sube_eft_kodu || a.teminat_referans_numarasi || a.kredi_hesabi_referans_numarasi ||
            a.tuzel_gercek_ref_no_teminat || a.teminat_turu_kodu || a.teminat_degeri || a.tmnt_alindigi_trh ||
            a.son_degerleme_trh || a.doviz_kodu || a.piyasa_ekspertiz_degeri || a.teminat_aktif_pasif_kodu || a.cek_senet_adedi ||
            a.kefil_adet || a.kefalet_miktari || a.rezerv_alan_1) kkb_txt
       FROM prsn.kkb_trbgr_txt_krd a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, a.tip, a.krdsube refsube, a.krdreftur reftur, a.krdrefsirano refsirano,
            a.krd_referans referans, a.kayit_referans_numarasi_krd, NULL kredi_hesap_ref_no,
            a.tzl_kisi_ref_no tuzel_kisi_ref_no, NULL gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi,
            NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, 'trbgr_sonrasi_trbfc_txt_kredi' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_numarasi_krd || a.segment_turu || a.versiyon_numarasi || a.tzl_kisi_ref_no ||
            a.sube_merkez_il_kodu || a.sube_eft_kodu || a.unvan || a.adres || a.adres_il_kodu || a.adres_ilce_kodu || a.ulke_kodu ||
            a.ticaret_sicil_numarasi || a.mersis_numarasi || a.ticaret_odasi || a.ticaret_tescil_il_kodu ||
            a.ticaret_tescil_merkezi_kodu || a.vergi_dairesi || a.kurulus_tarihi || a.firma_turu_kkb || a.firma_iliski_kodu ||
            a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.kredi_iliski_kodu || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.adres_posta_kod || a.tlf_ulke_kodu ||
            a.tlf_bolge_kodu || a.tlf_numarasi || a.formatli_telefon_numarasi_2 || a.web_adresi || a.e_posta ||
            a.uye_calisma_baslama_tarih || a.calisan_sayisi || a.finansman_konusu_kodu || a.firma_grup_kodu || a.ciro_doviz_kodu ||
            a.ciro_tutari || a.ciro_yili || a.risk_grup_kodu || a.risk_grup_kodu_sebebi || a.grup3_alinma_tarihi ||
            a.grup4_alinma_tarihi || a.grup5_alinma_tarihi || a.nakit_limit || a.gayrinakit_limit || a.firma_genel_limiti ||
            a.grup_limiti || a.grup_riski || a.genel_revize_vadesi || a.son_revize_tarihi || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbgr_sonrs_trbfc_txt_krd a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, a.tip, a.krdsube refsube, a.krdreftur reftur, a.krdrefsirano refsirano,
            a.krd_referans referans, a.kayit_referans_numarasi_krd kayit_referans_numarasi, NULL kredi_hesap_ref_no,
            NULL tuzel_kisi_ref_no, a.gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi,
            NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, 'trbgr_sonrasi_trbic_txt_kredi' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_numarasi_krd || a.segment_turu || a.versiyon_numarasi || a.gercek_kisi_ref_no ||
            a.sube_eft_kodu || a.sube_merkez_il_kodu || a.firma_iliski_kodu || a.isim || a.ikinci_isim || a.soyad || a.dogum_tarihi ||
            a.kimlik_kod_1 || a.kimlik_no_1 || a.kimlik_kod_2 || a.kimlik_no_2 || a.kimlik_kod_3 || a.kimlik_no_3 || a.kimlik_kod_4 ||
            a.kimlik_no_4 || a.is_adresi || a.is_adresi_il_kodu || a.is_adresi_ilce_kodu || a.ev_adresi || a.ev_adresi_il_kodu ||
            a.ev_adresi_ilce_kodu || a.uyruk || a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.unvan || a.imza_yetkisi_kodu || a.kredi_iliski_kodu ||
            a.ev_adresi_posta_kodu || a.is_adresi_posta_kodu || a.tlf_ulke_kodu || a.tlf_bolge_kodu || a.tlf_numarasi ||
                          /*a.formatli_telefon_numarasi_2 || */a.ev_tel_formatli_tel_no || a.cep_tel_formatli_tel_no || a.e_posta || a.meslek_kodu ||
            a.meslek || a.egitim_durumu_kodu || a.egitim_durumu || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbgr_sonrs_trbic_txt_krd a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT v_tarih kst_trh, a.segment_turu, NULL ana_musteri_no, NULL musteri_no, NULL vergi_no, NULL tck_no,
            NULL musteri_tip, NULL gercek_tuzel, NULL kontrol_tckn_vkn_f, NULL firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur,
            NULL refsirano, NULL referans, NULL kayit_referans_numarasi, NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no,
            NULL gercek_kisi_ref_no, NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing,
            NULL teminat_turu_acklm_ing, 'trbef_txt' tablo_adi,
            (a.rezerv_alan_1 || a.segment_turu || a.versiyon_numarasi || a.uye_kodu || a.veri_turu_kodu_kredi || a.rezerv_alan_2) kkb_txt
       FROM prsn.kkb_trbef_txt a
      WHERE 1 = 1
            AND a.kesit_tarihi = v_tarih

            ) x
            LEFT OUTER JOIN (SELECT DISTINCT kesit_tarihi kst_trh, musteri_no FROM prsn.kkb_trbfc_txt WHERE musteri_no > 0 AND kesit_tarihi = v_tarih) f
                            ON     1 = 1
                               AND x.kst_trh = f.kst_trh
                               AND x.ana_musteri_no = f.musteri_no
            LEFT OUTER JOIN (SELECT DISTINCT kesit_tarihi kst_trh, musteri_no FROM prsn.kkb_trbic_txt WHERE musteri_no > 0 AND kesit_tarihi = v_tarih) i
                            ON     1 = 1
                               AND x.kst_trh = i.kst_trh
                               AND x.ana_musteri_no = i.musteri_no
      WHERE 1 = 1
                      /*AND (
                 x.ana_musteri_no NOT IN (SELECT musteri_no FROM kkb_musteri_exclude)
              OR x.ana_musteri_no IS NULL
            )*/;

      COMMIT;
      v_line_no:=3125;
   --------------------------------------------------------------------------------

                 /*TEMINAT VERI DOSYASI  SEGMENT ACIKLAMASI
   TRBHF                   Baþlangýç Bilgileri Bildirim Segmenti
   TRBFC                   Firma Künye Bilgileri Bildirim Segmenti (müþteri tüzelse)
   TRBIC                   Gerçek Kiþi Bilgileri Bildirim Segmenti (müþteri gerçekse)
   TRBGR                   Teminat-Ödeme Aracý Bilgileri Bildirim Segmenti
   TRBFC                   Firma Künye Bilgileri Bildirim Segmenti (teminatý kefilse ve tüzelse)
   TRBIC                   Gerçek Kiþi Bilgileri Bildirim Segmenti (teminatý kefilse ve gerçekse)
   TRBEF                   Sonuç Bilgileri Bildirim Segmenti*/

   --TEMINAT VERI DOSYASI

   DELETE FROM prsn.kkb_tzl_03_tmnt_veri WHERE 1=1 AND kst_trh = v_tarih;
   COMMIT;
   v_line_no:=3130;

   INSERT               /*+ APPEND */ INTO prsn.kkb_tzl_03_tmnt_veri
     SELECT               /*+parallel(x,32) */
            ROW_NUMBER () OVER (PARTITION BY kst_trh ORDER BY kst_trh,
            DECODE (tablo_adi,
                                  'trbhf_txt',                     1,
                                  'trbef_txt',                     3,
                                                                   2
                   ),
            kayit_referans_numarasi,
            DECODE (tablo_adi,
                                  'trbfc_txt',                     1,
                                  'trbic_txt',                     2,
                                  'trbhg_txt',                     3,
                                  'trbip_txt',                     4,
                                                                   5
                   ),
            tmnt_referans, teminat_turu_kodu,
            DECODE (firma_iliski_kodu,
                                       NULL,                       1,
                                       '00',                       2,
                                       '01',                       3,
                                       '02',                       4,
                                       '03',                       5,
                                       '04',                       6,
                                       '06',                       7,
                                       '99',                       8,
                                                                   9
                   ),
            musteri_no
            ) sira,
            kst_trh, 'Teminat Veri Dosyasý' dosya_turu, segment_turu, ana_musteri_no, musteri_no, vergi_no, tck_no, musteri_tip,
            gercek_tuzel, kontrol_tckn_vkn_f, firma_iliski_kodu, tip, refsube, reftur, refsirano, referans, tmnt_referans, teminat_cesidi,
            teminat_turu_kodu, teminat_turu_kodu_ing, teminat_turu_acklm_ing, kayit_referans_numarasi, kredi_hesap_ref_no,
            tuzel_kisi_ref_no, gercek_kisi_ref_no, tablo_adi, kkb_txt
       FROM (

     SELECT TO_DATE (TO_DATE (a.bildirim_tarihi, 'YYYYMMDD'), 'DD/MM/YYYY') kst_trh, a.segment_turu, NULL ana_musteri_no,
            NULL musteri_no, NULL vergi_no, NULL tck_no, NULL musteri_tip, NULL gercek_tuzel, NULL kontrol_tckn_vkn_f,
            NULL firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur, NULL refsirano, NULL referans, NULL tmnt_referans,
            NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing,
            NULL kayit_referans_numarasi, NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no, NULL gercek_kisi_ref_no, 'trbhf_txt' tablo_adi,
            (a.rezerv_alan_1 || a.segment_turu || a.versiyon_numarasi || a.uye_kodu || a.veri_turu_kodu_teminat || a.bildirim_donemi ||
            a.bildirim_tarihi || a.rezerv_alan_2 || a.rezerv_alan_3) kkb_txt
       FROM prsn.kkb_trbhf_txt a
      WHERE 1 = 1
        AND TO_CHAR (TO_DATE (TO_DATE (a.bildirim_tarihi, 'YYYYMMDD'), 'DD/MM/YYYY'), 'YYYYMMDD') = TO_CHAR (v_tarih, 'YYYYMMDD')
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip, a.gercek_tuzel,
            a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur, NULL refsirano, NULL referans, NULL tmnt_referans,
            NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, a.kayit_referans_numarasi,
            NULL kredi_hesap_ref_no, a.tuzel_kisi_ref_no, NULL gercek_kisi_ref_no, 'trbfc_txt' tablo_adi,
            (a.veri_turu_teminat || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.tuzel_kisi_ref_no ||
            a.sube_merkez_il_kodu || a.sube_eft_kodu || a.unvan || a.adres || a.adres_il_kodu || a.adres_ilce_kodu || a.ulke_kodu ||
            a.ticaret_sicil_numarasi || a.mersis_numarasi || a.ticaret_odasi || a.ticaret_tescil_il_kodu || a.ticaret_tescil_merkezi_kodu ||
            a.vergi_dairesi || a.kurulus_tarihi || a.firma_turu_kkb || a.firma_iliski_kodu || a.ilsk_ndn_olan_grc_tzl_refno ||
            a.ilsk_ndn_olan_grc_unvan || a.kredi_iliski_kodu || a.ilsk_baslangic_tarihi || a.ilsk_bitis_tarihi || a.ilsk_gostergesi ||
            a.ortaklik_hisse_orani || a.adres_posta_kod || a.tlf_ulke_kodu || a.tlf_bolge_kodu || a.tlf_numarasi ||
            a.formatli_telefon_numarasi_2 || a.web_adresi || a.e_posta || a.uye_calisma_baslama_tarih || a.calisan_sayisi ||
            a.finansman_konusu_kodu || a.firma_grup_kodu || a.ciro_doviz_kodu || a.ciro_tutari || a.ciro_yili || a.risk_grup_kodu ||
            a.risk_grup_kodu_sebebi || a.grup3_alinma_tarihi || a.grup4_alinma_tarihi || a.grup5_alinma_tarihi || a.nakit_limit ||
            a.gayrinakit_limit || a.firma_genel_limiti || a.grup_limiti || a.grup_riski || a.genel_revize_vadesi || a.son_revize_tarihi ||
            a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbfc_txt a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
        AND a.ana_musteri_no IN (SELECT DISTINCT musteri_no FROM prsn.kkb_trbgr_txt WHERE kesit_tarihi = v_tarih)
        AND a.firma_iliski_kodu = '00'
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip, a.gercek_tuzel,
            a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur, NULL refsirano, NULL referans, NULL tmnt_referans,
            NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing, a.kayit_referans_numarasi,
            NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no, a.gercek_kisi_ref_no, 'trbic_txt' tablo_adi,
            (a.veri_turu_teminat || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.gercek_kisi_ref_no ||
            a.sube_eft_kodu || a.sube_merkez_il_kodu || a.firma_iliski_kodu || a.isim || a.ikinci_isim || a.soyad || a.dogum_tarihi ||
            a.kimlik_kod_1 || a.kimlik_no_1 || a.kimlik_kod_2 || a.kimlik_no_2 || a.kimlik_kod_3 || a.kimlik_no_3 || a.kimlik_kod_4 ||
            a.kimlik_no_4 || a.is_adresi || a.is_adresi_il_kodu || a.is_adresi_ilce_kodu || a.ev_adresi || a.ev_adresi_il_kodu ||
            a.ev_adresi_ilce_kodu || a.uyruk || a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.unvan || a.imza_yetkisi_kodu || a.kredi_iliski_kodu ||
            a.ev_adresi_posta_kodu || a.is_adresi_posta_kodu || a.tlf_ulke_kodu || a.tlf_bolge_kodu || a.tlf_numarasi ||
                          /*a.formatli_telefon_numarasi_2 || */a.ev_tel_formatli_tel_no || a.cep_tel_formatli_tel_no || a.e_posta || a.meslek_kodu ||
            a.meslek || a.egitim_durumu_kodu || a.egitim_durumu || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbic_txt a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
        AND a.ana_musteri_no IN (SELECT DISTINCT musteri_no FROM prsn.kkb_trbgr_txt WHERE kesit_tarihi = v_tarih)
        AND a.firma_iliski_kodu = '00'
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, '00' firma_iliski_kodu, a.tip, a.krdsube refsube, a.krdreftur reftur, a.krdrefsirano refsirano,
            a.krd_referans referans, a.tmnt_referans, a.teminat_cesidi, a.teminat_turu_kodu, a.teminat_turu_kodu_ing,
            a.teminat_turu_acklm_ing, a.kayit_referans_numarasi_tmnt kayit_referans_numarasi, a.kredi_hesabi_referans_numarasi kredi_hesap_ref_no,
            CASE WHEN a.vergi_no IS NOT NULL THEN a.tuzel_gercek_ref_no_teminat ELSE NULL END tuzel_kisi_ref_no,
            CASE WHEN a.tck_no IS NOT NULL THEN a.tuzel_gercek_ref_no_teminat ELSE NULL END gercek_kisi_ref_no,
            'trbgr_txt' tablo_adi,
            (a.veri_turu_teminat || a.uye_kodu || a.kayit_referans_numarasi_tmnt || a.segment_turu || a.versiyon_numarasi ||
            a.sube_merkez_ilkodu || a.sube_eft_kodu || a.teminat_referans_numarasi || a.kredi_hesabi_referans_numarasi ||
            a.tuzel_gercek_ref_no_teminat || a.teminat_turu_kodu || a.teminat_degeri || a.tmnt_alindigi_trh ||
            a.son_degerleme_trh || a.doviz_kodu || a.piyasa_ekspertiz_degeri || a.teminat_aktif_pasif_kodu || a.cek_senet_adedi ||
            a.kefil_adet || a.kefalet_miktari || a.rezerv_alan_1) kkb_txt
       FROM prsn.kkb_trbgr_txt a
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no,
            a.musteri_tip, a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur, NULL refsirano,
            NULL referans, aa.tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing,
            NULL teminat_turu_acklm_ing, a.kayit_referans_numarasi, NULL kredi_hesap_ref_no, a.tzl_kisi_ref_no tuzel_kisi_ref_no,
            NULL gercek_kisi_ref_no, 'trbgr_sonrasi_trbfc_txt' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.tzl_kisi_ref_no ||
            a.sube_merkez_il_kodu || a.sube_eft_kodu || a.unvan || a.adres || a.adres_il_kodu || a.adres_ilce_kodu || a.ulke_kodu ||
            a.ticaret_sicil_numarasi || a.mersis_numarasi || a.ticaret_odasi || a.ticaret_tescil_il_kodu ||
            a.ticaret_tescil_merkezi_kodu || a.vergi_dairesi || a.kurulus_tarihi || a.firma_turu_kkb || a.firma_iliski_kodu ||
            a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.kredi_iliski_kodu || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.adres_posta_kod || a.tlf_ulke_kodu ||
            a.tlf_bolge_kodu || a.tlf_numarasi || a.formatli_telefon_numarasi_2 || a.web_adresi || a.e_posta ||
            a.uye_calisma_baslama_tarih || a.calisan_sayisi || a.finansman_konusu_kodu || a.firma_grup_kodu || a.ciro_doviz_kodu ||
            a.ciro_tutari || a.ciro_yili || a.risk_grup_kodu || a.risk_grup_kodu_sebebi || a.grup3_alinma_tarihi ||
            a.grup4_alinma_tarihi || a.grup5_alinma_tarihi || a.nakit_limit || a.gayrinakit_limit || a.firma_genel_limiti ||
            a.grup_limiti || a.grup_riski || a.genel_revize_vadesi || a.son_revize_tarihi || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbgr_sonrs_trbfc_txt a
            INNER JOIN prsn.kkb_trbgr_txt aa ON a.kesit_tarihi = aa.kesit_tarihi AND a.tmnt_referans = aa.tmnt_referans AND aa.teminat_turu_kodu = '45'
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT a.kesit_tarihi kst_trh, a.segment_turu, a.ana_musteri_no ana_musteri_no, a.musteri_no, a.vergi_no, a.tck_no, a.musteri_tip,
            a.gercek_tuzel, a.kontrol_tckn_vkn_f, a.firma_iliski_kodu, NULL referans, NULL tip, NULL refsube, NULL reftur, NULL refsirano,
            aa.tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing, NULL teminat_turu_acklm_ing,
            a.kayit_referans_numarasi, NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no, a.gercek_kisi_ref_no, 'trbgr_sonrasi_trbic_txt' tablo_adi,
            (a.veri_turu || a.uye_kodu || a.kayit_referans_numarasi || a.segment_turu || a.versiyon_numarasi || a.gercek_kisi_ref_no ||
            a.sube_eft_kodu || a.sube_merkez_il_kodu || a.firma_iliski_kodu || a.isim || a.ikinci_isim || a.soyad || a.dogum_tarihi ||
            a.kimlik_kod_1 || a.kimlik_no_1 || a.kimlik_kod_2 || a.kimlik_no_2 || a.kimlik_kod_3 || a.kimlik_no_3 || a.kimlik_kod_4 ||
            a.kimlik_no_4 || a.is_adresi || a.is_adresi_il_kodu || a.is_adresi_ilce_kodu || a.ev_adresi || a.ev_adresi_il_kodu ||
            a.ev_adresi_ilce_kodu || a.uyruk || a.ilsk_ndn_olan_grc_tzl_refno || a.ilsk_ndn_olan_grc_unvan || a.ilsk_baslangic_tarihi ||
            a.ilsk_bitis_tarihi || a.ilsk_gostergesi || a.ortaklik_hisse_orani || a.unvan || a.imza_yetkisi_kodu || a.kredi_iliski_kodu ||
            a.ev_adresi_posta_kodu || a.is_adresi_posta_kodu || a.tlf_ulke_kodu || a.tlf_bolge_kodu || a.tlf_numarasi ||
                          /*a.formatli_telefon_numarasi_2 || */a.ev_tel_formatli_tel_no || a.cep_tel_formatli_tel_no || a.e_posta || a.meslek_kodu ||
            a.meslek || a.egitim_durumu_kodu || a.egitim_durumu || a.rezerv_alan1) kkb_txt
       FROM prsn.kkb_trbgr_sonrs_trbic_txt a
            INNER JOIN prsn.kkb_trbgr_txt aa ON a.kesit_tarihi = aa.kesit_tarihi AND a.tmnt_referans = aa.tmnt_referans AND aa.teminat_turu_kodu = '45'
      WHERE 1 = 1
        AND a.kesit_tarihi = v_tarih
   UNION ALL
     SELECT v_tarih kst_trh, a.segment_turu, NULL ana_musteri_no, NULL musteri_no, NULL vergi_no, NULL tck_no,
            NULL musteri_tip, NULL gercek_tuzel, NULL kontrol_tckn_vkn_f, NULL firma_iliski_kodu, NULL tip, NULL refsube, NULL reftur,
            NULL refsirano, NULL referans, NULL tmnt_referans, NULL teminat_cesidi, NULL teminat_turu_kodu, NULL teminat_turu_kodu_ing,
            NULL teminat_turu_acklm_ing, NULL kayit_referans_numarasi, NULL kredi_hesap_ref_no, NULL tuzel_kisi_ref_no, NULL gercek_kisi_ref_no,
            'trbef_txt' tablo_adi,
            (a.rezerv_alan_1 || a.segment_turu || a.versiyon_numarasi || a.uye_kodu || a.veri_turu_kodu_teminat ||
            a.rezerv_alan_2) kkb_txt
       FROM prsn.kkb_trbef_txt a
      WHERE 1 = 1
            AND a.kesit_tarihi = v_tarih

            ) x
      WHERE 1 = 1
                      /*AND (
                 x.ana_musteri_no NOT IN (SELECT musteri_no FROM kkb_musteri_exclude)
              OR x.ana_musteri_no IS NULL
            )*/;

   COMMIT;
   v_line_no:=3135;


   etl.pkg_util_lib.prc_log_end;


   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_tkkb_rapor_gonderim_sorgu;

   PROCEDURE sp_kkb_export (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1)) IS

      v_tarih             DATE;
      v_sqlcode           NUMBER   (10);
      v_sqlcodeexp        VARCHAR2 (200);
      v_sp_name           VARCHAR2 (40) := 'SP_KKB_EXPORT';
      v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
      v_line_no           NUMBER        := 3200;

      v_file_name         VARCHAR2(100);
      fid                 utl_file.file_type;
      v_max_linesize      NUMBER        := 1500;

   BEGIN

      etl.pkg_util_lib.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

      v_tarih := TRUNC(p_tarih);
      v_line_no:=3210;

      <<kunye_veri_dosyasi>>
      BEGIN
         v_file_name:='YENI_GUN'||TO_CHAR(v_tarih,'YYYYMMDD')||'_V10_01.TXT';

         fid := utl_file.fopen('TMP_DIR',v_file_name,'W',v_max_linesize);
         v_line_no:=3212;

         FOR i IN (
            SELECT kkb_txt FROM prsn.kkb_tzl_01_kunye_veri WHERE 1=1 AND kst_trh = v_tarih ORDER BY sira
         )
         LOOP
            utl_file.put_line(fid, i.kkb_txt);
         END LOOP;

         v_line_no:=3214;
         utl_file.fclose(fid);
      END kunye_veri_dosyasi;

      v_line_no:=3216;

      <<kredi_veri_dosyasi>>
      BEGIN
         v_file_name:='YENI_GUN'||TO_CHAR(v_tarih,'YYYYMMDD')||'_V30_01.TXT';

         fid := utl_file.fopen('TMP_DIR',v_file_name,'W',v_max_linesize);
         v_line_no:=3218;

         FOR i IN (
            SELECT kkb_txt FROM prsn.kkb_tzl_02_kredi_veri_ayl WHERE 1=1 AND kst_trh = v_tarih ORDER BY sira
         )
         LOOP
            utl_file.put_line(fid,i.kkb_txt);
         END LOOP;

         v_line_no:=3220;
         utl_file.fclose(fid);
      END kredi_veri_dosyasi;

      v_line_no:=3222;

      <<teminat_veri_dosyasi>>
      BEGIN
         v_file_name:='YENI_GUN'||TO_CHAR(v_tarih,'YYYYMMDD')||'_V32_01.TXT';

         fid := UTL_FILE.FOPEN('TMP_DIR',v_file_name,'W',v_max_linesize);
         v_line_no:=3224;

         FOR i IN (
            SELECT kkb_txt FROM prsn.kkb_tzl_03_tmnt_veri WHERE 1=1 AND kst_trh = v_tarih ORDER BY sira
         )
         LOOP
            utl_file.put_line(fid,i.kkb_txt);
         END LOOP;

         v_line_no:=3226;
         UTL_FILE.FCLOSE(fid);
      END teminat_veri_dosyasi;

      v_line_no:=3228;

   etl.pkg_util_lib.prc_log_end;

   EXCEPTION WHEN OTHERS THEN

      v_SqlCode := SQLCODE;
      v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);
      etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

      RAISE;
   END sp_kkb_export;

END pkg_kkb_tzl;
/
