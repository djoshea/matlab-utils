function c = myCallerName()

% c = myCallerName()
%
% OUTPUTS
%    c = name of function that called function that called "myCallerName"
%
%
% i.e. 
% 	function foo()
% 		bar();
% 	end
% 
% 	function bar()
% 		c = myCaller();
% 		% c will be "foo"
% 	end
%
%
% uses dbstack

ST = dbstack();
if length(ST)<3
	c = 'base';
else
	c = ST(3).name;
end
		
