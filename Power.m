%%%Script created by Ariane Delgado Sanchez
%% START
clear all 
dbstop if error % optional instruction to stop at a breakpoint if there is an error - useful for debugging
%% SET DIRECTORIES
%For toolboxes 
scripts_path='Y:\Uncertainty\Scripts'; % general path where I store scripts
eeglab_path = 'Y:\Uncertainty\Scripts\eeglab2022.0' ;  % EEGLAB path
fieldtrip_path= 'Y:\Uncertainty\Scripts\fieldtrip-20220104\fieldtrip-20220104' ; % fieldtrip path
data_path = 'Y:\Uncertainty\EEG analysis\Preprocessed\Continuous1'; % The path to the data you want to extract the power from.

addpath(scripts_path);
addpath(eeglab_path);
addpath(fieldtrip_path);

%Change it to select your conditions
%Select the data that you want to preprocess. 
power=struct;% clears the field
%%power.excludeparticipant = {}; %Participants to be excluded. If there is none put a number above the sample size.


%%Potential improvement - I can probably do this much simpler adding an &
%%but it seems to not be possible with this type of data or maybe I have
%%not used the right syntax. For now this rudementary and bulky way of
%%doing it works. 
filelist=pickfilelistADS(data_path, 'set')
if isempty(filelist)
    error('No files found for power analysis!\n');
end
%% Set data options to extract frequencies

%% If you want to get these frequencies write 1 next to it, if you don´t
%%want it write 0
delta =1;
theta =1;
alpha =1;
beta = 1;
gamma= 1;

selectedchannels={'all'};% change this if you want to select specific channels
channme='allchanels';% this is what will appear in the name of the excel sheet saved. 
    %It is to mark whether it is a doc with all the channels or only some.
    %This way you can run the same script several times selecting different
    %channels and you will not overwrite the output files. If you want to
    %make this specific to each frequency just write the two lines of code
    %underneath the if delta==1, if beta==1, etc


if delta == 1
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    %nme= erase(nme,"_continuous"); %%You can use this to change whatever extension name you have and for it to not appear on the list. E.g. epoched, continuous. 
    cfg = []; 
    cfg.dataset = fullfile(data_path, filenme);
    ft_data1 = ft_preprocessing(cfg);
    cfg = []; 
    cfg.output = 'pow'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis
    cfg.keeptrials= 'no'; %to keep trial information when extracting frequencies
    cfg.channels= selectedchannels;
    cfg.method = 'mtmfft'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.taper = 'hanning';%https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.pad = 'nextpow2';
    cfg.foilim = [1 3]; %frequency band of interest
    [freq] = ft_freqanalysis(cfg, ft_data1);
    cfg = [];
    cfg.avgoverfreq = 'yes';
    [averfreq] = ft_selectdata(cfg, freq);
    cfg=[];
    cfg.parameter = 'powspctrm';
    cfg.operation = '20*log(x1)';
    LOGaverfreq = ft_math(cfg, averfreq);
    snameexcel =[nme channme 'delta' '.xlsx'];
    xlswrite (fullfile(data_path,snameexcel), averfreq.label', 'Sheet1','A1');
    xlswrite (fullfile(data_path,snameexcel), averfreq.powspctrm', 'Sheet1','A2');
    xlswrite (fullfile(data_path,snameexcel), LOGaverfreq.powspctrm', 'Sheet1','A3');
end
end

if theta == 1
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    %nme= erase(nme,"_continuous"); %%You can use this to change whatever extension name you have and for it to not appear on the list. E.g. epoched, continuous. 
    cfg = []; 
    cfg.dataset = fullfile(data_path, filenme);
    ft_data1 = ft_preprocessing(cfg);
    cfg = []; 
    cfg.output = 'pow'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis
    cfg.keeptrials= 'no'; %to keep trial information when extracting frequencies
    cfg.channels=selectedchannels;
    cfg.method = 'mtmfft'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.taper = 'hanning';%https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.pad = 'nextpow2';
    cfg.foilim = [4 7]; %frequency band of interest
    [freq] = ft_freqanalysis(cfg, ft_data1);
    cfg = [];
    cfg.avgoverfreq = 'yes';
    [averfreq] = ft_selectdata(cfg, freq);
    cfg=[];
    cfg.parameter = 'powspctrm';
    cfg.operation = '20*log(x1)';
    LOGaverfreq = ft_math(cfg, averfreq);
    snameexcel =[nme channme 'theta' '.xlsx'];
    xlswrite (fullfile(data_path,snameexcel), averfreq.label', 'Sheet1','A1');
    xlswrite (fullfile(data_path,snameexcel), averfreq.powspctrm', 'Sheet1','A2');
    xlswrite (fullfile(data_path,snameexcel), LOGaverfreq.powspctrm', 'Sheet1','A3');
end
end

if alpha == 1
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    %nme= erase(nme,"_continuous"); %%You can use this to change whatever extension name you have and for it to not appear on the list. E.g. epoched, continuous. 
    cfg = []; 
    cfg.dataset = fullfile(data_path, filenme);
    ft_data1 = ft_preprocessing(cfg);
    cfg = []; 
    cfg.output = 'pow'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis
    cfg.keeptrials= 'no'; %to keep trial information when extracting frequencies
    cfg.channels=selectedchannels;
    cfg.method = 'mtmfft'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.taper = 'hanning';%https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.pad = 'nextpow2';
    cfg.foilim = [8 13]; %frequency band of interest
    [freq] = ft_freqanalysis(cfg, ft_data1);
    cfg = [];
    cfg.avgoverfreq = 'yes';
    [averfreq] = ft_selectdata(cfg, freq);
    cfg=[];
    cfg.parameter = 'powspctrm';
    cfg.operation = '20*log(x1)';
    LOGaverfreq = ft_math(cfg, averfreq);
    snameexcel =[nme channme 'alpha' '.xlsx'];
    xlswrite (fullfile(data_path,snameexcel), averfreq.label', 'Sheet1','A1');
    xlswrite (fullfile(data_path,snameexcel), averfreq.powspctrm', 'Sheet1','A2');
    xlswrite (fullfile(data_path,snameexcel), LOGaverfreq.powspctrm', 'Sheet1','A3');
end
end

if beta == 1
for f = 1:length (filelist)
    filenme = filelist {f};
    [fpath,nme,ext] = fileparts(filenme);%extract name without extension
    %nme= erase(nme,"_continuous"); %%You can use this to change whatever extension name you have and for it to not appear on the list. E.g. epoched, continuous. 
    cfg = []; 
    cfg.dataset = fullfile(data_path, filenme);
    ft_data1 = ft_preprocessing(cfg);
    cfg = []; 
    cfg.output = 'pow'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis
    cfg.keeptrials= 'no'; %to keep trial information when extracting frequencies
    cfg.channels=selectedchannels;
    cfg.method = 'mtmfft'; %https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.taper = 'hanning';%https://www.fieldtriptoolbox.org/reference/ft_freqanalysis/
    cfg.pad = 'nextpow2';
    cfg.foilim = [14 30]; %frequency band of interest
    [freq] = ft_freqanalysis(cfg, ft_data1);
    cfg = [];
    cfg.avgoverfreq = 'yes';
    [averfreq] = ft_selectdata(cfg, freq);
    cfg=[];
    cfg.parameter = 'powspctrm';
    cfg.operation = '20*log(x1)';
    LOGaverfreq = ft_math(cfg, averfreq);
    snameexcel =[nme channme 'beta' '.xlsx'];
    xlswrite (fullfile(data_path,snameexcel), averfreq.label', 'Sheet1','A1');
    xlswrite (fullfile(data_path,snameexcel), averfreq.powspctrm', 'Sheet1','A2');
    xlswrite (fullfile(data_path,snameexcel), LOGaverfreq.powspctrm', 'Sheet1','A3');
end
end
