
function [RSK] = RSKalignchannel(RSK, channel, lag, varargin)

% RSKalignchannel - Align a channel using a specified lag.
%
% Syntax:  [RSK] = RSKalignchannel(RSK, channel, lag, [OPTIONS])
% 
% Applies a time lag to a specified channel. Typically used for
% conductivity to minimize salinity spiking from C/T mismatches when
% the sensors are moving through regions of high vertical gradients.
%
% Inputs: 
%    [Required] - RSK - The input RSK structure.
%
%                 channel - Longname of channel to align (e.g. temperature).
%
%                 lag - The lag (in samples) to apply to the channel.
%                       A negative lag shifts the channel backward in
%                       time (earlier), while a positive lag shifts
%                       the channel forward in time (later).  To apply
%                       a different lag to each data field, specify the
%                       lags in a vector.
%
%    [Optional] - profile - Optional profile number. Default is to operate
%                       on all of data's elements. 
%
%                 direction - 'up' for upcast, 'down' for downcast, or
%                       `both` for all. Default all directions available.
%
%                  shiftfill - The values that will fill the void left
%                        at the beginning or end of the time series; 'nan',
%                        fills the removed samples of the shifted channel
%                        with NaN, 'zeroorderhold' fills the removed
%                        samples of the shifted channels with the first or
%                        last value, 'mirror' fills the removed values with
%                        the reflection of the original end point, and
%                        'union' will remove the values of the OTHER
%                        channels that do not align with the shifted
%                        channel (note: this will reduce the size of values
%                        array by "lag" samples). 
%
% Outputs:
%    RSK - The RSK structure with aligned channel values.
%
% Example: 
%    rsk = RSKopen('file.rsk');
%    rsk = RSKreadprofiles(rsk, 1:10); % read first 10 downcasts
%
%   1. Temperature channel of first four profiles with the same lag value.
%    rsk = RSKalignchannel(rsk, 'temperature', 2, 'profile', 1:4);
%
%   2. Oxygen channel of first 4 profiles with profile-specific lags.
%    rsk = RSKalignchannel(rsk, 'Dissolved O', [2 1 -1 0], 'profile',1:4);
%
%   3. Conductivity channel from all downcasts with optimal lag calculated 
%      with RSKgetCTlag.m.
%    lags = RSKgetCTlag(rsk)
%    rsk = RSKalignchannel(rsk, 'Conductivity', lags);
%
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-05-31

validShiftfill = {'zeroorderhold', 'union', 'nan', 'mirror'};
checkShiftfill = @(x) any(validatestring(x,validShiftfill));

validDirections = {'down', 'up', 'both'};
checkDirection = @(x) any(validatestring(x,validDirections));

p = inputParser;
addRequired(p, 'RSK', @isstruct);
addRequired(p, 'channel', @ischar);
addRequired(p, 'lag', @isnumeric);
addParameter(p, 'profile', [], @isnumeric);
addParameter(p, 'direction', [], checkDirection);
addParameter(p, 'shiftfill', 'zeroorderhold', checkShiftfill);
parse(p, RSK, channel, lag, varargin{:})

RSK = p.Results.RSK;
channel = p.Results.channel;
lag = p.Results.lag;
profile = p.Results.profile;
direction = p.Results.direction;
shiftfill = p.Results.shiftfill;



castidx = getdataindex(RSK, profile, direction);
lags = checklag(lag, castidx);
channelCol = getchannelindex(RSK, channel);

counter = 0;
for ndx =  castidx
    counter = counter + 1;       
    channelData = RSK.data(ndx).values(:, channelCol);
    
    if strcmpi(shiftfill, 'union')
        channelShifted = shiftarray(channelData, lags(counter), 'zeroorderhold');
        RSK.data(ndx).values(:, channelCol) = channelShifted;
        if lags(counter) > 0 
            RSK.data(ndx).values = RSK.data(ndx).values(lags(counter)+1:end,:);
            RSK.data(ndx).tstamp = RSK.data(ndx).tstamp(lags(counter)+1:end);
        elseif lags(counter) < 0 
            RSK.data(ndx).values = RSK.data(ndx).values(1:end-lags(counter),:);
            RSK.data(ndx).tstamp = RSK.data(ndx).tstamp(1:end-lags(counter));
        end
    else 
        channelShifted = shiftarray(channelData, lags(counter), shiftfill);
        RSK.data(ndx).values(:, channelCol) = channelShifted;
    end

end



if length(lag) == 1
    logdata = logentrydata(RSK, profile, direction);
    logentry = [channel ' aligned using a ' num2str(lags(1)) ' sample lag and ' shiftfill ' shiftfill on ' logdata '.'];
    RSK = RSKappendtolog(RSK, logentry);
else
    for ndx = 1:length(castidx)
        logdata = logentrydata(RSK, profile, direction);
        logentry = [channel ' aligned using a ' num2str(lags(ndx)) ' sample lag and ' shiftfill ' shiftfill on ' logdata '.'];
        RSK = RSKappendtolog(RSK, logentry);
    end
end



%% Nested function
    function lags = checklag(lag, castidx)
    % A helper function used to check if the lag values are intergers and
    % either one for all profiles or one for each profiles.

        if ~isequal(fix(lag),lag),
            error('Lag values must be integers.')
        end

        if length(lag) == 1 && length(castidx) ~= 1
            lags = repmat(lag, 1, length(castidx));
        elseif length(lag) > 1 && length(lag) ~= length(castidx)
            error(['Length of lag must equal the number of profiles or be a ' ...
                   'single value']);
        else
            lags = lag;
        end

    end
end
