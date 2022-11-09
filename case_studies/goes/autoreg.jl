using Statistics, LinearAlgebra, PyPlot, Printf

rm("plots", recursive=true, force=true)
mkdir("plots")

include("read.jl")

ti = df[:, :Time]
fl = df[:, :Flux1]

# Use blocks of size m, and use the first q obserations to predict
# the final observation.
m = 1000
q = 200

tax = range(-2*m, -2*(m-q))[1:q]

_, flx = make_blocks(ti, fl, m, 0)

flx = log.(1e-8 .+ flx)

x = flx[1:q, :]'
y = flx[end, :]

y .-= mean(y)
for j in 1:size(x, 2)
	x[:, j] .-= mean(x[:, j])
end

# (x'x+LI)ix'y = (v(ss + L)v')ivsu'y = v(s2+L)isu'y

function ridge(x, y, f)
	u,s,v = svd(x)
	b = v * Diagonal(s ./ (s.^2 .+ f)) * u' * y
	return b
end

function doridge(ifig)
	for f in Float64[1, 10, 100, 1000, 10000]
		b = ridge(x, y, f)
		PyPlot.clf()
		PyPlot.grid(true)
		PyPlot.plot(tax, b, "-")
		PyPlot.title(@sprintf("f=%.0f", f))
		PyPlot.savefig(@sprintf("plots/%03d.pdf", ifig))
		ifig += 1
	end

	return ifig
end

ifig = 0
ifig = doridge(ifig)

f = [@sprintf("plots/%03d.pdf", j) for j = 0:ifig-1]
c = `gs -sDEVICE=pdfwrite -dAutoRotatePages=/None -dNOPAUSE -dBATCH -dSAFER -sOutputFile=autoreg_jl.pdf $f`
run(c)
