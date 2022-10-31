# Characterizing distributions

Probability distributions are the central object of probability theory and statistics.
Probability theory provides us with several ways to represent a probability distribution,
such as the [probability density function](https://en.wikipedia.org/wiki/Probability_density_function) (pdf),
[cumulative distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function)
(cdf), and [moment generating function](https://en.wikipedia.org/wiki/Moment-generating_function) (mgf).
It also provides us with a means to
summarize probability distributions using characteristics such as the mean and
variance.  Statistics provides us with estimators of these quantities, such
as the [empirical cdf](https://en.wikipedia.org/wiki/Empirical_distribution_function),
the [histogram](https://en.wikipedia.org/wiki/Histogram) (an estimator of the pdf), and the sample mean.

The two most common characteristics used to summarize univariate distributions of
a quantitative value (i.e. probability distributions on the real line) are [moments](https://en.wikipedia.org/wiki/Moment_(mathematics))
and [quantiles](https://en.wikipedia.org/wiki/Quantile).  Both of these approaches can provide us with measures of
*location* (also known as *centrality* or *central tendency*), such as the mean
or median, and measures of [dispersion](https://en.wikipedia.org/wiki/Statistical_dispersion) (also known as *scale*), such as the
[standard deviation](https://en.wikipedia.org/wiki/Standard_deviation), [inter-quartile range](https://en.wikipedia.org/wiki/Interquartile_range) (IQR),
or [MAD](https://en.wikipedia.org/wiki/Median_absolute_deviation) (median absolute deviation).  [Skew](https://en.wikipedia.org/wiki/Skewness)
and [kurtosis](https://en.wikipedia.org/wiki/Kurtosis) are additional properties of probability distributions on the real
line that are sometimes of interest.

Below we summarize some less familiar characteristics of probability distributions,
and ways to estimate these characteristics from data.

## Heavy-tailed distributions and tail parameter estimation

The tail parameter
of a random variable $X$ describes how rapidly the tail probability $P(X>x)$
(the complementary CDF) converges to zero as $x$ grows.  In a [heavy tailed distribution](https://en.wikipedia.org/wiki/Heavy-tailed_distribution),
these probabilities
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

If a distribution is not heavy-tailed, then it may have a [power law](https://en.wikipedia.org/wiki/Power_law) tail, meaning
that $P(X>x) ~ x^{-\alpha}$.  The value of $\alpha$ is called the *tail index*.  To
estimate the tail index based on a sample of data $\\{X_i\\}$,
consider the [order statistics](https://en.wikipedia.org/wiki/Order_statistic) $X_{(1)}\le X_{(2)} \le \cdots \le X_{(n)}$.
The "Hill slope estimate" of $\alpha$ is

$$
k^{-1}\sum_{i=0}^{k-1} \log(X_{(n-i)}) - \log(X_{(n-k)}),
$$

where $k$ is a chosen tuning parameter.  We won't be able to justify this entirely, but
note that this is the average in log space of the differences between the upper $k$
order statistics, and the $n-k^{\rm th}$ order statistic.
