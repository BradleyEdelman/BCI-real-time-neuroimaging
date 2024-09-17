function [hObject,handles]=bci_fESI_BCISelect(hObject,handles,ParamType,Dimension)

% ParamType='BCITask';
% Dimension=1;
set(hObject,'backgroundcolor',[.94 .94 .94])
if strcmp(ParamType,'dim') || strcmp(ParamType,'task') ||...
        strcmp(ParamType,'freq')
    
    ParamType=strcat('bci',ParamType);

    TotDim=1:3;
    TotDim(Dimension)=[];

    values=zeros(1,2);
    for i=1:size(TotDim,2)
        Object=strcat(ParamType,num2str(TotDim(i)));
        values(i)=get(handles.(Object),'value');
    end
    
    currentvalue=get(hObject,'value');
    if ismember(currentvalue,values)
        set(hObject,'value',1)
        fprintf(2,'CANT DO THAT\n');
    end
    
else
    fprintf(2,'NOPE\n')
end
    





