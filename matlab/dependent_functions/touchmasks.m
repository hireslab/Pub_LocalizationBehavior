function [mask] = assist_touchmasks(array)    
% Function used to pull out masks based on touches and pole availability

% OUTPUT: 
% touchEx_mask = mask out all periods of touch 
% firsttouchEx_mask = mask out first touches wthin trials
% availtotrialend_mask = mask out periods from when pole rises to end of
% trial
% avail_mask = mask out periods from when pole is available 

%% this is used to mask out touches and allow analysis for phase, setpoint, and amplitude
    tmp=find(array.S_ctk(9,:,:)==1)/array.t;
    d = tmp-floor(tmp); %keep only decimals
    avail=round(min(d)*array.t); %pole available time in ms based on first touch 
    offset=round(array.meta.poleOffset*1000);
    offmax=find(offset>array.t);
    offset(offmax)=array.t;
   
    
    spikes = squeeze(array.R_ntk);
    
    licks = squeeze(array.S_ctk(16,:,:))';
    
    fl = [];
    for i = 1:size(licks,1)
        fl(i) = min([find(licks(i,:)==1) array.t]);
    end
    fl2 = fl(fl<3000);
    fls = sort(fl2);
    flninety= fls(ceil(numel(fls)*.9));
    fl(fl==array.t)=flninety;
    
    
    firsttouchIdx = [find(array.S_ctk(9,:,:)==1)];
    firsttouchOffIdx = [find(array.S_ctk(10,:,:)==1)];
    touchOnIdx = [find(array.S_ctk(9,:,:)==1); find(array.S_ctk(12,:,:)==1)];
    touchOffIdx = [find(array.S_ctk(10,:,:)==1); find(array.S_ctk(13,:,:)==1)];
    if touchOffIdx<(numel(spikes)-70) %ensures that offset is within index boundaries
        touchOffIdx = touchOffIdx+70;
    end
    
    firsttouchEx_mask = ones(size(squeeze(array.S_ctk(1,:,:))));
    for i = 1:length(firsttouchIdx)
        firsttouchEx_mask(firsttouchIdx(i):firsttouchOffIdx(i))=NaN;
    end
    
    touchEx_mask = ones(size(squeeze(array.S_ctk(1,:,:))));
    for i = 1:length(touchOnIdx)
        touchEx_mask(touchOnIdx(i):touchOffIdx(i)) = NaN;
    end
    touchEx_mask(1:100,:) = 1; %since bleedover from end of trials before, tihs ensure we keep end
    
%     availtotrialend_mask=ones(size(squeeze(array.S_ctk(1,:,:))));
%     availtotrialend_mask(avail:size(availtotrialend_mask,1),:) = NaN; %block out all periods after pole availability
%     
    avail_mask=ones(size(squeeze(array.S_ctk(1,:,:))));
    for j=1:array.k
        avail_mask(avail:offset(j),j)=NaN; %block out all periods between pole availability
    end
    
    sampling_mask=NaN(size(squeeze(array.S_ctk(1,:,:))));
    for f = 1:array.k
        sampling_mask(round(((array.meta.poleOnset(1))*1000),0):round(((array.meta.poleOnset(1))*1000),0)+750,f)=1;
%            sampling_mask(round(450):round((.45+.75)*1000),f)=1; %set custom value of 450ms because poleOnset vals are off. 
    end
   
    availToFirstlick = NaN(size(squeeze(array.S_ctk(1,:,:))));
    availToEnd = availToFirstlick  ;
    for d = 1:array.k
       availToFirstlick(round(((array.meta.poleOnset(1))*1000),0):fl(d),d)=1;
       availToEnd(round(((array.meta.poleOnset(1))*1000),0):end,d)=1;
    end
    
    
    
    
    
    mask.availtolick = availToFirstlick;
    mask.touch = touchEx_mask;
    mask.first = firsttouchEx_mask;
    mask.availend = availToEnd;
    mask.avail = avail_mask;
    mask.samplingp = sampling_mask;
    mask.samp_notouch = (touchEx_mask.*sampling_mask);