function scdu_html_summary(summary_information)
% Creates an HTML summary file for a set of images.  Currently, the HTML
% file consists of a description, followed by a table filled with images
% and, optionally, descriptions of the images, ending with an author and
% date tag
%
% Usage:
%    scdu_html_summary(summary_information)
%
% Inputs:
%    summary_information - a structure containing all the information
%                          used to create the HTML file
% 
% Outputs:
%    None
%
% struct summary_information fields: 
%    filename    - the filename for the webpage (must include the .html)
%    title       - the title for the webpage
%    description - a general description of the webpage content i.e. what
%                  sort of images are on the webpage and why do they matter
%    author      - the initials of the person who built the webpage
%    content     - an array of structures containing image location and
%                  descriptions
%
% struct content fields:
%    location    - the location of the image
%    caption     - the description for the image
%
% 
%   Date         rev.    Author    Desc
%    2008-10-09   1.0     taw       Initial release
%    2009-03-04   1.1     taw       Conversion to XHTML compatible
%                                   code



% error checking... don't want to create half an HTML file, do we?
if(~isfield(summary_information, 'filename'))
    display('summary_information must have filename field');
   
    return;
end

% This is the special case.  Check for existence of content AND a location
% field for each content array element
if(~isfield(summary_information, 'content'))
    display('summary_information must have content field');

    return;
else 
    num_images = length(summary_information.content);
    for i = 1:num_images
        if(isempty(summary_information.content(i).location))
            display(['summary_information.content(' num2str(i) ...
                ') must have a location']);

            return;
        end
    end
end

if(~isfield(summary_information, 'author'))
    display('summary_information must have author field');

    return;
end

fid = fopen(summary_information.filename, 'w');

% Print write the title
fprintf(fid, '%s\n', '<html>');
fprintf(fid, '%s', '<head>');
if(isfield(summary_information, 'title'))
    fprintf(fid, '%s%s%s', '<title>', ...
        summary_information.title, ...
        '</title>');
end
fprintf(fid, '%s\n', '</head>');

% Write the description
fprintf(fid, '%s\n', '<body>');
fprintf(fid, '%s\n  %s\n%s\n', '<h1>', summary_information.title, '</h1>');

if(isfield(summary_information, 'description'))
    fprintf(fid, '%s\n', '  <h3>Summary:</h3>');
    fprintf(fid, '%s\n%s', summary_information.description, ...
        '<br /><br />');
end

% Prepare for the image table
fprintf(fid, '%s\n', '<h3>Images:</h3>');
fprintf(fid, '%s\n%s\n', '<div align=center>', ...
    '<table border=1 width="95%">');

for i = 1:num_images
    % Start a new table row
    fprintf(fid, '%s\n', '<tr>');
    fprintf(fid, '%s',   '  <td width="70%" align="center">');

    % Write the image location
    fprintf(fid, '%s%s%s', '  <img src=', summary_information.content(i).location, ' />');
    
    fprintf(fid, '%s\n', '</td>');
    
    % Image descriptions are option.  If there is one, use it
    if(isfield(summary_information.content(i), 'caption'))
        fprintf(fid, '%s\n', '  <td width="30%" valign="top">');
        fprintf(fid, '%s\n', summary_information.content(i).caption);
        fprintf(fid, '%s\n', '  </td>');
    end
   
    fprintf(fid, '%s\n', '</tr>');
    
end

fprintf(fid, '%s\n%s\n', '</table>', ...
    '</div>');

% Print the ancillary information
fprintf(fid, '%s\n', '<br /><br />');
fprintf(fid, 'Author: %s<br />\n', summary_information.author);
fprintf(fid, 'Created: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

% Clean up
fprintf(fid, '%s\n', '</body>');
fprintf(fid, '%s\n', '</html>');

fclose(fid);
