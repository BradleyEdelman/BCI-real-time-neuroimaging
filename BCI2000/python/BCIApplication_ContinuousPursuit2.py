#
# Heavily modified from the "TriangleApplication.py" example provided with BCPy2000
#
import numpy as np
from random import randint

from AppTools.Boxes import box
from AppTools.Displays import fullscreen, init_screen
from AppTools.Shapes import PolygonTexture, Disc
from AppTools.StateMonitors import addstatemonitor, addphasemonitor
from SigTools.Plotting import plot

#################################################################
#################################################################

class BciApplication(BciGenericApplication):

    #############################################################

    def Description(self):
        return "continuous pursuit task"

    #############################################################

    def Construct(self):
        # format = "Section Datatype Name= Value DefaultValue LowRange HighRange //comment"
        self.define_param(
            "PythonApp:Design   int    ShowFixation=        0     0     0   1  // show a fixation point in the center (boolean)",
            "PythonApp:Design   int    ControlDim=          1     0     0   2  // Control Dimension: 1=1D-Horizontal, 2=1D-Vertical, 3=2D (enumeration)",
            "PythonApp:Screen   int    ScreenId=           -1    -1     %   %  // on which screen should the stimulus window be opened - use -1 for last",
            "PythonApp:Screen   float  WindowHeight=       100   100    %   %  // height of the stimulus window",
            "PythonApp:Screen   float  WindowWidth=        100   100    %   %  // width of the stimulus window",
            "PythonApp:Screen   float  WindowLeft=         100   100    %   %  // horizontal position of the stimulus window",
            "PythonApp:Screen   float  WindowTop=          100   100    %   %  // vertical position of the stimulus window",
            "PythonApp:Stimuli  int  CursorSize=            10  10  0   100 // diameter of cursor",
            "PythonApp:Stimuli  int  TargetSize=            40  40  0   200 // diameter of target",
            "PythonApp:Stimuli float TargetFriction=    1   1   0   10  //constant damping force on target movement",
            "PythonApp:Stimuli float TargetViscosity=   1   1   0   10  //damping force proportional to velocity",
            "PythonApp:Stimuli float TargetVariance=    1.0 1.0 0.0 10.0 //variance of force applied to target",
            "PythonApp:Feedback int CursorFeedback=     1   1       0   1  // show online feedback cursor (boolean)",
            "PythonApp:Feedback float CursorFriction=   1   1   0   10  //constant damping force on cursor movement",
            "PythonApp:Feedback float CursorViscosity=  1   1   0   10  //damping force proportional to velocity",
            "PythonApp:Feedback int ControlType=        1   0   0   2   //1=force-based, 2=velocity-based, 0=let program choose",
            )
        self.define_state(
            "Cursor_PosX_u        16 0 0 0",
            "Cursor_PosY_u        16 0 0 0",
            "Cursor_VelX_s        16 0 0 0",
            "Cursor_VelY_s        16 0 0 0",
            "Cursor_AccX_s        16 0 0 0",
            "Cursor_AccY_s        16 0 0 0",
            "Cursor_ForceX_s      16 0 0 0",
            "Cursor_ForceY_s      16 0 0 0",
            "Target_PosX_u        16 0 0 0",
            "Target_PosY_u        16 0 0 0",
            "Target_VelX_s        16 0 0 0",
            "Target_VelY_s        16 0 0 0",
            "Target_AccX_s        16 0 0 0",
            "Target_AccY_s        16 0 0 0",
            "SignedOffset       16 32767 0 0",
            "FloatScalar        16 10000 0 0",
            "BaselineOn   1 0 0 0",
            "StartCueOn   1 0 0 0",
            "StopCueOn    1 0 0 0",
            "Feedback     1 0 0 0",   # bells? whistles?
        )


    #############################################################

    def Preflight(self, sigprops):

        self.nclasses = 2

        self.ndim = 2

        if not self.in_signal_dim[0] in (self.nclasses,):
            raise EndUserError,'%d-channel input expected' % (self.nclasses,)

        screenid = int(self.params['ScreenId'])  # ScreenId 0 is the first screen, 1 the second, -1 the last
        #fullscreen(scale=siz, id=screenid, frameless_window=(siz==1))
        height = int(self.params['WindowHeight'])
        width = int(self.params['WindowWidth'])
        left = int(self.params['WindowLeft'])
        top = int(self.params['WindowTop'])
        b = box(size=[height, width], position=(left + width/2, top + height/2), sticky=True)
        init_screen(b)
        # only use a borderless window if the window is set to fill the whole screen

        #c_friction = 0.99 # reduce predicted velocity with each step
        c_friction = 1.0

        #self.historicalStates = np.zeros(self.kf['x'].shape) # for plotting

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
        self.states['Cursor_VelX_s'] = int(self.cursorState[1,0] + offset)
        self.states['Cursor_VelY_s'] = int(self.cursorState[1,1] + offset)
        self.states['Cursor_AccX_s'] = int(self.cursorState[2,0] + offset)
        self.states['Cursor_AccY_s'] = int(self.cursorState[2,1] + offset)

        self.states['Cursor_ForceX_s'] = int(self.cursorForce[0] + offset)
        self.states['Cursor_ForceY_s'] = int(self.cursorForce[1] + offset)

        self.states['Target_PosX_u'] = int(self.targetState[0,0])
        self.states['Target_PosY_u'] = int(self.targetState[0,1])
        self.states['Target_VelX_s'] = int(self.targetState[1,0] + offset)
        self.states['Target_VelY_s'] = int(self.targetState[1,1] + offset)
        self.states['Target_AccX_s'] = int(self.targetState[2,0] + offset)
        self.states['Target_AccY_s'] = int(self.targetState[2,1] + offset)

    def Initialize(self, indim, outdim):

        # compute how big everything should be
        #itf = float(self.params['InnerTriangleSize'])
        #otf = float(self.params['OuterTriangleSize'])
        scrw,scrh = self.screen.size
        scrsiz = min(scrw,scrh)

        self.screenSize = self.screen.size #TODO: change to have screenSize represent actual drawing space for cursor

        #circle_radius = scrsiz * 0.5 * float(self.params['CircleRadius'])
        #siz = (scrsiz * otf * 0.866,   scrsiz * otf * 0.75)
        siz = (scrsiz*0.8, scrsiz*0.9)

        # use a handy AppTools.Boxes.box object as the coordinate frame for the triangle
        b = box(size=siz, position=(scrw/2.0,scrh/2.0 - siz[1]/6.0), sticky=True)
        center = b.map((0.5,2.0/3.0), 'position')
        self.positions = {'origin': np.matrix(center)}

        self.cursorState = np.zeros((3,2)) # position, velocity, acceleration in 2D
        self.cursorForce = np.zeros( 2 )

        self.cursorState[0,:] = np.squeeze(np.asarray(self.positions['origin'])) #start cursor in center of screen

        self.targetState = np.zeros((3,2))
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

        # OK, now register all those stimuli, plus a few more, with the framework
        self.stimulus('cursor1',  z=3,   stim=Disc(position=center, radius=int(self.params['CursorSize']), color=(1,1,1), on=False))
        self.stimulus('cursor2',  z=4,   stim=Disc(position=center, radius=int(self.params['CursorSize'])*0.5,  color=(0,0,0), on=False))
        self.stimulus('target',   z=2,   stim=Disc(position=center, radius=int(self.params['TargetSize']),color=(0.5,0.5,0.5), on=False))
        self.stimulus('arrow',    z=4.5, stim=arrow)
        self.stimulus('cue',      z=5,   stim=VisualStimuli.Text(text='?', position=center, anchor='center', color=(1,1,1), font_size=50, on=False))
        self.stimulus('fixation', z=4.2, stim=Disc(position=center, radius=5, color=(1,1,1), on=False))

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

    #############################################################

    def StartRun(self):

        if int(self.params['ShowFixation']):
            self.stimuli['fixation'].on = True

    #############################################################

    def Phases(self) :

        self.phase(next='startcue',   duration=             100,    name='baseline')
        self.phase(next='gap',        duration=             1000,   name='startcue')
        self.phase(next='imagine',    duration=              100,   name='gap')
        self.phase(next='stopcue',    duration=             60000,  name='imagine')
        self.phase(next='intertrial', duration=             1000,   name='stopcue')
        self.phase(next='baseline',   duration=             1000,   name='intertrial')
        self.phase(next='intertrial', duration=             1000,   name='idle')

        self.design(start='intertrial', new_trial='baseline', interblock='idle')

    #############################################################

    def Transition(self, phase):

        # record what's going
        self.states['BaselineOn'] = int(phase in ['baseline'])
        self.states['StartCueOn'] = int(phase in ['startcue'])
        self.states['StopCueOn']  = int(phase in ['stopcue'])
        self.states['Feedback'] = int(phase in ['imagine'])

        self.stimuli['cue'].on = (phase in ['startcue', 'stopcue'])

        if phase == 'baseline':
            #self.states['TargetClass'] = 0
            pass

        if phase == 'startcue':
            #self.states['TargetClass'] = randint(1,self.nclasses)
            #t = self.states['TargetClass']
            self.stimuli['cue'].text = 'Start'
            #self.stimuli['arrow'].color = map(lambda x:int(x==t), [1,2,3])
            #self.stimuli['arrow'].angle = -120*(t - 1)
            pass

        if phase == 'stopcue':
            self.stimuli['cue'].text = 'Stop'
            pass

        if phase == 'imagine':
            # reset cursor state at start of imagine
            self.cursorState = np.zeros((3,2)) # position, velocity, acceleration in 2D
            self.cursorForce = np.zeros( 2 )

            self.cursorState[0,:] = np.squeeze(np.asarray(self.positions['origin']))
            self.targetState[0,:] = np.squeeze(np.asarray(self.positions['origin']))

            #TODO: reset relevant KF variables (e.g. position estimate)

            self.exportStateVariables()

            self.stimuli['cursor1'].on = True
            self.stimuli['cursor2'].on = True
            self.stimuli['target'].on = True

            self.states['Feedback'] = 1
        else:
            self.stimuli['cursor1'].on = False
            self.stimuli['cursor2'].on = False
            self.stimuli['target'].on = False

            self.states['Feedback'] = 0


    #############################################################

    def updateObjectPosition(self,objectState,dt=1.0/60):

        # calculate velocity
        objectState[1,:] = objectState[1,:] + objectState[2,:]*dt

        # calculate position
        objectState[0,:] = objectState[1,:]*dt + objectState[0,:]

        # wrap position around to other side of screen if it exceeds limits
        objectState[0,:] = np.mod(objectState[0,:], self.screenSize)

        return objectState


    def updateObjectMovement(self,objectState,externalInput,friction,viscosity,controlType,dt=1.0/40):
        prevObjState = objectState
        newObjState = objectState

        if controlType == 0:
            controlType = 3 # select default

        if controlType == 1: # force-based control

            undampedVelocity = prevObjState[1,:] + externalInput.T * dt * 100.0

            frictionForce = float(friction) * -1 * undampedVelocity / np.linalg.norm(undampedVelocity) * 20
            viscousForce = float(viscosity) * -1 * undampedVelocity * abs(undampedVelocity) * 0.01

            dampedVelocity = undampedVelocity + (frictionForce + viscousForce) * dt

            for d in range(0,2):
                if np.sign(dampedVelocity[d]) != np.sign(undampedVelocity[d]):
                    dampedVelocity[d] = 0

            newObjState[1,:] = dampedVelocity

            effectiveAcceleration = (newObjState[1,:] - prevObjState[1,:])/dt
            #newObjState[2,:] = effectiveAcceleration #TODO: decide whether this is necessary
            newObjState[2,:] = np.zeros(newObjState[1,:].shape)


        elif controlType == 2: # regular velocity-based control

            newObjState[2,:] = np.zeros(newObjState[1,:].shape)

            newObjState[1,:] = (externalInput.T * 100.0) 

            #newObjState[0,:] = newObjState[1,:]*dt + prevObjState[0,:]

            #plot(self.historicalStates,axis=1)


        #    newObjState[2,:] = np.zeros(newObjState[2,:].shape) # no added acceleration

        #    newObjState[1,:] = kf['x_est'].T

            #newObjState[0,:] = newObjState[1,:]*dt + prevObjState[0,:]



        else:
            raise Exception('Invalid control type')




        return newObjState


    def Frame(self, phasename):

        dt = 1.0/60 #TODO: calculate from difference between successive calls to Frame() rather than assuming constant

        # update cursor
        self.cursorState = self.updateObjectPosition(
            self.cursorState,
            dt)

        # update target
        self.targetState = self.updateObjectPosition(
            self.targetState,
            dt)

        if int(self.params['CursorFeedback']):
            self.stimuli['cursor1'].position = self.cursorState[0,:]
            self.stimuli['cursor2'].position = self.cursorState[0,:]

            self.stimuli['target'].position = self.targetState[0,:]


    def Process(self, sig):

        dt = 1.0/40 #TODO: dynamically calculate instead of approximating as constant

        self.cursorForce = np.squeeze(np.asarray(sig))*1.0

        # update cursor
        self.cursorState = self.updateObjectMovement(
            self.cursorState,
            self.cursorForce,
            self.params['CursorFriction'],
            self.params['CursorViscosity'],
            int(self.params['ControlType']),
            dt)

        # update target
        targetVariance = float(self.params['TargetVariance'])

        targetForce = np.random.normal(0,targetVariance*targetVariance,(2,))
        controlDim = int(self.params['ControlDim'])
        if controlDim == 1:
            targetForce[1] = 0
        elif controlDim == 2:
            targetForce[0] = 0


        self.targetState = self.updateObjectMovement(
            self.targetState,
            targetForce.T,
            self.params['TargetFriction'],
            self.params['TargetViscosity'],
            1,
            dt)

        self.exportStateVariables()


    #############################################################

    def StopRun(self):

        self.states['Feedback'] = 0
        self.stimuli['cue'].on = False
        self.stimuli['arrow'].on = False
        self.stimuli['cursor1'].on = False
        self.stimuli['cursor1'].position = self.positions['origin'].A.ravel().tolist()
        self.stimuli['cursor2'].on = False
        self.stimuli['cursor2'].position = self.positions['origin'].A.ravel().tolist()
        self.stimuli['fixation'].on = False

#################################################################
#################################################################
