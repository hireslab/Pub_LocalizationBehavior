function plotRxnTime(array)   
%reaction time is defined as the mean time from first touch to first lick
%after first touch
grxnT = cell(length(array),1); 

rxntime = zeros(1,length(array)); 

for i  = 1:length(array)
        pOnset = round(array{i}.meta.poleOnset(1)*1000);
        touch = zeros(array{i}.k,1); 
        lix = zeros(array{i}.k,1); 
        
        for k = 1:array{i}.k
            touch(k) = min([find(array{i}.S_ctk(9,pOnset:4000,k)==1,1) 4000])+pOnset;
            lix(k) =min([find(array{i}.S_ctk(16,touch(k):4000,k)==1,1) 4000])+touch(k);
        end
%         lix(lix==4000+pOnset+samplingPeriod)=nan;
        touch(touch==4000+pOnset)=nan;
        lix(lix>=4000)=nan;
        rxntimetmp = lix-touch;

        grxnT{i} = rxntimetmp;
        rxntime(i) = nanmean(rxntimetmp(rxntimetmp>0));
        
end

%RXN TIME
figure(25);clf
scatter(rxntime,ones(1,length(array)),'markerfacecolor',[.8 .8 .8],'markeredgecolor',[.8 .8 .8]);
hold on; errorbar(mean(rxntime),1,std(rxntime),'horizontal','ko','markerfacecolor','k','markeredgecolor','k','markersize',20)
set(gca,'ylim',[.5 1.5],'ytick',[],'xtick',0:250:1250,'xlim',[0 1250])
xlabel('reaction time (ms)')

set(gcf, 'Units', 'pixels', 'Position', [250, 250, 500, 200]);

%RXN time X trialoutcome
% figure(581);clf
% color = {'b','k','g','r'};
% for i = 1:length(array)
%     subplot(3,5,i)
%     c_rxn = grxnT{i}; 
%     
%     hit = intersect(find(array{i}.meta.trialType==1), find(array{i}.meta.trialCorrect==1));
%     miss = intersect(find(array{i}.meta.trialType==1), find(array{i}.meta.trialCorrect==0));
%     FA = intersect(find(array{i}.meta.trialType==0), find(array{i}.meta.trialCorrect==0));
%     CR = intersect(find(array{i}.meta.trialType==0), find(array{i}.meta.trialCorrect==1));
%     
%     
%     rxn_mat = nan(max([numel(hit);numel(miss);numel(FA);numel(CR)]),4);
%     rxn_mat(1:length(hit),1) = c_rxn(hit); 
%     rxn_mat(1:length(miss),2) = c_rxn(miss);
%     rxn_mat(1:length(FA),3) = c_rxn(FA);
%     rxn_mat(1:length(CR),4) = c_rxn(CR);
%     
%     for g = [1  3 ]
%         hold on; errorbar(g,nanmean(rxn_mat(:,g)),nanstd(rxn_mat(:,g)),[color{g} 'o']);
%     end
%     set(gca,'xlim',[0 4],'xtick',[1  3 ],'xticklabel',{'hit','fa'})
%     
%     g_rxnmat{i} = rxn_mat; 
% end
    


