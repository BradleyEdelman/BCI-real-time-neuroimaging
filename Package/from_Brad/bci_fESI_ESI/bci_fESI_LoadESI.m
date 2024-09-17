function [hObject,handles]=bci_fESI_LoadESI(hObject,handles)

[filename,pathname]=uigetfile('M:\_bci_fESI\Param_Files\fESI\');
if ~isequal(filename,0) && ~isequal(pathname,0)
    
    if ~isempty(findstr('ESI',filename)) 
    
        ParamFile=strcat(pathname,filename);
        load(ParamFile);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LOAD SYSTEM PARAMETERS
        SYSTEM=SaveESI.SYSTEM;
        handles.SYSTEM=SYSTEM;
        if isfield(SYSTEM,'initials') && ~isempty(SYSTEM.initials)
            set(handles.Initials,'String',SYSTEM.initials)
        end
        
        if isfield(SYSTEM,'savepath') && ~isempty(SYSTEM.savepath)
            set(handles.Savepath,'String',SYSTEM.savepath)
        end

        if isfield(SYSTEM,'eegsystem') && isnumeric(SYSTEM.eegsystem)
            set(handles.EEGsystem,'Value',SYSTEM.eegsystem)
        end
        
        if isfield(SYSTEM,'eegsystem') && isnumeric(SYSTEM.eegsystem)
            set(handles.EEGsystem,'Value',SYSTEM.eegsystem)
        end
        
        if isfield(SYSTEM,'fs') && ~isempty(SYSTEM.fs)
            set(handles.fs,'String',SYSTEM.fs)
        end

        if isfield(SYSTEM,'Electrodes') && ~isempty(SYSTEM.Electrodes)
            handles.Electrodes=SYSTEM.Electrodes;
        end

        % Plot electrode montage
        axes(handles.axes3); cla
        hold off; view(2); colorbar off
        topoplot([],handles.Electrodes.original.eLoc,'electrodes','ptlabels');
        set(gcf,'color',[.94 .94 .94])
        set(handles.Axis3Label,'String','Electrode Montage');
        title('')
        
        if isfield(SYSTEM,'psd') && ~isempty(SYSTEM.psd)
            set(handles.PSD,'Value',SYSTEM.psd)
        end
        
        if isfield(SYSTEM,'lowcutoff') && ~isempty(SYSTEM.lowcutoff)
            set(handles.LowCutoff,'String',num2str(SYSTEM.lowcutoff))
        end
        
        if isfield(SYSTEM,'highcutoff') && ~isempty(SYSTEM.highcutoff)
            set(handles.HighCutoff,'String',num2str(SYSTEM.highcutoff))
        end
        
        if isfield(SYSTEM,'dsfactor') && ~isempty(SYSTEM.dsfactor)
            set(handles.DSFactor,'String',SYSTEM.dsfactor)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % LOAD ESI PARAMETERS
        ESI=SaveESI.ESI;
        handles.ESI=ESI;
        if isfield(ESI,'files')
            
            if isfield(ESI.files,'cortex') && ~isempty(ESI.files.cortex)
                set(handles.Cortex,'String',ESI.files.cortex);
            end
            
            if isfield(ESI.files,'cortexlr') && ~isempty(ESI.files.cortexlr)
                set(handles.CortexLR,'String',ESI.files.cortexlr);
            end
            
            if isfield(ESI.files,'headmodel') && ~isempty(ESI.files.headmodel)
                set(handles.HeadModel,'String',ESI.files.headmodel);
            end
            
            if isfield(ESI.files,'fmri') && ~isempty(ESI.files.fmri)
                set(handles.fMRI,'String',ESI.files.fmri);
            end
            
            if isfield(ESI.files,'brainregions') && ~isempty(ESI.files.brainregions)
                set(handles.BrainRegionFile,'String',ESI.files.brainregions);
            end
            
            if isfield(ESI.files,'parcellation') && ~isempty(ESI.files.parcellation)
                set(handles.ESIData,'String',ESI.files.parcellation);
            end
            
        end
        
        if isfield(ESI,'parcellation') && isnumeric(ESI.parcellation)
            set(handles.Parcellation,'Value',ESI.parcellation);
        end
        
        if isfield(ESI,'noisetype') && isnumeric(ESI.noisetype)
            set(handles.Noise,'Value',ESI.noisetype);
        end
    
    
    elseif ~isempty(findstr('Param',filename))
    
    
    end
    
    
end
