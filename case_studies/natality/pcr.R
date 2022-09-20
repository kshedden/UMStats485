# Examine factors associated with birth count variation among US
# counties using Principal Components Regression and Poisson GLM/GEE.

library(geepack)
library(ggplot2)

source("prep.R")

# Write all plots to this file.
pdf("pcr_r.pdf")

# Calculate the mean and variance within each county to
# assess the mean/variance relationship.
mv = group_by(births, FIPS) %>% summarize(births_mean=mean(Births), births_var=var(Births))
mv = mutate(mv, log_births_mean=log(births_mean), log_births_var=log(births_var))

# Plot the variance against the mean on the log/log scale to assess the mean/variance
# relationship.
plt = ggplot(mv, aes(x=log_births_mean, y=log_births_var)) + geom_point()
print(plt)
dev.off()

# Merge the birth data with population and RUCC data
da = merge(births, pop, on="FIPS", how="left")
da = merge(da, rucc, on="FIPS", how="left")
da = mutate(da, logPop = log(da$Population))

# Basic GLM looking at births in terms of population and urbanicity.
# This model does not account for correlations between repeated
# observations on the same county.
r0 = glm(Births ~ logPop + RUCC_2013, quasipoisson(), da)

# GEE accounts for the correlated data
r1 = geeglm(Births ~ logPop + RUCC_2013, data=da, id=FIPS, family=poisson())

# GEE accounts for the correlated data
r2 = geeglm(Births ~ RUCC_2013, data=da, id=FIPS, family=poisson(), offset=logPop)
stop()
# Next we prepare to fit a Poisson model using principal components regression (PCR).
# The principal components (PC's) will be based on demographic characteristics of
# each county.

# First replace missing demographic values with 0.
demog = mutate(demog, across(where(anyNA), ~ replace_na(., 0)))

# Use a square root transformation to variance-stabilize the counts.
demog[,2:dim(demog)[2]] = sqrt(demog[,2:dim(demog)[2]])

# Get factors from the demographic data
va = colnames(demog)[2:dim(demog)[2]]
demog = mutate_at(demog, va, scale, scale=FALSE)
sv = svd(demog[,2:dim(demog)[2]])

# The proportion of variance explained by each factor.
pve = sv$d^2
pve = pve / sum(pve)

# Put the demographic factors into a dataframe
demog_f = data.frame(FIPS=demog$FIPS)
for (k in 1:100) {
    demog_f[,sprintf("pc%d", k)] = sv$u[, k]
}

# Merge the birth data with demographic data
da = merge(da, demog_f, on="FIPS", how="left")

# Include this number of factors in the next few models
npc = 20

# GLM, not appropriate since we have repeated measures on counties
fml = paste("pc", seq(npc), sep="")
fml = paste(fml, collapse=" + ")
fml = sprintf("Births ~ logPop + RUCC_2013 + %s", fml)
fml = as.formula(fml)
r2 = glm(fml, quasipoisson(), da)

# GEE accounts for the correlated data
r3 = geeglm(fml, data=da, id=FIPS, family=poisson())

# This function fits a Poisson GLM to the data using 'npc' principal components
# as explanatory variables.
fitmodel = function(npc) {

    # Construct a model formula
    fml = paste("pc", seq(npc), sep="")
    fml = paste(fml, collapse=" + ")
    fml = sprintf("Births ~ %s", fml)
    fml = as.formula(fml)

    # A GEE using log population as an offset
    r = geeglm(fml, data=da, id=FIPS, family=poisson(), offset=da$logPop)

    # Convert the coefficients back to the original coordinates
    cf = coef(r)
    cf = cf[2:length(cf)]
    cf = sv$v[,1:npc] %*% (cf / sv$d[1:npc])
    cf = data.frame(coef=cf)
    cf$Race = ""
    cf$Origin = ""
    cf$Sex = ""
    cf$Age = ""

    # Create a long-form dataframe containing the coefficients and
    # information about what each coefficient refers to.
    na = names(demog)
    na = na[2:length(na)]
    for (i in 1:length(na)) {
        x = strsplit(na[i], "_")[[1]]
        cf[i, "Race"] = x[1]
        cf[i, "Origin"] = x[2]
        cf[i, "Sex"] = x[3]
        cf[i, "Age"] = x[4]
    }
    return(cf)
}

# Fit models with these numbers of PCs.
pcs = c(5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

for (npc in pcs) {

    cf = fitmodel(npc)

    plt = ggplot(cf, aes(x=Age, y=coef, group=interaction(Race, Origin, Sex), color=Race, lty=Sex, shape=Origin))
    plt = plt + geom_line() + geom_point() + ggtitle(sprintf("%d factors", npc))
    plt = plt + ggtitle(sprintf("Cumulative PVE=%.4f", sum(pve[1:npc])))
    print(plt) # prints to the pdf
}

dev.off()
