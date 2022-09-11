library(geepack)
library(ggplot2)

source("prep.R")

# Calcuate the mean and variance within each county to
# assess the mean/variance relationship.
mv = group_by(births, FIPS) %>% summarize(births_mean=mean(Births), births_sd=sd(Births))
mv = mutate(mv, log_births_mean=log(births_mean), log_births_sd=log(births_sd))

# Replace missing demographic values with 0.
demog = mutate(demog, across(where(anyNA), ~ replace_na(., 0)))

# Use square root to variance stabilize the counts.
demog[,2:dim(demog)[2]] = sqrt(demog[,2:dim(demog)[2]])

# Get factors from the demographic data
va = colnames(demog)[2:dim(demog)[2]]
demog = mutate_at(demog, va, scale, scale=FALSE)
sv = svd(demog[,2:dim(demog)[2]])

# The proportion of explained variance.
pve = sv$d^2
pve = pve / sum(pve)

# Put the demographic factors into a dataframe
demog_f = data.frame(FIPS=demog$FIPS)
for (k in 1:100) {
    demog_f[,sprintf("pc%d", k)] = sv$u[, k]
}

# Merge the birth data with population and RUCC data
da = merge(births, demog_f, on="FIPS", how="left")
da = merge(da, pop, on="FIPS", how="left")
da = merge(da, rucc, on="FIPS", how="left")
da = mutate(da, logPop = log(da$Population))

# Include this number of factors in all subsequent models
npc = 20

# GLM, not appropriate since we have repeated measures on counties
fml = paste("pc", seq(npc), sep="")
fml = paste(fml, collapse=" + ")
fml = sprintf("Births ~ logPop + RUCC_2013 + %s", fml)
fml = as.formula(fml)
r0 = glm(fml, quasipoisson(), da)

# GEE accounts for the correlated data
r1 = geeglm(fml, data=da, id=FIPS, family=poisson())

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

pdf("pcr_r.pdf")
for (npc in pcs) {

    cf = fitmodel(npc)

    plt = ggplot(cf, aes(x=Age, y=coef, group=interaction(Race, Origin, Sex), color=Race, lty=Sex, shape=Origin))
    plt = plt + geom_line() + geom_point() + ggtitle(sprintf("%d factors", npc))
    print(plt) # prints to the pdf
}

dev.off()
