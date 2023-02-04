class_name RandomAudioStreamPlayer
extends AudioStreamPlayer


export var autoremove: bool = false
export var global: bool = false
export var pitch_scale_lower: float = -0.05
export var pitch_scale_upper: float = 0.05
export (Array, AudioStream) var alt_streams: Array = []

var default_pitch_scale: float


func _ready():
	default_pitch_scale = pitch_scale


static func choose_pitch_scale(scale: float, lower: float = 0.0, upper: float = 0.0) -> float:
	return rand_range(scale + lower, scale + upper)


static func choose_stream(_stream: AudioStream, _alt_streams: Array) -> AudioStream:
	if _alt_streams:
		return _alt_streams[randi() % _alt_streams.size()]
	return _stream


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
	pitch_scale = choose_pitch_scale(default_pitch_scale, pitch_scale_lower, pitch_scale_upper)
	stream = choose_stream(stream, alt_streams)

	if global:
		AudioPlayer.play_effect(stream, volume_db, pitch_scale)
	else:
		if autoremove:
			connect("finished", self, "queue_free", [], CONNECT_ONESHOT)
		.play(from_position)
