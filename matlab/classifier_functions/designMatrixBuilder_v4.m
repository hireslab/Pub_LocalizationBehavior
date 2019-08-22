




function [DmatX, DmatY, motorX, renormValues] = designMatrixBuilder_v4(V,U,params)



motorPos = U.meta.motorPosition;
hxMotor = motorPos(logical(V.trialNums.matrix(1,:)))';
mxMotor = motorPos(logical(V.trialNums.matrix(2,:)))';
FAxMotor = motorPos(logical(V.trialNums.matrix(3,:)))';
CRxMotor = motorPos(logical(V.trialNums.matrix(4,:)))';


switch params.designvars
    

    case 'counts'
        hx = [V.touchNum.hit'];
        FAx = [V.touchNum.FA'];
        CRx = [V.touchNum.CR'];
        mx = V.touchNum.miss';
        
    case 'countsBinary'
        hx = [V.touchNum.hit'];
        hx = hx>0;
        FAx = [V.touchNum.FA'];
        FAx = FAx>0;
        CRx = [V.touchNum.CR'];
        CRx = CRx>0;
        mx = [V.touchNum.miss'];
        mx = mx>0;
        
    case 'motor'
        hx = [hxMotor ];
        FAx = [FAxMotor ];
        CRx = [CRxMotor ] ;
        mx = [mxMotor ] ;
        
    case 'angle'
        varNum=1;
        hx = V.var.hit{varNum}'; FAx = V.var.FA{varNum}'; CRx = V.var.CR{varNum}'; mx = V.var.miss{varNum}';
        
    case 'amp'
        varNum=3;
        hx = V.var.hit{varNum}'; FAx = V.var.FA{varNum}'; CRx = V.var.CR{varNum}'; mx = V.var.miss{varNum}';
    case 'midpoint'
        varNum=4;
        hx = V.var.hit{varNum}'; FAx = V.var.FA{varNum}'; CRx = V.var.CR{varNum}'; mx = V.var.miss{varNum}';
        
    case 'phase'
        varNum=5;
        hx = V.var.hit{varNum}'; FAx = V.var.FA{varNum}'; CRx = V.var.CR{varNum}'; mx = V.var.miss{varNum}';
        
    case 'curvature'
        varNum=6;
        hx = V.var.hit{varNum}'; FAx = V.var.FA{varNum}'; CRx = V.var.CR{varNum}'; mx = V.var.miss{varNum}';
   
    case 'countsangle'
        hxt = V.var.hit{1}'; FAxt = V.var.FA{1}'; CRxt = V.var.CR{1}'; mxt = V.var.miss{1}';
        
        hx = [hxt V.touchNum.hit'];
        FAx = [FAxt V.touchNum.FA'];
        CRx = [CRxt V.touchNum.CR'];
        mx = [mxt V.touchNum.miss'];
        
    case 'countsamp' 
        varNum=3;
        hxa = V.var.hit{varNum}'; FAxa = V.var.FA{varNum}'; CRxa = V.var.CR{varNum}'; mxa = V.var.miss{varNum}';
        
        hx = [ hxa V.touchNum.hit'];
        FAx = [FAxa V.touchNum.FA'];
        CRx = [CRxa V.touchNum.CR'];
        mx = [mxa V.touchNum.miss'];
        
    case 'countsmidpoint'
        varNum=4;
        hxm = V.var.hit{varNum}'; FAxm = V.var.FA{varNum}'; CRxm = V.var.CR{varNum}'; mxm = V.var.miss{varNum}';
        
        hx = [hxm V.touchNum.hit'];
        FAx = [FAxm V.touchNum.FA'];
        CRx = [CRxm V.touchNum.CR'];
        mx = [mxm V.touchNum.miss'];
        
    case 'countsphase'
        varNum=5;
        hxp = V.var.hit{varNum}'; FAxp = V.var.FA{varNum}'; CRxp = V.var.CR{varNum}'; mxp = V.var.miss{varNum}';
        
        hx = [hxp V.touchNum.hit'];
        FAx = [FAxp V.touchNum.FA'];
        CRx = [CRxp V.touchNum.CR'];
        mx = [mxp V.touchNum.miss'];
        
    case 'hilbert'
        hxa = V.var.hit{3}'; FAxa = V.var.FA{3}'; CRxa = V.var.CR{3}'; mxa = V.var.miss{3}';
        hxm = V.var.hit{4}'; FAxm = V.var.FA{4}'; CRxm = V.var.CR{4}'; mxm = V.var.miss{4}';
        hxp = V.var.hit{5}'; FAxp = V.var.FA{5}'; CRxp = V.var.CR{5}'; mxp = V.var.miss{5}';
        
        hx = [hxa hxm hxp ];
        FAx = [FAxa FAxm FAxp ];
        CRx = [CRxa CRxm CRxp ];
        mx = [mxa mxm mxp ];
    case 'hilbertCounts'
        hxa = V.var.hit{3}'; FAxa = V.var.FA{3}'; CRxa = V.var.CR{3}'; mxa = V.var.miss{3}';
        hxm = V.var.hit{4}'; FAxm = V.var.FA{4}'; CRxm = V.var.CR{4}'; mxm = V.var.miss{4}';
        hxp = V.var.hit{5}'; FAxp = V.var.FA{5}'; CRxp = V.var.CR{5}'; mxp = V.var.miss{5}';
        
        hx = [hxa hxm hxp V.touchNum.hit'];
        FAx = [FAxa FAxm FAxp V.touchNum.FA'];
        CRx = [CRxa CRxm CRxp V.touchNum.CR'];
        mx = [mxa mxm mxp V.touchNum.miss'];

    case 'cueTiming'
        hx = [V.var.hit{10}(:,1) ];
        FAx = [V.var.FA{10}(:,1) ];
        CRx = [V.var.CR{10}(:,1) ];
        mx = [V.var.miss{10}(:,1)]; 
        
    case 'decompTime'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,1:3)) ];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,1:3)) ];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,1:3)) ];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,1:3)) ];
        
        % DECOMP TIME INDIVIDUALS: :1) timeTotouch from trough :2) angle at trough
        % :3) velocity measured in angle/ms
    case 'countsdecompTime'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,1:3)) V.touchNum.hit'];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,1:3)) V.touchNum.FA'];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,1:3)) V.touchNum.CR'];
        % DECOMP TIME INDIVIDUALS: :1) timeTotouch from trough :2) angle at trough
        % :3) velocity measured in angle/ms
    case 'countsonsetangle'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,2)) V.touchNum.hit'];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,2)) V.touchNum.FA'];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,2)) V.touchNum.CR'];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,2)) V.touchNum.miss'];
        
    case 'countsvelocity'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,3)) V.touchNum.hit'];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,3)) V.touchNum.FA'];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,3)) V.touchNum.CR'];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,3)) V.touchNum.miss'];
        
    case 'countstimeTotouch'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,1)) V.touchNum.hit'];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,1)) V.touchNum.FA'];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,1)) V.touchNum.CR'];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,1)) V.touchNum.miss'];
        
    case 'whiskTiming'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,1)) ];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,1)) ];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,1)) ];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,1)) ];
        
    case 'onsetangle'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,2)) ];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,2)) ];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,2)) ];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,2)) ];
        
    case 'velocity'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,3)) ];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,3)) ];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,3)) ];
        mx = [cellfun(@nanmean,V.var.miss{7}(:,3)) ];
        
    case 'Ivelocity'
        hx = [cellfun(@nanmean,V.var.hit{7}(:,4)) ];
        FAx = [cellfun(@nanmean,V.var.FA{7}(:,4)) ];
        CRx = [cellfun(@nanmean,V.var.CR{7}(:,4)) ];
        
    case 'Ivelocity2'
        [hxiv,~,FAxiv,CRxiv] = meanVarfinder_v2 (V,2);
        hx = [hxiv'];
        FAx = [FAxiv'];
        CRx = [CRxiv'];
        %
        
    case 'radialD'
        hx = [V.var.hit{11}(:,1)./33];
        FAx = [V.var.FA{11}(:,1)./33];
        CRx = [V.var.CR{11}(:,1)./33];
        mx = [V.var.miss{11}(:,1)./33];

        
    case 'roll'
        hxmotoridx = V.var.hit{8}(:,2);
        FAxmotoridx = V.var.FA{8}(:,2);
        CRxmotoridx = V.var.CR{8}(:,2);
        
        hx = [V.var.hit{8}(:,1)  motorPos(hxmotoridx)'];
        hy = ones(size(hx,1),1);
        FAx = [V.var.FA{8}(:,1) motorPos(FAxmotoridx)'];
        FAy = ones(size(FAx,1),1);
        CRx = [V.var.CR{8}(:,1) motorPos(CRxmotoridx)'];
        CRy = ones(size(CRx,1),1);
        
    case 'ubered'
        hxt = V.var.hit{1}'; FAxt = V.var.FA{1}'; CRxt = V.var.CR{1}'; mxt = V.var.miss{1}';
        hxk = V.var.hit{6}'; FAxk = V.var.FA{6}'; CRxk = V.var.CR{6}'; mxk = V.var.miss{6}'; %kappa
      
        
        hxw = [cellfun(@nanmean,V.var.hit{7}(:,1)) ]; %whisk onset latency
        FAxw = [cellfun(@nanmean,V.var.FA{7}(:,1)) ];
        CRxw = [cellfun(@nanmean,V.var.CR{7}(:,1)) ];
        mxw = [cellfun(@nanmean,V.var.miss{7}(:,1)) ];
        
        hxr = [V.var.hit{11}(:,1)./33 hxMotor]; %radial distance
        FAxr = [V.var.FA{11}(:,1)./33 FAxMotor];
        CRxr = [V.var.CR{11}(:,1)./33 CRxMotor];
        mxr = [V.var.miss{11}(:,1)./33 mxMotor];
        
        hx = [hxk V.var.hit{10}(:,1) hxw   V.touchNum.hit'  hxt]; %10 is cue to touch
        FAx = [FAxk V.var.FA{10}(:,1) FAxw V.touchNum.FA'   FAxt];
        CRx = [CRxk  V.var.CR{10}(:,1) CRxw  V.touchNum.CR'  CRxt];
        mx = [mxk  V.var.miss{10}(:,1) mxw  V.touchNum.miss'  mxt];
        
    case 'combined'
        
        hxt = V.var.hit{1}'; FAxt = V.var.FA{1}'; CRxt = V.var.CR{1}'; mxt = V.var.miss{1}';
        hxk = V.var.hit{6}'; FAxk = V.var.FA{6}'; CRxk = V.var.CR{6}'; mxk = V.var.miss{6}'; %kappa
      
        
        hxw = [cellfun(@nanmean,V.var.hit{7}(:,1)) ]; %whisk onset latency
        FAxw = [cellfun(@nanmean,V.var.FA{7}(:,1)) ];
        CRxw = [cellfun(@nanmean,V.var.CR{7}(:,1)) ];
        mxw = [cellfun(@nanmean,V.var.miss{7}(:,1)) ];
        
        hxr = [V.var.hit{11}(:,1)./33 hxMotor]; %radial distance
        FAxr = [V.var.FA{11}(:,1)./33 FAxMotor];
        CRxr = [V.var.CR{11}(:,1)./33 CRxMotor];
        mxr = [V.var.miss{11}(:,1)./33 mxMotor];
        
        
        hx = [hxk V.var.hit{10}(:,1) hxw   V.touchNum.hit' hxr(:,1) hxt]; %10 is cue to touch
        FAx = [FAxk V.var.FA{10}(:,1) FAxw V.touchNum.FA' FAxr(:,1)  FAxt];
        CRx = [CRxk  V.var.CR{10}(:,1) CRxw  V.touchNum.CR' CRxr(:,1) CRxt];
        mx = [mxk  V.var.miss{10}(:,1) mxw  V.touchNum.miss' mxr(:,1)  mxt];

    case 'countsmpamp'
        
        hxa = V.var.hit{3}'; FAxa = V.var.FA{3}'; CRxa = V.var.CR{3}';
        hxm = V.var.hit{4}'; FAxm = V.var.FA{4}'; CRxm = V.var.CR{4}';
        
        
        hx = [hxm hxa V.touchNum.hit'];
        FAx = [FAxm FAxa V.touchNum.FA'];
        CRx = [CRxm CRxa V.touchNum.CR'];
        
    case 'countsmpphase'
        
        hxm = V.var.hit{4}'; FAxm = V.var.FA{4}'; CRxm = V.var.CR{4}';
        hxp = V.var.hit{5}'; FAxp = V.var.FA{5}'; CRxp = V.var.CR{5}';
        
        hx = [hxm hxp V.touchNum.hit'];
        FAx = [FAxm FAxp V.touchNum.FA'];
        CRx = [CRxm CRxp V.touchNum.CR'];

        
    case 'countsampphase'
        
        hxa = V.var.hit{3}'; FAxa = V.var.FA{3}'; CRxa = V.var.CR{3}'; mxa = V.var.miss{3}';
        hxp = V.var.hit{5}'; FAxp = V.var.FA{5}'; CRxp = V.var.CR{5}'; mxp = V.var.miss{5}';
        
        hx = [ hxa hxp V.touchNum.hit'];
        FAx = [FAxa FAxp V.touchNum.FA'];
        CRx = [CRxa CRxp V.touchNum.CR'];
        mx = [mxa mxp V.touchNum.miss'];
        
    case 'mpamp'
        hxa = V.var.hit{3}'; FAxa = V.var.FA{3}'; CRxa = V.var.CR{3}';
        hxm = V.var.hit{4}'; FAxm = V.var.FA{4}'; CRxm = V.var.CR{4}';
        
        hx = [hxm hxa  ];
        FAx = [ FAxm  FAxa ];
        CRx = [ CRxm CRxa ];
        
    case 'mpphase'
        hxm = V.var.hit{4}'; FAxm = V.var.FA{4}'; CRxm = V.var.CR{4}';
        hxp = V.var.hit{5}'; FAxp = V.var.FA{5}'; CRxp = V.var.CR{5}';
        
        hx = [hxm hxp  ];
        FAx = [ FAxm  FAxp ];
        CRx = [ CRxm CRxp ];
        
    case 'ampphase'
        
        hxa = V.var.hit{3}'; FAxa = V.var.FA{3}'; CRxa = V.var.CR{3}';
        hxp = V.var.hit{5}'; FAxp = V.var.FA{5}'; CRxp = V.var.CR{5}';
        
        hx = [hxa hxp  ];
        FAx = [ FAxa  FAxp ];
        CRx = [ CRxa CRxp ];
       
    case 'maxP'
        
        hx = [V.var.hit{9}'  ];
        FAx = [V.var.FA{9}' ];
        CRx = [V.var.CR{9}'];
        
end

hx = [hx hxMotor];
FAx = [FAx FAxMotor];
CRx = [CRx CRxMotor] ;
mx = [mx mxMotor] ;

switch params.dropNonTouch
    case 'yes'
        
        if strcmp(params.designvars,'counts')
            hx = hx(hx(:,1)~=0,:);
            FAx = FAx(FAx(:,1)~=0,:);
            CRx = CRx(CRx(:,1)~=0,:);
            mx = mx(mx(:,1)~=0,:);
        else
            hx = hx(~sum(isnan(hx),2),:);
            FAx = FAx(~sum(isnan(FAx),2),:);
            CRx = CRx(~sum(isnan(CRx),2),:);
            mx = mx(~sum(isnan(mx),2),:);
        end
        
        hy = ones(size(hx,1),1);
        FAy = ones(size(FAx,1),1);
        CRy = ones(size(CRx,1),1);
        my = ones(size(mx,1),1);
        
    case 'no'
        
        
        hy = ones(size(hx,1),1);
        FAy = ones(size(FAx,1),1);
        CRy = ones(size(CRx,1),1);
        my = ones(size(mx,1),1);
end

switch params.classes
    case 'gonogo'
        DmatX = [hx(:,1:size(hx,2)-1); mx(:,1:size(mx,2)-1) ; FAx(:,1:size(FAx,2)-1); CRx(:,1:size(CRx,2)-1)];
        DmatY = [hy; my; FAy.*2;CRy.*2];
        motorX = [hx(:,size(hx,2)); mx(:,size(mx,2)) ; FAx(:,size(FAx,2));CRx(:,size(CRx,2))];
        
    case 'lick'
        DmatX = [hx(:,1:size(hx,2)-1); mx(:,1:size(mx,2)-1) ; FAx(:,1:size(FAx,2)-1); CRx(:,1:size(CRx,2)-1)];
        DmatY = [hy; my.*2; FAy; CRy.*2];
        motorX = [hx(:,size(hx,2)); mx(:,size(mx,2)) ; FAx(:,size(FAx,2));CRx(:,size(CRx,2))];
        
end

%Normalization for any multi-predictor features
if size(DmatX,2)>1
    switch params.normalization
        case 'meanNorm'
            renormValues = [nanmean(DmatX) (max(DmatX)-min(DmatX))];
            DmatX = DmatX- nanmean(DmatX); %mean normalization
            DmatX = DmatX ./ (max(DmatX)-min(DmatX));
        case 'whiten'
            DmatX = filex_whiten(DmatX);
            renormValues = nan;
    end
end

if ~exist('renormValues')
    renormValues = nan;
end
