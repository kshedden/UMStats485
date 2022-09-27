import numpy as np
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt
from statsmodels.nonparametric.smoothers_lowess import lowess
from read import *

# https://arxiv.org/pdf/1609.01811.pdf

# Equation 22 in Mak et al.
def update_support(X, Y):
    N, p = Y.shape
    n, _ = X.shape
    XX = np.zeros((n, p))

    for i in range(n):
        Dx = X[i, :] - X
        DxN = np.linalg.norm(Dx, axis=1)
        DxN[i] = np.inf
        Dy = X[i, :] - Y
        DyN = np.linalg.norm(Dy, axis=1)
        q = (1/DyN).sum()
        XX[i, :] = np.dot(1/DxN, Dx) * (N / n)
        XX[i, :] += np.dot(1/DyN, Y)
        XX[i, :] /= q

    return XX

# Calculate N support points for the data in Y.  The points
# are stored in the rows of Y.
def support(Y, N, maxiter=1000):

    n, p = Y.shape
    X = np.random.normal(size=(N, p))

    for i in range(maxiter):
        X1 = update_support(X, Y)
        ee = np.linalg.norm(X1 - X)
        X = X1
        if ee < 1e-8:
            break

    return X

pdf = PdfPages("support_py.pdf")
for npt in 5, 10, 20:
    print("npt=", npt)
    X = support(temp.T, npt, maxiter=100)
    plt.clf()
    plt.grid(True)
    plt.title("%d support points" % npt)
    for i in range(npt):
        plt.plot(pressure, X[i, :], "-", color="grey")
    plt.xlabel("Pressure", size=15)
    plt.ylabel("Temperature", size=15)
    pdf.savefig()

pdf.close()
