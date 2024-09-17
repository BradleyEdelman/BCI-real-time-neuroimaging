function [hObject,handles]=bci_fESI_CheckVar(hObject,handles)

trainfiles=cellstr(get(handles.trainfiles,'String'));
if ~isempty(trainfiles) && isequal(get(handles.SetSystem,'UserData'),1)
    
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
    [TrialStruct]=bci_fESI_ExtractBCI2000Parameters(trainfiles);
    [handles,TaskInfo,Data]=bci_fESI_TaskInfo(handles,trainfiles,TrialStruct);
    
    variance=zeros(1,size(Data,1));
    for i=1:size(Data,1)
        variance(i)=var(Data(i,:));
    end
    
    % Plot original electrode variances
    axes(handles.axes1); cla; axis off; colorbar off; rotate3d off; view(0,90)
    set(handles.Axis1Label,'String','Original Variance')
    variance1=(variance-min(variance))/(max(variance)-min(variance));
    topoplot(1./variance1,handles.SYSTEM.Electrodes.original.eLoc,...
        'electrodes','ptlabels','numcontour',0); %caxis([-.15 1.15]);
    set(gcf,'Color',[.94 .94 .94]);
    
    % Remove prespecified electrodes and replot
    variance(handles.SYSTEM.Electrodes.chanidxexclude)=[];
    axes(handles.axes2); cla; axis off; colorbar off; rotate3d off; view(0,90)
    set(handles.Axis2Label,'String','Current Variance')
    variance2=(variance-min(variance))/(max(variance)-min(variance));
    topoplot(1./variance2,handles.SYSTEM.Electrodes.current.eLoc,...
        'electrodes','ptlabels','numcontour',0); %caxis([-.15 1.15]);
    set(gcf,'Color',[.94 .94 .94]);
    
else
    fprintf(2,'MUST SET SYSTEM PARAMETERS TO VISUALIZE TRAINING DATA VARIANCE\n');
    [hObject,handles]=bci_fESI_Reset(hObject,handles,'None',[]);
end