
"""
	pdlag(df::AbstractDataFrame, PID::Symbol, TID::Symbol)

	This function returns the one-period lagged transformation of the dataframe.
	It uses a panel ID to perform the transformation panel wise and a temporal
	ID which is used to determine the order. The output is a dataset with only
	the observations that had their one-period lagged observations available,
	keeping the orginal colnames and adding the lagged variables as "colname_m1".
"""
function pdlag(df::AbstractDataFrame,
        PID::Symbol,
        TID::Symbol)

    varlist = names(df)
    allowmissing!(df) # Support missing values
    sort!(df, (PID, TID)) # Sort by PID, then by TID
    categorical!(df) # ???

    # Create list of rows that have their lagged observation
    # available (ex: (false, true, false) if TID = (1994, 1995, 1997))
    dfGaps = by(df, PID) do subdf

        return subdf[TID] .== vcat(false, subdf[TID][1:end-1]) .+ 1.0

    end
    vValidObs = dfGaps[:x1]

    # Shift values to their next observation, creating a "_m1" column:
    categorical = setdiff(names(df)[broadcast(<:, eltypes(df), AbstractCategoricalVector)], [PID, TID])
    todiff = df[:, union([PID], setdiff(names(df), union([TID], categorical)))]
    todiff = by(todiff, PID) do subdf # for each group
        if size(subdf, 1) == 1 # if only one observation
            output = subdf[:,2:end] # on dataset but group col
            for (name, col) ∈ eachcol(output, true)
                output[Symbol(String(name)*"_m1")] = missing
            end
        else
            output = subdf[:,2:end] # on dataset but group col
            for (name, col) ∈ eachcol(output, true)
                output[Symbol(String(name)*"_m1")] = vcat(missing, col[1:end-1])
            end
        end
        return output
    end
    output = hcat(df[[PID, TID]], todiff, df[categorical], makeunique=true)

    # Display the shifted dataset with new cols and only valid obs:
    output = output[vValidObs, vcat(1:2, length(varlist)+2:end) ]

    return output

end
