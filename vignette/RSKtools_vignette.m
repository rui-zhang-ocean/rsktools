%% RSKtools for Matlab access to RBR data
% RSKtools v2.0.0;
% RBR Ltd. Ottawa ON, Canada;
% support@rbr-global.com;
% 2017-07-06

%% Introduction 
% |RSKtools| provides some convenience functions for common data
% extraction (e.g. extracting profiles from a continuous dataset) and
% visualisation (plotting individual profiles). From this version on, we
% are expanding on our post-processing functions. For plans for future
% additions, see the Future plans section. 

%% Installing
% The latest stable version of |RSKtools| can be found at <http://www.rbr-global.com/support/matlab-tools>.
% 
% * Unzip the archive (to |~/matlab/RSKtools|, for instance)
% * Add the folder to your path inside matlab (|addpath ~/matlab/RSKtools| or some nifty GUI thing)
% * type |help RSKtools| to get an overview and take a look at the examples.

  
%% Examples of use
% <html><h3>Loading files</h3></html>
% 
% A connection to the database must be made to work with an RSK file using
% |RSKtools|. This connection is made using the |RSKopen()| function. Note
% that |RSKopen| does not actually read the data, but reads a /thumbnail/ of
% the data, which is up to 4000 samples long. The structure returned after
% opening an RSK looks something like:

file = 'sample.rsk';
rsk = RSKopen(file)

%%
% To read the actual data, we use the |RSKreaddata()| function. If given
% with one input argument (the variable name of the RSK structure) it will
% read the entire data set. Because RSK files can store a large amount of 
% data, it may be preferable to read a subset of the data, specified using
% a start and end time (in Matlab |datenum| format, which is defined as the
% number of days since January 0, 0000). 

t1 = datenum(2014, 05, 03);
t2 = datenum(2014, 05, 04);
rsk = RSKreaddata(rsk, 't1', t1, 't2', t2);

%%
% Note that the data structure can be found in the structure at:

rsk.data        

%% 
% In this example, because the instrument is a "CTD"-type instrument, we
% can derive a new channel called |Salinity|. |RSKderivesalinity| adds the
% data to all the appropriate places (using the Practical Salinity Scale).
% The salinity calculation is performed by the
% <http://teos-10.org/software.htm TEOS-10>]] package, which is available
% from <http://teos-10.org/software.htm>.  

rsk = RSKderivesalinity(rsk);
rsk.channels.longName

%% Working with profiles
% Profiling loggers with recent versions of firmware contain the
% ability to detect and log profile "events" automatically; these are
% denoted as "downcasts" and "upcasts". The function |RSKreadprofiles()|
% extracts individual profiles from the raw data, based on the previously
% identified profiling events. Then, quick plots of the profiles can be
% made using the |RSKplotprofiles()| function.
%
% If profiles have not been detected by the logger or Ruskin. The function
% |RSKfindprofiles()| can be used. The pressureThreshold argument, which
% determines the pressure reversal required to trigger a new profile, and
% the conductivityThreshold arguement, which determines if the logger is
% out of the water, can be adjusted for short or fresh water profiles.

% load the second to tenth profiles in both directions (upcast and downcast)
rsk = RSKreadprofiles(rsk, 'profile', 2:10, 'direction', 'both');
rsk = RSKderivesalinity(rsk);

% plot the upcasts of Conductivity, Temperature and Salinity
handles = RSKplotprofiles(rsk, 'channel', {'conductivity', 'temperature','salinity'}, 'direction', 'up');



%% Customizing plots
% All plotting functions return a handle which enables access to the lines
% in the plot. The output is a matrix containing a column for each
% channel subplot and a row for each profile. 
handles

% To increase the linewidth of the first profile in all subplots
(set(handles(1,:),{'linewidth'},{5}));

%% See RSKtools_vignette2
% A second vignette is available for information on getting started with
% post-processing functions.

%% Future plans
% * Function to write metadata, log and data to a file.
% * Wave processing functions.
% * A TS plotting function.

%% About this document
% This document was created using
% <http://www.mathworks.com/help/matlab/matlab_prog/marking-up-matlab-comments-for-publishing.html
% Matlab(TM) Markup Publishing>. To publish it as an HTML page, run the
% command:
%%
% 
%   publish('RSKtools_vignette.m');

%%
% See |help publish| for more document export options.