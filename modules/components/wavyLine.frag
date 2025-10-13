#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float phase;
    float amplitude;
    float frequency;
    vec4 shaderColor;
    float lineWidth;
    float canvasWidth;
    float canvasHeight;
    float fullLength;
} ubuf;

#define PI 3.14159265359

void main() {
    vec2 pixelPos = qt_TexCoord0 * vec2(ubuf.canvasWidth, ubuf.canvasHeight);
    float centerY = ubuf.canvasHeight * 0.5;
    
    // Debug: visualiza diferentes valores
    // Descomenta una línea a la vez para ver qué está pasando
    
    // Test 1: ¿Funciona el gradiente básico?
    // fragColor = vec4(qt_TexCoord0.x, qt_TexCoord0.y, 0.0, 1.0);
    
    // Test 2: ¿La amplitud es correcta? (debería variar en Y)
    float x = pixelPos.x;
    float waveValue = sin(ubuf.frequency * 2.0 * PI * x / ubuf.fullLength + ubuf.phase);
    // fragColor = vec4(waveValue * 0.5 + 0.5, 0.0, 0.0, 1.0);
    
    // Test 3: Visualiza la amplitud
    // fragColor = vec4(ubuf.amplitude / 10.0, 0.0, 0.0, 1.0);
    
    // Versión actual con valores visibles
    float waveY = centerY + ubuf.amplitude * waveValue;
    float dist = abs(pixelPos.y - waveY);
    
    // Aumenta la tolerancia para ver si hay algo
    float alpha = 1.0 - smoothstep(0.0, ubuf.lineWidth * 2.0, dist);
    
    // Debug color: mezcla rojo donde debería estar la onda
    vec3 debugColor = mix(ubuf.shaderColor.rgb, vec3(1.0, 0.0, 0.0), step(dist, 2.0));
    
    fragColor = vec4(debugColor, alpha * ubuf.qt_Opacity);
}
