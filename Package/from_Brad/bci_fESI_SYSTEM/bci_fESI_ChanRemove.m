function [hObject,handles]=bci_fESI_ChanRemove(hObject,handles)

set(handles.SelectSensorRegions,'backgroundColor','red','UserData',[]);

% Identify number of electrodes in montage
eLoc=handles.Electrodes.eLoc;
MaxChan=size(eLoc,2);

Value=get(hObject,'String');
% Find spaces in the entered text
Space=strfind(Value,' ');
   
for i=size(Value,2):-1:1          
    if ismember(i,Space)
    % Is the text a real (not imaginary) number > 0
    elseif isnan(str2double(Value(i))) || ~isreal(str2double(Value(i)))
        Value(i)=[];
        if ~exist('h','var')
            h=fprintf(2,'MUST BE A POSITIVE NUMERIC VALUE LESS THAN %s\n',...
                num2str(MaxChan));
        end
    end          
end

% Sort unique numbers in ascending order
Value=str2num(Value);
Value=sort(Value,'ascend');
Value=unique(Value);
% Remove channels numbers equal to 0 or greater than montage size
Value(Value==0)=[];
Value(Value>MaxChan)=[];
ValueNum=Value;
ValueNum=num2str(ValueNum);

% Removed double spaces remaining from previous removal
Space=strfind(ValueNum,' ');
SpaceRemove=zeros(1,size(Space,2));
for i=1:size(Space,2)-1
    if Space(i)==Space(i+1)-1
        SpaceRemove(i)=Space(i+1);
    end
end
SpaceRemove(SpaceRemove==0)=[];
ValueNum(SpaceRemove)=[];
Removed=ValueNum;
set(hObject,'String',Removed)

% Remove channels from plotting
Removed=str2num(Removed);
Removed=sort(unique(Removed),'ascend');
if ~isnan(Removed)
    eLoc(Removed)=[];
end

handles.Electrodes.eLoc2=eLoc;
handles.Electrodes.eLoc2plot.X=cell2mat({eLoc.X});
handles.Electrodes.eLoc2plot.Y=cell2mat({eLoc.Y});
handles.Electrodes.eLoc2plot.Z=cell2mat({eLoc.Z});
handles.Electrodes.RemovedChan=Removed;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UnusedChan=handles.Electrodes.UnusedChan;
if isempty(Removed)
else
	for i=1:size(Removed,2)
        Add=size(find(UnusedChan<Removed(i)),2);
        Removed(i)=Removed(i)+Add;
	end
end
ElecChanRemove=sort([UnusedChan Removed],'ascend');
handles.Electrodes.ElecChanRemove=ElecChanRemove;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Replot electrode montage with newly removed channels
axes(handles.axes3); cla
hold off; view(2); colorbar off
topoplot([],eLoc,'electrodes','ptlabels');
set(gcf,'color',[.94 .94 .94])
set(handles.Axis3Label,'String','Scalp Activity');
title('')

% Reset sensor control channels
Domain=get(handles.Domain,'Value');
if isequal(Domain,2)
    set(handles.LeftSensorCtrl,'String','Left')
    set(handles.LeftSensorCtrl,'BackgroundColor','red');
    set(handles.RightSensorCtrl,'String','Right')
    set(handles.RightSensorCtrl,'BackgroundColor','red');
end

