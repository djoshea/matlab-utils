LATEST VERSION: MClust 4.3

MClust-4.3.02
Colored buttons for ease of use.

MClust-4.3.01
Added EraseTfiles button (added EraseTfiles method in MClustData object)
Made sure clearing Tfiles also clears WV and CQ whether called from EraseTfiles or other methods
Put AreYouSure question in Clear Workspace as well.
Fixed bug that .t64 was not writing in 64-bit resolution
Added raw64 and raw32 saving parameters for those that want

MClust-4.3
MClust assumes that data is stored as Matlab doubles.  Added code to AutoCorr and CrossCorr to ensure this.

MClust-4.2.04
Fixed .clu loading problem (was using fn instead of fullfile(fd,fn))

MClust-4.2.03
Fixed KK loading so that to handle KKmat -> clu calling correctly.

MClust-4.2.02
Fixed KK loading so that it starts loading from current TTdn directory.  (Allows you to move FD directories as necessary.)
Fixed KK loading so that it tries KKmat if they exist.  Otherwise, tries Clu. 
Fixed KK loading so that it can either work from KKmat or Clu.  Clu assumes spikes are 1:n.
Changed KK loading so that it tries to load all neural waveforms first.  That's faster.
Fixed CheckCluster so that it uses interpreter none

MClust-4.2.01
Disp mistated number of KK files being written.  Fixed

MClust-4.2
Fixed KlustaKwik splitting process - was not including last set of spikes!  i.e. if had 750k spikes and asked to split at 400k, only included 1 set of 1:400k, now does 2 sets correctly.  Fixed.
Discovered that KKread doesn't work with splitting - had to create KKmat file to store and read it correctly. Fixed.
Discovered that was writing features incorrectly (used dlmwrite instead of fprintf for #features).  Fixed

MClust-4.1.5
Added KKwik next/prev buttons

MClust-4.1.4
Fixed KKlust call bug.  Calling KKlust defaulted to only using 2 features rather than full set. 
Changed RunClustBatch and KKwik call from clusters.

MClust-4.1.3
Added histcn to new "OutsideCode" directory.
RunClustBatch now checks that channelValidity is properly sized.

MClust-4.1.2
Continued errors in ApplyConvexHulls.  Fixed.

MClust-4.1.1
Features were objects and so carried over incorrectly when trying to convert convex hulls to a new data set. Added a new function to ApplyConvexHullsFromAFile

MClust-4.1
Added TDT loading engine that is not based on file dialog boxes.

MClust-4.0.8
Fixed minor tail bug in CrossCorr.c.  Remexed Crosscorr.mex64, but cannot remex 32.

MClust-4.0.7
Added "UseFileDialog" to MCS and to MainWindowClass to accomodate TDT
Tetrode loading can provide changes to names and extensions using the "get" mechanism

MClust-4.0.6
Added "AddSpikesByGaussian".
Fixed bug in Finding Loading Engines

MClust-4.0.5
CheckCluster skips empty clusters

MClust-4.0.4b
Fixed bug in peaks plot in checkcluster.  Now only tries to plot tetrodes.

MClust-4.0.4
RunClustBatch now subsets when more than 1e6 spikes
Changed Loading Engine definition so that there is new functionality:
  If a LoadingEngine provides "CV = LoadingEngine('get','ChannelValidity')" 
  and "xt = LoadingEngine('get','ExpectedExtension')" then the CV and XT will be changed 
  in the main MClust window.
  To make LoadSE_... and LoadTT_... comply with it, created .m wrapper functions for it.
Fixed bug in AverageWaveform - with 1 channel, Matlab's squeeze has a different functionality.
LimitSpikesByWaveforms no longer assumes 4 channels.
Fixed CheckClusters not to choke when given <4 channels.

MClust-4.0.3
Added CreateClusterFromTFiles
Added EvalOverlap

MClust-4.0.2 2013-12-16
Added Valley, Peak6to11 features

MClust-4.0.2 2013-12-12
Upgraded Klustakwik to version 3.0.
Fixed sWV bug in AverageWaveform when there was only one spike in the cluster.
Allowed cancel when looking for Klustakwik components.
Fixed bug in ShowWaveforms
Display window stays zoomed if just doing simple things like adding clusters.  You can click redraw axes to zoom out
Doesn't try to write 0 t files
Windows now remember where they were placed so when come back it sets it up like you like
Sped up CheckCluster slightly
Fixed can't-display-bug when feature was all 0

MClust-4.0.001: 2013-11-07
Fixed bug in KKCluster to allow losecomparison when no focus button yet


===========================================================================
BETA RELEASE 2013-11-06
===========================================================================

Initiated 2012-12-19
Moved all parms to a global structure "MClustSettings"
Moved all data to a global structure "MClustData"
Created MClustMainWindowClass to hold main window
Created ListBoxPair class to take care of features list

Restarted 2012-12-20
MClustSettings single instance
MClustData single instance

2012-12-21
MClust window -> handle class
Calculate Features and put into Data Class
Cannot normalize features - you shouldn't do that anyway.
Channel Validity boxes

Manual cutter 
- basic plots
- colors and clusters
- clusters display themselves

2012-12-22
Moved Clusters to +ClusterTypes package under +MClust
Add cluster, select cluster type to add
- ClusterTypeFunctions
- AddPoints/precut (use matlab's in polygon - doesn't require convexhull, but include add-by-chull)
- Create abstract cluster subclass that is DisplayableCluster

2012-12-23
- Loading/Saving Clusters
- Exit Cutter
- Basic ClusterOptions, ShowHistISI, ShowAverageWaveform
- Close all windows with Tag=MCS.DeleteableFigureTag
- Undo/Redo, used new UndoSystem class
- Made Cutter SingleInstance
- CutterOptions

----> Changed to have a singleinstance of a global variable
"MClustInstance" which contains links to Settings, Data, MainWindow
- this has solved the multiple cutters problem.

2012-12-25
Clusters plot themselves on axes
Autosave in MCCutter
ClusterQuality
Write T files
Write T,WV,CQ files
CheckCluster
  - need to add autocorrs
CheckAllClusters
ShowAll
HideAll
Pack
Removed Listeners

2012-12-26
ClusterScrollbar to have more than 20 clusters
RunClustBatch
general cutter class, make all cutters export/import

2012-12-27
DrawPolygonOnAxes(Axes, returnConvexHull)
DisplayableCluster.RemoveAccessToCutterFuncs
Append/Overwrite on export
KKwikCluster stores AvgWaveform, ISIhistogram, Keep/Not
KKwik selection cutter
Windows to view (AvgWaveform, HistISI, Axes with marker plotted larger)
KK Mergable clusters

2012-12-29
- limit to polygon/chull
- selectanddeleteclusters
- addfromunaccountedpoints

- mcconvexhull
- mccluster < mcprecut < mcconvexhull

2012-12-30 
Revamped copy and convert
Convert done!
autocorr - checkclust done!
xcorr 
=== first test (PSR)
no abstract clusters (does not work with 2011)
extensive bug fixes in KKwikCutter
ISI in KKcutter

2013-01-02
look for cutoffness
waveformwaterfall
Keep focus when redraw clusters on KKwikCluster
- requires KKwikCutter remember whoHasFocus
Change deletefcn callback to CloseRequestFcn - should be cleaner than delete

2013-01-03
RunKKwik on a cluster - done in a single function

2013-01-04
starting clustertype = Spikelistcluster
ShowWaveforms (with scrollbar to control how many waveforms to show)
MergeWith
limits on waveforms
- added WaveformLimit class (should I add a FeatureLimit class for convexhull cluster?

2013-03-11
Added FD directory to RunClustBatch

2013-03-13
Added BestSubplots
Added CompareAverageWaveforms (Manual Cutter)
In CheckCluster: changed FR to report mean dt (not median)
In MergeByAverageWaveform: changed to show actual log(MSE)
Added RemoveDoubles (SpikeList Cluster)
Fixed bug in saving .clusters files with .t files (wasn't saving correct extension)

2013-03-19
Added SplitByConvexHull, SplitByPolygon.
Moved RunKKWikOnOneCell to old system
MAJOR CHANGE: Undo now copies if can.  SOLVES PROBLEM: Clusters are
 handles.  This means that Undo has to do a  
 deep copy.  Undo system does not work!  FIXED.
MAJOR CHANGE: Cutters were using handles to clusters.  Now copies
them.

2013-03-20
Changed format of .t files saving.  Now saves in correct Neuralynx-.t format

2013-08-06
Fixed bug in Cutter.  Was not storing Markers correctly.

2013-08-14
Added BestProjectionCutter.  
Entailed several other smaller changes, including ability to store Features in Memory, and minor mods throughout.

2013-08-15
Changed Stats and Utils to +MClustStats and +MClustUtils so is all packaged correctly.
CutOnBestProjection - set different paths through "projectionX.m"
Condor RunClustBatch works.
KlustaKwik Cutter - MergeWaveforms displays both correlation and MSE

2013-08-19
KlustKwik clusters start with KK %02d as merge set

2013-08-20
LimitSpikesByWaveforms now reports # waveforms
ShowCrossCorr now uses Cutter's get names function
Merge now renames to sums of names
Fixed SetAssociatedCutter on BestCutterProjection export

2013-08-26
CrossCorr now works with multiple clusters
MergeWith now has parameters to change.
CompareAverageWaveforms now has parameters to change.

2013-08-27
Now can toggle unaccounted for only in ZeroCluster
ISI histogram now informs if spikes < 2ms
Limit by waveform can show individual colors
ShowWaveforms can show individual colors

2013-09-06
SelectKKwik:AvgWV, the y-axis changes scale for each cluster. - FIXED

2013-09-10
Fixed MergeSet errors in MergeByAverageWaveforms

2013-09-26
MClust now exits more gracefully after a crash.
Improved display in KKwikCutter
created nonmodal_listdlg function
Added showing clusters to KKwikMerge
Made listdlg in KKwikMerger nonmodal
MAJOR change to merge waveforms.  Merge now done by typing.  Windows just display clusters or waveforms.  No more need for nonmodal listdlg

2013-10-28
Redesigned KK merge system to be more similar to MClust-3.5

2013-11-03
Fixed bug using Foreground color of color button to reset KKCluster when losing focus.  Should have been Background color.
