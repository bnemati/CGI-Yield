function y = show(varname)
% Use imagesc to plot a variable in the base workspace with a simple command
% syntax:   
%     show('varname')
% B. Nemati, 24-Jul-2007

imagesc(evalin('base',varname))
colorbar
axis square
title(varname, 'interpret', 'none')

return
