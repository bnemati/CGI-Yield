function [cent_x_right_arm, cent_y_right_arm, cent_x_left_arm, ...
    cent_y_left_arm, time] = plot_at_centroids(data_file, ...
    dark_file, description)
% Plots the x & y coordinates for the centroid of an ATC data run.
% Assumes that the dark run is at least 30 seconds long.
%
% Usage:
%   [cent_x_right_arm, cent_y_right_arm, cent_x_left_arm, ...
%       cent_y_left_arm] = plot_at_centroids(data_file, dark_file)
%
%   [cent_x_right_arm, cent_y_right_arm, cent_x_left_arm, ...
%       cent_y_left_arm] = plot_at_centroids(data_file, dark_file, ...
%       description)
%
% Inputs:
%   data_file   - the file name of the data file to be analyzed (including
%       the extension)
%   dark_file   - the file name of the file containing the dark counts
%   description - an optional description that appears in the plot titles
%   
% Outputs:
%   cent_x_right_arm - a column vector containing the right arm centroid
%       x-coordinates
%   cent_y_right_arm - a column vector containing the right arm centroid
%       y-coordinates
%   cent_x_left_arm  - a column vector containing the left  arm centroid
%       x-coordinates
%   cent_y_left_arm  - a column vector containing the left  arm centroid
%       y-coordinates
%   time - a column vector containing sample times for the centroid values
%
%
%  Date        rev.      Author    Desc
%   2008-10-06  1.0       taw       Initial Release
%   2008-10-17  1.1       taw       Fixed pixel readout order bug

% Format the description nicely, if it exists
if (nargin < 3)
    description = '';
else
    description = ['(' description ') '];
end


% Load in the data file
load(data_file);

% Fix the readout-order problem
pixel = correct_order(double(pixel)); %#ok

% Get some state variables
nt = length(tv_sec);
ccd_size = size(pixel, 1);
run_id = data_file(1:6);

% Create a time vector
time = double(tv_sec - tv_sec(1)) + 1e-6*double(tv_usec);

% Do dark computation
[AT1_mean, AT2_mean] = compute_at_darks(dark_file, 500, 500);

% Generate moment weighting matrices
% These will produce centroids relative to the upper left corner (I
% think...) of the CCD.  We should really subtract out the target (x,y)
% centroids to get a "proper" result.  I don't currently know what that
% target is.
moment_matrix = (1:ccd_size) - 0.5;
moment_matrix = ones(ccd_size, 1)*moment_matrix;

moment_x_matrix_right_arm = moment_matrix;
moment_y_matrix_right_arm = flipud(moment_matrix.');

moment_x_matrix_left_arm = moment_x_matrix_right_arm;
moment_y_matrix_left_arm = moment_y_matrix_right_arm;

% Pre-allocate storage
right_arm = zeros(ccd_size, ccd_size, nt);
left_arm = zeros(ccd_size, ccd_size, nt);
moment_x_right_arm = zeros(nt, 1);
moment_y_right_arm = zeros(nt, 1);
moment_x_left_arm = zeros(nt, 1);
moment_y_left_arm = zeros(nt, 1);

% Subtract out the dark values
for k = 1:nt
    right_arm(:, :, k) = squeeze(double(pixel(:, :, 1, k))) - AT1_mean;
    left_arm(:, :, k) = squeeze(double(pixel(:, :, 2, k))) - AT2_mean;
end

% Compute the x & y moments
for k = 1:nt
    moment_x_right_arm(k) = ...
        sum(sum(right_arm(:, :, k).*moment_x_matrix_right_arm));
    moment_y_right_arm(k) = ...
        sum(sum(right_arm(:, :, k).*moment_y_matrix_right_arm));
    moment_x_left_arm(k) = ...
        sum(sum(left_arm(:, :, k).*moment_x_matrix_left_arm));
    moment_y_left_arm(k) = ...
        sum(sum(left_arm(:, :, k).*moment_y_matrix_left_arm));
end

% Compute frame masses
mass_right_arm = squeeze(sum(sum(right_arm)));
mass_left_arm = squeeze(sum(sum(left_arm)));

% Compute the centroids
cent_x_right_arm = moment_x_right_arm./mass_right_arm;
cent_y_right_arm = moment_y_right_arm./mass_right_arm;
cent_x_left_arm  = moment_x_left_arm./mass_left_arm;
cent_y_left_arm  = moment_y_left_arm./mass_left_arm;

% Calculate the time averages to include in the figures.
cent_x_right_mean = mean(cent_x_right_arm);
cent_y_right_mean = mean(cent_y_right_arm);
cent_x_left_mean  = mean(cent_x_left_arm);
cent_y_left_mean  = mean(cent_y_left_arm);

filt_len = 100;

% Plot some figures
figure; 
plot(time, smooth(squeeze(cent_x_right_arm), filt_len), '.r', ...
    time, smooth(squeeze(cent_y_right_arm), filt_len), '.b');
grid on;
xlabel('Time (s)');
ylabel('Centroid Position [pixel]');
legend(['cent_x (mean = ' num2str(cent_x_right_mean) ')'], ...
    ['cent_y (mean = ' num2str(cent_y_right_mean) ')'], ...
    'Location', 'Best');
title([run_id ': ' description 'Right Arm Centroid']);
% boldify;
% print('-djpeg', '-r100', [run_id '_right_arm_centroids.jpg']);

figure; 
plot(time, smooth(squeeze(cent_x_left_arm), filt_len), '.r', time, ...
    smooth(squeeze(cent_y_left_arm), filt_len), '.b');
grid on;
xlabel('Time (s)');
ylabel('Centroid Position [pixel]');
legend(['cent_x (mean = ' num2str(cent_x_left_mean) ')'], ...
    ['cent_y (mean = ' num2str(cent_y_left_mean) ')'], ...
    'Location', 'Best');
title([run_id ': ' description 'Left Arm Centroid']);
% boldify;
% print('-djpeg', '-r100', [run_id '_left_arm_centroids.jpg']);