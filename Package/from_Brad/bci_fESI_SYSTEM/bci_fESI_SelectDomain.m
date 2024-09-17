function [hObject,handles]=bci_fESI_SelectDomain(hObject,handles)

eegsystem=get(handles.eegsystem,'value');
if isequal(eegsystem,1)
    set(handles.eegsystem,'backgroundcolor','red')
end

psd=get(handles.psd,'value');
if isequal(psd,1)
    set(handles.psd,'backgroundcolor','red')
end

lowcutoff=get(handles.lowcutoff,'string');
if isempty(lowcutoff) || strcmp(lowcutoff,'Low')
    set(handles.lowcutoff,'backgroundcolor','red')
end

highcutoff=get(handles.highcutoff,'string');
if isempty(highcutoff) || strcmp(highcutoff,'High')
    set(handles.highcutoff,'backgroundcolor','red')
end

% % % Inform training options
% % set(handles.BrainRegionFile,'backgroundcolor','white');
% % set(handles.SelectBrainRegions,'backgroundcolor','white');
% % set(handles.SelectSensorRegions,'backgroundcolor','white');

domain=get(handles.domain,'value');
switch domain
    
    case 1 % None

        set(handles.eegsystem,'backgroundcolor','white')
        set(handles.psd,'backgroundcolor','white')
        set(handles.noise,'backgroundcolor','white')
        set(handles.noisefile,'backgroundcolor','white')
        set(handles.cortex,'backgroundcolor','white')
        set(handles.cortexlr,'backgroundcolor','white')
        set(handles.headmodel,'backgroundcolor','white')
        set(handles.fmri,'backgroundcolor','white')
        set(handles.vizsource,'value',0)
        set(handles.lrvizsource,'value',0)
        
        analysiswindow=get(handles.analysiswindow,'string');
        if isempty(analysiswindow)
            set(handles.analysiswindow,'backgroundcolor','white')
        end
        
        updatewindow=get(handles.updatewindow,'string');
        if isempty(updatewindow)
            set(handles.updatewindow,'backgroundcolor','white')
        end
        
        lowcutoff=get(handles.lowcutoff,'string');
        if isempty(lowcutoff) || strcmp(lowcutoff,'Low')
            set(handles.lowcutoff,'backgroundcolor','white')
        end
        
        highcutoff=get(handles.highcutoff,'string');
        if isempty(highcutoff) || strcmp(highcutoff,'High')
            set(handles.highcutoff,'backgroundcolor','white')
        end
        
        % Repopulate BCI options for current domain if they exist
        [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Clear');
        [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Clear');
        [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Clear');
        
    case 2 % Sensor
        
        set(hObject,'backgroundcolor','white')
        set(handles.noise,'backgroundcolor','white')
        set(handles.noisefile,'backgroundcolor','white')
        set(handles.cortexfile,'backgroundcolor','white')
        set(handles.cortexlrfile,'backgroundcolor','white')
        set(handles.headmodelfile,'backgroundcolor','white')
        set(handles.fmrifile,'backgroundcolor','white')
        set(handles.parcellation,'backgroundcolor','white')
        set(handles.vizsource,'value',0)
        set(handles.lrvizsource,'value',0)
        
        if isfield(handles,'Electrodes') && isfield(handles.Electrodes,'eLoc2') &&...
                ~isempty(handles.Electrodes.eLoc2)
            
            axes(handles.axes3)
            hold off; view(2); colorbar off
            topoplot([],handles.Electrodes.eLoc2,'electrodes','ptlabels');
            set(gcf,'color',[.94 .94 .94])
            set(handles.Axis3Label,'string','Electrode Montage');
            title('')
            
        end
        
        % Repopulate BCI options for current domain if they exist
        if isfield(handles,'RegressSensor') && isfield(handles.RegressSensor,'bcitask') &&...
                isfield(handles.RegressSensor,'bcifreq')
            
            set(handles.bcitask1,'string',handles.RegressSensor.bcitask{1})
            set(handles.bcitask2,'string',handles.RegressSensor.bcitask{2})
            set(handles.bcitask3,'string',handles.RegressSensor.bcitask{3})
            
            set(handles.bcifreq1,'string',handles.RegressSensor.bcifreq{1})
            set(handles.bcifreq2,'string',handles.RegressSensor.bcifreq{2})
            set(handles.bcifreq3,'string',handles.RegressSensor.bcifreq{3})
            
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Reset');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Reset');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Reset');
            
        else
            
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Clear');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Clear');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Clear');
            
        end
        

    case 3 % ESI
        
        set(hObject,'backgroundcolor','white')
        set(handles.fmrifile,'backgroundcolor','white')

        noise=get(handles.noise,'value');
        switch noise
            case 1 % None
                set(handles.noise,'backgroundcolor','red')
                set(handles.noisefile,'backgroundcolor','white')
            case 2 % No noise estimation
                set(handles.noise,'backgroundcolor','white')
                set(handles.noisefile,'backgroundcolor','white')
            case {3,4} % Diagonal of full noise covariance
                set(handles.noise,'backgroundcolor','white')
                set(handles.noisefile,'backgroundcolor',[1 .7 0])
        end
        
        cortexfile=get(handles.cortexfile,'string');
        if isempty(cortexfile)
            set(handles.cortexfile,'backgroundcolor','red')
        end
        
        headmodelfile=get(handles.headmodelfile,'string');
        if isempty(headmodelfile)
            set(handles.headmodelfile,'backgroundcolor','red')
        end
        
        brainregionfile=get(handles.brainregionfile,'string');
        if isempty(brainregionfile)
            set(handles.brainregionfile,'backgroundcolor','red');
        end
        
        % Repopulate BCI options for current domain if they exist
        if isfield(handles,'RegressSource') && isfield(handles.RegressSource,'bcitask') &&...
                isfield(handles.RegressSource,'bcifreq')
            
            set(handles.bcitask1,'string',handles.RegressSource.bcitask{1})
            set(handles.bcitask2,'string',handles.RegressSource.bcitask{2})
            set(handles.bcitask3,'string',handles.RegressSource.bcitask{3})
            
            set(handles.bcifreq1,'string',handles.RegressSource.bcifreq{1})
            set(handles.bcifreq2,'string',handles.RegressSource.bcifreq{2})
            set(handles.bcifreq3,'string',handles.RegressSource.bcifreq{3})
            
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Reset');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Reset');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Reset');

        else 
            
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Clear');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Clear');
            [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Clear');
            
        end

        
end