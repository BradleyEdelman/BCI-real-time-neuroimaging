function [hObject,handles]=bci_fESI_Reset(hObject,handles,Fields,Axes)

% RESET STAGES IN PREPARATION
if ~strcmp(Fields,'None')
    if strcmp(Fields,'System')
        Fields={'SetSystem' 'CheckESI' 'SetESI' 'CheckBCI' 'SetBCI' 'StartBCI' 'StartTrain' 'Stop' 'Regression'};
        
        % Also, remove options from BCI setup
        [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,1,'Clear');
        [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,2,'Clear');
        [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,3,'Clear');
        
    elseif strcmp(Fields,'ESI')
        Fields={'CheckESI' 'SetESI' 'CheckBCI' 'SetBCI' 'StartBCI' 'StartTrain' 'Stop' 'Regression'};
    elseif strcmp(Fields,'BCI')
        Fields={'CheckBCI' 'SetBCI' 'StartBCI' 'StartTrain' 'Stop'};
    end

    for i=1:size(Fields,2)
        set(handles.(Fields{i}),'BackgroundColor',[.94 .94 .94],'UserData',0);
    end
end


% CLEAR AXES
if ~strcmp(Axes,'None')
    if isempty(Axes)
        Axes=1:3;
    end

    for i=1:size(Axes,2)
        if isequal(Axes(i),1)
            axes(handles.axes1); axis off; colorbar off; cla; rotate3d off;
            set(handles.Axis1Label,'String','')
        elseif isequal(Axes(i),2)
            axes(handles.axes2); axis off; colorbar off; cla; rotate3d off;
            set(handles.Axis2Label,'String','')
        elseif isequal(Axes(i),3)
            axes(handles.axes3); axis off; colorbar off; cla; rotate3d off;
            set(handles.Axis3Label,'String','')
        end
    end
end