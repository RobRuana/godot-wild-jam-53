class_name RandomAudioStreamPlayer2D
extends AudioStreamPlayer2D


export var autoremove: bool = false
export var pitch_scale_lower: float = -0.05
export var pitch_scale_upper: float = 0.05
export (Array, AudioStream) var alt_streams: Array = []

var default_pitch_scale: float


func _ready():
	default_pitch_scale = pitch_scale


func get_max_length() -> float:
	var max_length: float = 0.0
	if stream:
		max_length = stream.get_length()
	for alt_stream in alt_streams:
		max_length = max(max_length, alt_stream.get_length())
	return max_length


func play_if_stopped(from_position: float = 0.0) -> void:
	if not playing:
		self.play(from_position)


func play_delayed(delay: float, from_position: float = 0.0) -> void:
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	self.play(from_position)


func play(from_position: float = 0.0) -> void:
	var lower: = default_pitch_scale + pitch_scale_lower
	var upper: = default_pitch_scale + pitch_scale_upper
	self.pitch_scale = rand_range(lower, upper)
	if alt_streams:
		self.stream = alt_streams[randi() % alt_streams.size()]
	if autoremove:
		connect("finished", self, "queue_free", [], CONNECT_ONESHOT)
	.play(from_position)
