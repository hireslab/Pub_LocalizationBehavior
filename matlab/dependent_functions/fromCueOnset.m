function fromCueOnset(array,variable)

figure(32);clf
window = [-100 500];
popamp = nan(length(array),length(window(1):window(2)));
for b = 1:length(array)
    poleOnset = round(mean(array{b}.meta.poleOnset)*1000);
    
    amps = squeeze(array{b}.S_ctk(variable,poleOnset+window(1):poleOnset+window(2),:));
    popamp(b,:) = mean(amps,2);
    
    hold on; plot(window(1):window(2),popamp(b,:),'color',[.8 .8 .8])
end

title('Fig 3B')
hold on; plot(window(1):window(2),mean(popamp),'k')
xlabel('time from cue onset(ms)');
ylabel('amplitude')

