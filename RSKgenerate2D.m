function RSK = RSKgenerate2D(RSK, varargin)

% RSKgenerate2D - Generate data for 2D plot by RSKimages.
%
% Syntax:  RSK = RSKgenerate2D(RSK, [OPTIONS])      
%
% Generate data with dimensions in time, reference channel and number of 
% channels stored in RSK.im.data for visualization use of RSKimages. All 
% data elements must have identical reference channel samples. 
% Use RSKbinaverage.m to achieve this. 
%
% Note: Calling RSKimages may overwrite RSK.im field if RSKimages allows
% RSK as outputs.
%
% Inputs:
%   [Required] - RSK - Structure, with profiles as read using RSKreadprofiles.
%
%   [Optional] - channel - Longname of channel to generate data, can be 
%                      multiple in a cell, if no value is given it will use
%                      all channels.
%
%                profile - Profile numbers to use. Default is to use all
%                      available profiles.  
%
%                direction - 'up' for upcast, 'down' for downcast. Default
%                      is down.
%
%                reference - Channel that will be used as y dimension. 
%                      Default is 'Sea Pressure', can be any other channel.
%
% Output:
%     RSK - Structure, with RSK.im field containing data, channel, profile,
%     direction and reference channel information.
%
% Example: 
%     rsk = RSKgenerate2D(rsk,'channel',{'Temperature','Conductivity'},'direction','down');
%
% See also: RSKbinaverage, RSKimages.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-10-17


validDirections = {'down', 'up'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', 'down', checkDirection);
addParameter(p, 'reference', 'Sea Pressure', @ischar);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;
reference = p.Results.reference;


castidx = getdataindex(RSK, profile, direction);
chanCol = [];
channels = cellchannelnames(RSK, channel);
for chan = channels
    chanCol = [chanCol getchannelindex(RSK, chan{1})];
end
YCol = getchannelindex(RSK, reference);

for ndx = 1:length(castidx)-1
    if length(RSK.data(castidx(ndx)).values(:,YCol)) == length(RSK.data(castidx(ndx+1)).values(:,YCol));
        binCenter = RSK.data(castidx(ndx)).values(:,YCol);
    else 
        error('The reference channel data of all the selected profiles must be identical. Use RSKbinaverage.m for selected cast direction.')
    end
end

RSK.im.x = cellfun( @(x)  min(x), {RSK.data(castidx).tstamp});
RSK.im.y = binCenter;
RSK.im.channel = chanCol;
if isempty(profile)
    RSK.im.profile = unique([RSK.data.profilenumber]);
else
    RSK.im.profile = profile;
end
RSK.im.direction = direction;
RSK.im.data = NaN(length(binCenter),length(castidx),length(chanCol));
RSK.im.reference = reference;

k = 1;
for c = chanCol
    binValues = NaN(length(binCenter), length(castidx));
    for ndx = 1:length(castidx)
        binValues(:,ndx) = RSK.data(castidx(ndx)).values(:,c);
    end
    RSK.im.data(:,:,k) = binValues;
    k = k + 1;
end
end

