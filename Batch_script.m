%% Script_eeglab_analysis 2022. 
%This script imports the data, selects the cases/channels wanted, adds electrode location, removes ECG and saves it in EEGLAB format
%On the second step downsamples the data, filters and does the first epoching.
%There is also an option to store continuous data, this is both for resting
%conditions and to be able to use clean_rawdata to identify bad channels
%The last part of this script uses different algorithms to detect bad
%channels and bad epochs and writes the suggested rejections in a excel
%file. Baseline correct after epoching - check if there is a debate. 

%% START
clear all 
dbstop if error % optional instruction to stop at a breakpoint if there is an error - useful for debugging
%% SET DIRECTORIES
%For toolboxes 
scripts_path='Y:\Uncertainty\Scripts';
eeglab_path = 'Y:\Uncertainty\Scripts\eeglab2022.0' ;  
fieldtrip_path= 'Y:\Uncertainty\Scripts\fieldtrip-20220104\fieldtrip-20220104' ; 

addpath(scripts_path);
addpath(eeglab_path);
addpath(fieldtrip_path);

%For data
raw_path = 'Y:\Uncertainty\EEG analysis\Raw2';
import_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Imported';
longepoched_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Longepoched';
epoched_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched';
continuous_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Continuous';

eeglab; 
delete(findall(0,'Type','figure'));
%% SELECT TASKS TO CARRY OUT
%Choose what parts of the script I want to complete
importdata =0; 
storelongepoch = 0;
storeepoch = 1;
storecontinuous=0;
checkautochannels=0;
checkautotrials=0;
%% IMPORT DATA
if importdata ==1
%%Potential improvement 
%Since I am doing it all in the same script I am not sure I need to make
%structures, but still, I thought it would make it easier to check the
%values, etc and for now I don´t think there is any harm on it.
%Select the data that you want to preprocess. 
import=struct;% clears the field
import.excludechannels = {'ECG'}; %If it doesn´t work with 32 try just typing ECG
import.excludeparticipant = {}; %Participants to be excluded. If there is none put a number above the sample size.
import.condition = {'T'};%Conditions to be included
import.extension =  {'vhdr'}; %Type of data (brainvision)
import.save_suffix = {'_imported'}; %Suffix to use to save data

%%Potential improvement - I can probably do this much simpler adding an &
%%but it seems to not be possible with this type of data or maybe I have
%%not used the right syntax. For now this rudementary and bulky way of
%%doing it works. 


filelist1=strtrim(string (ls (raw_path)));
filelist2=contains (filelist1, import.extension);
filelist3=filelist1(filelist2);
filelist4=contains(filelist3, import.condition);
filelist5=filelist3(filelist4);
filelist6= ~contains (filelist5, import.excludeparticipant);
filelist= filelist5(filelist6);
if isempty(filelist)
    error('No files found to import!\n');
end

    
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    EEG = pop_loadbv (raw_path, filenme); %load file
    EEG = eeg_checkset(EEG);
    EEG=pop_chanedit(EEG, 'lookup','Y:\\Uncertainty\\Scripts\\eeglab2022.0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');% As of 2021, the default channel location file for electrode position is the MNI file, which is best suited for source localization. Before 2021, it was the BESA spherical location file.
    EEG = pop_select( EEG, 'nochannel',import.excludechannels);
    EEG.setname = strcat(nme, import.save_suffix); 
    EEG.filename=char(strcat(nme, import.save_suffix, '.set'));
    EEG.filepath=import_path;
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end

end

%% LONG EPOCH DATA

if storelongepoch==1
%longepoch parameters
longepoch=struct;% clears the field
longepoch.condition = {'T'};%Conditions to be included
longepoch.extension =  {'set'}; %Type of data (brainvision)
longepoch.save_suffix = {'_longepoched'}; %Suffix to use to save data
longepoch.bandpassfilter = [0.1 40]; %high pass and low pass frequencies
longepoch.mainmarker = {'C 17'}; %marker around which I want to cut 
longepoch.cleantimewindow = [-0.5 11]; %timewindow of longepoch

filelist1= strtrim(string (ls (import_path)));
filelist2=contains (filelist1, longepoch.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end
%Note that if high-pass and low-pass cutoff frequencies are BOTH selected, 
%low-pass and high-pass parts will have the same slopes. 
%Frequently, the low-pass slope is therefore steeper than necessary. 
%To avoid this problem, we recommend first applying the low-pass filter and then, in a second call, the high-pass filter (or vice versa).
%
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_imported");
    EEG = pop_loadset (filenme, import_path); %load file
    EEG = eeg_checkset(EEG);
    EEG = pop_resample(EEG, 500);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',longepoch.bandpassfilter(2)); %low pass filter
    EEG = pop_eegfiltnew(EEG, 'locutoff',longepoch.bandpassfilter(1)); %high pass filter
    EEG = pop_epoch(EEG, longepoch.mainmarker, longepoch.cleantimewindow); %longepoch
    EEG.setname = strcat(nme, longepoch.save_suffix); 
    EEG.filename=char(strcat(nme, longepoch.save_suffix, '.set'));
    EEG.filepath=longepoched_path;
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end
end

%% SAVE DATA IN CONTINUOUS FORMAT
if storecontinuous==1

%Continuous parameters
continuous=struct;% clears the field
continuous.condition = {'T'};%Conditions to be included
continuous.extension =  {'set'}; %Type of data (brainvision)
continuous.save_suffix = {'_continuous'}; %Suffix to use to save data
continuous.bandpassfilter = [0.1 40]; %high pass and low pass frequencies

filelist1=string(ls (import_path));
filelist2=contains (filelist1, continuous.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end
%Note that if high-pass and low-pass cutoff frequencies are BOTH selected, 
%low-pass and high-pass parts will have the same slopes. 
%Frequently, the low-pass slope is therefore steeper than necessary. 
%To avoid this problem, we recommend first applying the low-pass filter and then, in a second call, the high-pass filter (or vice versa).
%
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_imported");
    EEG = pop_loadset (filenme, import_path); %load file
    EEG = eeg_checkset(EEG);
    EEG = pop_resample(EEG, 500);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',continuous.bandpassfilter(2)); %low pass filter
    EEG = pop_eegfiltnew(EEG, 'locutoff',continuous.bandpassfilter(1)); %high pass filter
    EEG.setname = strcat(nme, continuous.save_suffix); 
    EEG.filename=char(strcat(nme, continuous.save_suffix, '.set'));
    EEG.filepath=continuous_path;
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end
end

%% IDENTIFY BAD CHANNELS
if checkautochannels==1 %%This runs through the files in the continuous folder, uses the plugin
%%cleanrawdata on them and writes on a file which channels would be
%%rejected according to this. 
%Continuous parameters
continuous=struct;% clears the field
continuous.extension =  {'set'}; %Type of data (brainvision)


filelist1=string(ls(continuous_path));
filelist2=contains (filelist1, continuous.extension);
filelist=filelist1(filelist2);


for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_continuous");
    EEG = pop_loadset (filenme, continuous_path); %load file
    allchannels={EEG.chanlocs.labels}; %identify channels before cleaning
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian'); %cleanrawdata with only the channel rejection on.
    EEG.setname = strcat(nme);
    cleanchannels={EEG.chanlocs.labels}; %identify channels after cleaning
    cleanrawdata = {strjoin(setdiff(allchannels, cleanchannels))}; % identify which channesls have been rejected by comparing pre and post channel list
    if isempty(cleanrawdata)
        cleanrawdata = {'no channels identified for rejection'};
    end
    T=table({nme}, cleanrawdata);
    writetable(T, 'Y:\Uncertainty\EEG analysis\autorej.xls', 'WriteVariableNames',0, 'Range', ['A' num2str(f+1)])%write rejected channels on file
end

%longepoched parameters
longepoch=struct;% clears the field
longepoch.extension =  {'set'}; %Type of data (brainvision)

%I chose to do this with var and neighcorrel, just to have two metrics that
%seem different. In var high values indicate an artifact in neighcorrel low
%or negative values indicate an artifact. Therefore I am adjusting the
%threshold accordingly. 

filelist1=strtrim(string (ls(longepoched_path)));
filelist2=contains (filelist1, longepoch.extension);
filelist=filelist1(filelist2);

for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_longepoched");
    cfg = []; 
    cfg.dataset = fullfile(longepoched_path, filenme);
   % cfg.trialdef.eventtype = 'trial';
     % cfg = ft_definetrial(cfg);
    ft_data1 = ft_preprocessing(cfg);
    cfg.metric = 'var'; %string, default 'var', other options 'min', 'max', 'maxabs', 'range', 'kurtosis', 'zvalue', '1/var', 'maxzvalue', 'neighbstdratio', 'neighbexpvar', 'neighbcorr'
    cfg.threshold     = 7000; %scalar, the optimal value depends on the methods and on the data characteristics
    cfg.feedback      = 'no'; %'yes' or 'no', whether to show an image of the neighbour values (default = 'no')
    ft_data2= ft_badchannel(cfg, ft_data1);
    ftvarrejectchannels={strjoin(ft_data2.badchannel)};
    if isempty (ftvarrejectchannels)
        ftvarrejectchannels =  {'no channels identified for rejection'};
    end
    T=table({nme}, ftvarrejectchannels);
    writetable(T, 'Y:\Uncertainty\EEG analysis\autorej.xls', 'WriteVariableNames',0, 'Range', ['C' num2str(f+1)])%write rejected channels on file
end

for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_longepoched");
    cfg = []; 
    cfg.dataset = fullfile(longepoched_path, filenme);
    %Parameters for neighbour correlation
    cfg.metric = 'neighbcorr'; %string, default 'var', other options 'min', 'max', 'maxabs', 'range', 'kurtosis', 'zvalue', '1/var', 'maxzvalue', 'neighbstdratio', 'neighbexpvar', 'neighbcorr'
    cfg.threshold     =0.3; %scalar, the optimal value depends on the methods and on the data characteristics
    cfg.nbdetect      = 'any'; %'any', 'most', 'all', 'median' (default = 'median')
    ft_data1 = ft_preprocessing(cfg);
    ft_data2= ft_badchannel(cfg, ft_data1);
    ftneighrejectchannels={strjoin(ft_data2.badchannel)};
    if isempty (ftneighrejectchannels)
        ftneighrejectchannels =  {'no channels identified for rejection'};
    end
    T=table({nme}, ftneighrejectchannels);
    writetable(T, 'Y:\Uncertainty\EEG analysis\autorej.xls', 'WriteVariableNames',0, 'Range', ['E' num2str(f+1)])%write rejected channels on file
end
end

if checkautotrials==1
longepoch=struct;% clears the field
longepoch.extension =  {'set'}; %Type of data 

filelist1= strtrim(string (ls (longepoched_path)));
filelist2=contains (filelist1, longepoch.extension);
filelist=filelist1(filelist2);

for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_longepoched");
    cfg = []; 
    cfg.dataset = fullfile(longepoched_path, filenme);
    cfg.trialdef.eventtype = 'trial';
    cfg= ft_definetrial(cfg);
    trl= cfg.trl;
% Jump
    cfg = [];
    cfg.trl = trl;
    cfg.dataset = fullfile(longepoched_path, filenme);
    cfg.datafile = filenme;
    cfg.headerfile = filenme;
    cfg.continuous = 'no';

% channel selection, cutoff and padding
    cfg.artfctdef.zvalue.channel = 'EEG';
    cfg.artfctdef.zvalue.cutoff = 40;
    cfg.artfctdef.zvalue.trlpadding = 0;
    cfg.artfctdef.zvalue.artpadding = 0;
    cfg.artfctdef.zvalue.fltpadding = 0;

% algorithmic parameters
   cfg.artfctdef.zvalue.cumulative = 'yes';
   cfg.artfctdef.zvalue.medianfilter = 'yes';
   cfg.artfctdef.zvalue.medianfiltord = 9;
   cfg.artfctdef.zvalue.absdiff = 'yes';

% make the process interactive
   cfg.artfctdef.zvalue.interactive = 'no';
   [cfg, artifact_jump] = ft_artifact_zvalue(cfg);
   cfg = ft_rejectartifact(cfg);
    y= ismember(cfg.trlold(:,1), cfg.trl);
    if isempty(y)
        y = {'no trials identified for rejection'};
    end
    x=(1:length(cfg.trlold(:,1)))';
    jump_artifact={num2str((x(y==0))')};
    T=table({nme}, jump_artifact);
    writetable(T, 'Y:\Uncertainty\EEG analysis\autorej.xls', 'WriteVariableNames',0, 'Sheet',2, 'Range', ['A' num2str(f+1)])%write rejected trial numbers on file
 
%Muscle
    cfg = [];
    cfg.trl = trl;
    cfg.dataset = fullfile(longepoched_path, filenme);
    cfg.datafile = filenme;
    cfg.headerfile = filenme;
    cfg.continuous = 'no';
% channel selection, cutoff and padding
   cfg.artfctdef.zvalue.channel      = 'EEG';
   cfg.artfctdef.zvalue.cutoff       = 90;
   cfg.artfctdef.zvalue.trlpadding   = 0;
   cfg.artfctdef.zvalue.fltpadding   = 0;
   cfg.artfctdef.zvalue.artpadding   = 0.1;
% algorithmic parameters
  cfg.artfctdef.zvalue.bpfilter     = 'yes';
  cfg.artfctdef.zvalue.bpfreq       = [110 140];
  cfg.artfctdef.zvalue.bpfiltord    = 9;
  cfg.artfctdef.zvalue.bpfilttype   = 'but';
  cfg.artfctdef.zvalue.hilbert      = 'yes';
  cfg.artfctdef.zvalue.boxcar       = 0.2;

% make the process interactive
  cfg.artfctdef.zvalue.interactive = 'no';
 [cfg, artifact_muscle] = ft_artifact_zvalue(cfg);
 cfg = ft_rejectartifact(cfg);
 y=ismember(cfg.trlold(:,1), cfg.trl);
  if isempty(y)
        y = {'no trials identified for rejection'};
  end
 x=(1:length(cfg.trlold(:,1)))';
 muscle_artifact={num2str((x(y==0))')};
 T=table({nme}, muscle_artifact);
writetable(T, 'Y:\Uncertainty\EEG analysis\autorej.xls', 'WriteVariableNames',0, 'Sheet',2, 'Range', ['C' num2str(f+1)])%write rejected channels on file

end
end

%% EPOCH DATA (combined epochs)

if storeepoch==1
%epoch parameters
epoch=struct;% clears the field
epoch.condition = {'T'};%Conditions to be included
epoch.extension =  {'set'}; %Type of data (brainvision)
epoch.save_suffix = {'_epoched'}; %Suffix to use to save data
epoch.bandpassfilter = [0.1 40]; %high pass and low pass frequencies
epoch.onemarker = {'C 17'}; %marker around which I want to cut 
epoch.onetimewindow = [-0.5 0]; %timewindow of epoch one
epoch.twomarker = {'C  1', 'C  2', 'C  3', 'C  4', 'C  5', 'C  6', 'C  7', 'C  8', 'C  9', 'C 10', 'C 11', 'C 12', 'C 13', 'C 14', 'C 15', 'C 16'}; %marker(s) around which I want to cut 
epoch.twotimewindow = [-0.5 4]; %timewindow of epoch two
epoch.baseline= [-500 0]; %time from C1, C2... in final epoch

filelist1= strtrim(string (ls (import_path)));
filelist2=contains (filelist1, epoch.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end
%Note that if high-pass and low-pass cutoff frequencies are BOTH selected, 
%low-pass and high-pass parts will have the same slopes. 
%Frequently, the low-pass slope is therefore steeper than necessary. 
%To avoid this problem, we recommend first applying the low-pass filter and then, in a second call, the high-pass filter (or vice versa).
%
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_imported");
    EEG = pop_loadset (filenme, import_path); %load file
    EEG = eeg_checkset(EEG);
    EEG = pop_eegfiltnew(EEG, 'hicutoff',epoch.bandpassfilter(2)); %low pass filter
    EEG = pop_eegfiltnew(EEG, 'locutoff',epoch.bandpassfilter(1)); %high pass filter
    EEG = pop_resample(EEG, 500);
    EEG1 = pop_epoch(EEG, epoch.onemarker, epoch.onetimewindow); %epoch one
    EEG2 = pop_epoch(EEG, epoch.twomarker, epoch.twotimewindow); %epoch two
%     if length (EEG2.data)~=length (EEG1.data) %Sometimes matlab crashed after presenting the options. In this case there would be two "C 17" one after the other. This identifies that and rejects the first one.
%     a=string({EEG.event.type})'; %Get the list of trigger names
%     b=string({EEG.event.bvmknum})'; %Get the marker numer of the triggers
%     if a(length(a))=="C 17"
%         rejection=EEG1.trials
%         EEG1 = pop_rejepoch(EEG1, rejection,0);
%     end
%     c= contains(a, "C 17")  %Find all "C 17"s and create a vector that is 0 or 1
%     d=zeros(length(c), 1) %Create an empty vector to be filled in the loop
% 
%     for  i= 1:length(c) %Add the current and prior 0 or 1. If two C 17 s appear together the number on the location of second one will be two this way
%         x=i-1
%         if x==0
%             d(i)=c(i)
%         else 
%             d(i)=c(i)+c(x)
%         end
%     end
%     mknum= b(find(d==2)-1)     %Find marker number of the first C17 in the two cansecutive C17
%     a2=string({EEG1.event.epoch})'; 
%     b2=string({EEG1.event.bvmknum})'; %Find marker numbers once epoched (should be the same as without epoching)
%     rejection=find(contains(b2, mknum)) %Find location of marker which will be epoch number
%     if ~isempty(rejection)
%     EEG1 = pop_rejepoch( EEG1, rejection,0);%Reject epoch with the C17 before crashing
%     end
%     end
    EEG2.data(:, 1:250, :) = EEG1.data(:, 1:250, :);
%     combinedeventinfo = [EEG1.event, EEG2.event];
%     EEG2.event = combinedeventinfo;
    EEG=EEG2;
%    EEG = pop_rmbase( EEG, epoch.baseline ,[]);
    EEG.setname = strcat(nme, epoch.save_suffix); 
    EEG.filename=char(strcat(nme, epoch.save_suffix, '.set'));
    EEG.filepath=epoched_path;
    EEG = pop_saveset( EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end
end
% 
EEG = pop_loadset ('Y:\Uncertainty\EEG analysis\Preprocessed\Importedcrash\U_012_T_imported.set');
EEG = eeg_checkset(EEG);
EEG = pop_eegfiltnew(EEG, 'hicutoff',epoch.bandpassfilter(2)); %low pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',epoch.bandpassfilter(1)); %high pass filter
EEG = pop_resample(EEG, 500);
EEG1 = pop_epoch(EEG, epoch.onemarker, [-0.5 0]); %epoch one
EEG2 = pop_epoch(EEG, epoch.twomarker, epoch.twotimewindow); %epoch two
EEG1 = pop_rejepoch( EEG1, [39 40],0);
EEG2 = pop_rejepoch( EEG2, [39],0);
EEG2.data(:, 1:250, :) = EEG1.data(:, 1:250, :);
EEG=EEG2;
%EEG = pop_rmbase( EEG, epoch.baseline ,[]);
EEG = pop_saveset( EEG, 'filename','U_012_T_epoched.set','filepath', 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched');

EEG = pop_loadset ('Y:\Uncertainty\EEG analysis\Preprocessed\Importedcrash\U_021_T_imported.set');
EEG = eeg_checkset(EEG);
EEG = pop_eegfiltnew(EEG, 'hicutoff',epoch.bandpassfilter(2)); %low pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',epoch.bandpassfilter(1)); %high pass filter
EEG = pop_resample(EEG, 500);
EEG1 = pop_epoch(EEG, epoch.onemarker, [-0.5 0]); %epoch one
EEG2 = pop_epoch(EEG, epoch.twomarker, epoch.twotimewindow); %epoch two
EEG1 = pop_rejepoch(EEG1,[71],0);
EEG2.data(:, 1:250, :) = EEG1.data(:, 1:250, :);
EEG=EEG2;
%EEG = pop_rmbase( EEG, epoch.baseline ,[]);
EEG = pop_saveset( EEG, 'filename','U_021_T_epoched.set','filepath', 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched');

EEG = pop_loadset ('Y:\Uncertainty\EEG analysis\Preprocessed\Importedcrash\U_022_T_imported.set');
EEG = eeg_checkset(EEG);
EEG = pop_eegfiltnew(EEG, 'hicutoff',epoch.bandpassfilter(2)); %low pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',epoch.bandpassfilter(1)); %high pass filter
EEG = pop_resample(EEG, 500);
EEG1 = pop_epoch(EEG, epoch.onemarker, [-0.5 0]); %epoch one
EEG2 = pop_epoch(EEG, epoch.twomarker, epoch.twotimewindow); %epoch two
EEG1 = pop_rejepoch(EEG1,[71],0);
EEG2.data(:, 1:250, :) = EEG1.data(:, 1:250, :);
EEG=EEG2;
%EEG = pop_rmbase( EEG, epoch.baseline ,[]);
EEG = pop_saveset( EEG, 'filename','U_022_T_epoched.set','filepath', 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched');

EEG = pop_loadset ('Y:\Uncertainty\EEG analysis\Preprocessed\Importedcrash\U_024_T_imported.set');
EEG = eeg_checkset(EEG);
EEG = pop_eegfiltnew(EEG, 'hicutoff',epoch.bandpassfilter(2)); %low pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',epoch.bandpassfilter(1)); %high pass filter
EEG = pop_resample(EEG, 500);
EEG1 = pop_epoch(EEG, epoch.onemarker, [-0.5 0]); %epoch one
EEG2 = pop_epoch(EEG, epoch.twomarker, epoch.twotimewindow); %epoch two
EEG1 = pop_rejepoch(EEG1,[21],0);
EEG2.data(:, 1:250, :) = EEG1.data(:, 1:250, :);
EEG=EEG2;
%EEG = pop_rmbase( EEG, epoch.baseline ,[]);
EEG = pop_saveset( EEG, 'filename','U_024_T_epoched.set','filepath', 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched');

EEG = pop_loadset ('Y:\Uncertainty\EEG analysis\Preprocessed\Importedcrash\U_062_T_imported.set');
EEG = eeg_checkset(EEG);
EEG = pop_eegfiltnew(EEG, 'hicutoff',epoch.bandpassfilter(2)); %low pass filter
EEG = pop_eegfiltnew(EEG, 'locutoff',epoch.bandpassfilter(1)); %high pass filter
EEG = pop_resample(EEG, 500);
EEG1 = pop_epoch(EEG, epoch.onemarker, [-0.5 0]); %epoch one
EEG2 = pop_epoch(EEG, epoch.twomarker, epoch.twotimewindow); %epoch two
EEG1 = pop_rejepoch(EEG1,[72],0);
EEG2.data(:, 1:250, :) = EEG1.data(:, 1:250, :);
EEG=EEG2;
%EEG = pop_rmbase( EEG, epoch.baseline ,[]);
EEG = pop_saveset( EEG, 'filename','U_062_T_epoched.set','filepath', 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched');
