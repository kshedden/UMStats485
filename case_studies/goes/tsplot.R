library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
source("read.R")

# Generate summary time series plots showing the daily minimum and
# daily maximum flux for each instrument (flux-1 and flux-2) in
# each year.  Mark the thresholds for C, M, and X flares with
# horizontal lines.

years = c(2017, 2019)

pdf("tsplot_r.pdf")

for (year in years) {
    df = get_goes(year)
    df$Time = make_datetime(df$Year, df$Month, df$Day)
    df$DayOfYear = yday(df$Time)

    for (vn in c("Flux1", "Flux2")) {
        df$lFlux = log10(df[[vn]])
        dfs = df %>% group_by(DayOfYear) %>% summarize(maxFlux = max(lFlux), minFlux=min(lFlux))
        dfs = gather(dfs, mtype, flux, minFlux:maxFlux)
        plt = ggplot(aes(x=DayOfYear, y=flux, by=mtype, color=mtype), data=dfs) + geom_line()
        plt = plt + geom_hline(yintercept=-6, color="green")
        plt = plt + geom_hline(yintercept=-5, color="orange")
        plt = plt + geom_hline(yintercept=-4, color="red")
        plt = plt + ggtitle(sprintf("%4d %s", year, vn))
        plt = plt + labs(y="Log10 X-ray flux")
        print(plt)
    }
}

dev.off()
