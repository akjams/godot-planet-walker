class_name Util extends RefCounted

static func passMouseEventsAlong(root: Node):
	var controls: Array[Control]
	controls.assign(Util.findChildren(root, func(x): return x is Control))
	for c in controls:
		c.mouse_filter = c.MOUSE_FILTER_PASS

static func nowSec() -> int:
	@warning_ignore('integer_division')
	return nowMs() / 1000

static func nowMs() -> int:
	return Time.get_ticks_msec()

static func getScriptClassName(n: Node):
	var scr: Script = n.get_script()
	if scr == null:
		return 'Node'
	return scr.get_global_name()

static func getScenePaths() -> Array[String]:
	var paths: Array[String] = []
	getAllFilePathsFrom('res://src', paths)
	getAllFilePathsFrom('res://test', paths)
	var scenePaths: Array[String] = paths.filter(func(p: String): return p.get_extension() == 'tscn')
	return scenePaths

static var rsDataPath = 'res://src/rs/data'

static func getMyRss(predicate: Callable = returnTrue) -> Array[MyRs]:
	var rsPaths: Array[String] = []
	getAllFilePathsFrom(rsDataPath, rsPaths)

	# print(rsPaths.size(), Arrays.prettify(rsPaths))
	rsPaths = rsPaths.filter(func(p: String): return p.get_extension() == 'tres')
	# print(rsPaths.size(), Arrays.prettify(rsPaths))

	var rss: Array[MyRs]
	for path in rsPaths:
		var inst = load(path)
		if !inst is MyRs:
			push_error('inst not MyRs: %s:%s' % [inst, inst.resource_path])
			continue
		if predicate.call(inst):
			rss.append(inst)

	# print('instances', rsPaths)

	return rss

static func getAllFilePathsFrom(startingDir: String, result: Array[String]) -> void:
	var dir := DirAccess.open(startingDir)
	if !dir:
		push_error('cant open ', rsDataPath)
		return
	
	var files := dir.get_files()
	for file in files:
		var absFile = dir.get_current_dir().path_join(file)
		result.append(absFile)

	var subdirs := dir.get_directories()
	# print(subdirs)
	for subdir in subdirs:
		var absSubdir := dir.get_current_dir().path_join(subdir)
		getAllFilePathsFrom(absSubdir, result)

static func scream(s: Variant):
	print('-------------------------------------------')
	print(str(s))
	print('-------------------------------------------')

# freed
static func createOneshotTimer(waitTime: float, theParent: Node, callback: Callable = emptyFunc) -> Timer:
	var timer = Timer.new()
	timer.wait_time = waitTime
	timer.one_shot = true
	theParent.add_child(timer)
	timer.timeout.connect(callback)
	timer.start()

	var closure = func():
		timer.queue_free()
	timer.timeout.connect(closure)	

	return timer

static func findChildren(n: Node, predicate: Callable) -> Array[Node]:
	var candidates = gatherChildren(n)
	var filtered = candidates.filter(predicate)
	return filtered

static func gatherChildren(n: Node) -> Array[Node]:
	var ar: Array[Node] = []
	gatherChildrenHelper(n, ar)
	return ar

static func gatherChildrenHelper(n: Node, ar: Array[Node]):
	if !n:
		return
	ar.append(n)
	for child in n.get_children():
		gatherChildrenHelper(child, ar)

static func printChildren(n: Node, indent: int = 0):
	if !n:
		return
	
	var indentStr = ''
	for i in range(indent):
		indentStr += ' '
	print('|%s%s' % [indentStr, str(n)])

	for c in n.get_children():
		printChildren(c, indent + 1)

static func floatToMs(x: float) -> String:
	return '%1.f ms' % [x * 1000]

static func emptyFunc():
	pass

static func returnZero() -> int:
	return 0

static func returnTrue(_1) -> bool:
	return true

static func isFreedOrQFreed(o: Variant) -> bool:
	return str(o) == '<Freed Object>' || o.is_queued_for_deletion()
	# var wr = weakref(o)
	# return !(wr.get_ref() and str(o) != '<Freed Object>')

static func isStray(b: Variant) -> bool:
	# if it's actually fr fr null. instead of, ya'know, a freed obj
	if is_same(b, null):
		return false
	return !is_instance_valid(b) || b.is_queued_for_deletion()

static func trimFloat2(f: float):
	var s = '%.2f' % f
	var result = s.to_float()
	return result

static func trimFloat3(f: float):
	var s = '%.3f' % f
	var result = s.to_float()
	return result
