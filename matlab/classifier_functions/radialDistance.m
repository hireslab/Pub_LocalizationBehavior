function [outputs] = radialDistance(array,preDecisionMask)

    motors = normalize_var(array.meta.motorPosition,-1,1)*-1;
    
    hits = double(array.meta.trialType==1).*double(array.meta.trialCorrect==1);
    miss = double(array.meta.trialType==1).*double(array.meta.trialCorrect==0);
    FA = double(array.meta.trialType==0).*double(array.meta.trialCorrect==0);
    CR = double(array.meta.trialType==0).*double(array.meta.trialCorrect==1);
    
    radD  = nan(array.k,1);
    for d = 1:array.k
        touchIdx = [find(array.S_ctk(9,:,d)==1) find(array.S_ctk(12,:,d)==1)];
       touchIdx = intersect(find(preDecisionMask(:,d)==1),touchIdx);
        if ~isempty(touchIdx) 
        xfol = array.whisker.follicleX{d};
        yfol = array.whisker.follicleY{d};
        xbar = array.whisker.barPos{d}(1,2);
        ybar = array.whisker.barPos{d}(1,3);
        
        xdist = xfol(touchIdx)-xbar ;
        ydist = yfol(touchIdx)-ybar;
        
        radD(d) = nanmean(sqrt(xdist.^2 +ydist.^2));
        end
    end
    
    [~,svals] = sort(abs(motors));
    dbrad = nanmean(radD(svals(1:6)));
    
    
%     dbrad = nanmean(radD(find(motors<0.05 & motors>-.05)));
    
    radD = radD-dbrad;
    
    
    outputs{1} =  [radD(hits==1) find(hits==1)'];
    outputs{2} =  [radD(FA==1) find(FA==1)'];
    outputs{3} = [radD(CR==1) find(CR==1)'];
    outputs{4} =  [radD(miss==1) find(miss==1)'];

    
%     figure(380);subplot(2,5,k)
%     hold on; scatter(motors,radD./33)

    
% xlabel('normalized motor pos')
% ylabel('distance from follicle at touch (mm)')