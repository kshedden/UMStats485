import numpy as np
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
from statsmodels.nonparametric.smoothers_lowess import lowess
import pandas as pd
from read import *

pdf = PdfPages("depth_py.pdf")

ii = np.random.choice(np.arange(temp.shape[1]), 5000, replace=False)
tempx = temp[:, ii]
latx = lat[ii]
lonx = lon[ii]
dayx = day[ii]

# Calculate the spatial depth of column i of x relative
# to the other columns of x.
def sdepth(i, x):
    p, n = x.shape
    z = x - x[:, i][:, None]
    zn = np.sqrt((z**2).sum(0))
    zn[i] = np.inf
    z /= zn
    u = z.mean(1)
    return 1 - np.sqrt(np.sum(u**2))

# Calculate the spatial depth of every column of x relative
# to the other columns.
def sdepths(x, progress=False):
    p, n = x.shape
    d = np.zeros(n)
    for i in range(n):
        if progress and (i % 200 == 0):
            print(i, end="", flush=True)
            print(".", end="", flush=True)
        d[i] = sdepth(i, x)
    if progress:
        print("done", flush=True)
    return d

dp = sdepths(tempx, progress=True)

# Plot a small random selection of profiles from each depth decile.
q = 10
dq = pd.qcut(dp, q)
for (i,iv) in enumerate(dq.categories):
    ii = np.flatnonzero(dq == iv)
    jj = np.random.choice(ii, 10)

    plt.clf()
    plt.grid(True)
    plt.title("Depth quantile %d" % (i + 1))
    for j in jj:
        plt.plot(pressure, tempx[:, j], "-", color="grey")
    pdf.savefig()

# Plot the estimated conditional mean depth relative to each explanatory variable.
# The bands in these plots are +/- 2 times the mean absolute deviation from the
# conditional mean.
dpx = pd.DataFrame({"depth": dp, "lat": latx, "lon": lonx, "day": dayx})
f = 2
vn = {"lat": "Latitude", "lon": "Longitude", "day": "Day"}
for v in ["lat", "lon", "day"]:
    xx = np.linspace(dpx[v].min(), dpx[v].max(), 100)
    m = lowess(dpx["depth"], dpx[v])
    aresid = np.abs(m[:, 1] - dpx["depth"])
    r = lowess(aresid, dpx[v])
    dh = interp1d(m[:, 0], m[:, 1])(xx)
    dq = interp1d(r[:, 0], r[:, 1])(xx)
    plt.clf()
    plt.grid(True)
    plt.plot(xx, dh, "-")
    plt.fill_between(xx, dh-f*dq, dh+f*dq, color="grey", alpha=0.5)
    plt.xlabel(vn[v], size=15)
    plt.ylabel("Depth", size=15)
    pdf.savefig()

pdf.close()
