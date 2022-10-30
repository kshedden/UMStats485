# Characterizing distributions

Probability distributions are the central object of probability theory and statistics.
Probability theory provides us with means of representing probability distributions,
such as the probability density function (pdf), cumulative distribution function
(cdf), and moment generating function (mgf).  It also provides us with a means to
summarize probability distributions using characteristics such as the mean and
variance.  Statistics provides us with estimators of these quantities, such
as the empirical cdf, the histogram (an estimator of the pdf), and the sample mean.

The two most common characteristics used to summarize univariate distributions of
a quantitative value (i.e. probability distributions on the real line) are *moments*
and *quantiles*.  Both of these approaches can provide us with measures of
*location* (also known as *centrality* or *central tendency*), such as the mean
or median, and measures of dispersion (also known as *scale*), such as the standard
deviation, inter-quartile range (IQR), or MAD (median absolute deviation).  Skew
and kurtosis are additional properties of probability distributions on the real
line that are sometimes of interest.

Below we summarize some less familiar characteristics of probability distributions,
and ways to estimate these characteristics from data.

## Heavy-tailed distributions and tail parameter estimation

The tail parameter
of a random variable $X$ describes how rapidly the tail probability $P(X>x)$
(the complementary CDF) goes to zero as $x$ increases.  In a *heavy tailed* distribution,
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

If a distribution is not heavy-tailed, then it may have a *power law* tail, meaning
that $P(X>x) ~ x^{-\alpha}$.  The value of $\alpha$ is called the *tail index*.  To
estimate the tail index based on a sample of data $\\{X_i\\}$,
consider the *order statistics* $X_{(1)}\le X_{(2)} \le \cdots \le X_{(n)}$.
The "Hill slope estimate" of $\alpha$ is

$$
k^{-1}\sum_{i=0}^{k-1} \log(X_{(n-i)}) - \log(X_{(n-k)}),
$$

where $k$ is a chosen tuning parameter.  We won't be able to justify this entirely, but
note that this is the average in log space of the differences between the upper $k$
order statistics, and the $n-k^{\rm th}$ order statistic.
