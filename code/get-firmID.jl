using CSV
using DataFrames
using Statistics

dataFolder = "C:\\Users\\18579\\GitHub\\EnvRegCement\\data\\"
pcafiles = readdir(dataFolder)[(readdir(dataFolder) .> "p") .* (readdir(dataFolder) .< "q")]

# Firm ID creation
dfNames = CSV.read(dataFolder * pcafiles[1], header=2)
dropmissing!(dfNames, :Company)
dfNames = by(dfNames, :Company, N = :Year => sum)
dfNames[:firmID] = 1:size(dfNames,1)

dFirmtoID = Dict()
for i in 1:size(dfNames, 1)
    dFirmtoID[dfNames[:Company][i]] = dfNames[:firmID][i]
end

function firmtoID(firm)

    if typeof(firm) == Missing
        return missing
    else
        return get(dFirmtoID, firm, maximum(values(dFirmtoID))+1)
    end
end
