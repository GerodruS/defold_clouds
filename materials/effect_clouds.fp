const int noiseOctaves = 10;
const float softness = 0.2;
const float brightness = 1.0;
//const float curlStrain = 3.0;
const float curlSinRot = 0.14112000806; // sin(curlStrain);
const float curlCosRot = -0.9899924966; // cos(curlStrain);
const mat2 curlRotMat = mat2(curlCosRot, -curlSinRot, curlSinRot, curlCosRot);
const vec4 skyCol = vec4(0.6, 0.8, 1.0, 1.0);

varying mediump vec4 position;
varying mediump vec2 var_texcoord0;
varying mediump vec2 var_texcoord1;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 tint;
uniform lowp vec4 fc_data_1;

float saturate(float num)
{
    return clamp(num, 0.0, 1.0);
}

float noise(vec2 texcoord)
{
    return texture2D(DIFFUSE_TEXTURE, texcoord).r;
}

float fbm(vec2 uv)
{
    float time = fc_data_1.x * 0.00015;

    float f = 0.0;
    float total = 0.0;
    float mul = 0.5;

    for (int i = 0; i < noiseOctaves; ++i)
    {
        f += noise(uv + time - time * mul) * mul;
        total += mul;
        uv *= 3.0;
        uv *= curlRotMat;
        mul *= 0.5;
    }
    return f / total;
}

void main()
{
    float cover = 0.5;

    float bright = cover * brightness + 0.8 * brightness;

    float color1 = fbm(var_texcoord0);
    float color2 = fbm(var_texcoord1);

    float clouds1 = smoothstep(cover, min(cover + softness * 2.0, 1.0), color1);
    float clouds2 = smoothstep(cover, min(cover + softness, 1.0), color2);

    float cloudsFormComb = saturate(clouds1 + clouds2);

    float cloudCol = saturate(saturate(1.0 - color1 * 0.2) * bright);
    vec4 clouds1Color = vec4(cloudCol, cloudCol, cloudCol, 1.0);
    vec4 clouds2Color = mix(clouds1Color, skyCol, 0.25);
    vec4 cloudColComb = mix(clouds1Color, clouds2Color, saturate(clouds2 - clouds1));

	gl_FragColor = mix(skyCol, cloudColComb, cloudsFormComb);
}
