function [hObject,handles,OK]=bci_fESI_CheckInfo(hObject,handles,Field1,Field2)

OK=1;

if isfield(handles.(Field1),'initials') && isfield(handles.(Field2),'initials')
    Initials1=handles.(Field1).initials;
    Initials2=handles.(Field2).initials;
    if ~strcmp(Initials1,Initials2)
        fprintf(2,'\nINCONSISTENT "INTIALS" BETWEEN %s AND %s\n',Field1,Field2);
        set(handles.Initials,'BackgroundColor','red');
        OK=0;
        % Prevent starting bci and all that jive
    end
else
    fprintf(2,'\n "INITIALS" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'session') && isfield(handles.(Field2),'session')
    Session1=handles.(Field1).session;
    Session2=handles.(Field2).session;
    if ~strcmp(Session1,Session2)
        fprintf(2,'\nINCONSISTENT "SESSION" BETWEEN %s AND %s\n',Field1,Field2);
        set(handles.Session,'BackgroundColor','red');
        OK=0;
    end
else
    fprintf(2,'\n "SESSION" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


% if isfield(handles.(Field1),'run') && isfield(handles.(Field2),'run')
%     Run1=handles.(Field1).run;
%     Run2=handles.(Field2).run;
%     if ~strcmp(Run1,Run2)
%         fprintf(2,'\nINCONSISTENT "RUN" BETWEEN %s AND %s\n',Field1,Field2);
%         set(handles.Run,'BackgroundColor','red');
%         OK=0;
%     end
% else
%     fprintf(2,'\n "RUN" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
% end


if isfield(handles.(Field1),'year') && isfield(handles.(Field2),'year')
    Year1=handles.(Field1).year;
    Year2=handles.(Field2).year;
    if ~strcmp(Year1,Year2)
        fprintf(2,'\nINCONSISTENT "YEAR" BETWEEN %s AND %s\n',Field1,Field2);
        set(handles.Year,'BackgroundColor','red');
        OK=0;
    end
else
    fprintf(2,'\n "YEAR" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'month') && isfield(handles.(Field2),'month')
    Month1=handles.(Field1).month;
    Month2=handles.(Field2).month;
    if ~strcmp(Month1,Month2)
        fprintf(2,'\nINCONSISTENT "MONTH" BETWEEN %s AND %s\n',Field1,Field2);
        set(handles.Month,'BackgroundColor','red');
        OK=0;
    end
else
    fprintf(2,'\n "MONTH" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'day') && isfield(handles.(Field2),'day')
    Day1=handles.(Field1).day;
    Day2=handles.(Field2).day;
    if ~strcmp(Day1,Day2)
        fprintf(2,'\nINCONSISTENT "DAY" BETWEEN %s AND %s\n',Field1,Field2);
        set(handles.Day,'BackgroundColor','red');
        OK=0;
    end
else
    fprintf(2,'\n "DAY" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'savepath') && isfield(handles.(Field2),'savepath')
    Savepath1=handles.(Field1).savepath;
    Savepath2=handles.(Field2).savepath;
    if ~strcmp(Savepath1,Savepath2)
        fprintf(2,'\nINCONSISTENT "SAVEPATH" BETWEEN %s AND %s\n',Field1,Field2);
        set(handles.Savepath,'BackgroundColor','red');
        OK=0;
    end
else
    fprintf(2,'\n "SAVEPATH" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'subdir') && isfield(handles.(Field2),'subdir')
    SubDir1=handles.(Field1).subdir;
    SubDir2=handles.(Field2).subdir;
    if ~strcmp(SubDir1,SubDir2)
        fprintf(2,'\nINCONSISTENT "SUBJECT DIR" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "SUBJECT DIR" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end

if isfield(handles.(Field1),'sessiondir') && isfield(handles.(Field2),'sessiondir')
    SessionDir1=handles.(Field1).sessiondir;
    SessionDir2=handles.(Field2).sessiondir;
    if ~strcmp(SessionDir1,SessionDir2)
        fprintf(2,'\nINCONSISTENT "SESSION DIR" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "SESSION DIR" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end

if isfield(handles.(Field1),'savefiledir') && isfield(handles.(Field2),'savefiledir')
    SaveFileDir1=handles.(Field1).savefiledir;
    SaveFileDir2=handles.(Field2).savefiledir;
    if ~strcmp(SaveFileDir1,SaveFileDir2)
        fprintf(2,'\nINCONSISTENT "SAVE FILE DIR" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "SAVE FILE DIR" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'eegsystem') && isfield(handles.(Field2),'eegsystem')
    EEGsystem1=handles.(Field1).eegsystem;
    EEGsystem2=handles.(Field2).eegsystem;
    if ~isequal(EEGsystem1,EEGsystem2)
        fprintf(2,'\nINCONSISTENT "EEG SYSTEM" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "EEG SYSTEM" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'psd') && isfield(handles.(Field2),'psd')
    PSD1=handles.(Field1).psd;
    PSD2=handles.(Field2).psd;
    if ~isequal(PSD1,PSD2)
        fprintf(2,'\nINCONSISTENT "FREQUENCY TRANSFORM" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "FREQUENCY TRANSFORM" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'lowcutoff') && isfield(handles.(Field2),'lowcutoff')
    LowCutoff1=handles.(Field1).lowcutoff;
    LowCutoff2=handles.(Field2).lowcutoff;
    if ~isequal(LowCutoff1,LowCutoff2)
        fprintf(2,'\nINCONSISTENT "LOW FREQUENCY BOUND" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "LOW FREQUENCY BOUND" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'highcutoff') && isfield(handles.(Field2),'highcutoff')
    HighCutoff1=handles.(Field1).highcutoff;
    HighCutoff2=handles.(Field2).highcutoff;
    if ~isequal(HighCutoff1,HighCutoff2)
        fprintf(2,'\nINCONSISTENT "HIGH FREQUENCY BOUND" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "HIGH FREQUENCY BOUND" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end


if isfield(handles.(Field1),'chanremove') && isfield(handles.(Field2),'chanremove')
    ChanRemove1=handles.(Field1).chanremove;
    ChanRemove2=handles.(Field2).chanremove;
    if ~isequal(ChanRemove1,ChanRemove2)
        fprintf(2,'\nINCONSISTENT "CHANNELS REMOVED" BETWEEN %s AND %s\n',Field1,Field2);
        OK=0;
    end
else
    fprintf(2,'\n "CHANNELS REMOVED" NOT DEFINED FOR EITHER %s OR %s\n',Field1,Field2);
end




