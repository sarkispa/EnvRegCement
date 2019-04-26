using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels
using GLM

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
resultsFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\results\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")

unique(df.region)
dfEntry = by(dfProd, [:Market, :firmID], entry = :year => minimum)

dfEntry = dfEntry[dfEntry[:entry] .> 1980.0, :]

dMkttoEntryYears = Dict()
for mkt in vMkts
    dMkttoEntryYears[mkt] = dfEntry[dfEntry[:Market] .== mkt, :entry] .- 1.0
end

dMkttoEntryYears

df = by(dfProd, [:Market, :year], sumcap = :cap => sum, post1990 = :post1990 => mean)
df[:entry] = zeros(size(df, 1))
for i in 1:size(df, 1)
    if df[i, :year] ∈ dMkttoEntryYears[df[i, :Market]]
        df[i, :entry] = 1.0
    end
end

probit = glm(@formula(entry ~ sumcap + post1990), df, Binomial(), ProbitLink())
