# autoloaded as L
extends Node

func info(s: Variant):
	print(str(s))

func warn(s: Variant):
	push_warning(str(s))

func err(s: Variant):
	push_error(str(s))
