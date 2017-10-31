# RSKtools

Current stable version: 2.2.0 (2017-11-01)

RSKtools is a Matlab toolbox designed to open RSK SQLite files
generated by RBR instruments. This repository is for the development
version of the toolbox -- for the "officially" distributed version go
to:

[http://www.rbr-global.com/support/matlab-tools](http://www.rbr-global.com/support/matlab-tools)

Please note, RSKtools requires MATLAB R2013b or later, and we
recommend installing the freely
available [TEOS-10 GSW](http://www.teos-10.org/software.htm)
and
[cmocean](https://www.mathworks.com/matlabcentral/fileexchange/57773-cmocean-perceptually-uniform-colormaps) packages.


## What can RSKtools do?

* Open RSK files:
```matlab
r = RSKopen('sample.rsk');
```

* Plot time series:
```matlab
RSKplotdata(r);
```

* Low-pass filter selected channels:
```matlab
r = RSKsmooth(r,{'Conductivity','Temperature'},'windowLength',5);
```

* And lots of other stuff like automatic cast detection, sensor time
  alignment, and bin averaging.

## How do I get set up?

* Unzip the archive (to `~/matlab/RSKtools`, for instance).
* Add the folder to your Matlab path  (`addpath ~/matlab/RSKtools` or `pathtool` to launch a gui).
* Type `help RSKtools` to get an overview and take a look at the examples.
* Read the [RSKtools User Manual](https://docs.rbr-global.com/rsktools).
* Check out the [Getting started](https://rbr-global.com/wp-content/uploads/2017/08/VignetteStandard.pdf)
  and [Post-processing](https://rbr-global.com/wp-content/uploads/2017/08/VignettePostProcessing.pdf) vignettes.

## A note on calculation of salinity

A typical RBR CTD (e.g., Concerto or Maestro) has sensors to measure
*in situ* pressure, temperature, and electrical conductivity. These
three variables are required to calculate seawater salinity, either
using the Practical Salinity Scale (PSS-78,
see
[Unesco, 1981](http://unesdoc.unesco.org/images/0004/000461/046148eb.pdf)),
or Absolute Salinity based on the Thermodynamic Equation of Seawater
2010 (see [IOC, SCOR and IAPSO, 2010](http://www.teos-10.org)).  If
the [TEOS-10 GSW](http://www.teos-10.org/software.htm) Matlab toolbox
is installed, users can call the `RSKtools` function
`RSKderivesalinity` to calculate Practical Salinity and store it as a 
channel in the RSK structure.


## Contribution guidelines

* Feel free to add improvements at any time:
    * by forking and sending a pull request
    * by emailing patches or changes to `support@rbr-global.com`
* Write to `support@rbr-global.com` if you need help

## Changes

* Version 2.2.0 (2017-11-01)
    - New function `RSKcorrecthold` for correcting A2D zero-order hold points.
	- New function `RSKaddchannel` for adding new variable into exsiting rsk structure.
	- Improved algorithm for RSKremoveloops.
    - Added `direction` and `profilenumber` fields to rsk.data with profiles.
    - RSKplotprofiles enables different linestyle for upcast and downcast.
    - RSKplotprofiles enables pressure as Y-axis.
    - Add `Optode Temperature` channel name.

* Version 2.1.0 (2017-08-31)
    - New function `RSKtrim` for pruning data
	- Improved vignettes
	- Option to plot against depth in `RSKplotprofiles`
	- Fixed `RSKplotprofiles` for compatibility with pre-R2014b
	- Fixed `RSKcalculateCTlag` and `RSKdespike` for compatibility with pre-R2015a
	- pressureRange option in `RSKcalculateCTlag` now seapressureRange
	- Removed dependence on Financial Toolbox in `RSKbinaverage`
	- Fixed bug occurring when RSK file has multiple dissolved oxygen channels
	- Enumerate channels with duplicate longName

* Version 2.0.0 (2017-07-07)
    - All optional input arguments are name-value pair
    - Rename burstdata field to burstData
    - Add post-processing functions for smoothing, channel alignment, etc.
	- RSKtools data processing log recorded in RSK structure 
    - Add 2D plotting function, `RSKplot2D`
    - RSKplotprofiles contains a subplot for each channel
    - Add option to plot selected channels to plotting functions
	- Plotting functions output handles to line objects for customization
    - Relocate profiling data from the profiles field to the data field
    - Added function to calculate Practical Salinity, `RSKderivesalinity`
    - Added function to calculate sea pressure from total pressure, `RSKderiveseapressure`
    - Added function to calculate depth, `RSKderivedepth`
    - Added function to calculate profiling speed, `RSKderivevelocity`
	- Cast detection function added, `RSKfindprofiles`

* Version 1.5.3 (2017-06-07)
    - Use atmospheric pressure in database if available
    - Improve channel table reading by using instrumentChannels
    - Change geodata warning to a display message
    - Only read current parameter values in parameter table

* Version 1.5.2 (2017-05-23)
    - Update RSKconstants.m
    - Fix bug with opening files that are not in current directory

* Version 1.5.1 (2017-05-18)
    - Add RSKderivedepth function
    - Add RSKderiveseapressure function
    - Add channel longName change for doxy09
    - Add filename check to RSKopen
    - Fix bug with dbInfo 1.13.0
    - Add channel argument to RSKplotdata
    - Fix bug introduced in 1.5.0 in RSKreaddata from dbInfo.version < 1.8.9.

* Version 1.5.0 (2017-03-30)
    - Move salinity derivation from RSKreaddata to RSKderivesalinity
    - Move calibrations table reading from RSKopen to RSKreadcalibrations
    - Add RSKfirmwarever function
    - Add RSKsamplingperiod function
    - Add channel longName change for temp04, temp05, temp10 and temp13
    - Remove dataset and datasetDeployments fields
    - Fix bug with loading geodata
    - Support for RSK v1.13.8


* Version 1.4.6 (2017-01-18)
    - Remove non-marine channels from data table
    - Fix bugs that occured if RSKreaddata.m is run twice
    - Seperate profile metadata reading into a different fuction in RSKopen.m
    - Add option to enter UTCdelta for geodata
    - Remove channels units and longName from data table
    - Fix bug in data when reading in profile data


* Version 1.4.5 (2016-12-22)
    - Add more support for geodata
    - Add helper files to open different file types
    - Add function to read version of file


* Version 1.4.4 (2016-12-15)
    - Add support for geodata
    - Assure that non-marine channel stay hidden
    - Add RSK2MAT.m for legacy mat file users
    - Update support for coefficients and parameter tables


* Version 1.4.3 (2016-11-03)
    - Events structure does not read in notes
    - Fix dbInfo bug to read last entry
    - Support for RSK v1.13.4


* Version 1.4.2 (2016-10-20)
    - Changed removal of 'datasetID' to be case insensitive
    - Fix upcast/downcast type in RSKplotprofiles
    - Fix RSKreadprofile typo
    - Fix bug opening |rt instruments data


* Version 1.4.1 (2016-05-20)
    - Add RSKreadwavetxt to handle import wave text exports	
    - properly read "realtime" RSK files
    - don't plot hidden channels in profiles
    - Fix bug reading data table for RSK version >= 1.12.2
    - add info from `ranging` table to structure
    - mfile vignette using Matlab markup
  

* Version 1.4 (2015-11-30)
    - add support for profile events and profile plotting
    - supports TEOS-10 for calculation of salinity
    - improved documentation
  

* Version 1.3
    - compatible with RSK generated from an EasyParse (iOs format) logger


* Version 1.2

    - added linux 64 bit mksqlite library


* Version 1.1

    - added burst and event readers

