# autoloaded as P
extends Node

#################### RESOURCES

static var settingsDefault: SettingsRs = load('res://src/rs/data/settings/default.tres')
static var sfxTick: SfxRs = load('res://src/rs/data/sfx/tick.tres')

#################### SCENES

func instPauseMenu() -> PauseMenu:
	return preload('res://src/menu/pauseMenu.tscn').instantiate()

func instSettingsMenu() -> SettingsMenu:
	return preload('res://src/menu/settingsMenu.tscn').instantiate()
