#   $Id: TriangleApplication.py 2900 2010-07-09 15:44:21Z mellinger $
#   
#   This file is a BCPy2000 demo file, which illustrates the capabilities
#   of the BCPy2000 framework.
# 
#   Copyright (C) 2007-10  Jeremy Hill
#   
#   bcpy2000@bci2000.org
#   
#   This program is free software: you can redistribute it
#   and/or modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation, either version 3 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
import numpy as np
from random import randint

from AppTools.Boxes import box
from AppTools.Displays import fullscreen
from AppTools.Shapes import PolygonTexture, Disc
from AppTools.StateMonitors import addstatemonitor, addphasemonitor
from SigTools.Plotting import plot


# from pygame import mixer; from pygame.mixer import Sound
# from WavTools.FakePyGame import mixer, Sound # would provide a workalike interface to the line above
#
import WavTools                                # but let's get into the habit of using WavTools.player
# explicitly, since it is more flexible, and its timing
# is now more reliable than that of pygame.mixer.Sound

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
            "PythonApp:Screen   int    ScreenId=           -1    -1     %   %  // on which screen should the stimulus window be opened - use -1 for last",
            "PythonApp:Screen   float  WindowSize=         1.0   1.0   0.0 1.0 // size of the stimulus window, proportional to the screen",
            "PythonApp:Stimuli  int  CursorSize=            10  10  0   100 // diameter of cursor",
            "PythonApp:Stimuli  int  TargetSize=            40  40  0   200 // diameter of target",
            "PythonApp:Stimuli float TargetFriction=    1   1   0   10  //constant damping force on target movement",
            "PythonApp:Stimuli float TargetViscosity=   1   1   0   10  //damping force proportional to velocity",
            "PythonApp:Stimuli float TargetVariance=    1.0 1.0 0.0 10.0 //variance of force applied to target",
            "PythonApp:Feedback int CursorFeedback=     1   1       0   1  // show online feedback cursor (boolean)",
            "PythonApp:Feedback float CursorFriction=   1   1   0   10  //constant damping force on cursor movement",
            "PythonApp:Feedback float CursorViscosity=  1   1   0   10  //damping force proportional to velocity",
            "PythonApp:Feedback int ControlType=        0   3   0   3   //1=force-based, 2=velocity-based, 3=kalman filter, 0=let program choose",
            "PythonApp:KalmanFilter int ResidualBasedAdaptation= 1 1 0 1 //Adapt estimate covariance based on changes in residual (boolean)",
            "PythonApp:KalmanFilter float ResidualAdaptMax= 1.5 10.0 1.0 1000 //Maximum scalar per step to adapt estimate covariance",
            "PythonApp:KalmanFilter float TransitionNoiseScalar= 1.0 1.0 0 10000 //Scalar representing estimate of transition noise covariance",
            "PythonApp:KalmanFilter float MeasurementNoiseScalar= 100.0 100.0 0 10000 //Scalar representing estimate of measurement noise covariance"
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

        self.kf = {}
        self.kf['numState'] = 2 # number of state variables
        self.kf['numMeasure'] = 2 # number of measurement variables

        for i in range(0,self.kf['numState']):
            self.define_state("KF_xp" + str(i) + "_s 16 0 0 0") # prediction (next step)
            self.define_state("KF_xe" + str(i) + "_s 16 0 0 0") # estimate (current step)

        for i in range(0,self.kf['numMeasure']):
            self.define_state("KF_z" + str(i) + "_s 16 0 0 0")

        for i in range(0,self.kf['numState']):
            for j in range(0,self.kf['numState']):
                self.define_state("KF_P" + str(i) + str(j) + "_f 32 0 0 0")
                self.define_state("KF_K" + str(i) + str(j) + "_f 32 0 0 0") # Kalman gain

        self.define_state("KF_covarianceScalar_f    16 0 0 0",
                          "KF_residualScalar_f      16 0 0 0",
                          "KF_residual_f            16 0 0 0")

    #############################################################

    def Preflight(self, sigprops):

        self.nclasses = 2

        self.ndim = 2

        if not self.in_signal_dim[0] in (self.nclasses,):
            raise EndUserError,'%d-channel input expected' % (self.nclasses,)

        siz = float(self.params['WindowSize'])
        screenid = int(self.params['ScreenId'])  # ScreenId 0 is the first screen, 1 the second, -1 the last
        fullscreen(scale=siz, id=screenid, frameless_window=(siz==1))
        # only use a borderless window if the window is set to fill the whole screen

        c_friction = 0.99 # reduce predicted velocity with each step

        self.kf['F'] = np.matrix(
                [[c_friction ,   0],
                [0 ,   c_friction]]
        )
        self.kf['H'] = np.matrix(
                [[1, 0],
                 [0, 1]]
        )

        self.kf['Q'] = np.asmatrix(np.eye(self.kf['numState']))*float(self.params['TransitionNoiseScalar']) # transition noise estimate
        self.kf['R'] = np.asmatrix(np.eye(self.kf['numMeasure']))*float(self.params['MeasurementNoiseScalar']) # measurement noise estimate

        #TODO: find what would be reasonable initial guesses here
        self.kf['x'] = np.asmatrix(np.zeros((self.kf['numState'],1))) # initial state estimate
        self.kf['P'] = self.kf['Q'] * 100 # initial state covariance

        self.kf['lengthHistory'] = 100
        self.kf['residualScalarHistory'] = np.ones((self.kf['lengthHistory'],self.kf['numMeasure']))

        self.historicalStates = np.zeros(self.kf['x'].shape) # for plotting

    #############################################################

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

        #export Kalman state matrices from self.kf[]
        for i in range(0,self.kf['numState']):
            self.states["KF_xp" + str(i) + "_s"] = int(self.kf['x'][i] + offset)
            self.states["KF_xe" + str(i) + "_s"] = int((self.kf['x_est'][i] if 'x_est' in self.kf else 0) + offset)

        for i in range(0,self.kf['numMeasure']):
            self.states["KF_z" + str(i) + "_s"] = int((self.kf['z'][i] if 'z' in self.kf else 0) + offset)

        for i in range(0,self.kf['numState']):
            for j in range(0,self.kf['numState']):
                self.states["KF_P" + str(i) + str(j) + "_f"] = int((self.kf['P'][i,j])*multiplier + offset)
                self.states["KF_K" + str(i) + str(j) + "_f"] = int((self.kf['K'][i,j] if 'K' in self.kf else 0)*multiplier + offset)

        self.states['KF_residualScalar_f'] = int(self.kf['residualScalar']*multiplier + offset)
        self.states['KF_covarianceScalar_f'] = int(self.kf['covarianceScalar']*multiplier + offset)
        self.states['KF_residual_f'] = int(self.kf['residual']*multiplier + offset)


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

        # self.phase(next='startcue',     duration=             3000,   name='baseline')
        # self.phase(next='gap',          duration=             1000,   name='startcue')
        # self.phase(next='imagine1',     duration=              800,   name='gap')
        # self.phase(next='imagine2',     duration=             1000,   name='imagine1') # The 'Learn' state won't be set just yet...
        # self.phase(next='imagine3',     duration=             4000,   name='imagine2') # Set it now: let's learn from this phase.
        # self.phase(next='stopcue',      duration=             5000,   name='imagine3') # Ok, that's enough learning.
        # self.phase(next='intertrial', duration=                800,   name='stopcue')
        # self.phase(next='baseline',     duration=randint(1000,3000),  name='intertrial')

        self.design(start='intertrial', new_trial='baseline', interblock='idle')

    #############################################################

    def Transition(self, phase):

        # record what's going
        self.states['BaselineOn'] = int(phase in ['baseline'])
        self.states['StartCueOn'] = int(phase in ['startcue'])
        self.states['StopCueOn']  = int(phase in ['stopcue'])
        self.states['Feedback'] = int(phase in ['imagine'])

        self.stimuli['cue'].on = (phase in ['startcue', 'stopcue'])
        #self.stimuli['arrow'].on = (phase in ['startcue'])

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

            if dampedVelocity.shape != (2,):
                self.dbstop()


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


        elif controlType == 3: # kalman-filtered velocity-based control

            kf = self.kf
            next = {}

            # copy out of kf dict for convenience, shorthand in equations
            x = kf['x']
            F = kf['F']
            P = kf['P']
            H = kf['H']
            R = kf['R']
            Q = kf['Q']

            #TODO: change code so that externalInput is only incorporated once per data update, instead of once per render frame
            kf['z'] = np.asmatrix(externalInput * 100.0).T
            z = kf['z']

            # equations from Anderson and Moore, 5.4.9 - 5.4.11, 5.5.6

            #  calculate Kalman gain
            kf['L'] = P*H * np.linalg.pinv(H.T*P*H + R)
            L = kf['L']
            kf['K'] = F*L # assuming S=0
            K = kf['K']

            # prediction
            next['x'] = F*x + K*(z - H.T*x)

            if int(self.params['ResidualBasedAdaptation']):
                residual = z - H.T*x
                residualScalar = (residual.T * residual).item()
                covarianceScalar = residualScalar / np.mean(kf['residualScalarHistory'])
                kf['residualScalarHistory'] = np.roll(kf['residualScalarHistory'],1) # not very efficient
                kf['residualScalarHistory'][0] = residualScalar

                if covarianceScalar < 1:
                    covarianceScalar = 1

                if covarianceScalar > float(self.params['ResidualAdaptMax']):
                    covarianceScalar = float(self.params['ResidualAdaptMax']) # arbitrary ceiling to prevent state overflow on very large covariance
            else:
                covarianceScalar = 1.0

            kf['covarianceScalar'] = covarianceScalar
            kf['residualScalar'] = residualScalar
            kf['residual'] = residual

            #self.dbstop()

            next['P'] = covarianceScalar*((F - K*H.T)*P*(F-K*H.T).T + Q + K*R*K.T) # assuming S=0

            # estimate current filtered estimate, using latest measurement
            kf['x_est'] = x + L*(z-H.T*x)

            # transition to next 'index'
            kf['x'] = next['x']
            kf['P'] = next['P']

            self.historicalStates = np.append(self.historicalStates, kf['x'])



            #plot(self.historicalStates,axis=1)


            newObjState[2,:] = np.zeros(newObjState[2,:].shape) # no added acceleration

            newObjState[1,:] = kf['x_est'].T

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
