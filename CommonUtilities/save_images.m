function save_images()
% Saves all the current figures as .jpg files.  Uses the figure titles (for
% the first axis in a subplotted-figure), with spaces replaced by
% underscores, as the filename.  Does not attempt to handle exceptional
% cases (latex, characters that should not appear in filenames, etc.)
%
% Usage:
%   save_images()
%
% Inputs:
%   None
%
% Outputs:
%   None
%
%   Date         rev.    Author    Desc
%    2008-10-22   1.0     taw       Initial release

% Define a replacement table
replace_table = [{' '},      {'_'};
                 {'\alpha'}, {'a'};
                 {'\beta'},  {'b'};
                 {';'},      {'--'};
                 {':'},      {'--'};
                 {'\'},      {'--'};
                 {'/'},      {'--'}];

% Iterate through all the figures
for k = get(0, 'Children')'
    % Now k is a handle for a figure
    % Now get its first axis 
    axis_child = get(k, 'Children');
    axis_child = axis_child(1);
    
    % Now get the string in the title for that axis element
    title_string = get(get(axis_child, 'Title'), 'String');
    
    % Get rid of the spaces in the title
    for l = 1:length(replace_table)
        title_string = strrep(title_string, replace_table(l, 1), ...
            replace_table(l, 2));
    end
        
    title_string = strrep(title_string, ' ', '_');
        
    % Bring the image to the front and save it
    figure(k);
    print('-djpeg', '-r100', [title_string, '.jpg']);
end