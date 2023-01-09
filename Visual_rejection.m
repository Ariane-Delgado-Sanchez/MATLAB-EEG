%% Script_eeglab_analysis 2022. This script serves to visually inspect the data before ICA 
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

epoched_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Epoched';
continuous_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Continuous';
preICAclean_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\preICAclean';

preICAclean=struct;% clears the field
preICAclean.condition = {'T'};%Conditions to be included
preICAclean.extension =  {'set'}; %Type of data (brainvision)
preICAclean.save_suffix = {'_preICAclean'}; %Suffix to use to save data

filelist1=strtrim(string (ls (epoched_path)));
filelist2=contains (filelist1, preICAclean.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end

%%This runs through the files in the continuous folder, uses the plugin
%%cleanrawdata on them and writes on a file which channels would be
%%rejected according to this. Write channels to reject in numbers
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_epoched");
    delete(findall(0,'Type','figure'));
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
    delete(findall(0,'Type','figure'));
    EEG = pop_loadset (filenme, epoched_path); %load file
    pop_spectopo(EEG);
    pop_eegplot( EEG, 1, 1, 1);
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    delete(findall(0,'Type','figure'));
    a = split(inputdlg("Channels to reject"));
    EEG = pop_select( EEG, 'nochannel',a);
    %EEG = pop_interp(EEG, [answer2], 'spherical');
    pop_eegplot( EEG, 1, 1, 1);
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    EEG.setname = strcat(nme, preICAclean.save_suffix); 
    EEG.filename=char(strcat(nme, preICAclean.save_suffix, '.set'));
    EEG.filepath=preICAclean_path;
    EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end

