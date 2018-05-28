function RSK = RSKfindprofiles(RSK, varargin)

% RSKfindprofiles - Find profiles in a time series using pressure
%                  and conductivity data (if it exists). 
%
% Syntax:  [RSK] = RSKfindprofiles(RSK, [OPTIONS])
% 
% Implements the algorithm used by the logger and Ruskin to find
% upcasts or downcasts by looking for pressure reversals.  The
% algorithm distinguishes between upcasts and downcasts, and stores
% the start and end time for each as 'tstart' and 'tend' in the
% profile field of the RSK structure. If RSK.profiles already exists, it
% will be removed and replaced.
%
% Inputs: 
%    [Required] - RSK - Structure containing logger metadata and data
%               
%    [Optional] - pressureThreshold - Minimum pressure difference 
%                       required to detect a profile. The default is
%                       3 dbar, which is the same as the logger. 
%                       Consider reducing the pressure difference for
%                       very shallow profiles.  
%
%                 conductivityThreshold - Threshold value that indicates
%                       whether the sensor is out of water. Default is 
%                       0.05 mS/cm.  In very fresh water it may help to
%                       reduce this value.      
%
% Output: 
%   RSK - Structure containing profiles field with the profile metadata.
%         Use RSKreadprofiles to parse and organize the time series into 
%         profiles by applying the start and end times.
%
% Example:
%    RSK = RSKopen(fname);
%    RSK = RSKreaddata(RSK);
%    RSK = RSKfindprofiles(RSK, 'pressureThreshold', 1);
%
% See also: RSKreadprofiles, RSKgetprofiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2018-05-07

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addParameter(p, 'pressureThreshold', 3, @isnumeric);
addParameter(p, 'conductivityThreshold', 0.05, @isnumeric);
parse(p, RSK, varargin{:})

RSK = p.Results.RSK;
pressureThreshold = p.Results.pressureThreshold;
conductivityThreshold = p.Results.conductivityThreshold;



if isfield(RSK, 'profiles')
    RSK = rmfield(RSK, 'profiles');
end



%% Set up values
Pcol = getchannelindex(RSK, 'Pressure');
pressure = RSK.data.values(:, Pcol);
timestamp = RSK.data.tstamp;

% If conductivity is present it will be used to detect when the logger is
% out of the water.
try
    Ccol = getchannelindex(RSK, 'Conductivity');
    conductivity = RSK.data.values(:, Ccol);
catch
    conductivity = [];
end



%% Run profile detection
[wwevt] = detectprofiles(pressure, timestamp, conductivity, pressureThreshold, conductivityThreshold);
if size(wwevt,1) < 2
    disp('No profiles were detected in this dataset with the given parameters.')
    return
end



%% Use the events to establish profile start and end times.
% Event 1 is a downcast start
downstart = wwevt(wwevt(:,2) == 1,1);
% Event 2 is a upcast start
upstart = wwevt(wwevt(:,2) == 2,1);
% Event 3 is out of water

u=1;% up index
d=1;% down index
for ndx = 2:length(wwevt)
    t = find(timestamp == wwevt(ndx,1),1);
    if wwevt(ndx-1,2) ~= 3
        if wwevt(ndx,2) == 1
            % Upcast end is the sample of a downcast start
            upend(u) = timestamp(t);
            u = u+1;

        elseif wwevt(ndx,2) == 2
            % Downcast end is the sample of a upcast start
            downend(d) = timestamp(t);
            d = d+1;  
        end

    end
    if wwevt(ndx,2) == 3
        if wwevt(ndx-1,2) == 1
            % Event 3 ends a downcast if that was the last event
            downend(d) = timestamp(t);
            d = d+1;
            
         elseif wwevt(ndx-1,2) == 2
             % Event 3 ends a upcast if that was the last event
            upend(u) = timestamp(t);
            u = u+1;
        end
    end
end

% Finish the last profile
if wwevt(end,2) == 1
    downend(d) = timestamp(end);
elseif wwevt(end,2) == 2
    upend(u) = timestamp(end);
end



RSK.profiles.upcast.tstart = upstart;
RSK.profiles.upcast.tend = upend';
RSK.profiles.downcast.tstart = downstart;
RSK.profiles.downcast.tend = downend';

% Remove region.description, regionGeoData and regionComment field if exist
if isfield(RSK.region,'description') || isfield(RSK,'regionGeoData') || isfield(RSK,'regionComment');
    warning('Annotations from Ruskin is deleted due to potential mismatch between previous and current detected profiles.');
end

if isfield(RSK.region,'description');
    RSK.region = rmfield(RSK.region,'description');
end
if isfield(RSK,'regionGeoData');
    RSK = rmfield(RSK,'regionGeoData');
end
if isfield(RSK,'regionComment');
    RSK = rmfield(RSK,'regionComment');
end

% Check down or upcast comes first
if upstart(1) > downstart(1)
    firstdir = RSK.profiles.downcast;
    lastdir = RSK.profiles.upcast;
    firstType = 'DOWN';
    lastType = 'UP';
else
    firstdir = RSK.profiles.upcast;
    lastdir = RSK.profiles.downcast;
    firstType = 'UP';
    lastType = 'DOWN';
end

% Remove RSK.region and RSK.regionCast
if isfield(RSK, 'region')
    RSK = rmfield(RSK, 'region');
end
if isfield(RSK, 'regionCast')
    RSK = rmfield(RSK, 'regionCast');
end

% Create new RSK.region and RSK.regionCast
for n = 1:length(upstart)
    nprofile = n*3-2;
    RSK.region(nprofile).regionID = nprofile;
    RSK.region(nprofile).type = 'PROFILE';
    RSK.region(nprofile).tstamp1 = firstdir.tstart(n);
    RSK.region(nprofile).tstamp2 = lastdir.tend(n);
    
    RSK.region(nprofile+1).regionID = nprofile+1;
    RSK.region(nprofile+1).type = 'CAST'; 
    RSK.region(nprofile+1).tstamp1 = firstdir.tstart(n);
    RSK.region(nprofile+1).tstamp2 = firstdir.tend(n);

    RSK.region(nprofile+2).regionID = nprofile+2;    
    RSK.region(nprofile+2).type = 'CAST';
    RSK.region(nprofile+2).tstamp1 = lastdir.tstart(n);
    RSK.region(nprofile+2).tstamp2 = lastdir.tend(n);
    
    nregionCast = n*2-1;
    RSK.regionCast(nregionCast).regionID = nprofile+1;
    RSK.regionCast(nregionCast).regionProfileID = nprofile;
    RSK.regionCast(nregionCast).type = firstType;
    RSK.regionCast(nregionCast+1).regionID = nprofile+2;
    RSK.regionCast(nregionCast+1).regionProfileID = nprofile;
    RSK.regionCast(nregionCast+1).type = lastType;
end

end
            