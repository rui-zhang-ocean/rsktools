function [RSKdown, downidx] = RSKselectdowncast(RSK)

% RSKselectdowncast - Selects the datafields that have a increasing pressure.
%
% Syntax:  [RSKdown, isDown] = RSKselectdowncast(RSK)
%
% This function only keeps the downcasts in the RSK and returns the index of
% the downcasts from the input RSK structure.
%
% Inputs:
%    RSK - The input RSK structure
%
% Outputs:
%    RSKdown - The RSK structure only containing upcasts.
%
%    downidx - The index of the data fields from the input RSK structure
%          are downcasts.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-25

Pcol = getchannelindex(RSK, 'Pressure');
ndata = length(RSK.data);

downidx = NaN(ndata, 1);
for ndx = 1:ndata
    pressure = RSK.data(ndx).values(:, Pcol);
    downidx(ndx) = getcastdirection(pressure, 'down');
end

RSKdown.data = RSK.data(logical(downidx));

end