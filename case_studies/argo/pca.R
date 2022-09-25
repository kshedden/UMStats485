source("read.R")

library(ggplot2)

m = dim(temp)[1] # Number of pressure points
n = dim(temp)[2] # Number of profiles

# The mean profile
tempmean = apply(temp, 1, mean)

# Center the profiles
tempc = temp - outer(tempmean, array(1, n))

# Get the principal components
cc = cov(t(tempc))
ee = eigen(cc, symmetric=T)
eigval = ee$values
eigvec = ee$vectors

# Flip each PC loading vector if it is mostly negative.
for (j in 1:dim(eigvec)[2]) {
    if (sum(eigvec[,j] < 0) > sum(eigvec[,j] > 0)) {
        eigvec[,j] = -eigvec[,j]
    }
}

# Scores for the dominant PC's
scores = t(tempc) %*% eigvec[,1:10]

pdf("pca_r.pdf")

# Plot the mean profile
da = data.frame(pressure=pressure, tempmean=tempmean)
plt = ggplot(aes(x=pressure, y=tempmean), data=da) + geom_line()
print(plt)

for (j in 1:5) {
    # Plot the loadings
    da = data.frame(pressure=pressure, loading=eigvec[,j])
    plt = ggplot(aes(x=pressure, y=loading), data=da) + geom_line()
    plt = plt + ggtitle(sprintf("PC %d", j))
    print(plt)

    # Plot the mean profile +/- multiples of the loadings
    da = data.frame()
    s = sd(scores[,j])
    for (f in c(-2, -1, 0, 1, 2)) {
        dx = data.frame(pressure=pressure, profile=tempmean+f*s*eigvec[,j], f=f)
        da = rbind(da, dx)
    }
    da$f = as.factor(da$f)
    plt = ggplot(aes(x=pressure, y=profile, color=f, group=f), data=da) + geom_line()
    plt = plt + ggtitle(sprintf("PC %d", j))
    print(plt)
}

# Plot the j^th PC score against the k^th feature.
plot_pcscores = function(j, k) {

    xx = seq(min(Y[,k]), max(Y[,k]), length=100)
    m = lowess(Y[,k], scores[,j])
    mf = approxfun(m$x, m$y)
    f = abs(m$y - scores[,j])
    r = lowess(Y[,k], f)
    rf = approxfun(r$x, r$y)
    da = data.frame(x=xx, y=mf(xx), r=rf(xx))

    f = 2
    da$y1 = da$y - f*da$r
    da$y2 = da$y + f*da$r
    plt = ggplot(aes(x=x, y=y), data=da)
    plt = plt + labs(x=fn[k], y=sprintf("PC %d score", j))
    plt = plt + geom_ribbon(aes(x=x, ymin=y1, ymax=y2), fill="grey70")
    plt = plt + geom_line()
    print(plt)
}

fn = c("Latitude", "Longitude", "Day")
Y = cbind(lat, lon, day)

for (j in 1:3) {
    for (k in 1:3) {
        plot_pcscores(j, k)
    }
}

dev.off()
