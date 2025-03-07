# Autoloaded as RootMenu
# Listens for ESC. Spawns pause menu.
extends AkMenu

func _ready():
	pass

func onMenuDwim():
	spawnSubMenu(P.instPauseMenu())
