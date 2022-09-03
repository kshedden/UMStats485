# Factor-type analyses and embeddings

A large class of powerful statistical methods considers data in which
many "objects" are measured with respect to multiple variables.  At a
high level, these analyses usually aim to simultaneously understand
the relationships among the objects and the relationships among the
variables.

For example, we may have a sample of people (the "objects") with each
person measured in terms of their height, weight, age, and sex.  In
this example, two people are "similar" if they have similar values on
most or all of the variables, and two variables are "similar" if
knowing the value of just one of the variables for a particular object
allows one to predict the value of the other variable.

## Embedding

Embedding algorithms take input data vectors $X$ and transform them
into output data vectors $Z$.  Many embedding algorithms take the form
of a "dimension reduction", so that $q \equiv {\rm dim}(Z) < {\rm
dim}(X) \equiv p$.  However some embeddings preserve or even increase
the dimension.

Embeddings can be used for exploratory analysis, especially in
visualizations, and can also be used to construct features for
prediction, as well as being used in formal statistical inference,
e.g. in hypothesis testing.

An embedding approach is linear if $Z = BX$ for a fixed but
data-dependent $q\times p$ matrix $B$.  Linear embedding algorithms
are simpler to devise and characterize than nonlinear embeddings.
Many modern embedding algorithms are nonlinear, exploiting the
potential to better capture complex structure.

Some embedding algorithms embed only the objects while other embedding
algorithms embed both the objects and the variables.  Embedding the
objects provides a reduced feature representation for each object that
can be passed on to additional analysis procedures, or interpreted
directly.  Embedding the variables provides a means to interpret the
relationships among the variables.

## Singular Value Decoposition

Many embedding methods make use of a matrix factorization known as the
*Singular Value Decomposition* (SVD).  The SVD is defined for any
$n\times p$ matrix $X$.  In most cases we want $n \ge p$, and if $n<p$
we would take the SVD of $X^T$ instead of $X$.  When $n\ge p$, we
decompose $X$ as $X = USV^T$, where $U$ is $n\times p$, $S$ is
$p\times p$, and $V$ is $p\times p$.  The matrices $U$ and $V$ are
orthogonal so that $U^TU = I_p$, $V^TV = I_p$, and $S$ is diagonal
with $S_{11} \ge S_{22} \ge \cdots \ge S_{pp}$.  The values on the
diagonal of $S$ are the *singular values* of $S$, and the SVD is
unique except when there are ties among the singular values.

One use of the SVD is to obtain a low rank approximation to a matrix
$X$.  Suppose we truncate the SVD using only the first $k$ components,
so that $\tilde{U}$ is the $n\times k$ matrix consisting of the
leading (left-most) $k$ columns of $U$, $\tilde{S}$ is the upper-left
$k\times k$ block of $S$, and $V$ is the $p\times k$ matrix consisting
of the leading $k$ columns of $V$.  In this case, the matrix
$\tilde{X} \equiv \tilde{U}\tilde{S}\tilde{V}^T$ is a rank $k$ matrix
(it has $k$ non-zero singular values).  Among all rank $k$ matrices,
$\tilde{X}$ is the closest matrix to $X$ in the *Frobenius norm*,
which is defined as

$$
{\rm Frob}(X)^2 = \|X\|_F^2 \equiv \sum_{ij}X_{ij}^2 = {\rm trace}(X^\prime X).
$$

Thus we have

$$
\tilde{X} = {\rm argmin}_{A: {\rm rank}(A) = k} \|A - X\|_F.
$$

## Principal Components Analysis

Suppose that $X$ is a $p$-dimensional random vector with mean $0$ and
covariance matrix $\Sigma$ (our focus here is not the mean, so if $X$
does not have mean zero we can replace it with $X-\mu$, where
$\mu=EX$).  Principal Components Analysis (PCA) seeks a linear
embedding of $X$ into a lower dimensional space of dimension $q<p$.
The standard PCA approach gives us an orthogonal matrix $B$ of
*loadings*, which can be used to produce *scores* denoted $Q$.

For a single vector $X$, the scores are obtained via the mapping $Q(X)
= B^TX$.  For a data matrix $Z$ whose rows are independent and
identically distributed (IID) copies of the random vector $X$, the
scores can be obtained via the mapping $Q = ZB$, where each row of $Q$
contains the scores for the corresponding row of $Z$.

PCA can be viewed in terms of linear compression and decompression of
the variables in $X$.  Let

$$
X \rightarrow B_{:,1:q}^TX \equiv Q(X)
$$

denote the compression that reduces the data from $p$ dimensions to
$q$ dimensions, where $B_{:,1:q}$ is the $p\times q$ matrix consisting
of the leading $q$ columns of $B$.  We can now decompress the data as
follows:

$$ Q \rightarrow B_{:,1:q}Q \equiv \hat{X}.  $$

This represents a two-step process of first reducing the dimension,
then predicting the original data using the reduced data.  Among all
possible loading matrices $B$, the PCA loading matrix loses the least
information in that it minimizes the expected value of $\|X -
\hat{X}\|$.

The loading matrix $B$ used in PCA is the eigenvector matrix of
$\Sigma$.  Specifically, we can write $\Sigma = B\Lambda B^T$, where
$B$ is an orthogonal matrix and $\Lambda$ is a diagonal matrix with
$\Lambda_{11} \ge \Lambda_{22} \ge \cdots \ge \Lambda_{pp} > 0$.  This
is the spectral decomposition of $\Sigma$.  The columns of $B$ are
orthogonal in both the Euclidean metric and in the metric of $\Sigma$,
that is, $B^TB = I_p$ and $B^T\Sigma B = I_p$.  As a result, the
scores $Q \equiv B^TX$ are uncorrelated, ${\rm cov}(Q) = I_q$.

Next we consider how PCA can be carried out with a sample of data,
rather than in a population.  Given a $n\times p$ matrix of data $Z$
whose rows are iid copies of the random vector $X$ (assumed to have
mean $0$), we can estimate the covariance matrix $\Sigma$ as
$\hat{\Sigma} = Z^TZ/n$. Letting $B$ denote the eigenvectors of
$\hat{\Sigma}$, the scores have the form $Q = Z^cB$, where $Z^c$ is a
column-centered version of $Z$.

Since the eigenvalues $\Lambda_{ii}$ are non-increasing, the leading
columns of $Q$ contain the greatest fraction of information about $Z$.
Thus, visualizations (e.g. scatterplots) of the first two columns of
$Z$ best reflect the relationships among the rows of $Z$ (compared to
any other scatterplot formed from linear scores).

## Correspondence Analysis

Correspondence analysis is an embedding approach that aims to
represent *chi-square distances* in the data space as Euclidean
distances for visualization.  The motivation for doing this is that in
many settings chi-square distances may be the best approach for
summarizing the information in the data, while Euclidean distances are
arguably the best approach for producing visualizations for human
interpretation.

Let $X \in {\cal R}^p$ be a random vector with mean $\mu \ge 0$ and
covariance matrix $\Sigma$.  In some cases, it is reasonable to view
$\mu$ and $\Sigma$ as unrelated (i.e. knowing $\mu$ places no
constraints on $\Sigma$, and vice-versa).  On the other hand, in many
settings it is plausible that $\mu$ and $\Sigma$ are related in that
${\rm diag}(\Sigma) \propto \mu$.  Specifically in a Poisson
distribution $\Sigma_{ii} = \mu_i$, but in a broader class of settings
we may have over-dispersion or under-dispersion, meaning that
$\Sigma_{ii} = c\cdot \mu_i$, where $c>1$ or $c<1$ for over and
under-dispersion, respectively.

In any setting where the variance is proportional to the mean, it is
reasonable to compare vectors using chi-square distances.
Specifically the chi-square distance from $X$ to the mean is
$(X-\mu)^T{\rm diag}(\mu)^{-1}(X-\mu)$, and the chi-square distance
between two random vectors $X$ and $Y$ having the same mean $\mu$ is
$(X-Y)^T{\rm diag}(\mu)^{-1}(X-Y)$.  If $\Sigma$ is a diagonal matrix,
the chi-square distance is also the *Mahalanobis distance*, which is
arguably the proper way to measure distances among vectors whose
components have differing variances.

Suppose we have $n$ observations on $p$ variables, and the data are
represented in an $n\times p$ matrix $X$ whose rows are the cases
(observations) and columns are the variables.  Correspondence analysis
can be applied when each $X_{ij} \ge 0$, and where it makes sense to
compare any two rows or any two columns of $X$ using chi-square
distance.  Let $P \equiv X/N$, where $N = \sum_{ij} X_{ij}$.  The goal
is to transform $P$ into *row scores* $F$ and *column scores* $G$,
where $F$ is an $n\times p$ array and $G$ is a $p\times p$ array.

Let $P_{i,:}$, $F_{i,:}$, and $G_{i,:}$ denote row $i$ of the arrays
$P$, $F$, and $G$ respectively, and let $r \equiv P\cdot 1_p$ (the row sums
of $P$) and let $c = P^T\cdot 1_n$ (the column sums of $P$).

Let $\tilde{P}^r \equiv {\rm diag}(r)^{-1}\cdot P$ denote the *row
profiles* of $P$, which are simply the rows of $P$ (or of $X$)
normalized by their sum.  Analogously, let $\tilde{P}^c \equiv P\cdot
{\rm diag}(x)^{-1}$ denote the *column profiles* of $P$ (or of $X$).

Our goals are as follows:

* For any $1 \le i, j \le n$, the Euclidean distance from $F_{i,:}$ to
$F_{j:}$ is equal to the chi-square distance from $\tilde{P}^r_{i,:}$
to $\tilde{P}^r_{j,:}$.  Also, for any $1 \le i,j \le p$ the Euclidean
distance from $G_{:,i}$ to $G_{:,j}$ is equal to the chi-square
distance from $\tilde{P}^c_{:,i}$ to $\tilde{P}^c_{:,j}$.  Thus, $F$
provides an embedding of the rows of $\tilde{P}^r$ and $G$ provides an
embedding of the columns of $\tilde{P}^c$.

* The columns of $F$ and $G$ are ordered in terms of importance.
Specifically, if we select $1 \le q \le p$ then the Euclidean distance
from $F_{i,1:q}$ to $F_{j,1:q}$ is approximately equal to the
chi-square distance from $P_{i,:}$ to $P_{j,:}$.  Note that if $q=p$
then the approximation becomes exact, but for $q<p$ the approximation
is inexact.

### Derivation of the algorithm

Suppose that $X$ is a $n\times p$ array whose rows are an independent
and identically distributed (iid) sample from a population with mean
$\mu \in {\cal R}^p$.  Let $W_r = {\rm diag}(r)\in {\cal R}^{n\times
n}$ and $W_c = {\rm diag}(c) \in {\cal R}^{p\times p}$.

We begin by taking the singular value decomposition of a standardized
version of $P$:

$$
W_r^{-1/2}(P - rc^T)W_c^{-1/2} = USV^T.
$$

Now let $F = W_r^{-1/2}US$ and $G = W_c^{-1/2}VS$.  We now show that
this specification of $F$ and $G$ satisfies the conditions stated
above.

First, note that since $V$ is orthogonal

$$
\|F_{i,:} - F_{j,:}\| = \|W_r^{-1/2}(F_{i,:} - F_{j,:})V^T\|.
$$

Therefore,

$$
\|F_{i,:} - F_{j,:}\|^2 =
\|r_i^{-1/2}U_{i,:}S - r_j^{-1/2}U_{j,:}S\|^2 =
\|r_i^{-1}(P_{i,:} - r_ic^T)W_c^{-1/2} - r_j^{-1}(P_{j,:} - r_jc^T)W_c^{-1/2}\|^2 =
$$

$$
\|r_i^{-1}P_{i,:}W_c^{-1/2} - r_j^{-1}P_{j,:}W_c^{-1/2}\|^2 =
(P_{i,:}/r_i - P_{j,:}/r_j)^TW_c^{-1}(P_{i,:}/r_i - P_{j,:}/r_j).
$$

Since $W_c = {\rm diag}(\hat{\mu})$, where $\hat{\mu}$ is an estimate
of $\mu$, it follows that $\|F_{i,:} - F_{j,:} \|$ is an estimate of
the chi-square distance between $\tilde{P}^r_{i,:}$ and
$\tilde{P}^r_{j,:}$.  Thus, the rows of $F$ embed the rows of
$\tilde{P}^r$ as desired.  An analogous argument shows that the rows
of $G$ embed the variables (the columns of $\tilde{P}^c$).

### Correspondence analysis and Multiple Correspondence analysis for nominal data

One common application of correspondence analysis (CA) arises when
analyzing datasets in which all variables are nominal.  First, suppose
we have a single nominal variable and code it using an *indicator
matrix*.  That is, we define $X$ to be a matrix whose values are
entirely $0$ and $1$, such that $X_{ij}=1$ if and only if the value of
the nominal variable for case $i$ is equal to level $j$.
Correspondence analysis as defined above can be used to analyze this
indicator matrix, revealing how the objects and categories are
related.

A more interesting extension of CA is *Multiple Correspondence
Analysis*, in which we have several nominal variables.  In this case,
we recode each nominal variable with its own indicator matrix, and
then concatenate these matrices horizontally.  If there are $p_j$
levels for variable $j$, and we set $p = \sum_j p_j$, then the
concatenated indicator matrix is $n\times p$.  We then apply CA to
this concatenated indicator matrix, yielding insights into the
relationships among the objects, the relationships between different
levels of a single variable, and relationships among levels of
different variables.
