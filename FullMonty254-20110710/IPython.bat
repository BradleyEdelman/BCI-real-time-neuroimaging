@set PYTHONHOME="%1"
@set SELF=%0
@if %SELF:~0,1%%SELF:~-1,1% == "" set SELF=%SELF:~1,-1%
@if "%1"=="" set PYTHONHOME=%SELF%\..\App

@set HERE=%CD%
@cd  %PYTHONHOME%
@if "%PYTHONHOME:~1,1%" == ":" %PYTHONHOME:~0,2%
@set PYTHONHOME=%CD%
@cd  %HERE%
@%HERE:~0,2%

@set PATH=%PYTHONHOME%;%PATH%
@title IPython
@python -c "import pkg_resources; pkg_resources.run_script('ipython', 'ipython')"

