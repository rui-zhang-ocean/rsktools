function [RSK, isDerived] = removenonmarinechannels(RSK)

% removenonmarinechannels - Remove hidden or derived channels.
%
% Syntax:  [RSK, isDerived] = removenonmarinechannels(RSK)
%
% Removes the hidden or derived channels from the channels table and
% returns a logical index vector. They are also removed from
% instrumentChannels if the field exists. 
%
% Inputs:
%    RSK - Structure
%
% Outputs:
%    RSK - Structure with only marine channels.
%
%    isDerived - Logical index describing which channels are non-marine.
%
% See also: RSKopen, readheaderfull.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-09-26


p = inputParser;
addRequired(p, 'RSK', @isstruct);
parse(p, RSK)

RSK = p.Results.RSK;


tables = doSelect(RSK, 'SELECT name FROM sqlite_master WHERE type="table"');
if any(strcmpi({tables.name}, 'instrumentChannels'))
    RSK.instrumentChannels = doSelect(RSK, 'select * from instrumentChannels');
end   

if ~(strcmp(RSK.dbInfo(end).type, 'EPdesktop') || strcmp(RSK.dbInfo(end).type, 'skinny'))
    if iscompatibleversion(RSK, 1, 8, 9) && ~strcmp(RSK.dbInfo(end).type, 'EP')
        if RSK.toolSettings.readHiddenChannels
            isDerived = logical([RSK.instrumentChannels.channelStatus] == 4);% derived channels have a '4' channelStatus
        else
            isDerived = logical([RSK.instrumentChannels.channelStatus]);% hidden and derived channels have a non-zero channelStatus
        end
        RSK.instrumentChannels(isDerived) = [];
    else
        results = doSelect(RSK, 'select isDerived from channels');
        isDerived = logical([results.isDerived])'; 
    end
else
    isDerived = false(length(RSK.channels));
end


if length(RSK.channels) == length(isDerived)
    RSK.channels(isDerived) = [];
end


end


