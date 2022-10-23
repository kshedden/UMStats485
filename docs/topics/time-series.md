# Analysis of time series

A *time series* is a sequence of observed values viewed as a single
sample from a joint probability distribution. Let $y_1, y_2,
\ldots,y_n$ denote a time series.  This is a sample of size $n=1$ from
a probability distribution on the sample space ${\cal R}^n$.

Some time series exhibit very strong *mean trends*.  For example, if
$y_t$ is the global human population in year $t$, say where $t=1000,
1001, \ldots$, then $y_t$ is strictly increasing (although we know
that within 100 years from now it will very likely begin to decline).
Many methods of time series analysis assume that no mean trend is
present, or that any mean trend present in the observed time series
has been removed.

If a time series has no mean trend, then $E[y_t]= c$ for all $t$, for
some constant $c\in {\cal R}$.  In many cases we will have $c=0$.
Such a series may still have variance and/or covariance trends,
e.g. perhaps ${\rm var}(y_t)$ is increasing in $t$, or ${\rm cov}(y_t,
y_{t+1})$ is increasing (or decreasing) in $t$.

A time series is *stationary* if for any $m>0$, the probability
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
model for that population.

Statistical analysis is *empirical* and aims to learn primarily from
the data.  To achieve this goal, most of statistics is based on some
form of "replication" in the data.  For example, if we wish to
estimate the population mean from independent and identically
distributed (IID) data, we can use the sample mean of the data.  The
replicated observations in the IID sample enable us to learn about the
population mean from the sample mean.  However time series are not
generally IID.  Fortunately, many time series exhibit a property
called *mixing* that implies that forming averages over the values of
a time series enables estimation of population parameters, despite the
lack of IID data.  Not all time series are mixing, but when a time
series is not mixing most of the methods discussed here will not give
meaningful results.

## Autocorrelation

If a time series is stationary, then the correlation between $y_t$ and
$y_{t+1}$ is a constant that does not depend on $t$.  More generally,
the correlation between $y_t$ and $y_{t+d}$ is a constant called the
*autocorrelation at lag* $d$ that we will call $\gamma_d$.  We may
also say that $\gamma_d$ as a function of $d$ is the *autocorrelation
function* of the time series.  This correlation can be estimated by
taking the Pearson correlation between $y_1, \ldots, y_{n-d}$ and
$y_{1+d}, \ldots, y_n$.

For IID data, the autocorrelation function is $(\sigma^2, 0, 0,
\ldots)$, or $\gamma_j = \sigma^2{\cal I}_{j=d}$.  Other
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
dependence*.

A more extreme case of short range dependendence is known as
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
1 & y_{t-1} & y_{t-2} & \cdots & y_{t-m}\\
1 & y_{t-2} & y_{t-3} & \cdots & y_{t-m-1}\\
&&\cdots\\
\end{array}\right).
$$
