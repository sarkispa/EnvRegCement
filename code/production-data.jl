using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"

pcafiles = readdir(dataFolder)[(readdir(dataFolder) .> "p") .* (readdir(dataFolder) .< "q")]

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "get-firmID.jl")

# Production dataset cleaning
df = CSV.read(dataFolder * pcafiles[1], header=2)
df[:year] = ones(size(df, 1)) .* parse(Int64, pcafiles[1][4:7])
df[:firmID] = firmtoID.(df[:Company])

for file in pcafiles[2:end]
    dfTemp = CSV.read(dataFolder * file, header=2)[:,1:11]
    dfTemp[:year] = ones(size(dfTemp, 1)) .* parse(Int64, file[4:7])
    dfTemp[:firmID] = firmtoID.(dfTemp[:Company])
    dfTemp[Symbol("Finish Grinding Capacity")] = [ typeof(dfTemp[Symbol("Finish Grinding Capacity")][i]) == String ? (dfTemp[Symbol("Finish Grinding Capacity")][i] == "Exited" ? 0.0 : parse(Int64, dfTemp[Symbol("Finish Grinding Capacity")][i])) : dfTemp[Symbol("Finish Grinding Capacity")][i] for i in 1:size(dfTemp, 1) ]
    dfTemp[Symbol("Year")] = [ typeof(dfTemp[Symbol("Year")][i]) == String ? (dfTemp[Symbol("Year")][i] == "Changed to grinding only" ? 0.0 : parse(Int64, dfTemp[Symbol("Year")][i])) : dfTemp[Symbol("Year")][i] for i in 1:size(dfTemp, 1) ]
    append!(df, dfTemp)
end

chain(df, Impute.LOCF(); limit=0.8)

df[Symbol("ZIP Code")] = [df[Symbol("ZIP Code")][i][1:minimum([length(df[Symbol("ZIP Code")][i]), 5])] for i in 1:size(df,1)]
df[Symbol("ZIP Code")] = parse.(Int64, df[Symbol("ZIP Code")])

# Differentiate Pennsylvania
df[:State] = [(df[Symbol("ZIP Code")][i] < 16891)*(df[Symbol("ZIP Code")][i] > 15000) ? "PAW" : df[:State][i] for i in 1:size(df,1)]
df[:State] = [df[:State][i] == "PA" ? "1P" : df[:State][i] for i in 1:size(df,1)]
df[:State] = [df[:State][i] == "PAW" ? "PA" : df[:State][i] for i in 1:size(df,1)]

# Differentiate Texas
df[:State] = [(df[Symbol("ZIP Code")][i] < 76000)*(df[Symbol("ZIP Code")][i] > 74999 ) | (df[Symbol("ZIP Code")][i] < 79000)*(df[Symbol("ZIP Code")][i] > 76999 ) ? "1T" : df[:State][i] for i in 1:size(df,1)]

# Differentiate California
df[:State] = [(df[Symbol("ZIP Code")][i] < 94000)*(df[Symbol("ZIP Code")][i] > 91000 ) ? "1C" : df[:State][i] for i in 1:size(df,1)]

# Grouping states into markets
dStateToMkt = Dict()
for state in unique(df.State)
    dStateToMkt[state] = vMkts[ occursin.(state, vMkts) ][1]
end
statetomkt(state) = dStateToMkt[state]
df[:Market] = statetomkt.(df[:State])

unique(df.Market)
# Grouping dataset into firm-year-market level
dfProd = by(df, [:Market, :year, :firmID, Symbol("Plant Location")],
            prod = Symbol("Clinker Capacity Tons/Year (000)") => sum,
            cap = Symbol("Finish Grinding Capacity") => mean)

dfProd = by(dfProd, [:Market, :year, :firmID],
            prod = :prod => sum,
            cap = :cap => sum)

# Adding variables for production game
dfProd[:post1990] = (dfProd[:year] .> 1990.0) .* 1.0

# Creating dictionaries to store variables
dCap = Dict(convert(Vector, dfProd[[:firmID, :year, :Market]][i, :]) => dfProd[:cap][i] for i in 1:size(dfProd, 1))
dProd = Dict(convert(Vector, dfProd[[:firmID, :year, :Market]][i, :]) => dfProd[:prod][i] for i in 1:size(dfProd, 1))
d1990 = Dict(convert(Vector, dfProd[[:firmID, :year, :Market]][i, :]) => dfProd[:post1990][i] for i in 1:size(dfProd, 1))

# Create dictionary to get active firms by Market, year
vYears = unique(dfProd.year)
vMkts = unique(dfProd.Market)

dMkttoFirms = Dict()
for mkt in vMkts
    for year in vYears
        dMkttoFirms[mkt, year] = unique(dfProd[(dfProd[:Market] .== mkt).*(dfProd[:year] .== year), :].firmID)
    end
end
