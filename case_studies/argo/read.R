library(readr)

dpath = "/home/kshedden/data/Teaching/argo/julia"

Sys.setenv(VROOM_CONNECTION_SIZE=1000000)

lat = read_csv(file.path(dpath, "lat.csv.gz"))
lat = as.vector(lat[,1])$Column1

lon = read_csv(file.path(dpath, "lon.csv.gz"))
lon = as.vector(lon[,1])$Column1

date = read_csv(file.path(dpath, "date.csv.gz"))
date = as.vector(date[,1])$Column1
day = date - min(date)

pressure = read_csv(file.path(dpath, "pressure.csv.gz"))
pressure = as.vector(pressure[,1])$Column1

temp = read_csv(file.path(dpath, "temp.csv.gz"))
temp = as.matrix(temp)

#psal = read_csv(file.path(dpath, "psal.csv.gz"))
#psal = as.matrix(psal)
