function [hObject,handles]=bci_fESI_LoadParam(hObject,handles)

[filename,pathname]=uigetfile('M:\_bci_fESI\Param_Files\fESI\');
if ~isequal(filename,0) && ~isequal(pathname,0) &&...
        ~isempty(findstr('ESI',filename)) || ~isempty(findstr('Param',filename))

    ParamFile=strcat(pathname,filename);
    load(ParamFile);

    if isfield(Parameters,'savepath') && ~strcmp(Parameters.savepath,'')
        set(handles.Savepath,'String',Parameters.savepath)
    end

    if isfield(Parameters,'tasktypeval') && ~strcmp(Parameters.tasktypeval,'')
        set(handles.TaskType,'Value',Parameters.tasktypeval)
    end

    if isfield(Parameters,'chanremove') && ~isempty(Parameters.chanremove)
        set(handles.ChanRemove,'String',num2str(Parameters.chanremove))
    end

    if isfield(Parameters,'domainval') && ~strcmp(Parameters.domainval,'')
        set(handles.Domain,'Value',Parameters.domainval)
    end

    if isfield(Parameters,'eegsystemval') && ~strcmp(Parameters.eegsystemval,'')
        set(handles.EEGsystem,'Value',Parameters.eegsystemval)
    end

    EEGsystem=Parameters.eegsystemval;
    switch EEGsystem
        case 1 % None
            set(handles.fs,'String','')
            set(hObject,'BackgroundColor','red');
        case 2 % Neuroscan 64
            set(handles.fs,'String',num2str(1000))
            UnusedChan=[33 43 60 64 65:68]; % M1-2,CB1-2,VEO,HEO,EKG,EMG 
            UnusedChan=sort(UnusedChan,'ascend');
        case 3 % neuroscan 128
            set(handles.fs,'String',num2str(1000))
            UnusedChan=[10 11 84 85 110 111 129:132];
            UnusedChan=sort(UnusedChan,'ascend');
        case 4 % BioSemi 64
            set(handles.fs,'String',num2str(1024))
            UnusedChan=[];
            UnusedChan=sort(UnusedChan,'ascend');
        case 5 % BioSemi 128
            set(handles.fs,'String',num2str(1024))
            UnusedChan=[];
            UnusedChan=sort(UnusedChan,'ascend');
        case 6 % Signal Generator
            set(handles.fs,'String',num2str(256));
            UnusedChan=[];
            UnusedChan=sort(UnusedChan,'ascend');
    end

    handles.Electrodes.eLoc=Parameters.eloc;
    handles.Electrodes.NumChanOrig=Parameters.numchanorig;
    handles.Electrodes.eLoc2=Parameters.eloc2;
    handles.Electrodes.eLoc2plot.X=cell2mat({Parameters.eloc2.X});
    handles.Electrodes.eLoc2plot.Y=cell2mat({Parameters.eloc2.Y});
    handles.Electrodes.eLoc2plot.Z=cell2mat({Parameters.eloc2.Z});
    handles.Electrodes.UnusedChan=UnusedChan;
    handles.Electrodes.RemovedChan=Parameters.chanremove;
    handles.Electrodes.ElecChanRemove=sort(Parameters.chanremove,'ascend');

    % Plot electrode montage
    axes(handles.axes3); cla
    hold off; view(2); colorbar off
    topoplot([],Parameters.eloc2,'electrodes','ptlabels');
    set(gcf,'color',[.94 .94 .94])
    set(handles.Axis3Label,'String','Electrode Montage');
    title('')

    if isfield(Parameters,'psdval') && ~strcmp(Parameters.psdval,'')
        set(handles.PSD,'Value',Parameters.psdval)
    end

    set(handles.AnalysisWindow,'BackgroundColor','white');
    if isfield(Parameters,'analysiswindow') && ~strcmp(Parameters.analysiswindow,'')
        set(handles.AnalysisWindow,'String',Parameters.analysiswindow)
    end

    set(handles.LowCutoff,'BackgroundColor','white');
    if isfield(Parameters,'lowcutoff') && ~strcmp(Parameters.lowcutoff,'')
        set(handles.LowCutoff,'String',Parameters.lowcutoff)
    end

    set(handles.HighCutoff,'BackgroundColor','white');
    if isfield(Parameters,'highcutoff') && ~strcmp(Parameters.highcutoff,'')
        set(handles.HighCutoff,'String',Parameters.highcutoff)
    end
    
    if isfield(Parameters,'gainLR')
        if isnumeric(Parameters.gainLR)
            set(handles.GainLR,'String',num2str(Parameters.gainLR));
        elseif ~strcmp(Parameters.gainLR,'')
            set(handles.GainLR,'String',Parameters.gainLR)
        end
    end
    
    if isfield(Parameters,'offsetLR')
        if isnumeric(Parameters.offsetLR)
            set(handles.OffsetLR,'String',num2str(Parameters.offsetLR));
        elseif ~strcmp(Parameters.offsetLR,'')
            set(handles.OffsetLR,'String',Parameters.OffsetLR)
        end
    end
    
    if isfield(Parameters,'scaleLR')
        if isnumeric(Parameters.scaleLR)
            set(handles.GainLR,'String',num2str(Parameters.scaleLR));
        elseif ~strcmp(Parameters.scaleLR,'')
            set(handles.ScaleLR,'String',Parameters.scaleLR)
        end
    end
    
    if isfield(Parameters,'gainUD')
        if isnumeric(Parameters.gainUD)
            set(handles.GainUD,'String',num2str(Parameters.gainUD));
        elseif ~strcmp(Parameters.gainUD,'')
            set(handles.GainUD,'String',Parameters.gainUD)
        end
    end
    
    if isfield(Parameters,'offsetUD')
        if isnumeric(Parameters.offsetUD)
            set(handles.OffsetUD,'String',num2str(Parameters.offsetUD));
        elseif ~strcmp(Parameters.offsetUD,'')
            set(handles.OffsetUD,'String',Parameters.OffsetUD)
        end
    end
    
    if isfield(Parameters,'scaleUD')
        if isnumeric(Parameters.scaleUD)
            set(handles.ScaleUD,'String',str2double(Parameters.scaleUD));
        elseif ~strcmp(Parameters.scaleUD,'')
            set(handles.ScaleUD,'String',Parameters.scaleUD)
        end
    end
    
    if isfield(Parameters,'bufferlength') && ~strcmp(Parameters.bufferlength,'')
        set(handles.BufferLength,'String',Parameters.bufferlength)
    end

    set(handles.LeftSensorCtrl,'BackgroundColor','white');
    if isfield(Parameters,'leftsensorctrl') && ~strcmp(Parameters.leftsensorctrl,'')
        set(handles.LeftSensorCtrl,'String',Parameters.leftsensorctrl)
    end

    set(handles.RightSensorCtrl,'BackgroundColor','white');
    if isfield(Parameters,'rightsensorctrl') && ~strcmp(Parameters.rightsensorctrl,'')
        set(handles.RightSensorCtrl,'String',Parameters.rightsensorctrl)
    end
    
    if isfield(Parameters,'noiseval') && ~strcmp(Parameters.noiseval,'')
        set(handles.Noise,'Value',Parameters.noiseval)
    end
    
    if isfield(Parameters,'cortex') && ~strcmp(Parameters.cortex,'')
        set(handles.Cortex,'String',Parameters.cortex)
    end

    if isfield(Parameters,'cortexlr') && ~strcmp(Parameters.cortexlr,'')
        set(handles.CortexLR,'String',Parameters.cortexlr)
    end
    
    if isfield(Parameters,'vizsource') && ~strcmp(Parameters.vizsource,'')
        set(handles.VizSource,'Value',Parameters.vizsource)
    end

    if isfield(Parameters,'lrvizsource') && ~strcmp(Parameters.lrvizsource,'')
        set(handles.LRVizSource,'Value',Parameters.lrvizsource)
    end

    if isfield(Parameters,'headmodel') && ~strcmp(Parameters.headmodel,'')
        set(handles.HeadModel,'String',Parameters.headmodel)
    end

    if isfield(Parameters,'rois') && ~strcmp(Parameters.rois,'')
        set(handles.ROI,'String',Parameters.rois)
    end

    if isfield(Parameters,'fmri') && ~strcmp(Parameters.fmri,'')
        set(handles.fMRI,'String',Parameters.fmri)
    end

    set(handles.Initials,'String','');
    set(handles.Initials,'BackgroundColor','red');
    set(handles.Session,'String','');
    set(handles.Session,'BackgroundColor','red');
    set(handles.Run,'String','');
    set(handles.Run,'BackgroundColor','red');
    set(handles.Year,'String','');
    set(handles.Year,'BackgroundColor','red');
    set(handles.Month,'String','');
    set(handles.Month,'BackgroundColor','red');
    set(handles.Day,'String','');
    set(handles.Day,'BackgroundColor','red');
else
    fprintf(2,'MUST SELECT A PARAM.mat FILE\n');
end