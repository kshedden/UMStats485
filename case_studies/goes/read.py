import pandas as pd
import numpy as np
import os

# Location of the csv file produced by prep.py
qpath = "/home/kshedden/data/Teaching/goes"

def get_goes(year):
    return pd.read_csv(os.path.join(qpath, "goes%4d.csv.gz" % year))

# Create a data matrix whose rows are non-overlapping blocks
# of X-ray flux data, each block having length m.  The values
# within each block are uniformly spaced in time, with approximately
# 2-second time differences.
def make_blocks(df, m, d):

    df["Date"] = pd.to_datetime(df[["Year", "Month", "Day"]])
    df["DayofYear"] = [x.dayofyear for x in df.Date]
    df = df.loc[df.Time >= 0, :]
    df["Timex"] = df.DayofYear * 60 * 60 * 24 + df.Time
    df = df.sort_values(by="Timex")
    ti = df["Timex"].values
    fl = df["Flux1"].values

    q = len(ti) // m
    n = q * m
    ti = ti[0:n]
    fl = fl[0:n]
    g = n // m
    tix = np.reshape(ti, [g, m])
    flx = np.reshape(fl, [g, m])

    # Time difference within block
    td = tix[:, m-1] - tix[:, 0]

    # Exclude the blocks that contain skips
    ii = np.abs(td - np.median(td)) < 1
    tix = tix[ii, :]
    flx = flx[ii, :]

    if d > 0:
        for j in range(d):
            flx = np.diff(flx, axis=1)

    return tix, flx

