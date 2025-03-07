class_name PauseMenu extends AkMenu

func _ready():
	housewarming()
	focusTopBut()

func onMenuDwim():
	killMe.emit(self)

func onResumePressed() -> void:
	killMe.emit(self)

func onSettingsPressed() -> void:
	spawnSubMenu(P.instSettingsMenu())

func onRestartPressed() -> void:
	DebugActions.reloadScene()

func onQuitPressed() -> void:
	DebugActions.endScene()
