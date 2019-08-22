function mcc_scatters(mdl,BV)

% this function is for plotting the goodness of fit metric (MCC) for
% different models in mdl. It also compares mcc against metrics of standard
% accuracy and mouse accuracy.

features = fields(mdl.output.true_preds);
gcmat = cell(1,numel(features));
for b = 1:length(features)
    gcmat{b} = mdl.output.true_preds.(features{b});
end

mcc = zeros(numel(BV),numel(features));
accuracy = zeros(numel(BV),numel(features));
mouse_accuracy = zeros(numel(BV),numel(features));

for k = 1:numel(features)
    cmatcurr = gcmat{k};
    
    for rec = 1:length(cmatcurr)
        true = cmatcurr{rec}(:,2);
        predicted = cmatcurr{rec}(:,3);
        mcc(rec,k) = mccCalculator(true,predicted);
        
        %accuracy
        accuracy(rec,k) = mean(cmatcurr{rec}(:,3)==cmatcurr{rec}(:,2));
        mouse_accuracy(rec,k) = mean(BV{rec}.meta.trialCorrect);
    end
end


% mcc scatter plots
figure(100);clf
if numel(mdl.build_params.designvars) == 2 %plot two classifiers w/ unity line
    subplot(1,3,[1 2]); 
    scatter(mcc(:,1),mcc(:,2),'filled','markerfacecolor',[.8 .8 .8])
    yerr = std(mcc(:,2))./ sqrt(size(mcc,1));
    xerr = std(mcc(:,1))./ sqrt(size(mcc,1));
    hold on; errorbar(mean(mcc(:,1)),mean(mcc(:,2)),yerr,yerr,xerr,xerr,'ko')
    hold on; plot([0 1],[0 1],'-.k')
    set(gca,'xlim',[0 1],'ylim',[0 1],'xtick',0:.5:1,'ytick',0:.5:1)
    xlabel(features{1});
    ylabel(features{2});
    axis square
    title(['wilcoxon signed-rank test = ' num2str(signrank(mcc(:,1),mcc(:,2)))])
else %plot all other classifiers on a simple scatter 
    subplot(1,3,[1 2]);
    mccPlot = mcc(1:15,:);
    x = repmat(1:size(mccPlot,2),size(mccPlot,1),1);
    scatter(x(:),mccPlot(:),[],[.8 .8 .8],'markerfacecolor',rgb('DarkTurquoise'),'markeredgecolor',rgb('DarkTurquoise'))
    hold on; errorbar(1:size(mccPlot,2),mean(mccPlot),std(mccPlot)./sqrt(size(mccPlot,1)),'ko','linewidth',1)
    set(gca,'xlim',[.5 length(gcmat)+.5],'ytick',[-.5:.5:1],'xtick',1:length(gcmat),'ylim',[-.15 1],'xticklabel',features)
end



%% mcc vs accuracy
subplot(1,3,3);
scatter(mcc(:),accuracy(:)*100,[],'filled','k')
xlabel('mcc')
ylabel('model accuracy (%)')
lm = fitlm(mcc(:),accuracy(:));
set(gca,'ylim',[50 100],'ytick',0:25:100,'xtick',-1:.25:1)
hold on; plot(mcc(:),lm.predict*100,'k')
axis square
if strcmp(mdl.build_params.classes,'lick')
    title(['imbalanced classes (i.e., choice) rsq = ' num2str(lm.Rsquared.Ordinary) ] )
elseif strcmp(mdl.build_params.classes,'gonogo')
    title(['balanced classes (i.e., trial type) rsq = ' num2str(lm.Rsquared.Ordinary) ] )
end


% %binary counts vs touch counts vs mouse performance
% {'countsBinary','counts'}
if strcmp(mdl.build_params.designvars{1},'countsBinary')
    figure(43);clf
    yvals = [accuracy(:,1) mouse_accuracy(:,1)];
    xvals = repmat((1:size(yvals,2)),length(BV),1);
    semy = std(yvals) ./ sqrt(length(BV));
    
    scatter(xvals(:),yvals(:),[],rgb('DarkTurquoise'),'filled')
    hold on; errorbar(xvals(1,:),mean(yvals),semy,'ok')
    set(gca,'xlim',[.5 size(yvals,2)+.5],'xtick',1:size(yvals,2),'xticklabel',{'touch presence','mouse performance','# touches optimal'},'ylim',[.5 1],'ytick',[0:.25:1])
    ylabel('% correct')
    axis square
    
    signrank(mouse_accuracy(:,1),accuracy(:,1));
    title('figure 3F')
end




