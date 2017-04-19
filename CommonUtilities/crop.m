function y = crop(inputMatrix)
%
%
% B. Nemati -- 03-Dec-2009

[row, col] = find(inputMatrix); 
rowmin=min(row); 
rowmax=max(row); 
colmin=min(col); 
colmax=max(col); 

y.cropped  = inputMatrix(rowmin:rowmax, colmin:colmax);
y.rowrange = [rowmin, rowmax];
y.colrange = [colmin, colmax];
y.dims     = [rowmax-rowmin+1, colmax-colmin+1];


return
        