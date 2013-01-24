% LORENZGUI   -          ODE simulation [Lorenz attractor]
%
%   LORENZGUI is an GUI for exploring the  Lorenz attractor
%   (http://en.wikipedia.org/wiki/Lorenz_attractor). The user can start and
%   stop the simulation. Changes to the parameters are applied immediately
%   to the ongoing simulation -- this allows the user to push the system
%   into a non-chaotic regime and come back to a chaotic regime.
%
%   This example demonstrates how to:
%    a) use EasyGUI with an ODE solver
%    b) start and stop a simulation
%    c) change parameters without stopping a simulation
%
%   To see some interesting modulations of the chaotic regime:
%    - Start the simulation. 
%    - Change Rho from 28 to 5 to 45 to 28
%    - Reset the parameters
%    - Change Sigma from 10 to 2 to 10

%   Copyright 2009 The MathWorks, Inc.

function lorenzgui

% setup the gui
myGui = gui.autogui;
myGui.Name = 'Lorenz equation';
myGui.BackgroundColor = [.8 .9 .9];

gui.label('Lorenz parameters');
paramBeta = gui.slider('Beta', [0 5]);
paramRho = gui.slider('Rho', [0 60]);
paramSigma = gui.slider('Sigma', [0 15]);

resetButton = gui.pushbutton('Reset parameters');
startButton = gui.pushbutton('Start simulation');
stopButton = gui.pushbutton('Stop simulation');

paramBeta.ValueChangedFcn = @updateStoredParameters;
paramRho.ValueChangedFcn = @updateStoredParameters;
paramSigma.ValueChangedFcn = @updateStoredParameters;
resetButton.ValueChangedFcn = @resetParameters;
stopButton.ValueChangedFcn = @stopSim;

% set variables for the gui
mySigma = []; % the stored/cached parameters
myRho = [];
myBeta = [];
mySimulationFlag = 0;
myTrajHistory = zeros(3,200) + nan;
myTrajHistoryIndex = [];
myLine = plot3(0,0,0);

% initialize the parameter values
resetParameters; 

% set up the axis
axis([0 60 -30 30 -30 30]);
xlabel('x'); ylabel('y'); zlabel('z');
set(gca,'projection','perspective'); grid on;

% Note: we cannot start the ODE solver within within a callback (otherwise
% the callback doesn't return and the gui can't process new user events).

stopButton.Enable = false;
myGui.monitor(startButton);

while myGui.waitForInput()
    y0 = (rand(1,3) .* [30 35 40]) + [5 -30 -5];
    opts = odeset('OutputFcn', @solverOutputFcn);
    mySimulationFlag = 0;
    
    startButton.Enable = false;
    stopButton.Enable = true;    
    ode45(@lorenzOde, [0 inf], y0, opts);       
    if ~isvalid(myGui), break; end % check if figure was deleted 
    startButton.Enable = true;
    stopButton.Enable = false;
end
        
%%    
    function resetParameters(hWidget) %#ok<INUSD>
        paramSigma.Value = 10;
        paramBeta.Value = 2.6;
        paramRho.Value = 28;        
    end
  
    function updateStoredParameters(hWidget) %#ok<INUSD>
        mySigma = paramSigma.Value;
        myRho = paramRho.Value;
        myBeta = paramBeta.Value;
    end
    
    function stopSim(hWidget) %#ok<INUSD>
        mySimulationFlag = 1;
    end    
        
    function status = solverOutputFcn(t,y,flag) %#ok<INUSL,INUSD,INUSD>
        if ~ishandle(myLine),
            status = 1;
            return;
        end
        n = size(y,2);
        myTrajHistory = [myTrajHistory(:,n+1:end) y];
        set(myLine, 'xdata', myTrajHistory(1,:), ...
                    'ydata', myTrajHistory(2,:), ...
                    'zdata', myTrajHistory(3,:));
        drawnow; % flush queue and allow callbacks to execute
        status = mySimulationFlag;
    end
    
    function dy = lorenzOde(t,y) %#ok<INUSL>
        if ~isvalid(paramBeta), 
            dy = [0 0 0]; return;
        end
        % based on MATLAB's lorenz.m function
        A = [ -myBeta    0     y(2)
                0  -mySigma   mySigma
              -y(2)   myRho    -1  ];
        dy = A*y;
    end    
end
