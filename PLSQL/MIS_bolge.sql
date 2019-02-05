select distinct 
     MS_BOLGE.BOLGE_KOD as BOLGE_KOD,
     MS_BOLGE.BOLGE_AD as BOLGE_AD,
     main.SUBE as SUBE_KODU
,main.SUBEADI as SUBEADI,
     MS_BOLGE.AKTF_F as AKTF_F
from 
     DM_MIS.DIM_MIS_BOLGE MS_BOLGE,
     (select sube    ,
trim(subeadi) subeadi ,
bolum   ,
bolgeadi    ,
subetipi    ,
subesinif   ,
anasube ,
pazarlamabolgeadi   ,
pazarlamabolgeno    ,
sube_ozellik    ,
updtarih    ,
updzaman    ,
updprogram  ,
updsicil    ,
super_bolge_profil  ,
etl_trh ,
etl_job  from extr.fs_bcekbolgem
) main,
     DM_MIS.FCT_MIS_DBS DBS
where  ( main.SUBE = DBS.SUBE_KOD and DBS.KST_TRH = MS_BOLGE.KST_TRH and DBS.SUBE_KOD = MS_BOLGE.SUBE_KOD and (MS_BOLGE.BOLGE_AD <> 'Serbest Bölge' or MS_BOLGE.BOLGE_AD like '%Ticari%') 
and (MS_BOLGE.BOLGE_AD like '%Bölge%' or MS_BOLGE.BOLGE_AD like '%Ticari%') )
order by 1,2 desc
