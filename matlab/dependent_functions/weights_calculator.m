%Producing normalized odds ratios to compare weights between
%features

fields = fields(mdl.output.weights);
for k = 1:length(fields)
    
    currWeight = mdl.output.weights.(fields{k});
    
    if size(mdl.input.(fields{k}).DmatX{1},2)>1
        [nor] = ConvertToOddsRatio(currWeight,mdl.learn_params.cvKfold);
        
        figure(548);clf
        for e=1:size(nor,1)
            scatter(ones(1,length(currWeight))*e,nor(e,:),[],[.8 .8 .8],'filled')
            semnor = nanstd(nor(e,:))./sqrt(length(nor(e,:)));
            meannor = nanmean(nor(e,:));
            hold on; errorbar(e,meannor,semnor,'ko')
        end
        
        for b = 1:size(nor,2)
            hold on;plot(1:size(nor,1),nor(:,b),'color',[.8 .8 .8])
        end
        
        
        hold on; plot(1:size(DmatX,2),mean(nor,2),'-k')
        hold on;plot([1 size(DmatX,2)],[0 0],'-.k')
        set(gca,'xlim',[0.75 size(nor,1)+.25],'ylim',[-1 1],'xtick',[1:size(nor,1)],'ytick',-1:.5:1)
        
        
        [p,~,stats]=anova1(nor',[],'off');
        pcomp = multcompare(stats,[],'off')
        
    end
end
