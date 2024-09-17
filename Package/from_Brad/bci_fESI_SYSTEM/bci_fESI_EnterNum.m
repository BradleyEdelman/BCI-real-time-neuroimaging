function [hObject,handles]=bci_fESI_EnterNum(hObject,handles,cfg)

if ~isfield(cfg,'varname') || isempty(cfg.varname)
    error('Variable name required');
else
    VarName=cfg.varname;
end

if ~isfield(cfg,'defaultnum')
    DefaultNum=0;
else
    DefaultNum=cfg.defaultnum;
end

if ~isfield(cfg,'highbound')
    HighBound=inf;
else
    HighBound=cfg.highbound;
end

if ~isfield(cfg,'lowbound')
    LowBound=-inf;
else
    LowBound=cfg.lowbound;
end

if ~isfield(cfg,'length')
    length=2;
else
    length=cfg.length;
end

if ~isfield(cfg,'numbers')
    numbers=1;
else
    numbers=cfg.numbers;
end

if numbers>1
    value=sort(unique(str2num(get(hObject,'string'))));
else
	value=str2double(get(hObject,'string'));
end

if isempty(value)
    set(hObject,'backgroundcolor','white')
else
    set(hObject,'backgroundcolor','green')
    % Entered text must be a real and positive number
    Newvalue=[];
    for i=1:size(value,2)

        valueidx=value(i);

        if isnan(valueidx) || ~isreal(valueidx) || valueidx<LowBound || valueidx>HighBound
        elseif size(num2str(valueidx),2)<length
            tmp=valueidx;
            for j=1:length-size(num2str(tmp),2)
                tmp=strcat('0',num2str(tmp));
            end
            if isempty(Newvalue)
                Newvalue=tmp;
            else
                Newvalue=[Newvalue ' ' tmp];
            end
        else
            if isempty(Newvalue)
                Newvalue=num2str(valueidx);
            else
                Newvalue=[Newvalue ' ' num2str(valueidx)];
            end
        end

    end

    if isempty(Newvalue)
        set(hObject,'backgroundcolor','red','string',num2str(DefaultNum));
        fprintf(2,'MUST ENTER NUMERIC VALUE(S) BETWEEN %.2f AND %.2f FOR %s\n',LowBound,HighBound,VarName);
    else
        set(hObject,'string',Newvalue)
    end
end





