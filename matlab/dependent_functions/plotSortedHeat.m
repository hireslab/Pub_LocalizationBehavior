function plotSortedHeat(U,mouseNumber,variableNumber)
%%
figure(300);clf
for i = mouseNumber
    pOnset = round(mean(U{i}.meta.poleOnset)*1000);
    samplingPeriod = 0;
    answerPeriod = pOnset+samplingPeriod;
    
    hit = intersect(find(U{i}.meta.trialType==1), find(U{i}.meta.trialCorrect==1));
    miss = intersect(find(U{i}.meta.trialType==1), find(U{i}.meta.trialCorrect==0));
    FA = intersect(find(U{i}.meta.trialType==0), find(U{i}.meta.trialCorrect==0));
    CR = intersect(find(U{i}.meta.trialType==0), find(U{i}.meta.trialCorrect==1));
    
    numel(miss)./numel(U{i}.meta.trialType)
    
    heat = squeeze(cat(3,U{i}.S_ctk(variableNumber,:,hit), nan(1,U{i}.t,2),...
        U{i}.S_ctk(variableNumber,:,FA), nan(1,U{i}.t,2),...
        U{i}.S_ctk(variableNumber,:,CR), nan(1,U{i}.t,2),...
        U{i}.S_ctk(variableNumber,:,miss), nan(1,U{i}.t,2)))';
    
    firstLick = squeeze(cat(3,U{i}.S_ctk(16,:,hit), nan(1,U{i}.t,2),...
        U{i}.S_ctk(16,:,FA), nan(1,U{i}.t,2),...
        U{i}.S_ctk(16,:,CR), nan(1,U{i}.t,2),...
        U{i}.S_ctk(16,:,miss), nan(1,U{i}.t,2)))';
    
    firstTouch = squeeze(cat(3,U{i}.S_ctk(9,:,hit), nan(1,U{i}.t,2),...
        U{i}.S_ctk(9,:,FA), nan(1,U{i}.t,2),...
        U{i}.S_ctk(9,:,CR), nan(1,U{i}.t,2),...
        U{i}.S_ctk(9,:,miss), nan(1,U{i}.t,2)))';
    
    
%     tt = find(nansum(U{i}.S_ctk(9,:,:),2)==1);
%     ntt = find(nansum(U{i}.S_ctk(9,:,:),2)==0);
%     lt = find(nansum(U{i}.S_ctk(16,pOnset:2500,:),2)>=1);
%     nlt = find(nansum(U{i}.S_ctk(16,pOnset:2500,:),2)==0);
%     
%     heat = squeeze(cat(3,U{i}.S_ctk(variableNumber,:,intersect(lt,ntt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(variableNumber,:,intersect(nlt,ntt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(variableNumber,:,intersect(lt,tt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(variableNumber,:,intersect(nlt,tt)), nan(1,U{i}.t,2)))';
%     
%     firstLick = squeeze(cat(3,U{i}.S_ctk(16,:,intersect(lt,ntt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(16,:,intersect(nlt,ntt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(16,:,intersect(lt,tt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(16,:,intersect(nlt,tt)), nan(1,U{i}.t,2)))';
%     
%     firstTouch = squeeze(cat(3,U{i}.S_ctk(9,:,intersect(lt,ntt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(9,:,intersect(nlt,ntt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(9,:,intersect(lt,tt)), nan(1,U{i}.t,2),...
%         U{i}.S_ctk(9,:,intersect(nlt,tt)), nan(1,U{i}.t,2)))';
    
    figure(300);clf
    imagesc(heat(:,1:4000))
    hold on

    for j = 1:size(firstLick,1)
        plot(max([-2000 find(firstLick(j,answerPeriod:end)==1,1)]+answerPeriod),j,'mo','markersize',4)
        plot(max([-2000 find(firstTouch(j,pOnset:end)==1,1)]+pOnset),j,'w.')
    end
    plot([pOnset pOnset],[0 U{i}.k+10],'-.w')
    set(gca,'xlim',[0 4000],'xtick',0:1000:4000,'ytick',[])
    axis xy
    colorbar
end
