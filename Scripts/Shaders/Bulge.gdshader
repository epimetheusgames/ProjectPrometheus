shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float distortion_amm = 0.0f;
uniform float static_scale = 0.0f;

vec2 distort(vec2 r, float alpha)
{
    return r * -alpha * (dot(r, r));
}

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
uint hash( uint x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

// Construct a float with half-open range [0:1] using low 23 bits.
// All zeroes yields 0.0, all ones yields the next smallest representable value below 1.0.
float floatConstruct( uint m ) {
    const uint ieeeMantissa = 0x007FFFFFu; // binary32 mantissa bitmask
    const uint ieeeOne      = 0x3F800000u; // 1.0 in IEEE binary32

    m &= ieeeMantissa;                     // Keep only mantissa bits (fractional part)
    m |= ieeeOne;                          // Add fractional part to 1.0

    float  f = uintBitsToFloat( m );       // Range [1:2]
    return f - 1.0;                        // Range [0:1]
}

// Pseudo-random value in half-open range [0:1].
float random( float x ) { return floatConstruct(hash(floatBitsToUint(x))); }


void fragment() {
	vec2 uv = SCREEN_UV;
	float scale = 1.0f;
	uv.x -= 0.5f;
	uv.y -= 0.5f;
	uv *= scale;
	uv.x += 0.5f;
	uv.y += 0.5f;
    vec2 v = (uv - vec2(.5, .5));
    
    //float amount = m.x;
    float amount = (sin(-distortion_amm) * .5 ) ;
        
    uv = uv + distort(v, amount);
	vec4 color = textureLod(screen_texture, uv, 0.0);
	color.x += (random(uv.x * uv.y * color.x * random(uv.x * uv.y)) - 0.5) * static_scale;
	color.y += (random(uv.x * uv.y * color.y * random(uv.x * uv.y)) - 0.5) * static_scale;
	color.z += (random(uv.x * uv.y * color.z * random(uv.x * uv.y)) - 0.5) * static_scale;
	COLOR = color;
}