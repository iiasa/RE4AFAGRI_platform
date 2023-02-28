# LEAP-RE NEST implementation of a national model

import ixmp as ix
import message_ix
import pandas as pd
from message_ix_models.util import private_data_path

from message_data.projects.leap_re_nest.utils import map_basin
from message_data.projects.leap_re_nest.script.add_timeslice import (
    xls_to_df,
    time_setup,
    duration_time
    )

from message_data.projects.leap_re_nest.script import add_MLED_demand
from message_data.projects.leap_re_nest.script import add_grid_shares_OnSSET

# 1) Generate a Country model. See documentation #

# 2) adjust nodes, years and time-steps 
# 
# 2.1 add sub-basin nodes

# load a scenario
# IIASA users
# mp = ix.Platform(name='ixmp_dev' , jvmargs=['-Xmx14G'])
# external users
mp2 = ix.Platform(name='local' , jvmargs=['-Xmx14G'])

modelName = 'MESSAGEix_ZM'
scenarioName = 'single_node' 
scen2Name = 'sub-units'

# IIASA users
# sc_ref = message_ix.Scenario(mp, modelName, scenarioName,cache=True)
# sc_ref.to_excel(private_data_path("projects","leap_re_nest","ref_scen.xlsx") )
# # external users in local database
sc_ref2 = message_ix.Scenario(mp2, modelName, "test", version='new',annotation="load from excel")

sc_ref2.read_excel(private_data_path("projects","leap_re_nest","ref_scen.xlsx"),
                    add_units=True,
                    init_items=True,
                    commit_steps=True)
# sc_ref2.commit("")
# sc_ref2.solve(solve_options={"lpmethod": "4"},model="MESSAGE")

# for all
sc = sc_ref2.clone(modelName, scen2Name,keep_solution=False)

sc.check_out()
# add basins
map_basin(sc)
# check
sc.set('node')
sc.commit("add nodes")

# 2.2 add sub-annual time steps
n_time = 12     # number of time slices <= file ID
file_id = "12"
model_family = "ZMB"
set_update = True  # if True, adds time slices and set adjustments
last_year = 2060  # either int (year) or None (removes extra years)
node_exlude = ["World"]

xls_file = "input_data_" + file_id + "_" + model_family + ".xlsx"
path_xls = private_data_path("projects","leap_re_nest",xls_file)

if sc.has_solution():
        sc.remove_solution()

nodes = [x for x in sc.set("node") if x not in ["World"] + node_exlude]

# 2.2.1) Loading Excel data (time series)
xls = pd.ExcelFile(path_xls)

# 2.2.1) Updating sets related to time
# Adding subannual time slices to the relevant sets
duration, df_time, dict_xls = xls_to_df(xls, n_time, nodes)
times = df_time["time"].tolist()

if set_update:
    time_setup(sc, df_time, last_year)
    duration_time(sc, df_time)
    if last_year:
        df = sc.par("bound_activity_up")
        assert max(set(df["year_act"])) <= last_year
    
sc.set('map_time')
sc.set_as_default()

# scen_list = mp.scenario_list(default=False)
# scen_list = scen_list[(scen_list['model']==modelName)]

# 3) Demand processing
# TODO adding the scenario dimension
# scen = ["baseline", "moderate", "increased"]
scen3Name = "MLED_demand"
sc3 = sc.clone(modelName, scen3Name,keep_solution=False)

add_MLED_demand.main(sc3)
add_grid_shares_OnSSET.main(sc3)

caseName = sc3.model + "__" + sc3.scenario + "__v" + str(sc3.version)
# Solving the model
sc3.solve(solve_options={"lpmethod": "4"},model="MESSAGE", case=caseName)
sc3.set_as_default()

# %%4) add water structure

# when using the CLI it would be something like
# with the correct scenari name
# mix-models --url=ixmp://ixmp_dev/MESSAGEix_ZM/MLED_demand water --regions=ZMB nexus --rcps=7p0 --rels=low

# %% 5) add irrigation and adjust electricity uses in the water

# ADD GDP and Pop info in the timeseries
