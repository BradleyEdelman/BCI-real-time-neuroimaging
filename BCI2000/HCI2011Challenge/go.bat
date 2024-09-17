
@set WD=%CD%

cd ..\prog

call portable.bat
:: this is necessary so that BCI2000 can find Python:  see the comments in portable.bat


start Operator --OnConnect "- SETCONFIG"
::--OnSetConfig "- SET STATE Running 1"
start PythonSource           "--PythonSrcWD=%WD%\python" --PythonSrcClassFile=NoisyInput.py
start PythonSignalProcessing "--PythonSigWD=%WD%\python"
start PythonApplication      "--PythonAppWD=%WD%\python"


:: If you chose to enter a C++ implementation instead of Python, you would comment out
:: the 'start PythonApplication' line above, copy your custom .exe file compiled from C++
:: into the HCI2011Challenge directory, and then do something like:

::  cd %WD%
::  start MyCustomApplication
