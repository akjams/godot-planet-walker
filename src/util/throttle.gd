class_name Throttle extends Node

var c: Callable
var maxFreqMs: int
var lastCallMs: int = 0
var queuedCallArgs: Array = []
var queuedCallTimer: Timer

func _init(callable: Callable, theMaxFreqMs: int, theParent: Node):
	self.c = callable
	self.maxFreqMs = theMaxFreqMs
	self.queuedCallTimer = Timer.new()
	queuedCallTimer.one_shot = true
	queuedCallTimer.timeout.connect(onQueuedCallDing)

	# ensure first call can go off right after engine starts
	lastCallMs = -theMaxFreqMs

	theParent.add_child(self)
	self.add_child(queuedCallTimer)

# API HERE
func tryCall(args: Array) -> Variant:
	if canCallC():
		return callC(args)

	queuedCallArgs = args
	if queuedCallTimer.is_stopped():
		queuedCallTimer.wait_time = float(1 + lastCallMs + maxFreqMs - Util.nowMs()) / 1000.0
		queuedCallTimer.start()
	return null

func onQueuedCallDing():
	queuedCallTimer.stop()
	callC(queuedCallArgs)

func canCallC() -> bool:
	return lastCallMs + maxFreqMs < Util.nowMs()

func callC(args: Array):
	lastCallMs = Util.nowMs()
	return c.callv(args)




# usage: call the wrapper with wrapper.callv(args: Array)
#
# Returns a function wrapper around c
# The wrapper may be called many times.
# c will only be executed every maxFreqMs
# example with maxFreqMs == 50
# input calls at: 0, 2, 18, 42ms
# the first will be called immediately
# the second and third are never called
# the last will be called 8ms after it is attempted
# .
# wrapper returns what c returns if invoked immediately, else null
# static func throttle(c: Callable, maxFreqMs: int) -> Callable:
# 	var lastCallMs: int

# 	var queuedCallArgs: Array
# 	var queuedCallTimer: Timer = Timer.new()

# 	queuedCallTimer.one_shot = true
# 	queuedCallTimer.timeout.connect(onQueuedCallDing)
# 	theParent.add_child(queuedCallTimer)

# 	var onQueuedCallDing = func():
# 		c.callv(queuedCallArgs)
# 		queuedCallTimer.stop()
	


# 	var wrapper: Callable = func(args: Array):
# 		if canCallC.call():
# 			return callC.call(args)
		
# 		queuedCallArgs = args
# 		if queuedCallTimer.is_stopped():
# 			queuedCallTimer.wait_time = Time.get_tick
# 			queuedCallTimer.start()
# 		return null
	
# 	return wrapper