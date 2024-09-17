function [hObject,handles]=bci_fESI_SetBCI(hObject,handles)

CheckBCI=get(handles.CheckBCI,'UserData');
set(hObject,'BackgroundColor','green','UserData',1);

if isequal(sum(CheckBCI),0)
    fprintf(2,'BCI PARAMETERS HAVE NOT BEEN CHECKED\n');
    set(hObject,'BackgroundColor','red','UserData',0);
else
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TIMING PARAMETERS
    fsExtract=str2double(get(handles.fs,'String'));
    dsfactor=str2double(get(handles.dsfactor,'String'));
    fsProcess=fsExtract/dsfactor;
    
    analysiswindow=str2double(get(handles.analysiswindow,'String'));
    analysiswindowextract=round(analysiswindow/1000*fsExtract);
    analysiswindowprocess=round(analysiswindowextract/dsfactor);
    
    updatewindow=str2double(get(handles.updatewindow,'String'));
    updatewindowextract=round(updatewindow/1000*fsExtract);
    
    handles.BCI.fsextract=fsExtract;
    handles.BCI.fsprocess=fsProcess;
    handles.BCI.dsfactor=dsfactor;
    handles.BCI.analysiswindowextract=analysiswindowextract;
    handles.BCI.analysiswindowprocess=analysiswindowprocess;
    handles.BCI.updatewindowextract=updatewindowextract;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % WEIGHTING PARAMETERS
    LocUserData=CheckBCI;
    
    bciidx=cell(1,3);
    bciweight=cell(1,3);
    bcifreqidx=cell(1,3);
    normidx=zeros(1,3);
%     for i=1:size(CurrentDim,1)
    for i=1:size(LocUserData,1)
        if LocUserData(i)~=0
        
            dimvar=strcat('bcidim',num2str(i));
            dim=get(handles.(dimvar),'String');
            dimval=dim{get(handles.(dimvar),'Value')};

            freqvar=strcat('bcifreq',num2str(i));
            freqval=get(handles.(freqvar),'Value')-1;

            locvar=strcat('bciloc',num2str(i));
            locval=get(handles.(locvar),'UserData');
            locval=locval(1:end-1,:);
            locidx=locval(:,1);
            locweight=locval(:,2);

            if strcmp(dimval,'Horizontal')
                bciidx{1}=locidx;
                bciweight{1}=locweight;
                bcifreqidx{1}=freqval;
                normidx(1)=i;
            elseif strcmp(dimval,'Vertical')
                bciidx{2}=locidx;
                bciweight{2}=locweight;
                bcifreqidx{2}=freqval;
                normidx(2)=i;
            elseif strcmp(dimval,'Depth')
                bciidx{3}=locidx;
                bciweight{3}=locweight;
                bcifreqidx{3}=freqval;
                normidx(3)=i;
            end
        end
    end
    handles.BCI.control.idx=bciidx;
    handles.BCI.control.w=bciweight;
    handles.BCI.control.freqidx=bcifreqidx;
    handles.BCI.normidx=normidx;
    
    % Detect task type
    if ~isempty(bciidx{1}) && ~isempty(bciidx{2}) && ~isempty(bciidx{3})
        task='3D';
        targetID{1}=[1 2];
        targetID{2}=[3 4];
        targetID{3}=[5 6];
    elseif ~isempty(bciidx{1}) && ~isempty(bciidx{2}) && isempty(bciidx{3})
        task='2D';
        targetID{1}=[1 2];
        targetID{2}=[3 4];
        targetID{3}=[];
    elseif ~isempty(bciidx{1}) && isempty(bciidx{2}) && isempty(bciidx{3})
        task='1D Horizontal';
        targetID{1}=[1 2];
        targetID{2}=[];
        targetID{3}=[];
    elseif isempty(bciidx{1}) && ~isempty(bciidx{2}) && isempty(bciidx{3})
        task='1D Vertical';
        targetID{1}=[];
        targetID{2}=[1 2];
        targetID{3}=[];
    else
        fprintf(2,'NO DIMENSIONS SELECTED\n');
    end
    handles.BCI.targetid=targetID;
    handles.BCI.task=task;
    fprintf(2,'     BCI SET UP FOR "%s" TASK\n',task);
    
    ChanIdxInclude=handles.SYSTEM.Electrodes.chanidxinclude;
    handles.BCI.chanidxinclude=ChanIdxInclude;
    
end












