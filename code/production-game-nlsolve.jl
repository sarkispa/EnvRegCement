using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels
using NLsolve
using PyCall
so = pyimport("scipy.optimize")
np = pyimport("numpy")

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")

δ_1 = 31.58
δ_2 = 1.239
ν_c = 1.1916
ν = exp(ν_c)/(1 + exp(ν_c))

function FOC(vQ, params)
    α_0m, vK = params
    Qm = sum(vQ); # Mkt quantity
    Pm = Qm^(1/α_1) * exp(-α_0m/α_1); # Mkt price
    vS = vQ ./ Qm; # Mkt shares
    vMR = Pm .* ( 1 .+ vS ./ α_1 ) # Marginal revenues
    vMC = [ δ_1 + 2 * δ_2 * (vQ[i] - ν * vK[i]) * (vQ[i] > ν * vK[i] ? 1 : 0) for i in 1:length(vQ) ] # Marginal costs
    vFOC = vMR .- vMC
    return vFOC
end

function solve_game_nlsolve(mkt, year)
    vFirms = dMkttoFirms[mkt, year]
    vK = [dCap[[i, year, mkt]] for i in vFirms]
    vInit = [dProd[[i, year, mkt]] for i in vFirms]
    α_0m = dα_0[mkt]
    params = [α_0m, vK]
    sol = so.root(FOC, vInit, args=params)
    return sol
end


(solve_game_nlsolve("AL", 1980.0)["x"] .- [dProd[[i, 1980.0, "AL"]] for i in dMkttoFirms["AL", 1980.0]]).^2
