-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

-- Function prototypes

ProbablyEngine.protected.generic_check = false

function ProbablyEngine.protected.Generic()
	if not ProbablyEngine.protected.method and not ProbablyEngine.faceroll.rolling then
		pcall(RunMacroText, "/run ProbablyEngine.protected.generic_check = true")
		if ProbablyEngine.protected.generic_check then
			ProbablyEngine.protected.unlocked = true
			ProbablyEngine.protected.method = "generic"
			ProbablyEngine.timer.unregister('detectUnlock')
			ProbablyEngine.print('Detected a generic Lua unlock!  Some advanced features will not work.')

			function Cast(spell, target)
				if type(spell) == "number" then
					CastSpellByID(spell, target)
				else
					CastSpellByName(spell, target)
				end
			end

			function CastGround(spell, target)
				local stickyValue = GetCVar("deselectOnClick")
				SetCVar("deselectOnClick", "0")
				CameraOrSelectOrMoveStart(1)
				Cast(spell, target)
				CameraOrSelectOrMoveStop(1)
				SetCVar("deselectOnClick", "1")
				SetCVar("deselectOnClick", stickyValue)
			end

			function Macro(text)
				return RunMacroText(text)
			end

			function UseItem(name, target)
				return UseItemByName(name, target)
			end

		else
			ProbablyEngine.faceroll.rolling = true
			ProbablyEngine.faceroll.noticed = false
		end
	elseif ProbablyEngine.faceroll.rolling and not ProbablyEngine.faceroll.noticed then
		ProbablyEngine.print('No unlock found, now in FaceRoll mode, /reload your UI to check again.')
		ProbablyEngine.faceroll.noticed = true
	end
end