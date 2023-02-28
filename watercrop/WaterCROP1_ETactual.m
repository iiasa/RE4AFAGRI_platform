cd '~\WaterCrop_replication' 
climate = imread('thcli1.tif');

cd '~\WaterCrop_replication\1-ET0mm_day'
ET0_2020=importdata('ET0_2020_370_GFDL_bias.mat'); 
ET0_2020(isnan(ET0_2020))=0;

ET0_jan=ET0_2020(:,:,1);
ET0_feb=ET0_2020(:,:,2);
ET0_mar=ET0_2020(:,:,3);
ET0_apr=ET0_2020(:,:,4);
ET0_may=ET0_2020(:,:,5);
ET0_jun=ET0_2020(:,:,6);
ET0_jul=ET0_2020(:,:,7);
ET0_aug=ET0_2020(:,:,8);
ET0_sep=ET0_2020(:,:,9);
ET0_oct=ET0_2020(:,:,10);
ET0_nov=ET0_2020(:,:,11);
ET0_dec=ET0_2020(:,:,12);
 
cd '~\WaterCrop_replication\2-Prec_mm_day'
P_2020=importdata('P_2020_370_GFDL_bias.mat'); 
P_2020(isnan(P_2020))=0;

P_jan=P_2020(:,:,1);
P_feb=P_2020(:,:,2);
P_mar=P_2020(:,:,3);
P_apr=P_2020(:,:,4);
P_may=P_2020(:,:,5);
P_jun=P_2020(:,:,6);
P_jul=P_2020(:,:,7);
P_aug=P_2020(:,:,8);
P_sep=P_2020(:,:,9);
P_oct=P_2020(:,:,10);
P_nov=P_2020(:,:,11);
P_dec=P_2020(:,:,12);

x=(1:14)';
dec_before=1:1/30:2-1/30;
jan=2:1/30:3-1/30;
feb=3:1/30:4-1/30;
mar=4:1/30:5-1/30;
apr=5:1/30:6-1/30;
may=6:1/30:7-1/30;
jun=7:1/30:8-1/30;
jul=8:1/30:9-1/30;
aug=9:1/30:10-1/30;
sep=10:1/30:11-1/30;
oct=11:1/30:12-1/30;
nov=12:1/30:13-1/30;
dec=13:1/30:14-1/30;
jan_after=14:1/30:15-1/30;
days=[dec_before,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec,jan_after]';

cartella_kc = '~\WaterCrop_replication';
 
raccolto=1;%,2,3,4,5,6,7,8,9,10,11,12,13,14,15,24,31,32,33]; %19 crops
for r = 1:length(raccolto) %r crop index
  
    switch raccolto(r)
    
%--  II growing season 

        case 1 %Mais
            cartella='~\WaterCrop_replication\Maize';
         
            coeff_colturale='kc_maize';
            cartella_risultati='~\WaterCrop_replication\Results1_ETa\Maize';
            
            rd_ini=0.3;  %m
            rd_max_rainfed=1.7; %fao 56 tab 22 pag 190
            rd_max_irrigated=1;
            depl_fraction=0.55;
            ky=1.25;
             
            area_irrigata='spam2017V2r1_SSA_H_MAIZ_I.mat';
            area_rainfed='spam2017V2r1_SSA_H_MAIZ_R.mat';
            area_totale='spam2017V2r1_SSA_H_MAIZ_A.mat';
            
            data_semina='semina_rf_2017_MAIZ.mat';
            data_semina_irr='semina_ir_2017_MAIZ.mat';
            lgp='lgp_rf_2017_MAIZ.mat';
            lgp_irr='lgp_irr_2017_MAIZ.mat';
                    
%         case 2 %Rice
%             cartella='~/work/solarirr/Rice';
%             
%             area_irrigata='spam2017V2r1_SSA_H_RICE_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_RICE_R.mat';
%             area_totale='spam2017V2r1_SSA_H_RICE_A.mat';
% 
%             data_semina='semina_rf_2017_RICE.mat';
%             data_semina_irr='semina_ir_2017_RICE.mat';
%             lgp='lgp_rf_2017_RICE.mat';
%             lgp_irr='lgp_irr_2017_RICE.mat';
% 
%             coeff_colturale='rice';
%             cartella_risultati='~/work/solarirr/Risultati/Rice';
%             
%             rd_ini=0.3; 
%             rd_max_rainfed=1; %fao 56 tab 22 pag 190
%             rd_max_irrigated=0.5;
%             depl_fraction=0.2;
%             ky=1.5; %Ho messo ipotizzando che il riso sia molto sensibile alla carenza d'acqua. Cercare fonte
%       
%         case 3 %Wheat
%             cartella='~/work/solarirr/Wheat';
%            
%             area_irrigata='spam2017V2r1_SSA_H_WHEA_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_WHEA_R.mat';
%             area_totale='spam2017V2r1_SSA_H_WHEA_A.mat';
%             coeff_colturale='wheat'; %nome del foglio sull'excel del KC
%             
%             cartella_risultati='~/work/solarirr/Risultati/Wheat';
%           
%             data_semina='semina_rf_2017_WHEA.mat';
%             data_semina_irr='semina_ir_2017_WHEA.mat';
%             
%             lgp='lgp_rf_2017_WHEA.mat';
%             lgp_irr='lgp_irr_2017_WHEA.mat';
%             
%             rd_ini=0.3; %radicamento iniziale in m
%             rd_max_rainfed=1.8; %Siebert and doll
%             rd_max_irrigated=1.5; %radicamento cambia se condizioni irr o rf
%             
%             depl_fraction=0.55; %coefficiencte di deplezione critica, TAWC e RAWC
%             ky=1.05; %doorenbos. Mette in relazione delta Et e delta resa. Se Et subisce una variazione
%             % anche la resa varia in modo proporzionale. ky è il coeff. di proporzione. 5% in questo caso
%          
%          case 4 %Soy
%             cartella='~/work/solarirr/Soybean';
%             
%             coeff_colturale='kc_soybean';
%             cartella_risultati='~/work/solarirr/Risultati/Soybean';
%             
%             area_irrigata='spam2017V2r1_SSA_H_SOYB_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_SOYB_R.mat';
%             area_totale='spam2017V2r1_SSA_H_SOYB_A.mat';
%             
%             data_semina='semina_rf_2017_SOYB.mat';
%             data_semina_irr='semina_ir_2017_SOYB.mat';
%             lgp='lgp_rf_2017_SOYB.mat';
%             lgp_irr='lgp_irr_2017_SOYB.mat';
% 
%             rd_ini=0.3;  
%             rd_max_rainfed=1.30; %Siebert and doll
%             rd_max_irrigated=0.60;
%             depl_fraction=0.50;
%             ky=0.85;
%         
%         case 5 %sorghum  
%             cartella='~/work/solarirr/Sorghum';
%             
%             coeff_colturale='sorghum';
%             cartella_risultati='~/work/solarirr/Risultati/Sorghum';
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 2; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 1;
%             depl_fraction = 0.55;
%             ky = 0.9;
%             
%             area_irrigata='spam2017V2r1_SSA_H_SORG_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_SORG_R.mat';
%             area_totale='spam2017V2r1_SSA_H_SORG_A.mat';
%             
%             data_semina='semina_rf_2017_SORG.mat';
%             data_semina_irr='semina_ir_2017_SORG.mat';
%             lgp='lgp_rf_2017_SORG.mat';
%             lgp_irr='lgp_irr_2017_SORG.mat';
%             
%         case 6 %groundnut
%             cartella='~/work/solarirr/Groundnut';
%             coeff_colturale='groundnut';
%             cartella_risultati='~/work/solarirr/Risultati/Groundnut';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 1.0; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 0.5;
%             depl_fraction=0.50;
%             ky=0.7; %irrigationdrainage6
%             
%             area_irrigata='spam2017V2r1_SSA_H_GROU_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_GROU_R.mat';
%             area_totale='spam2017V2r1_SSA_H_GROU_A.mat';
%             
%             data_semina='semina_rf_2017_GROU.mat';
%             data_semina_irr='semina_ir_2017_GROU.mat';
%             lgp='lgp_rf_2017_GROU.mat';
%             lgp_irr='lgp_irr_2017_GROU.mat';
%         
%         case 7 %barley
%             cartella = '~/work/solarirr/Barley'; %input
% 
%             coeff_colturale = 'barley';
% 
%             cartella_risultati = '~/work/solarirr/Risultati/Barley'; %output
%             area_irrigata='spam2017V2r1_SSA_H_BARL_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_BARL_R.mat';
%             area_totale='spam2017V2r1_SSA_H_BARL_A.mat';
% 
%             data_semina='semina_rf_2017_BARL.mat';
%             data_semina_irr='semina_ir_2017_BARL.mat';
%             lgp='lgp_rf_2017_BARL.mat';
%             lgp_irr='lgp_irr_2017_BARL.mat';
% 
%             rd_ini = 0.3; 
%             rd_max_rainfed = 1.5; 
%             rd_max_irrigated = 1.0;
%             depl_fraction = 0.55;
%             ky = 1.05; 
%         
%         case 8 %cassava  
%             cartella='~/work/solarirr/Cassava';
% 
%             coeff_colturale='cassava';
%             cartella_risultati='~/work/solarirr/Risultati/Cassava';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 1; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 0.7;
%             depl_fraction = 0.40;
%             ky=1.1;
% 
%             area_irrigata='spam2017V2r1_SSA_H_CASS_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_CASS_R.mat';
%             area_totale='spam2017V2r1_SSA_H_CASS_A.mat';
%             
%             data_semina='semina_rf_2017_CASS.mat';
%             data_semina_irr='semina_ir_2017_CASS.mat';
%             lgp='lgp_rf_2017_CASS.mat';
%             lgp_irr='lgp_irr_2017_CASS.mat';
%         
%         case 9 %cotton
%             cartella = '~/work/solarirr/Cotton'; %input
% 
%             coeff_colturale = 'seedcotton';
% 
%             cartella_risultati = '~/work/solarirr/Risultati/Cotton'; %output
%             area_irrigata='spam2017V2r1_SSA_H_COTT_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_COTT_R.mat';
%             area_totale='spam2017V2r1_SSA_H_COTT_A.mat';
% 
%             data_semina='semina_rf_2017_COTT.mat';
%             data_semina_irr='semina_ir_2017_COTT.mat';
%             lgp='lgp_rf_2017_COTT.mat';
%             lgp_irr='lgp_irr_2017_COTT.mat';
%         
%             rd_ini = 0.3; 
%             rd_max_rainfed = 1.7; %Allen
%             rd_max_irrigated = 1.0;
%             depl_fraction = 0.65;
%             ky = 0.85; %  Allen
%         
%         case 10 % pearl millet  
%             cartella='~/work/solarirr/Millet_pearl';
% 
%             coeff_colturale='millet';
%             cartella_risultati='~/work/solarirr/Risultati/Millet_pearl';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 2; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 1;
%             depl_fraction = 0.55;
%             ky=1.05; %valore ipotetico, tipico dei cereali poiché mancante del drainage66
% 
%             area_irrigata='spam2017V2r1_SSA_H_PMIL_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_PMIL_R.mat';
%             area_totale='spam2017V2r1_SSA_H_PMIL_A.mat';
% 
%             data_semina='semina_rf_2017_PMIL.mat';
%             data_semina_irr='semina_ir_2017_PMIL.mat';
%             lgp='lgp_rf_2017_PMIL.mat';
%             lgp_irr='lgp_irr_2017_PMIL.mat';
%         
%         case 11 %sugarcane
%             cartella = '~/work/solarirr/Sugarcane'; %input
% 
%             coeff_colturale = 'sugarcane';
%             cartella_risultati = '~/work/solarirr/Risultati/Sugarcane'; %output
% 
%             area_irrigata='spam2017V2r1_SSA_H_SUGC_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_SUGC_R.mat';
%             area_totale='spam2017V2r1_SSA_H_SUGC_A.mat';
%             
%             data_semina='semina_rf_2017_SUGC.mat';
%             data_semina_irr='semina_ir_2017_SUGC.mat';
%             lgp='lgp_rf_2017_SUGC.mat';
%             lgp_irr='lgp_irr_2017_SUGC.mat';
% 
%             rd_ini = 0.3; 
%             rd_max_rainfed = 2.0; %Allen 1998 tab 22 pag 160
%             rd_max_irrigated = 1.2;
%             depl_fraction = 0.65;
%             ky = 1.2; %%Allen 1998 tab 24 pag 181
%         
%         case 12 %yams 
%             cartella='~/work/solarirr/Yams';
% 
%             coeff_colturale='yams';
%             cartella_risultati='~/work/solarirr/Risultati/Yams';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 1.5; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 1;
%             depl_fraction = 0.65;
%             ky=1.1;
%             
%             area_irrigata='spam2017V2r1_SSA_H_YAMS_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_YAMS_R.mat';
%             area_totale='spam2017V2r1_SSA_H_YAMS_A.mat';
% 
%             data_semina='semina_rf_2017_YAMS.mat';
%             data_semina_irr='semina_ir_2017_YAMS.mat';
%             lgp='lgp_rf_2017_YAMS.mat';
%             lgp_irr='lgp_irr_2017_YAMS.mat';
%             
%         case 13 %potatoes
%             cartella = '~/work/solarirr/Potatoes';
% 
%             coeff_colturale = 'kc_potato';
% 
%             cartella_risultati = '~/work/solarirr/Risultati/Potatoes';
%             
%             area_irrigata='spam2017V2r1_SSA_H_POTA_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_POTA_R.mat';
%             area_totale='spam2017V2r1_SSA_H_POTA_A.mat';
% 
%             data_semina='semina_rf_2017_POTA.mat';
%             data_semina_irr='semina_ir_2017_POTA.mat';
%             lgp='lgp_rf_2017_POTA.mat';
%             lgp_irr='lgp_irr_2017_POTA.mat';
% 
%             rd_ini = 0.3; 
%             rd_max_rainfed = 0.6; %Allen 1998 tab 22 pag 160
%             rd_max_irrigated = 0.4;
%             depl_fraction = 0.35;
%             ky = 1.1;    
%             
%         case 14 %sugarbeet
%             cartella = '~/work/Risultati/Sugarbeet';
% 
%             coeff_colturale = 'sugarbeet';
% 
%             cartella_risultati = '~/work/solarirr/Risultati/Sugarbeet';
% 
%             area_irrigata='spam2017V2r1_SSA_H_SUGB_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_SUGB_R.mat';
%             area_totale='spam2017V2r1_SSA_H_SUGB_A.mat';
% 
%             data_semina='semina_rf_2017_SUGB.mat';
%             data_semina_irr='semina_ir_2017_SUGB.mat';
%             lgp='lgp_rf_2017_SUGB.mat';
%             lgp_irr='lgp_irr_2017_SUGB.mat';
% 
%             rd_ini = 0.3; 
% 
%             rd_max_rainfed = 1.20; %Siebert and Doll 2008
%             rd_max_irrigated = 0.70;
%             depl_fraction = 0.55;
%             ky = 1.0; %%Allen 1998 tab 24 pag 181    
% 
%         case 15 %small millet  
%             cartella='~/work/solarirr/Millet_small';
% 
%             coeff_colturale='millet';
%             cartella_risultati='~/work/solarirr/Risultati/Millet_small';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 2; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 1;
%             depl_fraction = 0.55;
%             ky=1.05; %valore ipotetico, tipico dei cereali poiché mancante del drainage66
% 
%             area_irrigata='spam2017V2r1_SSA_H_SMIL_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_SMIL_R.mat';
%             area_totale='spam2017V2r1_SSA_H_SMIL_A.mat';
% 
%             data_semina='semina_rf_2017_SMIL.mat';
%             data_semina_irr='semina_ir_2017_SMIL.mat';
%             lgp='lgp_rf_2017_SMIL.mat';
%             lgp_irr='lgp_irr_2017_SMIL.mat';
            
%         case 16 %greenbean  
%             cartella='~/work/solarirr/Vegetables';
% 
%             coeff_colturale='greenbean';
%             cartella_risultati='~/work/Risultati/Greenbean';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 0.7; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 0.5;
%             depl_fraction = 0.45;
%             ky=1.15; %beans
% 
%             area_irrigata='spam2017V2r1_SSA_H_VEGE_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_VEGE_R.mat';
%             area_totale='spam2017V2r1_SSA_H_VEGE_A.mat';
% 
%             data_semina='semina_rf_2017.mat';
%             data_semina_irr='semina_ir_2017.mat';
%             lgp='lgp_rf_2017.mat';
%             lgp_irr='lgp_ir_2017.mat';
            
%         case 17 %beansdry  
%             cartella='~/work/solarirr/Beans';
% 
%             coeff_colturale='beansdry';
%             cartella_risultati='~/work/Risultati/Bean';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 0.9; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 0.6;
%             depl_fraction = 0.45;
%             ky=1.15; %beans
% 
%             area_irrigata='spam2017V2r1_SSA_H_BEAN_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_BEAN_R.mat';
%             area_totale='spam2017V2r1_SSA_H_BEAN_A.mat';
% 
%             data_semina='semina_rf_2017.mat';
%             data_semina_irr='semina_ir_2017.mat';
%             lgp='lgp_rf_2017.mat';
%             lgp_irr='lgp_ir_2017.mat';
%             
%         case 18 %peasdry  
%              cartella='~/work/solarirr/Pulses, other';
% 
%              coeff_colturale='peasdry';
%              cartella_risultati='~/work/Risultati/Peasdry';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.0; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.6;
%              depl_fraction = 0.40;
%              ky=1.15; %peas
% 
%              area_irrigata='spam2017V2r1_SSA_H_OPUL_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_OPUL_R.mat';
%              area_totale='spam2017V2r1_SSA_H_OPUL_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
%              
%         case 19 %pigeonpea  
%              cartella='~/work/solarirr/Pigeon pea';
% 
%              coeff_colturale='pigeonpea';
%              cartella_risultati='~/work/Risultati/Pigeon pea';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.0; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.6;
%              depl_fraction = 0.40;
%              ky=1.15; %peas
% 
%              area_irrigata='spam2017V2r1_SSA_H_PIGE_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_PIGE_R.mat';
%              area_totale='spam2017V2r1_SSA_H_PIGE_A.mat';       
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
%              
%         case 20 %broadbean 
%              cartella='~/work/solarirr/Pulses, other';
% 
%              coeff_colturale='broadbean';
%              cartella_risultati='~/work/Risultati/Broadbean';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 0.7; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.5;
%              depl_fraction = 0.45;
%              ky=1.15; %peas
% 
%              area_irrigata='spam2017V2r1_SSA_H_OPUL_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_OPUL_R.mat';
%              area_totale='spam2017V2r1_SSA_H_OPUL_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
%              
%       case 21 %chickpea  
%              cartella='~/work/solarirr/Chickpea';
% 
%              coeff_colturale='chickpea';
%              cartella_risultati='~/work/Risultati/Chickpea';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.0; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.6;
%              depl_fraction = 0.50;
%              ky=0; %definire
% 
%              area_irrigata='spam2017V2r1_SSA_H_CHIC_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_CHIC_R.mat';
%              area_totale='spam2017V2r1_SSA_H_CHIC_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
% 
%       case 22 %cowpea  
%              cartella='~/work/solarirr/Cowpea';
% 
%              coeff_colturale='cowpea';
%              cartella_risultati='~/work/Risultati/Cowpea';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.0; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.6;
%              depl_fraction = 0.45;
%              ky=0; %definire
% 
%              area_irrigata='area_ir.mat';
%              area_rainfed='area_rf.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
% 
%       case 23 %lupin  
%              cartella='~/work/solarirr/Pulses, other';
% 
%              coeff_colturale='lupin';
%              cartella_risultati='~/work/Risultati/Lupin';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 0.7; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.5;
%              depl_fraction = 0.45;
%              ky=1.15; %peas
% 
%              area_irrigata='spam2017V2r1_SSA_H_OPUL_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_OPUL_R.mat';
%              area_totale='spam2017V2r1_SSA_H_OPUL_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
             
%      case 24 %rapeseed  
%              cartella='~/work/solarirr/Rapeseed';
% 
%              coeff_colturale='rapeseed';
%              cartella_risultati='~/work/solarirr/Risultati/Rapeseed';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.5; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 1;
%              depl_fraction = 0.6;
%              ky=1.15;
% 
%              area_irrigata='spam2017V2r1_SSA_H_RAPE_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_RAPE_R.mat';
%              area_totale='spam2017V2r1_SSA_H_RAPE_A.mat';
% 
%              data_semina='semina_rf_2017_RAPE.mat';
%              data_semina_irr='semina_ir_2017_RAPE.mat';
%              lgp='lgp_rf_2017_RAPE.mat';
%              lgp_irr='lgp_irr_2017_RAPE.mat';
             
%       case 25 %vegetable X
%              cartella='~/work/solarirr/Vegetables';
% 
%             coeff_colturale='vegetableandroots';
%             cartella_risultati='~/work/Risultati/Vegetables';
% 
%             rd_ini=0.3;  %m
%             rd_max_rainfed = 1; %fao 56 tab 22 pag 190
%             rd_max_irrigated = 0.6;
%             depl_fraction = 0.5;
%             ky=0; %definire
% 
%             area_irrigata='spam2017V2r1_SSA_H_VEGE_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_VEGE_R.mat';
%             area_totale='spam2017V2r1_SSA_H_VEGE_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
%              
%        case 26 %oat X
%              cartella='~/work/solarirr/Cereals, others';
% 
%              coeff_colturale='oat';
%              cartella_risultati='~/work/Risultati/Oat';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.5; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 1;
%              depl_fraction = 0.55;
%              ky=1.1;
% 
%             area_irrigata='spam2017V2r1_SSA_H_OCER_I.mat';
%             area_rainfed='spam2017V2r1_SSA_H_OCER_R.mat';
%             area_totale='spam2017V2r1_SSA_H_OCER_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
%              
%        case 27 %rye  
%              cartella='~/work/solarirr/Cereals, others';
% 
%              coeff_colturale='rye';
%              cartella_risultati='~/work/Risultati/Rye';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.6;
%              depl_fraction = 0.60;
%              ky=1.1; 
% 
%              area_irrigata='spam2017V2r1_SSA_H_OCER_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_OCER_R.mat';
%              area_totale='spam2017V2r1_SSA_H_OCER_A.mat';
%              
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
%              
%         case 28 %mustardseed  
%              cartella='~/work/solarirr/Rapeseed';
% 
%              coeff_colturale='mustard';
%              cartella_risultati='~/work/Risultati/Mustardseed';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.5; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 1;
%              depl_fraction = 0.60;
%              ky=0; %definire
% 
%              area_irrigata='spam2017V2r1_SSA_H_RAPE_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_RAPE_R.mat';
%              area_totale='spam2017V2r1_SSA_H_RAPE_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
% 
%          case 29 %sesameseed  
%              cartella='~/work/solarirr/Sesameseed';
% 
%              coeff_colturale='sesame';
%              cartella_risultati='~/work/Risultati/Sesameseed';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.5; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 1;
%              depl_fraction = 0.60;
%              ky=0; %definire
% 
%              area_irrigata='spam2017V2r1_SSA_H_SESA_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_SESA_R.mat';
%              area_totale='spam2017V2r1_SSA_H_SESA_A.mat';
%              
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
% 
%         case 30 %sweet potatoes  
%              cartella='~/work/solarirr/Sweet potato';
% 
%              coeff_colturale='sweetpotatoes';
%              cartella_risultati='~/work/Risultati/Sweet potato';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.5; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 1;
%              depl_fraction = 0.65;
%              ky=1.1; 
% 
%              area_irrigata='spam2017V2r1_SSA_H_SWPO_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_SWPO_R.mat';
%              area_totale='spam2017V2r1_SSA_H_SWPO_A.mat';
% 
%              data_semina='semina_rf_2017.mat';
%              data_semina_irr='semina_ir_2017.mat';
%              lgp='lgp_rf_2017.mat';
%              lgp_irr='lgp_ir_2017.mat';
             
%         case 31 %oil palm 
%              cartella='~/work/solarirr/Oil palm';
% 
%              coeff_colturale='oil_palm';
%              cartella_risultati='~/work/solarirr/Risultati/Oil palm';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed = 1.1; %fao 56 tab 22 pag 190
%              rd_max_irrigated = 0.7;
%              depl_fraction = 0.65;
%              ky=1.1; %
% 
%              area_irrigata='spam2017V2r1_SSA_H_OILP_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_OILP_R.mat';
%              area_totale='spam2017V2r1_SSA_H_OILP_A.mat';
% 
%              data_semina='semina_rf_2017_OILP.mat';
%              data_semina_irr='semina_ir_2017_OILP.mat';
%              lgp='lgp_rf_2017_OILP.mat';
%              lgp_irr='lgp_irr_2017_OILP.mat';
%                     
%         case 32 %cocoa
%              cartella='~/work/solarirr/Cocoa';
% 
%              coeff_colturale='kc_maize';
%              cartella_risultati='~/work/solarirr/Risultati/Cocoa';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed=1; %fao 56 tab 22 pag 190
%              rd_max_irrigated=0.7;
%              depl_fraction=0.30;
%              ky=1.25;
% 
%              area_irrigata='spam2017V2r1_SSA_H_COCO_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_COCO_R.mat';
%              area_totale='spam2017V2r1_SSA_H_COCO_A.mat';
% 
%              data_semina='semina_rf_2017_COCO.mat';
%              data_semina_irr='semina_ir_2017_COCO.mat';
%              lgp='lgp_rf_2017_COCO.mat';
%              lgp_irr='lgp_irr_2017_COCO.mat';
%              
%              case 33 %sunflower
%              cartella='~/work/solarirr/Sunflower';
% 
%              coeff_colturale='sunflower';
%              cartella_risultati='~/work/solarirr/Risultati/Sunflower';
% 
%              rd_ini=0.3;  %m
%              rd_max_rainfed=1.5; %fao 56 tab 22 pag 190
%              rd_max_irrigated=0.8;
%              depl_fraction=0.45;
%              ky=0.95;
% 
%              area_irrigata='spam2017V2r1_SSA_H_SUNF_I.mat';
%              area_rainfed='spam2017V2r1_SSA_H_SUNF_R.mat';
%              area_totale='spam2017V2r1_SSA_H_SUNF_A.mat';
% 
%              data_semina='semina_rf_2017_SUNF.mat';
%              data_semina_irr='semina_ir_2017_SUNF.mat';
%              lgp='lgp_rf_2017_SUNF.mat';
%              lgp_irr='lgp_irr_2017_SUNF.mat';
                    
    end
    
%crop data
cd(cartella)

%2017 mapspam areas
area_irr=importdata(area_irrigata);

area_rain=importdata(area_rainfed);

area_tot=importdata(area_totale);
 
%Portmann planting date, updated to 2017
day_plant_modified=importdata(data_semina); 
day_plant_modified_irr=importdata(data_semina_irr);
 
%Portmann growing period, updated to 2017
lgp_ini=importdata(lgp);
lgp_ini_irr=importdata(lgp_irr);

%
cd(cartella_kc)
kc=xlsread('kc_global_NEWCROPS_def.xlsx',coeff_colturale,'C17:I26');

%
cd '~\WaterCrop_replication'
awc_final=importdata('awc_mmalm.mat');
       
temp=zeros(14,2);
 
%
ETc_tot_rain=zeros(2160,4320); 
ETc_tot_irr=zeros(2160,4320);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RAINFED
ETa_tot=zeros(2160,4320);
Ptot_rf=zeros(2160,4320); 
Ptot_gr_seas_rf=zeros(2160,4320);

%monthly variables
ETa_month=zeros(2160,4320,12);
ETc_month=zeros(2160,4320,12); %rainfed
ET0_rf_month=zeros(2160,4320,12);
Pre_eff_monthly=zeros(2160,4320,12);
Pre_tot_monthly_gs=zeros(2160,4320,12);

%

%IRRIGATED
I_tot=zeros(2160,4320);
ETgreen_tot=zeros(2160,4320);
ETblue_tot=zeros(2160,4320);
CWU_tot=zeros(2160,4320);
Ptot_ir=zeros(2160,4320); 
Ptot_gr_seas_ir=zeros(2160,4320);
ET0_tot_rf=zeros(2160,4320);
ET0_tot_ir=zeros(2160,4320);

%monthly variables
ETgreen_month=zeros(2160,4320,12);
CWU_month=zeros(2160,4320,12);     
ETblue_month=zeros(2160,4320,12); 
I_month=zeros(2160,4320,12);
ETc_irr_month=zeros(2160,4320,12);
ET0_irr_month=zeros(2160,4320,12);
Pre_eff_irr_month=zeros(2160,4320,12);
Pre_tot_irr_month_gs=zeros(2160,4320,12);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m = 630:1500 %Africa
    for n = 1855:2780
         
       if area_tot(m,n)>0 && climate(m,n)>0 && awc_final(m,n) && ET0_jan(m,n)>=0 && P_jan(m,n)>=0 
%      filter

temp(1,1)=ET0_dec(m,n);
temp(2,1)=ET0_jan(m,n);
temp(3,1)=ET0_feb(m,n);
temp(4,1)=ET0_mar(m,n);
temp(5,1)=ET0_apr(m,n);
temp(6,1)=ET0_may(m,n);
temp(7,1)=ET0_jun(m,n);
temp(8,1)=ET0_jul(m,n);
temp(9,1)=ET0_aug(m,n);
temp(10,1)=ET0_sep(m,n);
temp(11,1)=ET0_oct(m,n);
temp(12,1)=ET0_nov(m,n);
temp(13,1)=ET0_dec(m,n);
temp(14,1)=ET0_jan(m,n);
 
temp(1,2)=P_dec(m,n);
temp(2,2)=P_jan(m,n);
temp(3,2)=P_feb(m,n);
temp(4,2)=P_mar(m,n);
temp(5,2)=P_apr(m,n);
temp(6,2)=P_may(m,n);
temp(7,2)=P_jun(m,n);
temp(8,2)=P_jul(m,n);
temp(9,2)=P_aug(m,n);
temp(10,2)=P_sep(m,n);
temp(11,2)=P_oct(m,n);
temp(12,2)=P_nov(m,n);
temp(13,2)=P_dec(m,n);
temp(14,2)=P_jan(m,n);
        
        
for i=1:14 
    if temp(i,1)<0
       temp(i,1)=0;
   end
end

for i=1:14 
   if temp(i,2)<0
       temp(i,2)=0;
   end
end
 
ET0_daily=interp1q(x,temp(1:14,1),days); 

h=2;
g=17;

    Pre_tot_daily=zeros(length(days),1);
    for p=17:1:length(days)-15
        
        if p==g+30
            h=h+1;
            g=g+30;
        end
        Pre_tot_daily(p)=temp(h,2);
              
    end

switch climate(m,n)
            case 1
                kc_ini=kc(1,1);
                kc_mid=kc(1,2);
                kc_end=kc(1,3);
                
                lgp_2=round(lgp_ini(m,n).*kc(1,5));
                lgp_3=round(lgp_ini(m,n).*kc(1,6));
                lgp_4=round(lgp_ini(m,n).*kc(1,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(1,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(1,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(1,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 2
                kc_ini=kc(2,1);
                kc_mid=kc(2,2);
                kc_end=kc(2,3);
                              
                lgp_2=round(lgp_ini(m,n).*kc(2,5));
                lgp_3=round(lgp_ini(m,n).*kc(2,6));
                lgp_4=round(lgp_ini(m,n).*kc(2,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(2,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(2,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(2,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 3
                kc_ini=kc(3,1);
                kc_mid=kc(3,2);
                kc_end=kc(3,3);
                
                
                lgp_2=round(lgp_ini(m,n).*kc(3,5));
                lgp_3=round(lgp_ini(m,n).*kc(3,6));
                lgp_4=round(lgp_ini(m,n).*kc(3,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(3,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(3,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(3,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 4
                kc_ini=kc(4,1);
                kc_mid=kc(4,2);
                kc_end=kc(4,3);
                
                
                lgp_2=round(lgp_ini(m,n).*kc(4,5));
                lgp_3=round(lgp_ini(m,n).*kc(4,6));
                lgp_4=round(lgp_ini(m,n).*kc(4,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(4,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(4,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(4,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 5
                kc_ini=kc(5,1);
                kc_mid=kc(5,2);
                kc_end=kc(5,3);
                
                
                lgp_2=round(lgp_ini(m,n).*kc(5,5));
                lgp_3=round(lgp_ini(m,n).*kc(5,6));
                lgp_4=round(lgp_ini(m,n).*kc(5,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(5,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(5,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(5,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 6
                kc_ini=kc(6,1);
                kc_mid=kc(6,2);
                kc_end=kc(6,3);
                
                
                lgp_2=round(lgp_ini(m,n).*kc(6,5));
                lgp_3=round(lgp_ini(m,n).*kc(6,6));
                lgp_4=round(lgp_ini(m,n).*kc(6,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(6,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(6,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(6,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 7
                kc_ini=kc(7,1);
                kc_mid=kc(7,2);
                kc_end=kc(7,3);
               
                
                lgp_2=round(lgp_ini(m,n).*kc(7,5));
                lgp_3=round(lgp_ini(m,n).*kc(7,6));
                lgp_4=round(lgp_ini(m,n).*kc(7,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(7,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(7,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(7,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 8
                kc_ini=kc(8,1);
                kc_mid=kc(8,2);
                kc_end=kc(8,3);
               
                
                lgp_2=round(lgp_ini(m,n).*kc(8,5));
                lgp_3=round(lgp_ini(m,n).*kc(8,6));
                lgp_4=round(lgp_ini(m,n).*kc(8,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(8,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(8,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(8,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 9
                kc_ini=kc(9,1);
                kc_mid=kc(9,2);
                kc_end=kc(9,3);
                
                
                lgp_2=round(lgp_ini(m,n).*kc(9,5));
                lgp_3=round(lgp_ini(m,n).*kc(9,6));
                lgp_4=round(lgp_ini(m,n).*kc(9,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(9,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(9,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(9,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
            case 10
                kc_ini=kc(10,1);
                kc_mid=kc(10,2);
                kc_end=kc(10,3);
                
                
                lgp_2=round(lgp_ini(m,n).*kc(10,5));
                lgp_3=round(lgp_ini(m,n).*kc(10,6));
                lgp_4=round(lgp_ini(m,n).*kc(10,7));
                lgp_1=lgp_ini(m,n)-lgp_2-lgp_3-lgp_4;
                
                lgp_2_irr=round(lgp_ini_irr(m,n).*kc(10,5));
                lgp_3_irr=round(lgp_ini_irr(m,n).*kc(10,6));
                lgp_4_irr=round(lgp_ini_irr(m,n).*kc(10,7));
                lgp_1_irr=lgp_ini_irr(m,n)-lgp_2_irr-lgp_3_irr-lgp_4_irr;
                
    otherwise
                kc_ini=0;
                kc_mid=0;
                kc_end=0;
                lgp_1=0;
                lgp_2=0;
                lgp_3=0;
                lgp_4=0;
                lgp_1_irr=0;
                lgp_2_irr=0;
                lgp_3_irr=0;
                lgp_4_irr=0;
end 
 
%kc vector
lgp=lgp_1+lgp_2+lgp_3+lgp_4; %length of the growing period 
lgp_irr=lgp_1_irr+lgp_2_irr+lgp_3_irr+lgp_4_irr;
kc_crop=zeros(lgp,1);
kc_crop_irr=zeros(lgp_irr,1);
 
%Rainfed
kc_crop(1:lgp_1)=kc_ini;
for i=lgp_1+1:lgp_1+lgp_2
    kc_crop(i)=(kc_mid-kc_ini)/lgp_2*(i-lgp_1)+kc_ini;
end
kc_crop(lgp_2+lgp_1+1:lgp_2+lgp_1+lgp_3)=kc_mid;
for i=lgp_2+lgp_1+1+lgp_3:lgp
    kc_crop(i)=(kc_end-kc_mid)/lgp_4*(i-lgp_3-lgp_2-lgp_1)+kc_mid;
end


%Irrigated
kc_crop_irr(1:lgp_1_irr)=kc_ini;
for i=lgp_1_irr+1:lgp_1_irr+lgp_2_irr
    kc_crop_irr(i)=(kc_mid-kc_ini)/lgp_2_irr*(i-lgp_1_irr)+kc_ini;
end
kc_crop_irr(lgp_2_irr+lgp_1_irr+1:lgp_2_irr+lgp_1_irr+lgp_3_irr)=kc_mid;
for i=lgp_2_irr+lgp_1_irr+1+lgp_3_irr:lgp_irr
    kc_crop_irr(i)=(kc_end-kc_mid)/lgp_4_irr*(i-lgp_3_irr-lgp_2_irr-lgp_1_irr)+kc_mid;
end
 
%rainfed scenario: maximum rooting depth
rd=zeros(lgp,1); 
rd(1)=rd_ini;
for i=2:lgp_1+lgp_2
    rd(i)=rd_ini+(rd_max_rainfed-rd_ini)/(lgp_1+lgp_2)*i;
end
rd(lgp_1+lgp_2+1:lgp)=rd_max_rainfed;
 
%minimum value for irrigated case
rd_irrigated=zeros(lgp_irr,1); 
rd_irrigated(1)=rd_ini;
for i=2:lgp_1_irr+lgp_2_irr
    rd_irrigated(i)=rd_ini+(rd_max_irrigated-rd_ini)./(lgp_1_irr+lgp_2_irr)*i;
end
rd_irrigated(lgp_1_irr+lgp_2_irr+1:lgp_irr)=rd_max_irrigated;
 
%
tawc=zeros(lgp,1);
for i=1:lgp
    tawc(i,1)=awc_final(m,n).*rd(i,1); %[mm(water)/m(soildepth)]
end
 
%
tawc_irrigated=zeros(lgp_irr,1);
for i=1:lgp_irr
    tawc_irrigated(i,1)=awc_final(m,n).*rd_irrigated(i,1); %[mm(water)/m(soildepth)]
end
 
%depletion fraction constant along growing period
 
%Rainfed
f=zeros(lgp,1);
f(1:lgp)=depl_fraction;
 
%Irrigated
f_irr=zeros(lgp_irr,1);
f_irr(1:lgp_irr)=depl_fraction;
 
%rainfed
rawc=zeros(lgp,1);
for t=1:lgp
        rawc(t,1)=tawc(t,1).*f(t);
end
 
%irrigated
rawc_irrigated=zeros(lgp_irr,1);
for t=1:lgp_irr
        rawc_irrigated(t,1)=tawc_irrigated(t,1).*f_irr(t);
end
 
%water balance
deficit_start=zeros(lgp,1); %water needs
deficit_start_i=zeros(lgp_irr,1);%I balance, start 
deficit_st_irrigated = zeros(lgp_irr,1); %II balance

deficit_end=zeros(lgp,1);
deficit_end_i=zeros(lgp_irr,1);%I balance, end
deficit_end_irrigated = zeros(lgp_irr,1); %II balance

surplus=zeros(lgp,1); %runoff
surplus_i=zeros(lgp_irr,1);

ETc_daily=zeros(lgp,1); %crop specific
ETc_daily_irr=zeros(lgp_irr,1);

ETa_daily=zeros(lgp,1); %(CWU)

ETgreen_daily=zeros(lgp_irr,1);%irrigated
CWU_daily=zeros(lgp_irr,1); %(blue+green)
ETblue_daily=zeros(lgp_irr,1);

ks_rain=zeros(lgp,1);
ks=zeros(lgp_irr,1);
ks_irrigated = zeros(lgp_irr,1);

Pre_eff_daily=zeros(lgp,1);
Pre_eff_daily_i=zeros(lgp_irr,1);
Pre_tot_daily_growing_season = zeros(lgp,1);
Pre_tot_daily_growing_season_IR = zeros(lgp_irr,1);

I=zeros(lgp_irr,1);

%
ET0_rf=zeros(lgp,1);
ET0_ir=zeros(lgp_irr,1); 

%RAINFED
%
  if area_rain (m,n)>0 && day_plant_modified(m,n)>0  
        day_start=day_plant_modified(m,n)+16;
        day=day_plant_modified(m,n)+17;
        
% DAY: moves along growing period, counts the days of the year

        ETc_daily(1,1)=kc_crop(1,1)*ET0_daily(day_start,1);    
        
        %ks
        deficit_start(1,1)=0;
        ETa_daily(1,1)=ETc_daily(1,1);
        deficit_end(1,1)=ETa_daily(1,1)+deficit_start(1,1);
        ks_rain(1,1)=1;
        Pre_eff_daily(1,1)=Pre_tot_daily(day_start,1); %P parte da day_start
        Pre_tot_daily_growing_season(1,1)= Pre_tot_daily(day_start,1);
        surplus(1,1)=0;
        ET0_rf(1,1)=ET0_daily(day_start,1); 
       
        %rainfed water balance
   
        for i=2:lgp
        ET0_rf(i,1)=ET0_daily(day,1);    
        ETc_daily(i,1)=kc_crop(i,1).*ET0_daily(day,1);
        Pre_tot_daily_growing_season(i,1)= Pre_tot_daily(day,1);
        
            
                if deficit_end(i-1,1)-Pre_tot_daily(day,1)<0         
                    deficit_start(i,1)=0;
                    surplus(i,1)=Pre_tot_daily(day,1)-deficit_end(i-1,1);
                    else
                        deficit_start(i,1)=deficit_end(i-1,1)-Pre_tot_daily(day,1);
                        surplus(i,1)=0;
                end
 
                if Pre_tot_daily(day,1)>0
                    Pre_eff_daily(i,1)=Pre_tot_daily(day,1)-surplus(i,1);
                    else
                        Pre_eff_daily(i,1)=0;
                end
                
                
                if deficit_start(i,1)>=rawc(i,1)
                                ks_rain(i,1)=(tawc(i,1)-deficit_start(i,1))/(tawc(i,1)-rawc(i,1));
                else
                    ks_rain(i,1)=1;
                end
                
                if ks_rain(i,1)>1
                    ks_rain(i,1)=1;
                end
    
                if      ks_rain(i,1)<0
                        ks_rain(i,1)=0;
                end
 
                ETa_daily(i,1)=ks_rain(i,1)*ETc_daily(i,1);
                deficit_end(i,1)=deficit_start(i,1)+ETa_daily(i,1); 
 
                day=day+1;
                
                if day>=377 % 31 december
                        day=17; % 1 january
                end
%            
                
        end
        
% annual variables

      ETa_annual=zeros(360,1);
      ETc_annual=zeros(360,1);
      ET0_rf_annual=zeros(360,1);
      Pre_eff_annual=zeros(360,1);
      Pre_tot_annual_gs=zeros(360,1);
      
      day_end=day_start+lgp-1;
      day_add=0;
          if day_end>360
              day_end=360;
              day_add=day_start+lgp-361;
          end

      for d=1:1:360+day_add
          if d>= day_start && d<= day_end
              ETa_annual(d,1)=ETa_daily(d+1-day_start,1); 
              ETc_annual(d,1)=ETc_daily(d+1-day_start,1);
              ET0_rf_annual(d,1)=ET0_rf(d+1-day_start,1);
              Pre_eff_annual(d,1)=Pre_eff_daily(d+1-day_start,1);
              Pre_tot_annual_gs(d,1)=Pre_tot_daily_growing_season(d+1-day_start,1);
          elseif d>360
              ETa_annual(d-360,1)=ETa_daily(d+1-day_start,1);
              ETc_annual(d-360,1)=ETc_daily(d+1-day_start,1);
              ET0_rf_annual(d-360,1)=ET0_rf(d+1-day_start,1);
              Pre_eff_annual(d-360,1)=Pre_eff_daily(d+1-day_start,1);
              Pre_tot_annual_gs(d-360,1)=Pre_tot_daily_growing_season(d+1-day_start,1);
          else
          end
      end
      
      ETa_month(m,n,1)=sum(ETa_annual(1:30,1));
      ETa_month(m,n,1)=sum(ETa_annual(31:60,1));
      ETa_month(m,n,3)=sum(ETa_annual(61:90,1));
      ETa_month(m,n,4)=sum(ETa_annual(91:120,1));
      ETa_month(m,n,5)=sum(ETa_annual(121:150,1));
      ETa_month(m,n,6)=sum(ETa_annual(151:180,1));
      ETa_month(m,n,7)=sum(ETa_annual(181:210,1));
      ETa_month(m,n,8)=sum(ETa_annual(211:240,1));
      ETa_month(m,n,9)=sum(ETa_annual(241:270,1));
      ETa_month(m,n,10)=sum(ETa_annual(271:300,1));
      ETa_month(m,n,11)=sum(ETa_annual(301:330,1));
      ETa_month(m,n,12)=sum(ETa_annual(331:360,1));
      
           
      ETc_month(m,n,1)=sum(ETc_annual(1:30,1));
      ETc_month(m,n,1)=sum(ETc_annual(31:60,1));
      ETc_month(m,n,3)=sum(ETc_annual(61:90,1));
      ETc_month(m,n,4)=sum(ETc_annual(91:120,1));
      ETc_month(m,n,5)=sum(ETc_annual(121:150,1));
      ETc_month(m,n,6)=sum(ETc_annual(151:180,1));
      ETc_month(m,n,7)=sum(ETc_annual(181:210,1));
      ETc_month(m,n,8)=sum(ETc_annual(211:240,1));
      ETc_month(m,n,9)=sum(ETc_annual(241:270,1));
      ETc_month(m,n,10)=sum(ETc_annual(271:300,1));
      ETc_month(m,n,11)=sum(ETc_annual(301:330,1));
      ETc_month(m,n,12)=sum(ETc_annual(331:360,1));   

            
      ET0_rf_month(m,n,1)=sum(ET0_rf_annual(1:30,1));
      ET0_rf_month(m,n,1)=sum(ET0_rf_annual(31:60,1));
      ET0_rf_month(m,n,3)=sum(ET0_rf_annual(61:90,1));
      ET0_rf_month(m,n,4)=sum(ET0_rf_annual(91:120,1));
      ET0_rf_month(m,n,5)=sum(ET0_rf_annual(121:150,1));
      ET0_rf_month(m,n,6)=sum(ET0_rf_annual(151:180,1));
      ET0_rf_month(m,n,7)=sum(ET0_rf_annual(181:210,1));
      ET0_rf_month(m,n,8)=sum(ET0_rf_annual(211:240,1));
      ET0_rf_month(m,n,9)=sum(ET0_rf_annual(241:270,1));
      ET0_rf_month(m,n,10)=sum(ET0_rf_annual(271:300,1));
      ET0_rf_month(m,n,11)=sum(ET0_rf_annual(301:330,1));
      ET0_rf_month(m,n,12)=sum(ET0_rf_annual(331:360,1));
     
      
      Pre_eff_monthly(m,n,1)=sum(Pre_eff_annual(1:30,1));
      Pre_eff_monthly(m,n,2)=sum(Pre_eff_annual(31:60,1));
      Pre_eff_monthly(m,n,3)=sum(Pre_eff_annual(61:90,1));
      Pre_eff_monthly(m,n,4)=sum(Pre_eff_annual(91:120,1));
      Pre_eff_monthly(m,n,5)=sum(Pre_eff_annual(121:150,1));
      Pre_eff_monthly(m,n,6)=sum(Pre_eff_annual(151:180,1));
      Pre_eff_monthly(m,n,7)=sum(Pre_eff_annual(181:210,1));
      Pre_eff_monthly(m,n,8)=sum(Pre_eff_annual(211:240,1));
      Pre_eff_monthly(m,n,9)=sum(Pre_eff_annual(241:270,1));
      Pre_eff_monthly(m,n,10)=sum(Pre_eff_annual(271:300,1));
      Pre_eff_monthly(m,n,11)=sum(Pre_eff_annual(301:330,1));
      Pre_eff_monthly(m,n,12)=sum(Pre_eff_annual(331:360,1));

      
      Pre_tot_monthly_gs(m,n,1)=sum(Pre_tot_annual_gs(1:30,1));
      Pre_tot_monthly_gs(m,n,2)=sum(Pre_tot_annual_gs(31:60,1));
      Pre_tot_monthly_gs(m,n,3)=sum(Pre_tot_annual_gs(61:90,1));
      Pre_tot_monthly_gs(m,n,4)=sum(Pre_tot_annual_gs(91:120,1));
      Pre_tot_monthly_gs(m,n,5)=sum(Pre_tot_annual_gs(121:150,1));
      Pre_tot_monthly_gs(m,n,6)=sum(Pre_tot_annual_gs(151:180,1));
      Pre_tot_monthly_gs(m,n,7)=sum(Pre_tot_annual_gs(181:210,1));
      Pre_tot_monthly_gs(m,n,8)=sum(Pre_tot_annual_gs(211:240,1));
      Pre_tot_monthly_gs(m,n,9)=sum(Pre_tot_annual_gs(241:270,1));
      Pre_tot_monthly_gs(m,n,10)=sum(Pre_tot_annual_gs(271:300,1));
      Pre_tot_monthly_gs(m,n,11)=sum(Pre_tot_annual_gs(301:330,1));
      Pre_tot_monthly_gs(m,n,12)=sum(Pre_tot_annual_gs(331:360,1));
      
% totals
        ETa_tot(m,n)=sum(ETa_daily);
        ETc_tot_rain(m,n)=sum(ETc_daily);
        ET0_tot_rf(m,n)=sum(ET0_rf);
        Ptot_rf(m,n) = sum(Pre_eff_daily);
        Ptot_gr_seas_rf(m,n) = sum(Pre_tot_daily_growing_season);
  end
       
 %IRRIGATED      
 
             if area_irr (m,n)>0 && day_plant_modified_irr(m,n)>0
               
        day_start=day_plant_modified_irr(m,n)+16;
        day=day_plant_modified_irr(m,n)+17;
        
        deficit_start_i(1,1)=0;
        ks(1,1)=1;
        ks_irrigated(1,1)=1;
        ETc_daily_irr(1,1)=kc_crop_irr(1,1).*ET0_daily(day_start,1);
        
        Pre_eff_daily_i(1,1)=Pre_tot_daily(day_start,1); 
        Pre_tot_daily_growing_season_IR(1,1)= Pre_tot_daily(day_start,1);

        surplus_i(1,1)=0;
        CWU_daily(1,1)=ETc_daily_irr(1,1);
        ETgreen_daily(1,1)=CWU_daily(1,1);
        deficit_end_i(1,1)=CWU_daily(1,1)+deficit_start_i(1,1);
        ETblue_daily(1,1)=0;
        I(1,1) = 0;
        deficit_st_irrigated(1,1) = 0;
        deficit_end_irrigated(1,1) = deficit_st_irrigated(1,1)+CWU_daily(1,1)-I(1,1);

        ET0_ir(1,1)=ET0_daily(day_start,1);
        
        for i=2:lgp_irr   
        ET0_ir(i,1)=ET0_daily(day,1);
        ETc_daily_irr(i,1)=kc_crop_irr(i,1).*ET0_daily(day,1);
        Pre_tot_daily_growing_season_IR(i,1)= Pre_tot_daily(day,1);

                if deficit_end_i(i-1,1)-Pre_tot_daily(day,1)<0         
                   deficit_start_i(i,1)=0;
                   surplus_i(i,1)=Pre_tot_daily(day,1)-deficit_end_i(i-1,1);
                   Pre_eff_daily_i(i,1)=deficit_end_i(i-1,1);

                    else
                        deficit_start_i(i,1)=deficit_end_i(i-1,1)-Pre_tot_daily(day,1);
                        surplus_i(i,1)=0;
                        Pre_eff_daily_i(i,1)=Pre_tot_daily(day,1);
                end
 
                
                
                             
                            if deficit_start_i(i,1)>=rawc_irrigated(i,1) 
                                
                                ks(i,1)=(tawc_irrigated(i,1)-deficit_start_i(i,1))/(tawc_irrigated(i,1)-rawc_irrigated(i,1));

                            else
                                ks(i,1)=1;
                            end


                            if ks(i,1)>1
                                ks(i,1)=1;
                            end

                            if      ks(i,1)<0
                                    ks(i,1)=0;
                            end
                ETgreen_daily(i,1)=ks(i,1)*ETc_daily_irr(i,1);
                deficit_end_i(i,1)=deficit_start_i(i,1)+ETgreen_daily(i,1); 
 
% water balance with irrigation
deficit_st_irrigated(i,1)=deficit_end_irrigated(i-1,1)-Pre_tot_daily(day,1);
if deficit_st_irrigated(i,1)<0
    deficit_st_irrigated(i,1)=0;
end
 
if deficit_st_irrigated(i,1)>=rawc_irrigated(i,1)


    %--------------------------VERSIONE 1.1--------------------------------
    I(i,1)=deficit_st_irrigated(i,1)-rawc_irrigated(i,1); %irrigation that closes the water deficit
    %----------------------------------------------------------------------

% ks_irrigated(i,1) = 1;
deficit_st_irrigated(i,1) = deficit_st_irrigated(i,1) - I(i,1);
ks_irrigated(i,1)=(tawc_irrigated(i,1)-deficit_st_irrigated(i,1))/(tawc_irrigated(i,1)-rawc_irrigated(i,1));

else
    I(i,1)=0;
%     ks_irrigated(i,1)=1;
    ks_irrigated(i,1)=(tawc_irrigated(i,1)-deficit_st_irrigated(i,1))/(tawc_irrigated(i,1)-rawc_irrigated(i,1));

end

if ks_irrigated(i,1)>1
    ks_irrigated(i,1)=1;
end

if ks_irrigated(i,1)<0
    ks_irrigated(i,1)=0;
end

    %--------------------------VERSIONE 1.1-------------------------------------------------                          
            CWU_daily(i,1)=ks_irrigated(i,1)*ETc_daily_irr(i,1); %crop water use
            deficit_end_irrigated(i,1)=deficit_st_irrigated(i,1)+CWU_daily(i,1);
            ETblue_daily(i,1)=CWU_daily(i,1)-ETgreen_daily(i,1);                                               
     %----------------------------------------------------------------------------------------                
    
                day=day+1;
                
                if day>=377
                        day=17; 
                end
        end
        
%
        
      ETgreen_annual=zeros(360,1);
      CWU_annual=zeros(360,1);
      ETblue_annual=zeros(360,1);
      I_annual=zeros(360,1);
      ETc_irr_annual=zeros(360,1);
      ET0_irr_annual=zeros(360,1);
      Pre_eff_irr_annual=zeros(360,1);
      Pre_tot_irr_annual_gs=zeros(360,1);
      
      day_end=day_start+lgp_irr-1;
      day_add=0;
          if day_end>360
              day_end=360;
              day_add=day_start+lgp_irr-361; 
          end

      for d=1:1:360+day_add
          if d>= day_start && d<= day_end
              ETgreen_annual(d,1)=ETgreen_daily(d+1-day_start,1);
              CWU_annual(d,1)=CWU_daily(d+1-day_start,1);
              ETblue_annual(d,1)=ETblue_daily(d+1-day_start,1);
              ETc_irr_annual(d,1)=ETc_daily_irr(d+1-day_start,1);
              ET0_irr_annual(d,1)=ET0_ir(d+1-day_start,1);
              I_annual(d,1)=I(d+1-day_start,1);
              Pre_eff_irr_annual(d,1)=Pre_eff_daily_i(d+1-day_start,1);
              Pre_tot_irr_annual_gs(d,1)=Pre_tot_daily_growing_season_IR(d+1-day_start,1);
              
          elseif d>360
              ETgreen_annual(d-360,1)=ETgreen_daily(d+1-day_start,1);
              CWU_annual(d-360,1)=CWU_daily(d+1-day_start,1);
              ETblue_annual(d-360,1)=ETblue_daily(d+1-day_start,1);
              ETc_irr_annual(d-360,1)=ETc_daily_irr(d+1-day_start,1);
              ET0_irr_annual(d-360,1)=ET0_ir(d+1-day_start,1);
              I_annual(d-360,1)=I(d+1-day_start,1);
              Pre_eff_irr_annual(d-360,1)=Pre_eff_daily_i(d+1-day_start,1);
              Pre_tot_irr_annual_gs(d-360,1)=Pre_tot_daily_growing_season_IR(d+1-day_start,1);
          else
          end
      end
      
%
      
      ETgreen_month(m,n,1)=sum(ETgreen_annual(1:30,1));
      ETgreen_month(m,n,2)=sum(ETgreen_annual(31:60,1));
      ETgreen_month(m,n,3)=sum(ETgreen_annual(61:90,1));
      ETgreen_month(m,n,4)=sum(ETgreen_annual(91:120,1));
      ETgreen_month(m,n,5)=sum(ETgreen_annual(121:150,1));
      ETgreen_month(m,n,6)=sum(ETgreen_annual(151:180,1));
      ETgreen_month(m,n,7)=sum(ETgreen_annual(181:210,1));
      ETgreen_month(m,n,8)=sum(ETgreen_annual(211:240,1));
      ETgreen_month(m,n,9)=sum(ETgreen_annual(241:270,1));
      ETgreen_month(m,n,10)=sum(ETgreen_annual(271:300,1));
      ETgreen_month(m,n,11)=sum(ETgreen_annual(301:330,1));
      ETgreen_month(m,n,12)=sum(ETgreen_annual(331:360,1));
      
           
      CWU_month(m,n,1)=sum(CWU_annual(1:30,1));
      CWU_month(m,n,1)=sum(CWU_annual(31:60,1));
      CWU_month(m,n,3)=sum(CWU_annual(61:90,1));
      CWU_month(m,n,4)=sum(CWU_annual(91:120,1));
      CWU_month(m,n,5)=sum(CWU_annual(121:150,1));
      CWU_month(m,n,6)=sum(CWU_annual(151:180,1));
      CWU_month(m,n,7)=sum(CWU_annual(181:210,1));
      CWU_month(m,n,8)=sum(CWU_annual(211:240,1));
      CWU_month(m,n,9)=sum(CWU_annual(241:270,1));
      CWU_month(m,n,10)=sum(CWU_annual(271:300,1));
      CWU_month(m,n,11)=sum(CWU_annual(301:330,1));
      CWU_month(m,n,12)=sum(CWU_annual(331:360,1));   

            
      ETblue_month(m,n,1)=sum(ETblue_annual(1:30,1));
      ETblue_month(m,n,1)=sum(ETblue_annual(31:60,1));
      ETblue_month(m,n,3)=sum(ETblue_annual(61:90,1));
      ETblue_month(m,n,4)=sum(ETblue_annual(91:120,1));
      ETblue_month(m,n,5)=sum(ETblue_annual(121:150,1));
      ETblue_month(m,n,6)=sum(ETblue_annual(151:180,1));
      ETblue_month(m,n,7)=sum(ETblue_annual(181:210,1));
      ETblue_month(m,n,8)=sum(ETblue_annual(211:240,1));
      ETblue_month(m,n,9)=sum(ETblue_annual(241:270,1));
      ETblue_month(m,n,10)=sum(ETblue_annual(271:300,1));
      ETblue_month(m,n,11)=sum(ETblue_annual(301:330,1));
      ETblue_month(m,n,12)=sum(ETblue_annual(331:360,1));

      
      ETc_irr_month(m,n,1)=sum(ETc_irr_annual(1:30,1));
      ETc_irr_month(m,n,1)=sum(ETc_irr_annual(31:60,1));
      ETc_irr_month(m,n,3)=sum(ETc_irr_annual(61:90,1));
      ETc_irr_month(m,n,4)=sum(ETc_irr_annual(91:120,1));
      ETc_irr_month(m,n,5)=sum(ETc_irr_annual(121:150,1));
      ETc_irr_month(m,n,6)=sum(ETc_irr_annual(151:180,1));
      ETc_irr_month(m,n,7)=sum(ETc_irr_annual(181:210,1));
      ETc_irr_month(m,n,8)=sum(ETc_irr_annual(211:240,1));
      ETc_irr_month(m,n,9)=sum(ETc_irr_annual(241:270,1));
      ETc_irr_month(m,n,10)=sum(ETc_irr_annual(271:300,1));
      ETc_irr_month(m,n,11)=sum(ETc_irr_annual(301:330,1));
      ETc_irr_month(m,n,12)=sum(ETc_irr_annual(331:360,1));

      
      ET0_irr_month(m,n,1)=sum(ET0_irr_annual(1:30,1));
      ET0_irr_month(m,n,1)=sum(ET0_irr_annual(31:60,1));
      ET0_irr_month(m,n,3)=sum(ET0_irr_annual(61:90,1));
      ET0_irr_month(m,n,4)=sum(ET0_irr_annual(91:120,1));
      ET0_irr_month(m,n,5)=sum(ET0_irr_annual(121:150,1));
      ET0_irr_month(m,n,6)=sum(ET0_irr_annual(151:180,1));
      ET0_irr_month(m,n,7)=sum(ET0_irr_annual(181:210,1));
      ET0_irr_month(m,n,8)=sum(ET0_irr_annual(211:240,1));
      ET0_irr_month(m,n,9)=sum(ET0_irr_annual(241:270,1));
      ET0_irr_month(m,n,10)=sum(ET0_irr_annual(271:300,1));
      ET0_irr_month(m,n,11)=sum(ET0_irr_annual(301:330,1));
      ET0_irr_month(m,n,12)=sum(ET0_irr_annual(331:360,1));
     
      
      Pre_eff_irr_month(m,n,1)=sum(Pre_eff_irr_annual(1:30,1));
      Pre_eff_irr_month(m,n,2)=sum(Pre_eff_irr_annual(31:60,1));
      Pre_eff_irr_month(m,n,3)=sum(Pre_eff_irr_annual(61:90,1));
      Pre_eff_irr_month(m,n,4)=sum(Pre_eff_irr_annual(91:120,1));
      Pre_eff_irr_month(m,n,5)=sum(Pre_eff_irr_annual(121:150,1));
      Pre_eff_irr_month(m,n,6)=sum(Pre_eff_irr_annual(151:180,1));
      Pre_eff_irr_month(m,n,7)=sum(Pre_eff_irr_annual(181:210,1));
      Pre_eff_irr_month(m,n,8)=sum(Pre_eff_irr_annual(211:240,1));
      Pre_eff_irr_month(m,n,9)=sum(Pre_eff_irr_annual(241:270,1));
      Pre_eff_irr_month(m,n,10)=sum(Pre_eff_irr_annual(271:300,1));
      Pre_eff_irr_month(m,n,11)=sum(Pre_eff_irr_annual(301:330,1));
      Pre_eff_irr_month(m,n,12)=sum(Pre_eff_irr_annual(331:360,1));

      
      Pre_tot_irr_month_gs(m,n,1)=sum(Pre_tot_irr_annual_gs(1:30,1));
      Pre_tot_irr_month_gs(m,n,2)=sum(Pre_tot_irr_annual_gs(31:60,1));
      Pre_tot_irr_month_gs(m,n,3)=sum(Pre_tot_irr_annual_gs(61:90,1));
      Pre_tot_irr_month_gs(m,n,4)=sum(Pre_tot_irr_annual_gs(91:120,1));
      Pre_tot_irr_month_gs(m,n,5)=sum(Pre_tot_irr_annual_gs(121:150,1));
      Pre_tot_irr_month_gs(m,n,6)=sum(Pre_tot_irr_annual_gs(151:180,1));
      Pre_tot_irr_month_gs(m,n,7)=sum(Pre_tot_irr_annual_gs(181:210,1));
      Pre_tot_irr_month_gs(m,n,8)=sum(Pre_tot_irr_annual_gs(211:240,1));
      Pre_tot_irr_month_gs(m,n,9)=sum(Pre_tot_irr_annual_gs(241:270,1));
      Pre_tot_irr_month_gs(m,n,10)=sum(Pre_tot_irr_annual_gs(271:300,1));
      Pre_tot_irr_month_gs(m,n,11)=sum(Pre_tot_irr_annual_gs(301:330,1));
      Pre_tot_irr_month_gs(m,n,12)=sum(Pre_tot_irr_annual_gs(331:360,1));
      
           
      I_month(m,n,1)=sum(I_annual(1:30,1));
      I_month(m,n,2)=sum(I_annual(31:60,1));
      I_month(m,n,3)=sum(I_annual(61:90,1));
      I_month(m,n,4)=sum(I_annual(91:120,1));
      I_month(m,n,5)=sum(I_annual(121:150,1));
      I_month(m,n,6)=sum(I_annual(151:180,1));
      I_month(m,n,7)=sum(I_annual(181:210,1));
      I_month(m,n,8)=sum(I_annual(211:240,1));
      I_month(m,n,9)=sum(I_annual(241:270,1));
      I_month(m,n,10)=sum(I_annual(271:300,1));
      I_month(m,n,11)=sum(I_annual(301:330,1));
      I_month(m,n,12)=sum(I_annual(331:360,1));
      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ETgreen_tot(m,n)=sum(ETgreen_daily);        
        CWU_tot(m,n)=sum(CWU_daily);
        ETblue_tot(m,n)=sum(ETblue_daily); 
        I_tot(m,n)=sum(I);
        ETc_tot_irr(m,n)=sum(ETc_daily_irr);   
        ET0_tot_ir(m,n)=sum(ET0_ir);
        Ptot_ir(m,n)=sum(Pre_eff_daily_i);
        Ptot_gr_seas_ir(m,n)=sum(Pre_tot_daily_growing_season_IR);
        
        
            end
        end
    end
end

mkdir(cartella_risultati)
cd(cartella_risultati)

save('ETa_rain.mat','ETa_tot') 
save('Ptot_rf.mat','Ptot_rf')
save('ETa_irr.mat','CWU_tot')
save('ET_blu.mat','ETblue_tot') 
save('ET0_tot_rf.mat','ET0_tot_rf')
save('ET0_tot_ir.mat','ET0_tot_ir') 
save('Ptot_ir.mat','Ptot_ir')
save('ETc_tot_rain.mat','ETc_tot_rain')
save('ETc_tot_irr.mat','ETc_tot_irr')

save('ETa_rf_month.mat','ETa_month') 
save('ETc_rf_month.mat','ETc_month') 
save('ET0_rf_month.mat','ET0_rf_month')
save('Pre_eff_monthly.mat','Pre_eff_monthly')
save('Pre_tot_monthly_gs.mat','Pre_tot_monthly_gs')
save('ETgreen_month.mat','ETgreen_month')
save('ETa_irr_month.mat','CWU_month') 
save('ETblue_month.mat','ETblue_month')
save('I_month.mat','I_month')
save('ETc_irr_month.mat','ETc_irr_month')
save('ET0_irr_month.mat','ET0_irr_month')
save('Pre_eff_irr_month.mat','Pre_eff_irr_month')
save('Pre_tot_irr_month_gs.mat','Pre_tot_irr_month_gs')

end