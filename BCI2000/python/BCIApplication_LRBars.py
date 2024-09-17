#
# Heavily modified from the "TriangleApplication.py" example provided with BCPy2000
#
import numpy as np
from random import randint

from AppTools.Boxes import box
from AppTools.Displays import fullscreen
from AppTools.Shapes import PolygonTexture, Disc, Block
from AppTools.StateMonitors import addstatemonitor, addphasemonitor
from SigTools.Plotting import plot

#################################################################
#################################################################

class BciApplication(BciGenericApplication):

    #############################################################

    def Description(self):
        return "left/right bar task"

    #############################################################

    def Construct(self):
        # format = "Section Datatype Name= Value DefaultValue LowRange HighRange //comment"
        self.define_param(
            "PythonApp:Design   int    ShowFixation=        1     1     0   1  // show a fixation point in the center (boolean)",
            "PythonApp:Design matrix Tasks= 7 { Task%20Prompt Direction Online%20Feedback Relative%20Frequency } Move 1 0 1  Move 2 0 1 Imagine 1 0 2 Imagine 2 0 2 Imagine 1 1 2 Imagine 2 1 2 Rest 0 0 1 // Tasks. Directions: 0=none, 1=left, 2=right. Feedback: 0=none, 1=online.",
            "PythonApp:Screen   int    ScreenId=            -1      -1     %   %  // on which screen should the stimulus window be opened - use -1 for last",
            "PythonApp:Screen   float  WindowSize=          1.0     1.0     0.0     1.0 // size of the stimulus window, proportional to the screen",
            "PythonApp:Timing   int     ITI=                1000    1000    0       1e4 // inter-trial duration (ms)   ",
            "PythonApp:Timing   int     TaskCueDuration=    1000    1000    0       1e4 // task cue duration (ms)   ",
            "PythonApp:Timing   int     DirCueDuration=     1000    1000    0       1e4 // direction cue duration (ms)   ",
            "PythonApp:Timing   int     TaskDuration=       4000    4000    0       1e4 // task duration (ms)   ",
            "PythonApp:Stimuli  float   BarWidth=           0.1     0.1     0       1.0 //width of feedback bar (proportion of screen size)",
            "PythonApp:Stimuli  float   BarLengthMax=       0.4     0.4     0.0     0.5 //maximum length of feedback bar (proportion of screen size)",
            "PythonApp:Stimuli  float   BarLengthMultiplier= 5.0    1.0     0.0     %   //Multiply bar length by this factor",
            "PythonApp:Stimuli  float   BarCuePosition=     0.5     0.5     0.0     1.0 // Relative position of left/right cues on bars.",
            "PythonApp:Stimuli  int     CursorSize=         10      10      0       100 // diameter of cursor",
            "PythonApp:Stimuli  float   CursorMultiplier=   0.08    1.0     0.0     %   //Multiply cursor movement by this factor",
            "PythonApp:Stimuli  int     TargetSize=         40      40      0       200 // diameter of target",
            "PythonApp:Stimuli  int     ShowLateralCue=     0       0       0       1 // Show lateral cues (boolean)",
            "PythonApp:Feedback int     CursorFeedback=     0       0       0       1  // show online feedback cursor (boolean)",
            "PythonApp:Feedback int     ControlType=        0       0       0       3   //1=position-based, 2,3=undefined, 0=let program choose",
            "PythonApp:Feedback int     ControlDimension=   0       0       1       2   //0=LR, 1=UD, 2=LR+UD",
            "PythonApp:Feedback int     CursorSmoothLength= 16      8       1       %   //Number of frames of cursor position to average for smoothing movement. 1=no smoothing.",
            )
        self.define_state(
            "Cursor_PosX_u      16 0 0 0",
            "Cursor_PosY_u      16 0 0 0",
            "Bar_PosX_u         16 0 0 0",
            "Bar_PosY_u         16 0 0 0",
            "Target_PosX_u      16 0 0 0",
            "Target_PosY_u      16 0 0 0",
            "SignedOffset       16 32767 0 0",
            "FloatScalar        16 10000 0 0",
            "TaskCueOn          1 0 0 0",
            "DirectionCueOn     1 0 0 0",
            "TaskOn             1 0 0 0",
            "TaskType           8 0 0 0",
            "Feedback           1 0 0 0",   # bells? whistles?
        )

    #############################################################

    def Preflight(self, sigprops):

        if int(self.params['ControlDimension']==0):
            self.nclasses = 1
        else:
            self.nclasses = 2


        self.ndim = self.nclasses

        if not self.in_signal_dim[0] in (self.nclasses,):
            raise EndUserError,'%d-channel input expected' % (self.nclasses,)

        siz = float(self.params['WindowSize'])
        screenid = int(self.params['ScreenId'])  # ScreenId 0 is the first screen, 1 the second, -1 the last
        fullscreen(scale=siz, id=screenid, frameless_window=(siz==1))
        # only use a borderless window if the window is set to fill the whole screen

    #############################################################

    def exportFloat(self,stateKey,value):

        offset = self.states['SignedOffset']
        multiplier = self.states['FloatScalar']

        lowerLimit = 0
        upperLimit = 2**31 - 1

        intToExport = value*multiplier + offset

        if intToExport < lowerLimit:
            intToExport = lowerLimit
        elif intToExport > upperLimit:
            #intToExport = upperLimit
            while intToExport > upperLimit:
                intToExport /= 10.0

        self.states[stateKey] = int(intToExport)

    def exportStateVariables(self):
        offset = self.states['SignedOffset']
        multiplier = self.states['FloatScalar']

        self.states['Cursor_PosX_u'] = int(self.cursorState[0,0])
        self.states['Cursor_PosY_u'] = int(self.cursorState[0,1])

        self.states['Bar_PosX_u'] = int(self.barState[0,0])
        self.states['Bar_PosY_u'] = int(self.barState[0,1])

        self.states['Target_PosX_u'] = int(self.targetState[0,0])
        self.states['Target_PosY_u'] = int(self.targetState[0,1])

    def Initialize(self, indim, outdim):

        # compute how big everything should be
        scrw,scrh = self.screen.size
        scrsiz = min(scrw,scrh)

        self.screenSize = self.screen.size #TODO: change to have screenSize represent actual drawing space for cursor

        siz = (scrsiz*0.8, scrsiz*0.9)

        # use a handy AppTools.Boxes.box object as the coordinate frame
        #b = box(size=siz, position=(scrw/2.0,scrh/2.0 - siz[1]/6.0), sticky=True)
        b = box(size=self.screenSize,position=(self.screenSize[0]/2.0,self.screenSize[1]/2.0))
        #center = b.map((0.5,2.0/3.0), 'position')
        center = b.map((0.5,0.5), 'position')
        self.positions = {'origin': np.matrix(center)}

        self.cursorState = np.zeros((1,2)) # position in 2D
        self.cursorState[0,:] = np.squeeze(np.asarray(self.positions['origin'])) #start cursor in center of screen
        self.barState = np.zeros((1,2)) # position in 2D
        self.barState[0,:] = np.squeeze(np.asarray(self.positions['origin'])) #start bar in center of screen

        self.targetState = np.zeros((1,2)) # position in 2D
        self.targetState[0,:] = np.squeeze(np.asarray(self.positions['origin'])) #start target in center of screen

        self.exportStateVariables()

        # draw the arrow
        b.anchor='center'
        fac = (0.25,0.4)
        b.scale(fac)
        arrow = PolygonTexture(frame=b, vertices=((0.22,0.35),(0,0.35),(0.5,0),(1,0.35),(0.78,0.35),(0.78,0.75),(0.22,0.75),), color=(1,1,1), on=False, position=center)
        b.scale((1.0/fac[0],1.0/fac[1]))

        # let's have a black background
        self.screen.color = (0,0,0)

        b = box(size=self.screen.size, position=(scrw/2.0,scrh/2.0),sticky=True)
        # OK, now register all those stimuli, plus a few more, with the framework
        self.stimulus('cursor1',  z=4.3,   stim=Disc(position=center, radius=int(self.params['CursorSize']), color=(1,1,1), on=False))
        self.stimulus('cursor2',  z=4.4,   stim=Disc(position=center, radius=int(self.params['CursorSize'])*0.5,  color=(0,0,0), on=False))
        self.stimulus('bar1',     z=4.1, stim=Block(position=center,anchor='left',size=(0,float(self.params['BarWidth'])*scrw), color=(0,0,1), on=False))
        rct = (0.002*b.height/b.width,0.002) # relative container thickness
        print(rct)
        self.stimulus('barContainer_R', z=4.9,    stim=PolygonTexture(frame=b, vertices=(
            (0.5,0.5+float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5+float(self.params['BarLengthMax'])+rct[0],0.5+float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5+float(self.params['BarLengthMax'])+rct[0],0.5-float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5,0.5-float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5,0.5-float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5+float(self.params['BarLengthMax'])-rct[0],0.5-float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5+float(self.params['BarLengthMax'])-rct[0],0.5+float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5,0.5+float(self.params['BarWidth'])/2.0-rct[1]),
        ),color=(1,1,1)))
        self.stimulus('barContainer_L', z=4.9,    stim=PolygonTexture(frame=b, vertices=(
            (0.5,0.5+float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5-float(self.params['BarLengthMax'])-rct[0],0.5+float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5-float(self.params['BarLengthMax'])-rct[0],0.5-float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5,0.5-float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5,0.5-float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5-float(self.params['BarLengthMax'])+rct[0],0.5-float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5-float(self.params['BarLengthMax'])+rct[0],0.5+float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5,0.5+float(self.params['BarWidth'])/2.0-rct[1]),
        ),color=(1,1,1)))
        self.stimulus('barContainer_M', z=4.9,    stim=PolygonTexture(frame=b, vertices=(
            (0.5-10*rct[0]/2.0,0.5+float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5+10*rct[0]/2.0,0.5+float(self.params['BarWidth'])/2.0-rct[1]),
            (0.5+10*rct[0]/2.0,0.5-float(self.params['BarWidth'])/2.0+rct[1]),
            (0.5-10*rct[0]/2.0,0.5-float(self.params['BarWidth'])/2.0+rct[1]),
        ),color=(1,1,1)))
        self.stimulus('feedbackBlocker', z=4.5,    stim=PolygonTexture(frame=b, vertices=(
            (0.5-float(self.params['BarLengthMax']),0.5+float(self.params['BarWidth'])/2.0),
            (0.5-float(self.params['BarLengthMax']),0.5-float(self.params['BarWidth'])/2.0),
            (0.5+float(self.params['BarLengthMax']),0.5-float(self.params['BarWidth'])/2.0),
            (0.5+float(self.params['BarLengthMax']),0.5+float(self.params['BarWidth'])/2.0),
        ),color=(0.5,0.5,0.5)))
        self.stimulus('target',   z=2,   stim=Disc(position=center, radius=int(self.params['TargetSize']),color=(0.5,0.5,0.5), on=False))
        self.stimulus('arrow',    z=4.5, stim=arrow)
        self.stimulus('TaskCue',      z=5,   stim=VisualStimuli.Text(text='?', position=(center[0],int(center[1]+float(self.params['BarWidth'])*1.0*self.screen.size[1])), anchor='center', color=(1,1,1), font_size=int(0.1*self.screen.size[1]), on=False))
        self.stimulus('DirectionCue', z=5,   stim=VisualStimuli.Text(text='', position=(center[0],center[1]-200), anchor='center', color=(1,1,1), font_size=100, on=False))
        self.stimulus('fixation', z=4.2, stim=Disc(position=center, radius=5, color=(1,1,1), on=False))

        # arrows for left/right cues

        for leftOrRight in (0,1):
            for topOrBottom in (0,1):
                b = box(size=(30,70), position=(
                    self.screen.size[0]*(0.5 + (self.params['BarLengthMax'].val*self.params['BarCuePosition'].val)*(1.0 if leftOrRight==1 else -1.0)),
                    self.screen.size[1]*(0.5 + (self.params['BarWidth'].val/2.0+rct[1])*(1.0 if topOrBottom==1 else -1.0))),
                    anchor=('bottom' if topOrBottom==1 else 'top'),sticky=True)
                # print( self.screen.size[0]*(0.5 + (self.params['BarLengthMax'].val*self.params['BarCuePosition'].val)*(1.0 if leftOrRight==1 else -1.0)))
                # print( self.screen.size[1]*(0.5 + (self.params['BarWidth'].val/2.0+rct[1])*(1.0 if topOrBottom==1 else -1.0)))
                # print( "...")
                b.anchor = 'center'
                self.stimulus('LateralCue' + str(leftOrRight) + str(topOrBottom), z=2,
                              stim=PolygonTexture(frame=b,
                                        vertices=((0.3,0.35),(0,0.35),(0.5,0),(1,0.35),(0.7,0.35),(0.7,1.0),(0.3,1.0),),
                                        color=(0.5,0.5,0.5),
                                        angle=(0 if topOrBottom==1 else 180),
                                        on=False,
                                        ))

            b = box(size=(60,140), position=(
                self.screen.size[0]*0.5,
                self.screen.size[1]*(0.5 - (self.params['BarWidth'].val))),
                anchor=('center'),sticky=True)
            self.stimulus('BigCueArrow' + str(leftOrRight), z=2,
                stim=PolygonTexture(frame=b,
                        vertices=((0.3,0.35),(0,0.35),(0.5,0),(1,0.35),(0.7,0.35),(0.7,1.0),(0.3,1.0),),
                        color=(1, 1, 1),
                        angle=(90 if leftOrRight==1 else 270),
                        on=False,
                        ))

        # finally, some fancy stuff from AppTools.StateMonitors, for the developer to check
        # that everything's working OK
        if int(self.params['ShowSignalTime']):
            # turn on state monitors iff the packet clock is also turned on
            addstatemonitor(self, 'Running', showtime=True)
            addstatemonitor(self, 'CurrentBlock')
            addstatemonitor(self, 'CurrentTrial')
            addstatemonitor(self, 'TargetClass')
            addstatemonitor(self, 'Learn')

            addphasemonitor(self, 'phase', showtime=True)

            m = addstatemonitor(self, 'fs_reg')
            m.func = lambda x: '% 6.1fHz' % x._regfs.get('SamplesPerSecond', 0)
            m.pargs = (self,)
            m = addstatemonitor(self, 'fs_avg')
            m.func = lambda x: '% 6.1fHz' % x.estimated.get('SamplesPerSecond',{}).get('global', 0)
            m.pargs = (self,)
            m = addstatemonitor(self, 'fs_run')
            m.func = lambda x: '% 6.1fHz' % x.estimated.get('SamplesPerSecond',{}).get('running', 0)
            m.pargs = (self,)
            m = addstatemonitor(self, 'fr_run')
            m.func = lambda x: '% 6.1fHz' % x.estimated.get('FramesPerSecond',{}).get('running', 0)
            m.pargs = (self,)

        self.distance = lambda a,b: np.sqrt((np.asarray(a-b)**2).sum(axis=-1))
        #self.distance_scaling = (2.0 ** self.bits['DistanceFromCenter'] - 1.0) / self.distance(self.positions['green'], self.positions['red'])

        self.cursorSmoother = None

    #############################################################

    def StartRun(self):

        if int(self.params['ShowFixation']):
            self.stimuli['fixation'].on = True

        # pre-calculate trial task sequence

        self.numTaskTypes = len(self.params['Tasks'])

        relativeFrequencies = np.int_(np.asarray(self.params['Tasks'])[:,3])
        self.tasksMultiple = sum(relativeFrequencies)

        self.taskSubSequence = []
        for taskIndex in range(0,self.numTaskTypes):
            for repeat in range(0,relativeFrequencies[taskIndex]):
                self.taskSubSequence.append(taskIndex)

        # make sure that number of trials is a nice multiple of number of trial types
        if np.remainder(int(self.params['TrialsPerBlock']), self.tasksMultiple) != 0:
            raise ValueError('Parameter TrialsPerBlock (%d) is not a nice multiple of number of task types accounting for relative frequencies (%d)' % (int(self.params['TrialsPerBlock']), self.tasksMultiple))

        if self.params['BlocksPerRun'].val != 1:
            raise ValueError('Parameter BlocksPerRun is not equal to 1. Supporting this value would require changing task sequence generation and parsing code!')

        numTaskRepetitions = int(self.params['TrialsPerBlock'].val / self.tasksMultiple)

        self.taskSequence = np.tile(self.taskSubSequence, numTaskRepetitions)

        np.random.shuffle(self.taskSequence)

        print("Task sequence: %s" % self.taskSequence)

        self.trialCounter = -1 # initialize trial counter, incremented during state transitions



    #############################################################

    def Phases(self) :

        self.phase(name='intertrial',   duration=  int(self.params['ITI']),                 next='taskCue')
        self.phase(name='taskCue',      duration=  int(self.params['TaskCueDuration']),     next='directionCue')
        self.phase(name='directionCue', duration=  int(self.params['DirCueDuration']),      next='task')
        self.phase(name='task',         duration=  int(self.params['TaskDuration']),        next='intertrial')
        self.phase(name='idle',         duration=             2000,             next='intertrial' )
        self.phase(name='end')

        self.design(start='intertrial', new_trial='taskCue', interblock='idle',end='end')

    #############################################################

    def Transition(self, phase):

        # record what's going
        self.states['TaskCueOn'] = int(phase in ['taskCue'])
        self.states['DirectionCueOn'] = int(phase in ['directionCue'])
        self.states['TaskOn']  = int(phase in ['task'])

        self.stimuli['TaskCue'].on = (phase in ['taskCue', 'directionCue', 'task'])
        #$self.stimuli['DirectionCue'].on = (phase in ['directionCue', 'task'])

        if phase == 'intertrial':
            self.stimuli['cursor1'].on = False
            self.stimuli['cursor2'].on = False
            self.stimuli['target'].on = False
            self.stimuli['bar1'].on = False
            self.stimuli['feedbackBlocker'].on = False

            for leftOrRight in (0,1):
                for topOrBottom in (0,1):
                    self.stimuli['LateralCue' + str(leftOrRight) + str(topOrBottom)].on = False

                self.stimuli['BigCueArrow' + str(leftOrRight)].on = False

            self.states['TaskOn'] = 0
            self.states['Feedback'] = 0

            self.stimuli['barContainer_M'].color = (1,0,0)


        elif phase == 'taskCue':
            #self.states['TargetClass'] = randint(1,self.nclasses)
            #t = self.states['TargetClass']

            self.trialCounter += 1
            print("Trial counter: %d" % self.trialCounter)
            self.states['TaskType'] = self.taskSequence[self.trialCounter]

            self.stimuli['TaskCue'].text = self.params['Tasks'][self.taskSequence[self.trialCounter]][0]
            doShowFeedback = int(self.params['Tasks'][self.taskSequence[self.trialCounter]][2])
            if not doShowFeedback:
                self.stimuli['feedbackBlocker'].on = True

        elif phase == 'directionCue':
            direction = int(self.params['Tasks'][self.taskSequence[self.trialCounter]][1])

            if direction == 0:
                # no direction cue (e.g. rest)
                #self.stimuli['DirectionCue'].text = ''
                pass
            else:
                if direction == 1:
                    leftOrRight = 0
                    #self.stimuli['DirectionCue'].text = 'Left'
                else:
                    leftOrRight = 1
                    #self.stimuli['DirectionCue'].text = 'Right'

                if self.params['ShowLateralCue'].val:
                    for topOrBottom in (0,1):
                        self.stimuli['LateralCue' + str(leftOrRight) + str(topOrBottom)].on = True

                self.stimuli['BigCueArrow' + str(leftOrRight)].on = True

        elif phase == 'task':
            # reset cursor state at start of imagine
            self.cursorState[0,:] = np.squeeze(np.asarray(self.positions['origin']))
            self.barState[0,:] = np.squeeze(np.asarray(self.positions['origin']))

            self.targetState[0,:] = np.squeeze(np.asarray(self.positions['origin']))
            self.cursorSmoother = None

            self.exportStateVariables()

            self.stimuli['barContainer_M'].color = (0,1,0)

            #self.stimuli['target'].on = True


            doShowFeedback = int(self.params['Tasks'][self.taskSequence[self.trialCounter]][2])
            if doShowFeedback > 0:
                self.states['Feedback'] = 0
                self.stimuli['bar1'].on = True

                if int(self.params['CursorFeedback']) > 0:
                    self.stimuli['cursor1'].on = True
                    self.stimuli['cursor2'].on = True

            else:
                # don't turn on feedback stimuli
                self.stimuli['feedbackBlocker'].on = True
                pass

            self.states['TaskOn'] = 1

        elif phase == 'end':
            self.stimuli['TaskCue'].text = 'Done'
            self.states['Running'] = 0

        else:
            raise RuntimeError('Invalid phase transition')


    #############################################################

    def Frame(self, phasename):

        dt = 1.0/60 #TODO: calculate from difference between successive calls to Frame() rather than assuming constant

        # update cursor

        # update target

        center = np.squeeze(np.asarray(self.positions['origin']))
        center_x = center[0]
        center_y = center[1]
        xval = self.barState[0,0]

        signedBarLength = xval - center_x

        # smoothing
        #TODO: currently, if smoothing is enabled, self.barState when exported does not actually represent displayed bar position. Fix this (or delete smoothing code).
        if self.cursorSmoother == None:
            self.cursorSmoother = np.zeros(self.params['CursorSmoothLength'].val)

        self.cursorSmoother[0] = signedBarLength
        self.cursorSmoother = np.roll(self.cursorSmoother,1)

        signedBarLength = np.mean(self.cursorSmoother)

        if signedBarLength < 0:
            self.stimuli['bar1'].anchor = 'right'
            barLength = -signedBarLength
        else:
            self.stimuli['bar1'].anchor = 'left'
            barLength = signedBarLength

        barWidth = int(float(self.params['BarWidth'])*self.screenSize[1])
        #barVertices = ((xval,center_y+barWidth/2.0),(0,center_y+barWidth/2.0),
        #   (0,center_y-barWidth/2.0),(xval,center_y-barWidth/2.0))
        maxBarLength = int(float(self.params['BarLengthMax'])*self.screenSize[0])
        #print("Max bar length: %d     Actual bar length: %d" % (maxBarLength,barLength))#TODO: debug, delete
        barLength = np.minimum(barLength,maxBarLength)

        self.stimuli['bar1'].size = (barLength, int(float(self.params['BarWidth'])*self.screenSize[1]))
        #self.stimuli['bar1'].vertices = barVertices

        self.stimuli['cursor1'].position = np.clip(self.cursorState[0,:],center-maxBarLength,center+maxBarLength) #TODO: update to work correctly beyond just left/right control
        self.stimuli['cursor2'].position = np.clip(self.cursorState[0,:],center-maxBarLength,center+maxBarLength)

        self.stimuli['target'].position = self.targetState[0,:]

    def Process(self, sig):

        dt = 1.0/40 #TODO: dynamically calculate instead of approximating as constant

        self.barState[0,:] = np.squeeze(np.asarray(self.positions['origin']))

        if int(self.params['ControlDimension'])==0: # left/right
            self.barState[0,0] = self.barState[0,0] + np.squeeze(np.asarray(sig[0]))*100.0*self.params['BarLengthMultiplier'].val
            self.cursorState[0,0] = self.cursorState[0,0] + np.squeeze(np.asarray(sig[0]))*100.0*self.params['CursorMultiplier'].val

        elif int(self.params['ControlDimension'])==1: # up/down
            self.barState[0,1] = self.barState[0,1] + np.squeeze(np.asarray(sig[1]))*100.0*self.params['BarLengthMultiplier'].val
            self.cursorState[0,1] = self.cursorState[0,1] + np.squeeze(np.asarray(sig[1]))*100.0*self.params['CursorMutliplier'].val

        elif int(self.params['ControlDimension'])==2: #2D
            self.barState[0,:] = self.barState[0,:] + np.squeeze(np.asarray(sig))*100.0*self.params['BarLengthMultiplier'].val
            self.cursorState[0,:] = self.cursorState[0,:] + np.squeeze(np.asarray(sig))*100.0*self.params['CursorMultiplier'].val

        #print("Screen size: %d %d    cursor state: %d" % (self.screenSize[0], self.screenSize[1], self.cursorState[0,0]))
        center = np.squeeze(np.asarray(self.positions['origin']))
        maxBarLength = int(float(self.params['BarLengthMax'])*self.screenSize[0])
        barWidth = int(float(self.params['BarWidth'])*self.screenSize[1])
        self.barState[0,0] = max(min(self.barState[0,0],center[0]+maxBarLength),center[0]-maxBarLength)
        self.cursorState[0,0] = max(min(self.cursorState[0,0],center[0]+maxBarLength),center[0]-maxBarLength)
        #TODO: add support for up/down bar and cursor positions

        #print("  Screen size: %d %d    cursor state: %d" % (self.screenSize[0], self.screenSize[1], self.cursorState[0,0]))

        self.exportStateVariables()

    #############################################################

    def StopRun(self):

        self.states['TaskOn'] = 0
        self.stimuli['TaskCue'].on = False
        self.stimuli['DirectionCue'].on = False
        self.stimuli['arrow'].on = False
        self.stimuli['cursor1'].on = False
        self.stimuli['cursor1'].position = self.positions['origin'].A.ravel().tolist()
        self.stimuli['cursor2'].on = False
        self.stimuli['cursor2'].position = self.positions['origin'].A.ravel().tolist()
        self.stimuli['fixation'].on = False

################################################################
    #TODO: delete
    def barVertices(self, outerDisplacement, origin=(0.5,0.5)):

        if outerDisplacement[1] != 0:
            raise ValueError('Vertical position not yet supported')

        vertices = ((origin[0]+outerDisplacement[0], origin[1]+float(self.params['BarWidth'])/2.0),
                    (origin[0], origin[1]+float(self.params['BarWidth'])/2.0),
                    (origin[0], origin[1]-float(self.params['BarWidth'])/2.0),
                    (origin[0]+outerDisplacement[0], origin[1]-float(self.params['BarWidth'])/2.0))

        return vertices


#################################################################



