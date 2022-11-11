# Examine factors associated with birth count variation among US
# counties using Principal Components Regression and Poisson GLM/GEE.

import pandas as pd
import numpy as np
from prep import births, demog, pop, na, age_groups, rucc
import statsmodels.api as sm
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

# Create a dataframe for modeling.  Merge the birth data with
# population and RUCC data.
da = pd.merge(births, pop, on="FIPS", how="left")
da = pd.merge(da, rucc, on="FIPS", how="left")
da["logPop"] = np.log(da["Population"])

pdf = PdfPages("pcr_py.pdf")

# Calculate the mean and variance within each county to
# assess the mean/variance relationship.
mv = births.groupby("FIPS")["Births"].agg([np.mean, np.var])
lmv = np.log(mv)

mr = sm.OLS.from_formula("var ~ mean", lmv).fit()
print(mr.summary())

# Plot the log variance against the log mean.  If variance = phi*mean,
# then log(variance) = log(phi) + log(mean), i.e. the slope is 1 and
# the intercept is log(phi).
plt.clf()
plt.grid(True)
plt.plot(lmv["mean"], lmv["var"], "o", alpha=0.2, rasterized=True)
plt.xlabel("Log mean", size=16)
plt.ylabel("Log variance", size=16)
pdf.savefig()

# GLM, not appropriate since we have repeated measures on counties
fml = "Births ~ logPop + RUCC_2013"
m0 = sm.GLM.from_formula(fml, family=sm.families.Poisson(), data=da)
r0 = m0.fit(scale="X2")

# GEE accounts for the correlated data
m1 = sm.GEE.from_formula(fml, groups="FIPS", family=sm.families.Poisson(), data=da)
r1 = m1.fit(scale="X2")

# Use log population as an offset instead of a covariate
m2 = sm.GEE.from_formula("Births ~ RUCC_2013", groups="FIPS", offset="logPop",
                         family=sm.families.Poisson(), data=da)
r2 = m2.fit(scale="X2")

# Use Gamma family to better match the mean/variance relationship.
m3 = sm.GEE.from_formula("Births ~ RUCC_2013", groups="FIPS", offset="logPop",
                         family=sm.families.Gamma(link=sm.families.links.log()), data=da)
r3 = m3.fit(scale="X2")

# Demographic data, replace missing values with 0 and transform
# with square root to stabilize the variance.
demog = demog.fillna(0)
demog = np.sqrt(demog)

# Get factors (principal components) from the demographic data
demog -= demog.mean(0)
u, s, vt = np.linalg.svd(demog)
v = vt.T

# Convert the coefficients back to the original coordinates
def convert_coef(c, npc):
    return np.dot(v[:, 0:npc], c/s[0:npc])

# The proportion of explained variance.
pve = s**2
pve /= sum(pve)

# Put the demographic factors into a dataframe
demog_f = pd.DataFrame({"FIPS": demog.index})
for k in range(100):
    demog_f["pc%02d" % k] = u[:, k]

# Merge demographic information into the births data
da = pd.merge(da, demog_f, on="FIPS", how="left")

# Include this number of factors in all subsequent models
npc = 10

# GLM, not appropriate since we have repeated measures on counties
fml = "Births ~ logPop + RUCC_2013 + " + " + ".join(["pc%02d" % j for j in range(npc)])
m4 = sm.GLM.from_formula(fml, family=sm.families.Poisson(), data=da)
r4 = m4.fit(scale="X2")

# GEE accounts for the correlated data
m5 = sm.GEE.from_formula(fml, groups="FIPS", family=sm.families.Poisson(), data=da)
r5 = m5.fit(scale="X2")

# Use log population as an offset instead of a covarate
fml = "Births ~ " + " + ".join(["pc%02d" % j for j in range(npc)])
m6 = sm.GEE.from_formula(fml, groups="FIPS", offset="logPop", family=sm.families.Poisson(), data=da)
r6 = m6.fit(scale="X2")

# Restructure the coefficients so that the age bands are
# in the columns.
def restructure(c):
    ii = pd.MultiIndex.from_tuples(na)
    c = pd.Series(c, index=ii)
    c = c.unstack()
    return c

# This function fits a Poisson GLM to the data using 'npc' principal components
# as explanatory variables.
def fitmodel(npc):
    # A GEE using log population as an offset
    fml = "Births ~ " + " + ".join(["pc%02d" % j for j in range(npc)])
    m = sm.GEE.from_formula(fml, groups="FIPS", family=sm.families.Poisson(), offset=da["logPop"], data=da)
    r = m.fit(scale="X2")

    # Convert the coefficients back to the original coordinates
    c = convert_coef(r.params[1:], npc)

    # Restructure the coefficients so that the age bands are
    # in the columns.
    c = restructure(c)

    return c, m, r

# Plot styling information
colors = {"A": "purple", "B": "orange", "N": "lime", "W": "red"}
lt = {"F": "-", "M": ":"}
sym = {"H": "s", "N": "o"}
ages = range(0, 19)

# Fit models with these numbers of PCs.
pcs = [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

models = []
for npc in pcs:

    c, m, r = fitmodel(npc)
    models.append((m, r))

    plt.clf()
    plt.figure(figsize=(9, 7))
    ax = plt.axes([0.14, 0.18, 0.7, 0.75])
    ax.grid(True)
    for i in range(c.shape[0]):
        a = c.index[i]
        la = "/".join(a)
        ax.plot(ages, c.iloc[i, :], lt[a[2]] + sym[a[1]], color=colors[a[0]],
                label=la)

    # Setup the horizontal axis labels
    ax.set_xticks(ages)
    ax.set_xticklabels(age_groups)
    for x in plt.gca().get_xticklabels():
        x.set_rotation(-90)

    ha, lb = plt.gca().get_legend_handles_labels()
    leg = plt.figlegend(ha, lb, "center right")
    leg.draw_frame(False)

    plt.xlabel("Age group", size=17)
    plt.ylabel("Coefficient", size=17)
    plt.title("%d factors" % npc)
    pdf.savefig()

pdf.close()

# Use score tests to get a sense of the number of PC factors
# to include; also consider the PVEs calculated above.
for k in range(10):
    st = models[k+1][0].compare_score_test(models[k][1])
    print("%d versus %d: p=%f" % (pcs[k+1], pcs[k], st["p-value"]))
