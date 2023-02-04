extends Node


signal initialized

var is_initialized: bool = false

func once_initialized(target: Object, method: String):
	if is_initialized:
		target.call_deferred(method)
	else:
		connect("initialized", target, method, [], CONNECT_ONESHOT)


const LETTER_RECTS: Dictionary = {"+": Rect2(), "?": Rect2()}
const LETTER_TEXTURES: Dictionary = {}
const LETTER_NAMES: Dictionary = {
	"?": "question",
	"+": "plus",
	"=": "equals",
	"-": "dash",
	" ": "dash",
	"_": "underscore",
	".": "period",
	"!": "exclamation",
	"$": "dollar",
	"#": "hash",
	"@": "at",
	"%": "percent",
	"^": "caret",
	"~": "tilde",
	"`": "backtick",
	"/": "slash",
	"\\\\": "backslash",
	"&": "ampersand",
	"*": "asterisk",
	"(": "paren_l",
	")": "paren_r",
	"{": "brace_l",
	"}": "brace_r",
	"[": "bracket_l",
	"]": "bracket_r",
	"0": "0",
	"1": "1",
	"2": "2",
	"3": "3",
	"4": "4",
	"5": "5",
	"6": "6",
	"7": "7",
	"8": "8",
	"9": "9",
}
export var LEVEL_LETTERS: PoolStringArray = [
	"Growth",
	"Godot",
	"Wild",
	"Game Jam",
	"Uncontrollable",
	"Noumenon",
	"WIN!WIN!WIN!",
]


func _init():
	pause_mode = PAUSE_MODE_PROCESS


func _ready():
	for word in LEVEL_LETTERS:
		for letter in word:
			letter = letter.replace(" ", "_").strip_edges()
			if letter.empty():
				continue
			LETTER_RECTS[letter] = Rect2()

	for letter in LETTER_RECTS:
		var letter_name: String = get_letter_name(letter)
		var path: = "res://assets/images/typewriter/" + letter_name + ".png"
		if not ResourceLoader.exists(path):
			path = "res://assets/images/typewriter/question.png"
		LETTER_TEXTURES[letter] = load(path)
		LETTER_RECTS[letter] = LETTER_TEXTURES[letter].get_data().get_used_rect()

	is_initialized = true
	emit_signal("initialized")


func get_letter_rect(letter: String) -> Rect2:
	if letter in LETTER_RECTS:
		return LETTER_RECTS[letter]
	return Rect2()


func get_letter_texture(letter: String) -> Texture:
	if letter in LETTER_TEXTURES:
		return LETTER_TEXTURES[letter]
	return LETTER_TEXTURES["?"]


func get_letter_name(letter: String) -> String:
	letter = letter.replace(" ", "_").strip_edges()
	if letter.empty():
		return ""
	elif letter in LETTER_NAMES:
		return LETTER_NAMES[letter]
	else:
		var is_upper: bool = letter == letter.to_upper()
		return letter.to_lower() + "_" + ("upper" if is_upper else "lower")
