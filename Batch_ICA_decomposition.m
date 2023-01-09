%%ICA_decomposition script
%This script decomposes data in ICA.
%% START
clear all 
dbstop if error
%dbstop if error % optional instruction to stop at a breakpoint if there is an error - useful for debugging
%Firstw we state the paths where the toolboxes and functions are
scripts_path='Y:\Uncertainty\Scripts';
eeglab_path = 'Y:\Uncertainty\Scripts\eeglab2022.0' ;  
fieldtrip_path= 'Y:\Uncertainty\Scripts\fieldtrip-20220104' ; 
%Then we add the paths. Addpath adds the paths, genpath creates it, if you
%use them together you add the 
addpath(scripts_path);
addpath(eeglab_path);
addpath(fieldtrip_path);

epoched_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched1';
continuous_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Continuous';
preICAclean_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\preICAclean';
ICA_path='Y:\Uncertainty\EEG analysis\Preprocessed\ICA';


ICA=struct;% clears the field
ICA.condition = {'T'};%Conditions to be included
ICA.extension =  {'set'}; %Type of data (brainvision)
ICA.save_suffix = {'_ICA'}; %Suffix to use to save data

filelist1=strtrim(string (ls (preICAclean_path)));
filelist2=contains (filelist1, ICA.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_preICAclean");
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
    delete(findall(0,'Type','figure'));
    EEG = pop_loadset (filenme, preICAclean_path); %load file
    numcomp = numcompeig(EEG);
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on', 'PCA', numcomp); %ADD PCA
    EEG.setname = strcat(nme, ICA.save_suffix); 
    EEG.filename=char(strcat(nme, ICA.save_suffix, '.set'));
    EEG.filepath=ICA_path;
    EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end

