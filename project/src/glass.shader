shader_type canvas_item;

// Heartfelt - by Martijn Steinrucken aka BigWings - 2017
// Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// I revisited the rain effect I did for another shader. This one is better in multiple ways:
// 1. The glass gets foggy.
// 2. Drops cut trails in the fog on the glass.
// 3. The amount of rain is adjustable (with Mouse.y)

// To have full control over the rain, uncomment the HAS_HEART define

// A video of the effect can be found here:
// https://www.youtube.com/watch?v=uiF5Tlw22PI&feature=youtu.be

// Music - Alone In The Dark - Vadim Kiselev
// https://soundcloud.com/ahmed-gado-1/sad-piano-alone-in-the-dark
// Rain sounds:
// https://soundcloud.com/elirtmusic/sleeping-sound-rain-and-thunder-1-hours

//#define S(a, b, t) smoothstep(a, b, t)
//#define CHEAP_NORMALS
//#define HAS_HEART
//#define USE_POST_PROCESSING


uniform float fade_in_duration = 10.0;
uniform float lightning: hint_range(-1.0, 1.0) = 0.0;
uniform sampler2D background_texture;


vec3 N13(float p) {
	// from DAVE HOSKINS
	vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.11369, 0.13787));
	p3 += dot(p3, p3.yzx + 19.19);
	return fract(vec3((p3.x + p3.y) * p3.z, (p3.x + p3.z) * p3.y, (p3.y + p3.z) * p3.x));
}


vec4 N14(float t) {
	return fract(sin(t * vec4(123.0, 1024.0, 1456.0, 264.0)) * vec4(6547.0, 345.0, 8799.0, 1564.0));
}


float N(float t) {
	return fract(sin(t * 12345.564) * 7658.76);
}


float Saw(float b, float t) {
	return smoothstep(0.0, b, t) * smoothstep(1.0, b, t);
}


vec2 DropLayer2(vec2 uv, float t) {
	uv.y = -uv.y;
	vec2 orig_uv = uv;

	uv.y += t * 0.75;
	vec2 a = vec2(6.0, 1.0);
	vec2 grid = a * 2.0;
	vec2 id = floor(uv * grid);

	float colShift = N(id.x);
	uv.y += colShift;

	id = floor(uv * grid);
	vec3 n = N13(id.x * 35.2 + id.y * 2376.1);
	vec2 st = fract(uv * grid) - vec2(0.5, 0);

	float x = n.x - 0.5;

	float y = orig_uv.y * 20.0;
	float wiggle = sin(y + sin(y));
	x += wiggle * (0.5 - abs(x)) * (n.z - 0.5);
	x *= 0.7;
	float ti = fract(t + n.z);
	y = (Saw(0.85, ti) - 0.5) * 0.9 + 0.5;
	vec2 p = vec2(x, y);

	float d = length((st - p) * a.yx);

	float mainDrop = smoothstep(0.4, 0.0, d);

	float r = sqrt(smoothstep(1.0, y, st.y));
	float cd = abs(st.x - x);
	float trail = smoothstep(0.23 * r, 0.15 * r * r, cd);
	float trailFront = smoothstep(-0.02, 0.02, st.y - y);
	trail *= trailFront * r * r;

	y = orig_uv.y;
	float trail2 = smoothstep(0.2 * r, 0.0, cd);
	float droplets = max(0.0, (sin(y * (1.0 - y) * 120.0) - st.y)) * trail2 * trailFront * n.z;
	y = fract(y * 10.0) + (st.y - 0.5);
	float dd = length(st - vec2(x, y));
	droplets = smoothstep(0.3, 0.0, dd);
	float m = mainDrop + droplets * r * trailFront;

	//m += st.x>a.y * 0.45 || st.y>a.x * 0.165 ? 1.2 : 0.0;
	return vec2(m, trail);
}


float StaticDrops(vec2 uv, float t) {
	uv *= 40.0;

	vec2 id = floor(uv);
	uv = fract(uv) - 0.5;
	vec3 n = N13(id.x * 107.45 + id.y * 3543.654);
	vec2 p = (n.xy - 0.5) * 0.7;
	float d = length(uv - p);

	float fade = Saw(0.025, fract(t + n.z));
	float c = smoothstep(0.3, 0.0, d) * fract(n.z * 10.0) * fade;
	return c;
}


vec2 Drops(vec2 uv, float t, float l0, float l1, float l2) {
	float s = StaticDrops(uv, t) * l0;
	vec2 m1 = DropLayer2(uv, t) * l1;
	vec2 m2 = DropLayer2(uv * 1.85, t) * l2;

	float c = s + m1.x + m2.x;
	c = smoothstep(0.3, 1.0, c);

	return vec2(c, max(m1.y * l0, m2.y * l1));
}


// Generic algorithm to desaturate images used in most game engines
vec4 generic_desaturate(vec4 color, float factor) {
	vec3 lum = vec3(0.299, 0.587, 0.114);
	vec3 gray = vec3(dot(lum, color.rgb));
	return vec4(mix(color.rgb, gray, factor), color.a);
}


// Algorithm employed by photoshop to desaturate the input
vec4 photoshop_desaturate(vec4 color, float factor) {
	float bw = (min(color.r, min(color.g, color.b)) + max(color.r, max(color.g, color.b))) * 0.5;
	vec3 gray = vec3(bw, bw, bw);
	return vec4(mix(color.rgb, gray, factor), color.a);
}


void fragment() {
	// vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
	// vec2 UV = fragCoord.xy / iResolution.xy;
	// vec3 M = iMouse.xyz / iResolution.xyz;
	// float T = iTime + M.x * 2.0;

	// #ifdef HAS_HEART
	// T = mod(iTime, 102.0);
	// T = mix(T, M.x * 102.0, M.z>0.0?1.0:0.0);
	// #endif

	float T = TIME;
	float t = T * 0.2;

	// float rainAmount = iMouse.z>0.0 ? M.y : sin(T * 0.05) * 0.3+0.7;
	float rainAmount = sin(T * 0.05) * 0.3 + 0.7;

	float maxBlur = mix(3.0, 6.0, rainAmount);
	float minBlur = 2.0;

	// #ifdef HAS_HEART
	// story = smoothstep(0.0, 70.0, T);

	// t = min(1.0, T/70.0);						// remap drop time so it goes slower when it freezes
	// t = 1.0-t;
	// t = (1.0-t * t) * 70.0;

	// float zoom= mix(0.3, 1.2, story);		// slowly zoom out
	// uv *=zoom;
	// minBlur = 4.0+smoothstep(0.5, 1.0, story) * 3.0;		// more opaque glass towards the end
	// maxBlur = 6.0+smoothstep(0.5, 1.0, story) * 1.5;

	// vec2 hv = uv-vec2(0.0, -0.1);				// build heart
	// hv.x *= 0.5;
	// float s = smoothstep(110.0, 70.0, T);				// heart gets smaller and fades towards the end
	// hv.y-=sqrt(abs(hv.x)) * 0.5 * s;
	// heart = length(hv);
	// heart = smoothstep(0.4 * s, 0.2 * s, heart) * s;
	// rainAmount = heart;						// the rain is where the heart is

	// maxBlur-=heart;							// inside the heart slighly less foggy
	// uv *= 1.5;								// zoom out a bit more
	// t *= 0.25;
	// #else

	//	float zoom = -cos(T * 0.2);
	float zoom = 1.0;
	vec2 uv = UV;
	uv *= 0.7 + zoom * 0.3;

	// #endif

	vec2 custom_uv = (UV - 0.5) * (0.9 + zoom * 0.1) + 0.5;

	// float staticDrops = smoothstep(-0.5, 1.0, rainAmount) * 2.0;
	// float layer1 = smoothstep(0.25, 0.75, rainAmount);
	// float layer2 = smoothstep(0.0, 0.5, rainAmount);
	float staticDrops = 0.0;
	float layer1 = 0.0;
	float layer2 = 0.0;


	vec2 c = Drops(uv, t, staticDrops, layer1, layer2);
// #ifdef CHEAP_NORMALS
	// cheap normals (3x cheaper, but 2 times shittier ;))
	vec2 n = vec2(dFdx(c.x), dFdy(c.x));
// #else
	// expensive normals
	// vec2 e = vec2(0.001, 0.0);
	// float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
	// float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
	// vec2 n = vec2(cx - c.x, cy - c.x);
// #endif

	float focus = mix(maxBlur - c.y, minBlur, smoothstep(0.1, 0.2, c.x));
	vec3 col = generic_desaturate(textureLod(TEXTURE, custom_uv + n, focus), 1.0).rgb;


	// #ifdef USE_POST_PROCESSING
	t = (T + 3.0) * 0.5; // make time sync with first lightning

	// subtle color shift
	// float colFade = sin(t * 0.2) * 0.5 + 0.5;
	//col *= mix(vec3(1.0), vec3(0.8, 0.9, 1.3), colFade);

	// fade in at the start
	float fade = smoothstep(0.0, fade_in_duration, T);

	// lightning
	// float lightning = sin(t * sin(t * 10.0)); // lighting flicker
	// lightning *= pow(max(0.0, sin(t + sin(t))), 10.0); // lightning flash
	// col *= 1.0 + lightning * fade; // composite flicker and flash
	col *= 1.0 + lightning * fade;

	// vignette
	col *= 1.0 - dot(UV - 0.5, UV);

	// #ifdef HAS_HEART
	// 	col = mix(pow(col, vec3(1.2)), col, heart);
	// 	fade *= smoothstep(102.0, 97.0, T);
	// #endif

	col *= fade; // composite start and end fade
	// #endif

	COLOR = vec4(col, 1.0);
}
