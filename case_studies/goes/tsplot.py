import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
from read import get_goes

pdf = PdfPages("tsplot_py.pdf")

for year in [2017, 2019]:

    df = get_goes(year)
    df["Time"] = pd.to_datetime(df[["Year", "Month", "Day"]])
    df["DayofYear"] = [x.dayofyear for x in df.Time]
    dx = df.groupby("DayofYear").agg({"Flux1": [np.min, np.max], "Flux2": [np.min, np.max]})

    for vn in ["Flux1", "Flux2"]:
        plt.clf()
        plt.axes([0.12, 0.12, 0.75, 0.8])
        plt.grid(True)
        plt.plot(dx.index, np.log10(dx[(vn, "amin")]), "-", alpha=0.5)
        plt.plot(dx.index, np.log10(dx[(vn, "amax")]), "-", alpha=0.5)
        plt.axhline(-6, label="C", color="green")
        plt.axhline(-5, label="M", color="orange")
        plt.axhline(-4, label="X", color="red")
        ha, lb = plt.gca().get_legend_handles_labels()
        leg = plt.figlegend(ha, lb, "center right")
        leg.draw_frame(False)
        plt.xlabel("Day of year", size=15)
        plt.ylabel(vn, size=15)
        plt.title(year)
        pdf.savefig()

pdf.close()
