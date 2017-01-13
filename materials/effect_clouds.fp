varying mediump vec4 position;
varying mediump vec2 var_texcoord0;

uniform lowp sampler2D DIFFUSE_TEXTURE;
uniform lowp vec4 tint;
uniform lowp vec4 data_1;

const float timeScale = 10.0;
const int noiseOctaves = 10;
const float softness = 0.2;
const float brightness = 1.0;
//const float curlStrain = 3.0;
const float curlSinRot = 0.14112000806; // sin(curlStrain);
const float curlCosRot = -0.9899924966; // cos(curlStrain);
const mat2 curlRotMat = mat2(curlCosRot, -curlSinRot, curlSinRot, curlCosRot);
const float cloudScale = 0.5;

float saturate(float num)
{
    return clamp(num, 0.0, 1.0);
}

float noise(vec2 texcoord)
{
    return texture2D(DIFFUSE_TEXTURE, texcoord.xy).r;
}

vec2 rotate(vec2 uv)
{
    uv = uv + noise(uv*0.2)*0.005;
    return uv * curlRotMat;
}

float fbm(vec2 uv)
{
    float iGlobalTime = data_1.x;

    float f = 0.0;
    float total = 0.0;
    float mul = 0.5;
    mat2 rotMat = mat2(0.0, -1.0, 1.0, 0.0);

    for (int i = 0; i < noiseOctaves; ++i)
    {
        f += noise(uv + iGlobalTime * 0.00015 * timeScale * (1.0 - mul)) * mul;
        total += mul;
        uv *= 3.0;
        uv = rotate(uv);
        mul *= 0.5;
    }
    return f / total;
}

void main()
{
    float iGlobalTime = data_1.x;

    vec2 uv = var_texcoord0.xy * 256.0 / (40000.0 * cloudScale);

    float cover = 0.5;

    float bright = brightness*(1.8-cover);

    float color1 = fbm(uv-0.5+iGlobalTime*0.00004*timeScale);
    float color2 = fbm(uv-10.5+iGlobalTime*0.00002*timeScale);

    float clouds1 = smoothstep(1.0-cover,min((1.0-cover)+softness*2.0,1.0),color1);
    float clouds2 = smoothstep(1.0-cover,min((1.0-cover)+softness,1.0),color2);

    float cloudsFormComb = saturate(clouds1+clouds2);

    vec4 skyCol = vec4(0.6,0.8,1.0,1.0);
    float cloudCol = saturate(saturate(1.0-pow(color1,1.0)*0.2)*bright);
    vec4 clouds1Color = vec4(cloudCol,cloudCol,cloudCol,1.0);
    vec4 clouds2Color = mix(clouds1Color,skyCol,0.25);
    vec4 cloudColComb = mix(clouds1Color,clouds2Color,saturate(clouds2-clouds1));

	gl_FragColor = mix(skyCol, cloudColComb, cloudsFormComb);
}
