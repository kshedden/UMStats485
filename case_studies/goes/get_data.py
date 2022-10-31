import os, requests
from calendar import monthrange

tpath = "/scratch/stats_dept_root/stats_dept1/kshedden/goes/python"

url = "https://umbra.nascom.nasa.gov/goes/fits"

def getdata(year, go):
    os.makedirs("%s/%04d" % (tpath, year), exist_ok=True)
    print("%d: " % year, end="")
    for m in range(1, 13):
        print("%d.." % m, sep="", end="", flush=True)
        nday = monthrange(year, m)[1]
        for d in range(1, nday+1):
            fname = "go%02d%04d%02d%02d.fits" % (go, year, m, d)
            url1 = "%s/%04d/%s" % (url, year, fname)
            response = requests.get(url1)
            target = "%s/%04d/%s" % (tpath, year, fname)
            open(target, "wb").write(response.content)
    print("..DONE\n", flush=True)


getdata(2017, 13)
getdata(2019, 14)
