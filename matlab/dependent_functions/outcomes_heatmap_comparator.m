function outcomes_heatmap_comparator(predictionMatrix)
% This function is used to generate a comparison of MCC between
% Hilbert+counts against angle+counts as seen in Figure 7 and Figure S4 of
% Cheung et al. 2019 
%
% INPUTS: 
% predictionMatrix - this is an output from outcomes_heatmap 
%
% OUTPUTS: 
% Figures that compare MCC values along with wilcoxon rank sum p-values
% between angle+counts and Hilbert+counts. 
%
% Date edited: 190625 by Jonathan Cheung

hilbert = predictionMatrix.mcc.all_trials_matrix;
[~,idx] = max(hilbert(:,1:3)');
for b = 1:length(idx)
    maxMCC(b) = hilbert(b,idx(b));
end

angleCounts = hilbert(:,end);
figure(11);clf
scatter(maxMCC,angleCounts,[],'filled','markerfacecolor',[.8 .8 .8])
hold on; scatter(mean(maxMCC),mean(angleCounts),'r','filled')
hold on;plot([0 1],[0 1],'-.k')
set(gca,'xlim',[0 1],'xtick',0:.25:1,'ytick',0:.25:1,'ylim',[0 1])
axis square
ylabel('AngleCounts');xlabel('MaxCounts')

figure(12);clf
for i = 1:3
    subplot(1,3,i)
    scatter(angleCounts,hilbert(:,i),[],'filled','markerfacecolor',[.8 .8 .8])
    yerr = std(angleCounts); 
    xerr = std(hilbert(:,i));
    hold on; errorbar(mean(angleCounts),mean(hilbert(:,i)),yerr,yerr,xerr,xerr)
    hold on;plot([0 1],[0 1],'-.k')
    set(gca,'xlim',[0 1],'xtick',0:.25:1,'ytick',0:.25:1,'ylim',[0 1])
    axis square
    ylabel('AngleCounts')
    if i ==1
        xlabel('PhaseCounts')
    elseif i == 2
        xlabel('AmpCounts')
    elseif i == 3
        xlabel('MidpointCounts')
    end
    p = signrank(hilbert(:,i),angleCounts);
    title(['signRank p = ' num2str(p)])
end

suptitle('All trials : Model Comparison')