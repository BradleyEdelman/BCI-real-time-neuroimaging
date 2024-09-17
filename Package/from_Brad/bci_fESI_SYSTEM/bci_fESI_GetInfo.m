function [hObject,handles]=bci_fESI_GetInfo(hObject,handles,SetField)

if ~isfield(handles,SetField)
    handles.(SetField)=[];
end

set(hObject,'userdata',1);

initials=get(handles.initials,'string');
set(handles.initials,'backgroundcolor','green');
if isempty(initials)
    fprintf(2,'INITIALS NOT SPECIFIED\n');
    set(handles.initials,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

session=get(handles.session,'string');
set(handles.session,'backgroundcolor','green');
if isempty(session)
    fprintf(2,'SESSION # NOT SPECIFIED\n');
    set(handles.session,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

% Run=get(handles.Run,'string');
% set(handles.Run,'backgroundcolor','green');
% if isempty(Run)
%     fprintf(2,'RUN # NOT SPECIFIED\n');
%     set(handles.Run,'backgroundcolor','red');
%     set(hObject,'backgroundcolor','red','userdata',0);
% end

year=get(handles.year,'string');
set(handles.year,'backgroundcolor','green');
if isempty(year)
    fprintf(2,'YEAR NOT SPECIFIED\n');
    set(handles.year,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

month=get(handles.month,'string');
set(handles.month,'backgroundcolor','green');
if isempty(month)
    fprintf(2,'MONTH NOT SPECIFIED\n');
    set(handles.month,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

day=get(handles.day,'string');
set(handles.day,'backgroundcolor','green');
if isempty(day)
    fprintf(2,'DAY NOT SPECIFIED\n');
    set(handles.day,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

savepath=get(handles.savepath,'string');
set(handles.savepath,'backgroundcolor','green');
if isempty(savepath) || ~isequal(exist(savepath,'dir'),7)
    fprintf(2,'SAVEPATH NOT SPECIFIED\n');
    set(handles.Savepath,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

eegsystem=get(handles.eegsystem,'value');
set(handles.eegsystem,'backgroundcolor','green');
if isequal(eegsystem,1)
    fprintf(2,'EEG SYSTEM NOT SPECIFIED\n');
    set(handles.eegsystem,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end
fs=get(handles.fs,'string');

currentelectrodes=get(handles.selectsensors,'userdata');
set(handles.selectsensors,'backgroundcolor','green')
if isempty(currentelectrodes) || isequal(sum(currentelectrodes),0)
    fprintf(2,'NO ELECTRODES SELECTED\n');
    set(handles.selectsensors,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
else
    chanidxinclude=find(currentelectrodes==1);
    chanidxexclude=find(currentelectrodes==0)';
    currenteloc=handles.Electrodes.original.eLoc;
    currenteloc(chanidxexclude)=[];
end

dsfactor=str2double(get(handles.dsfactor,'string'));
set(handles.dsfactor,'backgroundcolor','green');

psd=get(handles.psd,'value');
set(handles.psd,'backgroundcolor','green');
if isequal(psd,1)
    fprintf(2,'FREQUENCY TRANSFORM NOT SPECIFIED\n');
    set(handles.psd,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

lowcutoff=str2double(get(handles.lowcutoff,'string'));
set(handles.lowcutoff,'backgroundcolor','green');
if isempty(lowcutoff) || strcmp(lowcutoff,'Low') || isnan(lowcutoff)
    fprintf(2,'LOW FREQUENCY BOUND NOT SPECIFIED\n');
    set(handles.lowcutoff,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

highcutoff=str2double(get(handles.highcutoff,'string'));
set(handles.highcutoff,'backgroundcolor','green');
if isempty(highcutoff) || strcmp(highcutoff,'High') || isnan(highcutoff)
    fprintf(2,'HIGH FREQUENCY BOUND NOT SPECIFIED\n');
    set(handles.highcutoff,'backgroundcolor','red');
    set(hObject,'backgroundcolor','red','userdata',0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IF ALL FIELDS ARE VALID, CREATE AND STORE NECESSARY PARAMETERS
if isequal(get(hObject,'userdata'),1)
    
    set(hObject,'backgroundcolor','green');
    subdir=strcat(savepath,'\',initials);

    sessiondir=strcat(subdir,'\',initials,year,month,day,'S',session);
    if ~exist(sessiondir,'dir')
        mkdir(sessiondir)
    end

    savefiledir=strcat(sessiondir,'\Saved');
    if ~exist(savefiledir,'dir')
        mkdir(savefiledir)
    end
    
    % CREATE BANDPASS FILTER
    n=4;
    numfreq=size(lowcutoff:highcutoff,2);
    fs2=str2double(get(handles.fs,'string'))/dsfactor;
    Wn=[lowcutoff highcutoff]/(fs2/2);
    [b,a]=butter(n,Wn);
    
    % ESTABLISH FREQUENCY TRANSFORMATION PARAMETERS
    psd=get(handles.psd,'value');
    handles.ESI.psd=psd;
    switch psd
        case 1 % None
            
        case 2 % Complex Morlet Wavelet
            
            mwparam.Freq=[lowcutoff highcutoff];
            mwparam.FreqRes=1;
            mwparam.FreqVect=lowcutoff:mwparam.FreqRes:highcutoff;
            mwparam.NumFreq=size(mwparam.FreqVect,2);
            mwparam.fs=str2double(get(handles.fs,'string'))/dsfactor;
            morwav=bci_fESI_MorWav(mwparam);
            handles.(SetField).mwparam=mwparam;
            handles.(SetField).morwav=morwav;

        case 3 % Welch's PSD
            
            welchparam.overlap=0;
            welchparam.nfft=2^(nextpow2(str2double(get(handles.AnalysisWindow,'string')))+1);
            welchparam.freqfact=2;
            welchparam.fs=str2double(get(handles.fs,'string'))/dsfactor;
            handles.(SetField).WelchParam=welchparam;

        case 4 % DFT
            
    end
    
    handles.(SetField).initials=initials;
    handles.(SetField).session=session;
    % handles.(SetField).run=Run;
    handles.(SetField).savepath=savepath;
    handles.(SetField).year=year;
    handles.(SetField).month=month;
    handles.(SetField).day=day;
    handles.(SetField).subdir=subdir;
    handles.(SetField).sessiondir=sessiondir;
    handles.(SetField).savefiledir=savefiledir;
    handles.(SetField).eegsystem=eegsystem;
    handles.(SetField).fs=fs;
    handles.(SetField).Electrodes=handles.Electrodes;
    handles.(SetField).Electrodes.current.eLoc=currenteloc;
    handles.(SetField).Electrodes.chanidxexclude=chanidxexclude;
    handles.(SetField).Electrodes.chanidxinclude=chanidxinclude;
    handles.(SetField).dsfactor=dsfactor;
    handles.(SetField).psd=psd;
    handles.(SetField).filter.a=a;
    handles.(SetField).filter.b=b;
    handles.(SetField).lowcutoff=lowcutoff;
    handles.(SetField).highcutoff=highcutoff;
    
    % SAVE SYSTEM PARAMETERS TO FILE
    k=1;
    savefile=strcat(savefiledir,'\',SetField,'_',num2str(k),'.mat');
    % Dont duplicate file (may want to load later)
    while exist(savefile,'file')
        k=k+1;
        savefile=strcat(savefiledir,'\',SetField,'_',num2str(k),'.mat');
    end
    handles.(SetField).savefile=savefile;
    savevar=matlab.lang.makeValidName(strcat('Save',SetField));
    eval([savevar ' = handles.(SetField);']);
    save(savefile,savevar,'-v7.3');
    
end


