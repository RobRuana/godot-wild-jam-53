extends UIScreen


const TEXT: String = """
[center]Noumenon by Rob Ruana[/center]

Noumenon was developed over the course of 9 days for the [url=https://itch.io/jam/godot-wild-jam-36]Godot Wild Jam #36[/url].


[font=res://assets/fonts/font_large.tres]Music[/font]
[url=https://freesound.org/people/frankum/sounds/384468/]"Vintage Elecro pop loop"[/url] by Frankum
Licensed under [url=https://creativecommons.org/licenses/by/3.0/]Attribution 3.0 Unported (CC BY 3.0)[/url]


[font=res://assets/fonts/font_large.tres]Sounds[/font]
[url=https://freesound.org/people/patchytherat/sounds/532215/]"meow (hungry).wav"[/url] by patchytherat
Licensed under [url=http://creativecommons.org/publicdomain/zero/1.0/]CC0 1.0 Universal (CC0 1.0)[/url]

[url=https://freesound.org/people/15FPanskaDavid_Matous/sounds/461823/]"meowing_long.wav"[/url] by 15FPanskaDavid_Matous
Licensed under [url=http://creativecommons.org/publicdomain/zero/1.0/]CC0 1.0 Universal (CC0 1.0)[/url]

[url=https://freesound.org/people/InspectorJ/sounds/415209/]"Cat, Screaming, A.wav"[/url] by InspectorJ
Licensed under [url=https://creativecommons.org/licenses/by/3.0/]Attribution 3.0 Unported (CC BY 3.0)[/url]

[url=https://freesound.org/people/Kastenfrosch/sounds/162476/]"gotItem.mp3"[/url] by Kastenfrosch
Licensed under [url=http://creativecommons.org/publicdomain/zero/1.0/]CC0 1.0 Universal (CC0 1.0)[/url]

[url=https://freesound.org/people/magnuswaker/sounds/524950/]"Punch Hard 1"[/url] by magnuswaker
Licensed under [url=http://creativecommons.org/publicdomain/zero/1.0/]CC0 1.0 Universal (CC0 1.0)[/url]

[url=https://freesound.org/people/Kastenfrosch/sounds/162473/]"successful.mp3"[/url] by Kastenfrosch
Licensed under [url=http://creativecommons.org/publicdomain/zero/1.0/]CC0 1.0 Universal (CC0 1.0)[/url]


[font=res://assets/fonts/font_large.tres]Godot Engine[/font]
This game uses Godot Engine, available under the following license:

Copyright (c) 2007-<year> Juan Linietsky, Ariel Manzur. Copyright (c) 2014-<year> Godot Engine contributors.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[font=res://assets/fonts/font_large.tres]FreeType[/font]
Portions of this software are copyright © <year> The FreeType Project (www.freetype.org). All rights reserved.


[font=res://assets/fonts/font_large.tres]ENet[/font]
Copyright (c) 2002-<year> Lee Salzman

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[font=res://assets/fonts/font_large.tres]MBedTLS[/font]
Copyright The Mbed TLS Contributors

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
"""


onready var label: RichTextLabel = $Margin/VBox/Margin/Scroll/RichTextLabel
onready var scroll: ScrollContainer = $Margin/VBox/Margin/Scroll


func _ready():
	var year: = String(OS.get_datetime()["year"])
	label.bbcode_text = TEXT.replace("<year>", year)
	label.connect("meta_clicked", self, "_on_meta_clicked")


func _on_meta_clicked(meta):
	OS.shell_open(meta)
