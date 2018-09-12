function [raw, diagndx] = checkDiagPlot(RSK, diagnostic, direction, castidx)

raw = RSK; 
diagndx = getdataindex(RSK, diagnostic, direction);

if any(strcmp({RSK.data.direction} ,'down')) && any(strcmp({RSK.data.direction} ,'up')) && (strcmp('both',direction) || isempty(direction))
    diagndx = getdataindex(RSK, diagnostic, 'down');
end

if any(~ismember(diagndx, castidx))
    error('Requested profile for diagnostic plot is not processed.')
end

end