function redecorateFig(hFig)
% redecorateFig returns the border/title of undecorated figure window
%
% Syntax:
%    redecorateFig(hFig)
%
% Description:
%    redecorateFig restores the decoration (border, title, toolbar, menubar)
%    of a Matlab figure that was previously undecorated using undecorateFig.
%
% Inputs:
%    hFig - (default=gcf) Handle of the modified figure. If a component
%           handle is specified, the containing figure will be inferred.
%
% Technical details:
%    http://undocumentedmatlab.com/blog/frameless-undecorated-figure-windows
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab functionality.
%    It works on Matlab 7 and higher, but use at your own risk!
%
% Change log:
%    2015-03-19: First version posted on Matlab's File Exchange: <a href="http://www.mathworks.com/matlabcentral/fileexchange/?term=authorid%3A27420">http://www.mathworks.com/matlabcentral/fileexchange/?term=authorid%3A27420</a>
%
% See also:
%    undecorateFig, enableDisableFig, setFigDockGroup, getJFrame (all of them on the File Exchange)

  % Require Java to run
  if ~usejava('awt')
      error([mfilename ' requires Java to run']);
  end

  % Set default input parameters values
  if nargin < 1,  hFig = gcf;  end

  % Get unique figure handles
  if ~isscalar(hFig)
      error('hFig must be a single valid GUI handle');
  elseif ~ishghandle(hFig)
      error('hFig must be a valid GUI handle');
  end

  % Ensure that we have a figure handle
  hFig = ancestor(hFig, 'figure');

  % Ensure that the figure has been undecorated
  jFrame = getappdata(hFig,'undecorate_jFrame');
  if isempty(jFrame)
      error('Figure is not undecorated');
  end

  % Get the content-pane handle
  jWindow = getappdata(hFig,'undecorate_jWindow');
  mjc = getappdata(hFig,'undecorate_contentJPanel'); %=jFrame.getComponent(0);

  % Reparent (move) the contents from the undecorated JFrame to the Matlab JFrame
  jWindow.setContentPane(mjc);

  % Restore the previous state of the figure's toolbar/menubar
  try set(hFig,'Toolbar',getappdata(hFig,'undecorate_toolbar')); catch, end
  try set(hFig,'Menubar',getappdata(hFig,'undecorate_menubar')); catch, end

  % Show the Matlab figure by moving it on-screen
  pos = getappdata(hFig,'undecorate_originalPos');
  set(hFig,'Position',pos);
  drawnow;

  % Dispose the JFrame
  jFrame.dispose;

  % Remove the figure's focus & deletion callback
  hjWindow = handle(jWindow, 'CallbackProperties');
  set(hjWindow, 'FocusGainedCallback',  []);
  set(hjWindow, 'WindowClosedCallback', []);

  % Remove the extraneous appdata from the figure
  rmappdata(hFig,'undecorate_jFrame');
  rmappdata(hFig,'undecorate_jWindow');
  rmappdata(hFig,'undecorate_contentJPanel');
  rmappdata(hFig,'undecorate_toolbar');
  rmappdata(hFig,'undecorate_menubar');
  rmappdata(hFig,'undecorate_originalPos');

end  % redecorateFig
