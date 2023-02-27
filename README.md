[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

# [RE4AFAGRI platform](https://sites.google.com/view/re4afagri/home) - Renewables for African Agriculture

![RE4AFAGRI diagram](https://lh3.googleusercontent.com/ND7Ld9by5HOwWia1uvTGOSSmReCPBgf1iw_DRAmuF-SfSIzI1gVno6V68P4lbNYLpog=w2400)

####
## Introduction and contents

The RE4AFAGRI platform is a multi-model framework to analyse deficits, requirements, and optimal solutions for integrated land-water-agriculture-energy-development nexus interlinkages in developing countries. 

A more comprehensive background on the design and principles behind the RE4AFAGRI platform is found in Falchetta, G., Adeleke, A., Awais, M., Byers, E., Copinschi, P., Duby, S., ... & Hafner, M. (2022). *A renewable energy-centred research agenda for planning and financing Nexus development objectives in rural sub-Saharan Africa*. Energy Strategy Reviews, 43, 100922. https://doi.org/10.1016/j.esr.2022.100922

The platform combines and soft-links four standalone peer-reviewed modelling tools:

- **WaterCROP**: WaterCROP is an evapotranspiration model to estimate the crop water demand by source (rainfall plus irrigation) as a function of the soil moisture available in the soil and the potential for irrigation expansion (by source, surface water or groundwater bodies) based on current yield gap. https://doi.org/10.1002/2015WR017148

- **M-LED**: M-LED is a Multi-sectoral Latent Electricity Demand geospatial data processing platform to estimate electricity demand in communities that live in energy poverty. The platform leverages big data and bottom-up energy modelling to represent the potential electricity demand with high spatio-temporal and sectoral granularity, with specific attention to the implications for water-energy-agriculture-development interlinkages.  https://doi.org/10.1088/1748-9326/ac0cab

- **OnSSET**: OnSSET (the Open Source Spatial Electrification Tool) is a GIS based optimization tool that has been developed to support electrification planning and decision making for the achievement of energy access goals in currently unserved locations. https://doi.org/10.1088/1748-9326/aa7b29

- **NEST**: NEST (The NExus Solutions Tool) is a modeling platform that integrates multi-scale energy–water–land resource optimization with distributed hydrological modeling, providing  insights into the vulnerability of water, energy and land resources to future socioeconomic and climatic change and how multi-sectoral policies, technological solutions and investments can improve the resilience and sustainability of transformation pathways while avoiding counterproductive interactions among sectors. https://doi.org/10.5194/gmd-13-1095-2020


## Downloading the database

The database to run the platform for the pilot country of Zambia is avaiable at [the official Zenodo repository of the RE4AFAGRI platform](https://doi.org/10.5281/zenodo.7534846). 

Once downloaded, the database(s) (a zipped folder for each of the four models) should be extracted. The exact full path to the database (e.g. *C:/Users/[yourusername]/Documents/RE4AFAGRI_database/...* should be parsed onto the different model at the following positions:

- For WaterCROP:
- For M-LED: at *line 10* of the `MLED_hourly.R` file, defining the `db_folder` parameter
- For OnSSET: include the OnSSET replication data folder unzipped in `onsset\onsset_replication` (more details below)
- For NEST:

## Setting up the environment

The platform has been developed and tested in a Windows 10 environment connected to the Internet.

Each models is developed in a specific programming language and has thus specific software requirements, which are listed below.

### First - Get the code and repository structure:
- Download or clone this entire repository either using, Github Desktop, `git clone` or downloading it as a .zip folder with all of the subfolders for each model included 

### For WaterCROP:
  - XXX
  
### For M-LED:
  - Have `R` (version >=3.6) installed on your local computer: https://cran.r-project.org/bin/windows/base/
  - Have a recent version of `RStudio` installed on your local computer: https://posit.co/download/rstudio-desktop/
  - Open the `MLED_hourly.r` file in RStudio
  - Update your email adrress in `line 12`. Note that you need to enable the address to use Google Earth Engine, the procedure can be completed on https://signup.earthengine.google.com
  - Run `lines 1-75`. This will automatically run the `backend.R` file, which will take care of installing all the required package dependencies
  - During this procedure (to be carried out only the first time M-LED is run), please follow the instructions prompted in the first run to install and reply accordingly to the user prompt requests.

### For OnSSET:
  - Have Python (version 3+) and the conda package manager installed on your local computer:
  - If you do not have this, then download and install Anaconda for your operating system from here: https://www.anaconda.com/ (Many useful Jupyter Notebook tutorials are also available there if you are unfamiliar with Jupyter)
  - Then open "Anaconda Prompt" and navigate to this repository and into the `onsset` folder, and run the following commands:
  - `conda env create --name gep_onsset_env --file gep_onsset_env.yml` (This might take a while and download 100+MB of Python packages)
  - Then run the following commands:
    - `conda activate gep_onsset_env`
    - `jupyter notebook` or `jupyter lab` (if you are familiar with JupyterLab and know how to ensure your correct environment is activated)
  - This will open up the Jupyter Notebook in a browser window. 
  - Include the "onsset_replication" data from the [the official Zenodo repository of the RE4AFAGRI platform](https://doi.org/10.5281/zenodo.7534846) Unzip the database and then take the onsset data into `onsset\onsset_replication` (the folder will exist in the code but will be empty when downloading the code from github). After completing this correctly the folder should have 3 sub-folders `clusters`, `mled`, and `onsset_input_files` and no longer be as .zip file. If done incorrectly the code in the next steps will likely fail.
  - Go to the instructions below to run the different OnSSET parts of the model.

### For NEST:
  - XXX
  
## Operating the platform

### For WaterCROP:
  - XXX

### For M-LED:
  - Open the `MLED_hourly.r` file in RStudio
  - After having run run `lines 1-75` to configure the environment and the required dependencies (as discussed above), run `line 80` to start running the scenarios specified in the `MLED_hourly.r` preamble in sequence (see below for more details on scenarios definition).
  
### For OnSSET:
- Make sure the replication data is downloaded from [the official Zenodo repository of the RE4AFAGRI platform](https://doi.org/10.5281/zenodo.7534846) as described above. 
- In the root of the `onsset` folder first open `MLED_extraction_to_OnSSET.ipynb` and run all of the cells. This will extract the MLED demands and create OnSSET compatible input files for use in the next step. The process may take a few minutes. You should find them as .CSV files in the `onsset\mled_processed_input_files` folder with the names of the scenarios. If for any reason this step fails, then there are pre-processed input files available in the `onsset_replication\mled_processed_input_files` database download which you could use instead or if you wish to double check your results.
- Then, navigate into the `onsset/onsset` sub folder which also includes the .py Python files used by OnSSET.
- Open the `OnSSET_Scenario_Running.ipynb` Notebook and run all of the cells. This will take a few minutes and will run the different scenarios and calculate the least-cost electrification options for the entire country. It will output it's results into several folders as .CSV files both as full results files for every population cluster in the country as well as summary files (also used later by NEST). 

### For NEST:
  - XXX

## Soft-linking the models

### WaterCrop to M-LED:
  - WaterCrop produces netcdf files of irrigation water requirements and yield growth potential for all African countries. These files are contained (and can be updated) in the `./MLED_database/input_folder/watercrop` folder and corresponding subfolders for each crop. These files are then read in the `scenario_countryname.R` file of M-LED.
 
### WaterCROP to NEST:
  - xxx
  - 

### M-LED to OnSSET: 
  - The details of transferring the demand data from the MLED modelling into OnSSET compatible files are completed in the `MLED_extraction_to_OnSSET.ipynb` notebook in the onsset root folder

### OnSSET to NEST: 
  - Summary files of the OnSSET geospatial results are created when running the OnSSET scenarios in the `OnSSET_Scenario_Running.ipynb` inside the `onsset/onsset` Python code folder. These are used by NEST to split the demands appropriately for each region, rurality, year, technology type, and scenario


## Customising the analysis

Consult the [Wiki documentation](https://github.com/iiasa/RE4AFAGRI_platform/wiki) (to be released in May 2023) for a detailed characterisation of the modules and key input datasets, parameters, and scenarios definition and updating.

## Examining the results

Currently, each model has own reporting methods and formats, although a joint reporting module is currently under development. 

In particular results can be examined by:

### For WaterCROP:
  - 
 
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

### For NEST:

## Support

General queries: open an issue on this repository.

- For WaterCROP: contact marta.tuninetti@polito.it
- For M-LED: contact falchetta@iiasa.ac.at
- For OnSSET: contact gregoryireland@gmail.com
- For NEST: contact vinca@iiasa.ac.at

###############

Financial support from the European Commission H2020 funded project LEAP-RE (Long-Term Joint EU-AU Research and Innovation Partnership on Renewable Energy), grant number 963530 is gratefully acknowledged.
