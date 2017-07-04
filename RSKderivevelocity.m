function RSK = RSKderivevelocity(RSK, varargin)

%RSKcalculatevelocity - Calculate velocity from depth and time.
%
% Syntax:  [RSK] = RSKcalculatevelocity(RSK, [OPTIONS])
% 
% Differenciates depth to estimate the profiling speed. The depth channel
% is first smoothed with a 'windowLength' running average to reduce noise.
%
% Inputs: 
%   [Required] - RSK - Structure containing the logger metadata and data
%
%   [Optional] - profile - Profile number. Defaults to all profiles.
%
%                direction - 'up' for upcast, 'down' for downcast, or
%                      'both' for all. Defaults to all directions
%                       available.
%
%                 windowLength - The total size of the filter window used
%                       to filter depth. Must be odd. Default is 3.
%
% Outputs:
%    RSK - RSK structure containing the velocity data.
%
% See also: RSKremoveloops, calculatevelocity.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-07-04

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'windowLength', 3, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
profile = p.Results.profile;
direction = p.Results.direction;
windowLength = p.Results.windowLength;



try
    Dcol = getchannelindex(RSK, 'Depth');
catch
    error('RSKcalculatevelocity requires a depth channel to calculate velocity (m/s). Use RSKderivedepth...');
end



RSK = addchannelmetadata(RSK, 'Velocity', 'm/s');
Vcol = getchannelindex(RSK, 'Velocity');



castidx = getdataindex(RSK, profile, direction);
for ndx = castidx
    d = RSK.data(ndx).values(:,Dcol);
    depth = runavg(d, windowLength, 'nan');
    time = RSK.data(ndx).tstamp;
    vel = calculatevelocity(depth, time);
    
    RSK.data(ndx).values(:,Vcol)  = vel;
end



logentry = ['Velocity calculated from depth filtered with a windowLength of ' num2str(windowLength) ' samples.'];
RSK = RSKappendtolog(RSK, logentry);
end


