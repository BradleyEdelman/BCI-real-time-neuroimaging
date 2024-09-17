function [hObject,handles]=bci_fESI_Noise(hObject,handles)

domain=get(handles.domain,'value');
switch domain
    case 1 % None
    case 2 % Sensor
    case 3 % ESI
        set(handles.CheckBCI,'backgroundcolor',[.94 .94 .94],'userdata',0);
        set(handles.SetBCI,'backgroundcolor',[.94 .94 .94],'userdata',0);
        set(handles.CheckESI,'backgroundcolor',[.94 .94 .94],'userdata',0);
        set(handles.SetESI,'backgroundcolor',[.94 .94 .94],'userdata',0);
        set(handles.StartBCI,'backgroundcolor',[.94 .94 .94],'value',0)
        set(handles.StartTrain,'backgroundcolor',[.94 .94 .94],'value',0)
        set(handles.Stop,'backgroundcolor',[.94 .94 .94])
        axes(handles.axes1); axis off; cla; set(handles.Axis1Label,'string','');
        axes(handles.axes2); axis off; cla; set(handles.Axis2Label,'string','');
        
        noise=get(hObject,'value');
        switch noise
            case 1 % None
                set(hObject,'backgroundcolor','red')
                set(handles.noisefile,'backgroundcolor','white')
            case 2 % None or no noise estimation
                set(hObject,'backgroundcolor','white')
                set(handles.noisefile,'backgroundcolor','white')
            case {3,4} % Diagonal or full noise covariance
                noisefile=get(handles.noisefile,'string');
                set(hObject,'backgroundcolor','white')
                if isempty(noisefile)
                    set(handles.noisefile,'backgroundcolor',[1 .7 0])
                else
                    set(handles.noisefile,'backgroundcolor','white')
                end
        end
end