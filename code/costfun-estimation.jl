using JuMP, Complementarity
using CSV
using DataFrames
using Statistics
using Impute
using FixedEffectModels
using NLsolve
using Plots
using PyCall
so = pyimport("scipy.optimize")
np = pyimport("numpy")

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"
resultsFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\results\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")
include(codeFolder * "production-game-mcp.jl")

init_δ_1 = 31.58
init_δ_2 = 1.239
init_ν_c = 1.916
init_ν = exp(init_ν_c)/(1 + exp(init_ν_c))
init_params = [init_δ_1, init_δ_2, init_ν]
vYears = vYears[1:10]

function objectivefun(params)
    resids = []
    for mkt in vMkts
        for year in vYears
            sol = solve_game_mcp(mkt, year, params)
            vProd = [dProd[[i, year, mkt]] for i in dMkttoFirms[mkt, year]]
            vCap = [dCap[[i, year, mkt]] for i in dMkttoFirms[mkt, year]]
            #push!(resids, sol .> vCap)
            push!(resids, (sol .- vProd).^2 )
        end
    end
    return sum(vcat(resids...))/length(vcat(resids...))
end

# objectivefun(init_params)

# function resids(params)
#     resids = []
#     for mkt in vMkts
#         for year in vYears
#             sol = solve_game_mcp(mkt, year, params)
#             vProd = [dProd[[i, year, mkt]] for i in dMkttoFirms[mkt, year]]
#             push!(resids, sol .- vProd)
#         end
#     end
#     return sum(vcat(resids...))
# end
#
# objectivefun(init_params)
# objectivefun(vParams1)
# objectivefun(vParams2)
#
# # Comparison with Ryan's parameter δ_2
# vObj = []
# for i in 0.2:0.1:5.0
#     append!(vObj, objectivefun([init_δ_1, i, init_ν]))
# end
# plot([i for i in 0.2:0.1:5.0], vObj)
# scatter!([[i for i in 0.2:0.1:5.0][argmin(vObj)]], [minimum(vObj)], lab="Min. point")
# scatter!([[i for i in 0.2:0.1:5.0][11]], [vObj[11]], lab="Ryan's point")
# savefig(resultsFolder*"delta2estim.pdf")
#
# # Comparison with Ryan's parameter ν
# vObj = []
# for i in 0.0:0.05:1.0
#     append!(vObj, objectivefun([init_δ_1, init_δ_2, i]))
# end
# plot([i for i in 0.0:0.05:1.0], vObj)
# scatter!([[i for i in 0.0:0.05:1.0][argmin(vObj)]], [minimum(vObj)], lab="Min. point")
# scatter!([[i for i in 0.0:0.05:1.0][18]], [vObj[18]], lab="Ryan's point")
# savefig(resultsFolder*"threshestim.pdf")
#
# # Comparison with Ryan's parameter δ_1
# vObj = []
# for i in 29.0:0.1:34.0
#     append!(vObj, objectivefun([i, init_δ_2, init_ν]))
# end
# plot([i for i in 29.0:0.1:34.0], vObj)
# scatter!([[i for i in 29.0:0.1:34.0][argmin(vObj)]], [minimum(vObj)], lab="Min. point")
# scatter!([[i for i in 29.0:0.1:34.0][27]], [vObj[27]], lab="Ryan's point")
# savefig(resultsFolder*"delta1estim.pdf")

# Actual estimation
vParams1 = [23.785, 0.135, 0.7755]
vParams2 = [26.735, 0.385, 0.83]
bnds= ((23.78, 26.74), (0.13, 0.39), (0.775, 0.835))
# open(resultsFolder*"brute5.txt", "w") do f
#     sol = so.brute(objectivefun, bnds, Ns=7, finish="None", full_output=true)
#     write(f, "$sol \n")
# end
# vParams = [init_params, vParams1, vParams2]
# sols = []
# open(resultsFolder*"unconstrained.txt", "w") do f
#     for initial_points in vParams
#         solP = so.minimize(objectivefun, initial_points, method="Powell", options=Dict("maxiter"=>200))
#         append!(sols, solP)
#         write(f, "$solP \n")
#     end
# end

open(resultsFolder*"bounded-params5.txt", "w") do f
    solP = so.minimize(objectivefun, vParams1, method="Powell", bounds=bnds, options=Dict("maxiter"=>100))
    write(f, "$solP \n")
end
#
open(resultsFolder*"bounded-params6.txt", "w") do f
    solP = so.minimize(objectivefun, vParams2, method="Powell", bounds=bnds, options=Dict("maxiter"=>100))
    write(f, "$solP \n")
end
