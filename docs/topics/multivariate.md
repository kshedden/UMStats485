# Multivariate analysis (various methods)

This document discusses several useful methods for analyzing
multivariate data that are less widely known than the classical
multivariate methods such as PCA, CCA, etc.

## Data Depth

There are various ways to measure the *depth* of a point $z \in {\cal
R}^d$ relative to a distribution or collection of points $\{x_i\in
{\cal R}^d; i=1,\ldots,n}$.  "Deep" points are surrounded in all
directions by many other points, while "shallow" points are near the
surface of the point set.  Another terminology that is used in this
area refers to the deep points as having high "centrality" and the
shallow points as having low "centrality" or high "outlyingness".
Data depth can be viewed as a multivariate generalization of the
notion of a quantile, with the deepest point in a point set being a
type of multivariate median.

Below are several examples of depths.

### Halfspace depth

The original definition of depth was the *halfspace depth* introduced
by John Tukey in 1975.  The definition of the halfspace depth is
simple to describe graphically and a bit more difficult to define
formally.  To calculate the halfspace depth of a single point $z\in
{\cal R}^d$ with respect to a collection of points $\{x_i; i=1,
\ldots, n\}$, with each $x_i \in {\cal R}^d$, let $U$ denote the set
of all unit vectors and define the halfspace depth as

$$
D(z) = 1 - {\rm min}_{u\in U} \sum_i {\cal I}(u^\prime (x_i - z) > 0).
$$

What we are doing here is searching for a line passing through $z$
that places the greatest fraction of the $x_i$ on one side of the
line.  If no such line exists then point $z$ is as deep as possible
and will have halfspace depth approximately equal to 1/2.  In the
other extreme, there is a line passing through $z$ such that all of
the $x_i$ are on the same side of this line.  In this case the point
$z$ is as shallow as possible and its halfspace depth is approximately
equal to zero.

The halfspace depth is geometrically natural but expensive to compute
exactly except in two dimensions.

### Spatial depth

The spatial depth has a simple definition that is relatively easy to
compute in high dimensions:

$$
D_S(z; \{x_i\}) = 1 - \|{\rm Avg}\{(x_i-z)/\|x_i-z\|\}\|
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
D_{L_2}(z; \{x_i\}) = 1 / (1 + {\rm Avg}\{\|z-x_i\|\}).
$$

### Properties of a good depth function

Analysis based on depths does not directly rely on probability models,
making it quite distinct from many other methods of statistical data
analysis.  Several researchers have attempted to define the geometric
properties that a depth function should exhibit.  Four basic such
properties are

* *Affine invariance* -- If the data are transformed by the affine
orthogonal mapping $x\longrightarrow c + Qx$, where $c\in {\cal R}^d$
is a fixed vector and $Q$ is an orthogonal matrix, then the depths
do not change.

* *Maximality at the center* -- If the data are symmetric around zero,
i.e. if $-x$ is in the dataset whenever $x$ is in the dataset, then
the vector $0_d$ achieves the maximum depth.

* *Monotonicity relative to the deepest point* -- If $x^*$ is the deepest
point and we consider any unit vector $u$, then we evaluate the depth
at $x^* + \lambda u$ for $\lambda \in {\cal R}^+$, then the depth is
a decreasing function of $\lambda$.

* *Vanishing at infinity* -- for any sequence $z_i$ with $\|z_i\|$ tending
to infinity, the depths of the $z_i$ tend to zero.


## Quantization
