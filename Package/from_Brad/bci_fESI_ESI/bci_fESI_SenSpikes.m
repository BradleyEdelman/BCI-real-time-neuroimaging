function [hObject,handles]=bci_fESI_SenSpikes(hObject,handles)

if isfield(handles,'Electrodes') && isfield(handles.Electrodes,'eLoc')

    eLoc=handles.Electrodes.eLoc2;
    maxchan=size(eLoc,2);

    value=get(hObject,'String');
    % Find spaces in the entered text
    space=strfind(value,' ');
   
    for i=size(value,2):-1:1
        if ismember(i,space)
        % Is the text a real (not imaginary) number > 0
        elseif isnan(str2double(value(i))) || ~isreal(str2double(value(i)))
            value(i)=[];
            if ~exist('h','var')
                h=fprintf(2,'MUST BE A POSITIVE NUMERIC VALUE LESS THAN %s\n',num2str(maxchan));
            end
        end          
    end

    % Sort unique numbers in ascending order
    value=str2num(value);
    value=sort(value,'ascend');
    value=unique(value);
    % Remove channels numbers equal to 0 or greater than montage size
    value(value==0)=[];
    value(value>maxchan)=[];
    valuenum=value;
    valuenum=num2str(valuenum);

    % Removed double spaces remaining from previous removal
    space=strfind(valuenum,' ');
    spaceremove=zeros(1,size(space,2));
    for i=1:size(space,2)-1
        if space(i)==space(i+1)-1
            spaceremove(i)=space(i+1);
        end
    end
    spaceremove(spaceremove==0)=[];
    valuenum(spaceremove)=[];
    removed=valuenum;
    set(hObject,'String',removed)
    
end