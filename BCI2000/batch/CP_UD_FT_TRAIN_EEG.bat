cd ..\prog

call portable.bat
:: this is necessary so that BCI2000 can find Python:  see the comments in portable.bat

start Operator               --OnConnect "-LOAD PARAMETERFILE ..\parms\_BRAD_CP\CP_UD_FT_TRAIN_EEG.prm;
start Biosemi2
start FieldTripBuffer
start PythonApplication      --PythonAppClassFile=BCIApplication_ContinuousPursuit2.py
