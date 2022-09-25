library(dplyr)
library(ggplot2)

source("read.R")

# The code below takes awhile to run so subsample columns.
m = 2000
ii = sample(1:dim(temp)[2], m, replace=F)
tempx = temp[,ii]
latx = lat[ii]
lonx = lon[ii]
dayx = day[ii]

# Calculate the spatial depth of column i of x relative
# to the other columns of x.
sdepth = function(i, x) {
    p = dim(x)[1]
    n = dim(x)[2]
    z = x - outer(x[,i], array(1, n))
    zn = sqrt(apply(z^2, 2, sum))
    zn[i] = Inf
    z = z / outer(array(1, p), zn)
    u = apply(z, 1, mean)
    return(1 - sqrt(sum(u^2)))
}

# Calculate the spatial depth of every column of x relative
# to the other columns.
sdepths = function(x, progress=F) {
    n = dim(x)[2]
    d = array(0, n)
    for (i in 1:n) {
        if (progress && (i %% 200 == 0)) {
            cat(i)
            cat(".")
        }
        d[i] = sdepth(i, x)
    }
    if (progress) {
        cat("\n")
    }
    return(d)
}

dp = sdepths(tempx, progress=T)

pdf("depth_r.pdf")

# Plot a small random selection of profiles from each depth decile.
q = 10
dq = ntile(dp, q)

for (i in 1:q) {
    ii = which(dq == i)
    jj = sample(ii, 10)

    da = data.frame()
    for (j in jj) {
        dd = data.frame(pressure=pressure, temp=tempx[,j], j=j)
        da = rbind(da, dd)
    }
    da$j = as.factor(da$j)

    plt = ggplot(aes(x=pressure, y=temp, color=j, group=j), data=da) + geom_line()
    plt = plt + ggtitle(sprintf("Depth decile %d", i))
    print(plt)
}

# Plot the estimated conditional mean depth relative to each explanatory variable.
# The bands in these plots are +/- 2 times the mean absolute deviation from the
# conditional mean.
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
    plt = plt + labs(x=v)
    print(plt)
}

dev.off()
