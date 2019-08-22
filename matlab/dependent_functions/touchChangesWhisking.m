function [] = touchChangesWhisking(U)

%% BUILD DISTRIBUTION OF whisk number for TT and NTT
    
    for i = 1:length(U)
        
        [whisks] = findMaxMinProtraction(U{i},5,'avail2end');
        whisktnums = ceil(whisks.peakidx./U{i}.t);
        peaks= whisks.peakidx;
        ptheta = whisks.theta;
        
        
        touched = squeeze(nansum(U{i}.S_ctk(9,:,:)));
        idx_touch = find(touched==1);
        idx_notouch = find(touched==0);
        
        %finding med lick/median touch time 
        clear lix
        clear touch
        
        pOnset = round(U{i}.meta.poleOnset(1)*1000);
        samplingPeriod = 750;
        
        for k = 1:U{i}.k
            lix(k) =min([find(U{i}.S_ctk(16,pOnset+samplingPeriod:4000,k)==1,1) 4000])+pOnset+samplingPeriod;
            touch(k) = min([find(U{i}.S_ctk(9,pOnset:4000,k)==1,1) 4000])+pOnset;
        end
        medlt = median(lix(lix<4000));
        medt = median(touch(touch<4000));
        
        %%%%%%%%%%% POLE POSITIONS
        ppoles = nan(U{i}.k,50);
        for b = 1:U{i}.k
            touchIdx = [find(U{i}.S_ctk(9,:,b)==1) find(U{i}.S_ctk(12,:,b)==1)];
            if ~isempty(touchIdx)
                tmpThetas = U{i}.S_ctk(1,touchIdx,b);
                ppoles(b,1:length(tmpThetas)) = tmpThetas;
            end
        end
        
        % FOR CONTINUOUS
        polyinputs = sortrows([U{i}.meta.motorPosition'  ppoles(:,1)]);
        polyinputs(isnan(polyinputs(:,2)),:)=[];
        [coeff, ~ , mu] = polyfit(polyinputs(:,1),polyinputs(:,2),2);
        
        dbtheta = polyval(coeff,mean(U{i}.meta.ranges),[],mu);
        
        motors=[U{i}.meta.motorPosition'];
        pthetas = ppoles;
        db = dbtheta;
        
        %FIND ALL NUM OF WHISK POST FIRST TOUCH!
        ttpre = nan(length(idx_touch),20);
        ttpost = nan(length(idx_touch),20);
        for b = 1:length(idx_touch)
            tr = idx_touch(b);
            firstt = find(U{i}.S_ctk(9,:,tr)==1);
            
            tmp2=peaks(find(whisktnums==tr));
            thetapeaks = ptheta(find(whisktnums==tr));
            whisktimes = mod(tmp2,U{i}.t);
            
            pret = whisktimes<medt;
            postt = whisktimes>medt & whisktimes<medlt;
            
            ttpre(b,1:length(thetapeaks(pret))) = thetapeaks(pret)';
            ttpost(b,1:length(thetapeaks(postt))) = thetapeaks(postt)';
            
        end
        
        
        nttpre = nan(length(idx_notouch),20);
        nttpost = nan(length(idx_notouch),20);       
        for b = 1:length(idx_notouch)
            tr = idx_notouch(b);
            
            tmp2=peaks(find(whisktnums==tr));
            thetapeaks = ptheta(find(whisktnums==tr));
            whisktimes = mod(tmp2,U{i}.t);
            
            pret = whisktimes<medt;
            postt = whisktimes>medt & whisktimes<medlt;
            
            nttpre(b,1:length(thetapeaks(pret))) = thetapeaks(pret)';
            nttpost(b,1:length(thetapeaks(postt))) = thetapeaks(postt)';
        end
        
        
        ttprenum{i} = sum(~isnan(ttpre),2);
        nttprenum{i} = sum(~isnan(nttpre),2);
        ttpostnum{i} = sum(~isnan(ttpost),2);
        nttpostnum{i} = sum(~isnan(nttpost),2);
        
        
        ttpostthattouch = sum(ttpost>=repmat(nanmean(pthetas(idx_touch),2),1,size(ttpost,2)),2);
        
    end

%% PLOTTING
%Individual plots of whisking numbers 
figure(331);clf
for i = 1:length(U)
    
    subplot(5,3,i)
    tmp1= histogram(ttprenum{i},0:1:20,'facecolor','b','normalization','probability');
    hold on; tmp2=histogram(nttprenum{i},0:1:20,'facecolor','c','normalization','probability');

    probttpre(i,:) = tmp1.Values;
    probnttpre(i,:) = tmp2.Values;
    preKLindiv = kldiv(1:20,probttpre(i,:),probnttpre(i,:));
    text(5,.6,num2str(preKLindiv),'fontsize',10,'color','k')
    
    tmp3 = histogram(ttpostnum{i}+20,20:1:40,'facecolor','b','normalization','probability');
    hold on;tmp4=histogram(nttpostnum{i}+20,20:1:40,'facecolor','c','normalization','probability');
    
    probttpost(i,:) = tmp3.Values;
    probnttpost(i,:) = tmp4.Values;
    postKLindiv = kldiv(1:20, probttpost(i,:), probnttpost(i,:));
    text(25,.6,num2str(postKLindiv),'fontsize',10,'color','k')
    
    hold on;plot([20 20],[0 .8],'-k')
    set(gca,'xtick',[0 10 20 30],'xticklabel',[0 10 0 10 ],'ylim',[0 .8])
    
end
suptitle('Individual: pretouch | posttouch:lick')
xlabel('whisk number')
legend('touch','nontouch')

%Population Plotting
popttpre = cell2mat(ttprenum');
popttpost = cell2mat(ttpostnum');
popnttpre = cell2mat(nttprenum');
popnttpost = cell2mat(nttpostnum');

%calculating kullback=liebler divergence 
preKL = kldiv(1:20,mean(probnttpre),mean(probttpre));
postKL = kldiv(1:20,mean(probnttpost),mean(probttpost));

figure(33);clf
histogram(popttpre,0:1:20,'facecolor','b','normalization','probability','facealpha',1)
hold on;histogram(popnttpre,0:1:20,'facecolor','c','normalization','probability','facealpha',1)
text(5,.6,num2str(preKL),'fontsize',20,'color','k')

histogram(popttpost+20,20:1:40,'facecolor','b','normalization','probability','facealpha',1)
hold on;histogram(popnttpost+20,20:1:40,'facecolor','c','normalization','probability','facealpha',1)
hold on;plot([20 20],[0 .8],'-k')
text(25,.6,num2str(postKL),'fontsize',20,'color','k')

set(gca,'xtick',[0 10 20 30],'xticklabel',[0 10 0 10 ],'ylim',[0 .75],'ytick',0:.25:.75)
title('Population: pretouch | posttouch:lick')
xlabel('number of whisks')
ylabel('proportion of trials')
suptitle('Fig 3C')




