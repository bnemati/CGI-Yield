function y = ExtractRunDatenum(date, runid)
% Given a Run date and ID return the datenum for the start of the run
% 
% B. Nemati -- 08-Oct-2009
elog = strread(urlread(['http://scdu.jpl.nasa.gov/scdu/ops/exp_log/' ...
    datestr(datevec(date), 'yyyymmdd') '.elog']), '%s', 'delimiter', '\t');

entry = find(ismember(elog, runid));
start_time = elog{entry + 1};
end_time = elog{entry + 2};

y = [ datenum(start_time, 'yyyy/mm/dd HH:MM:SS'), ...
      datenum(end_time, 'yyyy/mm/dd HH:MM:SS')];
  

return

% [T, R] = strtok(elog);
% while ((strcmp(runid, T) == 0) && ~isempty(T))
%     [T, R] = strtok(R);
% end
% for i = 1:3
%     [T, R] = strtok(R);
% end
% rundate = T;
% runtime = strtok(R);
% y = datenum([rundate, runtime], 'yyyy/mm/ddHH:MM:SS');