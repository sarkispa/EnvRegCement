function solve_game_mcp(mkt, year, params)

    δ_1, δ_2, ν = params
    #ν = exp(ν_c)/(1 + exp(ν_c))

    vFirms = dMkttoFirms[mkt, year]
    # Cournot game
    ## Model creation
    m = MCPModel()

    ## Choice variables (quantity)
    @variable(m, q[j in vFirms] >= 0.0, start=dProd[[j, year, mkt]])#dCap[[j, year, mkt]] >=

    ## Parameters
    @mapping(m, K[j in vFirms], dCap[[j, year, mkt]])
    ## Intermediate expressions
    @mapping(m, Q, sum(q[i] for i in vFirms)) # Market quantity
    @mapping(m, s[j in vFirms], q[j] /  Q) # Product shares
    @mapping(m, P, exp(-dα_0[mkt]/α_1) * Q^(1/α_1) ) # Market price
    @mapping(m, MR[j in vFirms], P*(1 + s[j]/α_1) )
    @mapping(m, MC[j in vFirms], δ_1 + 2 * δ_2 * (q[j] - ν * K[j]) * (1 / (1 + exp(-100 * (q[j] - ν * K[j])))) )
    @mapping(m, FOC[j in vFirms], MR[j] - MC[j] )

    ## Complementarity conditions
    @complementarity(m, FOC, q)

    ## Solver options
    PATHSolver.options(convergence_tolerance=1e-5, output=:no, time_limit=360, cumulative_iteration_limit=100)
    status = solveMCP(m)
    x = @show result_value.(q)
    return [x[i] for i in vFirms]
end
