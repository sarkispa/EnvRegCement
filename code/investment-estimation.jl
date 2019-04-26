using CSV
using DataFrames
using Statistics
using CategoricalArrays
using Impute
using FixedEffectModels
using NLsolve
using PyCall
so = pyimport("scipy.optimize")
np = pyimport("numpy")

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
resultsFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\results\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")
include(codeFolder * "pdlag.jl")


# Compute competitor's cap
dfProd[:totcap] = zeros(size(dfProd, 1))
dfTotCap = by(dfProd, [:Market, :year], totcap = :cap => sum)
for i in 1:size(dfProd, 1)
    mkt = dfProd[i, :Market]
    year = dfProd[i, :year]
    dfProd[i, :totcap] = dfTotCap[(dfTotCap[:Market] .== mkt) .* (dfTotCap[:year] .== year), :totcap][1]
end

dfProd[:compcap] = dfProd[:totcap] - dfProd[:cap]
dfProd

# Create lagged capacities
sort!(dfProd, (:firmID, :Market, :year))
dfGaps = by(dfProd, [:firmID, :Market]) do subdf
    return subdf[:year] .== vcat(false, subdf[:year][1:end-1]) .+ 1.0
end
vValidObs = dfGaps[:x1]
todiff = by(dfProd, [:firmID, :Market]) do subdf # for each group
    if size(subdf, 1) == 1 # if only one observation
        output = subdf[:,2:end] # on dataset but group col
        for (name, col) ∈ eachcol(output, true)
            output[Symbol(String(name)*"_m1")] = missing
        end
    else
        output = subdf[:,2:end] # on dataset but group col
        for (name, col) ∈ eachcol(output, true)
            output[Symbol(String(name)*"_m1")] = vcat(missing, col[1:end-1])
        end
    end
    return output
end
dfDiff = todiff[vValidObs, [:firmID, :Market, :year, :prod, :cap, :compcap, :post1990, :cap_m1]]

# Compute investment
dfDiff[:inv] = dfDiff[:cap] .- dfDiff[:cap_m1]

dfDiff[abs.(dfDiff[:inv]) .>= 5.0, :]
