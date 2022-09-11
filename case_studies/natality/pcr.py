import pandas as pd
import numpy as np
from prep import births, demog, pop, na, age_groups, rucc
import statsmodels.api as sm
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

pdf = PdfPages("pcr_py.pdf")

# Calcuate the mean and variance within each county to
# assess the mean/variance relationship.
mv = births.groupby("FIPS")["Births"].agg([np.mean, np.var])
lmv = np.log(mv)

# Plot the log variance against the log mean.  If variance = phi*mean,
# then log(variance) = log(phi) + log(mean), i.e. the slope is 1 and
# the intercept is log(phi).
plt.clf()
plt.grid(True)
plt.plot(lmv.iloc[:, 0], lmv.iloc[:, 1], "o", alpha=0.2, rasterized=True)
plt.xlabel("Log mean", size=16)
plt.ylabel("Log variance", size=16)
pdf.savefig()

# Demographic data, replace missing values with 0 and transform
# with square root to stabilize the variance.
demog = demog.fillna(0)
demog = np.sqrt(demog)

# Get factors (principal components) from the demographic data
demog -= demog.mean(0)
u, s, vt = np.linalg.svd(demog)
v = vt.T

# The proportion of explained variance.
pve = s**2
pve /= sum(pve)

# Put the demographic factors into a dataframe
demog_f = pd.DataFrame({"FIPS": demog.index})
for k in range(100):
    demog_f["pc%02d" % k] = u[:, k]

# Create a dataframe for modeling.  Merge the birth data with
# population and RUCC data.
da = pd.merge(births, demog_f, on="FIPS")
da = pd.merge(da, pop, on="FIPS")
da = pd.merge(da, rucc, on="FIPS")
da["logPop"] = np.log(da["Population"])

# Include this number of factors in all subsequent models
npc = 20

# GLM, not appropriate since we have repeated measures on counties
fml = "Births ~ logPop + RUCC_2013 + " + " + ".join(["pc%02d" % j for j in range(npc)])
m0 = sm.GLM.from_formula(fml, family=sm.families.Poisson(), data=da)
r0 = m0.fit(scale="X2")

# GEE accounts for the correlated data
m1 = sm.GEE.from_formula(fml, groups="FIPS", family=sm.families.Poisson(), data=da)
r1 = m1.fit(scale="X2")

# This function fits a Poisson GLM to the data using 'npc' principal components
# as explanatory variables.
def fitmodel(npc):
    # A GEE using log population as an offset
    fml = "Births ~ " + " + ".join(["pc%02d" % j for j in range(npc)])
    m = sm.GEE.from_formula(fml, groups="FIPS", family=sm.families.Poisson(), offset=da["logPop"], data=da)
    r = m.fit(scale="X2")

    # Convert the coefficients back to the original coordinates
    c = np.dot(v[:, 0:npc], r.params[1:]/s[0:npc])

    # Restructure the coefficients so that the age bands are
    # in the columns.
    ii = pd.MultiIndex.from_tuples(na)
    c = pd.Series(c, index=ii)
    c = c.unstack()
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
    ax = plt.axes([0.17, 0.18, 0.75, 0.75])
    ax.grid(True)
    for i in range(c.shape[0]):
        a = c.index[i]
        ax.plot(ages, c.iloc[i, :], lt[a[2]] + sym[a[1]], color=colors[a[0]])

    # Setup the horizontal axis labels
    ax.set_xticks(ages)
    ax.set_xticklabels(age_groups)
    for x in plt.gca().get_xticklabels():
        x.set_rotation(-90)

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
