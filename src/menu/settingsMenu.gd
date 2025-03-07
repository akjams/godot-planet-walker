class_name SettingsMenu extends AkMenu

@export var sfxAmt: Label
@export var sfxSlider: HSlider

var settingsRs: SettingsRs

var throttledSfxChange: Throttle

func onMenuDwim():
	killMe.emit(self)

func _ready():
	throttledSfxChange = Throttle.new(onSfxSliderChange, 50, self)
	sfxSlider.value_changed.connect(onSfxSliderChangeThrottleWrapper)

	settingsRs = Saver.loadSettingsRs()
	display()

func display():
	sfxAmt.text = '%d%%' % [settingsRs.sfxVolumePercent * 100]
	sfxSlider.value = settingsRs.sfxVolumePercent

func save():
	Saver.saveSettingsRs(settingsRs)

func onSfxSliderChangeThrottleWrapper(val: float) -> void:
	throttledSfxChange.tryCall([val])

func onSfxSliderChange(value: float) -> void:
	DJ.playSfxMono(P.sfxTick)
	value = Util.trimFloat2(value)
	settingsRs.sfxVolumePercent = value
	display()
	save()
