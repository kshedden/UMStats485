using LinearAlgebra, StatsBase, UnicodePlots, Printf
using StatsBase, DataFrames, PyPlot

#==
Basic implementation of Multiple Correspondence Analysis

References:
https://personal.utdallas.edu/~herve/Abdi-MCA2007-pretty.pdf
https://en.wikipedia.org/wiki/Multiple_correspondence_analysis
https://pca4ds.github.io
https://maths.cnam.fr/IMG/pdf/ClassMCA_cle825cfc.pdf
==#

struct CA{T<:Real}

    # The data matrix
    Z::Array{T}

    # The residuals
    R::Array{T}

    # Row and column masses (means)
    rm::Vector{T}
    cm::Vector{T}

    # The standardized residuals
    SR::Array{T}

    # Object scores
    F::Array{T}

    # Variable scores
    G::Array{T}

    # Inertia (eigenvalues of the indicator matrix)
    I::Vector{T}
end

function CA(X, d)

    # Convert to proportions
    X = X ./ sum(X)

    # Calculate row and column means
    r = sum(X, dims = 2)[:]
    c = sum(X, dims = 1)[:]

    # Center the data matrix to create residuals
    R = X - r * c'

    # Standardize the data matrix to create standardized residuals
    Wr = Diagonal(sqrt.(r))
    Wc = Diagonal(sqrt.(c))
    SR = Wr \ R / Wc

    # Get the object factor scores (F) and variable factor scores (G).
    P, D, Q = svd(SR)
    Dq = Diagonal(D)[:, 1:d]
    F = Wr \ P * Dq
    G = Wc \ Q * Dq
    I = D.^2

    return CA(X, R, r, c, SR, F, G, I)
end

struct MCA

    # The underlying corresponence analysis
    C::CA

    # Variable names
    vnames::Vector{String}

    # Map values to integer positions
    rd::Vector{Dict}

    # Map integer positions to values
    dr::Vector{Dict}

    # Split the variable scores into separate arrays for
    # each variable.
    Gv::Vector

    # Eigenvalues
    unadjusted_eigs::Vector{Float64}
    benzecri_eigs::Vector{Float64}
    greenacre_eigs::Vector{Float64}
end

# Split the variable scores to a separate array for each
# variable.
function xsplit(G, rd)
    K = [length(di) for di in rd]
    Js = cumsum(K)
    Js = vcat(1, 1 .+ Js)
    Gv = Vector{Matrix{eltype(G)}}()
    for j in eachindex(K)
        g = G[Js[j]:Js[j+1]-1, :]
        push!(Gv, g)
    end
    return Gv
end

function get_eigs(I, K, J)
    ben = zeros(length(I))
    gra = zeros(length(I))
    Ki = 1 / K
    f = K / (K - 1)
    for i in eachindex(I)
        if I[i] > Ki
            ben[i] = (f * (I[i] - Ki))^2
        end
    end

    unadjusted = I ./ sum(I)
    gt = f * (sum(abs2, I) - (J - K) / K^2)

    return unadjusted, ben ./ sum(ben), ben ./ gt
end

function MCA(Z, d)

    vnames = if typeof(Z) <: DataFrame
        names(Z)
    else
        # Default variable names if we don't have a dataframe
        ["v$(j)" for j in 1:size(Z, 2)]
    end

    # Get the indicator matrix
    X, rd, dr = make_indicators(Z)

    C = CA(X, d)

    # Split the variable scores into separate arrays for each variable.
    Gv = xsplit(C.G, rd)

    una, ben, gra = get_eigs(C.I, size(Z, 2), size(X, 2))

    return MCA(C, vnames, rd, dr, Gv, una, ben, gra)
end


function make_single_indicator(z)

    n = length(z)

    # Unique values of the variable
    uq = sort(unique(z))

    if length(uq) > 50
        @warn("Nominal variable has more than 50 levels")
    end

    # Recoding dictionary, maps each distinct value to
    # an offset
    rd = Dict{eltype(z),Int}()
    for (j, v) in enumerate(uq)
        if !ismissing(v)
            rd[v] = j
        end
    end

    # Number of unique values of the variable excluding missing
    m = length(rd)

    # The indicator matrix
    X = zeros(n, m)
    for (i, v) in enumerate(z)
        if ismissing(v)
            # Missing values are treated as uniform across the levels.
            X[i, :] .= 1 / m
        else
            X[i, rd[v]] = 1
        end
    end

    # Reverse the recoding dictionary
    rdi = Dict{Int,eltype(z)}()
    for (k, v) in rd
        rdi[v] = k
    end

    return X, rd, rdi
end

# Create an indicator matrix for the nominal data matrix Z.
# In addition to the indicator matrix, return vectors of
# dictionaries mapping levels to positions and positions
# to levels for each variable.
function make_indicators(Z)

    rd, rdr = [], []
    XX = []
    for j = 1:size(Z, 2)
        X, di, dir = make_single_indicator(Z[:, j])
        push!(rd, di)
        push!(rdr, dir)
        push!(XX, X)
    end
    I = hcat(XX...)

    return I, rd, rdr
end

# Return a table summarizing the inertia.
function inertia(mca::MCA)
    inr = DataFrame(:Raw=>mca.C.I, :Unadjusted=>mca.unadjusted_eigs,
                    :Benzecri=>mca.benzecri_eigs, :Greenacre=>mca.greenacre_eigs)
    return inr
end

function variable_plot(mca::MCA; text = true, x = 1, y = 2, vnames = [], kwargs...)
    if text
        return variable_plot_text(mca; x, y, vnames = [], kwargs...)
    else
        return variable_plot_mpl(mca; x, y, vnames = [], kwargs...)
    end
end

function variable_plot_text(mca::MCA; x = 1, y = 2, vnames = [], kwargs...)

    plt = scatterplot(mca.C.G[:, x], mca.C.G[:, y]; kwargs...)

    inr = inertia(mca)

    for (j, g) in enumerate(mca.Gv)
        # Map column position to variable names
        dr = mca.dr[j]
        vn = length(vnames) > 0 ? vnames[j] : ""
        for (k, v) in dr
            if vn != ""
                lb = @sprintf("%s-%s", vn, v)
            else
                lb = v
            end
            annotate!(plt, g[k, x], g[k, y], lb)
        end
    end

    return plt
end

function variable_plot_mpl(mca::MCA; x = 1, y = 2, vnames = [], ordered=[], kwargs...)

    fig = PyPlot.figure()
    ax = fig.add_axes([0.1, 0.1, 0.8, 0.8])
    ax.grid(true)

    # Set up the colormap
    cm = get(kwargs, :cmap, PyPlot.get_cmap("tab10"))

    # Set up the axis limits
    mn = 1.2*minimum(mca.C.G, dims=1)
    mx = 1.2*maximum(mca.C.G, dims=1)
    xlim = get(kwargs, :xlim, [mn[x], mx[x]])
    ylim = get(kwargs, :ylim, [mn[y], mx[y]])
    ax.set_xlim(xlim...)
    ax.set_ylim(ylim...)

    for (j, g) in enumerate(mca.Gv)

        if mca.vnames[j] in ordered
            PyPlot.plot(g[:, x], g[:, y], "-", color=cm(j))
        end

        dr = mca.dr[j]
        vn = length(vnames) > 0 ? vnames[j] : ""
        for (k, v) in dr
            if vn != ""
                lb = @sprintf("%s-%s", vn, v)
            else
                lb = v
            end
            ax.text(g[k, x], g[k, y], lb, color=cm(j), ha = "center", va = "center")
        end
    end

    inr = inertia(mca)
    PyPlot.xlabel(@sprintf("Dimension %d (%.2f%%)", x, 100*inr[x, :Greenacre]))
    PyPlot.ylabel(@sprintf("Dimension %d (%.2f%%)", y, 100*inr[y, :Greenacre]))

    return fig
end

