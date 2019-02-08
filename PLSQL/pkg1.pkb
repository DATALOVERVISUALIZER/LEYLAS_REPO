CREATE OR REPLACE PACKAGE BODY DM_INFOMAN.PKG_BDDK_GUN_ICI_LKDT_YNTM AS

    --global variables:
    g_module_name      VARCHAR2 (100):= 'PKG_BDDK_GUN_ICI_LKDT_YNTM';
    g_package_name     VARCHAR2 (40) := 'PKG_BDDK_GUN_ICI_LKDT_YNTM';
    g_owner            VARCHAR2 (40) := 'DM_INFOMAN';
    g_is_restartable   NUMBER (1)    := 1;

                                /*
    Depo_Kod'larýnýn analizi ve iþ birimi : Ozge Turkmen ve Yasemin Genç
    GI100AS'nin analizi ve iþ birimi: Aytaç Guler, Hurkan Karahanoðlu, Handan Mimarbaþý, Ozge Turkmen, Yasemin Genç
    GI101AS'nin analizi ve iþ birimi: Serap Keski Alireisoðlu
    GI102AS'nin analizi ve iþ birimi: Deniz Tümer, Zeynep Arslan, Ýdil Damla Bingöl

    Development: Ýlteriþ Mutlu

    Raporun Focus'taki Gösterimi: /shared/Ortak Raporlar/Fonlama ve Likidite Raporlarý/Raporlar

    Kaynak tablolarýn tamamý historik tablolardan geldiði için paket geriye dönük çalýþtýrýlabilir.

    */

    PROCEDURE SP_MAIN (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) ) IS

        v_tarih             date;
        v_sqlcode           number   (10);
        v_sqlcodeexp        varchar2 (200);
        v_sp_name           varchar2 (40) := 'SP_MAIN';
        v_etl_tarih         VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no           number        := $$PLSQL_LINE;


    BEGIN

        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name, g_package_name, g_owner, v_sp_name,  v_etl_tarih, g_is_restartable);

        v_tarih := NVL(p_tarih, TRUNC(SYSDATE-1));


        PKG_BDDK_GUN_ICI_LKDT_YNTM.SP_DEPO_KOD_005(v_tarih);
        v_line_no := $$PLSQL_LINE;


        FOR tar
        IN (SELECT   date_value
              FROM   prsn.tarih
             WHERE   1=1
                     AND date_value BETWEEN TRUNC(v_tarih,'MM') and v_tarih
           )
        LOOP
           PKG_BDDK_GUN_ICI_LKDT_YNTM.SP_DEPO_KOD_540(tar.date_value);
        END LOOP;


        v_line_no := $$PLSQL_LINE;
        PKG_BDDK_GUN_ICI_LKDT_YNTM.SP_DEPO_KOD_903(v_tarih);
        v_line_no := $$PLSQL_LINE;
        PKG_BDDK_GUN_ICI_LKDT_YNTM.SP_GI100AS(v_tarih);
        v_line_no := $$PLSQL_LINE;
        PKG_BDDK_GUN_ICI_LKDT_YNTM.SP_GI101AS(v_tarih);
        v_line_no := $$PLSQL_LINE;
        PKG_BDDK_GUN_ICI_LKDT_YNTM.SP_GI102AS(v_tarih);
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


    PROCEDURE SP_DEPO_KOD_005 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

        v_tarih            DATE          := TRUNC(p_tarih);
        v_SqlCode          NUMBER (10);
        v_SqlCodeExp       VARCHAR2 (200);
        v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no          NUMBER        :=$$PLSQL_LINE;
        v_sp_name          VARCHAR2 (40) := 'SP_DEPO_KOD_005';

    BEGIN
        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);




        DELETE FROM trfm.DEPO_KOD_HIST
              WHERE 1=1
                    AND depo_hesap_no = '005'
                    AND tarih = v_tarih;
        COMMIT;

        v_line_no := $$PLSQL_LINE;

        INSERT INTO trfm.DEPO_KOD_HIST
         SELECT tarih,
                '005' AS depo_hesap_no,
                'Takasbank B.P.P.' AS Depo_ismi,
                ROUND(tr_cari_tplm,0) as stok_degeri,
                ROUND(alis_limiti_TL,0) AS islem_limiti_tl,
                ROUND(alis_limiti_USD,0) AS islem_limiti_usd,
                ROUND(barrowing_plasma_toplam,0) AS islem_tutari,
                ROUND(dgrleme_katsy_dhl_tem_cari_dgr,0) AS kullanilan_stok_degeri,
                ROUND(dgrlme_katsy_dhl_kllnr_cr_dgr,0) as  kullanýlabilir_stok_degeri,
                ROUND(kullanilabilir_islem_limiti,0) as  kullanilabilir_islem_limiti,
                NULL AS dibs_kullanilablr_islem_limiti,
                NULL AS temnt_dvz_depo_kullblr_tl_lmt,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
        --        hb_dt_degerleme_katsayisi, dt_tr_cari_degeri, teminat_orani, kullanilan_teminat_cari_deger, kllnlblr_alis_islm_tr, kllnlblr_alis_islm_tr_cr_dgr,
           FROM
                (SELECT al.tarih,
                        al.tr_cari_tplm,
                        al.hb_dt_degerleme_katsayisi,
                        al.dt_tr_cari_degeri,
                        al.teminat_orani,
                        al.alis_limiti_TL,
                        al.alis_limiti_TL-al.barrowing_plasma_toplam AS kullanilabilir_islem_limiti,
                        al.alis_limiti_TL/(fd.d_alis*fd.katsayi) AS alis_limiti_USD,
                        al.barrowing_plasma_toplam,
                        al.kullanilan_teminat_cari_deger,
                        NVL(al.kullanilan_teminat_cari_deger/NULLIF(al.hb_dt_degerleme_katsayisi,0),0) as dgrleme_katsy_dhl_tem_cari_dgr,
                        al.alis_limiti_TL-al.barrowing_plasma_toplam as kllnlblr_alis_islm_tr,
                        (al.alis_limiti_TL-al.barrowing_plasma_toplam)*al.teminat_orani/100 as kllnlblr_alis_islm_tr_cr_dgr,
                        NVL(((al.alis_limiti_TL-al.barrowing_plasma_toplam)*al.teminat_orani/100)/NULLIF(al.hb_dt_degerleme_katsayisi,0),0) as dgrlme_katsy_dhl_kllnr_cr_dgr
                   FROM (
                           SELECT c.tarih,
                                  SUM(c.tr_cari) as tr_cari_tplm,
                                  0.91 as hb_dt_degerleme_katsayisi,
                                  SUM(c.tr_cari)* 0.91 as dt_tr_cari_degeri,
                                  te.teminat_oran as teminat_orani,
                                  NVL(((SUM(c.tr_cari)* 0.91)/NULLIF(te.teminat_oran,0)),0)*100 as alis_limiti_TL,
                                  bp.barrowing_plasma_toplam,
                                  bp.barrowing_plasma_toplam AS barrowing_plasma_toplam_dolar,
                                  bp.barrowing_plasma_toplam*(te.teminat_oran/100) as kullanilan_teminat_cari_deger
                             FROM (  SELECT cr.tarih,
                                          cr.isincode,
                                          cr.nominal_tplm,
                                          cr.fiyat,
                                          cr.katsayi,
                                          (cr.nominal_tplm*cr.fiyat)/cr.katsayi as tr_cari
                                     FROM (  SELECT a.tarih,
                                                    a.isincode,
                                                    SUM(a.nominal) as nominal_tplm,
                                                    b.fiyat,
                                                    CASE WHEN t.para <> 0 THEN t.ypkatsayi else t.tlkatsayi END katsayi
                                               FROM extr.FS_MENKULOZET a
                                                    INNER JOIN extr.FS_BONOFIYAT b ON A.TARIH = b.tarih
                                                                                    and a.isincode = b.isincode
                                                                                    and b.islemtip = 1
                                                    INNER JOIN extr.FS_MENKULTANIM t ON A.ISINCODE = t.ISINCODE
                                              WHERE 1=1
                                                    AND a.depokodu = 5
                                                    and a.tarih = v_tarih
                                           GROUP BY a.tarih,a.isincode ,B.FIYAT,case When t.para <> 0 Then t.ypkatsayi else t.tlkatsayi END
                                          ) cr
                                  ) c
                                  INNER JOIN (SELECT NVL(SUM(p.tutar) +SUM(p.brutfaiz),0) as barrowing_plasma_toplam
                                                FROM extr.FS_PLMISL p
                                                     INNER JOIN extr.FS_PLMMUHHESAP h ON p.durum = p.geneldurum
                                                                                      and p.reftur=h.reftur
                                                                                      and p.refnit=h.refnit and p.bankatip=h.bankatip
                                                                                      and p.vadetip=h.vadetip
                                                                                      and p.musilk7=50071
                                                                                      and h.ana=328
                                               WHERE 1=1
                                                     and p.musbnk = 'TVSB'
                                                     and p.valor BETWEEN to_date( '01.01.1995','DD.MM.YYYY') and v_tarih
                                                     and p.vade BETWEEN v_tarih+1 and to_date( '30.12.2099','DD.MM.YYYY')
                                                     and p.para BETWEEN 0 and 9999
                                                     and p.musbolge = 'TR'
                                                     and p.durum <> 9
                                                     and p.reftur = 'BR'
                                             ) bp ON 1=1
                                  LEFT JOIN dep_data.TEMINAT_ORANI te ON c.tarih BETWEEN baslangic_tarih AND NVL(bitis_tarih,TRUNC(SYSDATE) )
                            WHERE 1=1
                         GROUP BY c.tarih, bp.barrowing_plasma_toplam, te.teminat_oran
                        ) al
                        INNER JOIN extr.FS_FDOVIZ fd ON 1=1
                                                    AND fd.kurtipi = 2
                                                    and fd.tarih = al.tarih
                                                    and fd.para = 1
                );

                COMMIT;


        -- END LOG
        ETL.PKG_UTIL_LIB.prc_log_end;

        DBMS_APPLICATION_INFO.set_module(NULL,NULL);

        EXCEPTION WHEN OTHERS THEN
          v_SqlCode := SQLCODE;
          v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

          --FAILURE LOG
          etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

          RAISE;

    END SP_DEPO_KOD_005;




    PROCEDURE SP_DEPO_KOD_540 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

        v_tarih            DATE          := TRUNC(p_tarih);
        v_SqlCode          NUMBER (10);
        v_SqlCodeExp       VARCHAR2 (200);
        v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no          NUMBER        := $$PLSQL_LINE;
        v_sp_name          VARCHAR2 (40) := 'SP_DEPO_KOD_540';

    BEGIN
        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);

        DELETE FROM trfm.DEPO_KOD_HIST
              WHERE 1=1
                    AND depo_hesap_no = '540'
                    AND tarih = v_tarih;
        COMMIT;

        v_line_no := $$PLSQL_LINE;

        INSERT INTO trfm.DEPO_KOD_HIST
           SELECT a.tarih,
                 '540' AS depo_hesap_no,
                 'Ýnterbank Döviz P.P.' AS Depo_ismi,
                 ROUND(SUM(a.tr_cari),0) as stok_degeri,
                 ROUND(SUM(a.tcmb_islem_limiti_tl),0) as islem_limiti_tl,
                 ROUND(SUM(a.tcmb_islem_limiti_usd),0) as islem_limiti_usd,
                 ROUND(SUM(a.barrowing_plasman_toplam),0) as islem_tutari,
                 ROUND(SUM(a.kull_stok_degeri),0) as kullanilan_stok_degeri,
                 ROUND(SUM(a.kalan_stok_degeri_tl),0) as kullanilabilir_stok_degeri,
                 ROUND(b.kullanilabilir_islem_limit_usd*a.tcmb_alis_kuru) as kullanilabilir_islem_limiti,
--                 ROUND(SUM(tcmb_islem_limiti_tl-barrowing_plasman_toplam),0) as kullanilabilir_islem_limiti,
                 NULL AS dibs_kullanilablr_islem_limiti,
                 NULL AS temnt_dvz_depo_kullblr_tl_lmt,
                 SYSDATE AS etl_trh,
                 v_sp_name AS etl_job
                 --ISINCODE, NOMINAL_TPLM, FIYAT, KATSAYI, TR_CARI, TCMB_ALIS_KURU, TR_CARI_DOLAR, MENKULVADE, GUN_FARK, FAZLA_BULUNDURMA_ORANI, KALAN_STOK_DEGERI_USD
            FROM (
                  SELECT st.tarih,
                         st.isincode,
                         st.nominal_tplm,
                         st.fiyat,
                         st.katsayi,
                         st.tr_cari,
                         st.tcmb_alis_kuru,
                         st.tr_cari_dolar,
                         st.menkulvade,
                         st.gun_fark,
                         st.fazla_bulundurma_orani,
                         st.tr_cari/(1+st.fazla_bulundurma_orani/100) tcmb_islem_limiti_tl,
                         st.tr_cari_dolar/(1+st.fazla_bulundurma_orani/100) tcmb_islem_limiti_usd,
                         pl.barrowing_plasman_toplam,
                         pl.barrowing_plasman_toplam *(1+st.fazla_bulundurma_orani/100) as kull_stok_degeri,
                         (st.tr_cari_dolar - (pl.barrowing_plasman_toplam *(1+st.fazla_bulundurma_orani/100)) ) as kalan_stok_degeri_usd,
                         (st.tr_cari_dolar - (pl.barrowing_plasman_toplam *(1+st.fazla_bulundurma_orani/100)) ) * st.tcmb_alis_kuru as kalan_stok_DEGERI_tl
                    FROM (
                          SELECT cr.tarih,
                                 cr.isincode,
                                 cr.nominal_tplm,
                                 cr.fiyat,
                                 cr.katsayi,
                                 NVL((cr.nominal_tplm * cr.fiyat)/NULLIF(cr.katsayi,0),0) as tr_cari,
                                 cr.tcmb_alis_kuru,
                                 NVL(((cr.nominal_tplm * cr.fiyat)/NULLIF(cr.katsayi,0)) / NULLIF(cr.tcmb_alis_kuru,0),0) as tr_cari_dolar,
                                 cr.menkulvade,
                                 cr.gun_fark,
                                 cr.fazla_bulundurma_orani
                            FROM (
                                  SELECT a.tarih,
                                         a.isincode,
                                         SUM(a.nominal) as nominal_tplm,
                                         b.fiyat,
                                         CASE WHEN t.para <> 0 THEN t.ypkatsayi ELSE t.tlkatsayi END katsayi,
                                         fd.d_alis*fd.katsayi as tcmb_alis_kuru,
                                         b.menkulvade,
                                         b.menkulvade-v_tarih as gun_fark,
                                         CASE WHEN b.menkulvade-v_tarih< 1095 THEN fbo.uc_yildan_kucuk
                                              WHEN b.menkulvade-v_tarih>=1095 THEN fbo.uc_yildan_buyuk
                                         END as fazla_bulundurma_orani
                                    FROM extr.FS_MENKULOZET a
                                         INNER JOIN opr.IS_GUNU ig ON ig.tarih = a.tarih
                                         INNER JOIN extr.FS_BONOFIYAT b ON a.tarih = b.tarih
                                                                        and a.isincode = b.isincode
                                                                        and b.islemtip = 2
                                         INNER JOIN extr.FS_MENKULTANIM t ON a.isincode = t.isincode
                                         INNER JOIN extr.FS_FDOVIZ fd ON fd.kurtipi = 2
                                                                      and fd.tarih = a.tarih
                                                                      and fd.para = 1
                                         INNER JOIN dep_data.FAZLA_BULUNDURMA_ORANI fbo ON a.tarih BETWEEN fbo.baslangic_tarih and NVL(fbo.bitis_tarih,trunc(sysdate))
                                   WHERE 1=1
                                         AND a.depokodu = 540
                                         AND a.tarih = v_tarih
                                GROUP BY a.tarih,
                                         a.isincode ,
                                         b.fiyat,
                                         CASE WHEN t.para <> 0 THEN t.ypkatsayi ELSE t.tlkatsayi END,
                                         fd.d_alis*fd.katsayi,
                                         b.menkulvade,
                                         fbo.uc_yildan_kucuk,
                                         fbo.uc_yildan_buyuk
                                 ) cr
                         ) st
                         INNER JOIN (SELECT NVL(SUM(tutar) +SUM(brutfaiz),0) as barrowing_plasman_toplam
                                       FROM extr.FS_PLMISL p
                                      WHERE 1=1
                                            AND p.musbnk = 'TCMB'
                                            and p.valor BETWEEN to_date( '01.01.1995','DD.MM.YYYY') and v_tarih
                                            and p.vade  BETWEEN v_tarih+1 and to_date( '30.12.2099','DD.MM.YYYY')
                                            and p.para BETWEEN 0 and 9999
                                            and p.musbolge = 'TR'
                                            and p.durum <> 9
                                            and p.reftur = 'BR'
                                            and p.para <>0
                                            --finsoft ekranýna flag gelince buraya eklenecek.
                                    ) pl ON 1=1
                 ) a
                 LEFT JOIN TRFM.TMP_DEPO_KOD_540_HIST b on a.tarih = b.tarih --geçici süreliðine eklenmiþtir.
        GROUP BY a.tarih,(b.kullanilabilir_islem_limit_usd*a.tcmb_alis_kuru);



        COMMIT;

        -- END LOG
        ETL.PKG_UTIL_LIB.prc_log_end;

        DBMS_APPLICATION_INFO.set_module(NULL,NULL);

        EXCEPTION WHEN OTHERS THEN
          v_SqlCode := SQLCODE;
          v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

          --FAILURE LOG
          etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

          RAISE;

    END SP_DEPO_KOD_540;


    PROCEDURE SP_DEPO_KOD_903 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

        v_tarih            DATE          := TRUNC(p_tarih);
        v_SqlCode          NUMBER (10);
        v_SqlCodeExp       VARCHAR2 (200);
        v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no          NUMBER        := $$PLSQL_LINE;
        v_sp_name          VARCHAR2 (40) := 'SP_DEPO_KOD_903';


    BEGIN
        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);

        DELETE FROM trfm.DEPO_KOD_HIST
              WHERE 1=1
                    AND depo_hesap_no = '903'
                    AND tarih = v_tarih;
        COMMIT;

        v_line_no := $$PLSQL_LINE;

        INSERT INTO trfm.DEPO_KOD_HIST
        SELECT tarih,
               '903' AS depo_hesap_no,
               'Ýnterbank TL P.P.' AS Depo_ismi,
               ROUND(SUM(dips_tcmb_stok_degeri),0) as stok_degeri,
               ROUND(SUM(dibs_tcmb_islm_lmt_tl),0) AS islem_limiti_TL,
               ROUND(SUM(dibs_tcmb_islm_lmt_usd),0) AS islem_limiti_USD,
               ROUND(barrowing_plasma_toplam,0) AS islem_tutari,
               ROUND(SUM(kullanilan_stok_degeri),0) AS kullanilan_stok_degeri,
               ROUND(SUM(kalan_stok_degeri),0) as  kullanýlabilir_stok_degeri,
               ROUND(kullanilabilir_islem_limiti,0) AS kullanilabilir_islem_limiti,
               ROUND(SUM(kullanilabilir_islem_limiti),0) AS dibs_kullanilablr_islem_limiti,
               ROUND(CASE WHEN SUM(teminat_doviz_depo_tl_limit)-barrowing_plasma_toplam>0 THEN SUM(teminat_doviz_depo_tl_limit)-barrowing_plasma_toplam ELSE 0 END) AS temnt_dvz_depo_kullblr_tl_lmt,
               sysdate AS etl_trh,
               v_sp_name AS etl_job
          FROM (
                SELECT teminat_cesiti, tarih, fazla_bulundurma_orani, dibs_tcmb_islm_lmt_tl, dibs_tcmb_islm_lmt_USD,
                       teminat_doviz_depo_tl_limit, barrowing_plasma_toplam, dips_tcmb_stok_degeri, dips_islem_tutari,
                       kullanilabilir_islem_limiti, kullanilan_islem_limiti, kullanilan_stok_degeri,
                       dips_tcmb_stok_degeri-kullanilan_stok_degeri as kalan_stok_degeri
                  FROM (
                        SELECT teminat_cesiti,
                               tarih,
                               fazla_bulundurma_orani,
                               dibs_tcmb_islm_lmt_tl,
                               dibs_tcmb_islm_lmt_USD,
                               teminat_doviz_depo_tl_limit,
                               barrowing_plasma_toplam,
                               dips_tcmb_stok_degeri,
                               dips_islem_tutari,
                               kullanilabilir_islem_limiti,
                --               dips_tcmb_stok_degeri as dips_tcmb_stok_degr,
                                CASE WHEN fazla_bulundurma_orani = uc_yildan_kucuk THEN kullanilan_islem_limiti_kck_3
                                     WHEN fazla_bulundurma_orani = uc_yildan_buyuk THEN
                                           CASE WHEN first_value(dips_tcmb_stok_degeri) OVER (ORDER BY fazla_bulundurma_orani)
                                                     -first_value(kull_stok_degeri_kck_3) OVER (ORDER BY fazla_bulundurma_orani) = 0
                                                THEN dips_islem_tutari -first_value(kullanilan_islem_limiti_kck_3) OVER (ORDER BY fazla_bulundurma_orani)
                                                ELSE dips_islem_tutari
                                            END
                                    end
                                   as kullanilan_islem_limiti,
                                CASE WHEN fazla_bulundurma_orani = uc_yildan_kucuk  THEN kull_stok_degeri_kck_3
                                     WHEN fazla_bulundurma_orani = uc_yildan_buyuk THEN
                                          CASE WHEN FIRST_VALUE(dips_tcmb_stok_degeri) OVER (ORDER BY fazla_bulundurma_orani)
                                                    - FIRST_VALUE(kull_stok_degeri_kck_3) OVER (ORDER BY fazla_bulundurma_orani) = 0
                                               THEN (dips_islem_tutari -FIRST_VALUE(kullanilan_islem_limiti_kck_3) OVER (ORDER BY fazla_bulundurma_orani))*(1+uc_yildan_buyuk/100)
                                               ELSE dips_islem_tutari *(1+uc_yildan_buyuk/100)
                                          END
                                END as  kullanilan_stok_degeri,
                                uc_yildan_kucuk,
                                uc_yildan_buyuk
                          FROM (
                                 SELECT tarih,
                                        dibs_tcmb_islm_lmt_tl,
                                        dibs_tcmb_islm_lmt_USD,
                                       -- dips_karsiligi_islm_lmt_tplm,
                                        teminat_doviz_depo_tl_limit,
                                        barrowing_plasma_toplam,
                                        dips_tcmb_stok_degeri,
                                        dips_islem_tutari,
                                        kullanilabilir_islem_limiti,
                        --                dibs_tcmb_islm_lmt_tl as dips_karsiligi_islm_lmt_kck_3,
                        --                dips_karslk_islm_lmt_byk_est_3,
                                        CASE WHEN dips_islem_tutari >=dibs_tcmb_islm_lmt_tl THEN dibs_tcmb_islm_lmt_tl
                                             ELSE dips_islem_tutari
                                        END as kullanilan_islem_limiti_kck_3,
                                        CASE WHEN dips_islem_tutari >=dibs_tcmb_islm_lmt_tl THEN dibs_tcmb_islm_lmt_tl
                                             ELSE dips_islem_tutari
                                         END *(1+uc_yildan_kucuk/100) as kull_stok_degeri_kck_3,
                                        fazla_bulundurma_orani,
                                        teminat_cesiti,
                                        uc_yildan_kucuk,
                                        uc_yildan_buyuk
                                   FROM (
                                         SELECT dp.tarih,
                                                --SUM(dibs_tcmb_islm_lmt) OVER() as dips_karsiligi_islm_lmt_tplm,
                                                dp.dibs_tcmb_islm_lmt as dibs_tcmb_islm_lmt_tl,
                                                dp.dibs_tcmb_islm_lmt/(fd.d_alis*fd.katsayi) as dibs_tcmb_islm_lmt_USD,
                                                tdd.teminat_doviz_depo_tl_limit as teminat_doviz_depo_tl_limit,
                                                pl.barrowing_plasma_toplam as barrowing_plasma_toplam,
                                                dp.dibs_tcmb_degeri as dips_tcmb_stok_degeri,
                                                dp.fazla_bulundurma_orani,
                                                dp.uc_yildan_kucuk,
                                                dp.uc_yildan_buyuk,
                                                dp.teminat_cesiti,
                                                (CASE WHEN pl.barrowing_plasma_toplam<=tdd.teminat_doviz_depo_tl_limit THEN 0
                                                         ELSE (pl.barrowing_plasma_toplam-tdd.teminat_doviz_depo_tl_limit)
                                                    END) as dips_islem_tutari,
                                                (CASE WHEN pl.barrowing_plasma_toplam<=tdd.teminat_doviz_depo_tl_limit THEN SUM(dp.dibs_tcmb_islm_lmt) OVER()
                                                      ELSE  SUM(dp.dibs_tcmb_islm_lmt) OVER()-(pl.barrowing_plasma_toplam-tdd.teminat_doviz_depo_tl_limit)
                                                    END
                                                ) as kullanilabilir_islem_limiti
                                           FROM (
                                                   SELECT cr.tarih,
                                                          --cr.isincode,
                                                          SUM(cr.nominal_tplm) AS dips_nominal_deger,
                                                          cr.katsayi,
                                                          SUM((cr.nominal_tplm * cr.tcmb_fiyati)/cr.katsayi) as dibs_tcmb_degeri, --tr_cari,
                                                          cr.doviz_depo_fazla_bulndrm_orani,
                                                          fazla_bulundurma_orani,
                                                          uc_yildan_kucuk,
                                                          uc_yildan_buyuk,
                                                          teminat_cesiti,
                                                          SUM(NVL((cr.nominal_tplm * cr.tcmb_fiyati)/NULLIF(cr.katsayi,0),0)/(1+(fazla_bulundurma_orani/100))) as dibs_tcmb_islm_lmt--dips_karsiligi_islm_lmt
                                                    FROM (
                                                           SELECT a.tarih,
                                                                  a.isincode,
                                                                  SUM(a.nominal) as nominal_tplm,
                                                                  b.fiyat AS tcmb_fiyati,
                                                                  CASE WHEN t.para <> 0 THEN t.ypkatsayi ELSE t.tlkatsayi END katsayi,
                                                                  b.menkulvade,
                                                                  b.menkulvade-v_tarih as gun_fark,
                                                                  CASE WHEN b.menkulvade-v_tarih< 1095 THEN fbo.uc_yildan_kucuk--5
                                                                       WHEN b.menkulvade-v_tarih>=1095 THEN fbo.uc_yildan_buyuk--10
                                                                  END as fazla_bulundurma_orani,
                                                                  CASE WHEN b.menkulvade-v_tarih< 1095 THEN 'DIBS < 3 YIL'
                                                                       WHEN b.menkulvade-v_tarih>=1095 THEN 'DIBS >= 3 YIL'
                                                                  END as teminat_cesiti,
                                                                  0.05 doviz_depo_fazla_bulndrm_orani,
                                                                  fbo.uc_yildan_kucuk,
                                                                  fbo.uc_yildan_buyuk
                                                             FROM EXTR.FS_MENKULOZET a
                                                                  INNER JOIN opr.IS_GUNU ig ON ig.tarih = a.tarih
                                                                  INNER JOIN extr.FS_BONOFIYAT b ON a.tarih = b.tarih
                                                                                                 and a.isincode = b.isincode
                                                                                                 and b.islemtip = 2
                                                                  INNER JOIN EXTR.FS_MENKULTANIM t ON a.isincode = t.isincode
                                                                  INNER JOIN dep_data.FAZLA_BULUNDURMA_ORANI fbo ON a.tarih BETWEEN fbo.baslangic_tarih and NVL(fbo.bitis_tarih,trunc(sysdate))
                                                            WHERE 1=1
                                                                  AND a.depokodu = 903
                                                                  AND a.tarih = v_tarih
                                                         GROUP BY a.tarih,
                                                                  a.isincode ,
                                                                  b.fiyat,
                                                                  CASE WHEN t.para <> 0 THEN t.ypkatsayi ELSE t.tlkatsayi END,
                                                                  b.menkulvade,
                                                                  fbo.uc_yildan_kucuk,
                                                                  fbo.uc_yildan_buyuk
                                                         ) cr
                                                GROUP BY cr.tarih,
                                                         cr.doviz_depo_fazla_bulndrm_orani,
                                                         cr.fazla_bulundurma_orani,
                                                         cr.teminat_cesiti,
                                                         cr.katsayi,
                                                         cr.uc_yildan_kucuk,
                                                         cr.uc_yildan_buyuk
                                                ) dp
                                                INNER JOIN (
                                                              SELECT a.tarih,
                                                                     SUM(a.alacak-a.borc)*-1 as teminat_doviz_depo_orj,
                                                                     SUM((a.alacak-a.borc)*CASE WHEN a.para = 1 THEN fd.d_alis*fd.katsayi
                                                                                                WHEN a.para = 25 THEN fd25.d_alis*fd25.katsayi
                                                                                           END)*-1 as teminat_doviz_depo_tl,
                                                                     SUM((a.alacak-a.borc)*CASE WHEN a.para = 1 THEN fd.d_alis*fd.katsayi
                                                                                                WHEN a.para = 25 THEN fd25.d_alis*fd25.katsayi
                                                                                           END)*-1 / (1+0.05) as teminat_doviz_depo_tl_limit,
                                                                     0.05 AS doviz_depo_fazla_bulndrm_orani ,
                                                                     fd.d_alis*fd.katsayi
                                                                FROM extr.FS_HESAPOZET_GNC a
                                                                     INNER JOIN extr.FS_FDOVIZ fd ON fd.kurtipi = 2
                                                                                                 and fd.tarih = a.tarih
                                                                                                 and fd.para = 1
                                                                     INNER JOIN extr.FS_FDOVIZ fd25 ON fd25.kurtipi = 2
                                                                                                 and fd25.tarih = a.tarih
                                                                                                 and fd25.para = 25
                                                               WHERE 1=1
                                                                     AND a.tarih = v_tarih
                                                                     and a.sube = 998
                                                                     and a.silk7 = 210201
                                                                     and a.para in( 1,25)
                                                            GROUP BY a.tarih,fd.d_alis*fd.katsayi
                                                           ) tdd ON dp.tarih = tdd.tarih
                                                INNER JOIN (SELECT NVL(SUM(tutar) +SUM(brutfaiz),0) as barrowing_plasma_toplam
                                                                   --430000000 as barrowing_plasma_toplam
                                                              FROM EXTR.FS_PLMISL p
                                                             WHERE 1=1
                                                                   and p.musbnk = 'TCMB'
                                                                   and p.valor BETWEEN to_date( '01.01.1995','DD.MM.YYYY') and v_tarih
                                                                   and p.vade  BETWEEN v_tarih+1 and to_date( '30.12.2099','DD.MM.YYYY')
                                                                   and p.para BETWEEN 0 and 9999
                                                                   and p.musbolge = 'TR'
                                                                   and p.durum <> 9
                                                                   and p.reftur = 'BR'
                                                                   and p.para =0
                                                           ) pl ON 1=1
                                                INNER JOIN extr.FS_FDOVIZ fd ON fd.kurtipi = 2
                                                                                and fd.tarih = dp.tarih
                                                                                and fd.para = 1
                                        ) s
                              )
                       )
               )
      GROUP BY tarih,barrowing_plasma_toplam,kullanilabilir_islem_limiti;


  COMMIT;



        -- END LOG
        ETL.PKG_UTIL_LIB.prc_log_end;

        DBMS_APPLICATION_INFO.set_module(NULL,NULL);

        EXCEPTION WHEN OTHERS THEN
          v_SqlCode := SQLCODE;
          v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

          --FAILURE LOG
          etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

          RAISE;

    END SP_DEPO_KOD_903;


    PROCEDURE SP_GI100AS (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

        v_tarih            DATE          := NVL(TRUNC(p_tarih),TRUNC(sysdate-1));
        v_SqlCode          NUMBER (10);
        v_SqlCodeExp       VARCHAR2 (200);
        v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no          NUMBER        := $$PLSQL_LINE;
        v_sp_name          VARCHAR2 (40) := 'SP_GI100AS';


        v_m_bastar                     DATE:= TRUNC(v_tarih,'MM');
        v_oncek_ay_max_is_gunu         DATE;
        v_ay_sonundan_1_onceki_is_gunu DATE;


    BEGIN
        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);

        v_line_no := $$PLSQL_LINE;


        TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_GI100AS',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
        IF V_SQLCODE<>0 THEN
            RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
        END IF;
        v_line_no := $$PLSQL_LINE;


        --A1- Gün Ýçi Likidite Kullanýmý


        INSERT INTO trfm.TMP_GI100AS

            WITH DEGERLER_TRH AS
                 (
                  SELECT tarih,
                         MAX(tutar_kum) as max_tutar_kum,
                         ROW_NUMBER() OVER (ORDER BY MAX(tutar_kum) DESC) as max_tutar_kum_sira,
                         MIN(tutar_kum) as min_tutar_kum,
                         ROW_NUMBER() OVER (ORDER BY MIN(tutar_kum) ASC) as min_tutar_kum_sira
                    FROM (
                            --KAYNAK - A1
                          SELECT sistem, tarih, zaman, tutar, zaman_dilimi,
                                 SUM (tutar) OVER (PARTITION BY tarih ORDER BY tarih,zaman) Tutar_kum,
                                 SUM (DECODE (reftur, 'IM', tutar, 0)) OVER (PARTITION BY tarih ORDER BY tarih,zaman) Gelen_tutar_kum,
                                 SUM (DECODE (reftur, 'OM', tutar, 0)) OVER (PARTITION BY tarih ORDER BY tarih,zaman) Giden_tutar_kum
                            FROM OFSDATA.ILM_EFT200_HAMDATA
                           WHERE 1=1
                                 AND tarih BETWEEN v_m_bastar and v_tarih
                                 and sistem NOT IN ( 'POS_gelen','POS_giden')
--TCMB Açýlýþ Bakiyesi Çýkarýladý
                                   /*
                                 (
                                  SELECT SISTEM, TARIH, ZAMAN, GIRZAMAN, UPDZAMAN, SUBE, REFTUR, REFNIT,
                                         REFSIRANO, TUTAR, GONDERADI, TUTAR_KUM, GELEN_TUTAR_KUM, GIDEN_TUTAR_KUM, ZAMAN_DILIMI
                                    FROM OFSDATA.ILM_EFT200_HAMDATA a
                                   WHERE 1=1 AND tarih BETWEEN v_m_bastar and v_tarih
                                         and sistem not in ( 'POS_gelen','POS_giden')

                                  UNION ALL
                                  SELECT 'TCMB_ACL_B' AS sistem,
                                         girtarih tarih,
                                         girzaman,
                                         girzaman,
                                         updzaman,
                                         sube,
                                         reftur,
                                         refnit,
                                         refsirano,
                                         tutar,
                                         gonderadi,
                                         SUM (tutar) OVER (ORDER BY girzaman) AS Tutar_kum,
                                         SUM (DECODE (reftur, 'IM', tutar, 0)) OVER (PARTITION BY girtarih ORDER BY girzaman) AS Gelen_tutar_kum,
                                         SUM (DECODE (reftur, 'OM', tutar, 0)) OVER (PARTITION BY girtarih ORDER BY girzaman) AS Giden_tutar_kum,
                                         CASE
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('00:00:00','HH24:mi:ss') AND TO_DATE('09:00:00','HH24:mi:ss') THEN '09:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('09:00:01','HH24:mi:ss') AND TO_DATE('10:00:00','HH24:mi:ss') THEN '10:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('10:00:01','HH24:mi:ss') AND TO_DATE('11:00:00','HH24:mi:ss') THEN '11:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('11:00:01','HH24:mi:ss') AND TO_DATE('12:00:00','HH24:mi:ss') THEN '12:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('12:00:01','HH24:mi:ss') AND TO_DATE('13:00:00','HH24:mi:ss') THEN '13:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('13:00:01','HH24:mi:ss') AND TO_DATE('14:00:00','HH24:mi:ss') THEN '14:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('14:00:01','HH24:mi:ss') AND TO_DATE('15:00:00','HH24:mi:ss') THEN '15:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('15:00:01','HH24:mi:ss') AND TO_DATE('16:00:00','HH24:mi:ss') THEN '16:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('16:00:01','HH24:mi:ss') AND TO_DATE('17:00:00','HH24:mi:ss') THEN '17:00'
                                            WHEN TO_DATE(substr(girzaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('17:00:01','HH24:mi:ss') AND TO_DATE('23:59:59','HH24:mi:ss') THEN '18:00'
                                            END AS Zaman_dilimi
                                  FROM   EXTR.FS_EFTMSG a
                                 WHERE   1=1
                                         AND yeni_msgtip IN ('K11')
                                         AND sube = 5
                                         AND alicisube = 5
                                         AND ahessube = 5
                                         AND ahessinif = 'A'
                                         AND ahesmusteri = 200003
                                         AND ahestur = 0
                                         AND ahesekno = 1
                                         AND girtarih BETWEEN trunc(v_tarih,'MM') and v_tarih
                                 )
*/
                         )
                   WHERE 1=1
                GROUP BY tarih
--                ORDER BY 1
              )
            SELECT v_tarih as tarih,
                   'En Büyük Pozitif Net Kümülatif Pozisyon' as sira_adi,
                   (SELECT max_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND max_tutar_kum_sira = 1) as uc_deger_1, --1. Uç Deðer
                   (SELECT max_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND max_tutar_kum_sira = 2) as uc_deger_2, --2. Uç Deðer
                   (SELECT max_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND max_tutar_kum_sira = 3) as uc_deger_3, --3. Uç Deðer
                   (SELECT AVG(max_tutar_kum) FROM DEGERLER_TRH) as ortalama,
                   sysdate AS etl_trh,
                   v_sp_name AS etl_job
            FROM SYS.DUAL
            UNION ALL
             SELECT v_tarih as tarih,
                   'En Büyük Negatif Net Kümülatif Pozisyon' as sira_adi,
                   (SELECT min_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND min_tutar_kum_sira = 1) as uc_deger_1, --1. Uç Deðer
                   (SELECT min_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND min_tutar_kum_sira = 2) as uc_deger_2, --2. Uç Deðer
                   (SELECT min_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND min_tutar_kum_sira = 3) as uc_deger_3, --3. Uç Deðer
                   (SELECT AVG(min_tutar_kum) FROM DEGERLER_TRH) as ortalama,
                   sysdate AS etl_trh,
                   v_sp_name AS etl_job
            FROM SYS.DUAL;

        COMMIT;



        v_line_no := $$PLSQL_LINE;




                                            /*
        saat 8 deki tüm gün günlerin aritmetik ortalamalarý''nýn toplamýnýn
        genele bölümü
        */

                                            /*
        --KAYNAK - A2 - 4. Merkez Bankasý
        select a.rapor_tarihi,a.thp_no, a.anapara_tl
        from ofsdata.contract_data_calc_arsiv a
        INNER JOIN opr.IS_GUNU ig ON a.rapor_tarihi = ig.tarih
        WHERE A.rapor_tarihi BETWEEN (SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih <TO_DATE('01.10.2016','dd.mm.yyyy') )
                                       and (SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih < TO_DATE('31.10.2016','dd.mm.yyyy')-1  )
        AND a.solo_bilgisi = 'SOLO'
        AND a.tali_thp_no IN ('20000','20001')
        ORDER BY 1,2
        */

        --A2- Gün Baþýndaki Kullanýlabilir Likidite Tutarý (En Küçük) (4+5+6+7+10+11+12)

        SELECT max(tarih) INTO v_oncek_ay_max_is_gunu FROM opr.IS_GUNU WHERE 1=1 AND tarih <v_m_bastar;
        SELECT max(tarih) INTO v_ay_sonundan_1_onceki_is_gunu FROM opr.IS_GUNU WHERE 1=1 AND tarih <= v_tarih-1;


        INSERT INTO trfm.TMP_GI100AS

        WITH KAYNAK_THP_BAZLI AS
            (SELECT a.rapor_tarihi,
                    a.thp_no,
                    SUM(a.anapara_tl) tplm_anapara_tl
               FROM ofsdata.CONTRACT_DATA_CALC_ARSIV a
                    INNER JOIN opr.IS_GUNU ig ON a.rapor_tarihi = ig.tarih
              WHERE a.rapor_tarihi BETWEEN v_oncek_ay_max_is_gunu --(SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih <TO_DATE('01.10.2016','dd.mm.yyyy') )
                                       and v_ay_sonundan_1_onceki_is_gunu --(SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih < TO_DATE('31.10.2016','dd.mm.yyyy')-1  )
                    AND a.tali_thp_no IN (20000,20001)
                    AND a.solo_bilgisi = 'SOLO'
           GROUP BY a.rapor_tarihi, a.thp_no
            ),
            mrk_bnk_alnck AS
            (SELECT a.rapor_tarihi,
                    SUM(a.tplm_anapara_tl) tplm_anapara_tl,
                    ROW_NUMBER() OVER (ORDER BY SUM(a.tplm_anapara_tl) ASC) as sira
               FROM KAYNAK_THP_BAZLI a
           GROUP BY a.rapor_tarihi
            )
         SELECT v_tarih as tarih,
                'Merkez Bankasýndan Alacaklar' as sira_no,
                (SELECT tplm_anapara_tl FROM mrk_bnk_alnck WHERE 1=1 AND sira = 1) as uc_deger_1,
                (SELECT tplm_anapara_tl FROM mrk_bnk_alnck WHERE 1=1 AND sira = 2) as uc_deger_2,
                (SELECT tplm_anapara_tl FROM mrk_bnk_alnck WHERE 1=1 AND sira = 3) as uc_deger_3,
                (SELECT AVG(tplm_anapara_tl) as ort FROM mrk_bnk_alnck) as ortalama,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
           FROM sys.DUAL;

        COMMIT;

        v_line_no := $$PLSQL_LINE;

                                            /*
        --KAYNAK - A2 - 5. Banka Bilanços
        select a.rapor_tarihi,a.thp_no, CASE WHEN a.bsl3_lcr_kodu_final= 'A_3_1' THEN a.bsl3_lcr_bakiye_tl ELSE a.anapara_tl END AS anapara_tl
        from ofsdata.contract_data_calc_arsiv a
        INNER JOIN opr.IS_GUNU ig ON a.rapor_tarihi = ig.tarih
        WHERE A.rapor_tarihi BETWEEN (SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih <TO_DATE('01.10.2016','dd.mm.yyyy') )
                                       and (SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih < TO_DATE('31.10.2016','dd.mm.yyyy')-1  )
        AND a.solo_bilgisi = 'SOLO'
        AND (   a.bsl3_lcr_kodu_final = 'A_3_1'
             OR a.ana_thp_no IN (10,50)
            )
        ORDER BY 1;

        */

        INSERT INTO trfm.TMP_GI100AS
        WITH KAYNAK_THP_BAZLI AS
            (SELECT a.rapor_tarihi,
                    a.thp_no,
                    SUM(CASE WHEN a.bsl3_lcr_kodu_final= 'A_3_1' THEN a.bsl3_lcr_bakiye_tl ELSE a.anapara_tl END) as tplm_anapara_tl
               FROM ofsdata.CONTRACT_DATA_CALC_ARSIV a
                    INNER JOIN opr.IS_GUNU ig ON a.rapor_tarihi = ig.tarih
              WHERE a.rapor_tarihi BETWEEN v_oncek_ay_max_is_gunu         --(SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih <TO_DATE('01.10.2016','dd.mm.yyyy') )
                                       and v_ay_sonundan_1_onceki_is_gunu --(SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih < TO_DATE('31.10.2016','dd.mm.yyyy')-1  )
                    AND a.solo_bilgisi = 'SOLO'
                    AND (   a.bsl3_lcr_kodu_final = 'A_3_1'
                            OR a.ana_thp_no IN (10,50)
                        )
           GROUP BY a.rapor_tarihi, a.thp_no
            ),
            BNK_BLNC_SRB_LKT_VRK AS
            (
                 SELECT a.rapor_tarihi,
                        SUM(a.tplm_anapara_tl) tplm_anapara_tl,
                        ROW_NUMBER() OVER (ORDER BY SUM(a.tplm_anapara_tl) ASC) as sira
                   FROM KAYNAK_THP_BAZLI a
               GROUP BY a.rapor_tarihi
            )
         SELECT v_tarih as tarih,
                'Banka Bilançosundaki Serbest Likit Varlýklar' as sira_no,
                (SELECT tplm_anapara_tl FROM bnk_blnc_srb_lkt_vrk WHERE 1=1 AND sira = 1) as uc_deger_1,
                (SELECT tplm_anapara_tl FROM bnk_blnc_srb_lkt_vrk WHERE 1=1 AND sira = 2) as uc_deger_2,
                (SELECT tplm_anapara_tl FROM bnk_blnc_srb_lkt_vrk WHERE 1=1 AND sira = 3) as uc_deger_3,
                (SELECT AVG(tplm_anapara_tl) as ort FROM BNK_BLNC_SRB_LKT_VRK) as ortalama,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
           FROM sys.DUAL;

        COMMIT;
        v_line_no := $$PLSQL_LINE;

                                            /*
        --KAYNAK - A2 - 6. Bankalardan Al
        SELECT a.rapor_tarihi,
                    a.thp_no,
                    SUM(a.anapara_tl) tplm_anapara_tl
               FROM ofsdata.CONTRACT_DATA_CALC_ARSIV a
                    INNER JOIN opr.IS_GUNU ig ON a.rapor_tarihi = ig.tarih
              WHERE a.rapor_tarihi BETWEEN (SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih <TO_DATE('01.10.2016','dd.mm.yyyy') )
                                       and (SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih < TO_DATE('31.10.2016','dd.mm.yyyy')-1  )
                    AND a.ana_thp_no IN (22,24,40)
                    AND a.solo_bilgisi = 'SOLO'
           GROUP BY a.rapor_tarihi,thp_no
           ORDER BY 1;
        */

        INSERT INTO trfm.TMP_GI100AS
        WITH KAYNAK_THP_BAZLI AS
            (SELECT a.rapor_tarihi,
                    a.thp_no,
                    SUM(a.anapara_tl) tplm_anapara_tl
               FROM ofsdata.CONTRACT_DATA_CALC_ARSIV a
                    INNER JOIN opr.IS_GUNU ig ON a.rapor_tarihi = ig.tarih
              WHERE 1=1
                    AND a.rapor_tarihi BETWEEN v_oncek_ay_max_is_gunu     --(SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih <TO_DATE('01.10.2016','dd.mm.yyyy') )
                                       and v_ay_sonundan_1_onceki_is_gunu --(SELECT max(tarih) AS is_gunu_tarih FROM opr.IS_GUNU WHERE 1=1 AND tarih < TO_DATE('31.10.2016','dd.mm.yyyy')-1  )
                    AND a.ana_thp_no IN (22,24,40)
                    AND a.solo_bilgisi = 'SOLO'
           GROUP BY a.rapor_tarihi, a.thp_no
            ),
            Bankalardan_Alacaklar AS
            (
             SELECT a.rapor_tarihi,
                    SUM(a.tplm_anapara_tl) tplm_anapara_tl,
                    ROW_NUMBER() OVER (ORDER BY SUM(a.tplm_anapara_tl) ASC) as sira
               FROM KAYNAK_THP_BAZLI a
           GROUP BY a.rapor_tarihi
            )
         SELECT v_tarih as tarih,
                'Bankalardan Alacaklar' as sira_no,
                (SELECT tplm_anapara_tl FROM Bankalardan_Alacaklar WHERE 1=1 AND sira = 1) as uc_deger_1,
                (SELECT tplm_anapara_tl FROM Bankalardan_Alacaklar WHERE 1=1 AND sira = 2) as uc_deger_2,
                (SELECT tplm_anapara_tl FROM Bankalardan_Alacaklar WHERE 1=1 AND sira = 3) as uc_deger_3,
                (SELECT AVG(tplm_anapara_tl) as ort FROM Bankalardan_Alacaklar ) as ortalama,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
           FROM sys.DUAL;

        COMMIT;

        v_line_no := $$PLSQL_LINE;


        --KAYNAK - A2 - 8. Teminatlý
                                            /*
            SELECT *
              FROM trfm.DEPO_KOD_HIST a
             WHERE 1=1
                   AND tarih BETWEEN TO_DATE( '01.10.2016','DD.MM.YYYY')  AND TO_DATE( '31.10.2016','DD.MM.YYYY')
                   AND depo_hesap_no = '005'
          ORDER BY kullanilabilir_islem_limiti desc
        */

        INSERT INTO trfm.TMP_GI100AS
        WITH DEPO_HESAP_5 AS
            (
            SELECT tarih,
                   kullanilabilir_islem_limiti,
                   ROW_NUMBER() OVER (ORDER BY kullanilabilir_islem_limiti ASC) as sira
              FROM trfm.DEPO_KOD_HIST
             WHERE 1=1
                   AND tarih BETWEEN v_m_bastar and v_tarih
                   AND depo_hesap_no = '005'
        )
         SELECT v_tarih as tarih,
                'a) Teminatlý' as sira_no,
                (SELECT kullanilabilir_islem_limiti FROM DEPO_HESAP_5 WHERE 1=1 AND sira = 1) as uc_deger_1,
                (SELECT kullanilabilir_islem_limiti FROM DEPO_HESAP_5 WHERE 1=1 AND sira = 2) as uc_deger_2,
                (SELECT kullanilabilir_islem_limiti FROM DEPO_HESAP_5 WHERE 1=1 AND sira = 3) as uc_deger_3,
                (SELECT AVG(kullanilabilir_islem_limiti) as ort FROM DEPO_HESAP_5) as ortalama,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
           FROM sys.DUAL;

        COMMIT;

        v_line_no := $$PLSQL_LINE;

        --KAYNAK - A2 - 10. Merkez Bankasýna Verilmiþ Teminatlar
                                            /*
            SELECT *
              FROM trfm.DEPO_KOD_HIST a
             WHERE 1=1
                   AND tarih BETWEEN TO_DATE( '01.10.2016','DD.MM.YYYY')  AND TO_DATE( '31.10.2016','DD.MM.YYYY')
                   AND depo_hesap_no IN ('540','903')
          ORDER BY kullanilabilir_islem_limiti desc
        */

        INSERT INTO trfm.TMP_GI100AS

        WITH DEPO_HESAP_540_903 AS
            (
            SELECT tarih,
        --           depo_hesap_no,
                   SUM(kullanilabilir_islem_limiti) kullanilabilir_islem_limiti,
                   ROW_NUMBER() OVER (ORDER BY SUM(kullanilabilir_islem_limiti) ASC) as sira
              FROM trfm.DEPO_KOD_HIST a
             WHERE 1=1
                   AND tarih BETWEEN v_m_bastar and v_tarih
                   AND depo_hesap_no IN ('540','903')
          GROUP BY tarih
        )
         SELECT v_tarih as tarih,
                'Merkez Bankasýna Verilmiþ Teminatlar' as sira_no,
                (SELECT kullanilabilir_islem_limiti FROM DEPO_HESAP_540_903 WHERE 1=1 AND sira = 1) as uc_deger_1,
                (SELECT kullanilabilir_islem_limiti FROM DEPO_HESAP_540_903 WHERE 1=1 AND sira = 2) as uc_deger_2,
                (SELECT kullanilabilir_islem_limiti FROM DEPO_HESAP_540_903 WHERE 1=1 AND sira = 3) as uc_deger_3,
                (SELECT AVG(kullanilabilir_islem_limiti) as ort FROM DEPO_HESAP_540_903) as ortalama,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
           FROM sys.DUAL;

        COMMIT;

        v_line_no := $$PLSQL_LINE;


        --A3- Gün Ýçindeki Toplam/Brüt Ödemeler

        INSERT INTO trfm.TMP_GI100AS

            WITH DEGERLER_TRH AS
                 (
                  SELECT tarih,
                         max(tutar_kum) as max_tutar_kum, row_number() over (ORDER BY max(tutar_kum) desc) as max_tutar_kum_sira,
                         min(tutar_kum) as min_tutar_kum, row_number() over (ORDER BY min(tutar_kum) asc) as min_tutar_kum_sira,
                         min(Giden_tutar_kum) as min_giden_tutar_kum,  row_number() over (ORDER BY min(Giden_tutar_kum) asc) as min_giden_tutar_kum_sira,
                         max(Gelen_tutar_kum) as max_gelen_tutar_kum, row_number() over (ORDER BY max(Gelen_tutar_kum) desc) as max_gelen_tutar_kum_sira
                    FROM (
                            --KAYNAK - A3
                          SELECT sistem, tarih, zaman, tutar, zaman_dilimi,
                                 SUM (tutar) OVER (ORDER BY tarih,zaman) Tutar_kum,
                                 SUM (DECODE (reftur, 'IM', tutar, 0)) OVER (PARTITION BY tarih ORDER BY tarih,zaman) Gelen_tutar_kum,
                                 SUM (DECODE (reftur, 'OM', tutar, 0)) OVER (PARTITION BY tarih ORDER BY tarih,zaman) Giden_tutar_kum
                            FROM OFSDATA.ILM_EFT200_HAMDATA a
                           WHERE 1=1 AND tarih BETWEEN v_m_bastar and v_tarih
                                 and sistem not in ( 'POS_gelen','POS_giden')
                           --ORDER BY tarih,zaman
                         )
                GROUP BY tarih
              )
            SELECT v_tarih as tarih,
                   'Yapýlan En Büyük Toplam/Brüt Ödeme' as sira_adi,
                   (SELECT min_giden_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND min_giden_tutar_kum_sira = 1) as uc_deger_1, --1. Uç Deðer
                   (SELECT min_giden_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND min_giden_tutar_kum_sira = 2) as uc_deger_2, --2. Uç Deðer
                   (SELECT min_giden_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND min_giden_tutar_kum_sira = 3) as uc_deger_3, --3. Uç Deðer
                   (SELECT AVG(min_giden_tutar_kum) FROM DEGERLER_TRH) as ortalama,
                   sysdate AS etl_trh,
                   v_sp_name AS etl_job
            FROM SYS.DUAL
            UNION ALL
            SELECT v_tarih as tarih,
                   'Alýnan En Büyük Toplam/Brüt Ödeme' as sira_adi,
                   (SELECT max_gelen_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND max_gelen_tutar_kum_sira = 1) as uc_deger_1, --1. Uç Deðer
                   (SELECT max_gelen_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND max_gelen_tutar_kum_sira = 2) as uc_deger_2, --2. Uç Deðer
                   (SELECT max_gelen_tutar_kum FROM DEGERLER_TRH WHERE 1=1 AND max_gelen_tutar_kum_sira = 3) as uc_deger_3, --3. Uç Deðer
                   (SELECT AVG(max_gelen_tutar_kum) FROM DEGERLER_TRH) as ortalama,
                   sysdate AS etl_trh,
                   v_sp_name AS etl_job
              FROM SYS.DUAL;

        COMMIT;

        v_line_no := $$PLSQL_LINE;


        --    KAYNAK - C1- Gün Ýçi Ödeme Ýþl

        --C1- Gün Ýçi Ödeme Ýþlem Hacmi (%)

        INSERT INTO trfm.TMP_GI100AS

         WITH DEGERLER_ZMN AS
            (
          --   KAYNAK - C1- Gün Ýçi -ÞABLONLU
              SELECT b.tarih,
                     b.zaman_dilimleri AS Zaman_dilimi,
                     NVL(SUM (a.tutar),0) AS tutar_zmn_dlm_tplm
                FROM (
                    --KAYNAK - C1- Gün Ýçi -HAM DATA
                      SELECT sistem,
                             tarih, zaman,
                             tutar,
                             CASE   WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('00:00:00','HH24:mi:ss') AND TO_DATE('08:00:00','HH24:mi:ss') THEN '08:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('08:00:01','HH24:mi:ss') AND TO_DATE('09:00:00','HH24:mi:ss') THEN '09:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('09:00:01','HH24:mi:ss') AND TO_DATE('10:00:00','HH24:mi:ss') THEN '10:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('10:00:01','HH24:mi:ss') AND TO_DATE('11:00:00','HH24:mi:ss') THEN '11:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('11:00:01','HH24:mi:ss') AND TO_DATE('12:00:00','HH24:mi:ss') THEN '12:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('12:00:01','HH24:mi:ss') AND TO_DATE('13:00:00','HH24:mi:ss') THEN '13:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('13:00:01','HH24:mi:ss') AND TO_DATE('14:00:00','HH24:mi:ss') THEN '14:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('14:00:01','HH24:mi:ss') AND TO_DATE('15:00:00','HH24:mi:ss') THEN '15:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('15:00:01','HH24:mi:ss') AND TO_DATE('16:00:00','HH24:mi:ss') THEN '16:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('16:00:01','HH24:mi:ss') AND TO_DATE('17:00:00','HH24:mi:ss') THEN '17:00'
                                    WHEN TO_DATE(substr(zaman,1,8),'HH24:mi:ss') BETWEEN TO_DATE('17:00:01','HH24:mi:ss') AND TO_DATE('23:59:59','HH24:mi:ss') THEN '18:00'
                                    END AS Zaman_dilimi
                        FROM OFSDATA.ILM_EFT200_HAMDATA a
                       WHERE 1=1 AND tarih BETWEEN v_m_bastar and v_tarih
                             and sistem not in ( 'POS_gelen','POS_giden')
                             and reftur = 'OM'
                     )a
                     FULL JOIN ( SELECT a.tarih, zd.zaman_dilimleri
                                   FROM (
                                        SELECT t.tarih,
                                               CASE WHEN yg.tatil_bas IS NOT NULL THEN 'YG' ELSE 'TG' END AS Yarim_gun_f
                                          FROM opr.IS_GUNU t
                                               LEFT JOIN extr.FS_RESMITATIL yg ON yg.tatil_bas = t.tarih AND yg.tatil_tip = 8
                                         WHERE 1=1
                                               AND t.tarih BETWEEN v_m_bastar and v_tarih
                                       ) a
                                        INNER JOIN (    SELECT CONCAT(LPAD(TO_CHAR(LEVEL+7),2,'0'),':00') AS zaman_dilimleri,
                                                               LEVEL+7 AS zaman_dilimleri_nmbr
                                                          FROM DUAL
                                                    CONNECT BY LEVEL <= 11
                                            --          ORDER BY 1,2
                                                    ) zd ON 1=1
                                  WHERE 1=1
                                        AND CASE WHEN a.yarim_gun_f = 'TG' THEN 1
                                                 WHEN a.yarim_gun_f = 'YG' AND zd.zaman_dilimleri_nmbr BETWEEN 9 AND 13 THEN 1
                                                 WHEN a.yarim_gun_f = 'YG' AND zd.zaman_dilimleri_nmbr >13 THEN 0
                                            END = 1
                               ORDER BY 1 ,2
                               ) b ON b.zaman_dilimleri = a.Zaman_dilimi AND a.tarih = b.tarih
            GROUP BY b.tarih,b.zaman_dilimleri
            ORDER BY 1,2
              ),
              tplm_degerler_trh as
              (
                 SELECT tarih,
                        SUM(tutar_zmn_dlm_tplm) AS tutar_zmn_dlm_gun_tplm
                   FROM DEGERLER_ZMN
               GROUP BY tarih
              )
              SELECT v_tarih as tarih,
                     CASE WHEN a.zaman_dilimi = '08:00' THEN 'Saat 08:00''a Kadar'
                          WHEN a.zaman_dilimi = '09:00' THEN 'Saat 08:00 - 09:00 Arasý'
                          WHEN a.zaman_dilimi = '10:00' THEN 'Saat 09:00 - 10:00 Arasý'
                          WHEN a.zaman_dilimi = '11:00' THEN 'Saat 10:00 - 11:00 Arasý'
                          WHEN a.zaman_dilimi = '12:00' THEN 'Saat 11:00 - 12:00 Arasý'
                          WHEN a.zaman_dilimi = '13:00' THEN 'Saat 12:00 - 13:00 Arasý'
                          WHEN a.zaman_dilimi = '14:00' THEN 'Saat 13:00 - 14:00 Arasý'
                          WHEN a.zaman_dilimi = '15:00' THEN 'Saat 14:00 - 15:00 Arasý'
                          WHEN a.zaman_dilimi = '16:00' THEN 'Saat 15:00 - 16:00 Arasý'
                          WHEN a.zaman_dilimi = '17:00' THEN 'Saat 16:00 - 17:00 Arasý'
                          WHEN a.zaman_dilimi = '18:00' THEN 'Saat 17:00 - 18:00 Arasý'
                     ELSE a.zaman_dilimi END as sira_adi,
                     CAST(NULL AS NUMBER) as uc_deger_1,
                     CAST(NULL AS NUMBER) as uc_deger_2,
                     CAST(NULL AS NUMBER) as uc_deger_3,
                     NVL(100*AVG(a.tutar_zmn_dlm_tplm/NULLIF(b.tutar_zmn_dlm_gun_tplm,0)),0) as ortalama,
                     sysdate AS etl_trh,
                     v_sp_name AS etl_job
                FROM DEGERLER_ZMN a
                     INNER JOIN TPLM_DEGERLER_TRH b ON a.tarih = b.tarih
            GROUP BY CASE WHEN a.zaman_dilimi = '08:00' THEN 'Saat 08:00''a Kadar'
                          WHEN a.zaman_dilimi = '09:00' THEN 'Saat 08:00 - 09:00 Arasý'
                          WHEN a.zaman_dilimi = '10:00' THEN 'Saat 09:00 - 10:00 Arasý'
                          WHEN a.zaman_dilimi = '11:00' THEN 'Saat 10:00 - 11:00 Arasý'
                          WHEN a.zaman_dilimi = '12:00' THEN 'Saat 11:00 - 12:00 Arasý'
                          WHEN a.zaman_dilimi = '13:00' THEN 'Saat 12:00 - 13:00 Arasý'
                          WHEN a.zaman_dilimi = '14:00' THEN 'Saat 13:00 - 14:00 Arasý'
                          WHEN a.zaman_dilimi = '15:00' THEN 'Saat 14:00 - 15:00 Arasý'
                          WHEN a.zaman_dilimi = '16:00' THEN 'Saat 15:00 - 16:00 Arasý'
                          WHEN a.zaman_dilimi = '17:00' THEN 'Saat 16:00 - 17:00 Arasý'
                          WHEN a.zaman_dilimi = '18:00' THEN 'Saat 17:00 - 18:00 Arasý'
                     ELSE a.zaman_dilimi end
                   ORDER BY 2;

        COMMIT;


        v_line_no := $$PLSQL_LINE;

        ------------------GI100AS RAPOR------------------

        DELETE FROM dm_infoman.GI100AS WHERE 1=1 AND tarih BETWEEN v_m_bastar AND v_tarih;
        COMMIT;

         INSERT INTO dm_infoman.GI100AS
          SELECT tarih,
                 CASE WHEN sira_adi = 'En Büyük Pozitif Net Kümülatif Pozisyon' THEN 1
                      WHEN sira_adi = 'En Büyük Negatif Net Kümülatif Pozisyon' THEN 2
                      WHEN sira_adi = 'A2- Gün Baþýndaki Kullanýlabilir Likidite Tutarý (En Küçük) (4+5+6+7+10+11+12)' THEN 3
                      WHEN sira_adi = 'Merkez Bankasýndan Alacaklar' THEN 4
                      WHEN sira_adi = 'Banka Bilançosundaki Serbest Likit Varlýklar' THEN 5
                      WHEN sira_adi = 'Bankalardan Alacaklar' THEN 6
                      WHEN sira_adi = 'Kullanýlabilir Kredi Limitleri' THEN 7
                      WHEN sira_adi = 'a) Teminatlý' THEN 8
                      WHEN sira_adi = 'b) Taahhüt Edilmiþ' THEN 9
                      WHEN sira_adi = 'Merkez Bankasýna Verilmiþ Teminatlar' THEN 10
                      WHEN sira_adi = 'Diðer (Ýkincil) Ödeme Sistemlerine Verilen Teminatlar' THEN 11
                      WHEN sira_adi = 'Diðer' THEN 12
                      WHEN sira_adi = 'Yapýlan En Büyük Toplam/Brüt Ödeme' THEN 13
                      WHEN sira_adi = 'Alýnan En Büyük Toplam/Brüt Ödeme' THEN 14
                      WHEN sira_adi = 'A4- Zaman Kýsýtý Olan Yükümlülükler Toplamý (En Büyük)' THEN 15
                      WHEN sira_adi = 'Saat 08:00''a Kadar' THEN 16
                      WHEN sira_adi = 'Saat 08:00 - 09:00 Arasý' THEN 17
                      WHEN sira_adi = 'Saat 09:00 - 10:00 Arasý' THEN 18
                      WHEN sira_adi = 'Saat 10:00 - 11:00 Arasý' THEN 19
                      WHEN sira_adi = 'Saat 11:00 - 12:00 Arasý' THEN 20
                      WHEN sira_adi = 'Saat 12:00 - 13:00 Arasý' THEN 21
                      WHEN sira_adi = 'Saat 13:00 - 14:00 Arasý' THEN 22
                      WHEN sira_adi = 'Saat 14:00 - 15:00 Arasý' THEN 23
                      WHEN sira_adi = 'Saat 15:00 - 16:00 Arasý' THEN 24
                      WHEN sira_adi = 'Saat 16:00 - 17:00 Arasý' THEN 25
                      WHEN sira_adi = 'Saat 17:00 - 18:00 Arasý' THEN 26
                  END AS sira_no,
                 sira_adi, uc_deger_1, uc_deger_2, uc_deger_3, ortalama,
                 sysdate AS etl_trh,
                 v_sp_name AS etl_job
            FROM (SELECT TARIH, SIRA_ADI, UC_DEGER_1, UC_DEGER_2, UC_DEGER_3, ORTALAMA
                    FROM trfm.TMP_GI100AS
                   WHERE 1=1
                         AND tarih = v_tarih
                  -----------------
                  UNION ALL
                  SELECT v_tarih AS tarih,
                         'A1- Gün Ýçi Likidite Kullanýmý' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                  UNION ALL
                  -----------------
                  SELECT tarih,
                         'A2- Gün Baþýndaki Kullanýlabilir Likidite Tutarý (En Küçük) (4+5+6+7+10+11+12)' AS sira_adi,
                         SUM(uc_deger_1) AS uc_deger_1, SUM(uc_deger_2) AS uc_deger_2, SUM(uc_deger_3) AS uc_deger_3,
                         SUM(ortalama) AS ortalama
                    FROM trfm.TMP_GI100AS
                   WHERE 1=1
                         AND tarih = v_tarih
                         AND sira_adi IN (
                                          'Merkez Bankasýndan Alacaklar',
                                          'Banka Bilançosundaki Serbest Likit Varlýklar',
                                          'Bankalardan Alacaklar',
                                          'a) Teminatlý',
                                          'b) Taahhüt Edilmiþ',
                                          'Merkez Bankasýna Verilmiþ Teminatlar',
                                          'Diðer (Ýkincil) Ödeme Sistemlerine Verilen Teminatlar',
                                          'Diðer'
                                         )
                GROUP BY tarih
                  -----------------
                  UNION ALL
                  SELECT tarih,
                         'Kullanýlabilir Kredi Limitleri' AS sira_adi,
                         SUM(uc_deger_1) AS uc_deger_1, SUM(uc_deger_2) AS uc_deger_2, SUM(uc_deger_3) AS uc_deger_3,
                         SUM(ortalama) AS ortalama
                    FROM trfm.TMP_GI100AS
                   WHERE 1=1
                         AND tarih = v_tarih
                         AND sira_adi IN ('a) Teminatlý', 'b) Taahhüt Edilmiþ')
                GROUP BY tarih
                  -----------------
                UNION ALL
                  SELECT v_tarih AS tarih,
                         'b) Taahhüt Edilmiþ' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                  UNION ALL
                  SELECT v_tarih AS tarih,
                         'Diðer (Ýkincil) Ödeme Sistemlerine Verilen Teminatlar' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                  UNION ALL
                  SELECT v_tarih AS tarih,
                         'Diðer' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                  UNION ALL
                   SELECT v_tarih AS tarih,
                         'A3- Gün Ýçindeki Toplam/Brüt Ödemeler' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                  UNION ALL
                   SELECT v_tarih AS tarih,
                         'A4- Zaman Kýsýtý Olan Yükümlülükler Toplamý (En Büyük)' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                  UNION ALL
                   SELECT v_tarih AS tarih,
                         'C1- Gün Ýçi Ödeme Ýþlem Hacmi (%)' AS sira_adi,
                         CAST(NULL AS NUMBER) AS uc_deger_1, CAST(NULL AS NUMBER) AS uc_deger_2, CAST(NULL AS NUMBER) AS uc_deger_3, CAST(NULL AS NUMBER) AS ortalama
                    FROM sys.DUAL
                 )
        ORDER BY CASE WHEN sira_adi = 'A1- Gün Ýçi Likidite Kullanýmý' THEN 0
                      WHEN sira_adi = 'En Büyük Pozitif Net Kümülatif Pozisyon' THEN 1
                      WHEN sira_adi = 'En Büyük Negatif Net Kümülatif Pozisyon' THEN 2
                      WHEN sira_adi = 'A2- Gün Baþýndaki Kullanýlabilir Likidite Tutarý (En Küçük) (4+5+6+7+10+11+12)' THEN 3
                      WHEN sira_adi = 'Merkez Bankasýndan Alacaklar' THEN 4
                      WHEN sira_adi = 'Banka Bilançosundaki Serbest Likit Varlýklar' THEN 5
                      WHEN sira_adi = 'Bankalardan Alacaklar' THEN 6
                      WHEN sira_adi = 'Kullanýlabilir Kredi Limitleri' THEN 7
                      WHEN sira_adi = 'a) Teminatlý' THEN 8
                      WHEN sira_adi = 'b) Taahhüt Edilmiþ' THEN 9
                      WHEN sira_adi = 'Merkez Bankasýna Verilmiþ Teminatlar' THEN 10
                      WHEN sira_adi = 'Diðer (Ýkincil) Ödeme Sistemlerine Verilen Teminatlar' THEN 11
                      WHEN sira_adi = 'Diðer' THEN 12
                      WHEN sira_adi = 'A3- Gün Ýçindeki Toplam/Brüt Ödemeler' THEN 12.5
                      WHEN sira_adi = 'Yapýlan En Büyük Toplam/Brüt Ödeme' THEN 13
                      WHEN sira_adi = 'Alýnan En Büyük Toplam/Brüt Ödeme' THEN 14
                      WHEN sira_adi = 'A4- Zaman Kýsýtý Olan Yükümlülükler Toplamý (En Büyük)' THEN 15
                      WHEN sira_adi = 'C1- Gün Ýçi Ödeme Ýþlem Hacmi (%)' THEN 15.5
                      WHEN sira_adi = 'Saat 08:00''a Kadar' THEN 16
                      WHEN sira_adi = 'Saat 08:00 - 09:00 Arasý' THEN 17
                      WHEN sira_adi = 'Saat 09:00 - 10:00 Arasý' THEN 18
                      WHEN sira_adi = 'Saat 10:00 - 11:00 Arasý' THEN 19
                      WHEN sira_adi = 'Saat 11:00 - 12:00 Arasý' THEN 20
                      WHEN sira_adi = 'Saat 12:00 - 13:00 Arasý' THEN 21
                      WHEN sira_adi = 'Saat 13:00 - 14:00 Arasý' THEN 22
                      WHEN sira_adi = 'Saat 14:00 - 15:00 Arasý' THEN 23
                      WHEN sira_adi = 'Saat 15:00 - 16:00 Arasý' THEN 24
                      WHEN sira_adi = 'Saat 16:00 - 17:00 Arasý' THEN 25
                      WHEN sira_adi = 'Saat 17:00 - 18:00 Arasý' THEN 26
                  END;
        COMMIT;

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

    END SP_GI100AS;



    PROCEDURE SP_GI101AS (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

        v_tarih            DATE          := TRUNC(p_tarih);
        v_SqlCode          NUMBER (10);
        v_SqlCodeExp       VARCHAR2 (200);
        v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no          NUMBER        := $$PLSQL_LINE;
        v_sp_name          VARCHAR2 (40) := 'SP_GI101AS';
        v_sonraki_periyot  NUMBER := -15;
        v_tarih_cash203    DATE;
        v_tarih_aybasi     DATE          := TRUNC(v_tarih, 'MONTH');
        v_tarih_onceki_ay     DATE       := TRUNC(v_tarih, 'MONTH')-1;

       v_yil NUMBER(4) := TO_NUMBER(TO_CHAR(p_tarih, 'YYYY'));
       v_ay  NUMBER(2) := TO_NUMBER(TO_CHAR(p_tarih, 'MM'));

       b0               NUMBER(25, 2) := 0;
       b1               NUMBER(25, 2) := 0;
       b2               NUMBER(25, 2) := 0;
       b3               NUMBER(25, 2) := 0;
       b4               NUMBER(25, 2) := 0;
       b5               NUMBER(25, 2) := 0;
       b6               NUMBER(25, 2) := 0;
       b7               NUMBER(25, 2) := 0;
       b8               NUMBER(25, 2) := 0;
       b9               NUMBER(25, 2) := 0;
       b10              NUMBER(25, 2) := 0;
       b11              NUMBER(25, 2) := 0;
       b12              NUMBER(25, 2) := 0;
       a0               NUMBER(26, 2) := 0;
       a1               NUMBER(26, 2) := 0;
       a2               NUMBER(26, 2) := 0;
       a3               NUMBER(26, 2) := 0;
       a4               NUMBER(26, 2) := 0;
       a5               NUMBER(26, 2) := 0;
       a6               NUMBER(26, 2) := 0;
       a7               NUMBER(26, 2) := 0;
       a8               NUMBER(26, 2) := 0;
       a9               NUMBER(26, 2) := 0;
       a10              NUMBER(26, 2) := 0;
       a11              NUMBER(26, 2) := 0;
       a12              NUMBER(26, 2) := 0;
       btop             NUMBER(26, 2) := 0;
       atop             NUMBER(26, 2) := 0;
       v_bbalance       NUMBER(26, 2) := 0;
       v_uncertain      NUMBER(26, 2) := 0;
       v_abalance       NUMBER(26, 2) := 0;


    BEGIN
        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);

        v_line_no := $$PLSQL_LINE;

       v_tarih_cash203 := v_tarih;

    LOOP


        --USD

        SELECT sum(case when c.yil < v_yil then c.bookbalance1 + c.bookbalance2 + c.bookbalance3 + c.bookbalance4 + c.bookbalance5 +
                          c.bookbalance6 + c.bookbalance7 + c.bookbalance8 + c.bookbalance9 +
                          c.bookbalance10 + c.bookbalance11 + c.bookbalance12 end), --bulunulan yýldan önceki tüm bakiyeler (devreden book balance)

               SUM(case when  c.yil = v_yil then c.bookbalance1 end),
               SUM(case when  c.yil = v_yil then c.bookbalance2 end),
               SUM(case when  c.yil = v_yil then c.bookbalance3 end),
               SUM(case when  c.yil = v_yil then c.bookbalance4 end),
               SUM(case when  c.yil = v_yil then c.bookbalance5 end),
               SUM(case when  c.yil = v_yil then c.bookbalance6 end),
               SUM(case when  c.yil = v_yil then c.bookbalance7 end),
               SUM(case when  c.yil = v_yil then c.bookbalance8 end),
               SUM(case when  c.yil = v_yil then c.bookbalance9 end),
               SUM(case when  c.yil = v_yil then c.bookbalance10 end),
               SUM(case when  c.yil = v_yil then c.bookbalance11 end),
               SUM(case when  c.yil = v_yil then c.bookbalance11 end),

               sum(case when c.yil < v_yil then c.uncertain1 + c.uncertain2 + c.uncertain3 + c.uncertain4 + c.uncertain5 +
                          c.uncertain6 + c.uncertain7 + c.uncertain8 + c.uncertain9 + c.uncertain10 +
                          c.uncertain11 + c.uncertain12 end), --bulunulan yýldan önceki tüm bakiyeler (devreden uncertain)

               SUM(case when  c.yil = v_yil then c.uncertain1 end),
               SUM(case when  c.yil = v_yil then c.uncertain2 end),
               SUM(case when  c.yil = v_yil then c.uncertain3 end),
               SUM(case when  c.yil = v_yil then c.uncertain4 end),
               SUM(case when  c.yil = v_yil then c.uncertain5 end),
               SUM(case when  c.yil = v_yil then c.uncertain6 end),
               SUM(case when  c.yil = v_yil then c.uncertain7 end),
               SUM(case when  c.yil = v_yil then c.uncertain8 end),
               SUM(case when  c.yil = v_yil then c.uncertain9 end),
               SUM(case when  c.yil = v_yil then c.uncertain10 end),
               SUM(case when  c.yil = v_yil then c.uncertain11 end),
               SUM(case when  c.yil = v_yil then c.uncertain11 end)

               into b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12,
                    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12

               FROM extr.fs_cashdevir c
               WHERE c.muhbnk   = 'PNBP'
                 AND c.muhulke  = 'US'
                 AND c.muhbolge = '3N'
                 AND c.muhsube  = 'NYC'
                 AND c.yil <= v_yil
                 AND c.para = 1 --USD
                 and c.durum <> 9;

        v_line_no := $$PLSQL_LINE;


       IF v_ay = 1 THEN
          btop := 0;
          atop := 0;
       ELSIF v_ay = 2 THEN
          btop := b1;
          atop := a1;
       ELSIF v_ay = 3 THEN
          btop := b1 + b2;
          atop := a1 + a2;
       ELSIF v_ay = 4 THEN
          btop := b1 + b2 + b3;
          atop := a1 + a2 + a3;
       ELSIF v_ay = 5 THEN
          btop := b1 + b2 + b3 + b4;
          atop := a1 + a2 + a3 + a4;
       ELSIF v_ay = 6 THEN
          btop := b1 + b2 + b3 + b4 + b5;
          atop := a1 + a2 + a3 + a4 + a5;
       ELSIF v_ay = 7 THEN
          btop := b1 + b2 + b3 + b4 + b5 + b6;
          atop := a1 + a2 + a3 + a4 + a5 + a6;
       ELSIF v_ay = 8 THEN
          btop := b1 + b2 + b3 + b4 + b5 + b6 + b7;
          atop := a1 + a2 + a3 + a4 + a5 + a6 + a7;
       ELSIF v_ay = 9 THEN
          btop := b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8;
          atop := a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8;
       ELSIF v_ay = 10 THEN
          btop := b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8 + b9;
          atop := a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9;
       ELSIF v_ay = 11 THEN
          btop := b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8 + b9 + b10;
          atop := a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10;
       ELSIF v_ay = 12 THEN
          btop := b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8 + b9 + b10 + b11;
          atop := a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10 + a11;
       END IF;

        v_line_no := $$PLSQL_LINE;


      btop := btop + b0;
      atop := atop + a0;


        SELECT  nvl(sum(case when durum = 1 then
                                            case when islemtur = 'G' then c.tutar else c.tutar*-1 end
                        when durum = 2 then
                                            case when islemtur = 'G' then c.tutar else c.tutar*-1 end end), 0),

                nvl(sum(case when durum = 2 then  case when islemtur = 'G' then c.tutar else c.tutar*-1 end end), 0)

                into v_bbalance, v_uncertain
                              FROM extr.fs_cashflow c
                   WHERE c.muhbnk   = 'PNBP'
                 AND c.muhulke  = 'US'
                 AND c.muhbolge = '3N'
                 AND c.muhsube  = 'NYC'
                 AND c.valor >= v_tarih_aybasi --to_date('01/11/2017', 'dd/mm/yyyy')
                 AND c.valor < v_tarih_cash203 --to_date('30/11/2017', 'dd/mm/yyyy')
                 AND c.para = 1;

      btop := btop + v_bbalance;
      atop := atop + v_uncertain;

      v_abalance := abs(btop) + abs(atop);

      DELETE FROM trfm.TMP_CASH203_ACILIS_BAKIYE
              WHERE tarih = v_tarih_cash203;
      COMMIT;

      insert into
      TRFM.TMP_CASH203_ACILIS_BAKIYE
      (TARIH, PARA, BAKIYE, ETL_TRH, ETL_JOB)
      values (v_tarih_cash203, 1, v_abalance, sysdate, 'SP_GI101AS');

      commit;

            --dbms_output.put_line(v_tarih_cash203) ;

      v_tarih_cash203 := v_tarih_cash203 - 1;


       IF v_tarih_cash203 = v_tarih_onceki_ay  THEN
         EXIT;
       END IF;

    END LOOP;


        ------------------GI101AS RAPOR------------------

        DELETE FROM dm_infoman.GI101AS WHERE 1=1 AND tarih = v_tarih;
        COMMIT;

         --sýra 1 ve 2  En Büyük Pozitif/Negatif Net Kümülatif Pozisyon


         INSERT INTO dm_infoman.GI101AS
         SELECT
         v_tarih,
         'USD' parakodu,
         CASE WHEN pozitif in (1,2,3) THEN 1 ELSE 2 END SIRA_NO,
         CASE WHEN pozitif in (1,2,3) THEN 'En Büyük Pozitif Net Kümülatif Pozisyon' ELSE 'En Büyük Negatif Net Kümülatif Pozisyon' END SIRA_ADI,
         sum(CASE WHEN pozitif=1 OR negatif=1 THEN cumulative  end) deger1,
         sum(CASE WHEN pozitif=2 OR negatif=2 THEN cumulative end) deger2,
         sum(CASE WHEN pozitif=3 OR negatif=3 THEN cumulative end) deger3,
         avg(CASE WHEN pozitif in (1,2,3) THEN average_pozitif ELSE average_negatif end) ortalama,
         sysdate AS etl_trh,
         v_sp_name AS etl_job
         FROM
            (
            SELECT * FROM (

            SELECT
            valor,
            entry_date_time,
            sira_pozitif,
            sira_negatif,
            cumulative,
            average_pozitif,
            average_negatif,
            ROW_NUMBER() OVER (ORDER BY sira_pozitif, cumulative desc ) AS pozitif,
            ROW_NUMBER() OVER (ORDER BY sira_negatif, cumulative  ) AS negatif
            FROM
               (

               SELECT a.*,
               AVG(CASE WHEN sira_pozitif = 1 THEN cumulative END ) over (partition by 1) average_pozitif,
               sum(CASE WHEN sira_negatif = 1 AND cumulative < 0  THEN cumulative END ) over (partition by 1) / count(distinct valor) over (partition by 1) average_negatif
                FROM
                  (
                  SELECT valor, entry_date_time, cumulative, dr_cr,
                  ROW_NUMBER() OVER (partition by valor ORDER BY cumulative desc) sira_pozitif,
                  ROW_NUMBER() OVER (partition by valor ORDER BY cumulative asc) sira_negatif
                  FROM
                     (

                   SELECT
                     valor,
                     entry_date_time,
                     dr_cr,
                     amount,
                       sum(AMOUNT) over ( PARTITION BY valor order by sira, entry_date_time , rownum) cumulative
                     FROM (
                     SELECT value_date valor, entry_date_time , dr_cr,
                     case WHEN trim(dr_cr)='DR' THEN amount*-1 ELSE amount END amount,  2 AS sira
                     --FROM cihana.XL_PNBP a WHERE 1=1 AND entry_date_time BETWEEN v_tarih_aybasi AND v_tarih
                     FROM trfm.XL_PNBP where entry_date_time between v_tarih_aybasi AND v_tarih
                     union all
                     SELECT tarih, null, NULL, bakiye,  1 AS sira FROM TRFM.TMP_CASH203_ACILIS_BAKIYE c
                     WHERE 1=1 AND PARA = 1 AND tarih BETWEEN v_tarih_aybasi AND v_tarih
                     --AND exists (SELECT 1 FROM cihana.XL_PNBP a WHERE 1=1 AND a.value_date = c.tarih)
                     AND exists (SELECT 1 FROM trfm.XL_PNBP a WHERE 1=1 AND a.value_date = c.tarih and a.entry_date_time between v_tarih_aybasi AND v_tarih)

                     )

                     )
                  ) a WHERE sira_pozitif = 1 OR (sira_negatif = 1 AND cumulative < 0)

               )

            ) WHERE pozitif <= 3 OR negatif <= 3
            )


         GROUP BY
         CASE WHEN pozitif in (1,2,3) THEN 1 ELSE 2 END,
         CASE WHEN pozitif in (1,2,3) THEN 'En Büyük Pozitif Net Kümülatif Pozisyon' ELSE 'En Büyük Negatif Net Kümülatif Pozisyon' END;

         COMMIT;


--
--
--         INSERT INTO dm_infoman.GI101AS
--         SELECT
--         v_tarih,
--         'USD' parakodu, 1 AS SIRA_NO, 'En Büyük Pozitif Net Kümülatif Pozisyon' AS SIRA_ADI,
--         sum(CASE WHEN sira=1 THEN cumulative end) deger1,
--         sum(CASE WHEN sira=2 THEN cumulative end) deger2,
--         sum(CASE WHEN sira=3 THEN cumulative end) deger3,
--         max(average),
--         sysdate AS etl_trh,
--         v_sp_name AS etl_job
--         FROM
--            (
--            SELECT * FROM (
--            SELECT
--            valor,
--            entry_date_time,
--            cumulative,
--            average,
--            ROW_NUMBER() OVER (ORDER BY cumulative desc ) AS sira
--            FROM
--               (
--
--               SELECT a.*,
--               AVG(cumulative) over (partition by 1) average
--                FROM
--                  (
--                  SELECT valor, entry_date_time, cumulative,
--                  ROW_NUMBER() OVER (partition by valor ORDER BY cumulative desc) sira
--                  FROM
--                     (
--
--                   SELECT
--                     valor,
--                     entry_date_time,
--                     amount,
--                       sum(AMOUNT) over ( PARTITION BY valor order by sira, entry_date_time , rownum) cumulative
--                     FROM (
--                     SELECT value_date valor, entry_date_time ,
--                     case WHEN trim(dr_cr)='DR' THEN amount*-1 ELSE amount END amount,  2 AS sira
--                     FROM cihana.XL_PNBP a WHERE 1=1 AND entry_date_time BETWEEN v_tarih_aybasi AND v_tarih
--                     union all
--                     SELECT tarih, null,  bakiye,  1 AS sira FROM trfm.tmp_cash204_hist c WHERE 1=1 AND tarih BETWEEN v_tarih_aybasi AND v_tarih
--                     AND exists (SELECT 1 FROM cihana.XL_PNBP a WHERE 1=1 AND a.value_date = c.tarih)
--                     )
--
--                     )
--                  ) a WHERE 1=1 AND sira = 1
--
--               )
--
--            ) WHERE 1=1 AND sira <= 3
--            );
--
--         COMMIT;


--    v_line_no := $$PLSQL_LINE;
--
--    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PNBP_CUM',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
--
--    IF V_SQLCODE<>0 THEN
--         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
--    END IF;
--
--    v_line_no := $$PLSQL_LINE;
--
--     INSERT       /*+ APPEND */ INTO trfm.TMP_PNBP_CUM
--      SELECT account_no, TO_DATE(entry_date_time, 'dd.mm.yyyy') , TO_DATE(posting_date, 'dd.mm.yyyy'), to_date(value_date,'dd.mm.yyyy'), currency, amount, dr_cr,yukleme_sira_no,
--             sum(AMOUNT) over ( PARTITION BY POSTING_DATE order by POSTING_DATE,
--                        CASE WHEN dr_cr = 'AB' THEN 1 ELSE 2 END, --önce açýlýþ bakiyesi
--                        ENTRY_DATE_TIME,
--                        yukleme_sira_no --rows between unbounded preceding and 1 preceding
--      ) AS kumulatif_toplam
--       FROM (
--               SELECT ACCOUNT_NO,
--                      TO_DATE(ENTRY_DATE_TIME, 'dd-mon-yyyy hh24:mi')+(1/24/60/60) AS ENTRY_DATE_TIME,     --acilis bak. ile ayný ayda gelmemesi için +1 saniye ekledim. data dakika bazlýydý zaten.
--                      POSTING_DATE,
--                      VALUE_DATE,
--                      TRIM(CURRENCY) CURRENCY,
--                      CASE WHEN TRIM(DR_CR) = 'DR' THEN AMOUNT*-1 ELSE amount END AS amount,
--                      TRIM(DR_CR) DR_CR,
--                      yukleme_sira_no
--                FROM dep_data.xl_PNBP --dep_data
--                WHERE 1=1 AND TO_DATE(ENTRY_DATE_TIME, 'dd-mon-yyyy hh24:mi') BETWEEN TRUNC(v_tarih, 'MONTH') AND v_tarih --to_date( '01.08.2017','DD.MM.YYYY') AND to_date( '31.08.2017','DD.MM.YYYY')
--      );
--
--      COMMIT;


--    v_line_no := $$PLSQL_LINE;
--
--    TRFM.PKG_TRFM_UTIL_LIB.PRC_UTL_OBJECT('TMP_PNBP_SIRALAMA',NULL,NULL,'tt',V_SQLCODE,V_SQLCODEEXP);
--
--    IF V_SQLCODE<>0 THEN
--         RAISE_APPLICATION_ERROR(-20001,TO_CHAR(V_SQLCODE)||V_SQLCODEEXP);
--    END IF;
--
--    v_line_no := $$PLSQL_LINE;


--     INSERT       /*+ APPEND */ INTO trfm.TMP_PNBP_SIRALAMA
--      SELECT posting_date,
--             poz_max_degerler,
--             row_number() OVER (ORDER BY poz_max_degerler desc) AS poz_max_deger_sira,
--             negatif_min_degerler,
--             row_number() OVER (ORDER BY negatif_min_degerler asc) neg_min_deger_sira
--        FROM
--            (
--              SELECT POSTING_DATE,
--                     ROUND(MAX( kUMULATIF_TOPLAM)) poz_max_degerler,
--                     CASE WHEN ROUND(MIN( kUMULATIF_TOPLAM))>0 THEN 0 ELSE ROUND(MIN( kUMULATIF_TOPLAM)) end negatif_min_degerler
--                FROM trfm.TMP_PNBP_CUM
--            GROUP BY POSTING_DATE
--      );
--
--    COMMIT;



--         SELECT v_tarih, 'USD' parakodu, NULL AS sira_no, 'A1- Gün Ýçi Likidite Kullanýmý' AS sira_adi, NULL AS uc_deger_1, NULL AS uc_deger_2, NULL AS uc_deger_3, NULL AS ortalama, sysdate AS etl_trh,
--                v_sp_name AS etl_job
--         FROM dual
--         UNION ALL
--         SELECT v_tarih, 'USD' parakodu, 1 AS SIRA_NO, 'En Büyük Pozitif Net Kümülatif Pozisyon' AS SIRA_ADI,
--               (SELECT poz_max_degerler FROM trfm.TMP_PNBP_SIRALAMA WHERE 1=1 AND poz_max_deger_sira=1 ) AS UC_DEGER_1,
--               (SELECT poz_max_degerler FROM trfm.TMP_PNBP_SIRALAMA WHERE 1=1 AND poz_max_deger_sira=2 ) AS UC_DEGER_2,
--               (SELECT poz_max_degerler FROM trfm.TMP_PNBP_SIRALAMA WHERE 1=1 AND poz_max_deger_sira=3 ) AS UC_DEGER_3,
--               (SELECT avg(p_ort) FROM (SELECT avg(poz_max_degerler) AS p_ort,posting_date FROM trfm.TMP_PNBP_SIRALAMA GROUP BY posting_date)) AS ORTALAMA,
--               sysdate AS etl_trh,
--               v_sp_name AS etl_job
--         FROM dual
--         UNION ALL
--         SELECT v_tarih, 'USD' parakodu, 2 AS SIRA_NO, 'En Büyük Negatif Net Kümülatif Pozisyon' AS SIRA_ADI,
--               (SELECT negatif_min_degerler FROM trfm.TMP_PNBP_SIRALAMA WHERE 1=1 AND neg_min_deger_sira=1 ) AS UC_DEGER_1,
--               (SELECT negatif_min_degerler FROM trfm.TMP_PNBP_SIRALAMA WHERE 1=1 AND neg_min_deger_sira=2 ) AS UC_DEGER_2,
--               (SELECT negatif_min_degerler FROM trfm.TMP_PNBP_SIRALAMA WHERE 1=1 AND neg_min_deger_sira=3 ) AS UC_DEGER_3,
--               (SELECT avg(n_ort) FROM (SELECT avg(negatif_min_degerler) AS n_ort,posting_date FROM trfm.TMP_PNBP_SIRALAMA GROUP BY posting_date)) AS ORTALAMA,
--               sysdate AS etl_trh,
--               v_sp_name AS etl_job
--         FROM dual ;



          /*
DROP TABLE tmp_PNBP_cum_v2;

create table tmp_PNBP_cum_v2  PARALLEL (DEGREE 8 INSTANCES 1) NOLOGGING as
SELECT account_no, entry_date_time, posting_date, value_date, currency, amount, dr_cr,yukleme_sira_no,
       sum(AMOUNT) over ( PARTITION BY POSTING_DATE
         order by POSTING_DATE,
                  CASE WHEN dr_cr = 'AB' THEN 1 ELSE 2 END, --önce açýlýþ bakiyesi
                  ENTRY_DATE_TIME,
                  yukleme_sira_no --rows between unbounded preceding and 1 preceding
) AS kumulatif_toplam
 FROM (
         SELECT ACCOUNT_NO,
                ENTRY_DATE_TIME+(1/24/60/60) AS ENTRY_DATE_TIME,     --acilis bak. ile ayný ayda gelmemesi için +1 saniye ekledim. data dakika bazlýydý zaten.
                POSTING_DATE,
                VALUE_DATE, CURRENCY,
                CASE WHEN dr_cr= 'DR' THEN AMOUNT*-1 ELSE amount END AS amount,
                DR_CR,
                yukleme_sira_no
          FROM trfm.xl_PNBP
          WHERE 1=1 AND ENTRY_DATE_TIME BETWEEN to_date( '01.08.2017','DD.MM.YYYY') AND to_date( '31.08.2017','DD.MM.YYYY')
       UNION ALL
          SELECT NULL AS ACCOUNT_NO,
--                 a.trh,
                 (SELECT min(t.date_value) FROM PRSN.TARIH t WHERE 1=1 AND t.date_value> a.tarih AND weekend_flag=0) AS ENTRY_DATE_TIME,
                 (SELECT min(t.date_value) FROM PRSN.TARIH t WHERE 1=1 AND t.date_value> a.tarih AND weekend_flag=0) AS POSTING_DATE,
                 NULL AS VALUE_DATE,
                 'USD' AS CURRENCY,
                 a.PNBP, --a.acilis_bak AS AMOUNT,
                 'AB' AS DR_CR,
                 0 AS yukleme_sira_no
           FROM  dep_data.XL_MUHABIR_ACILIS_BAKIYELERI a
           WHERE 1=1 AND a.tarih BETWEEN to_date( '01.08.2017','DD.MM.YYYY')-1 AND to_date( '31.08.2017','DD.MM.YYYY')-1
--                  (
--                  SELECT 455245 AS acilis_bak, to_date( '02.05.2017','DD.MM.YYYY') trh FROM dual
--                  UNION ALL
--                  SELECT 3903144 AS acilis_bak, to_date( '03.05.2017','DD.MM.YYYY') trh FROM dual
--                  UNION ALL
--                  SELECT 480539 AS acilis_bak, to_date( '04.05.2017','DD.MM.YYYY') trh FROM dual
--                  UNION ALL
--                  SELECT 1156495 AS acilis_bak, to_date( '05.05.2017','DD.MM.YYYY') trh FROM dual
--                 UNION ALL
--                  SELECT 551359 AS acilis_bak, to_date( '08.05.2017','DD.MM.YYYY') trh FROM dual
--                  UNION ALL
--                  SELECT 1290992 AS acilis_bak, to_date( '09.05.2017','DD.MM.YYYY') trh FROM dual
--                  UNION ALL
--                  SELECT 216596 AS acilis_bak, to_date( '10.05.2017','DD.MM.YYYY') trh FROM dual
--                  ) a
                  --                  INNER JOIN PRSN.TARIH t ON a.trh = T.DATE_VALUE
        );




--SELECT DATE_VALUE, MIS_PREV_WORKDAY, MIS_NEXT_WORKDAY
--FROM PRSN.TARIH
--WHERE 1=1 AND date_value = mis_prev_workday
--AND date_value = trunc(sysdate-1)

DROP TABLE tmp_PNBP_siralama_v2;

create table  tmp_PNBP_siralama_v2 NOLOGGING as
SELECT posting_date,
       poz_max_degerler,
       row_number() OVER (ORDER BY poz_max_degerler desc) AS poz_max_deger_sira,
       negatif_min_degerler,
       row_number() OVER (ORDER BY negatif_min_degerler asc) neg_min_deger_sira
  FROM
      (
        SELECT POSTING_DATE,
               ROUND(MAX( kUMULATIF_TOPLAM)) poz_max_degerler,
               CASE WHEN ROUND(MIN( kUMULATIF_TOPLAM))>0 THEN 0 ELSE ROUND(MIN( kUMULATIF_TOPLAM)) end negatif_min_degerler
          FROM tmp_PNBP_cum_v2
      GROUP BY POSTING_DATE
      );




SELECT * FROM trfm.xl_PNBP;

SELECT * FROM tmp_PNBP_cum_v2
ORDER BY posting_date,
         CASE WHEN dr_cr = 'AB' THEN 1 ELSE 2 END, --önce açýlýþ bakiyesi
                  ENTRY_DATE_TIME,
                  yukleme_sira_no;

SELECT * FROM tmp_PNBP_siralama_v2;



SELECT NULL AS sira_no, 'A1- Gün Ýçi Likidite Kullanýmý' AS sira_adi, NULL AS uc_deger_1, NULL AS uc_deger_2, NULL AS uc_deger_3, NULL AS ortalama
FROM dual
UNION ALL
SELECT 1 AS SIRA_NO, 'En Büyük Pozitif Net Kümülatif Pozisyon' AS SIRA_ADI,
      (SELECT poz_max_degerler FROM tmp_PNBP_siralama_v2 WHERE 1=1 AND poz_max_deger_sira=1 ) AS UC_DEGER_1,
      (SELECT poz_max_degerler FROM tmp_PNBP_siralama_v2 WHERE 1=1 AND poz_max_deger_sira=2 ) AS UC_DEGER_2,
      (SELECT poz_max_degerler FROM tmp_PNBP_siralama_v2 WHERE 1=1 AND poz_max_deger_sira=3 ) AS UC_DEGER_3,
      (SELECT avg(p_ort) FROM (SELECT avg(poz_max_degerler) AS p_ort,posting_date FROM tmp_PNBP_siralama_v2 GROUP BY posting_date)) AS ORTALAMA
FROM dual
UNION ALL
SELECT 2 AS SIRA_NO, 'En Büyük Negatif Net Kümülatif Pozisyon' AS SIRA_ADI,
      (SELECT negatif_min_degerler FROM tmp_PNBP_siralama_v2 WHERE 1=1 AND neg_min_deger_sira=1 ) AS UC_DEGER_1,
      (SELECT negatif_min_degerler FROM tmp_PNBP_siralama_v2 WHERE 1=1 AND neg_min_deger_sira=2 ) AS UC_DEGER_2,
      (SELECT negatif_min_degerler FROM tmp_PNBP_siralama_v2 WHERE 1=1 AND neg_min_deger_sira=3 ) AS UC_DEGER_3,
      (SELECT avg(n_ort) FROM (SELECT avg(negatif_min_degerler) AS n_ort,posting_date FROM tmp_PNBP_siralama_v2 GROUP BY posting_date)) AS ORTALAMA
FROM dual ;




*/

        -- END LOG

        v_line_no := $$PLSQL_LINE;

        ETL.PKG_UTIL_LIB.prc_log_end;

        DBMS_APPLICATION_INFO.set_module(NULL,NULL);

        EXCEPTION WHEN OTHERS THEN
          v_SqlCode := SQLCODE;
          v_SqlCodeExp := SUBSTR (SQLERRM (v_SqlCode), 1, 400);

          --FAILURE LOG
          etl.pkg_util_lib.prc_log_fail (v_SqlCode, v_SqlCodeExp, v_line_no);

          RAISE;

    END SP_GI101AS;

    PROCEDURE SP_GI102AS (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) )
    IS

        v_tarih            DATE          := TRUNC(p_tarih);
        v_SqlCode          NUMBER (10);
        v_SqlCodeExp       VARCHAR2 (200);
        v_etl_tarih        VARCHAR2 (8)  := TO_CHAR (p_tarih, 'YYYYMMDD');
        v_line_no          NUMBER        := $$PLSQL_LINE;
        v_sp_name          VARCHAR2 (40) := 'SP_GI102AS';

        v_m_bastar         DATE:= TRUNC(v_tarih,'MM');


    BEGIN
        ETL.PKG_UTIL_LIB.prc_log_begin (g_module_name,g_package_name,g_owner,v_sp_name,v_etl_tarih,g_is_restartable);

        DELETE FROM dm_infoman.gi102as WHERE 1=1 AND tarih BETWEEN v_m_bastar AND v_tarih;
        COMMIT;
        v_line_no := $$PLSQL_LINE;


        DELETE FROM trfm.tmp_gi102as_b1_kynk WHERE 1=1 AND fistarih BETWEEN v_m_bastar AND v_tarih;
        COMMIT;

        v_line_no := $$PLSQL_LINE;

        INSERT               /*+ APPEND */ INTO trfm.tmp_gi102as_b1_kynk
        SELECT sube, fistarih, fissicil, fisno, fissatir, fiszaman, islsube, sinif, ilk7, hestur, ekno, valor, tutar, kmhtutar, bakod, para, acik1, acik2, musteri, irefsube,
               ireftur, irefsirano, hserino, cuzdan, cuzdan_iptsw, hareket_tip, dab_tip, vade, secenek, onaylayan, subestatus, durum, updtarih, updzaman, updprogram, updsicil,
               SYSDATE AS ETL_TRH, v_sp_name AS ETL_JOB
          FROM extr.FS_HRKTDET_SG  a
         WHERE 1=1
               AND a.fistarih BETWEEN v_m_bastar AND v_tarih
               AND a.bakod = 'B'
               AND CASE WHEN a.kmhtutar = 3080600 AND a.acik1 LIKE 'GÝDEN EFT%' THEN 1
                        WHEN a.kmhtutar = 3090600 AND RTRIM(a.acik1) = 'MAHSUP FÝÞÝ' THEN 1
                        ELSE 0
                   END = 1
               AND a.para IN ( 0,1,25)
               AND a.islsube = 5
               AND a.sinif = 'C';
        COMMIT;

        v_line_no := $$PLSQL_LINE;

        INSERT INTO dm_infoman.gi102as
        WITH degerler_B1 AS
        (
        SELECT SUM(a.tutar) AS tutar,
               a.fistarih,
               a.kmhtutar,
               a.para,
               ROW_NUMBER() OVER (PARTITION BY a.kmhtutar, a.para ORDER BY SUM(a.tutar) DESC) AS tutar_sira
          FROM trfm.tmp_gi102as_b1_kynk a
         WHERE 1=1
               AND a.fistarih BETWEEN v_m_bastar AND v_tarih
       GROUP BY a.fistarih, a.kmhtutar, a.para
        )
         SELECT v_tarih AS tarih,
                1 AS sira_no,
                'B1- Muhabir Bankacýlýk Müþterileri Adýna Yapýlan Toplam/Brüt Ödemeler' AS sira_adi,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3080600 AND tutar_sira = 1) AS en_buyuk_deger_1,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3080600 AND tutar_sira = 2) AS en_buyuk_deger_2,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3080600 AND tutar_sira = 3) AS en_buyuk_deger_3,
                (SELECT round(avg(tutar)) AS avg_tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3080600 ) AS ortalama,
                0 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
         UNION ALL
         SELECT v_tarih AS tarih,
                1 AS sira_no,
                'B1- Muhabir Bankacýlýk Müþterileri Adýna Yapýlan Toplam/Brüt Ödemeler' AS sira_adi,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 1 AND tutar_sira = 1) AS en_buyuk_deger_1,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 1 AND tutar_sira = 2) AS en_buyuk_deger_2,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 1 AND tutar_sira = 3) AS en_buyuk_deger_3,
                (SELECT round(avg(tutar)) AS avg_tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 1 ) AS ortalama,
                1 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
        UNION ALL
         SELECT v_tarih AS tarih,
                1 AS sira_no,
                'B1- Muhabir Bankacýlýk Müþterileri Adýna Yapýlan Toplam/Brüt Ödemeler' AS sira_adi,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 25 AND tutar_sira = 1) AS en_buyuk_deger_1,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 25 AND tutar_sira = 2) AS en_buyuk_deger_2,
                (SELECT tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 25 AND tutar_sira = 3) AS en_buyuk_deger_3,
                (SELECT round(avg(tutar)) AS avg_tutar FROM degerler_B1 WHERE 1=1 AND kmhtutar=3090600 AND para= 25 ) AS ortalama,
                25 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL;
COMMIT;
            v_line_no := $$PLSQL_LINE;


                        /*
      SELECT * FROM trfm.TMP_GI102AS_B2_KAYNAK WHERE 1=1 AND TO_DATE( '01.06.2017','DD.MM.YYYY') AND TO_DATE( '30.06.2017','DD.MM.YYYY')
      */


      DELETE FROM trfm.tmp_gi102as_b2_kaynak WHERE 1=1 AND fistarih BETWEEN  v_m_bastar AND v_tarih;
      COMMIT;
      v_line_no := $$PLSQL_LINE;


      INSERT                   /*+ APPEND */ INTO trfm.tmp_gi102as_b2_kaynak
          SELECT fistarih, updtarih, updzaman, acik1, kmhtutar, fisno, ilk7, hestur, ekno, sinif, sube, islsube, bakod, bak, tutar,
                 SUM(u.bak) OVER (PARTITION BY sube, sinif, ekno, hestur, ilk7--, fistarih
                                  ORDER BY u.fistarih,u.updtarih,u.updzaman
                                  RANGE UNBOUNDED PRECEDING) bakiye,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM (
                     SELECT v_m_bastar AS fistarih,
                            v_m_bastar AS updtarih,
                            '00:00:00.00001' AS updzaman,
                            '***** DEVIR BAKIYE *****' AS acik1,
                            3080600 AS kmhtutar,
                            NULL AS fisno,
                            d.ilk7,
                            d.hestur,
                            d.ekno,
                            d.sinif,
                            d.sube,
                            d.sube as islsube,
                            'B' AS bakod,
                           --(alac1+alac2+alac3+alac4+alac5)-(borc1+borc2+borc3+borc4+borc5),
                            (CASE
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=1  THEN 0
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=2  THEN d.alac1 - d.borc1
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=3  THEN (d.alac1+d.alac2)-(d.borc1+d.borc2)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=4  THEN (d.alac1+d.alac2+d.alac3) - (d.borc1+d.borc2+d.borc3)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=5  THEN (d.alac1+d.alac2+d.alac3+d.alac4) - (d.borc1+d.borc2+d.borc3+d.borc4)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=6  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5)- (d.borc1+d.borc2+d.borc3+d.borc4+d.borc5)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=7  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=8  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=9  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=10 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=11 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9+d.alac10)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9+d.borc10)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=12 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9+d.alac10+d.alac11)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9+d.borc10+d.borc11)
                     --           WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=12 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9+d.alac10+d.alac11+d.alac12)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9+d.borc10+d.borc11+d.borc12)
                            END) AS bak, --devir_bakiye
                            (CASE
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=1  THEN 0
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=2  THEN d.alac1 - d.borc1
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=3  THEN (d.alac1+d.alac2)-(d.borc1+d.borc2)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=4  THEN (d.alac1+d.alac2+d.alac3) - (d.borc1+d.borc2+d.borc3)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=5  THEN (d.alac1+d.alac2+d.alac3+d.alac4) - (d.borc1+d.borc2+d.borc3+d.borc4)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=6  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5)- (d.borc1+d.borc2+d.borc3+d.borc4+d.borc5)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=7  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=8  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=9  THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=10 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=11 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9+d.alac10)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9+d.borc10)
                                WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=12 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9+d.alac10+d.alac11)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9+d.borc10+d.borc11)
                     --           WHEN TO_NUMBER(TO_CHAR(v_tarih,'mm'))=12 THEN (d.alac1+d.alac2+d.alac3+d.alac4+d.alac5+d.alac6+d.alac7+d.alac8+d.alac9+d.alac10+d.alac11+d.alac12)-(d.borc1+d.borc2+d.borc3+d.borc4+d.borc5+d.borc6+d.borc7+d.borc8+d.borc9+d.borc10+d.borc11+d.borc12)
                            END) AS tutar
                       FROM extr.fs_hplandet_sg d
                            INNER JOIN (SELECT DISTINCT ilk7, hestur, ekno, sinif,sube
                                          FROM extr.FS_HRKTDET_SG
                                         WHERE 1=1
                                               AND fistarih BETWEEN v_m_bastar  AND  v_tarih
                                               AND sube = 5       --islsube
                                               AND SINIF = 'C'
                                               AND durum = 0
                                               AND kmhtutar = 3080600
                                       ) f ON f.ilk7= d.ilk7 AND  f.hestur= D.HESTUR AND  f.ekno= d.ekno AND f.sinif= d.sinif AND  f.sube = d.sube
                     WHERE 1=1
                     AND  d.sube = 5
--                                    and ilk7 = 76957
                     --and hestur = 'MT'
                     --and ekno = 1
                     AND yil = EXTRACT (YEAR FROM v_tarih)
                 UNION ALL
                       SELECT a.fistarih,a.updtarih,a.updzaman,a.acik1, a.kmhtutar, a.fisno, a.ilk7, a.hestur, a.ekno, a.sinif, a.sube, a.islsube, a.bakod,
                           (CASE bakod WHEN 'A' THEN  NVL(tutar,0)
                                                 ELSE  -NVL(tutar,0)
                                                 END) bak,
                            tutar
                       FROM extr.FS_HRKTDET_SG a
 --                           LEFT JOIN extr.FS_MUSTERI_MASTER m on a.ilk7 = m.musteri_no
                      WHERE 1=1
                            AND a.fistarih BETWEEN v_m_bastar  AND v_tarih
                            --and a.kmhtutar = 3080600
                            --and a.bakod = 'B'
                            AND a.sube = 5       --islsube
                            AND a.sinif = 'C'
                            AND durum = 0
                 ) u
         WHERE 1=1;

         COMMIT;

             v_line_no := $$PLSQL_LINE;


         INSERT INTO dm_infoman.GI102AS
         WITH degerler_B2_gunluk_ilk7 AS
          (
             SELECT fistarih,ilk7,
                    (bakiye) AS gunluk_tplm_bky,
                    ROW_NUMBER() OVER (PARTITION BY fistarih, ilk7 ORDER BY (bakiye) ASC) AS tutar_ilk7_sira
               FROM trfm.TMP_GI102AS_B2_KAYNAK
               WHERE 1=1
                     and kmhtutar = 3080600
                     AND islsube = 5
                     AND (acik1 like 'GÝDEN EFT%' OR acik1 = '***** DEVIR BAKIYE *****' )
                     AND bakod = 'B'
                     AND bakiye <0
                    AND fistarih BETWEEN v_m_bastar AND v_tarih
--                    AND ilk7 = 75055
--           GROUP BY fistarih,ilk7
          ),
        degerler_B2_gunluk AS
        (
         SELECT fistarih, sum(gunluk_tplm_bky) AS gunluk_tplm_bky,
                ROW_NUMBER() OVER (ORDER BY sum(gunluk_tplm_bky) ASC) AS tutar_sira
           FROM degerler_B2_gunluk_ilk7 WHERE 1=1 AND tutar_ilk7_sira = 1 GROUP BY fistarih
        )
          SELECT v_tarih AS tarih,
                 2 AS sira_no,
                 'B2- Muhabir Bankacýlýk Müþterilerine Saðlanan Kredi Limitleri' AS sira_adi,
                 (SELECT gunluk_tplm_bky FROM degerler_B2_gunluk WHERE 1=1 AND tutar_sira = 1) AS en_buyuk_deger_1,
                 (SELECT gunluk_tplm_bky FROM degerler_B2_gunluk WHERE 1=1 AND tutar_sira = 2) AS en_buyuk_deger_2,
                 (SELECT gunluk_tplm_bky FROM degerler_B2_gunluk WHERE 1=1 AND tutar_sira = 3) AS en_buyuk_deger_3,
                 (SELECT ROUND(AVG(gunluk_tplm_bky)) AS avg_tutar FROM degerler_B2_gunluk) AS ortalama,
                 0 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
         UNION ALL
          SELECT v_tarih AS tarih,
                 2 AS sira_no,
                 'B2- Muhabir Bankacýlýk Müþterilerine Saðlanan Kredi Limitleri' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 1 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
                  UNION ALL
          SELECT v_tarih AS tarih,
                 2 AS sira_no,
                 'B2- Muhabir Bankacýlýk Müþterilerine Saðlanan Kredi Limitleri' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 25 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL;

        COMMIT;
        v_line_no := $$PLSQL_LINE;

        INSERT INTO dm_infoman.GI102AS
          SELECT v_tarih AS tarih,
                 3 AS sira_no,
                 'a) Teminatlý' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 0 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
        UNION ALL
          SELECT v_tarih AS tarih,
                 3 AS sira_no,
                 'a) Teminatlý' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 1 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
        UNION ALL
          SELECT v_tarih AS tarih,
                 3 AS sira_no,
                 'a) Teminatlý' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 25 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL;
        COMMIT;

         v_line_no := $$PLSQL_LINE;



        DELETE FROM trfm.tmp_gi102as_b_kynk WHERE 1=1 AND fistarih BETWEEN v_m_bastar AND v_tarih;
        COMMIT;

        v_line_no := $$PLSQL_LINE;

      INSERT               /*+ APPEND */ INTO trfm.tmp_gi102as_b_kynk
        SELECT h.tutar, h.fistarih,
               h.sube, h.fissicil, h.fisno, h.fissatir, h.fiszaman, h.islsube, h.sinif, h.ilk7, h.hestur, h.ekno, h.valor, h.kmhtutar, h.bakod, h.para,
               h.acik1, h.acik2, h.musteri, h.irefsube, h.ireftur, h.irefsirano, h.hserino, h.cuzdan, h.cuzdan_iptsw, h.hareket_tip, h.dab_tip, h.vade,
               h.secenek, h.onaylayan, h.subestatus, h.durum, h.updtarih, h.updzaman, h.updprogram, h.updsicil,
               ROW_NUMBER() OVER (ORDER BY -nvl(h.tutar,0) ASC) AS tutar_sira
          FROM extr.fs_hrktdet_sg h
         WHERE 1=1
               AND kmhtutar = 3080600        --3090600
               AND bakod = 'A'
               AND fistarih BETWEEN v_m_bastar AND v_tarih
               AND h.durum     = 0
               AND acik1 like '%PL YT%';

         COMMIT;

        v_line_no := $$PLSQL_LINE;

      INSERT INTO dm_infoman.GI102AS
      WITH degerler_B2_4_gun_tplm AS
          (
          SELECT fistarih,
                 145000000-SUM(tutar) AS tutar,
                 ROW_NUMBER() OVER (ORDER BY NVL(145000000-SUM(tutar),0) DESC) AS tutar_sira
            FROM trfm.tmp_gi102as_b_kynk h
           WHERE 1=1
                 AND fistarih BETWEEN v_m_bastar AND v_tarih
         GROUP BY fistarih
          )
          SELECT v_tarih AS tarih,
                 4 AS sira_no,
                 'b) Taahhüt Edilmiþ' AS sira_adi,
                (SELECT tutar FROM degerler_B2_4_gun_tplm WHERE 1=1 AND tutar_sira = 1) AS en_buyuk_deger_1,
                (SELECT tutar FROM degerler_B2_4_gun_tplm WHERE 1=1 AND tutar_sira = 2) AS en_buyuk_deger_2,
                (SELECT tutar FROM degerler_B2_4_gun_tplm WHERE 1=1 AND tutar_sira = 3) AS en_buyuk_deger_3,
                (SELECT ROUND(AVG(tutar)) AS avg_tutar FROM degerler_B2_4_gun_tplm) AS ortalama,
                0 AS para,
                sysdate AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
         UNION ALL
          SELECT v_tarih AS tarih,
                 4 AS sira_no,
                 'b) Taahhüt Edilmiþ' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 1 AS para,
                SYSDATE AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL
        UNION ALL
          SELECT v_tarih AS tarih,
                 4 AS sira_no,
                 'b) Taahhüt Edilmiþ' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 25 AS para,
                SYSDATE AS etl_trh,
                v_sp_name AS etl_job
            FROM sys.DUAL;

            COMMIT;

         v_line_no := $$PLSQL_LINE;

        INSERT INTO dm_infoman.GI102AS
          WITH degerler_B2_5 AS
          (
             SELECT SUM(h.tutar) AS tutar, h.fistarih,
                    ROW_NUMBER() OVER (ORDER BY SUM(NVL(h.tutar,0)) DESC) AS tutar_sira
               FROM trfm.tmp_gi102as_b_kynk h
              WHERE 1=1
                    AND fistarih BETWEEN v_m_bastar AND v_tarih
           GROUP BY h.fistarih
          )
          SELECT v_tarih AS tarih,
                 5 AS sira_no,
                 'Tamamý Kullanýlan Limitler' AS sira_adi,
                 (SELECT tutar FROM degerler_B2_5 WHERE 1=1 AND tutar_sira = 1) AS en_buyuk_deger_1,
                 (SELECT tutar FROM degerler_B2_5 WHERE 1=1 AND tutar_sira = 2) AS en_buyuk_deger_2,
                 (SELECT tutar FROM degerler_B2_5 WHERE 1=1 AND tutar_sira = 3) AS en_buyuk_deger_3,
                 (SELECT round(avg(tutar)) AS avg_tutar FROM degerler_B2_5) AS ortalama,
                 0 AS para,
                 SYSDATE AS etl_trh,
                 v_sp_name AS etl_job
            FROM sys.DUAL
        UNION ALL
          SELECT v_tarih AS tarih,
                 5 AS sira_no,
                 'Tamamý Kullanýlan Limitler' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 1 AS para,
                 SYSDATE AS etl_trh,
                 v_sp_name AS etl_job
            FROM sys.DUAL
        UNION ALL
          SELECT v_tarih AS tarih,
                 5 AS sira_no,
                 'Tamamý Kullanýlan Limitler' AS sira_adi,
                 0 AS en_buyuk_deger_1,
                 0 AS en_buyuk_deger_2,
                 0 AS en_buyuk_deger_3,
                 0 AS ortalama,
                 25 AS para,
                 SYSDATE AS etl_trh,
                 v_sp_name AS etl_job
            FROM sys.DUAL;
    COMMIT;

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

    END SP_GI102AS;

END PKG_BDDK_GUN_ICI_LKDT_YNTM;
/