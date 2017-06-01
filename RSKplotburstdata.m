function handles = RSKplotburstdata(RSK)

% RSKplotburstdata - Plot summaries of logger burst data
%
% Syntax:  [handles] = RSKplotburstdata(RSK)
% 
% This generates a plot, similar to the thumbnail plot, only using the
% full 'burst data' that you read in, rather than just the thumbnail
% view.  It tries to be intelligent about the subplots and channel
% names, so you can get an idea of how to do better processing.
% 
% Inputs:
%    RSK - Structure containing the logger metadata and burst data
%
% Output:
%     handles - The line object of the plot.
%
% Example: 
%    RSK = RSKopen('sample.rsk');  
%    RSK = RSKreadburstdata(RSK);  
%    RSKplotdata(RSK);  
%
% See also: RSKplotthumbnail, RSKplotdata, RSKreadburstdata
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-01

field = 'burstdata';
if ~isfield(RSK, field)
    disp('You must read a section of burst data in first!');
    disp('Use RSKreadburstdata...')
    return
end

handles = channelsubplots(RSK, field);

end