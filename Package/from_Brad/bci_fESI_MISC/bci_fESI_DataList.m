function [hObject,handles]=bci_fESI_DataList(hObject,handles,Action,DataList1,DataList2)

switch Action
    case 'Add'
        
        oldlist=cellstr(get(handles.(DataList1),'String'));
        oldlist=oldlist';
        [filename,pathname]=uigetfile('MultiSelect','on',{'*.Dat*'});
        if ~isequal(filename,0) && ~isequal(pathname,0)
            newfiles=strcat(pathname,filename);
            newlist=horzcat(oldlist,newfiles)';
            set(handles.(DataList1),'String',newlist,'Value',size(newlist,1))
        else
            set(handles.(DataList1),'String',oldlist);
        end
        
    case 'Remove'
        
        oldlist=get(handles.(DataList1),'String');
        listind=1:size(oldlist,1);
        remove=get(handles.(DataList1),'value');
        if ~isequal(remove,0)
            listind(remove)=[];
            for i=1:size(listind,2)
                newlist{i}=oldlist{listind(i)};
            end
            if ~exist('newlist','var')
                newlist=cell(0);
            end
            set(handles.(DataList1),'Value',size(newlist,2),'String',newlist)
        end
        
    case 'Clear'
        
        set(handles.(DataList1),'String',cell(0));
        
    case 'Copy'
        
        if ~isempty(DataList2) && ~isempty(get(handles.(DataList2),'String'))
            set(handles.(DataList1),'String',get(handles.(DataList2),'String'));
        end

end
        
        
        
        
        
        
        
        
        