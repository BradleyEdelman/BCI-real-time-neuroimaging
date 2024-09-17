function [hObject,handles]=bci_fESI_Initials(hObject,handles)

value=get(hObject,'string');
set(hObject,'backgroundcolor','green')
length=size(value,2);
if length>3 || length<2
    set(hObject,'string','')
    fprintf(2,'INITIALS MUST BE 2-3 CHRACTERS LONG\n');
    set(hObject,'backgroundcolor','red')
elseif isequal(length,2)
    for i=1:2
        if ~isnan(str2double(value(i)))
            set(hObject,'string','')
            fprintf(2,'FIRST TWO CHARACTERS MUST BE ALPHABETICAL\n');
            set(hObject,'backgroundcolor','red')
        end
    end
elseif isequal(length,3)
    for i=1:2
        if ~isnan(str2double(value(i)))
            set(hObject,'string','')
            fprintf(2,'FIRST TWO CHARACTERS MUST BE ALPHABETICAL\n');
            set(hObject,'backgroundcolor','red')
        end
    end
    
    if isnan(str2double(value(3)))
        set(hObject,'string',value(1:2))
        fprintf(2,'THIRD CHARACTERS MUST BE NUMERIC\n');
        set(hObject,'backgroundcolor','red')
    end
end