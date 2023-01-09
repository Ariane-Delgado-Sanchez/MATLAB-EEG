%% Script_eeglab_analysis 2022. This script serves to visually inspect the data after ICA. 
%Note: It is the same as the visual rejection for before ICA but I have it in two scripts so I do not need to change directories, etc.
%The channel interpolation lines are also commented out since these should
%happen before ICA, not after.
%% START
clear all 
dbstop if error % optional instruction to stop at a breakpoint if there is an error - useful for debugging
%First we state the paths where the toolboxes and functions are.
scripts_path='Y:\Uncertainty\Scripts';
eeglab_path = 'Y:\Uncertainty\Scripts\eeglab2022.0' ;  
fieldtrip_path= 'Y:\Uncertainty\Scripts\fieldtrip-20220104' ; 
%Then we add the paths. Addpath adds the paths, genpath creates it, if you
%use them together you add the 
addpath(scripts_path);
addpath(eeglab_path);
addpath(fieldtrip_path);

postICA_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\postICA';
postICAclean_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\postICAclean';

postICAclean=struct;% clears the field
postICAclean.condition = {'T'};%Conditions to be included
postICAclean.extension =  {'set'}; %Type of data (brainvision)
postICAclean.save_suffix = {'_postICAclean'}; %Suffix to use to save data

filelist1=strtrim(string (ls (postICA_path)));
filelist2=contains (filelist1, postICAclean.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end

%%This runs through the files in the continuous folder, uses the plugin
%%cleanrawdata on them and writes on a file which channels would be
%%rejected according to this. 
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    nme= erase(nme,"_postICA");
    delete(findall(0,'Type','figure'));
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
    delete(findall(0,'Type','figure'));
    EEG = pop_loadset (filenme, postICA_path); %load file
    pop_eegplot( EEG, 1, 1, 1);
    waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
    delete(findall(0,'Type','figure'));
    %answer = inputdlg("Channels to interpolate");
    %answer2 = str2num(answer{1});
    %EEG = pop_interp(EEG, answer2, 'spherical');
    EEG.setname = strcat(nme, postICAclean.save_suffix); 
    EEG.filename=char(strcat(nme, postICAclean.save_suffix, '.set'));
    EEG.filepath=postICAclean_path;
    EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
end