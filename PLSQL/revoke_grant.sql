
REVOKE  DELETE, INSERT,  UPDATE ON TRFM.TMEK_HARIC_MUSTERI_TMP01 FROM R_OFSDATA;


REVOKE DELETE, INSERT, UPDATE ON TRFM.TMEK_HARIC_MUSTERI_TMP02  FROM  R_OFSDATA,OFSDATA;


REVOKE DELETE, INSERT,  UPDATE ON TRFM.TMEK_HARIC_MUSTERI_TMP03  FROM R_OFSDATA,OFSDATA;


REVOKE DELETE, INSERT,  UPDATE ON  TRFM.TEMMEKMAS_N  FROM  R_OFSDATA,OFSDATA;


REVOKE DELETE, INSERT,  UPDATE ON EXTR.FS_TEKLIF_MASTER_EKBILGI FROM GGUNEL;

REVOKE SELECT ON EXTR.FS_TEKLIF_MASTER_EKBILGI FROM  MURATCE;

REVOKE  DELETE, INSERT, UPDATE ON EXTR.FS_TEKLIF_MASTER_EKBILGI FROM R_OFSDATA;

REVOKE  DELETE, INSERT, UPDATE ON EXTR.FS_TEKLIF_MASTER_EKBILGI FROM  XNEXT_REPORT ;