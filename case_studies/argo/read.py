import pandas as pd
import numpy as np
import os

dpath = "/home/kshedden/data/Teaching/argo/python"

lat = np.loadtxt(os.path.join(dpath, "lat.csv.gz"))
lon = np.loadtxt(os.path.join(dpath, "lon.csv.gz"))

date = np.loadtxt(os.path.join(dpath, "date.csv.gz"), dtype="str")
date = pd.to_datetime(date)
day = date - date.min()
day = np.asarray([x.days for x in day])

temp = np.loadtxt(os.path.join(dpath, "temp.csv.gz"))
pressure = np.loadtxt(os.path.join(dpath, "pressure.csv.gz"))
psal = np.loadtxt(os.path.join(dpath, "psal.csv.gz"))
