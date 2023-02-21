clc
clear all

crop_name = [{'Barley'},'Cassava','Cocoa','Cotton','Groundnut','Maize','Millet_pearl','Millet_small','Oil palm','Potatoes','Rapeseed','Rice','Sorghum','Soybean','Sugarbeet','Sugarcane','Sunflower','Wheat','Yams'];
crop = [{'Barley'},'Cassava','Cocoa','Cotton','Groundnut','Maize','Millet_pearl','Millet_small','Oil palm','Potatoes','Rapeseed','Rice','Sorghum','Soybean','Sugarbeet','Sugarcane','Sunflower','Wheat','Yams'];
code = [{'BARL'},'CASS','COCO','COTT','GROU','MAIZ','PMIL','SMIL','OILP','POTA','RAPE','RICE','SORG','SOYB','SUGB','SUGC','SUNF','WHEA','YAMS']; 


cd('C:\Users\giord\Desktop\IIASA collab\WaterCrop')
ky = xlsread('crops_list_ky.xlsx','B2:B20');

for cr = 6 %1 2 3 4 5 6 7 9 11 12 22 28 crop number
    
    cd(['C:\Users\giord\Desktop\IIASA collab\WaterCrop\',char(crop_name(cr)),''])
    area_rf = importdata(['spam2017V2r1_SSA_H_',char(code(cr)),'_R.mat']);
    area_ir = importdata(['spam2017V2r1_SSA_H_',char(code(cr)),'_I.mat']);
    ya = importdata(['spam2017V2r1_SSA_Y_',char(code(cr)),'_R.mat']);
    ya(isnan(ya)) = 0;
    
    cd(['C:\Users\giord\Desktop\IIASA collab\WaterCrop\Risultati1_ETa\',char(crop(cr)),''])
   
    ETa_RF = importdata('ETa_rf_month.mat');
    ETa_IR = importdata('ETa_irr_month.mat');
    ETa_ann_RF= importdata('ETa_rain.mat');  
    ETa_ann_IR= importdata('ETa_irr.mat');
    
    ETc_RF = importdata('ETc_rf_month.mat');
    ETc_IR = importdata('ETc_irr_month.mat');
    ETc_ann_RF= importdata('ETc_tot_rain.mat');  
    ETc_ann_IR= importdata('ETc_tot_irr.mat');
    
    actual_I_mm = importdata('I_month.mat');
    
    ETa=zeros(2160,4320,12);
    ETc=zeros(2160,4320,12);
    
    ETa(:,:,1) = (ETa_RF(:,:,1).*area_rf + ETa_IR(:,:,1).*area_ir)./(area_rf + area_ir);
    ETa(:,:,2) = (ETa_RF(:,:,2).*area_rf + ETa_IR(:,:,2).*area_ir)./(area_rf + area_ir);
    ETa(:,:,3) = (ETa_RF(:,:,3).*area_rf + ETa_IR(:,:,3).*area_ir)./(area_rf + area_ir);
    ETa(:,:,4) = (ETa_RF(:,:,4).*area_rf + ETa_IR(:,:,4).*area_ir)./(area_rf + area_ir);
    ETa(:,:,5) = (ETa_RF(:,:,5).*area_rf + ETa_IR(:,:,5).*area_ir)./(area_rf + area_ir);
    ETa(:,:,6) = (ETa_RF(:,:,6).*area_rf + ETa_IR(:,:,6).*area_ir)./(area_rf + area_ir);
    ETa(:,:,7) = (ETa_RF(:,:,7).*area_rf + ETa_IR(:,:,7).*area_ir)./(area_rf + area_ir);
    ETa(:,:,8) = (ETa_RF(:,:,8).*area_rf + ETa_IR(:,:,8).*area_ir)./(area_rf + area_ir);
    ETa(:,:,9) = (ETa_RF(:,:,9).*area_rf + ETa_IR(:,:,9).*area_ir)./(area_rf + area_ir);
    ETa(:,:,10) = (ETa_RF(:,:,10).*area_rf + ETa_IR(:,:,10).*area_ir)./(area_rf + area_ir);
    ETa(:,:,11) = (ETa_RF(:,:,11).*area_rf + ETa_IR(:,:,11).*area_ir)./(area_rf + area_ir);
    ETa(:,:,12) = (ETa_RF(:,:,12).*area_rf + ETa_IR(:,:,12).*area_ir)./(area_rf + area_ir);
    
    ETc(:,:,1) = (ETc_RF(:,:,1).*area_rf + ETc_IR(:,:,1).*area_ir)./(area_rf + area_ir);
    ETc(:,:,2) = (ETc_RF(:,:,2).*area_rf + ETc_IR(:,:,2).*area_ir)./(area_rf + area_ir);
    ETc(:,:,3) = (ETc_RF(:,:,3).*area_rf + ETc_IR(:,:,3).*area_ir)./(area_rf + area_ir);
    ETc(:,:,4) = (ETc_RF(:,:,4).*area_rf + ETc_IR(:,:,4).*area_ir)./(area_rf + area_ir);
    ETc(:,:,5) = (ETc_RF(:,:,5).*area_rf + ETc_IR(:,:,5).*area_ir)./(area_rf + area_ir);
    ETc(:,:,6) = (ETc_RF(:,:,6).*area_rf + ETc_IR(:,:,6).*area_ir)./(area_rf + area_ir);
    ETc(:,:,7) = (ETc_RF(:,:,7).*area_rf + ETc_IR(:,:,7).*area_ir)./(area_rf + area_ir);
    ETc(:,:,8) = (ETc_RF(:,:,8).*area_rf + ETc_IR(:,:,8).*area_ir)./(area_rf + area_ir);
    ETc(:,:,9) = (ETc_RF(:,:,9).*area_rf + ETc_IR(:,:,9).*area_ir)./(area_rf + area_ir);
    ETc(:,:,10) = (ETc_RF(:,:,10).*area_rf + ETc_IR(:,:,10).*area_ir)./(area_rf + area_ir);
    ETc(:,:,11) = (ETc_RF(:,:,11).*area_rf + ETc_IR(:,:,11).*area_ir)./(area_rf + area_ir);
    ETc(:,:,12) = (ETc_RF(:,:,12).*area_rf + ETc_IR(:,:,12).*area_ir)./(area_rf + area_ir);
        
    ETa_ann = (ETa_ann_RF.*area_rf + ETa_ann_IR.*area_ir)./(area_rf + area_ir);
    ETc_ann = (ETc_ann_RF.*area_rf + ETc_ann_IR.*area_ir)./(area_rf + area_ir);
    
    ETc(isnan(ETc)) = 0;
    ETc(isinf(ETc)) = 0;
    
    ETc_ann(isnan(ETc_ann)) = 0;
    ETc_ann(isinf(ETc_ann)) = 0;
    
    ETa(isnan(ETa)) = 0;
    ETa(isinf(ETa)) = 0;
    
    ETa_ann(isnan(ETa_ann)) = 0;
    ETa_ann(isinf(ETa_ann)) = 0;
    
 %water needed for gap closure between actual evapotranspiration and crop potential evapotranspiration   
    closure_mm=zeros(2160,4320,12);
    for i=1:12
    closure_mm(:,:,i) = ETc(:,:,i) - ETa(:,:,i); %[mm]
    end
    
%Doorenbos yield with new ETa
    yc = ya .* (ones(2160,4320)-ky(cr)*(ones(2160,4320)-ETc_ann./ETa_ann));
%     yc = ya .* (ones(2160,4320)-ky(cr)*(ones(2160,4320)-(ETa + 0.2*closure_mm)./ETa));
    
    yc(isnan(yc)) = 0;
    yc(isinf(yc)) = 0;
    
    %percentage variation        
    delta = (yc - ya)./ya * 100;
        
    cart_new = ['C:\Users\giord\Desktop\IIASA collab\WaterCrop\Risultati2_NEST\',char(crop(cr)),''];
    cd(cart_new)
    save('closure_yield.mat','yc')
    save('yield_percentage_variation.mat','delta')
    
    yc(yc==0) = -9999;    
    txt_per_QGis(yc,'closure_yield','-9999','0.0833333','2')
    
    delta(delta<0) = -9999;
    delta(isnan(delta)) = -9999;
    delta(isinf(delta)) = -9999;
    txt_per_QGis(delta,'yield_percentage_variation','-9999','0.0833333','2')
    
    closure_m3 = closure_mm .* area_rf./ 10; %[m3]
%     txt_per_QGis(closure_m3_jan,'closure_m3_jan','-9999','0.0833333') %2D-only
    save('closure_mm.mat','closure_mm')
    save('closure_m3.mat','closure_m3')

     actual_I_m3=(actual_I_mm.*area_ir)./10;
     actual_I_m3(isnan(actual_I_m3))=0;
     %     txt_per_QGis(actual_I_mm(:,:,1),'actual_I_mm_jan','-9999','0.0833333','2')
     
     nccreate('waterwith_2020_monthly_maize_mm.nc','Irr_mm','Dimensions',{'x',2160,'y',4320,'z',12});
     ncwrite('waterwith_2020_monthly_maize_mm.nc','Irr_mm',actual_I_mm);
     nccreate('waterwith_2020_monthly_maize_m3.nc','Irr_m3','Dimensions',{'x',2160,'y',4320,'z',12});
     ncwrite('waterwith_2020_monthly_maize_m3.nc','Irr_m3',actual_I_m3);
end