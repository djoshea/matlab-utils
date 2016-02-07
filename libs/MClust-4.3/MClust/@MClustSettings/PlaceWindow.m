function PlaceWindow(self, W)

% If the name of window W is in the windows map container, then read the
% location and place it there.  If it is not, then don't.

name = get(W, 'name');
if isKey(self.windowLocations, name)
    set(W, 'position', self.windowLocations(name));
end

