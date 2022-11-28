# Multilevel regression

Regression analysis aims to understand the conditional distribution of a scalar response $y$
in relation to explanatory variables $x \in {\cal R}^p$.  In many familiar forms of
regression, we focus on the marginal distribution $y|x$.  However it may be that
we collect data in such a way that different observed values of $y$ are correlated
with each other.  Multilevel regression is a means to understand the conditional
mean, conditional variance, and conditional covariances among the observations.

The usual manner in which correlated data arise in practice is through some
manner of collecting data as *repeated measures*.  For example, we may be
studying a characteristic of individual people, say income, and we collect
this data every year for 5 years on each person.  Since a person's
income may not change much from year to year, there is a correlation between
two income observations made on the same person.  This is called *longitudinal
data*.

Another typical setting in which correlated data arise is when we have
a *clustered sample*.  For example, suppose that we randomly sample
communities, and then within each community we randomly sample 100 people
and obtain their incomes.  Since two people in a community tend
to have similar incomes, any two observations made in the same 
community will be correlated. 

Generically, we can refer to a collection of repeated measures as a *block*.
If we have longitudinal data, then each person is a block.  If we have
a cluster sample, then each community is a block.

Let $y_{ij}$ denote the $j^{\rm th}$ repeated measure for the $i^{\rm th}$ 
block.  One way to account for the correlations in the data is to introduce
a *random effect*, with the most basic random effect being a *random intercept*.  
A random intercept is a random
variable $\theta_i$ that arises in the following model:

$$
y_{ij} = \beta^\prime x_i + \theta_i + \epsilon_{ij}.
$$

In this model, $i=1, \ldots n$ indexes blocks and $j=1, \ldots, n_i$
indexes observations within block $i$ ($n_i$ is the size of block $i$). 

The *mean structure* is parameterized through the linear predictor

$$
\beta^\prime = \beta_0 + \beta_1x_{i1} + \cdots \beta_p x_{ip}.
$$

This linear predictor is exactly the same as would be present in a
single-level (conventional) linear model.

The random intercepts $\theta_i$ are a collection of independent and
identically distributed (IID) random variables assumed to follow
a Gaussian distribution with mean zero and variance $\tau^2$. The
*unexplained variation* is represented through the random variables
$\epsilon_{ij}$, which are IID Gaussian random variables with mean 
zero and variance $\sigma^2$. 

We can now study the marginal moments of the multilevel model.
The marginal mean is

$$
E[y_{ij}] = \beta^\prime x_i,
$$

since the random effects $\theta_i$ and the unexplained "errors"
$\epsilon_{ij}$ all have mean zero.

The marginal variance is

$$
{\rm var}[y_{ij}] = {\rm var}(\theta_i) + {\rm var}(\epsilon_{ij}) = \tau^2 + \sigma^2.
$$

Note that 

$$
{\rm var}(\theta_i + \epsilon_{ij}) = {\rm var}(\theta_i) + {\rm var}(\epsilon_{ij})
$$ 

since $\theta_i$ and $\epsilon_{ij}$ are independent.

The marginal covariance between two observations in the same block is

$$
{\rm cov}[y_{ij}, y_{ij^\prime}] = {\rm cov}(\theta_i+\epsilon_{ij}, \theta_i+\epsilon_{ij^\prime}) = \tau^2.
$$

Further, the marginal correlation between two observations in the same block is $\tau^2/(\tau^2+\sigma^2)$,
which is also known as the *intra-class correlation*, or *ICC*.

Two observations in different blocks are independent so the covariance and correlation between them
is zero.

It is important to note that the random effects $\theta_i$ are neither data (which must be observed)
nor are they parameters which are unknown values to be estimated based on the data.  Instead, 
the random effects are "latent" data
that are not observed and are integrated out of the model before estimating the parameters
using a procedure such as maximum likelihood estimation. 

The parameters of the model discussed above are $\beta$, $\tau^2$, and $\sigma^2$.  All these parameters
are estimated jointly, usually via maximum likelihood estimation (MLE) or the closely-related
restricted maximum likelihood estimation (REML) which we will not define here.

It would be possible to fit a model to correlated data using OLS, ignoring the correlations.  
Let $\hat{\beta}_{\mathrm ols}$ denote this estimator, while $\hat{\beta}$ denotes the
estimated mean parameters for the mixed model.  Further, let $\hat{\sigma}^2_{\rm ols}$ denote
the MLE of $\sigma^2$ for simple linear regression (essentially the sample variance of the residuals).

It is a fact that $\hat{\beta}_{\mathrm ols} \approx \hat{\beta}$.  That is, we can still recover the
mean parameters even when ignoring the correlations present in the data.  Further, $\hat{\sigma}^2_{\mathrm ols}$
will be approximately equal to $\sigma^2 + \tau^2$, the total variance from both random effects
and unexplained variation.  Nevertheless, there are at least two important reasons that OLS is not
the best choice for analyzing such data.  First, and most important, the OLS standard errors
for $\hat{\beta}_{\mathrm ols}$ will be wrong, usually too small.  This will lead to overconfidence
about any findings.  Second, OLS will not recover $\beta$ as efficiently as possible, where
"efficiency" here means that we get the most accurate estimate possible for a given sample
size.

