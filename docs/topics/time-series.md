# Analysis of time series

A *time series* is a sequence of observed values viewed as a single
sample from a joint probability distribution. The central premise of a
time series is that the order in which the values are observed
contains information about the underlying probability distribution.
Let $y_1, y_2, \ldots,y_n$ denote a time series.  This is a sample of
size $n=1$ from a probability distribution on the sample space ${\cal
R}^n$.

Some time series exhibit strong *mean trends*.  For example, if
$y_t$ is the global human population in year $t$, say where $t=1000,
1001, \ldots$, then $y_t$ is increasing.  We don't know for sure
if this is a trend in the mean, i.e. that $E[y_t]$ is increasing,
since we can only observe the history
of humanity on Earth one time, but based on the nature of biological
growth, it is reasonable to view the increasing values of $y_t$ as
an inevitable fact that would recur in any "replication" of the
observations.  That is, it is reasonable to supose that $E[y_t]$ is increasing.
Many methods of time series analysis assume that no mean trend is
present, or that any mean trend present in the observed time series
has been removed.

If a time series has no mean trend, then $E[y_t]= c$ for all $t$, for
some constant $c\in {\cal R}$.  In many cases we will have $c=0$.
Such a series may still have variance and/or covariance trends,
e.g. perhaps ${\rm var}(y_t)$ is increasing in $t$, or ${\rm cov}(y_t,
y_{t+1})$ is increasing (or decreasing) in $t$.

A time series is *stationary* if for any $m>0$, the joint probability
distribution of $y_t, y_{t+1}, \ldots, y_{t+m}$ does not depend on
$t$. For example, the probability distribution of $(y_{100}, y_{101})$
is the same as the probability distribution of $(y_{200}, y_{201})$.
Note that one consequence of stationarity is that the distribution of
$y_t$ does not depend on $t$, and therefore in particular the variance
of $y_t$ does not depend on $t$, so there is a constant $k$ such that
${\rm var}[y_t] = k$ for all $t$.  If the series is standardized then
$k=1$.

One approach to time series analysis is based on probability models.
There are many famous parametric models for time series, especially
the so-called *ARIMA* models.  We will not review model-based
approaches to time series analysis here.  Instead we focus on
approaches to time series analysis that aim to capture certain
features of a time series without aiming to produce a comprehensive
model for its population distribution.

Statistical analysis is *empirical* and aims to learn primarily from
the data.  To achieve this goal, most statistical analysis is based on
exploiting some form of "replication" in the data.  For example, if we
wish to estimate the population mean from independent and identically
distributed (IID) data, we can use the sample mean of the data as an estimate of the population mean.  The
replicated observations in the IID sample enable us to learn about the
population mean from the sample mean.  However time series are
generally not IID.  Fortunately, many time series exhibit a property
called *mixing* that implies that forming averages over the values of
a time series enables estimation of population parameters, despite the
lack of IID data.  Not all time series are mixing, and when a time
series is not mixing most of the methods discussed here will not give
meaningful results.

## Autocorrelation

If a time series is stationary, then the correlation between $y_t$ and
$y_{t+1}$ is a constant that does not depend on $t$.  More generally,
the correlation between $y_t$ and $y_{t+d}$ is a constant called the
*autocorrelation at lag* $d$ that we will denote $\gamma_d$.  We may
also view $\gamma_d$ as a function of $d$ that is the *autocorrelation
function* of the time series.  This autocorrelation at lag $d$ can be estimated
by taking the Pearson correlation between $y_1, \ldots, y_{n-d}$ and
$y_{1+d}, \ldots, y_n$.

For IID data, the autocorrelation function is $(\sigma^2, 0, 0,
\ldots)$, or $\gamma_j = \sigma^2{\cal I}_{j=1}$.  Other
commonly-encountered forms for the autocorrelation function are an
exponential form $\gamma_j \propto \exp(-j/\lambda)$, or a power-law
form $\gamma_j = c/(1+j)^b$.

If we consider all autocorrelations at all possible lags, we can
consider whether the autocorrelations are summable, i.e. does $\sum_j
\gamma_j$ exist as a finite value?  If the autocorrelations decay
exponentially, then the autocorrelations are summable.  In the
power-law case, the autocorrelations are summable if and only if $b >
1$.

A time series with summable autocorrelations exhibits *short range
dependence* while otherwise the series exhibits *long range
dependence*.  A special case of short range dependendence is known as
*m-dependence*, where $\gamma_j = 0$ when $j>m$.

## Autoregression

One way to analyze a time series is to restructure the data into a
form that can be considered using regression analysis.  Most commonly,
this involves partitioning the data into overlapping blocks of the
form $(y_t; y_{t-1}, \ldots, y_{t-q})$.  In regression terms, $y_t$ is
the response variable, and $(y_{t-1}, \ldots, y_{t-q})$ is the
corresponding vector of covariates.

Autoregression can also be considered in terms of likelihoods, by
factoring the joint probability distribution as follows:

$$
P(y_1, \ldots, y_n) = \prod_t P(y_t | y_{t-1}, \ldots, y_1).
$$

If the time series is $m$-dependent, we can write the above as

$$
P(y_1, \ldots, y_n) = \prod_t P(y_t | y_{t-1}, \ldots, y_{t-m}).
$$

If we are analyzing the data via a likelihood-based method such as
maximum likelihood estimation (MLE), then the log-likelihood has the
form

$$
\sum_j \log P_\theta(y_t | y_{t-1}, \ldots, y_{t-m})
$$

where $\theta$ is a parameter to be estimated.

Autoregression analysis can use any method for fitting regression
models, for example linear modeling via ordinary least squares (OLS).
Suppose we choose to fit an autoregressive model of "order m", meaning
that we choose to model the conditional distribution of $y_t$ given
$y_{t-1}, y_{t-2}, \ldots$ using only the truncated history $y_{t-1},
\ldots, y_{t-m}$.  If a time series is stationary and $m$-dependent,
it makes sense to analyze it using an order $m$ autoregression.  Note
that in practice we do not know if our time series is $m$-dependent,
and if it is what is the value of $m$.  The value of $m$ is assessed
using diagnostics and model-selection techniques.  In general, if we
use a given finite value of $m$, this does not mean that the time
series must be $m$-dependent, but rather that we accept a small amount
of bias by adopting a given finite value of $m$.

A basic linear autoregresive model fit using OLS uses as its dependent
variable

$$
y_{t+1}, y_{t+2}, \ldots, y_n
$$

and the design matrix whose columns are the independent variables in
the regression is

$$
\left(
\begin{array}{rrrrr}
1 & y_t & y_{t-1} & \cdots & y_{t-m+1}\\
1 & y_{t+1} & y_{t} & \cdots & y_{t-m+2}\\
1 & y_{t+2} & y_{t+1} & \cdots & y_{t-m+3}\\
&&\cdots\\
\end{array}\right).
$$

Using this response vector and design matrix, we can apply many methods
for fitting regression models including OLS, PCR, dimension reduction
regression, kernel methods, and many forms of regularized modeling
such as the lasso and ridge regression.

## Hurst parameters

A useful way to summarize the dependence structure of a time series is
through the *Hurst parameter*.  There are various ways to introduce
the Hurst parameter and we will only consider one approach here.
Recall that if we have IID data $X_1, \ldots, X_m$, the variance of
the sample mean $\bar{X}_m = (X_1 + \cdots + X_m)/m$ is $\sigma^2/m$.
Thus, if we double the sample size, the variance of the sample mean is
reduced by a factor of two.  It turns out that this scaling
relationship between the variance of the sample mean and the sample
size continues to hold as long as the dependence is "short range" as
defined above.  However if the dependence is long range, the variance
will scale in a qualitatively different way.

For a given block-size $b$, we can calculate the sample means
for consecutive blocks of $b$ observations, $m^b_1 = {\rm Avg}(y_1,
\ldots, y_b)$, $m^b_2={\rm Avg}(y_{b+1}, \ldots, y_{2b})$ etc., and
then calculate the sample variance of these sample means:

$$
v_b = {\rm var}(m^b_1, m^b_2, \ldots).
$$

Finally, we can consider the log-space relationship between $\log(b)$
and $\log(v_b)$.  If $v_b = a\cdot b^f$ then $\log(v_b) = \log(a) +
f\log(b)$, so $f$ is the slope of $\log(v_b)$ on $\log(b)$.  For IID
and short-range dependent data, then $f=-1$ will hold.  If $f>-1$ then
the variances decrease slower than in the IID case, which is a
logical consequence of long-range dependence.  Long-range dependence
implies that the time series is not mixing and does not exhibit enough
independence for the sample means derived from different parts of the
series to average to something that reflects the population struture.

The Hurst parameter is defined to be $h = 1 + b/2$, where the slope
$b$ is defined as above.  When $b=-1$ (as in IID data), the Hurst parameter is $h=1/2$.
When $b>-1$, it follows that $h > 1/2$.

## Differencing

A simple and important technique in time series analysis is *differencing*.
If our time series is $y_1, y_2, \ldots$, then the differenced time
series is $y_2-y_1$, $y_3-y_2, \ldots$.  We can then difference these
differences, yielding second order differences $y_3-2y_2+y_1$,
$y_4-2y_3+y_2$, and so on.  Differencing is analogous to taking the
derivative of a smooth function, and has the effect of removing longer-range
trends and focusing on more local structure.  It turns out that in many
cases the differenced series have shorter-range dependence than the original
series.  At the same time differencing loses certain information about the
series.  In practice it may be helpful to difference one or two times and
consider the structure of the original series as well as a few differenced
series.

## Heavy-tailed distributions and tail parameter estimation

Tail parameters are a property of univariate distributions and do not directly
relate to time series.  However, there is an important way in which tail parameters
and time series are related, so we discuss tail parameters here.  The tail parameter
of a probability distribution $f(t)$ describes how rapidly the tail probability $P(X>x)$
goes to zero as $x$ increases.  In a *heavy tailed* distribution, these probabilities
do not shrink exponentially fast, which means that

$$
\lim_{x\rightarrow \infty} \exp(tx) \cdot P(X>x) = \infty
$$

for all $t > 0$.  To understand this definition, suppose that it does not hold,
so there is a value $t>0$ and a constant $c$ such that

$$
\lim_{x\rightarrow \infty} \exp(tx) \cdot P(X>x) = c
$$

Roughly speaking this means that $P(X>x)$ behaves like $\exp(-tx)$ for large $x$, or
if $c = 0$ it means that $P(X>x)$ is dominated by $\exp(-tx)$ for large $x$.

To quantify the tail of a probability distribution
based on a sample of data $\\{X_i\\}$, consider the *order statistics* $X_{(1)}\le X_{(2)} \le \cdots \le X_{(n)}$.
The "Hill slope estimate" is

$$
k^{-1}\sum_{i=0}^{k-1} \log(X_{(n-i)}) - \log(X_{(n-k)}),
$$

where $k$ is a chosen tuning parameter.  We won't be able to justify this entirely, but
note that this is the average in log space of the differences between the upper $k$
order statistics, and the $n-k^{\rm th}$ order statistic.  This turns out to be an
estimator of the constant $\gamma$ in the expression $1 - F(x) \sim x^{-1/\gamma}$,
where $F$ is the CDF corresponding to the pdf $f$.

If $F$ lacks heavy tails then $\gamma = 0$ but for heavy-tailed distributions we have
$\gamma > 0$ and the estimator defined above should reflect this.
