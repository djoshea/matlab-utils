% FITZNAG   -         ODE simulation [Fitzhugh-Nagumo model]
%
%   FITGNAG is an GUI (created using EasyGUI) of the Fitzhugh-Nagumo
%   model of neuronal spiking dynamics. For details, see:
%    http://en.wikipedia.org/wiki/Fitzhugh-Nagumo_model
%
%   This example demonstrates how to use EasyGUI with an ODE solver, so
%   that a user can interactively change parameters and see the new
%   solution right away. 

%   Copyright 2009 The MathWorks, Inc.

function fitznag
    
myGui = gui.autogui;
myGui.Name = 'Fitzhugh-Nagumo model';
myGui.Location = 'right';
myGui.BackgroundColor = [.8 .9 .9];

gui.label('Fitzhugh-Nagumo Parameters');
current = gui.slider('Input current', [0 3]);
paramA = gui.slider('A', [0 2]);
paramB = gui.slider('B', [0 2]);
tau = gui.slider('tau (time scaling)', [0 0.5]);
resetButton = gui.pushbutton('Reset parameters');

current.Value = 0.4;
paramA.Value = 0.7;
paramB.Value = 0.8;
tau.Value= 0.08;

while myGui.waitForInput()
    if myGui.LastInput == resetButton
        current.Value = 0.4;
        paramA.Value = 0.7;
        paramB.Value = 0.8;
        tau.Value= 0.08;
    end
   [t,y] = solve_equation(paramA.Value, paramB.Value, tau.Value, current.Value);
   subplot(211); plot(t,y); ylim([-2.5 2.5]);
   xlabel('time'); 
   subplot(212); plot(y(:,1), y(:,2)); axis([-2.5 2.5 -2.5 2.5]); axis equal;
   xlabel('Voltage V'); ylabel('Recovery variable W');
end
    
end

%%
function [t,y] = solve_equation(A,B,tau,Iext)
    % http://www.scholarpedia.org/article/FitzHugh-Nagumo_model
    [t,y]=ode45(@fitzhugh_nagumo, [0 160], [0 1]);

    function dx = fitzhugh_nagumo(t,x) %#ok<INUSL>
        dx = [0 0].';
        dx(1) = x(1) - (x(1)^3)/3 - x(2) + Iext;
        dx(2) = tau * (x(1) + A - B*x(2));
    end
end
