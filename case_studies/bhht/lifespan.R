library(dplyr)
library(readr)
library(ggplot2)

da = read_csv("cross-verified-database.csv.gz")

da$lifespan = da$death - da$birth

da = da[, c("birth", "lifespan", "gender", "level1_main_occ", "un_region")]

da = rename(da, "occ"="level1_main_occ")
da = rename(da, "reg"="un_region")
da = rename(da, "sex"="gender")

# There are too few people with "Other" gender to estimate
# the conditional mean lifespans.
da = filter(da, sex %in% c("Female", "Male"))

# Focus on the last 500 years.
da = filter(da, birth >= 1500)

# People born after 1920 may still be alive, which leads to censoring.
da = filter(da, birth <= 1920)

dx = da[, c("birth", "occ", "sex", "reg", "lifespan")]
dx = dx[complete.cases(dx),]

# Estimate the conditional mean of the variable 'va' given the value of
# 'birth' on a grid of 100 years spanning from 1500 to 1920.
cmest = function(va, dx) {
    bb = seq(1500, 1920, length.out=100)
    rr = dx %>% group_by(!!sym(va)) %>% group_modify(~ {
        m = lowess(.x$birth, .x$lifespan)
        f = approxfun(m)
        data.frame(birth=bb, lifespan=f(bb))
    })
    return(rr)
}

# Use bootstrapping to estimate the standard errors for the
# quantities calculated by the function 'cmest'.
cmest_boot = function(va, dx, nboot=10) {
    br = NULL
    for (i in 1:nboot) {
        dxb = dx %>% slice_sample(n=dim(dx)[1], replace=T)
        rr = cmest(va, dxb)
        if (i == 1) {
            br = array(0, c(dim(rr)[1], nboot))
        }
        br[,i] = rr$lifespan
    }
    return(apply(br, 1, sd))
}

# Generate a plot of the estimated conditional mean lifespan given
# year of birth, for data stratified according to the variable in 'va'.
# If se=T plot a pointwise confidence band around the conditional mean
# estimates.
cmplot = function(va, dx, se=F) {
    rr = cmest(va, dx)
    if (se) {
        s = cmest_boot(va, dx)
        rr$lcb = rr$lifespan - 2*s
        rr$ucb = rr$lifespan + 2*s
        plt = ggplot(data=rr, aes(x=birth, y=lifespan, group=!!sym(va), color=!!sym(va), fill=!!sym(va)))
        plt = plt + geom_line()
        plt = plt + geom_ribbon(aes(ymin=lcb, ymax=ucb), alpha=0.3, linetype=0)
    } else {
        plt = ggplot() + geom_line(data=rr, aes(x=birth, y=lifespan, color=!!sym(va)))
    }
    return(plt)
}

cmdiff = function(dx) {
    rr = cmest("sex", dx)
    s = cmest_boot("sex", dx)
    n = dim(rr)[1]

    stopifnot(rr$sex[1] == "Female")
    stopifnot(rr$sex[n/2+1] == "Male")

    # Female - male mean lifespan
    d = rr$lifespan[1:(n/2)] - rr$lifespan[(n/2+1):n]

    # Standard error of d
    s = sqrt(s[1:(n/2)]^2 + s[(n/2+1):n]^2)

    # Confidence band
    lcb = d - 2*s
    ucb = d + 2*s

    r2 = data.frame(birth=rr$birth[1:(n/2)], d=d, lcb=lcb, ucb=ucb)
    plt = ggplot(data=r2, aes(x=birth, y=d))
    plt = plt + geom_line()
    plt = plt + geom_ribbon(aes(ymin=lcb, ymax=ucb), alpha=0.3, linetype=0)

    return(plt)
}

plt1 = cmplot("sex", dx, T)
plt2 = cmplot("reg", dx)
plt3 = cmplot("occ", dx)
plt4 = cmdiff(dx)

pdf("lifespan_r_lowess.pdf")
print(plt1)
print(plt2)
print(plt3)
print(plt4)
dev.off()
