CREATE OR REPLACE PACKAGE DM_INFOMAN.PKG_BDDK_GUN_ICI_LKDT_YNTM
IS
PROCEDURE SP_MAIN (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE SP_DEPO_KOD_005 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE SP_DEPO_KOD_540 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE SP_DEPO_KOD_903 (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE SP_GI100AS (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE SP_GI101AS (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
PROCEDURE SP_GI102AS (p_tarih IN DATE DEFAULT TRUNC(SYSDATE-1) );
END PKG_BDDK_GUN_ICI_LKDT_YNTM;
/