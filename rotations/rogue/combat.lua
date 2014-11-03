-- SPEC ID 260
ProbablyEngine.rotation.register(260, {

--------------------
-- Start Rotation --
--------------------
  
-- Buffs
{ "Deadly Poison", "!player.buff(Deadly Poison)" },
{ "Leeching Poison", "!player.buff(Leeching Poison)" },

-- Interrupts
{ "Kick", "modifier.interrupts" },

-- Cooldowns
{ "Adrenaline Rush", {
  "modifier.cooldowns",
  "player.buff(Deep Insight)",
}},
  
{ "Killing Spree", { 
  "modifier.cooldowns", 
  "player.energy <= 35", 
  "!player.buff(Adrenaline Rush)",
  "player.buff(Moderate Insight)",
}},
  
{ "Shadow Blades", { 
  "modifier.cooldowns", 
  "player.buff(Adrenaline Rush)",
}},

-- Blade Flurry
{ "Blade Flurry", { 
  "!modifier.multitarget", 
  "player.buff(Blade Flurry)",
}},
  
{ "Blade Flurry", { 
  "modifier.multitarget", 
  "!player.buff(Blade Flurry)",
}},

-- Rotation
{ "Marked for Death", "player.combopoints = 0" },
  
{ "Slice and Dice", { 
  "player.buff(Slice and Dice).duration <= 7", 
  "player.combopoints = 5",
}},
  

{ "Slice and Dice", { 
  "!player.buff(Slice and Dice)", 
  "player.combopoints = 5",
}},
  
{ "Revealing Strike", "target.debuff(Revealing Strike).duration <= 6" },
  
{ "Rupture", { 
  "target.debuff(Rupture).duration <= 8", 
  "player.combopoints = 5",
}},
  
{ "Eviscerate", "player.combopoints = 5" },
{ "Sinister Strike" },
  
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

 { "Blade Flurry", { 
 "!modifier.multitarget", 
 "player.buff(Blade Flurry)",
}},
  
{ "Blade Flurry", { 
 "modifier.multitarget", 
 "!player.buff(Blade Flurry)",
}},

-------------
-- OOC End --
-------------
})
