/* Formatted on 27/02/2017 11:01:02 (QP5 v5.252.13127.32867) */
  SELECT *
    FROM (SELECT a.talep_no kredi_ref_no,                                                                                  -- talep_no kredi_ref_nodur
                 T.ICMAL_TARIHI kredi_acilis_tarhi,                                                                             -- kredi acýlýs tarihi
                 C.INSERT_KANAL bayi_bilgisi,                                                                                         -- teknosa, ptt.
                 A.GERCEKLESME_TARIHI odeme_tarihi,
                trunc(  a.odeme_tarihi)  taksit_tarihi,   
                 SUM( (ODEME_TUTARI)  ) OVER(PARTITION BY a.talep_no,a.odeme_tarihi ORDER BY a.talep_no) tasit_tutari,
                 SUM(a.faiz) OVER(PARTITION BY a.talep_no,a.odeme_tarihi ORDER BY a.talep_no) ilgiliay_taksit_faizi,                   -- ilgili ay içersinden ödenen faiz
                 SUM(CASE WHEN a.gerceklesme_tarihi IS NOT NULL THEN a.faiz END) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no) odenen_toplam_faiz, -- krediye ödenen toplam faiz
                 SUM(CASE WHEN a.gerceklesme_tarihi IS NULL THEN a.anapara ELSE 0 END) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no) kalan_anapara,
                 SUM(CASE WHEN a.gerceklesme_tarihi IS NULL THEN a.faiz END) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no) kalan_toplam_faiz, -- kredi için henüz ödenmemiþ toplam faiz
                 SUM(CASE WHEN a.gerceklesme_tarihi IS NULL THEN a.anapara + a.faiz + a.bsmv + a.kkdf ELSE 0 END)
                    OVER(PARTITION BY a.talep_no ORDER BY a.talep_no)
                    kalan_toplam_borc,
                 SUM(a.anapara) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no) kredi_acilis_tutar, 
              SUM(c.tutar) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no) odenen_promosyon_tutari, --(toplam_giderleþen)ODENE PROMOSYON TUTARI     
              --  ODENE PROMOSYON TUTARI :  Bunun için talep bazýnda kredi_hizmet_odemeleri tablosunda tutar alaný sum alýnarak hesaplanabilir.OK
 SUM(CASE WHEN c.giderlestirme_tarihi  IS NOT NULL THEN c.tutar ELSE 0 END) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no)
                    giderlesen_promosyon_tutari,   
                     --GIDERLESEN PROMOSYON TUTARI, kredi_hizmet_odemeleri tablosunda   giderlestirme_tarihi is  not null  alaný sum alýnarak hesaplanabilir.
SUM(CASE WHEN c.giderlestirme_tarihi IS NULL THEN c.tutar ELSE 0 END) OVER(PARTITION BY a.talep_no ORDER BY a.talep_no)
                    giderlesecek_promosyon_tutari 
                    --GIDERLESECEK PROMOSYON TUTARI  kredi_hizmet_odemeleri tablosunda giderlestirme_tarihi is null olan kayýtlar için sum alýnabilir
            FROM extr.oy_ko_tukodeme a
                 LEFT JOIN extr.oy_kredi_hizmet_odemeleri c
                    ON a.talep_no = c.talep_no
                       AND A.TAKSIT_SIRA = C.TAKSIT_SIRA
                 INNER JOIN EXTR.OY_KO_TALEP T ON T.talep_no = a.talep_no
          WHERE a.talep_no  in (38053778)           
           ) a
   WHERE a.odeme_tarihi BETWEEN TO_DATE('01/12/2016', 'dd/mm/yyyy') AND TO_DATE('31/12/2016', 'dd/mm/yyyy')
ORDER BY a.ODEME_TARIHI;






-- Birden fazla talep no oldugu zaman rakam toplýyor ve cokluyor. 

--in ( 37999914,35385778,35366855,35171877,3424364)
--
select * from EXTR.OY_KO_TALEP where talep_no = 35385778;

select to_char(to_date('15-11-2010', 'DD-MM-YYYY'), 'Month') from dual;

--select * from dba_tables where lower(table_name) like '%talep%';

 select * from extr.oy_ko_tukodeme where talep_no=38053778 ;   -- odeme_tarihi,gerceklesme_tarihi,,
 

--38783627,38784330,38790989,38052898,37999914,38050813,38052173,38053769,38053778

 --TEST QUERY
 select * 
           FROM extr.oy_ko_tukodeme a
               LEFT JOIN extr.oy_kredi_hizmet_odemeleri c
                  ON a.talep_no = c.talep_no
                     AND A.TAKSIT_SIRA = C.TAKSIT_SIRA
       WHERE 
    1=1
 --   and  ODEME_TARIHI BETWEEN TO_DATE('01/12/2016', 'dd/mm/yyyy') AND TO_DATE('31/12/2016', 'dd/mm/yyyy')
  and   a.talep_no  in (38053778) 
--and  INSERT_KANAL  in ('PTT','TEKNOSA')
         order by ODEME_TARIHI ;
