using JuMP, Complementarity

# Input files
dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
codeFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\code\\"

include(codeFolder * "demand-estimation.jl")
include(codeFolder * "production-data.jl")
include(codeFolder * "production-game-func.jl")


# Parameters set-up
δ_1 = 31.58
δ_2 = 1.239
ν_c = 1.1916
ν = exp(ν_c)/(1 + exp(ν_c))

vFirms = dMkttoFirms["AKHIORWA", 1980.0]
# Cournot game
## Model creation
m = MCPModel()

## Choice variables (quantity)
@variable(m, q[j in vFirms] >= 0.1, start=dProd[[j, 1980.0, "AKHIORWA"]])

## Intermediate expressions
@mapping(m, Q, sum(q[i] for i in vFirms)) # Market quantity
@mapping(m, s[j in vFirms], q[j] /  Q) # Product shares
@mapping(m, P, exp(-dα_0["AKHIORWA"]/α_1) * Q^(1/α_1) ) # Market price
@mapping(m, MR, P/(Q * α_1))
@mapping(m, MC[j in vFirms], δ_1 + 2 * δ_2 * (q[j] - ν * dCap[[j, 1980.0, "AKHIORWA"]]) * (1 / (1 + exp(-100 * (q[j] - ν * dCap[[j, 1980.0, "AKHIORWA"]])))) )
@mapping(m, FOC[j in vFirms], MR - MC[j] )

## Complementarity conditions
@complementarity(m, FOC, q)

## Solver options
PATHSolver.options(convergence_tolerance=1e-5, output=:yes, time_limit=360)
status = solveMCP(m)
x = @show result_value.(q)
[x[i] for i in vFirms]
[dProd[[i, 1980.0, "AKHIORWA"]] for i in vFirms]

solve_game("AKHIORWA", 1980.0)
