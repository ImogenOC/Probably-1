ProbablyEngine.rotation.shared = {
{ "#5512", "player.health < 70"},
{ "nil", "modifier.cooldowns"},
{ "nil", "modifier.cooldowns"},
{ "nil", "modifier.cooldowns"},
{ "nil", "modifier.cooldowns"},
{ "nil", "modifier.cooldowns"},
{ "nil", "modifier.cooldowns"},
}


-- No one was supposed to use this, fucking retarded...
ProbablyEngine.library.register('coreHealing', {
  needsHealing = function(percent, count)
    return ProbablyEngine.raid.needsHealing(tonumber(percent)) >= count
  end,
  needsDispelled = function(spell)
    for _, unit in pairs(ProbablyEngine.raid.roster) do
      if UnitDebuff(unit.unit, spell) then
        ProbablyEngine.dsl.parsedTarget = unit.unit
        return true
      end
    end
  end,
})
