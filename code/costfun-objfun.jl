function objectivefun(params)
    resids = []
    for mkt in vMkts
        for year in vYears
            sol = solve_game_mcp(mkt, year, params)
            vProd = [dProd[[i, year, mkt]] for i in dMkttoFirms[mkt, year]]
            push!(resids, (sol .- vProd).^2 )
        end
    end
    return sum(vcat(resids...))/length(vcat(resids...))
end
