function jFrame = undecorateFig(hFig)
% undecorateFig removes the border and title of a figure window
%
% Syntax:
%    jFrame = undecorateFig(hFig)
%
% Description:
%    undecorateFig creates a new undecorated (borderless and title-less)
%    Java JFrame window at the position of the specified figure, at the
%    same time hiding the original Matlab figure. This provides an optical
%    illusion that the Matlab figure's border and title were removed.
%    As a side effect, the figure's menubar and toolbar are removed.
%
% Input:
%    hFig - (default=gcf) Handle of the modified figure. If a component
%           handle is specified, the containing figure will be inferred.
%
% Output:
%    jFrame - Java reference handle of the newly-created JFrame.
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
%    redecorateFig, enableDisableFig, setFigDockGroup, getJFrame (all of them on the File Exchange)

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

  % Ensure that the figure is not undecorated already
  jFrame_ = getappdata(hFig,'undecorate_jFrame');
  if ~isempty(jFrame_)
      %error('Figure is already undecorated');
  else
      % Store the previous state of the figure's toolbar/menubar
      setappdata(hFig,'undecorate_toolbar',get(hFig,'Toolbar'));
      setappdata(hFig,'undecorate_menubar',get(hFig,'Menubar'));

      % Remove toolbar/menubar (don't work well in undecorated JFrame)
      set(hFig, 'Toolbar','none', 'MenuBar','none');
      drawnow;

      % Get the root Java frame
      jWindow = getJFrame(hFig);
      setappdata(hFig,'undecorate_jWindow',jWindow);

      % Get the content pane's handle
      mjc = jWindow.getContentPane;  %=getRootPane;
      mjr = jWindow.getRootPane;

      % Create a new pure-Java undecorated JFrame
      figTitle = jWindow.getTitle;
      jFrame_ = javaObjectEDT(javax.swing.JFrame(figTitle));
      jFrame_.setUndecorated(true);

      % Move the JFrame's on-screen location just on top of the original
      jFrame_.setLocation(mjc.getLocationOnScreen);

      % Set the JFrame's size to the Matlab figure's content size
      %jFrame_.setSize(mjc.getSize);  % slightly incorrect (content-pane's offset)
      jFrame_.setSize(mjc.getWidth+mjr.getX, mjc.getHeight+mjr.getY);
      setappdata(hFig,'undecorate_contentJPanel',mjc);

      % Reparent (move) the contents from the Matlab JFrame to the new undecorated JFrame
      jFrame_.setContentPane(mjc);

      % Hide the taskbar component (Java 7 i.e. R2013b or newer only)
      try jFrame_.setType(javaMethod('valueOf','java.awt.Window$Type','UTILITY')); catch, end

      % Make the new JFrame visible
      jFrame_.setVisible(true);

      % Hide the Matlab figure by moving it off-screen
      pos = get(hFig,'Position');
      setappdata(hFig,'undecorate_originalPos',pos);
      set(hFig,'Position',pos-[9000,9000,0,0]);
      drawnow;

      % Enlarge the content pane to fill the jFrame
      mjc.setSize(jFrame_.getSize);

      % Set the focus callback to enable focusing by clicking in the taskbar
      hjWindow = handle(jWindow, 'CallbackProperties');
      set(hjWindow, 'FocusGainedCallback', @(h,e)jFrame_.requestFocus);

      % Dispose the JFrame when the Matlab figure closes
      set(hjWindow, 'WindowClosedCallback', @(h,e)jFrame_.dispose);

      % Store the JFrame reference for possible later use by redecorateFig
      setappdata(hFig,'undecorate_jFrame',jFrame_);
  end

  % Return the jFrame reference handle, if requested
  if nargout
      jFrame = jFrame_;
  end

end  % undecorateFig


%% Get the root Java frame (up to 10 tries, to wait for figure to become responsive)
function jWindow = getJFrame(hFig)
    % Ensure that hFig is a non-empty handle...
    if isempty(hFig)
        error('Cannot retrieve the figure handle');
    end

    % Check for the desktop handle
    if isequal(hFig,0)
        %jframe = com.mathworks.mde.desk.MLDesktop.getInstance.getMainFrame; return;
        error('Only figure windows can be undecorated, not the Matlab desktop');
    end

    % Check whether the figure is invisible
    if strcmpi(get(hFig,'Visible'),'off')
        error('Cannot undecorate a non-visible figure');
    end

    % Check whether the figure is docked
    if strcmpi(get(hFig,'WindowStyle'),'docked')
        error('Cannot undecorate a docked figure');
    end

    % Retrieve the figure window (JFrame) handle
    jWindow = [];
    maxTries = 10;
    oldWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    while maxTries > 0
        try
            % Get the figure's underlying Java frame
            jf = get(handle(hFig),'JavaFrame');

            % Get the Java frame's root frame handle
            %jframe = jf.getFigurePanelContainer.getComponent(0).getRootPane.getParent;
            try  % Old releases
                jWindow = jf.fFigureClient.getWindow;  % equivalent to above...
            catch
                try  % HG2
                    jWindow = jf.fHG2Client.getWindow;  % equivalent to above...
                catch  % HG1
                    jWindow = jf.fHG1Client.getWindow;  % equivalent to above...
                end
            end
            if ~isempty(jWindow)
                break;
            else
                maxTries = maxTries - 1;
                drawnow; pause(0.1);
            end
        catch
            maxTries = maxTries - 1;
            drawnow; pause(0.1);
        end
    end
    warning(oldWarn);
    if isempty(jWindow)
        error('Cannot retrieve the figure''s underlying Java Frame');
    end
end  % getJFrame
