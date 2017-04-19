function set_scdu_path()
%
% make sure you type
%  global SCDU_DATA_PATH 
% to get access to the global variable


global SCDU_DATA_PATH;
    
default_directory = '/proj/scdu/ops/data-mat/';
hostname_table = [ ...
    {'medoc.jpl.nasa.gov'}, {'/proj/scdu/ops/data-mat/'}; ...
    {'nemati-dt'}, {'C:\Data\something'}; ...
];


if (~isempty(SCDU_DATA_PATH))
% SCDU data directory variable already exists, leave it be
    return;
    
else
% SCDU data directory variable doesn't exist

    [s, hostname] = system('hostname'); %#ok
    
    % trim out silly newlines
    hostname = strrep(hostname, char(10), '');
    hostname = strrep(hostname, char(13), '');
    
    % look through the table
    table_index = strmatch(hostname, hostname_table);
   
    if (~isempty(table_index))
    % haha, this machine is in the table
       SCDU_DATA_PATH = char(hostname_table(table_index, 2));
       return;
    end
    
    % if we get to this point, this computer isn't in the hostname table
    % if it's linux, assume it's on the S383 network and can hit
    % the standard project directory
    if (strcmp(computer, 'GLNX86'))
        SCDU_DATA_PATH = default_directory;
        return;
    end
    
    % If we get to this point, we're running on some new machine.
    % Complain.
    disp('SCDU_DATA_PATH isn''t set and your machine is not in the table.');
    disp(['Consider adding this computer to the hostname_table in the '...
        'set_scdu_path.m function.']);
    disp('');
    SCDU_DATA_PATH = input('Where is SCDU data on your system: ', 's');
end

return