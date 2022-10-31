library(readr)
library(dplyr)

# Location of the csv file produced by prep.py
qpath = "/home/kshedden/data/Teaching/goes"

get_goes = function(year) {
    df = read_csv(sprintf("%s/goes%4d.csv.gz", qpath, year))
    return(df)
}

make_blocks = function(ti, fl, m, d) {

    q = floor(length(ti) / m)
    n = q * m
    ti = ti[1:n]
    fl = fl[1:n]
    g = floor(n / m)
    tix = array(ti, c(m, g))
    flx = array(fl, c(m, g))

    # Time difference within block
    td = tix[m,] - tix[1,]

    # Exclude the blocks that contain skips
    ii = abs(td - median(td)) < 1
    tix = tix[, ii]
    flx = flx[, ii]

    if (d > 0) {
        for (j in 1:d) {
            flx = diff(flx, dims=1)
        }
    }

    return(list(time=tix, flux=flx))
}
