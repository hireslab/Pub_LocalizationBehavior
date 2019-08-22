%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function will find the peak protraction of each whisk cycle within
% specific timepoints of a trial. I.e. Default is pole avail to first lick.
% 
% maskString vals = 'avail2lick' OR 'sampling'
%
% Will need to edit if you want to swap windows of where you want to look
% for peak protractions. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [P] = findMaxMinProtraction(array,ampthresh,varargin)

%% Find max theta excursion on each whisk cycle
    
    [objmask]= touchmasks(array);
    
    if nargin<3
        mask = ones(size(squeeze(array.S_ctk(1,:,:))));
    else
        maskString = varargin;
        if strcmp(maskString,'avail2lick')
            mask = objmask.availtolick;
        elseif strcmp(maskString,'sampling')
            mask = objmask.samplingp;
        elseif strcmp(maskString,'avail2end')
            mask = objmask.availend;
        end
    end
    
    
    amp_mask = ones(size(squeeze(array.S_ctk(3,:,:))));
    amp_mask(array.S_ctk(3,:,:)<ampthresh) = NaN; %amplitude mask used to filter out only periods of high whisking
    phase = squeeze(array.S_ctk(5,:,:));
    amp = squeeze(array.S_ctk(3,:,:));
    setpoint = squeeze(array.S_ctk(4,:,:));
    theta = squeeze(array.S_ctk(1,:,:));
    selectedPhase = mask.*amp_mask.*phase; %can add a mask here to adjust what time period to look at (i.e. pole avail to end trial mask)
    
    %if peak protractoin finding phases within -.1 and .1 as phase of 0 =
    %peak
    peakphases = find(selectedPhase>-.1 & selectedPhase<.1); %find all phases within this window
    
    %if trough protractoin finding phases within -.1 and .1 as phase of 0 =
    %peak
     troughphases = find(abs(selectedPhase)>3.14-.1 & abs(selectedPhase)<3.14+.1); %find all phases within this window
    
    
    samp_r=[-20:20];%look -20:20ms around those found phases
    
    %trimming indices that may fall out of range 
    peakphases=peakphases(peakphases+max(samp_r)<numel(theta));
    peakphases=peakphases(peakphases+min(samp_r)>0);
    
    troughphases= troughphases(troughphases+max(samp_r)<numel(theta));
    troughphases=troughphases(troughphases+min(samp_r)>0);
    
    
    
    pidx=repmat(peakphases,1,41)+repmat(samp_r,length(peakphases),1); %build indices
    tidx=repmat(troughphases,1,41)+repmat(samp_r,length(troughphases),1); %build indices
    
    %finding trough index
    minidx=zeros(1,size(tidx,1));
    for f = 1:size(tidx,1)
        [~,mintmp]=min(theta(tidx(f,:)));
        minidx(f)=samp_r(mintmp);
    end
   
    
    maxidx=zeros(1,size(pidx,1));
    for f = 1:size(pidx,1)
        [~,maxtmp]=max(theta(pidx(f,:)));
        maxidx(f)=samp_r(maxtmp);
    end
    
    P.peakidx=unique(peakphases+maxidx'); %this is the idx for peak protraction 
    P.troughidx = unique(troughphases+minidx'); %this is the idx for trough of protraction
    
    P.trialNums = floor(P.peakidx/array.t)+1;
    P.theta = [theta(P.peakidx)];
    P.phase = [phase(P.peakidx)];
    P.amp= [amp(P.peakidx)];
    P.setpoint = [setpoint(P.peakidx)];
    
    
    
    
%         %%
         %% test a trial to make sure that theta is aligned right
%             touchIdx = [find(array.S_ctk(9,:,:)==1);find(array.S_ctk(12,:,:)==1)];
%             
%             trial = 54; %shifted by 1 (ex. trial=0 ..> trial =1)
%             figure(trial+1);clf;plot(theta(:,trial+1));
%             xlabel('Time from Trial Start (ms)');ylabel('Whisker Position')
%         
%             validx=P.peakidx(floor(P.peakidx/array.t)==trial);
%             validtouchx = touchIdx(floor(touchIdx/array.t)==trial);
%             
%             excurx=round(((validx/array.t)-trial)*array.t);
%             touchexcurx=round(((validtouchx/array.t)-trial)*array.t);
%             
%             for i = 1:length(excurx)
%                 hold on; scatter(excurx(i),theta(excurx(i),trial+1),'ro')
%                
%             end
%             
%             for i = 1:length(touchexcurx)
%              hold on; scatter(touchexcurx(i),theta(touchexcurx(i),trial+1),'go','filled')
%             end
    %%
