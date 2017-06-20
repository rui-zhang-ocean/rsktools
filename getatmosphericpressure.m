function pAtm = getatmosphericpressure(RSK)

%GETATMOSPHERICPRESSURE - Return the atmospheric pressure stored in RSK file.
%
% Syntax:  [pAtm] = getatmosphericpressure(RSK)
%
% Uses the parameterKeys or parameters field to find the atmospheric
% pressure, if it is not there or there is no parameters field a default
% value of 10.1235 dbar is used.
%
% Inputs:
%    RSK - Structure containing the logger metadata and data.
%
% Outputs:
%    pAtm - Atmospheric pressure in dbar.
%
% See also: RSKderiveseapressure.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-20

if isfield(RSK, 'parameterKeys')
    atmrow = strcmpi({RSK.parameterKeys.key}, 'ATMOSPHERE');
    pAtm = str2double(RSK.parameterKeys(atmrow).value);
elseif isfield(RSK, 'parameters')
    pAtm = RSK.parameters.atmosphere;
else 
    pAtm = 10.1325;
end

end
    