class_name MyRs extends Resource

func validate():
	pass

func getScriptName() -> String:
	return get_script().get_global_name()

func _to_string() -> String:
	return '%s:%s' % [getScriptName(), resource_path]
