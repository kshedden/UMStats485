"""
Examine the lifespans of notable people using the BHHT data.

The main statistical tool here is a form of local regression
known as "LOESS", which is a form of local polynomial regression.
"""

import pandas as pd
import plotille
import statsmodels.api as sm

# Load the dataset.  Use the latin-1 encoding since there is some non-UTF
# data in the file.
df = pd.read_csv("cross-verified-database.csv.gz", encoding="latin-1")

# Create a lifespan variable (years of life).
df.loc[:, "lifespan"] = df.loc[:, "death"] - df.loc[:, "birth"]

# Examine lifespans of females and males in relation to year of birth.  To avoid
# censoring, exclude people born after 1920.  Also exclude people born before 1500.
dx = df.loc[(df.birth >= 1500) & (df.birth <= 1920), ["birth", "lifespan", "gender"]]
dx = dx.dropna()

# There are a small number of people with missing or "Other" gender but it
# is too small of a sample to draw conclusions.
dx = dx.loc[dx.gender.isin(["Female", "Male"]), :]

# plotille is a package for plotting in the terminal.  Feel free to use
# Matplotlib/PyPlot or Seaborn if you want bitmapped graphs.
fig = plotille.Figure()

# Estimate the conditional mean lifespan given year of birth for
# females and males.
for (la, dd) in dx.groupby("gender"):
    print("%s %d" % (la, dd.shape[0]))
    dd = dd.sort_values(by="birth")
    ll = sm.nonparametric.lowess(dd.lifespan, dd.birth)

    # It is sufficient to plot every 1000'th point.
    fig.plot(ll[::1000, 0], ll[::1000, 1], label=la)

print(fig.show(legend=True))

# Estimate the conditional mean lifespan given year of birth for
# each occupation.
dx = df.loc[(df.birth >= 1500) & (df.birth <= 1920), ["birth", "lifespan", "level1_main_occ"]]
dx = dx.dropna()
dx = dx.loc[~dx.level1_main_occ.isin(["Missing", "Other"]), :]

fig = plotille.Figure()

for (la, dd) in dx.groupby("level1_main_occ"):
    print("%s %d" % (la, dd.shape[0]))
    dd = dd.sort_values(by="birth")
    ll = sm.nonparametric.lowess(dd.lifespan, dd.birth)
    fig.plot(ll[::1000, 0], ll[::1000, 1], label=la)

print(fig.show(legend=True))
