library(dplyr)
library(ggplot2)

source("read.R")

# The code below takes awhile to run so subsample columns.
m = 10000
ii = sample(1:dim(temp)[2], m, replace=F)
tempx = temp[,ii]
psalx = psal[,ii]
latx = lat[ii]
lonx = lon[ii]
dayx = day[ii]

# Calculate the spatial depth of column i of x relative
# to the other columns of x.
sdepth = function(i, x) {
    p = dim(x)[1]
    n = dim(x)[2]
    z = x - x[,i]
    zn = sqrt(colSums(z^2))
    zn[i] = Inf
    z = z / outer(array(1, p), zn)
    u = apply(z, 1, mean)
    return(1 - sqrt(sum(u^2)))
}

# Calculate the L2 depth of column i of x relative
# to the other columns of x.
l2depth = function(i, x) {
    p = dim(x)[1]
    n = dim(x)[2]
    z = x - x[,i]
    zn = sqrt(colSums(z^2))
    return(1e6 / (1 + mean(zn)))
}

# Calculate the depth of every column of x relative
# to the other columns, using the given depth function.
depths = function(x, dfun, progress=F) {
    n = dim(x)[2]
    d = array(0, n)
    for (i in 1:n) {
        if (progress && (i %% 200 == 0)) {
            cat(i)
            cat(".")
        }
        d[i] = dfun(i, x)
    }
    if (progress) {
        cat("\n")
    }
    return(d)
}

pdf("depth_r.pdf")

plot_mean = function(x, pressure, ylab) {
    y = apply(x, 1, mean)
    da = data.frame(pressure=pressure, y=y)
    plt = ggplot(aes(x=pressure, y=y), data=da) + geom_line()
    plt = plt + ylab(ylab) + xlab("Pressure")
    print(plt)
}

# Plot the mean curves for temperature and salinity.
plot_mean(temp, pressure, "Mean temperature")
plot_mean(psal, pressure, "Mean salinity")

# Partition the depths into q equal-sized bins.  Within each
# bin plot the response variable (temperature or salinity)
# against pressure for 10 randomly selected profiles.
depth_cut = function(x, q, pressure, ylab) {
    dp = depths(x, l2depth, progress=T)
    dq = ntile(dp, q)

    for (i in seq(1, q, 2)) {

        da = data.frame()
        for (k in c(i, i+1)) {
            ii = which(dq == k)
            jj = sample(ii, 10)
            for (j in jj) {
                dd = data.frame(pressure=pressure, y=x[,j], j=j, k=k)
                da = rbind(da, dd)
            }
        }
        da$j = as.factor(da$j)
        da$k = as.factor(da$k)

        plt = ggplot(aes(x=pressure, y=y, color=k, group=j), data=da) + geom_line()
        plt = plt + ggtitle(sprintf("Depth band %d-%d", i, i+1))
        plt = plt + ylab(ylab) + xlab("Pressure")
        print(plt)
    }
    return(dp)
}

# Plot a small random selection of profiles from each depth interval.
q = 20
dp_temp = depth_cut(tempx, q, pressure, "Temperature")
dp_psal = depth_cut(psalx, q, pressure, "Salinity")

# Plot the estimated conditional mean depth relative to each explanatory variable.
# The bands in these plots are +/- 2 times the mean absolute deviation from the
# conditional mean.
depth_correlates = function(dp, ttl) {
    dpx = data.frame(depth=dp, lat=latx, lon=lonx, day=dayx)
    for (v in c("lat", "lon", "day")) {
        xx = seq(min(dpx[[v]]), max(dpx[[v]]), length.out=100)
        m = lowess(dpx[[v]], dpx$depth)
        aresid = abs(m$y - dpx$depth)
        r = lowess(dpx[[v]], aresid)
        dh = approxfun(m$x, m$y)(xx)
        dq = approxfun(r$x, r$y)(xx)
        da = data.frame(x=xx, depth=dh, r=dq)
        f = 2
        da$ymin = dh - f*dq
        da$ymax = dh + f*dq
        plt = ggplot(aes(x=x, y=depth), data=da)
        plt = plt + geom_ribbon(aes(x=x, ymin=ymin, ymax=ymax, y=depth), fill="grey70", data=da) + geom_line()
        plt = plt + labs(x=v, y="Depth") + ggtitle(ttl)
        print(plt)
    }
}

depth_correlates(dp_temp, "Temperature")
depth_correlates(dp_psal, "Salinity")

dev.off()
