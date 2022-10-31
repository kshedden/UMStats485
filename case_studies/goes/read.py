import pandas as pd
import os

# Location of the csv file produced by prep.py
qpath = "/home/kshedden/data/Teaching/goes"

def get_goes(year):
    return pd.read_csv(os.path.join(qpath, "goes%4d.csv.gz" % year))
