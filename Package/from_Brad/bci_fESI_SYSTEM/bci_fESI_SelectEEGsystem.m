function [hObject,handles]=bci_fESI_SelectEEGsystem(hObject,handles)

set(handles.selectsensors,'UserData',[]);

eegsystem=get(hObject,'Value');
switch eegsystem
    case 1 % None
        set(handles.fs,'String','')
        set(hObject,'BackgroundColor','red');
        if isfield(handles,'Electrodes')
            handles=rmfield(handles,'Electrodes');
        end
    case 2 % Neuroscan 64
        % Automatically update sampling rate based on EEG system
        set(handles.fs,'String',num2str(1000))
        % Adjust high cutoff to nyquist frequency if set at value above
        if isempty(get(handles.highcutoff,'String'))
        elseif str2double(get(handles.highcutoff,'String'))>=1000
            set(handles.highcutoff,'String',num2str(500))
        end
        set(hObject,'BackgroundColor','white');
        
        ChanIdxAutoExclude=[33 43 60 64 65:68]; % M1-2,CB1-2,VEO,HEO,EKG,EMG 
        ChanIdxAutoExclude=sort(ChanIdxAutoExclude,'ascend');
        eFILE='bci_fESI_neuroscan68.loc';
        
    case 3 % neuroscan 128
        set(handles.fs,'String',num2str(1000))
        if isempty(get(handles.highcutoff,'String'))
        elseif str2double(get(handles.highcutoff,'String'))>=1000
            set(handles.highcutoff,'String',num2str(500))
        end
        set(hObject,'BackgroundColor','white');
        
        ChanIdxAutoExclude=[10 11 84 85 110 111 129:132];
        ChanIdxAutoExclude=sort(ChanIdxAutoExclude,'ascend');
        eFILE='bci_fESI_neuroscan132.loc';
        
    case 4 % BioSemi 64
        set(handles.fs,'String',num2str(1024))
        if isempty(get(handles.highcutoff,'String'))
        elseif str2double(get(handles.highcutoff,'String'))>=1024
            set(handles.highcutoff,'String',num2str(512))
        end
        set(hObject,'BackgroundColor','white');
        
        ChanIdxAutoExclude=[];
        ChanIdxAutoExclude=sort(ChanIdxAutoExclude,'ascend');
        eFILE='bci_fESI_BioSemi64.xyz';
        
    case 5 % BioSemi 128
        set(handles.fs,'String',num2str(1024))
        if isempty(get(handles.highcutoff,'String'))
        elseif str2double(get(handles.highcutoff,'String'))>=1024
            set(handles.highcutoff,'String',num2str(512))
        end
        set(hObject,'BackgroundColor','white');
        
        ChanIdxAutoExclude=[];
        ChanIdxAutoExclude=sort(ChanIdxAutoExclude,'ascend');
        eFILE='bci_fESI_BioSemi128.xyz';
        
    case 6 % Signal Generator
        set(handles.fs,'String',num2str(256));
        if isempty(get(handles.highcutoff,'String'))
        elseif str2double(get(handles.highcutoff,'String'))>=256
            set(handles.highcutoff,'String',num2str(128))
        end
        set(hObject,'BackgroundColor','white');
        
        ChanIdxAutoExclude=[];
        ChanIdxAutoExclude=sort(ChanIdxAutoExclude,'ascend');
        eFILE='bci_fESI_SigGen16.xyz';
end

switch eegsystem
    case 1
        axes(handles.axes3); cla
    case {2,3,4,5,6}
        if exist(eFILE,'file')
            eLoc=readlocs(eFILE);
        else
            fprintf(2,'%s SENSOR LOCATION FILE NOT IN ROOT FOLDER\n',eFILE);
            set(hObject,'BackgroundColor','red','UserData',2);
            set(hObject,'UserData',2);
        end

        % Save electrode montage
        eLoc(ChanIdxAutoExclude)=[];
        handles.Electrodes.chanidxautoexclude=ChanIdxAutoExclude;
        handles.Electrodes.original.eLoc=eLoc;
        handles.Electrodes.current.eLoc=eLoc;
        handles.Electrodes.current.plotX=cell2mat({eLoc.X});
        handles.Electrodes.current.plotY=cell2mat({eLoc.Y});
        handles.Electrodes.current.plotZ=cell2mat({eLoc.Z});
        handles.Electrodes.chanidxinclude=1:size(eLoc,2);

        % Plot electrode montage
        axes(handles.axes3); cla
        hold off; view(2); colorbar off;
        topoplot([],eLoc,'electrodes','ptlabels');
        set(gcf,'color',[.94 .94 .94])
        set(handles.Axis3Label,'String','Electrode Montage');
        title('')
end

