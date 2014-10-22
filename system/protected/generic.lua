-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

-- Function prototypes

ProbablyEngine.protected.generic_check = false

function ProbablyEngine.protected.Generic()
	if not ProbablyEngine.protected.method then
		pcall(RunMacroText, "/run ProbablyEngine.protected.generic_check = true")
		if ProbablyEngine.protected.generic_check then
			ProbablyEngine.protected.unlocked = true
			ProbablyEngine.protected.method = "generic"
			ProbablyEngine.timer.unregister('detectUnlock')
			ProbablyEngine.print('Detected a generic Lua unlock!  Some advanced features will not work.')
		end
	end
end