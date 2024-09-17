function [hObject,handles]=bci_fESI_ResetBCI(hObject,handles,Dimension,Method)

bcidim=strcat('bcidim',num2str(Dimension));
bcitask=strcat('bcitask',num2str(Dimension));
bcifreq=strcat('bcifreq',num2str(Dimension));
bciloc=strcat('bciloc',num2str(Dimension));

if strcmp(Method,'Reset')
    
    set(handles.(bcidim),'backgroundcolor','white','value',1)
    set(handles.(bcitask),'backgroundcolor',[.94 .94 .94],'value',1)
    set(handles.(bcifreq),'backgroundcolor',[.94 .94 .94],'value',1)
    set(handles.(bciloc),'backgroundcolor',[.94 .94 .94],'Userdata',[]);
    
elseif strcmp(Method,'Clear')
    
    set(handles.(bcidim),'backgroundcolor','white','value',1)
    set(handles.(bcitask),'backgroundcolor',[.94 .94 .94],'string',' ','value',1)
    set(handles.(bcifreq),'backgroundcolor',[.94 .94 .94],'string',' ','value',1)
    set(handles.(bciloc),'backgroundcolor',[.94 .94 .94],'Userdata',[]);
    
end

gain=strcat('gain',num2str(Dimension));
offset=strcat('offset',num2str(Dimension));
scale=strcat('scale',num2str(Dimension));
set(handles.(gain),'backgroundcolor',[.94 .94 .94],'string','0.01')
set(handles.(offset),'backgroundcolor',[.94 .94 .94],'string','0')
set(handles.(scale),'backgroundcolor',[.94 .94 .94],'string','1');