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

The database to run the platform for the pilot country of Zambia is avaiable at [the official Zenodo repository of the RE4AFAGRI platform](https://zenodo.org/deposit/7534846). 

Once downloaded, the database (a zipped folder) should be extracted. The exact full path to the database (e.g. *C:/Users/[yourusername]/Documents/RE4AFAGRI_database/...* should be copied onto the different model at the following positions:

- For WaterCROP:
- For M-LED: at line 10 of the MLED_hourly.R file, defining the 'db_folder' parameter
- For OnSSET:
- For NEST:

## Setting up the environment

The platform has been developed and tested in a Windows 10 environment connected to the Internet.

Each models is developed in a specific programming language and has thus specific software requirements, which are listed below.

For WaterCROP:
  - XXX

For M-LED:
  - Have R (version >=3.6) installed on your local computer: https://cran.r-project.org/bin/windows/base/
  - Have a recent version of Rstudio installed on your local computer: https://posit.co/download/rstudio-desktop/
  - Follow the instructions prompted in the first run to install all the required package dependencies

- For OnSSET:
  - Have Python (version 3+) installed on your local computer:
  - Have XXX

- For NEST:
  - XXX
  
## Operating the platform

For WaterCROP:
  - XXX

## Soft-linking the models

- WaterCrop to M-LED


- WaterCROP to NEST


- M-LED to OnSSET


- OnSSET to NEST


## Customising the analysis

Consult the [Wiki documentation](https://github.com/iiasa/RE4AFAGRI_platform/wiki) (to be released in May 2023) for a detailed characterisation of the modules and key input datasets, parameters, and scenarios definition and updating.

## Examining the results

Currently, each model has own reporting methods and formats, although a joint reporting module is currently under development. 

In particular results can be examined by:

- For WaterCROP:
- For M-LED: at line 10 of the MLED_hourly.R file, defining the 'db_folder' parameter
- For OnSSET:
- For NEST:

## Support

General queries: open an issue on this repository.

- For WaterCROP: contact marta.tuninetti@polito.it
- For M-LED: contact falchetta@iiasa.ac.at
- For OnSSET: contact gregoryireland@gmail.com
- For NEST: contact vinca@iiasa.ac.at

###############

Financial support from the European Commission H2020 funded project LEAP-RE (Long-Term Joint EU-AU Research and Innovation Partnership on Renewable Energy), grant number 963530 is gratefully acknowledged.
