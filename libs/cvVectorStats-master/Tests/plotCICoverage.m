function plotCICoverage( ciNames, coverageCell, trueValues )
    figure('Position',[680   827   753   271]);
    for c=1:length(coverageCell)
        subplot(1,length(coverageCell),c);
        hold on;
        for d=1:length(trueValues)
            [p,CI] = binofit(sum(coverageCell{c}(d,:)), length(coverageCell{c}(d,:)));
            plot(trueValues(d),p,'ko','LineWidth',2);
            plot([trueValues(d),trueValues(d)],CI,'k-','LineWidth',2);
        end
        xlabel('True Values');
        ylabel('Coverage');
        title(ciNames{c});

        xlim([trueValues(1)-1,trueValues(end)+1]); 
        ylim([0,1]);
        set(gca,'FontSize',14);
    end
end

