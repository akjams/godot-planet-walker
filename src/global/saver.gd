# autoloaded as Saver
extends Node

const gameVersion = '0.0.1'
const dir = 'res://src/saves/0.0.1/'

var settingsRsPath = dir.path_join('settings.tres')

func ensureDirExists():
	DirAccess.make_dir_recursive_absolute(dir)

func _ready() -> void:
	ensureDirExists()

func saveSettingsRs(settings: SettingsRs):
	ResourceSaver.save(settings, settingsRsPath)

func loadSettingsRs() -> SettingsRs:
	if not FileAccess.file_exists(settingsRsPath):
		return P.settingsDefault
	var result = load(settingsRsPath)
	return result.duplicate(true)

func eraseSettingsRs():
	ResourceSaver.save(P.settingsDefault, settingsRsPath)
