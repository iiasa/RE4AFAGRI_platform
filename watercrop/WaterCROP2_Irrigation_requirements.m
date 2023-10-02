crop_name = [{'Cassava'},'Cocoa','Cotton','Groundnut','Maize','Millet_pearl','Millet_small','Potatoes','Rice','Sorghum','Soybean','Sugarcane','Sunflower','Wheat'];
crop = [{'Cassava'},'Cocoa','Cotton','Groundnut','Maize','Millet_pearl','Millet_small','Potatoes','Rice','Sorghum','Soybean','Sugarcane','Sunflower','Wheat'];
code = [{'CASS'},'COCO','COTT','GROU','MAIZ','PMIL','SMIL','POTA','RICE','SORG','SOYB','SUGC','SUNF','WHEA']; 
code_G = [{'cas'},'coco','cot','gnut','mze','pmlt','smlt','wpo','rice','srg','soy','suc','sfl','whe'];
month = [{'January'},'February','March','April','May','June','July','August','September','October','November','December'];
latlim = [-90 90];
lonlim = [-180 180];
rasterSize = [2160 4320];
R = georefcells(latlim,lonlim,rasterSize,'ColumnsStartFrom','north');
tags.Compression = Tiff.Compression.Deflate;

cd('~/WaterCROP')
ky = xlsread('crops_list_ky.xlsx','B2:B20');

year=[{'2020_370_GFDL'},'2030_370_GFDL','2040_370_GFDL','2050_370_GFDL'];

cd('C:\Users\giord\OneDrive - Politecnico di Torino\IIASA collab\RE4AFAGRI\Zambia')
perc_scen=importdata('perc_scen.mat'); % ETa percentage of ETc for ZAMBIA, for each crop and scenario

for v = 1:4 %time interval
    for cr =1:14 %crop number
    
    cd(['~\WaterCROP\',char(crop_name(cr)),''])
    area_rf = importdata(['spam2017V2r1_SSA_H_',char(code(cr)),'_R.mat']);
    area_rf(isnan(area_rf))=0;
    area_ir = importdata(['spam2017V2r1_SSA_H_',char(code(cr)),'_I.mat']);
    area_ir(isnan(area_ir))=0;
    area_tot= importdata(['spam2017V2r1_SSA_H_',char(code(cr)),'_A.mat']);
    area_tot(isnan(area_tot))=0;
    
    ya_rf = importdata(['spam2017V2r1_SSA_Y_',char(code(cr)),'_R.mat']);  % actual yield - Mapspam
    ya_rf(isnan(ya_rf)) = 0;
    
    ya_ir = importdata(['spam2017V2r1_SSA_Y_',char(code(cr)),'_I.mat']);
    ya_ir(isnan(ya_ir)) = 0;
    
    ya_avg = importdata(['spam2017V2r1_SSA_Y_',char(code(cr)),'_A.mat']);
    ya_avg(isnan(ya_avg)) = 0;
    
    y_rf_GAEZ_40=importdata(['ya_',char(code_G(cr)),'_2011_40_RCP60_rf_CO2_ENSEMBLE.mat']); %attainable yield GAEZ 2011-2040
    y_rf_GAEZ_40(isnan(y_rf_GAEZ_40))=0;
    
    y_irr_GAEZ_40=importdata(['ya_',char(code_G(cr)),'_2011_40_RCP60_irr_CO2_ENSEMBLE.mat']);
    y_irr_GAEZ_40(isnan(y_irr_GAEZ_40))=0;
    
    y_rf_GAEZ_70=importdata(['ya_',char(code_G(cr)),'_2041_70_RCP60_rf_CO2_ENSEMBLE.mat']); %attainable yield GAEZ 2041-2070
    y_rf_GAEZ_70(isnan(y_rf_GAEZ_70))=0;
    
    y_irr_GAEZ_70=importdata(['ya_',char(code_G(cr)),'_2041_70_RCP60_irr_CO2_ENSEMBLE.mat']);
    y_irr_GAEZ_70(isnan(y_irr_GAEZ_70))=0;

    y_avg_GAEZ_40=importdata(['ya_',char(code_G(cr)),'_2011_40_RCP60_avg_CO2_ENSEMBLE.mat']); % average attainable yield GAEZ 2011-2040
    y_avg_GAEZ_40(isnan(y_avg_GAEZ_40))=0;
    
    y_avg_GAEZ_70=importdata(['ya_',char(code_G(cr)),'_2041_70_RCP60_avg_CO2_ENSEMBLE.mat']); % average attainable yield GAEZ 2041-2070
    y_avg_GAEZ_70(isnan(y_avg_GAEZ_70))=0;
    
    cd(['~\WaterCROP\Results1\',char(crop(cr)),'\',char(year(v)),''])
   
    ETa_RF = importdata('ETa_rf_month.mat'); 
    ETa_ann_RF= importdata('ETa_rain.mat');
    
    ETa_IR = importdata('ETa_irr_month.mat');
    ETa_ann_IR= importdata('ETa_irr.mat');
    
    ETc_RF = importdata('ETc_rf_month.mat');
    ETc_ann_RF= importdata('ETc_tot_rain.mat'); 
    
    ETc_ann_IR= importdata('ETc_tot_irr.mat'); 
    ET_blu = importdata('ETblue_month.mat');
    
    cd(['~\WaterCROP\Results1\',char(crop(cr)),'\2020_370_GFDL'])
   
    ETa_ann_RF_2020= importdata('ETa_rain.mat');
    ETa_ann_IR_2020= importdata('ETa_irr.mat');
    
    P=perc_scen(cr,v); 
%%  
    ET_blu_m3=(ET_blu.*area_ir).*10;
    ET_blu_m3(isinf(ET_blu_m3))=0;
    
%% SCENARIO 3: Irrigation expansion, evapotranspiration reaches ETc by 2050, GAEZ attainable yields achieved by 2050 through improved management condition and high input levels
%--------------    
    if v==2 
        if P<0.7
            P3=0.7; % ETa achieved in scenario 3 and time period as percentage of ETc 
        else
            P3=P;
        end
    end
    
    if v==3 
        if P<0.85
            P3=0.85;
        else
            P3=P;
        end
    end
    
    if v==4 
         P3=1;% 100% ETc achieved on rainfed areas
    else
    end
%-----------------           

    if v>1
        %water needed for gap closure between actual evapotranspiration and crop potential evapotranspiration   
        closure_mm_scen3=zeros(2160,4320,12);
        
        for i=1:12
            for s=630:1500 
                for r=1855:2780 %Africa
                    if ETa_RF(s,r,i)<=(P3*ETc_RF(s,r,i)) && ETa_RF(s,r,i)>(0.5*ETc_RF(s,r,i))
                        closure_mm_scen3(s,r,i) = P3.*ETc_RF(s,r,i) - ETa_RF(s,r,i);
                    elseif (P3*ETc_RF(s,r,i))<ETa_RF(s,r,i) || ETa_RF(s,r,i)<(0.5*ETc_RF(s,r,i))
                        closure_mm_scen3(s,r,i) = ETc_RF(s,r,i) - ETa_RF(s,r,i);
                    end
                end
            end
        end
        %-----------------
%         var_per_closure=ETa_ann_RF(:,:)./ETc_ann_RF(:,:);
        
        closure_m3_scen3 = closure_mm_scen3.* area_rf.*10; %[m3]
        closure_mm_scen3(isinf(closure_mm_scen3))=NaN;
        closure_m3_scen3(isinf(closure_m3_scen3))=NaN;
    
%% Doorenbos yield from y_actual 2000 - Starting equation
        yx_rf_scen3=zeros(2160,4320); %Doorenbos yield rainfed calculated form 2020 actual yield mapspam

        for s=630:1500 
            for r=1855:2780 %Africa
                if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF_2020(s,r) && ETa_ann_RF_2020(s,r)<=ETc_ann_RF(s,r)
                    yx_rf_scen3(s,r)=ya_rf(s,r)/(1-ky(cr)*(1-(ETa_ann_RF_2020(s,r)/ETc_ann_RF(s,r))));
                else
                    yx_rf_scen3(s,r)=ya_rf(s,r);
                end
                
                if yx_rf_scen3(s,r)<ya_rf(s,r)
                    yx_rf_scen3(s,r)=ya_rf(s,r);
                else
                    
                end
            end
        end
        
        yx_rf_scen3(isnan(yx_rf_scen3))=0;

        yx_ir_scen3=zeros(2160,4320); %Doorenbos yield rainfed calculated form 2020 actual yield mapspam
       
        for s=630:1500 
            for r=1855:2780
                if (0.5*ETc_ann_IR(s,r))<=ETa_ann_IR_2020(s,r) && ETa_ann_IR_2020(s,r)<=ETc_ann_IR(s,r)
                    yx_ir_scen3(s,r)=ya_ir(s,r)/(1-ky(cr)*(1-(ETa_ann_IR_2020(s,r)/ETc_ann_IR(s,r))));
                else
                    yx_ir_scen3(s,r)=ya_ir(s,r);
                end
                
                if yx_ir_scen3(s,r)<ya_ir(s,r)
                    yx_ir_scen3(s,r)=ya_ir(s,r);
                else
                end
            end
        end
        
        yx_ir_scen3(isnan(yx_ir_scen3))=0;

        yx_avg_scen3=(yx_rf_scen3.*area_rf + yx_ir_scen3.*area_ir)./(area_tot); %starting yield value, obtained with Doorenbos
        yx_avg_scen3(isnan(yx_avg_scen3))=0;
        
        for s=630:1500 
            for r=1855:2780
                if yx_avg_scen3(s,r)<ya_avg(s,r)
                    yx_avg_scen3(s,r)=ya_avg(s,r);
                else
                end
            end
        end
    
    
%% SCENARIO 1: actual areas extension, no further expansion of irrigation, evaporation = ETa, just climatic effect on yields
    % Doorenbos yield
    
        ya_rf_scen1=zeros(2160,4320);

        for s=630:1500 
            for r=1855:2780 %Africa
                if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=ETc_ann_RF(s,r)
                    ya_rf_scen1(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-ETa_ann_RF(s,r)/ETc_ann_RF(s,r)));
                else
                    ya_rf_scen1(s,r)=ya_rf(s,r);
                end
            end
        end
        
        ya_rf_scen1(isnan(ya_rf_scen1))=0;

        ya_ir_scen1=zeros(2160,4320);
       
       for s=630:1500 
           for r=1855:2780
               if (0.5*ETc_ann_IR(s,r))<=ETa_ann_IR(s,r) && ETa_ann_IR(s,r)<=ETc_ann_IR(s,r)
                   ya_ir_scen1(s,r)=yx_ir_scen3(s,r)*(1-ky(cr)*(1-ETa_ann_IR(s,r)/ETc_ann_IR(s,r)));
               else
                   ya_ir_scen1(s,r)=ya_ir(s,r);
               end
           end
       end
       
       ya_ir_scen1(isnan(ya_ir_scen1))=0;
       
       ya_avg_scen1=(ya_rf_scen1.*area_rf + ya_ir_scen1.*area_ir)./(area_tot);
       ya_avg_scen1(isnan(ya_avg_scen1))=0;
       
    end

    cart_new = ['C:\Users\giord\OneDrive - Politecnico di Torino\IIASA collab\RE4AFAGRI\WaterCrop\Risultati2.0_NEST\Scenario1\',char(crop(cr)),'\',char(year(v)),''];
    mkdir(cart_new)
    cd(cart_new)

    if v==1    
        geotiffwrite(['yield_avg_ton_ha_scen1_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg,R,'TiffTags',tags);
        for s = 1:12
            geotiffwrite(['waterwith_m3_scen1_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
            
        end
        
    else
        geotiffwrite(['yield_avg_ton_ha_scen1_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg_scen1,R,'TiffTags',tags);
    
        for s = 1:12
            geotiffwrite(['waterwith_m3_scen1_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
      
        end
    end        
        
%% scenario 3 Doorenbos for potatoes, sugarcane, wheat
    if v>1
             
            ya_rf_scen3_pota=zeros(2160,4320);  %for potatoes,sugarcane,wheat, 2030
            
            for s=630:1500 
                for r=1855:2780 %Africa
                    if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<(P3*ETc_ann_RF(s,r))
                        ya_rf_scen3_pota(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-((P3*ETc_ann_RF(s,r))/ETc_ann_RF(s,r))));
                    
                    elseif (P3*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=ETc_ann_RF(s,r)
                        ya_rf_scen3_pota(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-(ETa_ann_RF(s,r)/ETc_ann_RF(s,r))));
                    
                    else
                        ya_rf_scen3_pota(s,r)=yx_rf_scen3(s,r);
                    
                    end
                    
                    if ya_rf_scen3_pota(s,r)<ya_rf_scen1(s,r)
                        ya_rf_scen3_pota(s,r)=ya_rf_scen1(s,r);
                    else
                    end
                        
                end
            end
            
            
            ya_avg_scen3_pota=(ya_rf_scen3_pota.*area_rf + yx_ir_scen3.*area_ir)./(area_tot);
            ya_avg_scen3_pota(isnan(ya_avg_scen3_pota))=0;
        
            for s=630:1500 
                for r=1855:2780
                    if ya_avg_scen3_pota(s,r)<ya_avg_scen1(s,r)
                        ya_avg_scen3_pota(s,r)=ya_avg_scen1(s,r);
                    else
                    end
                end
            end
    
%% Doorenbos yield from GAEZ
    
            ya_rf_scen3=zeros(2160,4320);
            
            Y3=[0,0.75,0.9,1]; %percentage of GAEZ attainable yield achieved by temporal interval
            
                for s=630:1500 
                    for r=1855:2780 %Africa
                        if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<(P3*ETc_ann_RF(s,r))
                            ya_rf_scen3(s,r)=Y3(v)*y_rf_GAEZ_40(s,r)*(1-(ky(cr)*(1-(P3*ETc_ann_RF(s,r)/ETc_ann_RF(s,r)))));
                        
                        elseif (P3*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=ETc_ann_RF(s,r)
                            ya_rf_scen3(s,r)=Y3(v)*y_rf_GAEZ_40(s,r)*(1-ky(cr)*(1-(ETa_ann_RF(s,r)/ETc_ann_RF(s,r))));
                        else
                            ya_rf_scen3(s,r)=Y3(v)*y_rf_GAEZ_40(s,r);
                        end
                    
                        if ya_rf_scen3(s,r)<ya_rf_scen1(s,r)
                            ya_rf_scen3(s,r)=ya_rf_scen1(s,r);
                        
                        elseif ya_rf_scen3(s,r)>y_rf_GAEZ_40(s,r)
                            ya_rf_scen3(s,r)=y_rf_GAEZ_40(s,r);
                        end
                    end
                end
            
            ya_rf_scen3(isnan(ya_rf_scen3))=0;

            ya_ir_scen3=zeros(2160,4320);
            
            for s=630:1500 
                for r=1855:2780
                    if (0.5*ETc_ann_IR(s,r))<=ETa_ann_IR(s,r) && ETa_ann_IR(s,r)<=ETc_ann_IR(s,r)
                        ya_ir_scen3(s,r)=Y3(v)*y_irr_GAEZ_40(s,r)*(1-ky(cr)*(1-ETa_ann_IR(s,r)/ETc_ann_IR(s,r)));
                    
                    else
                        ya_ir_scen3(s,r)=Y3(v)*y_irr_GAEZ_40(s,r);
                    end
                    if ya_ir_scen3(s,r)<ya_ir_scen1(s,r)
                        ya_ir_scen3(s,r)=ya_ir_scen1(s,r);
                        
                    elseif ya_ir_scen3(s,r)>y_irr_GAEZ_40(s,r)
                        ya_ir_scen3(s,r)=y_irr_GAEZ_40(s,r);
                    end                    
                end
            end
    
            ya_ir_scen3(isnan(ya_ir_scen3))=0;

            ya_avg_scen3=(ya_rf_scen3.*area_rf + ya_ir_scen3.*area_ir)./(area_tot);
            ya_avg_scen3(isnan(ya_avg_scen3))=0;
            
            for s=630:1500 
                for r=1855:2780
                    if ya_avg_scen3(s,r)<ya_avg_scen1(s,r)
                        ya_avg_scen3(s,r)=ya_avg_scen1(s,r);
                    elseif ya_avg_scen3(s,r)>y_avg_GAEZ_40(s,r)
                        ya_avg_scen3(s,r)=y_avg_GAEZ_40(s,r);
                    end
                end
            end
        
    else
            
    end

    cart_new = ['C:\Users\giord\OneDrive - Politecnico di Torino\IIASA collab\RE4AFAGRI\WaterCrop\Risultati2.0_NEST\Scenario3\',char(crop(cr)),'\',char(year(v)),''];
    mkdir(cart_new)
    cd(cart_new)

    if cr==8 || cr==12 || cr==14 %potato, sugarcane, wheat
        
        if v==1    
            geotiffwrite(['yield_avg_ton_ha_scen3_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg,R,'TiffTags',tags);
            
            for s = 1:12
                geotiffwrite(['waterwith_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
            
            end
            
        elseif v>1
            geotiffwrite(['yield_avg_closure_ton_ha_scen3_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg_scen3_pota,R,'TiffTags',tags);

            for s = 1:12
                geotiffwrite(['waterwith_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
                geotiffwrite(['watergap_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],closure_m3_scen3(:,:,s),R,'TiffTags',tags);
                
            end
    
         end
    
    else
        
        if v==1
            geotiffwrite(['yield_avg_ton_ha_scen3_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg,R,'TiffTags',tags);
    
            for s = 1:12
                geotiffwrite(['waterwith_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
            
            end
    
        elseif v==2 || v==3
            geotiffwrite(['yield_avg_closure_ton_ha_scen3_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg_scen3,R,'TiffTags',tags);

            for s = 1:12
                geotiffwrite(['waterwith_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
                geotiffwrite(['watergap_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],closure_m3_scen3(:,:,s),R,'TiffTags',tags);
            end
            
        elseif v==4
            geotiffwrite(['yield_avg_closure_ton_ha_scen3_',char(crop(cr)),'_',char(year(v)),'.tif'],y_avg_GAEZ_40,R,'TiffTags',tags);

        for s = 1:12
            geotiffwrite(['waterwith_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
            geotiffwrite(['watergap_m3_scen3_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],closure_m3_scen3(:,:,s),R,'TiffTags',tags);
        end
        end
    end

%% SCENARIO 2: irrigation expansion, ETc achieved by 2050, NO improved management

    %--------------    
    if v==2 
        if P<0.5
            P2=0.5; % ETa achieved in scenario 2 and by time period as percentage of ETc 
        else
            P2=P;
        end
    end
    
    if v==3 
        if P<0.7
            P2=0.7;
        else
            P2=P;
        end
    end
    
    if v==4 
         if P<0.85
            P2=0.85;
        else
            P2=P;
        end
    end
%-----------------

    if v>1
        %water needed for gap closure between actual evapotranspiration and crop potential evapotranspiration   
        closure_mm_scen2=zeros(2160,4320,12);
        
        for i=1:12
            for s=630:1500 
                for r=1855:2780 %Africa
                    if ETa_RF(s,r,i)<=(P2*ETc_RF(s,r,i))
                        closure_mm_scen2(s,r,i) = P2.*ETc_RF(s,r,i) - ETa_RF(s,r,i);
                    elseif (P2*ETc_RF(s,r,i))<ETa_RF(s,r,i)
                        closure_mm_scen2(s,r,i) = ETc_RF(s,r,i) - ETa_RF(s,r,i);
                    end
                end
            end
        end
    %-------------------------------
        
        closure_m3_scen2 = closure_mm_scen2.* area_rf.*10; %[m3]
        closure_mm_scen2(isinf(closure_mm_scen2))=NaN;
        closure_m3_scen2(isinf(closure_m3_scen2))=NaN;
    
        % Doorenbos yield

        yx_rf_scen2=zeros(2160,4320);

        for s=630:1500 
           for r=1855:2780 %Africa
               if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<(P2*ETc_ann_RF(s,r))
                   yx_rf_scen2(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-(P2*ETc_ann_RF(s,r)/ETc_ann_RF(s,r))));

               elseif (P2*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=ETc_ann_RF(s,r)
                   yx_rf_scen2(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-ETa_ann_RF(s,r)/ETc_ann_RF(s,r)));
%             
               else
                   yx_rf_scen2(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-(P2*ETc_ann_RF(s,r)/ETc_ann_RF(s,r))));
               
               end
               
               if yx_rf_scen2(s,r)<ya_rf_scen1(s,r)
                   yx_rf_scen2(s,r)=ya_rf_scen1(s,r);
                   
               elseif yx_rf_scen2(s,r)>yx_rf_scen3(s,r)
                        yx_rf_scen2(s,r)=yx_rf_scen3(s,r);
                
               end
           end
       end 

       yx_rf_scen2(isnan(yx_rf_scen2))=0;

        yx_ir_scen2=zeros(2160,4320);

        for s=630:1500 
            for r=1855:2780
                if (0.5*ETc_ann_IR(s,r))<=ETa_ann_IR_2020(s,r) && ETa_ann_IR_2020(s,r)<=ETc_ann_IR(s,r)
                    yx_ir_scen2(s,r)=ya_ir(s,r)/(1-ky(cr)*(1-ETa_ann_IR_2020(s,r)/ETc_ann_IR(s,r)));
                else
                    yx_ir_scen2(s,r)=ya_ir_scen1(s,r);
                end
                if yx_ir_scen2(s,r)<ya_ir_scen1(s,r)
                    yx_ir_scen2(s,r)=ya_ir_scen1(s,r);
                else
                end
            end
        end

        yx_ir_scen2(isnan(yx_ir_scen2))=0;

        yx_avg_scen2=(yx_rf_scen2.*area_rf + yx_ir_scen2.*area_ir)./(area_tot); %other crops 2030 & potato,sugarcane, wheat 2040,2050
        yx_avg_scen2(isnan(yx_avg_scen2))=0;
        
        for s=630:1500 
            for r=1855:2780
                if yx_avg_scen2(s,r)<ya_avg_scen1(s,r)
                    yx_avg_scen2(s,r)=ya_avg_scen1(s,r);
                elseif yx_avg_scen2(s,r)>yx_avg_scen3(s,r)
                    yx_avg_scen2(s,r)=yx_avg_scen3(s,r);
                end
            end
        end
        
            ya_rf_scen2_pota=zeros(2160,4320);  %potato, sugarcane, wheat 2030
            
            for s=630:1500 
                for r=1855:2780 %Africa
                    if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=(P2*ETc_ann_RF(s,r))
                        ya_rf_scen2_pota(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-P2*ETc_ann_RF(s,r)/ETc_ann_RF(s,r)));
                       
                    elseif (P2*ETc_ann_RF(s,r))<ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=ETc_ann_RF(s,r)
                        ya_rf_scen2_pota(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-ETa_ann_RF(s,r)/ETc_ann_RF(s,r)));
                    
                    else
                        ya_rf_scen2_pota(s,r)=yx_rf_scen3(s,r)*(1-ky(cr)*(1-P2*ETc_ann_RF(s,r)/ETc_ann_RF(s,r))); %_scen3_pota(s,r);
                    
                    end
                    
                    if ya_rf_scen2_pota(s,r)<ya_rf_scen1(s,r)
                        ya_rf_scen2_pota(s,r)=ya_rf_scen1(s,r);
                    elseif ya_rf_scen2_pota(s,r)>ya_rf_scen3_pota(s,r)
                        ya_rf_scen2_pota(s,r)=ya_rf_scen3_pota(s,r);
                    end
                        
                end
            end
            
            
            ya_avg_scen2_pota=(ya_rf_scen2_pota.*area_rf + yx_ir_scen2.*area_ir)./(area_tot);
            ya_avg_scen2_pota(isnan(ya_avg_scen2_pota))=0;
            
            for s=630:1500 
                for r=1855:2780
                    if ya_avg_scen2_pota(s,r)<ya_avg_scen1(s,r)
                        ya_avg_scen2_pota(s,r)=ya_avg_scen1(s,r);
                    elseif ya_avg_scen2_pota(s,r)>ya_avg_scen3_pota(s,r)
                        ya_avg_scen2_pota(s,r)=ya_avg_scen3_pota(s,r);
                    end
                end
            end
                
%% Doorenbos yield from GAEZ
    
        ya_rf_scen2=zeros(2160,4320);
        
        Y2=[0,0.6,0.7,0.8]; %percentage of GAEZ attainable yield achieved by temporal interval
            
            for s=630:1500 
                for r=1855:2780 %Africa
                    if (0.5*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<(P2*ETc_ann_RF(s,r))
                        ya_rf_scen2(s,r)=Y2(v)*y_rf_GAEZ_40(s,r)*(1-ky(cr)*(1-(P2*ETc_ann_RF(s,r)/ETc_ann_RF(s,r))));
                        
                    elseif (P2*ETc_ann_RF(s,r))<=ETa_ann_RF(s,r) && ETa_ann_RF(s,r)<=ETc_ann_RF(s,r)
                        ya_rf_scen2(s,r)=Y2(v)*y_rf_GAEZ_40(s,r)*(1-ky(cr)*(1-ETa_ann_RF(s,r)/ETc_ann_RF(s,r))); 
                     
                    else
                        ya_rf_scen2(s,r)=Y2(v)*y_rf_GAEZ_40(s,r)*(1-ky(cr)*(1-(P2*ETc_ann_RF(s,r)/ETc_ann_RF(s,r))));
                    end
                    
                    if ya_rf_scen2(s,r)<ya_rf_scen1(s,r)
                        ya_rf_scen2(s,r)=ya_rf_scen1(s,r);
                        
                    elseif ya_rf_scen2(s,r)>y_rf_GAEZ_40(s,r)
                        ya_rf_scen2(s,r)=y_rf_GAEZ_40(s,r);
                    end
                end
            end

            ya_rf_scen2(isnan(ya_rf_scen2))=0;

            ya_ir_scen2=zeros(2160,4320);
            
            for s=630:1500 
                for r=1855:2780
                    if (0.5*ETc_ann_IR(s,r))<=ETa_ann_IR(s,r) && ETa_ann_IR(s,r)<=ETc_ann_IR(s,r)
                        ya_ir_scen2(s,r)=Y2(v)*y_irr_GAEZ_40(s,r)*(1-ky(cr)*(1-ETa_ann_IR(s,r)/ETc_ann_IR(s,r)));
                    else
                        ya_ir_scen2(s,r)=Y2(v)*yx_ir_scen2(s,r);
                    end
                    if ya_ir_scen2(s,r)<ya_ir_scen1(s,r)
                        ya_ir_scen2(s,r)=ya_ir_scen1(s,r);
                        
                    elseif ya_ir_scen2(s,r)>y_irr_GAEZ_40(s,r)
                        ya_ir_scen2(s,r)=y_irr_GAEZ_40(s,r);
                    end
                end
            end
    
            ya_ir_scen2(isnan(ya_ir_scen2))=0;

            ya_avg_scen2=(ya_rf_scen2.*area_rf + ya_ir_scen2.*area_ir)./(area_tot);
            ya_avg_scen2(isnan(ya_avg_scen2))=0;
            
            for s=630:1500 
                for r=1855:2780
                    if ya_avg_scen2(s,r)<ya_avg_scen1(s,r)
                        ya_avg_scen2(s,r)=ya_avg_scen1(s,r);
                    elseif ya_avg_scen2(s,r)>y_avg_GAEZ_40(s,r)
                        ya_avg_scen2(s,r)=y_avg_GAEZ_40(s,r);
                    end
                end
            end
            
            for s=630:1500 
                for r=1855:2780
                    if ya_avg_scen2(s,r)<ya_avg(s,r)
                        ya_avg_scen2(s,r)=ya_avg(s,r);
                    
                    end
                end
            end
        
    else
    end

    cart_new = ['C:\Users\giord\OneDrive - Politecnico di Torino\IIASA collab\RE4AFAGRI\WaterCrop\Risultati2.0_NEST\Scenario2\',char(crop(cr)),'\',char(year(v)),''];
    mkdir(cart_new)
    cd(cart_new)
    if cr==8 || cr==12 || cr==14 %potato, sugarcane, wheat
        if v==1
            geotiffwrite(['yield_avg_ton_ha_scen2_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg,R,'TiffTags',tags);
            for s = 1:12
                geotiffwrite(['waterwith_m3_scen2_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
            
            end
            
         elseif v>1
            geotiffwrite(['yield_avg_closure_ton_ha_scen2_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg_scen2_pota,R,'TiffTags',tags);

            for s = 1:12
                geotiffwrite(['waterwith_m3_scen2_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
                geotiffwrite(['watergap_m3_scen2_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],closure_m3_scen2(:,:,s),R,'TiffTags',tags);
                
            end
        end
    else
        
        if v==1
            geotiffwrite(['yield_avg_ton_ha_scen2_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg,R,'TiffTags',tags);
            for s = 1:12
                geotiffwrite(['waterwith_m3_scen2_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
            
            end
              
        elseif v>1
            geotiffwrite(['yield_avg_closure_ton_ha_scen2_',char(crop(cr)),'_',char(year(v)),'.tif'],ya_avg_scen2,R,'TiffTags',tags);
    
            for s = 1:12
                geotiffwrite(['waterwith_m3_scen2_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],ET_blu_m3(:,:,s),R,'TiffTags',tags);
                geotiffwrite(['watergap_m3_scen2_',char(crop(cr)),'_',char(year(v)),'_',char(month(s)),'.tif'],closure_m3_scen2(:,:,s),R,'TiffTags',tags);
            end
        
        end
    end
    end
end