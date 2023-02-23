# utils for NEST model
import pandas as pd
from message_ix_models.util import private_data_path

def map_basin(sc):
    """Return specification for mapping basins to regions

    The basins are spatially consolidated from HydroSHEDS basins delineation
    database.This delineation is then intersected with MESSAGE regions to form new
    water sector regions for the nexus module.
    The nomenclature for basin names is <basin_id>|<MESSAGEregion> such as R1|AFR
    """


    # define an empty dictionary
    results = {}
    # read csv file for basin names and region mapping
    # reading basin_delineation
    FILE = f"basins_by_region_simpl_ZMB.csv"
    PATH = private_data_path("projects","leap_re_nest", "delineation", FILE)

    df = pd.read_csv(PATH)
    # Assigning proper nomenclature
    df["node"] = "B" + df["BCU_name"].astype(str)
    df["mode"] = "M" + df["BCU_name"].astype(str)
    df["region"] = df["REGION"].astype(str)
    results["node"] = df["node"]
    results["mode"] = df["mode"]
    # map nodes as per dimensions
    df1 = pd.DataFrame({"node_parent": df["region"], "node": df["node"]})
    df2 = pd.DataFrame({"node_parent": df["node"], "node": df["node"]})
    frame = [df1, df2]
    df_node = pd.concat(frame)
    nodes = df_node.values.tolist()

    results["map_node"] = nodes

    # context.all_nodes = df["node"]

    for set_name, config in results.items():
        
        print("Adding set",set_name)
        # print("config",config)
        # Sets  to add
        sc.add_set(set_name,config)
        
    print("sets for nodes updated")