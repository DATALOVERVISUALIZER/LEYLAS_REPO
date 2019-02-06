CREATE OR REPLACE PACKAGE ETL.PKG_KKB_TZL
IS
PROCEDURE sp_main (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
-------------FCT-------------
PROCEDURE sp_trbgr_p1 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbip (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbfc_trbic (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbac (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbgr_p2 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
---------------------TXT-------------------
PROCEDURE sp_trbef_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbfc_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbgr_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbhf_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbic_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
--
PROCEDURE sp_trbfc_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbac_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbgr_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbic_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbip_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
--
PROCEDURE sp_trbgr_sonrs_trbfc_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbgr_sonrs_trbic_txt (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbgr_sonrs_trbfc_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_trbgr_sonrs_trbic_txt_krd (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
----
PROCEDURE sp_tkkb_rapor_gonderim_sorgu (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE sp_kkb_export (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
END pkg_kkb_tzl;
/