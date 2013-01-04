function tf = calledViaDataTip()
% tf = calledViaDataTip()
% Returns true if this function has been called from within
% datatipinfo. Typically useful when overriding the disp() method of a
% class, when special characters and colors would be inappropriate

stack = dbstack();
tf = ismember('datatipinfo', {stack.name});

end

