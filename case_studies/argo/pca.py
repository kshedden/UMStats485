import numpy as np
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
import os
from scipy.interpolate import interp1d
from statsmodels.nonparametric.smoothers_lowess import lowess
from sklearn.cross_decomposition import CCA
import statsmodels.api as sm
from statsmodels.multivariate.cancorr import CanCorr
from read import *

pdf = PdfPages("pca_py.pdf")

# Convert the date to the number of days since the first date.
date = pd.to_datetime(date)
ddate = date - date.min()
day = [x.days for x in ddate]

# Create a matrix of observed variables that describe
# the location and time at which each profile was
# obtained.
n = len(lat)
Y = np.zeros((n, 3))
Y[:, 0] = lat
Y[:, 1] = lon
Y[:, 2] = day

# Get the principal components.
def get_pcs(x):
    xc = x.copy()
    xm = x.mean(1)
    for j in range(x.shape[0]):
        xc[j, :] = x[j, :] - xm[j]
    cc = np.cov(xc)
    pcw, pcv = np.linalg.eigh(cc)

    # Reorder the PC's so that the dominant factors
    # are first.
    ii = np.argsort(pcw)[::-1]
    pcw = pcw[ii]
    pcv = pcv[:, ii]

    # For interpretability flip the PC's that are
    # mostly negative.
    for j in range(pcv.shape[1]):
        if (pcv[:, j] < 0).sum() > (pcv[:, j] >= 0).sum():
            pcv[:, j] *= -1

    # Get the PC scores for temperature
    scores = np.dot(xc.T, pcv[:, 0:5])

    return xm, pcw, pcv, scores

# Plot the j^th PC score against the k^th feature.
def pcplot(j, k, mean, pcv, scores, label):

    # Plot the mean profile
    plt.clf()
    plt.grid(True)
    plt.plot(pressure, mean)
    plt.gca().set_xlabel("Pressure", size=15)
    plt.gca().set_ylabel("Mean %s" % label, size=15)
    pdf.savefig()

    # Plot the PC loadings
    fn = ["Latitude", "Longitude", "Day"]
    plt.clf()
    plt.grid(True)
    plt.plot(pressure, pcv[:, j])
    plt.gca().set_xlabel("Pressure", size=15)
    plt.gca().set_ylabel("%s PC %d loading" % (label.title(), j + 1), size=15)
    if pcv[:, j].min() > 0:
        plt.gca().set_ylim(ymin=0)
    pdf.savefig()

    plt.clf()
    plt.title(label.title())
    plt.grid(True)
    s = scores[:, j].std()
    for f in [-1, 0, 1]:
        plt.plot(pressure, mean + f*s*pcv[:, j], color={-1: "blue", 0: "black", 1: "red"}[f])
    plt.gca().set_xlabel("Pressure", size=15)
    plt.gca().set_ylabel("Mean %s +/- PC %d loading" % (label, j + 1), size=15)
    pdf.savefig()

    # Plot the conditional mean PC score against an observed variable
    xx = np.linspace(Y[:, k].min(), Y[:, k].max(), 100)
    m = lowess(scores[:, j], Y[:, k], delta=0.01*np.ptp(Y[:, k]))
    resid = scores[:, j] - m[:, 1]
    r = lowess(np.abs(resid), Y[:, k], delta=0.01*np.ptp(Y[:, k]))
    yy = interp1d(m[:, 0], m[:, 1])(xx)
    yr = interp1d(r[:, 0], r[:, 1])(xx)
    f = 2
    ymx = (yy + f*yr).max()
    ymn = (yy - f*yr).min()
    plt.clf()
    plt.grid(True)
    plt.plot(xx, yy, "-", color="red")
    plt.plot(xx, yy-f*yr, "-", color="grey")
    plt.plot(xx, yy+f*yr, "-", color="grey")
    plt.gca().set_ylim([ymn, ymx])
    plt.gca().set_xlabel(fn[k], size=15)
    plt.gca().set_ylabel("%s PC %d score" % (label.title(), j + 1), size=15)
    pdf.savefig()

tempmean, tempw, tempv, tempscores = get_pcs(temp)
psalmean, psalw, psalv, psalscores = get_pcs(psal)

for j in range(3):
    for k in range(3):
        pcplot(j, k, tempmean, tempv, tempscores, "temperature")

for j in range(3):
    for k in range(3):
        pcplot(j, k, psalmean, psalv, psalscores, "salinity")

# CCA that agrees with R.
def my_cca(X, Y):
    n = X.shape[0]
    X = X - X.mean(0)
    Y = Y - Y.mean(0)
    Sx = np.dot(X.T, X) / n
    Sy = np.dot(Y.T, Y) / n
    Sxy = np.dot(X.T, Y) / n
    Rx = np.linalg.cholesky(Sx)
    Ry = np.linalg.cholesky(Sy)
    M = np.linalg.solve(Rx, Sxy)
    M = np.linalg.solve(Ry, M.T).T
    u, s, vt = np.linalg.svd(M)
    v = vt.T
    u = np.linalg.solve(Rx.T, u)
    v = np.linalg.solve(Ry.T, v)
    return u, v, s


# Standard CCA, due to the high dimensionality the results
# make little sense.
X = temp.T
Y = psal.T
xc, yc, r = my_cca(X, Y)

# Flip the CCA components as needed for interpretability
def flip(xc, yc):
    for j in range(xc.shape[1]):
        if (xc[:, j] > 0).mean() + (yc[:, j] > 0).mean() < 1:
            xc[:, j] *= -1
            yc[:, j] *= -1
    return xc, yc

ux,sx,vtx = np.linalg.svd(X, 0)
uy,sy,vty = np.linalg.svd(Y, 0)

# Reduce the temperature and salinity data to PCs, then do CCA on
# the projected data and finally map the loadings back to the original
# coordinates (this is very similar to PCR but applied to CCA not to
# linear regression).
for q in [1, 2, 5, 10, 20, 50]:
    xc, yc, r = my_cca(ux[:, 0:q], uy[:, 0:q])
    xc1 = np.dot(vtx.T[:, 0:q], np.linalg.solve(np.diag(sx[0:q]), xc))
    yc1 = np.dot(vty.T[:, 0:q], np.linalg.solve(np.diag(sy[0:q]), yc))
    xc1, yc1 = flip(xc1, yc1)
    plt.clf()
    plt.axes([0.15, 0.1, 0.8, 0.8])
    plt.grid(True)
    plt.title("%d principal components, r=%.2f" % (q, r[0]))
    plt.plot(pressure, xc1[:, 0])
    if xc1[:, 0].min() > 0:
        plt.ylim(ymin=0)
    plt.xlabel("Pressure", size=15)
    plt.ylabel("Temperature", size=15)
    pdf.savefig()
    plt.clf()
    plt.axes([0.15, 0.1, 0.8, 0.8])
    plt.title("%d principal components, r=%.2f" % (q, r[0]))
    plt.grid(True)
    plt.plot(pressure, yc1[:, 0])
    if yc1[:, 0].min() >= 0:
        plt.ylim(ymin=0)
    plt.xlabel("Pressure", size=15)
    plt.ylabel("Salinity", size=15)
    pdf.savefig()
    print(np.corrcoef(np.dot(X, xc1[:, 0]), np.dot(Y, yc1[:, 0]))[0,1])

pdf.close()
