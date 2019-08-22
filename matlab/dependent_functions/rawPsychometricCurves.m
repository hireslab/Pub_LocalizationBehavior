function [prob,raw] = rawPsychometricCurves(U)

%outputs a cell array. Each array = 1 session.
%Column 1 = normalized pole positions. 2 = AVG number of touches. 3 =
%p(lick)

prob=cell(1,length(U));

%function for finding all touches before decision lick 
[preDecisionTouchIdx] = preDecisionTouchMat(U);

%building small matrix
for rec=1:length(U)
    motors = U{rec}.meta.motorPosition; 
    gos=find(U{rec}.meta.trialType==1);
    nogos=find(U{rec}.meta.trialType==0);
    
    gonorm = normalize_var(motors(gos),0,1); 
    nogonorm = normalize_var(motors(nogos),-1,0); 
    
    touchesPreD = nansum(preDecisionTouchIdx{rec});
    
    normpos=zeros(U{rec}.k,3);
    normpos(gos,1)=gonorm;
    normpos(nogos,1)=nogonorm;
    normpos(:,2) = touchesPreD;
    normpos(:,3)=U{rec}.meta.trialCorrect;
    
    clust=[]; %bin by motor positions
    for k=1:length(normpos)
        clust=binslin(normpos(:,1),normpos(:,1:3),'equalE',11,-1,1);
    end
    
    raw{rec} = cell2mat(clust);
    
    prob{rec}=cell2mat(cellfun(@(x) mean(x,1),clust,'uniformoutput',0));
    prob{rec}(1:5,3)=1-prob{rec}(1:5,3);
    
end


%---------------------------------------------------
% Plotting features 
figure(27);clf;plot(1:10,flipud(prob{1}(:,3)),'k')
for i = 1:length(prob)
    hold on;plot(1:10,flipud(prob{i}(:,3)),'color',[.8 .8 .8]);
end
tmp=cell2mat(prob);
allavg = mean(tmp(:,3:3:end),2);
numavg = mean(tmp(:,2:3:end),2);
plot(1:10,flipud(allavg),'k','linewidth',4);
hold on; bar(1:10,flipud(numavg/50),1,'FaceColor',[.7 .7 .7]);%mean number of touches per trial
ylabel('Probability of licking')
set(gca,'xlim',[0 11],'xtick',[1 5.5 10],'xticklabel',{-1 0 1},'ytick',[0:.25:1],'ylim',[0 1])
a2 = axes('YAxisLocation', 'Right');
set(a2,'color','none');set(a2,'XTick',[]);set(a2,'YLim',[0 2],'ytick',[0:.1:.4],'yticklabel',[0:2.5:10]);ylabel('# Pre-decision touches/trial')


