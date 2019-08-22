function learningCurves(behavDataLocation)

fileName = 'learning_struct';
if exist([behavDataLocation '\' fileName '.mat'],'file')
    load([behavDataLocation '\' fileName '.mat'])
else
    % wrap all behavioral data files
    [hist, info, ~] = bdatawrapper(behavDataLocation);
    clear O
    
    msnames = ones(length(hist),1);
    for d = 1:length(hist)
        msnames(d) = str2num(info{d}.SavingSection_MouseName(end-2:end));
        rewarded{d} = sign(diff(cell2mat(hist{d}.AnalysisSection_PercentCorrect)))==1;
        Motorranges(d) = [hist{d}.MotorsSection_no_pole_position_pos{end} - hist{d}.MotorsSection_yes_pole_position_ant{end}];
    end
    
    uniqueMouseNames = unique(msnames);
    
    for j = 1:length(uniqueMouseNames)
        idx=find(msnames==uniqueMouseNames(j));
        fullIdx = find(abs(Motorranges(idx))==min(abs(Motorranges(idx))));
        
        fullIdx = fullIdx(fullIdx > 3); %no session before session 3 can have a motor position with 0
        
        collatedrewards=[];
        for g=1:length(idx)
            if g == fullIdx(1)
                learning_struct.num_trials_b4_continuous(j) = numel(collatedrewards);
            end
            collatedrewards = [collatedrewards; rewarded{idx(g)}];
        end
        learning_struct.mat{j} = collatedrewards;
        
    end
    save('learning_struct','learning_struct')
end

%% Plotting Raw Behavioral Data - This will provide the curves for each individual mouse.

%DEFAULT PLOTTING PARAMS
smoothWindow = 200;
perfthresh=.75;
stretch = 1000; %trials to plot post learning threshold
%-----------------------------
catmat = nan(numel(learning_struct.mat),50000);
continuous_catmat = nan(numel(learning_struct.mat),50000);
non_learned = zeros(1,numel(learning_struct.mat));
learned_trial_all = zeros(1,numel(learning_struct.mat));

for i = 1:length(learning_struct.mat)
    smoothed = [smooth(learning_struct.mat{i},smoothWindow) ;nan(stretch,1)];
    
    AccThresh = find(smoothed>perfthresh); %find idx of > performance threshold
    crossIdx = find(AccThresh>learning_struct.num_trials_b4_continuous(i),1); %find idx during full continuous
    %IF MOUSE DOESNT REACH THRESHOLD, THIS PLOTTER IS USED TO ID WHAT THEIR
    %MAX PERFORMANCE WAS AND USE THAT AS THE LEARNED
    if isempty(crossIdx)
        non_learned(i) = 1;
        peakPerf = max(smoothed(learning_struct.num_trials_b4_continuous(i):end));
        AccThresh = find(smoothed>=peakPerf);
        crossIdx = find(AccThresh>learning_struct.num_trials_b4_continuous(i),1);
    end
    
    learnedtrial = AccThresh(crossIdx);
    backwards = fliplr(smoothed(1:learnedtrial+stretch)');
    %tossing out last 20 trials to clean up plots
    lastIdx = find(~isnan(backwards),1,'first');
    backwards(lastIdx:lastIdx+20)=nan;
    
    firstIdx = find(~isnan(backwards),1,'last');
    backwards(firstIdx-60:firstIdx)=nan;
    
    catmat(i,1:length(backwards)) = backwards;
    learned_trial_all(i) = learnedtrial;
    trimmed = flipud(smoothed(learning_struct.num_trials_b4_continuous(i):learnedtrial+stretch));
    trimmed(find(~isnan(trimmed),20,'first')) = nan; %nanning out ends due to smooth errors
    continuous_catmat(i,1:length(trimmed)) = trimmed;
end

%Plotting for all trials
forwards = fliplr(catmat);
figure(26);clf
subplot(3,1,[1 2])
plot(1:length(catmat),forwards,'color',[.8 .8 .8])
xlabel('Trials to expert (thousands)')
ylabel('Accuracy (%)')
set(gca,'xlim',[42000 50000],'xtick',[0:1000:50000],'xticklabel',fliplr((0-(stretch/1000):1:50-(stretch/1000))),'ytick',[0:.25:1],'yticklabel',[0:25:100],'ylim',[.25 1])
% hold on; plot(fliplr(continuous_catmat(~non_learned,:))','color','g') %learning curves for learners
% hold on; plot(fliplr(continuous_catmat(logical(non_learned),:))','color','r') %learning curves for non-learners
hold on; plot([0 50000],[perfthresh perfthresh],'-.k') %plotting expert line threshold
hold on; plot([0 50000],[.5 .5],'-.k') %plotting chance line threshold
hold on; plot(1:length(catmat),fliplr(nanmean(catmat)),'k')


%-----------------------------
% %Plotting number of trials required to reach learning threshold
figure(26);subplot(3,1,[3])
allends = learned_trial_all;
allends(2) = []; %removing one outlier of 23000 trials
scatter(allends,ones(1,length(allends)),[],'ko');
hold on; errorbar(mean(allends),1,std(allends),'horizontal','ko','markersize',15,'markerfacecolor','k')
set(gca,'xlim',[0 15000],'xtick',0:2000:15000,'xticklabel',0:2:20,'yticklabel',[],'ytick',[],'xdir','reverse')
xlabel('Trials to expert (thousands)')