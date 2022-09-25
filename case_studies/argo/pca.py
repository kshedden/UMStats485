import numpy as np
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
import os
from scipy.interpolate import interp1d
from statsmodels.nonparametric.smoothers_lowess import lowess
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

# Get the PC's of the profiles.
tempc = temp.copy()
tempmean = temp.mean(1)
for j in range(temp.shape[0]):
    tempc[j, :] = temp[j, :] - tempmean[j]
cc = np.cov(tempc)
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
scores = np.dot(tempc.T, pcv[:, 0:5])

# Plot the j^th PC score against the k^th feature.
def pcplot(j, k):

    # Plot the mean profile
    plt.clf()
    plt.grid(True)
    plt.plot(pressure, tempmean)
    plt.gca().set_xlabel("Pressure", size=15)
    plt.gca().set_ylabel("Mean temperature", size=15)
    pdf.savefig()

    # Plot the PC loadings
    fn = ["Latitude", "Longitude", "Day"]
    plt.clf()
    plt.grid(True)
    plt.plot(pressure, pcv[:, j])
    plt.gca().set_xlabel("Pressure", size=15)
    plt.gca().set_ylabel("PC %d loading" % (j + 1), size=15)
    if pcv[:, j].min() > 0:
        plt.gca().set_ylim(ymin=0)
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
    plt.gca().set_ylabel("PC %d score" % (j + 1), size=15)
    pdf.savefig()

for j in range(3):
    for k in range(3):
        pcplot(j, k)

pdf.close()
