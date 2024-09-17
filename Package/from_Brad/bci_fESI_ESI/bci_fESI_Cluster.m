function [hObject,handles]=bci_fESI_Cluster(hObject,handles)

Parcellation=get(handles.Parcellation,'Value');
switch Parcellation
    
    case 1 % None Selected
        
    case 2 % None
        
    case 3 % MSP
        
        ESIFiles=cellstr(get(handles.ESIFiles,'String'));
        [TrialStruct]=bci_fESI_ExtractBCI2000Parameters(TrainFiles);
        [handles,TaskInfo,Data]=bci_fESI_TaskInfo(handles,TrainFiles,TrialStruct);
        
        % Generate bandpass filter
        LowCutoff=str2double(get(handles.LowCutoff,'String'));
        HighCutoff=str2double(get(handles.HighCutoff,'String'));
        handles.(DomainField).numfreq=size(LowCutoff:HighCutoff,2);
        n=4;
        Wn=[LowCutoff HighCutoff]/(fs/4/2);
        [b,a]=butter(n,Wn);
        handles.(DomainField).bpfiltb=b;
        handles.(DomainField).bpfilta=a;
        Data=Data-repmat(mean(Data,2),[1 size(Data,2)]);
        % Common average reference
        Data=Data-repmat(mean(Data,1),[size(Data,1),1]);
        % Bandpass filter
        Data=filtfilt(b,a,double(Data'));
        Data=Data';
        
        
        
        
    case 4 % k-means
end
