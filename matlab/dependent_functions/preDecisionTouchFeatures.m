function [numTouches, meanFeature] = preDecisionTouchFeatures(array,preDecisionMask,variableNumber,touchDir,touchOrder)

if ~exist('touchDir')
    error('set touch direction to be pro ,ret, or all')
end

if ~exist('touchOrder')
    error('set touch order to be first, last, all, or random')
end

touchmat = nan(size(preDecisionMask));
touchIdx = [find(array.S_ctk(9,:,:)==1) ;find(array.S_ctk(12,:,:)==1)];
touchmat(touchIdx)=1;

if strcmp(touchDir,'pro')
    phaseMask = squeeze(array.S_ctk(5,:,:));
    dirMask = double(phaseMask<=0);
    dirMask(dirMask==0)=nan;
elseif strcmp(touchDir,'ret')
    phaseMask = squeeze(array.S_ctk(5,:,:));
    dirMask = double(phaseMask>=0);
    dirMask(dirMask==0)=nan;
elseif strcmp(touchDir,'all')
    dirMask = ones(size(preDecisionMask));
end

preD_dir_Touch_mask = touchmat .* preDecisionMask .* dirMask;

if strcmp(touchOrder,'first')
    isOne = preD_dir_Touch_mask == 1 ;
    touch_order_mask = double(isOne & cumsum(isOne,1) == 1);
    touch_order_mask(touch_order_mask==0)=nan;
elseif strcmp(touchOrder,'last')
    isOne = preD_dir_Touch_mask == 1 ;
    touch_order_mask = double(isOne & cumsum(isOne,1,'reverse') == 1);
    touch_order_mask(touch_order_mask==0)=nan;
elseif strcmp(touchOrder,'all')
    touch_order_mask = ones(size(preD_dir_Touch_mask));
elseif strcmp(touchOrder,'random')
    touch_order_mask = nan(size(preD_dir_Touch_mask));
    for b = 1:size(preD_dir_Touch_mask,2)
        if ~isempty(find(preD_dir_Touch_mask(:,b)==1));
            touch_order_mask(datasample(find(preD_dir_Touch_mask(:,b)==1),1),b)=1;
        end
    end
end


preD_dir_Touch_mask = preD_dir_Touch_mask .* touch_order_mask;

feature = squeeze(array.S_ctk(variableNumber,:,:));
touchFeature = feature.*preD_dir_Touch_mask;


nanMat = nan(size(preDecisionMask));
if variableNumber == 17
    updatedMaskIdx = find(preD_dir_Touch_mask==1)-1; %doing 1ms pretouch
    nanMat(updatedMaskIdx)=1;
    touchFeature = feature .* nanMat;
end


meanFeature = touchFeature;
numTouches = nansum(preD_dir_Touch_mask);