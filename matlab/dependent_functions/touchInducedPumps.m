function touchInducedPumps(U)

timeThresh = 300; %in ms for viewing touches below a time; 

%TIPS
preDecisionMask = preDecisionTouchMat(U);
fts = cellfun(@(x) find(x==1),preDecisionMask,'uniformoutput',0);
tbts = cellfun(@(x) [x(2:end) ;nan] - x,fts,'uniformoutput',0); 
r_tbts = cellfun(@(x) x(x<timeThresh) ,tbts,'uniformoutput',0);

figure(230);clf
for i = 1:length(U)
    subplot(3,5,i)
    histogram(r_tbts{i},0:10:timeThresh)
    hold on; plot([18 18],[0 round(max(histcounts(r_tbts{i}))*1.2)],'-.k')
    set(gca,'ylim',[0 round(max(histcounts(r_tbts{i}))*1.2)])
end

suptitle('touch induced pumps')
xlabel('time from last touch (ms)')
ylabel('number of touches')