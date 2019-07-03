function plotTrueVsEstimated( trialNums, estValuesStandard, estValuesUnbiased, trueValues, statName )
    %%
    colors = [0.8 0 0;
        0 0 0.8];
    lHandles = zeros(2,1);

    figure('Position',[680   838   659   260]);
    for t=1:length(trialNums)
        subplot(1,length(trialNums),t);
        hold on;

        if ndims(estValuesStandard)==2
            [mn,sd,CI] = normfit(estValuesStandard');
            [mn_un,sd_un,CI_un] = normfit(estValuesUnbiased');
        else
            [mn,sd,CI] = normfit(squeeze(estValuesStandard(t,:,:))');
            [mn_un,sd_un,CI_un] = normfit(squeeze(estValuesUnbiased(t,:,:))');
        end

        lHandles(1)=plot(trueValues, mn, 'Color', colors(1,:), 'LineWidth', 2);
        lHandles(2)=plot(trueValues, mn_un, 'Color', colors(2,:), 'LineWidth', 2);
        plot([0,max(trueValues)],[0,max(trueValues)],'--k','LineWidth',2);

        plot(trueValues', [mn'-sd', mn'+sd'], 'Color', colors(1,:), 'LineStyle', '--');
        plot(trueValues', [mn_un'-sd_un', mn_un'+sd_un'], 'Color', colors(2,:), 'LineStyle', '--');

        title([num2str(trialNums(t)) ' Trials']);
        xlabel(['True ' statName]);
        ylabel(['Estimated ' statName]);

        if t==length(trialNums)
            legend(lHandles, {'Standard','Cross-Validated'},'Box','Off');
        end
        axis tight;
        set(gca,'FontSize',16,'LineWidth',2);
    end
end

