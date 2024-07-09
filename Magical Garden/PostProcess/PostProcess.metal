//
//  PostProcess.metal
//  Magical Garden
//
//  Created by Jacques André Kerambrun on 07/07/24.
//


#include <metal_stdlib>
using namespace metal;

constant int filterIndex [[function_constant(0)]];
constant float time [[function_constant(1)]];

float4 enhanceColor(float4 color) {
    float3 gray = float3(0.3, 0.59, 0.11);
    float luminance = dot(color.rgb, gray);
    float3 enhancedColor = mix(float3(luminance), color.rgb, 1.5);
    enhancedColor = mix(enhancedColor, float3(0.2, 0.2, 0.8), 0.3);
    return float4(enhancedColor, color.a);
}

float4 applyGlow(uint2 gid, float4 color, float2 resolution) {
    // Create a circular, dynamic glow effect with greenish tint
    float2 uv = float2(gid) / resolution;
    float2 center = float2(0.5, 0.5);
    float distanceFromCenter = distance(uv, center);


  //  float glowRadius = 0.25;
    float glowIntensity = 1.0; // Intensity of the glow effect
    float glowFalloff = 3.0; // Falloff rate of the glow

    // Circular glow that pulses over time
    float dynamicGlow = exp(-distanceFromCenter * glowFalloff) * sin(10.0 * distanceFromCenter - time) * 0.5 + 0.5;
    dynamicGlow = smoothstep(0.3, 0.7, dynamicGlow);
    float3 glowColor = float3(0.0, 0.2, 0.8) * dynamicGlow * glowIntensity;
    return float4(color.rgb + glowColor, color.a);
}

[[kernel]]
void postProcess(uint2 gid [[thread_position_in_grid]],
                 texture2d<float, access::sample> inputTexture [[texture(0)]],
                 texture2d<float, access::write> outputTexture [[texture(1)]]) {
    
    if ((gid.x >= inputTexture.get_width()) || (gid.y >= inputTexture.get_height())) {
        return;
    }
    
    float4 sourceColor = inputTexture.read(gid);
    float2 resolution = float2(inputTexture.get_width(), inputTexture.get_height());

    if (filterIndex == 0) { // Helium Blue
        float average = (sourceColor.r + sourceColor.g + sourceColor.b) * 0.25;
        float4 finalColor = float4(sourceColor.r - average, average, average, 1.0);
        outputTexture.write(finalColor, gid);
    }
    
    
    else if (filterIndex == 1) { // Garden Bloom
        float4 enhancedColor = enhanceColor(sourceColor);
        float4 finalColor = applyGlow(gid, enhancedColor, resolution);
        outputTexture.write(finalColor, gid);
    }
    
    else {
        outputTexture.write(float4(0.0, 1.0, 0.0, 1.0), gid);
    }
}
