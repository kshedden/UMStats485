using DataFrames, CSV, DataFrames, UnicodePlots

include("mca.jl")

# Load the dataset.
df = open("cross-verified-database.csv.gz") do io
    CSV.read(io, DataFrame)
end

dx = df[:, [:birth, :un_region, :gender, :level1_main_occ]]
dx = rename(dx, :un_region=>:reg)
dx = rename(dx, :gender=>:sex)
dx = rename(dx, :level1_main_occ=>:occ)

dx = dx[completecases(dx), :]
dx = filter(r->r.birth >= 1500, dx)
dx = filter(r->r.occ != "Other", dx)
dx = filter(r->r.occ != "Missing", dx)
dx = filter(r->r.sex != "Other", dx)

dx[!, :birth] = Float64.(dx[:, :birth])

# Era of birth, round birth year to the nearest 50 years
dx[:, :era] = round.(2*dx[:, :birth]; digits=-2)./2
dx = select(dx, Not(:birth))
dx[!, :era] = [@sprintf("%4d", x) for x in dx[:, :era]]

m = MCA(dx, 3)

# Demonstrate that people with similar object scores tend to have
# similar values on the analysis variables.
ii = sortperm(m.C.F[:, 1])
for _ in 1:10
    jj = sample(1:length(ii)-1)
    println("Similar pair:")
    println(dx[[ii[jj], ii[jj+1]], :])
    println("")
end

# Demonstrate that people with different object scores tend to have
# similar values on the analysis variables.
for _ in 1:10
    jj = sample(1:1000)
    jj = [jj, length(ii) - jj]
    println("Dissimilar pair:")
    println(dx[ii[jj], :])
    println("")
end

# Plot the category scores
p = variable_plot(m; x=1, y=2, text=false, ordered=["era"])
p.savefig("bhht_mca_12.pdf")
p = variable_plot(m; x=1, y=3, text=false, ordered=["era"])
p.savefig("bhht_mca_13.pdf")
p = variable_plot(m; x=2, y=3, text=false, ordered=["era"])
p.savefig("bhht_mca_23.pdf")

# Add an articial variable that is independent of all other
# variables, to demonstrate that MCA places such variables
# at the origin.
dx[:, :junk] = sample(["A", "B", "C"], size(dx, 1))
m2 = MCA(dx, 3)
p = variable_plot(m2; x=1, y=2, text=false, ordered=["era"])
p.savefig("bhht_mca_12_junk.pdf")
dx = select(dx, Not(:junk))

# Try to show how well we are separating the objects.
F = m2.C.F
for k in 1:size(dx, 2)

    vn = m2.vnames[k]
    z = []
    u = unique(dx[:, k])
    sort!(u)
    for v in u
        ii = findall(dx[:, k] .== v)
        push!(z, F[ii, 1])
    end

    PyPlot.clf()
    PyPlot.title(vn)
    PyPlot.boxplot(z, labels=u)
    PyPlot.savefig("obj_scores_$(vn).pdf")
end
