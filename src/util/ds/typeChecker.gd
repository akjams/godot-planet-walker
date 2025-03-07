class_name TypeChecker extends RefCounted

# Godot uses a three-level type system:
# Variant types, for example TYPE_INT. You can get this via typeof().
# Native types (only for TYPE_OBJECT), for example Node. You can get this via get_class() and check it via is_class() (with inheritance).
# Script types (only for TYPE_OBJECT, optional). You can get this via get_script().

# returns null if type is
func isType(_x: Variant) -> Result:
	assert(false, 'isType is abstract')
	return null

func duplicate() -> TypeChecker:
	assert(false, 'override')
	return null

class Result extends RefCounted:
	var result: bool
	var message: String

class VariantTypeChecker extends TypeChecker:
	var varTyp: Variant.Type
	func _init(varType: Variant.Type):
		varTyp = varType

	func isType(x: Variant) -> Result:
		var res := Result.new()
		if typeof(x) == varTyp:
			res.result = true
			return res
		
		res.result = false
		res.message = 'expectedType:gotType:val %s:%s:%s' % [varTyp, typeof(x), x]
		return res

class NativeTypeChecker extends TypeChecker:
	var builtInClassName: String
	func _init(theBuiltInClassName: String) -> void:
		builtInClassName = theBuiltInClassName

	func isType(x: Variant) -> Result:
		var res := Result.new()
		if typeof(x) != TYPE_OBJECT:
			res.result = false
			res.message = 'expectedType:gotType:val %s:%s:%s' % [builtInClassName, typeof(x), x]
			return res

		if x.is_class(builtInClassName):
			res.result = true
			return res
		
		res.result = false
		res.message = 'expectedType:gotType:val %s:%s:%s' % [builtInClassName, x.get_class(), x]
		return res
	
	func duplicate() -> NativeTypeChecker:
		return NativeTypeChecker.new(builtInClassName)

class CustomTypeChecker extends TypeChecker:
	var scr: GDScript
	func _init(theScript: GDScript) -> void:
		scr = theScript

	func isType(x: Variant) -> Result:
		var res := Result.new()
		if typeof(x) != TYPE_OBJECT:
			res.result = false
			res.message = 'expectedType:gotType:val %s:%s:%s' % [scr.get_path(), typeof(x), x]
			return res

		if is_instance_of(x, scr):
			res.result = true
			return res
		
		res.result = false
		res.message = 'expectedType:gotType:val %s:%s:%s' % [scr.get_path(), x.get_script(), x]
		return res
	
	func duplicate() -> CustomTypeChecker:
		return CustomTypeChecker.new(scr)
