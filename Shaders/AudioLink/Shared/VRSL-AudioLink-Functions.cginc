
#define IF(a, b, c) lerp(b, c, step((fixed) (a), 0));
#include "Assets/AudioLink/Shaders/AudioLink.cginc"

float4 RGBtoHSV(in float3 RGB)
{
    float3 HSV = 0;
    HSV.z = max(RGB.r, max(RGB.g, RGB.b));
    float M = min(RGB.r, min(RGB.g, RGB.b));
    float C = HSV.z - M;
    if (C != 0)
    {
        HSV.y = C / HSV.z;
        float3 Delta = (HSV.z - RGB) / C;
        Delta.rgb -= Delta.brg;
        Delta.rg += float2(2,4);
        if (RGB.r >= HSV.z)
            HSV.x = Delta.b;
        else if (RGB.g >= HSV.z)
            HSV.x = Delta.r;
        else
            HSV.x = Delta.g;
        HSV.x = frac(HSV.x / 6);
    }
    return float4(HSV,1);
}
float3 Hue(float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B));
}
float4 HSVtoRGB(in float3 HSV)
{
    return float4(((Hue(HSV.x) - 1) * HSV.y + 1) * HSV.z,1);
}

inline float AudioLinkLerp3_g5( int Band, float Delay )
{
    return AudioLinkLerp( ALPASS_AUDIOLINK + float2( Delay, Band ) ).r;
}
uint checkPanInvertY()
{
    return (uint) UNITY_ACCESS_INSTANCED_PROP(Props, _PanInvert);
}
uint checkTiltInvertZ()
{
    return (uint) UNITY_ACCESS_INSTANCED_PROP(Props, _TiltInvert);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float4 GetTextureSampleColor()
{
    float4 rawColor = tex2Dlod(_SamplingTexture, float4(UNITY_ACCESS_INSTANCED_PROP(Props, _TextureColorSampleX), UNITY_ACCESS_INSTANCED_PROP(Props, _TextureColorSampleY), 0, 0));
    // Exceed Custom
    #if defined(_USE_SAMPLING_TEXTURE_BRIGHTNESS)
    return rawColor;
    #endif
    float4 h = RGBtoHSV(rawColor.rgb);
    h.z = 1.0;
    return(HSVtoRGB(h));
}

uint isStrobe()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_EnableStrobe);
}

uint instancedGOBOSelection()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_ProjectionSelection);
}

float getOffsetX()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_FixtureRotationX);
}

float getOffsetY()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_FixtureBaseRotationY);
}

float getStrobeFreq()

{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_StrobeFreq);
}


float getConeWidth()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_ConeWidth) - 1.25;
}

uint isGOBOSpin()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props,_EnableSpin);
}

float getConeLength()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _ConeLength);
}
float getMaxConeLength()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _MaxConeLength);
}

float getGlobalIntensity()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _GlobalIntensity);
}

float getFinalIntensity()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _FinalIntensity);
}

///////////////////////////////////////////////////////////////////////////////////////////
float getNumBands()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _NumBands);
}

float getBand()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _Band);
}

float getDelay()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _Delay);
}

float getBandMultiplier()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _BandMultiplier);
}

float checkIfAudioLink()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _EnableAudioLink);
}

uint checkIfColorChord()
{
    return UNITY_ACCESS_INSTANCED_PROP(Props, _EnableColorChord);
}
////////////////////////////////////////////////////////////////////////////////////////////


float GetAudioReactAmplitude()
{
    if(checkIfAudioLink() > 0)
    {
        return AudioLinkLerp3_g5(getBand(), getDelay()) * getBandMultiplier();
    }
    else
    {
        return 1;
    }
}

float4 GetColorChordLight()
{
    return AudioLinkData(ALPASS_CCLIGHTS).rgba;
}

float4 getEmissionColor()
{
    float4 emissiveColor = UNITY_ACCESS_INSTANCED_PROP(Props,_Emission);
    float4 col =  IF(UNITY_ACCESS_INSTANCED_PROP(Props,_EnableColorTextureSample) > 0,((emissiveColor.r + emissiveColor.g + emissiveColor.b)/3.0) * GetTextureSampleColor(),emissiveColor);
    return IF(checkIfColorChord() == 1, GetColorChordLight(), col);
}