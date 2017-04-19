function StartEnd = get_wl_StartEnd(rundate, runid )
%
% Parameters:
%        runid - Runid as a string (with 'wl')
%        rundate - Run date as 'YYYYMMDD'
%
% Example:
%        runid = 'wl0048';
%        rundate = '20091027';
%        StartEnd = get_wl_StartEnd(rundate, runid )
%
% B. Nemati - 05-Feb-2010 
% (orig. from T. Werne)

URL = 'http://scdu.jpl.nasa.gov/scdu/ops/exp_log/';
extension = '.elog';

index = str2double(runid(3:end));
if isempty(index)
    error([runid ' is not a valid runid']);
end

elog = urlread([URL rundate extension]);

newlines = strfind(elog, 10);

if (index > length(newlines))
    % Oops, this run doesn't exist on this date
    error(['Invalid runid: ', num2str(length(newlines)), ' runs were performed on ', rundate, ...
        ' you requested ' num2str(index)]);
else
    % Get the desired elog entry
    newlines = [0 newlines];
    entry = elog(newlines(index) + 1 : newlines(index + 1) - 1);
end

startDate = entry(8:17);
startTime = entry(19:26);
datenumStart = datenum([startDate,'_',startTime],'yyyy/mm/dd_HH:MM:SS');
EndDate = entry(28:37);
EndTime = entry(39:46);
datenumEnd = datenum([EndDate,'_',EndTime],'yyyy/mm/dd_HH:MM:SS');

StartEnd.datenumStart = datenumStart;
StartEnd.datenumEnd = datenumEnd;

return



