
% Packing is very flexible - it doesn't just do grids.
%
% (a) Pack a pair of columns.
% (b) Pack a bit into one of them, and then pack some more.
% (c) Pack into the other using absolute packing mode.
% (d) Call select('all'), to show off the result.
% (e) What you can't (currently) do.



%% (a)

% create the root panel, and pack two columns. to pack
% columns instead of rows, we just pass "h" (horizontal) to
% pack().
p = panel();
p.pack('h', 2);



%% (b)

% pack some stuff into the left column.
p(1).pack([1/6 1/6 1/6]);

% oops, we didn't fill the thing. let's finish that off with
% a couple of panels that are streeeeeeeee-tchy... we could
% have also called p(1).pack(2) to do both at once, or one
% call could have done all five if we'd passed enough
% arguments above (remember we can pass -1 to leave a panel
% stretchy).
p(1).pack();
p(1).pack();

% see help panel/pack or doc panel for more information on
% the packing possibilities.



%% (c)

% in the other column, we'll show how to do absolute
% positioning. perhaps you're unlikely to need this, but
% it's there if you do. with absolute positioning, you can
% even place the child panel outside of its parent's area.
p(2).pack('abs', [-0.3 0.05 1 0.4]);

% and you can pack more than one of these...
p(2).pack('abs', [0.2 0.6 0.6 0.4]);

% see help panel/pack or doc panel for more information on
% the packing possibilities.



%% (d)

% use selectAll to quickly show the layout you've achieved.
% this commits all uncommitted panels as axis panels, so
% they can't be parents anymore (i.e. they can't have more
% children pack()ed into them).
p.select('all');




%% (e)

% what you can't do is do fit packing and absolute packing
% into the same parent panel - the line below would generate
% an error. you could do this, in principle, but i'm not
% sure it would be useful.
% p(2).pack();

% neither, currently, can you pack into an abs panel. this
% might be supported in future, it's just a bit of a chore
% to work out the code. let me know if you find a need for
% it.
% p(2,2).pack(2, 2);






