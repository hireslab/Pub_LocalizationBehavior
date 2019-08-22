%%__main__all analysis below is built off a data structure of 200
%%consecutive best performing trials in an object localization task. 
close all; clear; clc; 
%% Load behavioral data matrix 
behavioralDataLocation = 'C:\Users\jacheung\Dropbox\LocalizationBehavior\DataStructs\publication\localization_task_raw';
decomposed_behavior_directory = 'C:\Users\jacheung\Dropbox\LocalizationBehavior\DataStructs\publication\decomposed_task_raw';
dataStructLocation = 'C:\Users\jacheung\Dropbox\LocalizationBehavior\DataStructs\publication';
cd(dataStructLocation)
load('behavioral_structure.mat') 

%% Fig 2 Head-Fixed Task and Performance 
%Fig 2E reaction time (first touch to first lick) of population
plotRxnTime(BV)  

%Fig 2F learning curves of population  
learningCurves(behavioralDataLocation)

%Fig 2G psychometric curves of animal during best performing 200 trials
rawPsychometricCurves(BV); 

%Fig 2H discrimation precision of the animal 
discrimination_precision(BV); 

%% Fig 3 Motor Strategy and Its Influence on Patterns of Touch 
%Fig 3A heatmap of whisker motion (sorted by motor position)
%can input mouseNumber to plot or variable number
%variable number :1) angle, :3) amplitude :4) midpoint :5) phase
mouseNumber = 9; %paper example mouseNumber 9
variableNumber = 1; %paper example variable 3(amplitude)
plotSortedHeat(BV,mouseNumber,variableNumber);

%Fig 3B plot the amplitude from cue onset
fromCueOnset(BV,3) %3 correlates to the index of amplitude feature

%Fig 3C %outputs whisking changing due to touch for individual and
%population
touchChangesWhisking(BV)

%Fig 3D whisking feature at the peak of each whisk in the cycle. shown in
% Cheung et al. 2019 is angle relative to the discrimination boundary
peakProtractionFeature(BV); 

%Fig 3E Proportion of go/nogo with touches; 
proportionTTypeTouch(BV)

%Fig 3F Touch presence classifier vs mouse performance 
cd(dataStructLocation)
load([dataStructLocation filesep 'model_3F'])
mcc_scatters(mdl,BV)

%Fig 3G Scatter of proportion of licking|no touch and licking|touch 
trialProportion(BV,'all');% can set all to 'pro' or 'ret' for touch direction


%% Fig 4 The Distribution of Sensorimotor Features and Their Utility for Predicting Trial Type and Choice
%Fig 4A-H feature distribution and decision boundary of model across
%different features
load([dataStructLocation filesep 'model_4_trialType.mat'])
variable_options = fields(mdl.input); %list of options available;
plot_variable = variable_options{3}; %vary feature here
plot_decision_boundary(mdl,plot_variable) %plot variable is a string indicating which feature is available

%Fig 4G scatter of MCC values across all features in trial type prediction
mcc_scatters(mdl,BV)

%Fig 4H scatter of MCC values across all features in choice prediction
load([dataStructLocation filesep 'model_4_choice.mat'])
mcc_scatters(mdl,BV)

%% Fig 5 Mice Discriminate Location Using More Than Touch Count
%Fig A/B Lick probability as a function of touch count 
touchDirection = 'all';
touchOrder = 'all';
numTouchesLickProbability(BV,touchDirection,touchOrder)

%% Fig 6 Mice Discriminate Location Using Features Correlated to Azimuthal Angle Rather Than Radial Distance
%uses directory housing behavioral files to generate plots B and D shown 
% in fig 6 of Cheung et al. 2019
decomposed_task_behavior(decomposed_behavior_directory)

%% Fig 7 Choice Can Be Best Predicted by a Combination of Touch Count and Whisking Midpoint at Touch
%fig 7C 
load([dataStructLocation filesep 'model_7CD.mat']) %hilbert vs angle model 
variable_options = fields(mdl.input); %list of options available;
plot_variable = variable_options{2}; %vary feature here
plot_decision_boundary(mdl,plot_variable) %plot variable is a string indicating which feature is available

%fig 7D
mcc_scatters(mdl,BV)

%fig 7E 
load([dataStructLocation filesep 'model_7E.mat']) %hilbert component model 
mcc_scatters(mdl,BV)

%fig 7F 
load([dataStructLocation filesep 'model_7FGH.mat']) %counts+hilbert component model 
mcc_scatters(mdl,BV)


%Fig 7G prediction heat map 
predictionMatrix = outcomes_heatmap(BV,mdl.output.motor_preds);
predictionMatrix.columnNames

%Fig 7H prediction heat map comaparison
outcomes_heatmap_comparator(predictionMatrix)

%Fig 7IJ 
load([dataStructLocation filesep 'model_7IJ.mat']) %counts, counts+midpoint, counts+angle model 
model_psychometric_comparison(mdl,BV) %Figure 7I
model_precision_comparison(mdl,BV) %Figure 7J

