%%ICA_visusl rejection script
%This script shows the component plots, allows you to select them and then saves the files without them. It uses SASICA.
%% START https://labeling.ucsd.edu/tutorial
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

epoched_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched';
continuous_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Continuous';
ICA_path='Y:\Uncertainty\EEG analysis\Preprocessed\ICA';
postICA_path='Y:\Uncertainty\EEG analysis\Preprocessed\postICA';
postICAclean_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\postICAclean';

postICA=struct;% clears the field
postICA.condition = {'T'};%Conditions to be included
postICA.extension =  {'set'}; %Type of data (brainvision)
postICA.save_suffix = {'_postICA'}; %Suffix to use to save data
postICAclean.save_suffix = {'_postICAclean'}; %Suffix to use to save data

filelist1=strtrim(string (ls (ICA_path)));
filelist2=contains (filelist1, postICA.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end

for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_ICA");
    delete(findall(0,'Type','figure'));
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
    delete(findall(0,'Type','figure'));
    origfilenme=char(strcat(nme,"_epoched", '.set'));
    origEEG=pop_loadset(origfilenme, epoched_path);
    EEG = pop_loadset (filenme, ICA_path); %load file
    graphs = str2double(split(inputdlg("Show ICA component selection: 1=yes, 0=no")));
    while (graphs==1)
    EEG1= pop_iclabel(EEG, 'default');
    EEG1 = eeg_checkset( EEG1 );
    pop_selectcomps(EEG1);
    waitfor (gcf)
    [EEG1 com] = SASICA(EEG1);
    pop_eegplot( EEG, 0, 1, 1);
    pop_eegplot( EEG1, 1, 1, 1);
    waitfor (gcf) %This waits for SASICA to be closed before moving on. Note that the small window needs to be closed manually too, it´s not enough to click ok on the plot window
    EEG1 = pop_subcomp( EEG, [], 1);
    waitfor(findall(0,'Type','figure'));
    pop_eegplot( EEG1, 1, 1, 1);
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    pop_eegplot( EEG, 0, 1, 1);
    pop_timtopo(EEG);
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    delete(findall(0,'Type','figure'));
    repeat = str2double(split(inputdlg("Show ICA component selection again: 1=yes, 0=no")));
    if repeat ==0
        break
    end
    end
    EEG=EEG1;
    delete(findall(0,'Type','figure'));
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    EEG=pop_interp(EEG,origEEG.chanlocs, 'spherical');
    EEG.setname = strcat(nme, postICA.save_suffix); 
    EEG.filename=char(strcat(nme, postICA.save_suffix, '.set'));
    EEG.filepath=postICA_path;
    EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
    pop_spectopo(EEG);
    pop_eegplot( EEG, 1, 1, 1);
    pop_timtopo(EEG);
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    delete(findall(0,'Type','figure'));
    EEG.setname = strcat(nme, postICAclean.save_suffix); 
    EEG.filename=char(strcat(nme, postICAclean.save_suffix, '.set'));
    EEG.filepath=postICAclean_path;
    EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end