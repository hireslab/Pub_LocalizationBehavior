%% DECOMPOSING THETA AT TOUCH TO TIMING COMPONENTS:
% Output is sorted by trialOutcome. Within each trialOutcome theta at touch
% is decomposed to column :1) timeTotouch from trough :2) theta at trough
% :3) velocity measured in theta/ms :4) trialNumber if needed


function [hx,FAx,CRx,mx] = touchTimeDecomp(array,touchOrder)


% RAW VARIABLES
[P] = findMaxMinProtraction(array,1);
[objmask]= touchmasks(array);
mask = objmask.availtolick;
thetas = squeeze(array.S_ctk(1,:,:));
phases = squeeze(array.S_ctk(5,:,:));
touchIdx = [find(array.S_ctk(9,:,:)==1);find(array.S_ctk(12,:,:)==1)];
touchIdx= intersect(touchIdx,find(mask==1));
alltroughs = P.troughidx;
troughsIdx = intersect(alltroughs,find(mask==1));

%Filter for only protraction touches
proTouchFilt =phases(touchIdx)<0;
touchIdx = touchIdx(proTouchFilt);

%TrialType
hits = find(double(array.meta.trialType==1).*double(array.meta.trialCorrect==1));
FA = find(double(array.meta.trialType==0).*double(array.meta.trialCorrect==0));
CR = find(double(array.meta.trialType==0).*double(array.meta.trialCorrect==1));
miss = find(double(array.meta.trialType==1).*double(array.meta.trialCorrect==0));


ivel = squeeze(array.S_ctk(2,:,:));


matches = zeros(length(touchIdx),2);
for k = 1:length(touchIdx)
    troughPair = max([0 find(troughsIdx<touchIdx(k),1,'last')]);
    matches(k,:) = [troughsIdx(troughPair) touchIdx(k)];
end

%Filter to onset to touch times >100ms as that is very unlikely
times = matches(:,2)-matches(:,1);
if ~isempty(find(times>500))
    matches(find(times>500),:) = [];
end

times = matches(:,2)-matches(:,1);
matchestnums = ceil(matches./array.t);
onset = thetas(matches(:,1));
touchtheta = thetas(matches(:,2));
vel = ((touchtheta-onset)./times);
ivels = ivel(touchIdx);


meanT = cell(1,array.k);
meanOnset = cell(1,array.k);
meanVel = cell(1,array.k);
meaniVel = cell(1,array.k); 


for g = 1:array.k
    selTrials = find(matchestnums(:,1)==g);
    if ~isempty(selTrials)
        
        if strcmp(touchOrder,'first')
            selTrials = selTrials(1);
        elseif strcmp(touchOrder,'last')
            selTrials = selTrials(end);
        elseif strcmp(touchOrder,'all')
            selTrials = selTrials;
        end
        
        meanT{g} = times(selTrials);
        meanOnset{g} = onset(selTrials);
        meanVel{g} = vel(selTrials);
        meaniVel{g} = ivels(selTrials);
    end
end

hx = [meanT(hits)' meanOnset(hits)' meanVel(hits)' meaniVel(hits)' num2cell(hits)'];
FAx = [meanT(FA)' meanOnset(FA)' meanVel(FA)' meaniVel(FA)' num2cell(FA)'];
CRx = [meanT(CR)' meanOnset(CR)' meanVel(CR)' meaniVel(CR)' num2cell(CR)'];
mx = [meanT(miss)' meanOnset(miss)' meanVel(miss)' meaniVel(miss)' num2cell(miss)'];


%% Test to see if theta calculations are correct using time. 
% realT = touchtheta;
% calcT = (times.*vel)+onset;
% 
% figure(280);clf
% histogram(realT,[-20:1:40],'facecolor','r')
% hold on;histogram(calcT,[-20:1:40],'facecolor','b')
% legend('real theta','time decomposed calc theta')

%% % VISUALIZATION to see troughs, theta, and touch
%
% % RAW VARIABLES
% [P] = findMaxMinProtraction(array,1);
% [objmask]= assist_touchmasks(array);
% mask = objmask.availtolick;
% thetas = squeeze(array.S_ctk(1,:,:));
% phases = squeeze(array.S_ctk(5,:,:));
% touchIdx = [find(array.S_ctk(9,:,:)==1);find(array.S_ctk(12,:,:)==1)];
% touchIdx= intersect(touchIdx,find(mask==1));
% alltroughs = P.troughidx;
% troughsIdx = intersect(alltroughs,find(mask==1));
%
% %Filter for only protraction touches
% proTouchFilt =phases(touchIdx)<0;
% touchIdx = touchIdx(proTouchFilt);
%
%
% %Plotting for one random trial of theta, touch(red), and whisk
% %trough(green)
% xmin=1;
% xmax=array.k;
% trialIdx=round(xmin+rand(1,1)*(xmax-xmin));
%
% selranges = (trialIdx*array.t)+1:(trialIdx*array.t)+array.t;
% plotTouch = mod(intersect(touchIdx,selranges),array.t);
% plottroughs = mod(intersect(troughsIdx,selranges),array.t);
% plotthetas = thetas(selranges);
% figure(20);clf
% hold on; plot(plotthetas,'k')
% hold on; scatter(plotTouch,plotthetas(plotTouch),'ro')
% hold on; scatter(plottroughs,plotthetas(plottroughs),'go')
