# Various methods of multivariate analysis

This document discusses several useful methods for analyzing
multivariate data that are less widely known than the classical
multivariate methods such as PCA, CCA, etc.

## Functional data

A particular type of multivariate data is known as *functional data*,
in which we observe vectors $v$ that arise from evaluating
a function on a grid of points, i.e. $v_i = f_i(t_i)$ for
a grid $t_1 < t_2 < \cdots$.  If the functions $f_i$ are smooth
then the elements of each $v_i$ will reflect this smoothness.
*Functional Data Analysis* (FDA) encompasses many methods for
analyzing functions as data.  In practice we never
actually observe a function in its entirety, and instead only
observe a function evaluated on a finite set of points.  Thus
the data we work with in FDA are finite dimensional vectors,
and thus have the same form as other types
of quantitative multivariate data.  But since the data are
considered to arise by evaluating smooth functions, different
methods have been developed to take advantage of this property.

## Data Depth

There are various ways to measure the *depth* of a point $z \in {\cal
R}^d$ relative to a distribution or collection of points $\{x_i\in
{\cal R}^d; i=1,\ldots,n}$.  "Deep" points are surrounded in all
directions by many other points, while "shallow" points lie near the
surface of the point set.  Another terminology that is used in this
area refers to the deep points as having high "centrality" and the
shallow points as having low "centrality" or high "outlyingness".
Data depth can be viewed as a multivariate generalization of the
notion of a quantile, with the deepest point in a set being a
type of multivariate median.

Below are several examples of depths.

### Halfspace depth

The original definition of depth was the *halfspace depth* introduced
by John Tukey in 1975.  The definition of the halfspace depth is
simple to describe graphically and a bit more difficult to define
formally.  To calculate the halfspace depth of a single point $z\in
{\cal R}^d$ with respect to a collection of points $\{x_i; i=1,
\ldots, n\}$, with each $x_i \in {\cal R}^d$, let $U$ denote the set
of all unit vectors in ${\cal R}^d$ and define the halfspace depth as

$$
D(z) = {\rm min}_{u\in U} n^{-1}\sum_{i=1}^n {\cal I}(u^\prime (x_i - z) > 0).
$$

What we are doing here is searching for a line passing through $z$
that places the greatest fraction of the $x_i$ on one side of the
line.  If $z$ falls at the geometric center of a collection of
symmetrically distributed points, then $z$ is as deep as possible
and will have halfspace depth approximately equal to 1/2.  At the
other extreme there is a line passing through $z$ such that all of
the $x_i$ are on the same side of this line.  In this case the point
$z$ is as shallow as possible and its halfspace depth is approximately
equal to zero.

The halfspace depth is geometrically natural but expensive to compute
exactly except in two dimensions.

### Spatial depth

The spatial depth has a simple definition that is relatively easy to
compute in high dimensions:

$$
D_S(z; \{x_i\}) = 1 - \|{\rm Avg}_i\{(x_i-z)/\|x_i-z\|\}\|
$$

Note that $(x_i-z)/\|x_i-z\|$ is a unit vector pointing in the
direction from $z$ to $x_i$.  If a point $z$ is "shallow" then most of
the unit vectors $(x_i-z)/\|x_i-z\|$ point in roughly the same
direction, and therefore their average value will have large
magnitude.  If a point $z$ is "deep" then these unit vectors will
point in many different directions and their average value will have
small magnitude.

### L2 depth

The $L_2$ depth also has a simple definition and is easy to compute:

$$
D_{L_2}(z; \{x_i\}) = 1 / (1 + {\rm Avg}_i\{\|x_i-z\|\}).
$$

### Properties of a good depth function

Analysis based on depths does not directly rely on probability models,
making it quite distinct from many other methods of statistical data
analysis.  For statistical methods based on probability there are
standard properties such as unbiasedness, consistency, accuracy, and
efficiency that are used to quantify the performance of the approach.
Although it is possible to place depth into a probabilistic framework so
that these notions can be applied, several researchers have attempted
to define the geometric properties that a depth function should
exhibit that do not depend on any probability framework.  Four basic
such properties are

* *Affine invariance* -- If the data are transformed by the affine
orthogonal mapping $x\longrightarrow c + Qx$, where $c\in {\cal R}^d$
is a fixed vector and $Q$ is an orthogonal matrix, then the depths do
not change.

* *Maximality at the center* -- If the data are symmetric around zero,
i.e. if $-x$ is in the dataset whenever $x$ is in the dataset, then
the vector $0_d$ achieves the maximum depth.

* *Monotonicity relative to the deepest point* -- Let $\tilde{x}$ be
the deepest point and we consider any unit vector $u$, and we then
evaluate the depth at $\tilde{x} + \lambda u$ for $\lambda \in {\cal
R}^+$, then the depth is a decreasing function of $\lambda$.

* *Vanishing at infinity* -- for any sequence $z_i$ with $\|z_i\|$
tending to infinity, the depths of the $z_i$ tend to zero.

### Depth peeling

Data depth can be used in exploratory multivariate analysis to identify
the most central or typical points and then contrast them with the more
outlying points.  A systematic way to do this is to stratify the data
based on depth and then inspect the points in each depth stratum.  For
example, if we stratify the data into 10 groups based on depth deciles,
the first decile consists of the shallowest 10% of points and the last
decile consists of the deepest 10% of points.

Often (not always) there is little heterogeneity in the deepest decile,
meaning that all of the deepest points are very similar.  However there
is nearly always heterogeneity in the shallowest decile, as there are
many different ways to be near the periphery of a collection of points.

## Quantization

A quantization algoithm aims to represent a multivariate distribution
through a relatively small number of representative points.
This can be a useful exploratory technique if the distribution being
studied has a complex form that is not well captured through additive factors
(as in PCA).  The goal of almost any quantization algorithm is to
find a collection of representative points $\{x_i\}$ that are optimal
in some sense - for example we may wish to optimize the $x_i$ so as
to minimize the distance from any observation to its closest representative
point.  Inspecting the representative points may provide a quick
means to understand the high probability regions of the distribution.

A recently developed algorithm constructs
[support points](https://arxiv.org/abs/1609.01811) that are an
effective form of quanization.
