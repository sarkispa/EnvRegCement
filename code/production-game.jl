using JuMP, Complementarity
using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels


# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")
include(codeFolder * "production-game-nlsolve.jl")

# Parameters set-up
δ_1 = 31.58
δ_2 = 1.239
ν_c = 1.1916
ν = exp(ν_c)/(1 + exp(ν_c))


#vMkts = vMkts[]
vYears = [vYears[1]]

vMkts
solve_game.(vMkts, vYears[1])
#results = Dict()

for mkt in vMkts
    for year in vYears
        sol = solve_game(mkt, year)
        println(sol)
    end
end
#results
sol
