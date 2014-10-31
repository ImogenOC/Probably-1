ProbablyEngine.rotation.shared = {
-- Healthstone
{ "#5512", { "player.health < 30", "modifier.cooldowns" }},
-- Tier 90 DPS Potions (Pandaria)
{ "#76093", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Potion of the Jade Serpent (INT)
{ "#76095", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Potion of Mogu Power (STR)
{ "#76089", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Virmen's Bite (AGI)
-- -- Tier 85 DPS Potions (Cata)
-- { "#76089", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Potion of the Tol'vir (AGI)
-- { "#76089", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Volcanic Potion (INT)
-- { "#76089", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Golemblood Potion (STR)
-- -- Tier 80 DPS Potions (WotLK)

-- -- None, because fuck you

-- -- Tier 70 DPS Potions (BC)
-- { "#22839", { "modifier.cooldowns", "player.level <= 70", "player.level >= 60" }}, -- Destruction Potion (Crit / SP)
-- { "#22837", { "modifier.cooldowns", "player.level <= 70", "player.level >= 60" }}, -- Heroic Potion (Str / HP)
-- { "#22838", { "modifier.cooldowns", "player.level <= 90", "player.level >= 85" }}, -- Haste Potion (Haste???)
-- -- Tier 60 ??? Potions (Classic)
-- { "#nil", { "modifier.cooldowns", "main.condition" }},
-- { "#nil", { "modifier.cooldowns", "main.condition" }},
	
-- Health Potions
-- Tier 100 (WoD)
{ "#115498", { "modifier.cooldowns", "player.level = 100", "player.health <= 35", "toggle.survival" }},
{ "#109223", { "modifier.cooldowns", "player.level >= 91", "player.level < 100", "player.health <= 35", "toggle.survival" }},
{ "#117415", { "modifier.cooldowns", "player.level >= 91", "player.level < 100", "player.health <= 35", "toggle.survival" }},
-- Tier 90 (Pandaria)
{ "#76097", { "modifier.cooldowns", "player.level = 90", "player.health <= 35", "toggle.survival" }},
-- -- Tier 85 (Cataclysm)
-- { "#76097", { "modifier.cooldowns", "player.level = 90", "player.health <= 35", "toggle.survival" }},
-- -- Tier 80 (Wrath of the Lich King)
-- { "#33447", { "modifier.cooldowns", "player.level >= 70", "player.health <= 35", "toggle.survival" }},
-- { "#41166", { "modifier.cooldowns", "player.level >= 70", "player.health <= 35", "toggle.survival" }},
-- -- Tier 70 (Burning Crusade)
-- { "#39671", { "modifier.cooldowns", "player.level >= 65", "player.health <= 35", "toggle.survival" }},
-- -- Tier 60 (Classic)
-- { "#33092", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#22829", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#32947", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#43531", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#32904", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#28100", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#33934", { "modifier.cooldowns", "player.level >= 55", "player.health <= 35", "toggle.survival" }},
-- { "#13446", { "modifier.cooldowns", "player.level >= 45", "player.health <= 35", "toggle.survival" }},
-- { "#18839", { "modifier.cooldowns", "player.level >= 90", "player.health <= 35", "toggle.survival" }},
-- { "#3928", { "modifier.cooldowns", "player.level >= 35", "player.health <= 35", "toggle.survival" }},
-- { "#1710", { "modifier.cooldowns", "player.level >= 35", "player.health <= 35", "toggle.survival" }},
-- { "#929", { "modifier.cooldowns", "player.level >= 22", "player.health <= 35", "toggle.survival" }},
-- { "#4596", { "modifier.cooldowns", "player.level >= 15", "player.health <= 35", "toggle.survival" }},
-- { "#858", { "modifier.cooldowns", "player.level >= 13", "player.health <= 35", "toggle.survival" }},
-- { "#118", { "modifier.cooldowns", "player.level >= 1", "player.health <= 35", "toggle.survival" }},

-- Mana Potions
-- Tier 100 (WoD)
{ "#109222", { "modifier.cooldowns", "player.level = 90", "player.mana <= 35", "toggle.survival" }},
-- Tier 90 (Pandaria)
{ "#76098", { "modifier.cooldowns", "player.level = 90", "player.mana <= 35", "toggle.survival" }},

-- Don't look here its messy
-- Tier 90 DPS Potions (Pandaria)
-- Tier 85 DPS Potions (Cataclysm)
-- Tier 80 DPS Potions (Wrath of the Lich King)
-- Tier 70 DPS Potions (Burning Crusade)
-- Tier 60 DPS Potions (Classic)
-- Tier 90 (Pandaria)
-- Tier 85 (Cataclysm)
-- Tier 80 (Wrath of the Lich King)
-- Tier 70 (Burning Crusade)
-- Tier 60 (Classic)
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
