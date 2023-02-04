import os
import string



CMD = "convert -background '#ffffff00' -fill white -font {font} -size 256x256 -pointsize 128 -gravity center 'label:{label}' {out_dir}/{filename}.png"


def generate(out_dir, font, letter):
    os.system(CMD.format(font=font, label=letter.lower(), out_dir=out_dir, filename=f"{letter.lower()}_lower"))
    os.system(CMD.format(font=font, label=letter.upper(), out_dir=out_dir, filename=f"{letter.lower()}_upper"))


typefaces = {
    "typewriter": "~/.magick/fonts/AmericanTypewriter_01.ttf",
    # "impact": "~/.magick/fonts/Impact.ttf",
}


for (out_dir, font) in typefaces.items():
    os.makedirs(out_dir, exist_ok=True)
    for letter in string.ascii_lowercase:
        generate(out_dir, font, letter)
    os.system(CMD.format(font=font, label="?", out_dir=out_dir, filename="question"))
    os.system(CMD.format(font=font, label="+", out_dir=out_dir, filename="plus"))
    os.system(CMD.format(font=font, label="=", out_dir=out_dir, filename="equals"))
    os.system(CMD.format(font=font, label="-", out_dir=out_dir, filename="dash"))
    os.system(CMD.format(font=font, label="_", out_dir=out_dir, filename="underscore"))
    os.system(CMD.format(font=font, label=".", out_dir=out_dir, filename="period"))
    os.system(CMD.format(font=font, label="!", out_dir=out_dir, filename="exclamation"))
    os.system(CMD.format(font=font, label="$", out_dir=out_dir, filename="dollar"))
    os.system(CMD.format(font=font, label="#", out_dir=out_dir, filename="hash"))
    os.system(CMD.format(font=font, label="@", out_dir=out_dir, filename="at"))
    os.system(CMD.format(font=font, label="%", out_dir=out_dir, filename="percent"))
    os.system(CMD.format(font=font, label="^", out_dir=out_dir, filename="caret"))
    os.system(CMD.format(font=font, label="~", out_dir=out_dir, filename="tilde"))
    os.system(CMD.format(font=font, label="`", out_dir=out_dir, filename="backtick"))
    os.system(CMD.format(font=font, label="/", out_dir=out_dir, filename="slash"))
    os.system(CMD.format(font=font, label="\\\\", out_dir=out_dir, filename="backslash"))
    os.system(CMD.format(font=font, label="&", out_dir=out_dir, filename="ampersand"))
    os.system(CMD.format(font=font, label="*", out_dir=out_dir, filename="asterisk"))
    os.system(CMD.format(font=font, label="(", out_dir=out_dir, filename="paren_l"))
    os.system(CMD.format(font=font, label=")", out_dir=out_dir, filename="paren_r"))
    os.system(CMD.format(font=font, label="{", out_dir=out_dir, filename="brace_l"))
    os.system(CMD.format(font=font, label="}", out_dir=out_dir, filename="brace_r"))
    os.system(CMD.format(font=font, label="[", out_dir=out_dir, filename="bracket_l"))
    os.system(CMD.format(font=font, label="]", out_dir=out_dir, filename="bracket_r"))
    os.system(CMD.format(font=font, label="0", out_dir=out_dir, filename="0"))
    os.system(CMD.format(font=font, label="1", out_dir=out_dir, filename="1"))
    os.system(CMD.format(font=font, label="2", out_dir=out_dir, filename="2"))
    os.system(CMD.format(font=font, label="3", out_dir=out_dir, filename="3"))
    os.system(CMD.format(font=font, label="4", out_dir=out_dir, filename="4"))
    os.system(CMD.format(font=font, label="5", out_dir=out_dir, filename="5"))
    os.system(CMD.format(font=font, label="6", out_dir=out_dir, filename="6"))
    os.system(CMD.format(font=font, label="7", out_dir=out_dir, filename="7"))
    os.system(CMD.format(font=font, label="8", out_dir=out_dir, filename="8"))
    os.system(CMD.format(font=font, label="9", out_dir=out_dir, filename="9"))
