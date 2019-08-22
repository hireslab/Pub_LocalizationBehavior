function peakProtractionFeature(U)

clearvars -except U

%Identify indices of peak protractions 
for i = [1:15]
    [w] = findMaxMinProtraction(U{i},5,'sampling');
    whisks(i) = w;
end

for i = 1:length(U)
    
    % Find theta at the discrimination boundary using touch indices 
    ppoles = nan(U{i}.k,50);
    pOnset = round(mean(U{i}.meta.poleOnset)*1000);
    %find touch indices 
    for b = 1:U{i}.k
        touchIdx = [find(U{i}.S_ctk(9,:,b)==1) find(U{i}.S_ctk(12,:,b)==1)];
        if ~isempty(touchIdx)
            tmpThetas = U{i}.S_ctk(1,touchIdx,b);
            ppoles(b,1:length(tmpThetas)) = tmpThetas;
        end
    end
    %fit 2nd order polynomial to touches to identify feature at
    %discrimination bondary 
    polyinputs = sortrows([U{i}.meta.motorPosition'  ppoles(:,1)]);
    polyinputs(isnan(polyinputs(:,2)),:)=[];
    [coeff, ~ , mu] = polyfit(polyinputs(:,1),polyinputs(:,2),2);
    dbtheta = polyval(coeff,mean(U{i}.meta.ranges),[],mu);
    
    
    whisks(i).whisktimes = mod(whisks(i).peakidx,U{1}.t);
    
    peaks{i}= whisks(i).peakidx;
    ttwtheta{i} = nan(U{i}.k,30);
    ttwsp{i} = nan(U{i}.k,30);
    ttwamp{i} = nan(U{i}.k,30);
    ttwtheta_pretouch{i} = nan(U{i}.k,30);
    
    %for each trial 
    for k = 1:U{i}.k
        % identify lick and touch index
        lix(k) = min([find(U{i}.S_ctk(16,pOnset:2500,k)==1,1) 2500])+pOnset;
        touch(k) =min([find(U{i}.S_ctk(9,pOnset:2500,k)==1,1) 2500])+pOnset;
        
        %find whisks before the first lick 
        wtind = find(whisks(i).trialNums==k);
        keepidx =  whisks(i).whisktimes(wtind)<lix(k);% &whisks(i).whisktimes(wtind)<touch(k);
        
        %find feature of the peak of each whisk (theta is relative to
        %discrimination boundary)
        ttwtheta{i}(k,1:sum(keepidx)) = whisks(i).theta(wtind(keepidx))-dbtheta;
        ttwsp{i}(k,1:sum(keepidx)) = whisks(i).setpoint(wtind(keepidx));
        ttwamp{i}(k,1:sum(keepidx)) = whisks(i).amp(wtind(keepidx));
        
        %find whisks features pre and post touch
        keepidx_pretouch =  whisks(i).whisktimes(wtind)<lix(k) & whisks(i).whisktimes(wtind)<touch(k);
        ttwtheta_pretouch{i}(k,1:sum(keepidx_pretouch)) = whisks(i).theta(wtind(keepidx_pretouch));
        
    end
    
    %Build mean of each feature across the population 
    mean_theta_go{i} =  ttwtheta{i}(find(U{i}.meta.trialType==1),:);
    mean_theta_nogo{i} = ttwtheta{i}(find(U{i}.meta.trialType==0),:);
    
    mean_amp_go{i} =  ttwamp{i}(find(U{i}.meta.trialType==1),:);
    mean_amp_nogo{i} = ttwamp{i}(find(U{i}.meta.trialType==0),:);
    
    mean_sp_go{i} =  ttwsp{i}(find(U{i}.meta.trialType==1),:);
    mean_sp_nogo{i} = ttwsp{i}(find(U{i}.meta.trialType==0),:);
    

end

%Concatenate values into matrix
allvals = {cat(1,mean_theta_go{:}),cat(1,mean_theta_nogo{:}),...
    cat(1,mean_amp_go{:}),cat(1,mean_amp_nogo{:}),...
    cat(1,mean_sp_go{:}),cat(1,mean_sp_nogo{:})};

%Compile confidence intervals set at 95%
for k = 1:size(allvals,2)
    selvals = allvals{k};
    for g = 1:size(selvals,2)
        x=selvals(:,g);
        SEM = nanstd(x)/sum(~isnan(x));               % Standard Error
        ts = tinv([0.025  0.975],sum(~isnan(x))-1);      % T-Score
        cibin{k}(g,:) = ts.*SEM;   %confidence intervals
    end
    cibin{k} = cibin{k} + [nanmean(selvals)' nanmean(selvals)'];
    stdbin{k} = [nanstd(selvals)' -nanstd(selvals)'] + [nanmean(selvals)' nanmean(selvals)'];
end

%% Plotting for whisk features across the population 
bin = stdbin;
figure(34);clf
subplot(3,1,1)
plot(nanmean(cat(1,mean_theta_go{:})),'bo-')
hold on; plot(nanmean(cat(1,mean_theta_nogo{:})),'ro-')
hold on;plot(bin{1}(:,1),'b-');plot(bin{1}(:,2),'b-')
hold on
hold on;plot(bin{2}(:,1),'r-');plot(bin{2}(:,2),'r-')
set(gca,'xlim',[0 10])
ylabel('Theta rel. to db')
legend('go+std','nogo+std')

subplot(3,1,2)
ylabel('Amplitude')
plot(nanmean(cat(1,mean_amp_go{:})),'bo-')
hold on;plot(bin{3}(:,1),'b-');plot(bin{3}(:,2),'b-')
hold on
plot(nanmean(cat(1,mean_amp_nogo{:})),'ro-')
hold on;plot(bin{4}(:,1),'r-');plot(bin{4}(:,2),'r-')
set(gca,'xlim',[0 10])
ylabel('Amplitude')

subplot(3,1,3)
plot(nanmean(cat(1,mean_sp_go{:})),'bo-')
hold on;plot(bin{5}(:,1),'b-');plot(bin{5}(:,2),'b-')
hold on
plot(nanmean(cat(1,mean_sp_nogo{:})),'ro-')
hold on;plot(bin{6}(:,1),'r-');plot(bin{6}(:,2),'r-')
set(gca,'xlim',[0 10])
ylabel('Setpoint')
xlabel('whisk number in trial')

suptitle('Fig 3D')

