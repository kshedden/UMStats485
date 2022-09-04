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

# Era of birth, round to the nearest 50 years
dx[:, :era] = round.(2*dx[:, :birth]; digits=-2)./2
dx = select(dx, Not(:birth))
dx[!, :era] = [@sprintf("%4d", x) for x in dx[:, :era]]

m = MCA(dx, 3)
p = variable_plot(m; x=1, y=2, text=false, ordered=["era"])
p.savefig("bhht_mca_12.pdf")
p = variable_plot(m; x=1, y=3, text=false, ordered=["era"])
p.savefig("bhht_mca_13.pdf")
p = variable_plot(m; x=2, y=3, text=false, ordered=["era"])
p.savefig("bhht_mca_23.pdf")
