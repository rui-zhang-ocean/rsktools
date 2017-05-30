function hdls = RSKplotdata(RSK, varargin)

% RSKplotdata - Plot summaries of logger data
%
% Syntax:  [hdls] = RSKplotdata(RSK, [OPTIONS])
% 
% This generates a plot, similar to the thumbnail plot, only using the
% full 'data' that you read in.
% 
% Inputs:
%    [Required] - RSK - Structure containing the logger metadata and data
%
%    [Optional] - channel - channel to plots, can be multiple in a cell, if no value is
%                       given it will plot all channels.
%
%                  profile - number indicating the profile to plot. Default
%                       is 1.
% 
%                 direction - 'up' for upcast, 'down' for downcast. Default
%                       is 'down'. 
%
% Output:
%     hdls - The line object of the plot.
%
% Example: 
%    RSK = RSKopen('sample.rsk');   
%    RSK = RSKreaddata(RSK);  
%    RSKplotdata(RSK);
%    -OR-
%    hdls = RSKplotdata(RSK, 'channel', {'Temperature', 'Conductivity'})
%
% See also: RSKplotprofiles, RSKplotburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-30

validDirections = {'down', 'up'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'channel', 'all');
addParameter(p, 'profile', 1);
addParameter(p, 'direction', [], checkDirection);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
profile = p.Results.profile;
direction = p.Results.direction;



if ~isfield(RSK,'data')
    disp('You must read a section of data in first!');
    disp('Use RSKreaddata...')
    hdls = [];
    return
end

castidx = getdataindex(RSK, profile, direction);
if size(castidx,2) ~= 1 
    disp('RSKplotdata can only plot one cast, use RSKplotprofiles...');
    return
end
    


chanCol = [];
if ~strcmp(channel, 'all')
    channels = cellchannelnames(RSK, channel);
    for chan = channels
        chanCol = [chanCol getchannelindex(RSK, chan{1})];
    end
end
hdls = channelsubplots(RSK, 'data', 'chanCol', chanCol, 'castidx', castidx);

end


