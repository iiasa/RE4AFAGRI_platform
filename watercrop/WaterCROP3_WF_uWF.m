clear all
clc


raccolto=1:40; %crop switch
for r = 1 %crop index
    r
    
switch raccolto(r)
    
case 1
    crop = 'Maize';
    
    area_irrigata='spam2017V2r1_SSA_H_MAIZ_I.mat';
    area_rainfed='spam2017V2r1_SSA_H_MAIZ_R.mat';
    area_totale='spam2017V2r1_SSA_H_MAIZ_A.mat';
    
    y_avg='spam2017V2r1_SSA_Y_MAIZ_A.mat'; 
    y_irr='spam2017V2r1_SSA_Y_MAIZ_I.mat';
    y_rf='spam2017V2r1_SSA_Y_MAIZ_R.mat';
    
% case 2
%     crop = 'Wheat';
%     
%     area_irrigata='aree_irr_whe_2010.mat';
%     area_rainfed='aree_rf_whe_2010.mat';
%     area_totale='aree_tot_whe_2010.mat';
%     
%     y_avg='ya_whe_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_whe_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_whe_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 3
%     crop = 'Soy';
%     
%     area_irrigata='aree_irr_soy_2010.mat';
%     area_rainfed='aree_rf_soy_2010.mat';
%     area_totale='aree_tot_soy_2010.mat';
%     
%     y_avg='ya_soy_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_soy_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_soy_2071_00_RCP60_rf_CO2_ENSEMBLE.mat'; 
% 
% case 4 
%     crop = 'Sorghum';
%     
%     area_irrigata='aree_irr_srg_2010.mat';
%     area_rainfed='aree_rf_srg_2010.mat';
%     area_totale='aree_tot_srg_2010.mat';
%     
%     y_avg='ya_srg_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_srg_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_srg_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 5
%     crop = 'Rice';
%     
%     area_irrigata='aree_irr_rice_2010.mat';
%     area_rainfed='aree_rf_rice_2010.mat';
%     area_totale='aree_tot_rice_2010.mat';
%     
%     y_avg='ya_rice_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_rice_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_rice_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 6
%     crop = 'Groundnut';
%     
%     area_irrigata='aree_irr_gnut_2010.mat';
%     area_rainfed='aree_rf_gnut_2010.mat';
%     area_totale='aree_tot_gnut_2010.mat';
%     
%     y_avg='ya_gnut_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_gnut_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_gnut_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 7
%     crop = 'Barley';
%     
%     area_irrigata='aree_irr_brl_2010.mat';
%     area_rainfed='aree_rf_brl_2010.mat';
%     area_totale='aree_tot_brl_2010.mat';
%     
%     y_avg='ya_brl_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_brl_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_brl_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 8
%     crop = 'Cassava';
%     
%     area_irrigata='aree_irr_cas_2010.mat';
%     area_rainfed='aree_rf_cas_2010.mat';
%     area_totale='aree_tot_cas_2010.mat';
%     
%     y_avg='ya_cas_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_cas_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_cas_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 9
%     crop = 'Cotton';
%     
%     area_irrigata='aree_irr_cot_2010.mat';
%     area_rainfed='aree_rf_cot_2010.mat';
%     area_totale='aree_tot_cot_2010.mat';
%     
%     y_avg='ya_cot_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_cot_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_cot_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 10
%     crop = 'Millet';
%     
%     area_irrigata='aree_irr_mlt_2010.mat';
%     area_rainfed='aree_rf_mlt_2010.mat';
%     area_totale='aree_tot_mlt_2010.mat';
%    
%     y_avg='ya_mlt_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_mlt_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_mlt_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
%     
% case 11
%     crop = 'Sugarcane';
%     
%     area_irrigata='aree_irr_suc_2010.mat';
%     area_rainfed='aree_rf_suc_2010.mat';
%     area_totale='aree_tot_suc_2010.mat';
%     
%     y_avg='ya_suc_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
%     y_irr='ya_suc_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_suc_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
    
% case 12 usa altro codice x yams
%     crop = 'Yams';
%     
% %     area_irrigata='aree_irr_yam_2010.mat';
%     area_rainfed='aree_rf_yam_2010.mat';
% %     area_totale='aree_tot_yam_2010.mat';
%     
% %     y_avg='ya_yam_2071_00_RCP60_avg_CO2_ENSEMBLE.mat';
% %     y_irr='ya_yam_2071_00_RCP60_irr_CO2_ENSEMBLE.mat';
%     y_rf='ya_yam_2071_00_RCP60_rf_CO2_ENSEMBLE.mat';
    
end

cartella_aree = ['C:\Users\giord\Desktop\IIASA collab\WaterCrop\',crop,''];

cartella_ET_Igrow = ['C:\Users\giord\Desktop\IIASA collab\WaterCrop\Risultati1_ETa\',crop,''];

cartella_rese = ['C:\Users\giord\Desktop\IIASA collab\WaterCrop\',crop,''];

cd(cartella_aree)
area_irr=importdata(area_irrigata);

area_rain=importdata(area_rainfed);

area_tot=importdata(area_totale);
     
cd(cartella_ET_Igrow)
    ET_verde_rain=importdata('ETa_rain.mat');
    ET_blu_irr=importdata('ET_blu.mat');
    ET_tot_irr=importdata('ETa_irr.mat');
    
    ET_verde_irr=ET_tot_irr-ET_blu_irr;
    
cd(cartella_rese)
resa=importdata(y_avg);
resa_irr=importdata(y_irr);
resa_rain=importdata(y_rf);

% 2 growing seasons
% ET_verde=(ET_verde_rain.*area_rain+ET_verde_irr.*area_irr + ET_verde_rainII.*area_rain_II+ET_verde_irrII.*area_irr_II)./(area_rain+area_irr + area_rain_II+area_irr_II);
% ET_blu=(ET_blu_irr.*area_irr + ET_blu_irrII.*area_irr_II)./(area_rain+area_irr + area_rain_II+area_irr_II);

% 1 growing season
    ET_verde_I_grow=(ET_verde_rain.*area_rain+ET_verde_irr.*area_irr)./(area_tot);
    ET_blu_I_grow=(ET_blu_irr.*area_irr)./(area_tot);
    
%calcolo et verde e blu complessive dei due scenari, pesando i contributi in funzione dell'area coltivata

% ET_rf=(ET_verde_rain.*area_rain + ET_verde_rainII.*area_rain_II)./(area_rain+area_irr + area_rain_II+area_irr_II);
% ET_ir=(ET_tot_irr.*area_irr + ET_tot_irrII.*area_irr_II)./(area_rain+area_irr + area_rain_II+area_irr_II);

%calcolo l'impronta idrica complessiva dei due scenari
    uWF_rf_I_grow=ET_verde_rain*10./resa_rain; 
    uWF_ir_I_grow=ET_tot_irr*10./resa_irr;

%calcolo l'impronta idrica complessiva dei due scenari
    uWF_verde_I_grow=ET_verde_I_grow*10./resa; %average yield
    uWF_blu_I_grow=ET_blu_I_grow*10./resa;
    
    uWF_rf_I_grow(isinf(uWF_rf_I_grow))=0;
    uWF_rf_I_grow(isnan(uWF_rf_I_grow))=0;
    
    uWF_ir_I_grow(isinf(uWF_ir_I_grow))=0;
    uWF_ir_I_grow(isnan(uWF_ir_I_grow))=0;

    uWF_verde_I_grow(isinf(uWF_verde_I_grow))=0;
    uWF_verde_I_grow(isnan(uWF_verde_I_grow))=0;

    uWF_blu_I_grow(isinf(uWF_blu_I_grow))=0;
    uWF_blu_I_grow(isnan(uWF_blu_I_grow))=0;

    uWF_tot_I_grow=uWF_verde_I_grow+uWF_blu_I_grow;

    uWF_tot_I_grow(isinf(uWF_tot_I_grow))=0;
    uWF_tot_I_grow(isnan(uWF_tot_I_grow))=0;
    
prod_irr=resa_irr.*area_irr;
prod_rf=resa_rain.*area_rain;
prod_tot=resa.*area_tot;
    
WFb=uWF_blu_I_grow.*prod_tot;
WFb(isinf(WFb))=0;
WFb(isnan(WFb))=0;

WFg=uWF_verde_I_grow.*prod_tot;
WFg(isinf(WFg))=0;
WFg(isnan(WFg))=0;

WFt=uWF_tot_I_grow.*prod_tot;
WFt(isinf(WFt))=0;
WFt(isnan(WFt))=0;

WFirr=uWF_ir_I_grow.*prod_irr;
WFirr(isinf(WFirr))=0;
WFirr(isnan(WFirr))=0;

WFrf=uWF_rf_I_grow.*prod_rf;
WFrf(isinf(WFrf))=0;
WFrf(isnan(WFrf))=0;

%memorizzo i risultati
cartella_risultati_I_grow=['C:\Users\giord\Desktop\IIASA collab\WaterCrop\Risultati3_WF\',crop,''];
cd(cartella_risultati_I_grow)

save('ET_verde_I_grow.mat','ET_verde_I_grow')
save('ET_blu_I_grow.mat','ET_blu_I_grow')
save('uWF_verde_I_grow.mat','uWF_verde_I_grow')
save('uWF_blu_I_grow.mat','uWF_blu_I_grow')
save('uWF_tot_I_grow.mat','uWF_tot_I_grow')
save('uWF_ir_I_grow.mat','uWF_ir_I_grow')
save('uWF_rf_I_grow.mat','uWF_rf_I_grow')
save('WFg.mat','WFg')
save('WFb.mat','WFb')
save('WFt.mat','WFt')
save('WFirr.mat','WFirr')
save('WFrf.mat','WFrf')
 
%  fid=fopen('uWF_tot_I_grow.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
%     
%         fprintf(fid,'%.2f ',uWF_tot_I_grow(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% %  
% fid=fopen('uWF_blu_I_grow.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
%     
%         fprintf(fid,'%.2f ',uWF_blu_I_grow(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% % 
%  fid=fopen('uWF_verde_I_grow.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
% 
%         fprintf(fid,'%.2f ',uWF_verde_I_grow(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% %  
%  fid=fopen('uWF_rf_I_grow.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
% 
%         fprintf(fid,'%.2f ',uWF_rf_I_grow(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% %  
%  fid=fopen('uWF_ir_I_grow.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
% 
%         fprintf(fid,'%.2f ',uWF_ir_I_grow(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
%  
% fid=fopen('WFt.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
%     
%         fprintf(fid,'%.2f ',WFt(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% %  
% fid=fopen('WFb.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
%     
%         fprintf(fid,'%.2f ',WFb(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% % 
%  fid=fopen('WFg.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
% 
%         fprintf(fid,'%.2f ',WFg(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% %  
%  fid=fopen('WFrf.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
% 
%         fprintf(fid,'%.2f ',WFrf(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% %  
%  fid=fopen('WFirr.txt','w');
%    fprintf(fid,'ncols 4320\r\nnrows 2160\r\nxllcorner -180\r\nyllcorner -90\r\ncellsize 0.0833333\r\nNODATA_value 0\r\n');
% for i=1:2160
% 
%         fprintf(fid,'%.2f ',WFirr(i,:));
%     
%     fprintf(fid,'\r\n');
% end
%  fclose(fid);
% 
% end
