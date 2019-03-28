using CSV
using DataFrames
using Statistics
using Impute

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

# Grouping states into markets
dStateToMkt = Dict()
for state in unique(df.State)
    dStateToMkt[state] = vMkts[ occursin.(state, vMkts) ][1]
end
statetomkt(state) = dStateToMkt[state]
df[:Market] = statetomkt.(df[:State])


# Grouping dataset into firm-year-market level
dfProd = by(df, [:firmID, Symbol("Plant Location"), :year, :Market],
            prod = Symbol("Clinker Capacity Tons/Year (000)") => sum,
            cap = Symbol("Finish Grinding Capacity") => mean)

dfProd = by(dfProd, [:firmID, :year, :Market],
            prod = :prod => sum,
            cap = :cap => sum)

# Adding variables for production game
dfProd[:post1990] = (dfProd[:year] .> 1990.0) .* 1.0

# Creating dictionaries to store variables
dCap = Dict(convert(Vector, dfProd[[:firmID, :year, :Market]][i, :]) => dfProd[:cap][i] for i in 1:size(dfProd, 1))
dProd = Dict(convert(Vector, dfProd[[:firmID, :year, :Market]][i, :]) => dfProd[:prod][i] for i in 1:size(dfProd, 1))
d1990 = Dict(convert(Vector, dfProd[[:firmID, :year, :Market]][i, :]) => dfProd[:post1990][i] for i in 1:size(dfProd, 1))
