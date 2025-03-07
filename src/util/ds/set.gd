class_name Set extends RefCounted

var data: Dictionary = {}
var tc: TypeChecker

signal err(msg: String)

func error(s: String):
	push_error('[Set]: %s' % s)
	err.emit(s)

static func forVariants(type: Variant.Type) -> Set:
	var typeChecker := TypeChecker.VariantTypeChecker.new(type)
	return Set.new(typeChecker)

static func forNativeObjects(builtInClassName: String) -> Set:
	var typeChecker := TypeChecker.NativeTypeChecker.new(builtInClassName)
	return Set.new(typeChecker)

static func forCustomObjects(gdScript: GDScript) -> Set:
	if gdScript == null:
		push_error('[Set] null gdScript')
		return null
	var typeChecker := TypeChecker.CustomTypeChecker.new(gdScript)
	return Set.new(typeChecker)

func _init(typeChecker: TypeChecker = TypeChecker.VariantTypeChecker.new(TYPE_FLOAT)) -> void:
	tc = typeChecker

func add(element: Variant) -> bool:
	var tcRes := tc.isType(element)
	if tcRes.result == false:
		error(tcRes.message)
		return false
	if not data.has(element):
		data[element] = true
		return true
	return false

func addAll(els: Array[Variant]) -> bool:
	var res = false
	for el in els:
		res = res || add(el)
	return res

func remove(element: Variant) -> bool:
	if data.has(element):
		data.erase(element)
		return true
	return false

func has(element: Variant) -> bool:
	var tcRes := tc.isType(element)
	if tcRes.result == false:
		error(tcRes.message)
		return false
	return data.has(element)

func intersectAr(oth: Array) -> Array:
	return oth.filter(func(o): return has(o))

func filter(predicate: Callable) -> Set:
	var fels: Array[Variant] = []
	for el in elements():
		if predicate.call(el):
			fels.append(el)
	
	var result = Set.new(tc)
	result.addAll(fels)
	return result

func elements() -> Array:
	return data.keys()

func size() -> int:
	return data.size()

func isEmpty() -> bool:
	return data.size() == 0

func clear() -> void:
	data.clear()
