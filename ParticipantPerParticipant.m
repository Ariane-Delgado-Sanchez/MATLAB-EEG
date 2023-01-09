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
ICA_path='Y:\Uncertainty\EEG analysis\Preprocessed\ICA';
postICA_path='Y:\Uncertainty\EEG analysis\Preprocessed\postICA';
postICAclean_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\postICAclean';


preICAclean=struct;% clears the field
preICAclean.condition = {'T'};%Conditions to be included
preICAclean.extension =  {'set'}; %Type of data (brainvision)
preICAclean.load_suffix= {'_epoched'};
preICAclean.save_suffix = {'_preICAclean'}; %Suffix to use to save data
ICA=struct;% clears the field
ICA.condition = {'T'};%Conditions to be included
ICA.extension =  {'set'}; %Type of data (brainvision)
ICA.load_suffix = {'_preICAclean'};
ICA.save_suffix = {'_ICA'}; %Suffix to use to save data
postICA=struct;% clears the field
postICA.condition = {'T'};%Conditions to be included
postICA.load_suffix = {'_ICA'}; %Suffix to use to save data
postICA.extension =  {'set'}; %Type of data (brainvision)
postICA.save_suffix = {'_postICA'}; %Suffix to use to save data
postICAclean.save_suffix = {'_postICAclean'}; %Suffix to use to save data

filelist1=strtrim(string (ls (epoched_path)));
filelist2=contains (filelist1, preICAclean.extension);
filelist=filelist1(filelist2);

if isempty(filelist)
    error('No files found!\n');
end



for f = 1:length (filelist)
        filenme = filelist {f};
        [fpath,nme,ext] = fileparts(filenme);
        nme= erase(nme,"_epoched");
        startagain=1;
    while (startagain ==1)
        visrej = str2double(split(inputdlg("Visual rejection?: 1=yes, 0=no")));
        if visrej==1
            %extract name without extension
            delete(findall(0,'Type','figure'));
            [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
            delete(findall(0,'Type','figure'));
            EEG = pop_loadset (char(strcat(nme, preICAclean.load_suffix, '.set')), epoched_path); %load file
            pop_spectopo(EEG);
            pop_timtopo(EEG);
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
        ICAdecomposition = str2double(split(inputdlg("Perform ICA decomposition?: 1=yes, 0=no")));
        if ICAdecomposition==1
          nme= erase(nme,"_preICAclean");
          [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
          delete(findall(0,'Type','figure'));
          EEG = pop_loadset (char(strcat(nme, ICA.load_suffix, '.set')), preICAclean_path); %load file
          numcomp = numcompeig(EEG);
          EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on', 'PCA', numcomp); %ADD PCA
          EEG.setname = strcat(nme, ICA.save_suffix); 
          EEG.filename=char(strcat(nme, ICA.save_suffix, '.set'));
          EEG.filepath=ICA_path;
          EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
        end
        ICAvisrej = str2double(split(inputdlg("Select ICA components?: 1=yes, 0=no")));
        if ICAvisrej==1
        nme= erase(nme,"_ICA");
        delete(findall(0,'Type','figure'));
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab; 
        delete(findall(0,'Type','figure'));
        origfilenme=char(strcat(nme,"_epoched", '.set'));
        origEEG=pop_loadset(origfilenme, epoched_path);
        EEG = pop_loadset (char(strcat(nme, postICA.load_suffix, '.set')), ICA_path); %load file
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
        pop_timtopo(EEG);
        pop_eegplot( EEG, 0, 1, 1);
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
        pop_timtopo(EEG);
        pop_eegplot( EEG, 1, 1, 1);
        waitfor(findobj('parent', gcf, 'string', 'REJECT'), 'userdata');
        delete(findall(0,'Type','figure'));
        EEG.setname = strcat(nme, postICAclean.save_suffix); 
        EEG.filename=char(strcat(nme, postICAclean.save_suffix, '.set'));
        EEG.filepath=postICAclean_path;
        EEG = pop_saveset(EEG, 'filename',EEG.filename,'filepath', EEG.filepath);
        end
   startagain = str2double(split(inputdlg("Repeat participant?: 1=yes, 0=no")));
    end
end

