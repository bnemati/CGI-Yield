function key_found = scdu_key_in_elog(key, runid, rundate, requireExact)
% SCDU_KEY_IN_ELOG Returns whether the description for a SCDU run contains
%                  a key
%
% Usage:
%        key_found = scdu_key_in_elog(key, runid, rundate)
%
% Parameters:
%        key - The key to search for in the elog
%        runid - Runid as a string (with 'wl')
%        rundate - Run date as 'YYYYMMDD'
%
% Returns:
%        key_found - (bool) was the key found?
%
% Example:
%        key = 'NAbias';
%        runid = 'wl0048';
%        rundate = '20091027';
%        key_found = scdu_key_in_elog(key, runid, rundate);
%
% Note: without caching, one test of 1000 checks took ~6 secs.  
%       with caching, it took < 0.5 sec
%
% Author: Thomas Werne
% Date:   16 Nov 2009
% Rev:    0.1


% For let the elog and date be persistent
persistent elog prev_date;
mlock; % Keeps the m-file resident in memory.  Persistent doesn't work w/o it

% Location of the elog online
URL = 'http://scdu.jpl.nasa.gov/scdu/ops/exp_log/';
extension = '.elog';

% Pick the run number out of the runid
index = str2double(runid(3:end)); 
if (isempty(index) || isnan(index))

%     disp([runid ' is not a valid runid']);
    key_found = false;
    return
else
    % Cache the elog and date.  If we are searching for a bunch of runs in
    % temporal order, this caching will save time.
    if ~strcmp(prev_date, rundate)
        elog = urlread([URL rundate extension]);
        prev_date = rundate;
    end
    
    % elog is just a string of characters.  We need to find the '\n's
    newlines = strfind(elog, 10);
    if (index > length(newlines))
        % Oops, this run doesn't exist on this date
        display(['Warning: scdu_key_in_elog did not find runid ', runid,' on ', rundate]);
        
        if requireExact
            key_found = false;
        else
            % At the UTC day boundary we can get this error - check for it
            yesterday = datestr(datenum(rundate, 'yyyymmdd')-1,'yyyymmdd' );
            elogYesterday = urlread([URL yesterday extension]);
            newlinesYesterday = strfind(elogYesterday, 10);
            if (index > length(newlinesYesterday))
                key_found = false;
            else
                display(['            ... so applying to ', yesterday]);
                % Get the desired elog entry
                newlinesYesterday = [0 newlinesYesterday];
                entry = elogYesterday(newlinesYesterday(index) + 1 : newlinesYesterday(index + 1) - 1);
                
                key_found = ~isempty(strfind(entry, key));
            end        
        end
    else 
        % Get the desired elog entry
        newlines = [0 newlines];
        entry = elog(newlines(index) + 1 : newlines(index + 1) - 1);
        
        key_found = ~isempty(strfind(entry, key));
    end
end



return
