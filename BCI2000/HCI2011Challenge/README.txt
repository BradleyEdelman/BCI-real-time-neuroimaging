             ============================================================
             Welcome to the Brain-Computer Interfacing HCI 2011 Challenge
             ============================================================


The provisional description of the challenge can be found in  HCI-BCI-Challenge2011.pdf

Final details of deadlines, prizes, and submission rules can be found at:

                        http://bcimeeting.org/HCI2011Challenge


STRUCTURE OF THIS DOWNLOAD
==========================

This README file should be inside a directory called HCI2011Challenge. To create your
competition entry, you should only modify files inside this area.

The HCI2011Challenge directory, in turn, is inside a directory called BCI2000: this contains
a very minimal demo distribution of the BCI2000 software platform <http://bci2000.org>
designed to demonstrate how BCI2000 interfaces with the Python programming language.

Next to the BCI2000 directory, there should be a directory called FullMonty254-20110710
This contains a complete, portable distribtion of Python 2.5.4, pre-loaded and configured
with various third-party packages, including numpy, scipy, IPython, pygame, VisionEgg and
BCPy2000, as described here:  http://bci2000.org/downloads/BCPy2000/Full_Monty.html

If all these things are in place, you should be able to run the challenge framework by
launching BCI2000/HCI2011Challenge/go.bat


SYSTEM REQUIREMENTS 
===================

The demo is designed to run on a 32-bit Windows system. Competition entries will be
judged using a 32-bit Windows XP SP3 system running on a dual core 2.2 GHz Intel processor.

Unfortunately you will probably find that BCPy2000 graphical presentation performance is
EXTREMELY slow and processor-hungry on a Virtual Machine:  therefore, we strongly suggest
running this in a native Windows environment.


GETTING STARTED
===============

In development, you simulate the user's intent to make a selection by moving the mouse.
Mouse movement is translated by our framework, after a variable delay, into a positive
signal deflection embedded in noise,  to simulate an event-related potential or other
burst of EEG activity). Your goal is to build a spelling interface that can spell English
text as efficiently as possible using this control signal. (Note, though, that speed is
not the only criterion on which entries will be judged: see the pdf and website for details).

You can start developing your competition entry by editing the files in the
BCI2000/HCI2011Challenge/python directory. From one of the IPython terminal windows that open
when you launch go.bat, you could type edit BciApplication.py for example.  The existing
BciApplication.py contains example stimuli which do not form a meaningful interface, but which
illustrate how the elements of an interface may be created.

You may wish to re-implement the signal-processing module (BciSignalProcessing.py) as well as
the application (BciApplication.py). The signal source module, NoisyInput.py, provides a
preview of the input that will be used to assess your entry, but this code will not be under
your control when your entry is assessed, so there is nothing to be gained by changing this
file.

You can also develop your signal-processing and application modules using C++ instead of Python:
go to http://doc.bci2000.org/ and browse the "Programming Reference" section to learn how to
build BCI2000 modules. Note that, unless you are already experienced in BCI2000 development, the
learning-curve for doing this in C++ will be considerably steeper, and development time much
longer, than for Python. Note also that there are additional requirements for submitting C++
entries, as described on the challenge website.
