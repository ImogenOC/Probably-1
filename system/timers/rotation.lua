-- ProbablyEngine Rotations - https://probablyengine.com/
-- Released under modified BSD, see attached LICENSE.

local GetSpellInfo = GetSpellInfo

ProbablyEngine.current_spell = false

ProbablyEngine.cycleTime = ProbablyEngine.cycleTime or 50

ProbablyEngine.cycle = function(skip_verify)

  local turbo = ProbablyEngine.config.read('pe_turbo', false)
  local cycle =
    IsMounted() == false
    and UnitInVehicle("player") == false
    and ProbablyEngine.module.player.combat
    and ProbablyEngine.config.read('button_states', 'MasterToggle', false)
    and ProbablyEngine.module.player.specID
    and (ProbablyEngine.protected.unlocked or IsMacClient())

  if cycle or skip_verify then
    
    local spell, target = false

    local queue = ProbablyEngine.module.queue.spellQueue
    if queue ~= nil and ProbablyEngine.parser.can_cast(queue) then
      spell = queue
      target = 'target'
      ProbablyEngine.module.queue.spellQueue = nil
    elseif ProbablyEngine.parser.lastCast == queue then
      ProbablyEngine.module.queue.spellQueue = nil
    else
      spell, target = ProbablyEngine.parser.table(ProbablyEngine.rotation.activeRotation)
    end

    if not spell then
      spell, target = ProbablyEngine.parser.table(ProbablyEngine.rotation.activeRotation)
    end

    if spell then
      local spellIndex, spellBook = GetSpellBookIndex(spell)
      local spellID, name, icon
      if spellBook ~= nil then
        _, spellID = GetSpellBookItemInfo(spellIndex, spellBook)
        name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellIndex, spellBook)
      else
        spellID = spellIndex
        name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellID)
      end

      ProbablyEngine.buttons.icon('MasterToggle', icon)
      ProbablyEngine.current_spell = name

      if target == "ground" then
        CastGround(name, 'target')
      elseif string.sub(target, -7) == ".ground" then
        target = string.sub(target, 0, -8)
        CastGround(name, target)
      else
        if spellID == 110309 then
          Macro("/target " .. target)
          target = "target"
        end
        Cast(name, target or "target")
        if spellID == 110309 then
          Macro("/targetlasttarget")
        end
        if icon then
          ProbablyEngine.actionLog.insert('Spell Cast', name, icon, target or "target")
        end
      end

      if target ~= "ground" and UnitExists(target or 'target') then
        ProbablyEngine.debug.print("Casting |T"..icon..":10:10|t ".. name .. " on ( " .. UnitName(target or 'target') .. " )", 'spell_cast')
      else
        ProbablyEngine.debug.print("Casting |T"..icon..":10:10|t ".. name .. " on the ground!", 'spell_cast')
      end

    end
    
  end
end

ProbablyEngine.timer.register("rotation", function()
  ProbablyEngine.cycle()
end, ProbablyEngine.cycleTime)

ProbablyEngine.ooc_cycle = function()
  local cycle =
    IsMounted() == false
    and UnitInVehicle("player") == false
    and not ProbablyEngine.module.player.combat
    and ProbablyEngine.config.read('button_states', 'MasterToggle', false)
    and ProbablyEngine.module.player.specID ~= 0
    and ProbablyEngine.rotation.activeOOCRotation ~= false
    and (ProbablyEngine.protected.unlocked or IsMacClient())

  if cycle then
    local spell, target = ''
    spell, target = ProbablyEngine.parser.table(ProbablyEngine.rotation.activeOOCRotation, 'player')

    if target == nil then target = 'player' end
    if spell then
      local spellIndex, spellBook = GetSpellBookIndex(spell)
      local spellID, name, icon
      if spellBook ~= nil then
        _, spellID = GetSpellBookItemInfo(spellIndex, spellBook)
        name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellIndex, spellBook)
      else
        spellID = spellIndex
        name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellID)
      end

      ProbablyEngine.buttons.icon('MasterToggle', icon)
      ProbablyEngine.current_spell = name

      if target == "ground" then
        CastGround(name, 'target')
      elseif string.sub(target, -7) == ".ground" then
        target = string.sub(target, 0, -8)
        CastGround(name, target)
      else
        if spellID == 110309 then
          Macro("/target " .. target)
          target = "target"
        end
        Cast(name, target)
        if spellID == 110309 then
          Macro("/targetlasttarget")
        end
        if icon then
          ProbablyEngine.actionLog.insert('Spell Cast', name, icon, target)
        end
      end

      if target ~= "ground" and UnitExists(target or 'target') then
        ProbablyEngine.debug.print("Casting |T"..icon..":10:10|t ".. name .. " on ( " .. UnitName(target or 'target') .. " )", 'spell_cast')
      else
        ProbablyEngine.debug.print("Casting |T"..icon..":10:10|t ".. name .. " on the ground!", 'spell_cast')
      end

      --soon... soon
      --Purrmetheus.api:UpdateIntent("default", ProbablyEngine.ooc_cycle, name, nil, target or "target")

    end
  end
end

ProbablyEngine.timer.register("oocrotation", function()
  ProbablyEngine.ooc_cycle()
end, ProbablyEngine.cycleTime)


if IsWindowsClient() then
  ProbablyEngine.timer.register("detectUnlock", function()
    ProbablyEngine.protected.FireHack()
    ProbablyEngine.protected.OffSpring()
  end, 1000)
end