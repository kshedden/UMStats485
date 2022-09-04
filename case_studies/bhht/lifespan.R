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

# Generate a plot of the estimated conditional mean lifespan given
# year of birth, for data stratified according to the variable in 'va'.
# We estimate the conditional mean on a grid of years spanning the range
# of the observed birth years.
cmplot = function(va) {
    bb = seq(1500, 1920, length.out=100)
    rr = dx %>% group_by(!!sym(va)) %>% group_modify(~ {
        m = lowess(.x$birth, .x$lifespan)
        f = approxfun(m)
        data.frame(birth=bb, lifespan=f(bb))
    })
    plt = ggplot() + geom_line(data=rr, aes(x=birth, y=lifespan, color=!!sym(va)))
    return(plt)
}

plt1 = cmplot("sex")
plt2 = cmplot("reg")
plt3 = cmplot("occ")

pdf("lifespan_r_lowess.pdf")
print(plt1)
print(plt2)
print(plt3)
dev.off()
