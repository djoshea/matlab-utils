function plotPermutationTestResults( methodNames, significanceCell, trueValues )
    figure('Position',[680   827   753   271]);
    for c=1:length(significanceCell)
        subplot(1,length(significanceCell),c);
        hold on;
        for d=1:length(trueValues)
            [p,CI] = binofit(sum(significanceCell{c}(d,:)), length(significanceCell{c}(d,:)));
            plot(trueValues(d),p,'ko','LineWidth',2);
            plot([trueValues(d),trueValues(d)],CI,'k-','LineWidth',2);
        end
        xlabel('True Values');
        ylabel('Proportion of Runs with p<0.05');
        title(methodNames{c});

        xlim([trueValues(1)-1,trueValues(end)+1]); 
        ylim([0,1]);
        set(gca,'FontSize',14);
    end
end

