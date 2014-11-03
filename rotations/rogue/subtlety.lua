-- SPEC ID 261
ProbablyEngine.rotation.register(261, {

  --------------------
  -- Start Rotation --
  --------------------
  
  -- Interrupts
  { "Kick", "modifier.interrupts" },
  
  -- Cooldowns
  { "Shadow Blades", "modifier.cooldowns" },
  
  { "Slice and Dice", { 
    "!player.buff(Slice and Dice)", 
    "player.combopoints = 5",
  }},
  -- Because why not
  { "Ambush" },

  { "Vanish", { 
    "!player.buff(Shadow Dance)", 
    "modifier.cooldowns",
  }},

  { "Preparation", {
    "player.spell(Vanish).cooldown",
  }},
  
  -- Multitarget
  { "Crimson Tempest", {
    "modifier.multitarget", 
    "player.combopoints = 5", 
    "target.range",
  }},

  { "Fan of Knives", { "modifier.multitarget", "player.combopoints <= 4" }},

  -- Rotation
  { "Eviscerate", "player.combopoints = 5" },
  { "Ambush", "player.combopoints <= 3" },
  { "Hemorrhage", "target.debuff(Hemorrhage).duration <= 7" },
  { "Hemorrhage", "!target.debuff(Hemorrhage)" },
  { "Backstab", { "player.combopoints <= 4", "player.behind" }},
  ------------------
  -- End Rotation --
  ------------------

},{

  ---------------
  -- OOC Begin --
  ---------------
  
-- Buffs
{ "Deadly Poison", "player.buff(Deadly Poison).duration <= 900" },
{ "Leeching Poison", "player.buff(Leeching Poison).duration <= 900" },

{ "Deadly Poison", "!player.buff(Deadly Poison)" },
{ "Leeching Poison", "!player.buff(Leeching Poison)" },

-- Vanish Handle
{ "Ambush",{
  "player.buff(Vanish)",
  "target.debuff(Rupture)",
}},
  -------------
  -- OOC End --
  -------------
  
})
