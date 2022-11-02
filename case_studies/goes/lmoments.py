import lmom
import pandas as pd
import numpy as np
from read import get_goes
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

pdf = PdfPages("lmoments_py.pdf")

df = get_goes(2017)

lm = []
for (k, dv) in df.groupby(["Year", "Month", "Day"]):
    v = np.sort(dv["Flux1"].values)
    row = [lmom.l1(v), lmom.l2(v), lmom.l3(v), lmom.l4(v)]
    lm.append(row)

lm = np.asarray(lm)
lm = pd.DataFrame(lm, columns=["l1", "l2", "l3", "l4"])

lm["l3s"] = lm["l3"] / lm["l2"]
lm["l4s"] = lm["l4"] / lm["l2"]

v = ["l1", "l2", "l3s", "l4s"]
na = ["L-mean", "L-dispersion", "Standardized L-skew", "Standardized L-kurtosis"]
for j in range(4):
    for k in range(j):
        plt.clf()
        plt.grid(True)
        plt.plot(lm[v[j]], lm[v[k]], "o", alpha=0.5, mfc="none")
        plt.xlabel(na[j], size=15)
        plt.ylabel(na[k], size=15)
        pdf.savefig()

pdf.close()
