%% A quick and dirty comparison between Matlabfrag and LaPrint
close all;
hfig = figure;
set(hfig,'units','centimeters');
pos = get(hfig,'position');
set(hfig,'position',[pos(1:2),5.5,5]);

%% Draw the figure
gaussfunc = @(x,a,b,c) a*exp(-(x-b).^2/(2*c^2));
x = -5:0.1:5;
y = gaussfunc(x,1e-3,0,2);
plot(x,y);
hl=legend( '$f(x)=ae^{-\frac{(x-b)^2}{2c^2}}$', 'location','south' );
set(hl,'interpreter','latex');

%% Produce the figure with matlabfrag
matlabfrag('graphics/comparison01-matlabfrag');

%% Produce the figure with LaPrint
% These are the options required to make LaPrint behave in the same manner
% as matlabfrag
laprint(1,'comparison01-laprint','width',6,'factor',1,'scalefonts','off',...
  'keepfontprops','on','asonscreen','on','keepticklabels','off');
% Now open the file, and comment out parts of it to make it compatible with
% pstool.
fh = fopen('comparison01-laprint.tex','r');
texfile = fread(fh,inf,'uint8=>char').';
fclose(fh);
texfile = regexprep(texfile,'\\begin\{psfrags\}','%\\begin{psfrags}');
texfile = regexprep(texfile,'\\psfragscanon%','%\\psfragscanon%');
texfile = regexprep(texfile,'\\includegraphics','%\\includegraphics');
texfile = regexprep(texfile,'\\end\{psfrags\}','%\\end{psfrags}');
fh = fopen('comparison01-laprint.tex','w');
fwrite(fh,texfile);
fh=fclose(fh);
movefile('comparison01-laprint*','graphics/');