function RSK = readheaderEPdesktop(RSK)

% readheaderEPdesktop - read tables that are populated in an 'EPdesktop' file.
%
% Syntax:  [RSK] = readheaderEPdesktop(RSK)
%
% readheaderEPdesktop is a RSKtools helper function that opens the populated
% tables of 'EPdesktop' files. 
% These tables are channels, epochs, schedules, deployments, instruments,
% instrumentsChannels and thumbnailData. If data is available it
% will open appSettings, datasets, datasetDeployments, parameters,
% parameterKeys and geodata. 
%
% Inputs:
%    RSK - 'EPdesktop' file opened using RSKopen.m
%
% Outputs:
%    RSK - Structure containing the logger metadata and thumbnail
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-03-14

%% Set up version variables
[~, vsnMajor, vsnMinor, vsnPatch] = RSKver(RSK);

%% Tables that are definitely in 'EPdesktop'

RSK.channels = mksqlite('select shortName,longName,units from channels');

RSK.epochs = mksqlite('select deploymentID,startTime/1.0 as startTime, endTime/1.0 as endTime from epochs');
RSK.epochs.startTime = RSKtime2datenum(RSK.epochs.startTime);
RSK.epochs.endTime = RSKtime2datenum(RSK.epochs.endTime);

RSK.schedules = mksqlite('select * from schedules');

RSK.deployments = mksqlite('select * from deployments');

RSK.instruments = mksqlite('select * from instruments');


RSK.thumbnailData = RSKreadthumbnail;


%% List all tables present
tables = mksqlite('SELECT name FROM sqlite_master WHERE type="table"');


%% Remove non marine channels
results = mksqlite('select isDerived from channels');

try
    RSK.instrumentChannels = mksqlite('select * from instrumentChannels');
    isMeasured = ~[RSK.instrumentChannels.channelStatus];% hidden and derived channels should have a non-zero channelStatus
    RSK.instrumentChannels(~isMeasured) = []; 
catch
    
    isMeasured = ~[results.isDerived]; % some files may not have channelStatus
end

RSK.channels(~isMeasured) = [];  


%% Load calibration
%As of RSK v1.13.4 parameterKeys is a table
if any(strcmpi({tables.name}, 'parameterKeys'))
    RSK.parameterKeys = mksqlite('select * from parameterKeys');
end


%% Tables that may or may not be in 'EPdesktop'
if any(strcmpi({tables.name}, 'geodata'))
    RSK = RSKreadgeodata(RSK);
end


% Parameter table is empty if data is from Mobile Ruskin.
if any(strcmpi({tables.name}, 'parameters')) && ~strcmpi(RSK.dbInfo(1).type, 'EasyParse') && ~strcmpi(RSK.dbInfo(1).type, 'skinny') 
    RSK.parameters = mksqlite('select * from parameters');
end

if any(strcmpi({tables.name}, 'datasets')) && ~strcmpi(RSK.dbInfo(1).type, 'EasyParse')
    RSK.datasets = mksqlite('select * from datasets');
end

if any(strcmpi({tables.name}, 'datasetDeployments')) && ~strcmpi(RSK.dbInfo(1).type, 'EasyParse')
    RSK.datasetDeployments = mksqlite('select * from datasetDeployments');     
end


end

