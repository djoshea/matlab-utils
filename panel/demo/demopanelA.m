
% Panel builds image files, not just on-screen figures.
%
% (a) Use demopanel1 to create a layout.
% (b) Export the result to file.
% (c) Export to different physical sizes.
% (d) Export at high quality.
% (e) Adjust margins.
% (f) Export using smoothing.
% (g) Export to EPS, rather than PNG.



%% (a)

% delegate
demopanel1

% see "help panel/export" for the full range of options.



%% (b)

% the default sizing model for export targets a piece of
% paper. the default paper model is A4, single column, with
% 20mm margins. the default aspect ratio is the golden ratio
% (landscape). therefore, if you provide only a filename,
% you get this...

% do a default export
p.export('export_b');

% the default export resolution is 150DPI, so the resulting
% file will look a bit scraggy, but it's a nice small file
% that is probably fine for laying out your document.



%% (c)

% one thing you might want to vary from figure to
% figure is the aspect ratio. the default (golden ratio) is
% a little short, here, so let's make it a touch taller.
p.export('export_c', '-a1.4');

% the other thing is the column layout. we've exported to a
% single column, above - let's target a single column of a
% two-column layout.
p.export('export_c_c2', '-a1.4', '-c2');

% ach... that's never going to work, it doesn't fit. this
% figure will have to span two columns, let's leave it how
% it was.

% NB: here, we have used the "paper sizing model". if you
% prefer, you can use the "explicit sizing model" and just
% specify width and height directly. see "help
% panel/export".



%% (d)

% when you're done drafting your document, you can bring up
% the export resolution to get a nice looking figure. "-rp"
% means "publication resolution" (600DPI).
p.export('export_d', '-a1.4', '-rp');



%% (e)

% once exported at final resolution, i can't help
% noticing the margins are a little generous. let's pull
% them in as tight as we dare to reduce the whitespace.
p.de.margin = 1;
p(1,1).marginbottom = 9;
p(2).marginleft = 12;
p.margin = [10 8 0.5 0.5];
p.export('export_e', '-a1.4', '-rp');

% NB: when the margins are this tight, you may notice
% small differences in layout between the on-screen
% renderer, the PNG renderer, the EPS renderer.



%% (f)

% that's now exported at 600DPI, which is fine for most
% purposes. however, the matlab renderer you are using may
% not do nice anti-aliasing like some renderers. one way to
% mitigate this is to export at 1200 (or higher) DPI, but
% that makes for a very large figure file. an alternative is
% to ask panel to render at a higher resolution, then smooth
% back down to the specfied resolution. you'll have to wait a
% few seconds for the result. here, we'll smooth by factor
% 2. since this takes a little while, i don't usually do
% this until i'm preparing a manuscript for submission.
p.export('export_f', '-a1.4', '-rp/2');

% NB: this is brute force smoothing, and is not the same as
% anti-aliasing. nonetheless, i find the results can be
% useful.



%% (g)

% export by default is to PNG format - you may prefer EPS,
% in which case just indicate this to export (other formats
% are supported, too). in EPS format, smoothing won't be
% applied, so we can drop that option.
p.export('export_g', '-a1.4', '-rp', '-oeps');



