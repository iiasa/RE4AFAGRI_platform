[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

# [RE4AFAGRI platform](https://sites.google.com/view/re4afagri/home) - Renewables for African Agriculture

<p align="center">
  <img width="357.5" height="190" src="https://github.com/iiasa/RE4AFAGRI_platform/assets/36954873/c4587eba-fb0a-41f5-9309-cc5077f22f66">
</p>

####
## Introduction and contents

The RE4AFAGRI platform is a multi-model framework to analyse deficits, requirements, and optimal solutions for integrated land-water-agriculture-energy-development nexus interlinkages in developing countries. 

A more comprehensive background on the design and principles behind the RE4AFAGRI platform is found in Falchetta, G., Adeleke, A., Awais, M., Byers, E., Copinschi, P., Duby, S., ... & Hafner, M. (2022). *A renewable energy-centred research agenda for planning and financing Nexus development objectives in rural sub-Saharan Africa*. Energy Strategy Reviews, 43, 100922. https://doi.org/10.1016/j.esr.2022.100922

The platform combines and soft-links four standalone peer-reviewed modelling tools:

- **WaterCROP**: WaterCROP is an evapotranspiration model to estimate the crop water demand by source (rainfall plus irrigation) as a function of the soil moisture available in the soil and the potential for irrigation expansion (by source, surface water or groundwater bodies) based on current yield gap. https://doi.org/10.1002/2015WR017148

- **M-LED**: M-LED is a Multi-sectoral Latent Electricity Demand geospatial data processing platform to estimate electricity demand in communities that live in energy poverty. The platform leverages big data and bottom-up energy modelling to represent the potential electricity demand with high spatio-temporal and sectoral granularity, with specific attention to the implications for water-energy-agriculture-development interlinkages.  https://doi.org/10.1088/1748-9326/ac0cab

- **OnSSET**: OnSSET (the Open Source Spatial Electrification Tool) is a GIS based optimization tool that has been developed to support electrification planning and decision making for the achievement of energy access goals in currently unserved locations. https://doi.org/10.1088/1748-9326/aa7b29

- **NEST**: NEST (The NExus Solutions Tool) is a modeling platform that integrates multi-scale energy–water–land resource optimization with distributed hydrological modeling, providing  insights into the vulnerability of water, energy and land resources to future socioeconomic and climatic change and how multi-sectoral policies, technological solutions and investments can improve the resilience and sustainability of transformation pathways while avoiding counterproductive interactions among sectors. https://doi.org/10.5194/gmd-13-1095-2020

![RE4AFAGRI diagram](https://lh3.googleusercontent.com/ND7Ld9by5HOwWia1uvTGOSSmReCPBgf1iw_DRAmuF-SfSIzI1gVno6V68P4lbNYLpog=w2400)

## Downloading the database

The database to run the platform for the pilot country of Zambia is avaiable at [the official Zenodo repository of the RE4AFAGRI platform](https://zenodo.org/record/8365630#.ZFnjK3ZBxhk)). 

Once downloaded, the database(s) (a zipped folder for each of the four models) should be extracted. The exact full path to the database (e.g. *C:/Users/[yourusername]/Documents/RE4AFAGRI_database/...* should be parsed onto the different model at the following positions:

- For WaterCROP: at *lines 3, 10, 27, 61, 69 & 72 (repeat for each of the 14 crops), 387* of the 'WaterCROP1_ETactual.mat' file
                 at *lines 12, 17, 23, 58, 72, 217, 342, 616* of the 'WaterCROP2_Irrigation_requirements.mat' file
- For M-LED: at *line 10* of the `MLED_hourly.R` file, defining the `db_folder` parameter
- For OnSSET: include the OnSSET replication data folder unzipped in `onsset\onsset_replication` (more details below)
- For NEST: The database only raw data needed in the pre-processing phase. The data needed to run the model is already included in the Github repository

## Setting up the environment

The platform has been developed and tested in a Windows 10 environment connected to the Internet.

Each models is developed in a specific programming language and has thus specific software requirements, which are listed below.

### First - Get the code and repository structure:
- Download or clone this entire repository either using, Github Desktop, `git clone` or downloading it as a .zip folder with all of the subfolders for each model included 

### For WaterCROP:
  - Have 'Matlab' (version >= R2017a) installed on your local computer
  
### For M-LED:
  - Have `R` (version >=4) installed on your local computer: https://cran.r-project.org/bin/windows/base/
  - Have a recent version of `RStudio` installed on your local computer: https://posit.co/download/rstudio-desktop/
  - Open the `MLED_hourly.r` file in RStudio
  - Run `lines 1-75`. This will automatically run the `backend.R` file, which will take care of installing all the required package dependencies
  - During this procedure (to be carried out only the first time M-LED is run), please follow the instructions prompted in the first run to install and reply accordingly to the user prompt requests.

### For OnSSET:
  - Have Python (version 3+) and the conda package manager installed on your local computer:
  - Or, if you do not have this, then download and install Anaconda for your operating system from here: https://www.anaconda.com/ (Many useful Jupyter Notebook tutorials are also available there if you are unfamiliar with Jupyter)
  - Then open "Anaconda Prompt" and navigate to where you cloned or downloaded the RE4AFAGRI repository using `cd <path to repository>` and then `cd` again and into the `onsset` folder with `cd onsset`, and then run the following commands:
  - `conda env create --name gep_onsset_env --file gep_onsset_env.yml` (This might take a while and download 100+MB of Python packages)
  - Then run the following commands:
    - `conda activate gep_onsset_env`
    - `jupyter notebook` or `jupyter lab` (if you are familiar with JupyterLab and know how to ensure your correct environment is activated)
  - This will open up the Jupyter Notebook in a browser window. 
  - Include the "onsset_replication" data from the [the official Zenodo repository of the RE4AFAGRI platform](https://zenodo.org/record/8365630#.ZFnjK3ZBxhk) Unzip the database and then take the onsset data into `onsset\onsset_replication` (the folder will exist in the code but will be empty when downloading the code from github). After completing this correctly the folder should have 3 sub-folders `clusters`, `mled`, and `onsset_input_files` and no longer be as .zip file. If done incorrectly the code in the next steps will likely fail.
  - Go to the instructions below to run the different OnSSET parts of the model.

### For NEST:
  - The requirements to run NEST are the same for running MESSAGEix, please check the [MESSAGEix documentation](https://docs.messageix.org/en/stable/install.html)
  - Python 3.7 or newer
  - GAMS with an active licence for the solver cplex
  - R only needed to run pre-processing scripts
  - once the setup is installed, also install the content of this folder as a `message-ix-models` package from source, following ths instructions in the `message-ix-models` [documentation](https://docs.messageix.org/projects/models/en/latest/install.html)
  
## Operating the platform

### For WaterCROP:
  - Open 'WaterCROP1_ETactual.mat' file in MATLAB and run the code which will output crop actual and potential evapotranspiration results in .mat files for each crop and scenario, which serve as input to the second part of the code;
  - Open 'WaterCROP2_Irrigation_requirements.mat' and run the code. It will output yield growth potential for African countries and the related water requirement into specific folders for each crop and scenario in georeferenced .tiff format;

### For M-LED:
  - Have `R` (version >=4) installed on your local computer: https://cran.r-project.org/bin/windows/base/
  - Have a recent version of `RStudio` installed on your local computer: https://posit.co/download/rstudio-desktop/
  - Open the `MLED_hourly.r` file in RStudio
  - Here, in [`line 8`](https://github.com/iiasa/RE4AFAGRI_platform/blob/8f8ee4a12caa1895375f52fa0e09d588bd874f46/mled/MLED_hourly.r#L8) set the working directory (i.e. the folder path containing the cloned Github repository folder called mled)  
   - In addition, in [`line 10`](https://github.com/iiasa/RE4AFAGRI_platform/blob/8f8ee4a12caa1895375f52fa0e09d588bd874f46/mled/MLED_hourly.r#L10) edit the `db_folder` parameter, specifying the path where the M-LED database was downloaded from Zenodo or where it should be automatically downloaded if the  [`download_data`](https://github.com/iiasa/RE4AFAGRI_platform/blob/8f8ee4a12caa1895375f52fa0e09d588bd874f46/mled/MLED_hourly.r#L14) parameter is set to `TRUE`.
  - Finally, run `lines 1-75`. This will automatically run the `backend.R` file, which will take care of installing all the required package dependencies
  - During this procedure (to be carried out only the first time M-LED is run), please reply "no" if asked "Install from sources?"
  
### For OnSSET:
- Make sure the replication data is downloaded from [the official Zenodo repository of the RE4AFAGRI platform](https://zenodo.org/record/8365630#.ZFnjK3ZBxhk) as described above. 
- In the root of the `onsset` folder first open `MLED_extraction_to_OnSSET.ipynb` and run all of the cells. This will extract the MLED demands and create OnSSET compatible input files for use in the next step. The process may take a few minutes. You should find them as .CSV files in the `onsset\mled_processed_input_files` folder with the names of the scenarios. If for any reason this step fails, then there are pre-processed input files available in the `onsset_replication\mled_processed_input_files` database download which you could use instead or if you wish to double check your results.
- Then, navigate into the `onsset/onsset` sub folder which also includes the .py Python files used by OnSSET.
- Open the `OnSSET_Scenario_Running.ipynb` Notebook and run all of the cells. This will take a few minutes and will run the different scenarios and calculate the least-cost electrification options for the entire country. It will output it's results into several folders as .CSV files both as full results files for every population cluster in the country as well as summary files (also used later by NEST). 

### For NEST:
  - After having installed the folder by source (see *Setting up the environment*) run the script `nest\message_ix_models\project\leap_re_nest\build.py`
  - around line 126, at * 4) add water structure* follow the instruction and run the command in the command prompt

## Soft-linking the models

**RELEASE NOtE:** the current release is still not including all the exchange of data for future scenarios, which will be included in the next release.

### WaterCrop to M-LED:
  - WaterCrop produces georeferenced .tiff files of irrigation water requirements and yield growth potential for all African countries. These files are contained (and can be updated) in the `./MLED_database/input_folder/watercrop` folder and corresponding subfolders for each crop. These files are then read in the `scenario_countryname.R` file of M-LED.
 
### WaterCROP to NEST:
  - NEST uses the same input as M-LED

### M-LED to OnSSET: 
  - The details of transferring the demand data from the MLED modelling into OnSSET compatible files are completed in the `MLED_extraction_to_OnSSET.ipynb` notebook in the onsset root folder

### OnSSET to NEST: 
  - Summary files of the OnSSET geospatial results are created when running the OnSSET scenarios in the `OnSSET_Scenario_Running.ipynb` inside the `onsset/onsset` Python code folder. These are used by NEST to split the demands appropriately for each region, rurality, year, technology type, and scenario


## Customising the analysis

Consult the [Wiki documentation](https://github.com/iiasa/RE4AFAGRI_platform/wiki) for a detailed characterisation of the modules and key input datasets, parameters, and scenarios definition and updating.

## Examining the results

Currently, each model has own reporting methods and formats, although a joint reporting module is currently under development. 

In particular results can be examined by:

### For WaterCROP:
  - WaterCROP outputs are found in `Results2` folder, and in each specific crop and scenario subfolder, which are automatically created after a model run.
  - WaterCROP writes output data at 5 arcmin for the whole African continent;
  - The results files can be analysed using MATLAB and can be vsualized in GIS softwares;
 
### For M-LED:
  - M-LED outputs are found in the `results` folder which is automatically created inside the `m-led` home folder after a model run.
  - For each scenario run, M-LED writes output data at four levels of aggregation, serving both model interlinkage purposes as part of the RE4AFAGRI modelling platform, interactive visualisation purposes in the RE4AFAGRI dashboards under development, and as static output summary files. Note that the output geopackages are reporting monthly demand for each timestep and each sector in kWh/month, while the summary csv files are reporting units in TWh/year:
    - OnSSET output geopackage, containing demand for all the original population cluster, the unit of analysis of M-LED
    - NEST output geopackage, aggregating the population clusters results at the NEST nodes level. In particular two files are written as NEST outputs, one total and one urban/rural stratified output for each NEST node.
    - GADM level 2 output geopackage, aggregating the population clusters results at the second level of administrative boundaries; useful for visualisation of aggregated results in the online dashboards and for informing policymakers
    - Summary CSVs and figures of results aggregated at the country level, disaggregated by sector, scenario, and year

### For OnSSET: 
  - The results files can be analysed using Python and Pandas in the "OnSSET_Scenario_Running.ipynb" notebook or with custom notebooks. 
  - Otherwise they can be visusalised in GIS software such as QGIS: https://download.qgis.org/. They can be linked back to the cluster .gpkg shape files using a join on the "id" variable to visualise the shapes in addition to the electrification optimization information. 
  - Go to the RE4AFAGRI visualisation platform (coming soon) to see the existing scenarios. 

### For NEST: work in progress

## Support

General queries: open an issue on this repository.

- For WaterCROP: contact marta.tuninetti@polito.it
- For M-LED: contact falchetta@iiasa.ac.at
- For OnSSET: contact gregoryireland@gmail.com
- For NEST: contact vinca@iiasa.ac.at

###############

Financial support from the European Commission H2020 funded project LEAP-RE (Long-Term Joint EU-AU Research and Innovation Partnership on Renewable Energy), grant number 963530 is gratefully acknowledged.
