class_name AkMenu extends CanvasLayer

signal killMe(me: AkMenu)

var isListeningToMenuDwim: bool = true

func onMenuDwim():
	print('inherit me plz - onMenuDwim')

######### Helpers

func spawnSubMenu(sub: AkMenu):
	add_child(sub)
	sub.layer = layer + 1
	isListeningToMenuDwim = false
	sub.killMe.connect(onSubDie)

func onSubDie(sub: AkMenu):
	sub.queue_free()
	await Util.createOneshotTimer(.1, self).timeout
	isListeningToMenuDwim = true		
	focusTopBut()

func getButs() -> Array[Button]:
	var buts: Array[Button]
	buts.assign(Util.findChildren(self, func(n: Node): return n is Button))
	return buts

######### Initialization stuff

func _input(event):
	if isListeningToMenuDwim && event.is_action_pressed('menu-dwim'):
		self.onMenuDwim()

func focusTopBut():
	var buts := getButs()
	if buts.size() == 0:
		# expected in rootMenu
		# L.warn('no top button to focus in self: %s' % self)
		return
	buts[0].grab_focus()

# careful not to include submenu lol. only call in ready() once
func housewarming():
	var buts := getButs()
	for i in range(buts.size()):
		var curr: Button = buts[i]
		var prev: NodePath = buts[wrap(i - 1, 0, buts.size())].get_path()
		var next: NodePath = buts[wrap(i + 1, 0, buts.size())].get_path()
		curr.focus_neighbor_top = prev
		curr.focus_neighbor_left = prev
		curr.focus_neighbor_bottom = next
		curr.focus_neighbor_right = next
