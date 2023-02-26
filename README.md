[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity)

# [RE4AFAGRI platform](https://sites.google.com/view/re4afagri/home) - Renewables for African Agriculture

![RE4AFAGRI diagram](https://lh3.googleusercontent.com/ND7Ld9by5HOwWia1uvTGOSSmReCPBgf1iw_DRAmuF-SfSIzI1gVno6V68P4lbNYLpog=w2400)

####
## Introduction and contents

The RE4AFAGRI platform...

- WaterCROP: WaterCROP is an evapotranspiration model to estimate the crop water demand by source (rainfall plus irrigation) as a function of the soil moisture available in the soil and the potential for irrigation expansion (by source, surface water or groundwater bodies) based on current yield gap.

- M-LED: M-LED is a Multi-sectoral Latent Electricity Demand geospatial data processing platform to estimate electricity demand in communities that live in energy poverty. The platform leverages big data and bottom-up energy modelling to represent the potential electricity demand with high spatio-temporal and sectoral granularity, with specific attention to the implications for water-energy-agriculture-development interlinkages.  

- OnSSET: OnSSET (the Open Source Spatial Electrification Tool) is a GIS based optimization tool that has been developed to support electrification planning and decision making for the achievement of energy access goals in currently unserved locations. 

- NEST: NEST (The NExus Solutions Tool) is a modeling platform that integrates multi-scale energy–water–land resource optimization with distributed hydrological modeling, providing  insights into the vulnerability of water, energy and land resources to future socioeconomic and climatic change and how multi-sectoral policies, technological solutions and investments can improve the resilience and sustainability of transformation pathways while avoiding counterproductive interactions among sectors. 

A more comprehensive background on the design and principles behind the RE4AFAGRI platform is found in Falchetta, G., Adeleke, A., Awais, M., Byers, E., Copinschi, P., Duby, S., ... & Hafner, M. (2022). A renewable energy-centred research agenda for planning and financing Nexus development objectives in rural sub-Saharan Africa. Energy Strategy Reviews, 43, 100922. https://doi.org/10.1016/j.esr.2022.100922

## Downloading the database

The database to run the platform for the pilot country of Zambia is avaiable at [the official Zenodo repository of the RE4AFAGRI platform](https://doi.org/10.5281/zenodo.7534846). 

Once downloaded, the database (a zipped folder) should be extracted. The exact full path to the database (e.g. *C:/Users/[yourusername]/Documents/RE4AFAGRI_database/...* should be copied onto the different model at the following positions:

- For WaterCROP:
- For M-LED: at line 10 of the MLED_hourly.R file, defining the 'db_folder' parameter
- For OnSSET: include the OnSSET replication data folder unzipped in `onsset\onsset_replication` (more details below)
- For NEST:

## Setting up the environment

The platform has been developed and tested in a Windows 10 environment connected to the Internet.

Each models is developed in a specific programming language and has thus specific software requirements, which are listed below.

### First - Get the code and repository structure:
- Download or clone this entire repository either using, Github Desktop, git clone or downloading it as a .zip folder with all of the subfolders for each model included 

### For WaterCROP:
  - XXX

### For M-LED:
  - Have R (version >=3.6) installed on your local computer: https://cran.r-project.org/bin/windows/base/
  - Have a recent version of Rstudio installed on your local computer: https://posit.co/download/rstudio-desktop/
  - Follow the instructions prompted in the first run to install all the required package dependencies

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
  - 
### For OnSSET:
- Make sure the replication data is downloaded from [the official Zenodo repository of the RE4AFAGRI platform](https://doi.org/10.5281/zenodo.7534846) as described above. 
- In the root of the `onsset` folder first open `MLED_extraction_to_OnSSET.ipynb` and run all of the cells. This will extract the MLED demands and create OnSSET compatible input files for use in the next step. The process may take a few minutes. You should find them as .CSV files in the `onsset\mled_processed_input_files` folder with the names of the scenarios.
- Then, navigate into the `onsset/onsset` sub folder which also includes the .py Python files used by OnSSET.
- Open the `OnSSET_Scenario_Running.ipynb` Notebook and run all of the cells. This will take a few minutes and will run the different scenarios and calculate the least-cost electrification options for the entire country. It will output it's results into several folders as .CSV files both as full results files for every population cluster in the country as well as summary files (also used later by NEST). 

## Soft-linking the models

- WaterCrop to M-LED


- WaterCROP to NEST


- M-LED to OnSSET: 
  - The details of transferring the demand data from the MLED modelling into OnSSET compatible files are completed in the `MLED_extraction_to_OnSSET.ipynb` notebook in the onsset root folder

- OnSSET to NEST: 
  - Summary files of the OnSSET geospatial results are created when running the OnSSET scenarios in the `OnSSET_Scenario_Running.ipynb` inside the `onsset/onsset` Python code folder. These are used by NEST to split the demands appropriately for each region, rurality, year, technology type, and scenario


## Customising the analysis

Consult the [Wiki documentation](https://github.com/iiasa/RE4AFAGRI_platform/wiki) (to be released in May 2023) for a detailed characterisation of the modules and key input datasets, parameters, and scenarios definition and updating.

## Examining the results

Currently, each model has own reporting methods and formats, although a joint reporting module is currently under development. 

In particular results can be examined by:

- For WaterCROP:
- For M-LED: at line 10 of the MLED_hourly.R file, defining the 'db_folder' parameter
- For OnSSET: 
  - The results files can be analysed using Python and Pandas in the "OnSSET_Scenario_Running.ipynb" notebook or with custom notebooks. 
  - Otherwise they can be visusalised in GIS software such as QGIS: https://download.qgis.org/. They can be linked back to the cluster .gpkg shape files using a join on the "id" variable to visualise the shapes in addition to the electrification optimization information. 
  - Go to the RE4AFAGRI visualisation platform (coming soon) to see the existing scenarios. 
- For NEST:

## Support

General queries: open an issue on this repository.

- For WaterCROP: contact marta.tuninetti@polito.it
- For M-LED: contact falchetta@iiasa.ac.at
- For OnSSET: contact gregoryireland@gmail.com
- For NEST: contact vinca@iiasa.ac.at

###############

Financial support from the European Commission H2020 funded project LEAP-RE (Long-Term Joint EU-AU Research and Innovation Partnership on Renewable Energy), grant number 963530 is gratefully acknowledged.
