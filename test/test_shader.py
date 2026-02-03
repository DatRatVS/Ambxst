import sys, os, shutil
mpvShaderDir = sys.argv[1]
currentShaderPath = sys.argv[2]
shaderContent = sys.argv[3]

if not os.path.exists(mpvShaderDir): os.makedirs(mpvShaderDir)
for f in os.listdir(mpvShaderDir):
    path = os.path.join(mpvShaderDir, f)
    if os.path.isfile(path): os.remove(path)
open(currentShaderPath, 'w').write(shaderContent)
print('Wrote shader to ' + currentShaderPath)
legacy = [os.path.join(os.path.dirname(mpvShaderDir), f) for f in ['mpv_tint_0.glsl', 'mpv_tint_1.glsl', 'mpv_tint.glsl']]
for l in legacy:
  if os.path.exists(l): os.remove(l)
