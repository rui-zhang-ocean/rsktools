function RSK = RSKreadprofiles(RSK, profileNum, direction)

% RSKreadprofiles - Read individual profiles (e.g. upcast and
%                   downcast) from an rsk file.
%
% Syntax:  RSK = RSKreadprofiles(RSK, profileNum, direction)
% 
% Reads profiles, including up and down casts, from the events
% contained in an rsk file. The profiles are written as fields in a
% structure array, divided into upcast and downcast fields, which can
% be indexed individually.
%
% The profile events are parsed from the events table using the following types:
%   33 - Begin upcast
%   34 - Begin downcast
%   35 - End of profile cast
%
% Currently the function assumes that upcasts and downcasts come in
% pairs, as would be recorded by a continuously recording
% logger. Future versions may be better at parsing more complicated
% deployments, such as thresholds or scheduled profiles.
% 
% Inputs: 
%    RSK - Structure containing the logger data read
%                     from the RSK file.
%
%    profileNum - vector identifying the profile numbers to read. This
%          can be used to read only a subset of all the profiles.
%
%    direction - `up` for upcast, `down` for downcast, or `both` for
%          all. Default is `down`.
%
% Outputs:
%    RSK - RSK structure containing individual profiles
%
% Examples:
%
%    rsk = RSKopen('profiles.rsk');
%
%    % read all profiles
%    rsk = RSKreadprofiles(rsk);
%
%    % read selective upcasts
%    rsk = RSKreadprofiles(rsk, [1 3 10], 'up');
%
% See also: RSKreaddata, RSKreadevents, RSKplotprofiles
%
% Author: RBR Global Inc. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: http://www.rbr-global.com
% Last revision: 2015-10-06

if ~isfield(RSK, 'profiles') 
    error('No profiles events in this RSK');
end

if nargin == 1
    profileNum = 1:length(RSK.profiles.downcast.tstart); % default read all profiles
    direction = 'down'; % default read downcasts
elseif nargin == 2
    direction = 'down';
end
if isempty(profileNum) profileNum = 1:length(RSK.profiles.downcast.tstart); end
if isempty(direction) type = 'down'; end

nup = length(profileNum);
ndown = length(profileNum);
    
% initialize upcast and downcast structures
RSK.profiles.downcast.data(ndown).tstamp = [];
RSK.profiles.downcast.data(ndown).values = [];
RSK.profiles.upcast.data(nup).tstamp = [];
RSK.profiles.upcast.data(nup).values = [];

if strcmp(direction, 'down') | strcmp(direction, 'both')
% loop through downcasts
    ii = 1;
    for i=profileNum
        tstart = RSK.profiles.downcast.tstart(i);
        tend = RSK.profiles.downcast.tend(i);
        tmp = RSKreaddata(RSK, tstart, tend);
        RSK.profiles.downcast.data(ii).tstamp = tmp.data.tstamp;
        RSK.profiles.downcast.data(ii).values = tmp.data.values;
        ii = ii + 1;
    end
    RSK.channels = tmp.channels;
end

if strcmp(direction, 'up') | strcmp(direction, 'both')
% loop through upcasts
    ii = 1;
    for i=profileNum
        tstart = RSK.profiles.upcast.tstart(i);
        tend = RSK.profiles.upcast.tend(i);
        tmp = RSKreaddata(RSK, tstart, tend);
        RSK.profiles.upcast.data(ii).tstamp = tmp.data.tstamp;
        RSK.profiles.upcast.data(ii).values = tmp.data.values;
        ii = ii + 1;
    end
    RSK.channels = tmp.channels;
end