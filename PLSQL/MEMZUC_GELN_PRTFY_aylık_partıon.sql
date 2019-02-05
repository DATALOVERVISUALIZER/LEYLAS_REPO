DROP TABLE DM_INFOMAN.MEMZUC_GELN_PRTFY CASCADE CONSTRAINTS;

CREATE TABLE DM_INFOMAN.MEMZUC_GELN_PRTFY
(
  DNM                  NUMBER(10),
  MUS_NO               NUMBER(10),
  CLSM_SKL             NUMBER(5),
  UNVN                 VARCHAR2(54 BYTE),
  GRP                  NUMBER(10),
  GRP_AD               VARCHAR2(40 BYTE),
  ANA_SUBE_KOD         NUMBER(5),
  SUBE_AD              VARCHAR2(40 BYTE),
  BOLGE_AD             VARCHAR2(30 BYTE),
  PRTFY_KOD            VARCHAR2(10 BYTE),
  VKN                  VARCHAR2(11 BYTE),
  RSK_KOD_ACKLM        VARCHAR2(52 BYTE),
  TKP_BKY              NUMBER,
  LMT                  NUMBER,
  TPLM_MEMZUC_BKY      NUMBER,
  BANK_ADET            NUMBER,
  TPLM_RSK             NUMBER,
  RSK_KOD              NUMBER,
  KISA_VADE            NUMBER,
  ORTA_VADE            NUMBER,
  UZN_VADE             NUMBER,
  FAIZ                 NUMBER,
  TAHKUK               NUMBER,
  BSLNG_TRH            DATE,
  BTIS_TRH             DATE,
  BANK_NKT_RSK         NUMBER,
  BANK_GNAKDI_RSK      NUMBER,
  BANK_FIRM_LIMIT      NUMBER(18,2),
  BANK_NPL_NKT_RSK     NUMBER,
  BANK_NPL_GNAKDI_RSK  NUMBER,
  BANK_TPLM_RSK        NUMBER,
  ING_SKTR             NUMBER,
  ING_SKTR_ACKLM_TR    VARCHAR2(500 BYTE),
  ING_SKTR_ACKLM_EN    VARCHAR2(500 BYTE),
  YTK_SVY              VARCHAR2(40 BYTE),
  YTK_SVY_ACKLM        VARCHAR2(1000 BYTE),
  RTG                  VARCHAR2(15 BYTE),
  KRNOTU               VARCHAR2(1 BYTE),
  YAKN_GZLM_DRM        NUMBER,
  PRTFY_SHP_ACKLM      VARCHAR2(40 BYTE),
  P                    NUMBER,
  KRD_YNLM_VADE        DATE,
  SIM_TRH              DATE,
  SIM_CIRO             NUMBER(20,2),
  BANK_TRH             DATE,
  BANK_CIRO            NUMBER(20,2),
  MUS_TIP              NUMBER(5),
  ETL_TRH              DATE,
  ETL_JOB              VARCHAR2(40 BYTE)
)
COMPRESS FOR QUERY HIGH 
TABLESPACE OFSDATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    0
INITRANS   1
MAXTRANS   255
STORAGE    (
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
NOLOGGING
PARTITION BY LIST (DNM)
(  
  PARTITION P_201311 VALUES (201311)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201312 VALUES (201312)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201401 VALUES (201401)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201402 VALUES (201402)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201403 VALUES (201403)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201404 VALUES (201404)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201405 VALUES (201405)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201406 VALUES (201406)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201407 VALUES (201407)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201408 VALUES (201408)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201409 VALUES (201409)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201410 VALUES (201410)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201411 VALUES (201411)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201412 VALUES (201412)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201501 VALUES (201501)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201502 VALUES (201502)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201503 VALUES (201503)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201504 VALUES (201504)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201505 VALUES (201505)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201506 VALUES (201506)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201507 VALUES (201507)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201508 VALUES (201508)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201509 VALUES (201509)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201510 VALUES (201510)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201511 VALUES (201511)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201512 VALUES (201512)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201601 VALUES (201601)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201602 VALUES (201602)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201603 VALUES (201603)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201604 VALUES (201604)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201605 VALUES (201605)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201606 VALUES (201606)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201607 VALUES (201607)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201608 VALUES (201608)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201609 VALUES (201609)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201610 VALUES (201610)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201611 VALUES (201611)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201612 VALUES (201612)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201701 VALUES (201701)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201702 VALUES (201702)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201703 VALUES (201703)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201704 VALUES (201704)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201705 VALUES (201705)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201706 VALUES (201706)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201707 VALUES (201707)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201708 VALUES (201708)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201709 VALUES (201709)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201710 VALUES (201710)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201711 VALUES (201711)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201712 VALUES (201712)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201801 VALUES (201801)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201802 VALUES (201802)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201803 VALUES (201803)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201804 VALUES (201804)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201805 VALUES (201805)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201806 VALUES (201806)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201807 VALUES (201807)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201808 VALUES (201808)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201809 VALUES (201809)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201810 VALUES (201810)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201811 VALUES (201811)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201812 VALUES (201812)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201901 VALUES (201901)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201902 VALUES (201902)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201903 VALUES (201903)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201904 VALUES (201904)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201905 VALUES (201905)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201906 VALUES (201906)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201907 VALUES (201907)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201908 VALUES (201908)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201909 VALUES (201909)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201910 VALUES (201910)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201911 VALUES (201911)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201912 VALUES (201912)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202001 VALUES (202001)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202002 VALUES (202002)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202003 VALUES (202003)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202004 VALUES (202004)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202005 VALUES (202005)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202006 VALUES (202006)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202007 VALUES (202007)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202008 VALUES (202008)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202009 VALUES (202009)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202010 VALUES (202010)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202011 VALUES (202011)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202012 VALUES (202012)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202101 VALUES (202101)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202102 VALUES (202102)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202103 VALUES (202103)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202104 VALUES (202104)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202105 VALUES (202105)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202106 VALUES (202106)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202107 VALUES (202107)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202108 VALUES (202108)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202109 VALUES (202109)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202110 VALUES (202110)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202111 VALUES (202111)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202112 VALUES (202112)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202201 VALUES (202201)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202202 VALUES (202202)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202203 VALUES (202203)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202204 VALUES (202204)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202205 VALUES (202205)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202206 VALUES (202206)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202207 VALUES (202207)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202208 VALUES (202208)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202209 VALUES (202209)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202210 VALUES (202210)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202211 VALUES (202211)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_202212 VALUES (202212)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                MAXSIZE          UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201001 VALUES (201001)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201002 VALUES (201002)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201003 VALUES (201003)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201004 VALUES (201004)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201005 VALUES (201005)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201006 VALUES (201006)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201007 VALUES (201007)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201008 VALUES (201008)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201009 VALUES (201009)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201010 VALUES (201010)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201011 VALUES (201011)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201012 VALUES (201012)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201101 VALUES (201101)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201102 VALUES (201102)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201103 VALUES (201103)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201104 VALUES (201104)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201105 VALUES (201105)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201106 VALUES (201106)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201107 VALUES (201107)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201108 VALUES (201108)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201109 VALUES (201109)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201110 VALUES (201110)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201111 VALUES (201111)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201112 VALUES (201112)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201201 VALUES (201201)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201202 VALUES (201202)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201203 VALUES (201203)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201204 VALUES (201204)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201205 VALUES (201205)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201206 VALUES (201206)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201207 VALUES (201207)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201208 VALUES (201208)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201209 VALUES (201209)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201210 VALUES (201210)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201211 VALUES (201211)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201212 VALUES (201212)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201301 VALUES (201301)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201302 VALUES (201302)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201303 VALUES (201303)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201304 VALUES (201304)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201305 VALUES (201305)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201306 VALUES (201306)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201307 VALUES (201307)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201308 VALUES (201308)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201309 VALUES (201309)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               ),  
  PARTITION P_201310 VALUES (201310)
    NOLOGGING
    COMPRESS FOR QUERY HIGH 
    TABLESPACE OFSDATA
    PCTFREE    0
    INITRANS   1
    MAXTRANS   255
    STORAGE    (
                INITIAL          8M
                NEXT             1M
                MAXSIZE          UNLIMITED
                MINEXTENTS       1
                MAXEXTENTS       UNLIMITED
                BUFFER_POOL      DEFAULT
                FLASH_CACHE      DEFAULT
                CELL_FLASH_CACHE DEFAULT
               )
)
NOCACHE
NOPARALLEL
MONITORING;


GRANT SELECT ON DM_INFOMAN.MEMZUC_GELN_PRTFY TO R_OFSDATA;

GRANT SELECT ON DM_INFOMAN.MEMZUC_GELN_PRTFY TO R_OW_SAS;

GRANT SELECT ON DM_INFOMAN.MEMZUC_GELN_PRTFY TO R_SAS_PAZARLAMA;
