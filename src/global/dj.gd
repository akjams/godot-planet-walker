# autoloaded as "DJ"
extends Node

var groupsPlaying: Set = Set.forVariants(TYPE_STRING)

const effectivelyMute = -80

func playSfxMono(sfxRs: SfxRs) -> void:
	if sfxRs == null:
		# That's fine. convenient code.
		return
	if groupsPlaying.has(sfxRs.group()):
		return
	groupsPlaying.add(sfxRs.group())
	var asp := AudioStreamPlayer.new()
	asp.stream = sfxRs.stream
	var volumePercent = Saver.loadSettingsRs().sfxVolumePercent
	asp.volume_db = linear_to_db(volumePercent) + sfxRs.baseVolDb
	add_child(asp)
	asp.play()
	asp.finished.connect(func():
			asp.queue_free()
			groupsPlaying.remove(sfxRs.group())
	)


func playSfx3d(stream: AudioStream, theParent: Node3D):
	var asp := AudioStreamPlayer3D.new()
	asp.stream = stream
	var volumePercent = Saver.loadSettingsRs().sfxVolumePercent
	asp.volume_db = linear_to_db(volumePercent)
	theParent.add_child(asp)
	asp.play()
	asp.finished.connect(func():
			asp.queue_free()
	)
