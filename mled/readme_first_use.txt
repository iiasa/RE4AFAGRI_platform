# M-LED - Multi-sectoral Latent Electricity Demand assessment platform
# v0.2 (LEAP_RE)
# 23/01/2023

####

# Readme file for the software configuration and first run of M-LED

####

# 0) Software requirements

- Have R (version >=3.6) installed on your local computer: https://cran.r-project.org/bin/windows/base/

- Have a recent version of Rstudio installed on your local computer: https://posit.co/download/rstudio-desktop/


# 1) Configuration

The starting point for operating the platform is the MLED_hourly.r file. Here the user should necessarily customise three parameters:

- Line 8: setwd("...") : "..." should be replaced with the complete folder path containing the MLED_hourly.r file, i.e. the M-LED folder cloned from the RE4AFAGRI Github repository

- Line 10: db_folder = "" : "..." should be replaced with the complete path to (or where to download) the M-LED database

- Line 12: email<- "..." : should be replaced with an email address of the user enabled to use Google Earth Engine.

Concerning this last step, the user can request free access to Google Earth Engine via https://signup.earthengine.google.com. 

Please note that in the demostrative version of M-LED (Zambia model) contained in the repository (and in the related M-LED database), direct use of
Google Earth Engine is not required, as processed files are already included in the M-LED database. However, access to Google Earth Engine 
is required to alter analysis assumptions or run M-LED for different geographies. 

######

Further parameters worth consideration:

- Line 14: download_data <- F # flag: download the M-LED database? Type "F" if you already have done so previously. Note that this option can take long time if ran with a slow internet connection.

- Line 16: allowparallel=T # allows paralellised processing. considerably shortens run time but requires computer with large CPU cores # (e.g. >=8 cores) and RAM (e.g. >=16 GB)

Concerning the 'allowparallel' option, lines 15-16 of the "backend.R" file allows the user to select what % (or how many) cores to be utilised if the 'allowparallel' option is set to T.
Please not that using many cores requires a proportionally large amount of RAM installed on the local computer, otherwise memory errors might appear and interrupt the model runs.

######

All other parameters contained in the preamble of the 'MLED_hourly.r' file can be customised, but this is not mandatory.

########

# 2) Scenarios definition

- Lines 55-75 of the MLED_hourly.r file allows customising the scenarios to be run, both in terms of socio-economic, climate change, and policy targets to be achieved. Refer to the complete
model documentation (to be published in May 2023) for a complete description of each scenario assumption and its implications for the model results.


########

# 3) Running the model

Launching the function at line 80 of the MLED_hourly.r file (after having run lines 1-79) will result in the model being operated for the scenarios defined and selected in lines 55-75. 

Please note that at the first model run, the 'backend.R' module will take care of automatically installing the required packages and prompting the user where information is required.

If you encounter issues or doubts at this stage, open an issue at https://github.com/iiasa/RE4AFAGRI_platform/issues or contact falchetta@iiasa.ac.at.

Upon running of line 80, the log.txt file will then pop-up, allowing the user to track the running time and advancement of each scenario run. 

Once completed (depending on number of scenarios ran, size of country, and power of local computer the run time can vary considerably),
the 'All scenario runs completed' text will appear in the RStudio console. 

########

# 4) Reporting and results

The results of each scenario are contained in the results/*countrystudy* subfolder of the M-LED folder (where *countrystudy* corresponds to the name of the country for which the platform was run).
In the demostration case, *countrystudy* will correspond to Zambia.

Such result folder contains the following:

1. OnSSET output geopackage, containing demand for all the original population cluster, the unit of analysis of M-LED 
2. NEST output geopackages, aggregating the population clusters results at the NEST nodes level. In particular two files are written as NEST outputs, one total and one urban/rural stratified output for each NEST node.
3. GADM level 2 output geopackage, aggregating  the population clusters results at the second level of administrative boundaries; useful for visualisation of aggregated results in the online dashboards and for informing policymakers
4. Summary CSVs and figures (bar and line pots)  of results aggregated at the country level, disaggregated by sector, scenario, and year

The output geopackages are reporting monthly demand for each timestep and each sector in kWh/month, while the summary csv files are reporting units in TWh/year.

Please note that the main scenario characteristics are reflected in the filename of each output file. 

########

# 5) Support

- For general queries, bugs, and errors, open an issue at https://github.com/iiasa/RE4AFAGRI_platform/issues

- For other information, contact falchetta@iiasa.ac.at


###############

Financial support from the European Commission H2020 funded project LEAP-RE (Long-Term Joint EU-AU Research and Innovation Partnership on Renewable Energy), grant number 963530 is gratefully acknowledged.