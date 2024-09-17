cd ..\prog

call portable.bat
:: this is necessary so that BCI2000 can find Python:  see the comments in portable.bat

start Operator               --OnConnect "-LOAD PARAMETERFILE ..\parms\2DCal.prm; LOAD PARAMETERFILE ..\parms\Fragment_MouseInput.prm"
::start PythonSource           --PythonSrcClassFile=TrefoilSource.py
start SignalGenerator		--RandomSeed=10
::start PythonSignalProcessing --PythonSigClassFile=
start ARSignalProcessing
::start PythonApplication      --PythonAppClassFile=BCIApplication_ContinuousPursuit.py
start CursorTask
