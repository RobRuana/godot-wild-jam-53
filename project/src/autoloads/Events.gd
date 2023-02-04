extends Node


signal player_health_changed(player, value, old_value)
signal player_zoom_changed(player, value, old_value)
signal player_zoom_recovery(player, value)
signal player_zoom(player, value)
signal player_death(player)

signal letter_inside_goal(letter)

signal level_completed(level)

signal game_state_changed(value, old_value)
signal game_reset()

signal camera_shake(strength, decay_delay, decay)

signal add_effects_node(node, autoremove, autoremove_delay, fade_duration)


var signal_once: = {}


func _init():
	for signal_info in self.get_signal_list():
		var arg_count: int = signal_info.args.size()
		if arg_count == 0:
			connect(signal_info.name, self, "_on_signal_once_0", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 1:
			connect(signal_info.name, self, "_on_signal_once_1", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 2:
			connect(signal_info.name, self, "_on_signal_once_2", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 3:
			connect(signal_info.name, self, "_on_signal_once_3", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 4:
			connect(signal_info.name, self, "_on_signal_once_4", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 5:
			connect(signal_info.name, self, "_on_signal_once_5", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 6:
			connect(signal_info.name, self, "_on_signal_once_6", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 7:
			connect(signal_info.name, self, "_on_signal_once_7", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 8:
			connect(signal_info.name, self, "_on_signal_once_8", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 9:
			connect(signal_info.name, self, "_on_signal_once_9", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 10:
			connect(signal_info.name, self, "_on_signal_once_10", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 11:
			connect(signal_info.name, self, "_on_signal_once_11", [signal_info.name], CONNECT_ONESHOT)
		elif arg_count == 12:
			connect(signal_info.name, self, "_on_signal_once_12", [signal_info.name], CONNECT_ONESHOT)



# All of these _on_signal functions are needed because GDScript doesn't support variadic arguments
func _on_signal_once_0(signal_name):
	if signal_name:
		signal_once[signal_name] = []


func _on_signal_once_1(a1=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1]


func _on_signal_once_2(a1=null, a2=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2]


func _on_signal_once_3(a1=null, a2=null, a3=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3]


func _on_signal_once_4(a1=null, a2=null, a3=null, a4=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4]


func _on_signal_once_5(a1=null, a2=null, a3=null, a4=null, a5=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5]


func _on_signal_once_6(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6]


func _on_signal_once_7(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, a7=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6, a7]


func _on_signal_once_8(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, a7=null, a8=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6, a7, a8]


func _on_signal_once_9(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, a7=null, a8=null, a9=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6, a7, a8, a9]


func _on_signal_once_10(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, a7=null, a8=null, a9=null, a10=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10]


func _on_signal_once_11(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, a7=null, a8=null, a9=null, a10=null, a11=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11]


func _on_signal_once_12(a1=null, a2=null, a3=null, a4=null, a5=null, a6=null, a7=null, a8=null, a9=null, a10=null, a11=null, a12=null, signal_name=""):
	if signal_name:
		signal_once[signal_name] = [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12]


func reset_once():
	signal_once.clear()


func once(signal_name: String, target: Object, method: String, binds: Array = []):
	if signal_once.has(signal_name):
		var args: Array = binds + signal_once[signal_name]
		# Needed because Godot does not have a native callv_deferred implementation
		call_deferred("_do_callv_deferred", target, method, args)
	else:
		connect(signal_name, target, method, binds, CONNECT_ONESHOT)


func _do_callv_deferred(target: Object, method: String, binds: Array = []):
	if is_instance_valid(target):
		target.callv(method, binds)
