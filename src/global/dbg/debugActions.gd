# autoloaded as DebugActions
extends Node2D

var windowSizes: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

var currWinSizeIdx := 0 

func toggleWindowSize():
	currWinSizeIdx = (currWinSizeIdx + 1) % windowSizes.size()
	var winSize = windowSizes[currWinSizeIdx]
	# DevHud.showVec('winSize', winSize)
	get_viewport().size = winSize
	# $'/root'.set_content_scale_size(winSize)
	# get_window().size = winSize
	# get_window().content_scale_size = winSize
	# get_viewport().set_size
	# DisplayServer.window_set_size(winSize)
	# get_viewport().size = winSize
	# get_viewport().set_content_scale(Vector2.ONE)
	# get_viewport().size_2d_override = winSize
	# get_viewport().size_2d_override_stretch = true

func reloadScene():
		# this way will reload resources too:
		var scene_path = get_tree().current_scene.scene_file_path
		get_tree().unload_current_scene()
		get_tree().change_scene_to_file(scene_path)

		# alternative:
		# get_tree().reload_current_scene()

func endScene():
		get_tree().quit()

func _input(event: InputEvent):
	if !OS.has_feature("editor"):
		return

	if event.is_action_pressed("dbg-reload-scene"):
		reloadScene()

	if event.is_action_pressed("dbg-end-scene"):
		endScene()
	
	if event.is_action_pressed("dbg-toggle-window-size"):
		toggleWindowSize()
