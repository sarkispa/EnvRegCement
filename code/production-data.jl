using CSV
using DataFrames
using Statistics
using Impute

codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
include(codeFolder * "demand-estimation.jl")

#IO
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
pcafiles = readdir(dataFolder)[(readdir(dataFolder) .> "p") .* (readdir(dataFolder) .< "q")]

df = CSV.read(dataFolder * pcafiles[1], header=2)
df[:year] = ones(size(df, 1)) .* parse(Int64, pcafiles[1][4:7])
df[Symbol("Finish Grinding Capacity")] = typeof(df[Symbol("Finish Grinding Capacity")][1]) == String ? parse.(Int64, df[Symbol("Finish Grinding Capacity")]) : df[Symbol("Finish Grinding Capacity")]
vTypes = eltypes(df)
vNames = names(df)

for file in pcafiles[2:end]

    dfTemp = CSV.read(dataFolder * file, header=2)[:,1:11]
    dfTemp[:year] = ones(size(dfTemp, 1)) .* parse(Int64, file[4:7])
    dfTemp[Symbol("Finish Grinding Capacity")] = [ typeof(dfTemp[Symbol("Finish Grinding Capacity")][i]) == String ? (dfTemp[Symbol("Finish Grinding Capacity")][i] == "Exited" ? 0.0 : parse(Int64, dfTemp[Symbol("Finish Grinding Capacity")][i])) : dfTemp[Symbol("Finish Grinding Capacity")][i] for i in 1:size(dfTemp, 1) ]
    dfTemp[Symbol("Year")] = [ typeof(dfTemp[Symbol("Year")][i]) == String ? (dfTemp[Symbol("Year")][i] == "Changed to grinding only" ? 0.0 : parse(Int64, dfTemp[Symbol("Year")][i])) : dfTemp[Symbol("Year")][i] for i in 1:size(dfTemp, 1) ]
    append!(df, dfTemp)

end

df

chain(df, Impute.LOCF(); limit=0.8)

dStateToMkt = Dict()

for state in unique(df.State)
    dStateToMkt[state] = vMkts[ occursin.(state, vMkts) ][1]
end

statetomkt(state) = dStateToMkt[state]
regiontoconst(region) = dα_0[region]

df[:Market] = statetomkt.(df[:State])
df[:α_0] = regiontoconst.(df[:Market])
df[:post1990] = (df[:year] .> 1990.0) .* 1.0

describe(by(df, [:Company, Symbol("Plant Location"), :year, :Market], N = Symbol("Clinker Capacity Tons/Year (000)") => sum))
describe(by(df, [:Company, Symbol("Plant Location"), :year, :Market], N = Symbol("Finish Grinding Capacity") => mean))

df
