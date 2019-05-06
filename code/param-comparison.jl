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

include(codeFolder * "production-data.jl")
include(codeFolder * "production-game-mcp.jl")
include(codeFolder * "costfun-objfun.jl")

# Pre-1990 params
δ_1_R, δ_2_R, ν_R = [31.58, 1.239, exp(1.916)/(1 + exp(1.916))] # Ryan's optimal params
δ_1_S, δ_2_S, ν_S = [24.8889, 0.238254, 0.808778] # My optimal params
vPre90 = vYears[1:10]

# Post-1990 Ryan's params
δ_1_Rp90, δ_2_Rp90, ν_Rp90 = [33.99, 1.2091, exp(2.0)/(1 + exp(2.0))]
δ_1_Sp90, δ_2_Sp90, ν_Sp90 = [29.6675, 0.635812, 0.900011] # My optimal params
vPost90 = vYears[11:end]

# Comparison with Ryan's parameter δ_2

# Pre-1990 results
vYears = vPre90
vObj = []
for i in 0.1:0.1:2.0
    append!(vObj, objectivefun([δ_1_S, i, ν_S]))
end
plot([i for i in 0.1:0.1:2.0], vObj, lab="Obj. function")
scatter!([δ_2_S], [objectivefun([δ_1_S, δ_2_S, ν_S])], lab="My δ_2")
scatter!([δ_2_R], [objectivefun([δ_1_S, δ_2_R, ν_S])], lab="Ryan's δ_2")
yaxis!("Obj. fun. value")
xaxis!("Cap. cost param.")
title!("Comparison of Capacity cost parameter,\n using my optimal parameters (Pre 1990)")
savefig(resultsFolder*"paramcomp-S.pdf")

vObj = []
for i in 0.1:0.1:2.0
    append!(vObj, objectivefun([δ_1_R, i, ν_R]))
end
plot([i for i in 0.1:0.1:2.0], vObj, lab="Obj. function")
scatter!([δ_2_S], [objectivefun([δ_1_R, δ_2_S, ν_R])], lab="My δ_2")
scatter!([δ_2_R], [objectivefun([δ_1_R, δ_2_R, ν_R])], lab="Ryan's δ_2")
yaxis!("Obj. fun. value")
xaxis!("Cap. cost param.")
title!("Comparison of Capacity cost parameter,\n using Ryan's optimal parameters (Pre 1990)")
savefig(resultsFolder*"paramcomp-R.pdf")

# Post-1990 results
vYears = vPost90
vObj = []
for i in 0.1:0.1:2.0
    append!(vObj, objectivefun([δ_1_Sp90, i, ν_Sp90]))
end
plot([i for i in 0.1:0.1:2.0], vObj, lab="Obj. function")
scatter!([δ_2_Sp90], [objectivefun([δ_1_Sp90, δ_2_Sp90, ν_Sp90])], lab="My δ_2")
scatter!([δ_2_Rp90], [objectivefun([δ_1_Sp90, δ_2_Rp90, ν_Sp90])], lab="Ryan's δ_2")
yaxis!("Obj. fun. value")
xaxis!("Cap. cost param.")
title!("Comparison of Capacity cost parameter,\n using my optimal parameters (Post 1990)")
savefig(resultsFolder*"paramcomp-p90-S.pdf")

vObj = []
for i in 0.1:0.1:2.0
    append!(vObj, objectivefun([δ_1_Rp90, i, ν_Rp90]))
end
plot([i for i in 0.1:0.1:2.0], vObj, lab="Obj. function")
scatter!([δ_2_Sp90], [objectivefun([δ_1_Rp90, δ_2_Sp90, ν_Rp90])], lab="My δ_2")
scatter!([δ_2_Rp90], [objectivefun([δ_1_Rp90, δ_2_Rp90, ν_Rp90])], lab="Ryan's δ_2")
yaxis!("Obj. fun. value")
xaxis!("Cap. cost param.")
title!("Comparison of Capacity cost parameter,\n using Ryan's optimal parameters (Post 1990)")
savefig(resultsFolder*"paramcomp-p90-R.pdf")
