function CGdata = loadCGdata(CGfile, CGdesignsFolder)

startRow = 2;
endRow = inf;
formatSpec = '%13f%13f%16f%16f%16f%16f%16f%f%[^\n\r]';
fileID = fopen(fullfile(CGdesignsFolder, CGfile),'r');

dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, ...
    'Delimiter', '', 'WhiteSpace', '', 'HeaderLines', startRow(1)-1, ...
    'ReturnOnError', false);

for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

fclose(fileID);

data.CGdesign = CGfile;
data.rlamD = dataArray{:, 1};
data.rarcsec = dataArray{:, 2};
data.I = dataArray{:, 3};
data.contrast = dataArray{:, 4};
data.core_thruput = dataArray{:, 5};
data.PSF_peak = dataArray{:, 6};
data.areasq_arcs = dataArray{:, 7};
data.occ_trans = dataArray{:, 8};

CGdata  = data;
end



% % txt=fileread(fullfile(CGdesignsFolder, CGtype, 'matlab', 'graph2d', 'plot.m'));
% %  sum(txt==10)+1
% txt=fileread(fullfile(CGdesignsFolder, CGtype, CGfile));
% nlines = sum(txt==10);
% 