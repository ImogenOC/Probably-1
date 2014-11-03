-- SPEC ID 259
ProbablyEngine.rotation.register(259, {

  --------------------
  -- Start Rotation --
  --------------------

  -- Interrupts
  { "Kick", "modifier.interrupts" },

  -- Cooldowns
  { "Vendetta", "modifier.cooldowns" },

  -- Multitarget
  { "Crimson Tempest", {
    "modifier.multitarget", 
    "player.combopoints = 5", 
    "target.range",
  }},

  { "Fan of Knives", { "modifier.multitarget", "player.combopoints <= 4" }},

  -- Rotation
  { "Slice and Dice", {  
    "!player.buff(Slice and Dice)", 
    "player.combopoints >= 1",
  }},
  
  { "Rupture", { 
    "target.debuff(Rupture).duration <= 7", 
    "player.combopoints = 5",
  }},
  
  { "Envenom", "player.combopoints = 5" },
  { "Dispatch", "player.buff(Blindside)" },
  { "Fan of Knives", "modifier.multitarget" },
  { "Mutilate", "target.health > 35" },
  { "Dispatch", "target.health < 35" },
  
  ------------------
  -- End Rotation --
  ------------------

},{

-- Buffs
{ "Deadly Poison", "player.buff(Deadly Poison).duration <= 900" },
{ "Leeching Poison", "player.buff(Leeching Poison).duration <= 900" },

{ "Deadly Poison", "!player.buff(Deadly Poison)" },
{ "Leeching Poison", "!player.buff(Leeching Poison)" },

})
