%% A quick and dirty comparison between Matlabfrag and LaPrint
close all;
hfig = figure;
set(hfig,'units','centimeters');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),5.5,6]);

%% Draw the figure
[x,y,z] = peaks(20);
surf(x.*1e-3,y.*1e-3,z.*1e-4);
xlabel('x axis');
ylabel('y axis');
zlabel('z axis');

%% Produce the figure with matlabfrag
matlabfrag('graphics/comparison02-matlabfrag');

%% Produce the figure with LaPrint
% These are the options required to make LaPrint behave in the same manner
% as matlabfrag
laprint(1,'comparison02-laprint','width',6,'factor',1,'scalefonts','off',...
  'keepfontprops','on','asonscreen','on','keepticklabels','off');
% Now open the file, and comment out parts of it to make it compatible with
% pstool.
fh = fopen('comparison02-laprint.tex','r');
texfile = fread(fh,inf,'uint8=>char').';
fclose(fh);
texfile = regexprep(texfile,'\\begin\{psfrags\}','%\\begin{psfrags}');
texfile = regexprep(texfile,'\\psfragscanon%','%\\psfragscanon%');
texfile = regexprep(texfile,'\\includegraphics','%\\includegraphics');
texfile = regexprep(texfile,'\\end\{psfrags\}','%\\end{psfrags}');
fh = fopen('comparison02-laprint.tex','w');
fwrite(fh,texfile);
fh=fclose(fh);
movefile('comparison02-laprint*','graphics/');