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
include(codeFolder * "costfun-objfun.jl")

# Pre-1990 params
δ_1_R, δ_2_R, ν_R = [31.58, 1.239, exp(1.916)/(1 + exp(1.916))] # Ryan's optimal params
δ_1_S, δ_2_S, ν_S = [24.8889, 0.238254, 0.808778] # My optimal params
vPre90 = vYears[1:10]

# Post-1990 Ryan's params
δ_1_Rp90, δ_2_Rp90, ν_Rp90 = [33.99, 1.2091, exp(2.0)/(1 + exp(2.0))]
δ_1_Sp90, δ_2_Sp90, ν_Sp90 = [29.6675, 0.635812, 0.900011] # My optimal params
vPost90 = vYears[11:end]

# Actual estimation
# Note that you need to change the years to do either pre- or post-1990 results.
vYears = vPre90 # or vPost90
bnds = ((20.0, 32.0), (0.0, 2.0), (0.5, 1.0)) # Grid
open(resultsFolder*"brute.txt", "w") do f
    sol = so.brute(objectivefun, bnds, Ns=7, finish="None", full_output=true)
    write(f, "$sol \n")
end
# Adapt bounds and try again, until grid is small enough.
# Then,
vParams = [24.8889, 0.238254, 0.808778] # Should be center of final grid
open(resultsFolder*"finalPowell.txt", "w") do f
    sol = so.minimize(objectivefun, vParams, method="Powell", bounds=bnds, options=Dict("maxiter"=>100))
    write(f, "$sol \n")
end
