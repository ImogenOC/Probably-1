-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

ProbablyEngine = {
  addonName = "Probably",
  addonReal = "Probably",
  addonColor = "EE2200",
  version = "6.0.3r8"
}

function ProbablyEngine.print(message)
  print('|c00'..ProbablyEngine.addonColor..'['..ProbablyEngine.addonName..']|r ' .. message)
end
