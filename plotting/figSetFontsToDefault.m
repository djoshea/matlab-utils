function figSetFontsToDefault(figh)

    szAx = get(0, 'DefaultAxesFontSize');
    szAxLabel = szAx * get(0, 'DefaultAxesLabelFontSizeMultiplier');
    szAxTitle = szAx * get(0, 'DefaultAxesTitleFontSizeMultiplier');
    szText = get(0, 'DefaultTextFontSize');
    fnAx = get(0, 'DefaultAxesFontName');
    fnText = get(0, 'DefaultTextFontName');

    if nargin < 1
        figh = gcf;
    end

    % find axes in figure
    axList = findobj(figh, 'Type', 'axes');

    for i = 1:numel(axList)
       ax = axList(i);

       ax.XLabel.FontSize = szAxLabel;
       ax.XLabel.FontName = fnAx;

       ax.YLabel.FontSize = szAxLabel;
       ax.YLabel.FontName = fnAx;

       ax.ZLabel.FontSize = szAxLabel;
       ax.ZLabel.FontName = fnAx;

       ax.Title.FontSize = szAxTitle;
       ax.Title.FontName = fnAx;

       textList = findall(ax, 'Type', 'text');
       for t = 1:numel(textList)
           text = textList(t);
           text.FontName = fnText;
           text.FontSize = szText;
       end
    end
    
    au = AutoAxis.recoverForAxis();
    if ~isempty(au)
        au.restoreDefaults();
        au.update();
    end
end