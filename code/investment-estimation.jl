using JuMP, Complementarity
using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels
using NLsolve
using PyCall
si = pyimport("scipy.interpolate")

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
resultsFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\results\\"

include(codeFolder * "production-data.jl")

# Compute competitor's cap
dfProd[:totcap] = zeros(size(dfProd, 1))
dfTotCap = by(dfProd, [:Market, :year], totcap = :cap => sum)
for i in 1:size(dfProd, 1)
    mkt = dfProd[i, :Market]
    year = dfProd[i, :year]
    dfProd[i, :totcap] = dfTotCap[(dfTotCap[:Market] .== mkt) .* (dfTotCap[:year] .== year), :totcap][1]
end
dfProd[:compcap] = dfProd[:totcap] - dfProd[:cap]

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
dfDiff = todiff[vValidObs, [:firmID, :Market, :year, :prod, :cap, :compcap, :post1990, :cap_m1, :compcap_m1]]

# Compute investment
dfDiff[:inv] = dfDiff[:cap] .- dfDiff[:cap_m1]
dfDiff[:linv] = log.(abs.(dfDiff.inv)) # Because of symmetry
dfDiff[:lcap] = log.(dfDiff.cap) # Equiv to s^* in the paper
dfInv = dfDiff[abs.(dfDiff[:inv]) .> 0.0, :] # Only keep abs. positive inv.

# Band estimation
splBands = si.SmoothBivariateSpline(dfInv.cap_m1, dfInv.compcap_m1, dfInv.linv)

# Target cap. estimation
splTarget = si.SmoothBivariateSpline(dfInv.cap_m1, dfInv.compcap_m1, dfInv.lcap)
