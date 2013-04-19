%
%  A demonstration file for gridLegend
%
% Adrian Cherry
% 2/11/2010

% Lets generate lots of data and plot it
y=[0:0.1:3.0]'*sin(-pi:0.1:pi);
hdlY=plot(y');

% now the standard legend function will probably flow off the figure
% although if you maximise it then you might see all of the legend,
% however the print preview is probably truncated.
legend(hdlY);
pause

% plot again this time using gridLegend to print the legend in 4 columns
hdlY=plot(y');
gridLegend(hdlY,4);
pause

% As standard the legend flows down filling the first column before
% moing onto the next. We can change this by using the Orientation
% horizontal option to fill across the rows before moving down a row.
gridLegend(hdlY,4,'Orientation','Horizontal');
pause 

% to use some options the standard legend function needs a key
for i=1:31,
    key{i}=sprintf('trace %d',i);
end

% here we place legend on the lefthand side and reduce the fontsize
hdlY=plot(y');
gridLegend(hdlY,2,key,'location','westoutside','Fontsize',8,'Box','off','XColor',[1 1 1],'YColor',[1 1 1]);
