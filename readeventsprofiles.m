function RSK = readeventsprofiles(RSK)

%READEVENTSPROFILES - Read profiles start and end times from events table.
%
% Syntax:  [RSK] = READEVENTSPROFILES(RSK)
%
% Uses the events table generated by the logger to extract information
% about profiling, casts direction, start and end times.
%
% Inputs:
%    RSK - Structure.
%
% Outputs:
%    RSK - Structure containing populated profiles.
%
% Author: RBR Ltd. Ottawa ON, Canada
% email: support@rbr-global.com
% Website: www.rbr-global.com
% Last revision: 2017-06-21

RSKconstants

tmp = RSKreadevents(RSK);

if isfield(tmp, 'events')
    events = tmp.events;
    nup = length(find(events.values(:,2) == eventBeginUpcast));
    ndown = length(find(events.values(:,2) == eventBeginDowncast));
    
    if nup ~= 0 && ndown ~= 0
        
        iup = find(events.values(:,2) == eventBeginUpcast);
        idown = find(events.values(:,2) == eventBeginDowncast);
        iend = find(events.values(:,2) == eventEndcast);
        
        if (idown(1) < iup(1)) 
            idownend = iend(1:2:end);
            iupend = iend(2:2:end);
        else
            idownend = iend(2:2:end);
            iupend = iend(1:2:end);
        end
        
        RSK.profiles.downcast.tstart = events.tstamp(idown);
        RSK.profiles.downcast.tend = events.tstamp(idownend);
        RSK.profiles.upcast.tstart = events.tstamp(iup);
        RSK.profiles.upcast.tend = events.tstamp(iupend);
    end
end

end
