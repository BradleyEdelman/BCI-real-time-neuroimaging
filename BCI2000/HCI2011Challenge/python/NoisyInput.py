import numpy
import win32api
import SigTools
import copy

#################################################################
#################################################################

class BciSource(BciGenericSource):	
	"""
	This class generates a signal similar to the one that will be used for judging the HCI2011
	challenge.
	
	It is provided to you for the purposes of testing your implementations. You should not, nor
	should you need to, change the code in this file or the values of the parameters it declares.
	
	This source module translates mouse movement into a positive signal embedded in noise. There is
	a delay between the detection of mouse movement and the generation of the positive signal, and the
	length of this delay will vary over time. There is also a refractory effect, such that
	signal-to-noise ratio decreases if mouse movement is continual or rapidly repeated over the
	course of several seconds. This simulates a noisy input to an assistive technology system
	(from EOG, EMG or EEG).
		
	In the competition final, this source module will be running on one computer (to which the
	mouse is attached) and your signal-processing and application modules will be running on another
	(to which the user's screen and speakers are attached).
	
	Note that the competition places its emphasis on interface design rather than signal processing.
	Therefore, your signal-processing should be fairly simple.  We advise against spending any time
	reverse-engineering the exact statistical properties of the BciSource algorithm that generates
	the noisy input signal: in the judging and in the final event of the competition, the input signal
	will be *qualitatively* similar to that generated here, in that mouse movement will create
	a positive signal with a variable delay, a lot of noise, some refractory effects, and a
	comparable amplitude to the current implementation.  However, the algorithm and parameters used
	to generate the signal will not necessarily be identical to those in this demo file.
	"""
	#############################################################
	
	def Construct(self):
		self.define_param('Source:Generation float     SourceCh=                  1          0     0 % //')
		self.define_param('Source:Generation floatlist SourceChGain=         1    1.0        1.0   0 % //')
		self.define_param('Source:Generation floatlist SourceChOffset=       1    0.0        0.0   0 % //')
		self.define_param('Source:Generation intlist   TransmitChList=       1    1          1     1 % //')
		
		self.define_param('Source:Generation float     LookbackMsec=           3000       3000     0 % //')
		self.define_param('Source:Generation float     LookbackExponent=          4.0        4.0   0 % //')
		self.define_param('Source:Generation float     PreGain=                   0.003      0.003 0 % //')
		self.define_param('Source:Generation float     PreNoise=                  1.8        1.8   0 % //')
		self.define_param('Source:Generation float     PostNoise=                 0.3        0.3   0 % //')
		self.define_param('Source:Generation float     PostGain=                100        100     0 % //')
		self.define_param('Source:Generation float     LowpassCutoffHz=          10.0       10.0   0 % //')
		self.define_param('Source:Generation int       LowpassOrder=             10         10     0 % //')
		self.define_param('Source:Generation floatlist DelayRangeMsec=       2    0 1500     0     % % //')
		self.define_param('Source:Generation floatlist DeltaRangeMsecPerSec= 2 -200  200     %     % % //')
		
	#############################################################
	
	def Preflight(self, inprops):
		self.pre_gain = float(self.params['PreGain'])
		self.pre_noise = float(self.params['PreNoise'])
		self.post_noise = float(self.params['PostNoise'])
		self.post_gain = float(self.params['PostGain'])
		self.lpcutoff = float(self.params['LowpassCutoffHz'])
		self.lporder = int(self.params['LowpassOrder'])
		self.fs = self.samplingrate()
		
		self.delaydelta = self.params['DeltaRangeMsecPerSec'].val
		self.delayrange = self.params['DelayRangeMsec'].val
		
		self.lookback = float(self.params['LookbackMsec'])
		self.attexp = float(self.params['LookbackExponent'])
		self.attcft = 1.0
		
	#############################################################
	
	def Initialize(self, indim, outdim):
		if self.lporder == 0 or self.lpcutoff == 0.0:
			self.filter = None
		else:
			self.filter = SigTools.causalfilter(self.lpcutoff, self.samplingrate(), self.lporder, type='lowpass', method=SigTools.firdesign)
				
		if self.lookback == 0.0:
			self.trap = None
		else:
			nc = indim[0]
			ns = SigTools.msec2samples(self.lookback,self.fs)
			self.trap = SigTools.trap(ns, nc, leaky=True)
			z = numpy.asmatrix(numpy.zeros((nc,ns)))
			zz,c = self.noisify(z)
			zz,c = self.noisify(z)
			self.attcft = 1.0/c

		self.last_mpos = None
		self.ring = None
		self.delay = None
	
		
	#############################################################
	
	def StartRun(self):
		pass
		
	#############################################################
	
	def Process(self, sig):
		
		mpos = numpy.asarray(win32api.GetCursorPos(), dtype=numpy.float64)
		if self.last_mpos == None: mmov = 0.0
		else: mmov = ((mpos - self.last_mpos) ** 2).sum() ** 0.5
		self.last_mpos = mpos
		
		delayrange = numpy.asarray(self.delayrange).flatten()
		if self.delay == None:
			self.delay = min(delayrange) + (max(delayrange)-min(delayrange)) * numpy.random.rand()
		olddelaymsec,olddelaysamples = self.round(msec=self.delay)
		if self.ring == None:
			nc = sig.shape[0]
			ns = self.nominal.SamplesPerPacket + self.round(msec=max(delayrange))[1]
			z = numpy.asmatrix(numpy.zeros((nc,olddelaysamples)))
			z,attenuation = self.noisify(z)
			self.ring = SigTools.ring(ns*20, nc)
			self.ring.write(z)

		deltarange = numpy.asarray(self.delaydelta).flatten() * self.nominal.SecondsPerPacket
		negjumplimit = -SigTools.samples2msec(self.nominal.SamplesPerPacket-1, self.fs)
		negjumplimit = max(min(deltarange), negjumplimit)

		deltamsec = negjumplimit + (max(deltarange) - negjumplimit) * numpy.random.rand()
		newdelaymsec = olddelaymsec + deltamsec
		newdelaymsec = max(newdelaymsec, min(delayrange))
		newdelaymsec = min(newdelaymsec, max(delayrange))
		deltamsec,deltasamples = self.round(msec=newdelaymsec-olddelaymsec)
		self.delay = olddelaymsec + deltamsec
		
		shape = (sig.shape[0],  self.nominal.SamplesPerPacket + deltasamples)
		sig = mmov + numpy.asmatrix(numpy.zeros(shape))
		sig,attenuation = self.noisify(sig)
		#print attenuation
		
		self.ring.write(sig)
		sig = self.ring.read(self.nominal.SamplesPerPacket)
		
		return sig

	#############################################################
	
	def StopRun(self):
		pass
		
	#############################################################
	
	def round(self, msec=None, samples=None):
		if msec != None:
			samples = SigTools.msec2samples(msec, self.fs)
		if samples != None:
			samples = int(round(samples))
			msec = SigTools.samples2msec(samples, self.fs)
		return msec,samples
	
	def noisify(self, sig):
		
		sig = sig + 0.0 # makes a copy

		if self.trap and self.trap.full():
			rms = (self.trap.read() ** 2).mean() ** 0.5
			attenuation = self.attcft * rms ** self.attexp
		else:
			attenuation = 1.0
			
		sig *= self.pre_gain / attenuation
		sig += numpy.random.randn(1,sig.shape[1]) * self.pre_noise
		sig = SigTools.logistic(sig) - 0.5
		sig += numpy.random.randn(1,sig.shape[1]) * self.post_noise
		if self.filter: sig = self.filter.apply(sig)
		self.trap.process(sig)
		sig *= self.post_gain
				
		return sig,attenuation
	
#################################################################
#################################################################
