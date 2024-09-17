
import numpy

#################################################################

class BciApplication(BciGenericApplication):
	
	"""
	This is where the main point of the competition lies.  Your job is to
	write a BCI2000-compatible Application module which will present stimuli
	and respond to inputs in such a way as to enable efficient spelling of
	English text from a noisy input signal.
	
	If you want to implement your interface in Python, use the PythonApplication.exe
	module in combination with this file, BciApplication.py  When first downloaded,
	this file contains definitions of several demo stimuli to help you get
	started. Rewrite it.
	
	If you want to implement your interface in C++, go to the "Programming Reference"
	section of http://doc.bci2000.org to learn how to build a BCI2000 Application
	module.
	"""
	
	#############################################################
	
	def Preflight(self, inputProps):
		
		self.screen.setup(frameless_window=False)
	
	#############################################################
	
	def Initialize(self, inputDims, outputDims):
		
		from AppTools.CurrentRenderer import VisualStimuli
		
		self.screen.color = [0.8,0.8,0.8]
		w,h = self.screen.size
				
		self.screen.SetDefaultFont('courier')
		
		# The next section contains definitions of some example stimuli.
		# 
		# The classes VisualStimuli.Block, .Disc, .Text and .ImageStimulus have these generic names here
		# in order to abstract them away from the underlying implementation, which by default is
		# the third-party visual stimulus toolkit VisionEgg. In fact, any VisionEgg stimulus class can
		# be used here if you wish. The names and values of the stimulus construction parameters are
		# legal and meaningful only to the extent that instances of the underlying class recognize them:
		# for example, the VisionEgg.Text.Text constructor happens to recognize parameters called anchor,
		# position, text, and color, among others.
		
		# If you want to stick with Python but move away from VisionEgg, this is also possible, though it
		# requires quite some extra programming: see self.doc("Renderers")  
		
				
		# An example text object
		self.stimulus('ExampleText',  VisualStimuli.Text,
			anchor='center',
			position=[w*0.5, h*0.5],
			text='Here are some simple example stimuli.  Press Start...',
			color=[0.5,0,0],
			font_size=20,
		)

		# A filled circle
		self.stimulus('ExampleDisc',  VisualStimuli.Disc,
			position=[w*0.75, h*0.75],
			radius=20,
			color=[0,0,1],
		)
		
		# A filled rectangular patch
		self.stimulus('ExampleBlock', VisualStimuli.Block,
			anchor='upperleft',
			position=[w*0.05, h*0.95],
			size=[150,120],
			color=[0,0.5,0],
		)
		
		# An image stimulus can be created direct from a filename:
		self.stimulus('ExampleImage', VisualStimuli.ImageStimulus,
			texture='ArrowDown.png',
			anchor='top',
			position=[w*0.5,h-1],
			size=[192,192],
		)
						
		# ... or from an image object from pygame or PIL 
		import pygame
		logo = pygame.image.load('BCPy2000.png')
		imw,imh = logo.get_size()
		scaling = 0.5*w / imw 
		
		self.stimulus('ExampleImage2', VisualStimuli.ImageStimulus,
			texture=logo,
			anchor='lowerright',
			position=[w,0],
			size=[round(imw*scaling), round(imh*scaling)],
			color=self.screen.color,
		)
		
		
		# One more text stimulus
		pos = self.stimuli.ExampleBlock.position
		siz = self.stimuli.ExampleBlock.size
		self.stimulus('LabelForBlock', VisualStimuli.Text,
			anchor='center',
			position=[pos[0]+siz[0]/2, pos[1]-siz[1]/2],
			color=[0,0,0],
			on=False,
			z=+1,
			text='see self.doc("Phase Machine")',
			font_size=10,
			angle=20,
		)
		
		# Here is a sound stimulus
		from WavTools import wav, player
		w = wav('ding.wav')
		self.ding = player(w)
				
	#############################################################
	
	def StartRun(self):
		
		self.stimuli.ExampleText.text = 'Rapid mouse movements trigger a response.'	
		self.detections = 0
	
	#############################################################
	
	def Phases(self):
		
		self.phase(name='oblique',     duration= 2000,   next='horizontal')
		self.phase(name='horizontal',  duration= 5000,   next='oblique')
		
		self.design(start='horizontal')
	
	#############################################################
	
	def Transition(self, phase):
		
		if phase == 'oblique':
			self.stimuli.ExampleBlock.orientation = 20
			self.stimuli.LabelForBlock.on = True
			
		if phase == 'horizontal':
			self.stimuli.ExampleBlock.orientation = 0
			self.stimuli.LabelForBlock.on = False
	
	#############################################################

	def Process(self, sig):
		
		x = sig[0,0]  # scalar signal value
		
		if x:
			if not self.ding.going: self.ding.play()
			self.detections += 1
			self.stimuli.ExampleImage.color = (1,0,0)
			self.stimuli.ExampleText.text = 'Responses detected: %d' % self.detections
			
		else: 
			self.stimuli.ExampleImage.color = (1,1,1)
			
	#############################################################
	
	def StopRun(self):
		self.stimuli.ExampleText.text = 'suspended'
	
	#############################################################

	def Frame(self, phase):
		
		freq = 0.2
		t = self.frame_count * self.nominal.SecondsPerFrame
		y = 0.5 + 0.5 * numpy.sin(2 * numpy.pi * freq * t)
		
		self.stimuli.ExampleDisc.color = (0,0,y)

#################################################################
