function mesdplot(x,groupIx,nSample,factor,isDep,fName,contrast)
% ** function mesdplot(x,groupIx,nSample,factor,isDep,fName,contrast)
% is an accessory function for mes2way.m which plots data for a twoway
% factorial analysis. This function is meant to be called from within
% mes2way.m, therefore there are neither explanations of input variables
% nor error checks here as they would be redundant. If you use it from
% outside mes2way make sure the input variables are properly shaped.
% Specifics:
% - each group of samples resides in one subplot
% - levels of factor 1 down the columns
% - levels of factor 2 along the rows
% - samples are circles, group mean is a horizontal line
% - dependent (repeated measures) data are depicted with individual colors
% - background color of the subplots reflects sign and value of contrast
%   weights (if they were specified)
% - levels of factors are written in upper left corner of each subplot

% -------------------------------------------------------------------------
% Measures of Effect Size Toolbox Version 1.4, January 2015
% Code by Harald Hentschke (University of Tübingen) and 
% Maik Stüttgen (University of Bochum)
% For additional information see Hentschke and Stüttgen, 
% Eur J Neurosci 34:1887-1894, 2011
% -------------------------------------------------------------------------

% ------- PART I: PREPARATORY WORKS ----------
% total number of groups
nGroup=numel(nSample);
% number of factors
nL1=factor(1).nLevel;
nL2=factor(2).nLevel;
%  max & min value in whole data set to determine axis limits
mima=[min(x(:)) max(x(:))];
% ...stretched a bit  so that all data points are fully contained in plot
mima=mima+diff(mima)*[-.1 .1];
% maximal group (cell) sample size within data set
maxNs=max(nSample(:));
% define colors for individual data points in case of dependent data
switch num2str(isDep')'
  case '11'
    % completely within-subjects: sample sizes are equal in all groups
    cm=colorcube(nSample(1));
  case '10'
    % repeated measures along first factor:
    % cumulative sum of sample sizes needed for... 
    cumSampleSize=[0 cumsum(nSample(1,:))];
    % ...indexing this colormap
    cm=colorcube(cumSampleSize(end));
  case '01'
    % repeated measures along second factor:
    cumSampleSize=[0 cumsum(nSample(:,1))'];
    cm=colorcube(cumSampleSize(end));
  otherwise
    % we don't need a colormap
    cm=[];
end
% define markersize depending on average number of samples per cell
% (empirical values, change according to gusto)
ms=3+7*exp(-mean(nSample(:))*.02);
% set random number generator to fixed state (old syntax for downward
% compatibility - use rng('default') for newer Matlab versions)
rand('seed',0);
% abscissa values: centered at zero; horizontal spread depending on max
% number of samples
absci=(rand(maxNs,1)-.5)*maxNs/(maxNs+10);
% expand contrast weights (makes plotting below easier)
if contrast.do
  switch contrast.type
    case 'main1'
      contrast.weight=repmat(contrast.weight,1,nL2);
    case 'main2'
      contrast.weight=repmat(contrast.weight,nL1,1);
    otherwise
      % do nothing: contrast weights are already handily shaped
  end
end
      
% ------- PART II: PLOT ----------
figure
% defaults for all axes on plot
set(gcf,'DefaultlineMarkerSize',ms)
set(gcf,'DefaultaxesFontSize',8)
set(gcf,'DefaulttextFontSize',8);
for r=1:nL1
  for c=1:nL2
    sph=subplot(nL1,nL2,(r-1)*nL2+c);
    hold on
    set(gca,'xtick',[],'ygrid','on','box','on'); 
    if any(isDep)
      % define which colors to use for individual samples depending on
      % which factor is repeated measures
      switch num2str(isDep')'
        case '11'
          % completely within-subjects (dependent) data: identical colors
          % of samples across all groups
          colorMapIndex=1:nSample(r,c);
        case '10'
          % repeated measures along first factor
          colorMapIndex=cumSampleSize(c)+1:cumSampleSize(c+1);
        case '01'
          % repeated measures along second factor
          colorMapIndex=cumSampleSize(r)+1:cumSampleSize(r+1);          
        otherwise
          error('something funny happened to isDep')
      end
      % plot individual samples
      for g=1:nSample(r,c)
        ph=plot(absci(g),x(groupIx{r,c}(g)),'o');
        % make outline color a darker version of fill color
        set(ph,'color',cm(colorMapIndex(g),:)*.5,'markerfacecolor',cm(colorMapIndex(g),:))
      end
    else
      % independent data: open black symbols
      ph=plot(absci(1:nSample(r,c)),x(groupIx{r,c}),'ko');
    end
    % plot mean as horizontal line
    line([-.3 .3],mean(x(groupIx{r,c})*[1 1]),'color','k','linewidth',2)
    % same scaling for all plots
    axis([-.55 .55 mima])
    if contrast.do
      % current contrast weight
      cw=contrast.weight(r,c);
      % axis color indicating sign and value of contrast weights (if
      % contrast is specified):
      if isfinite(cw)
        if cw>0
          % positive values in red (maximally reaching a somewhat blunted
          % hue)
          cCol=[1 1-cw 1-cw]*.7+.3;
        elseif cw<0
          % negative values in blue (ditto)
          cCol=[1+cw 1+cw 1]*.7+.3;
        else
          % zero contrast weights in light gray
          cCol=[.88 .88 .88];
        end
        set(gca,'color',cCol)
      end
    end
    % illustrate assignment of rows/columns to factors
    if r==1 && c==1
      title([factor(2).name ' --->'])
      ylabel(['<--- ' factor(1).name]); 
    end
    % finally, show levels of factors in upper left corner
    text(-.5, mima(2)-.1*diff(mima),...
      ['[' num2str(factor(1).level(r)) ',' num2str(factor(2).level(c)) ']']);
  end
end