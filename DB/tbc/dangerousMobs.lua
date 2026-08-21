local _, addon = ...

-- Outland danger routes selectively imported from RestedXP/RXPGuides
-- v4.10.25. The upstream data duplicates these routes by faction;
-- 3.3.5 stores one shared copy because the operational records are equal.
if addon.game ~= "WOTLK" or addon.gameVersion ~= 30300 then return end

local dangerousMobs = addon.dangerousMobs
if type(dangerousMobs) ~= "table" then return end

local outlandDangerousMobs = {
  ["Alliance"] = {
    ["Blade's Edge Mountains"] = {
      ["Grulloc"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits extremely hard. extremely dangerous",
        Location = ".pin Blade's Edge Mountains,60.92,47.60;.mob Grulloc"
        },
      },
      ["Maggoc"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow Patrol",
        Notes = "Hits extremely hard. extremely dangerous",
        Location = ".line Blade's Edge Mountains,58.06,64.98,57.98,62.98,58.49,60.96,58.75,59.05,59.27,57.22,59.73,56.17,61.08,54.74,62.34,55.09,63.44,55.38,64.23,55.33,65.34,54.82,66.54,56.21,67.51,58.10,67.85,59.58,68.06,61.57,68.35,62.78,67.98,64.20,67.86,66.44,68.08,67.80,68.05,70.16,68.24,71.99,68.06,74.56,67.98,75.06;.mob Maggoc"
        },
      },
      ["Hemathion"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "5 second fear, flame breath. Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,29.8,68.6;.pin Blade's Edge Mountains,30.2,48.2;.mob Hemathion"
        },
      },
      ["Morcrush"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Knockback. Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,67.8,70.2;.pin Blade's Edge Mountains,65.0,49.2;.pin Blade's Edge Mountains,73.6,24.6;.pin Blade's Edge Mountains,61.8,22.6;.mob Morcrush"
        },
      },
      ["Speaker Mar'grom"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Frostbolt, fireball, scorch, fire ward",
        Location = ".pin Blade's Edge Mountains,67.8,70.2;.pin Blade's Edge Mountains,65.0,49.2;.pin Blade's Edge Mountains,73.6,24.6;.pin Blade's Edge Mountains,61.8,22.6;.mob Speaker Mar'grom"
        },
      },
      ["Goc"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Aoe knockdown (20 yards). Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,64.0,18.8;.mob Goc"
        },
      },
      ["Baelmon the Hound-Master"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Cripple, rain of fire, summons wrath hounds. Hits hard",
        Location = ".pin Blade's Edge Mountains,63.62,59.11;.mob Baelmon the Hound-Master"
        },
      }, 
      ["Galvanoth"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Mortal Strike. Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,36.0,39.6;.pin Blade's Edge Mountains,30.2,77.6;.mob Galvanoth"
        },
      }, 
      ["Bladespire Battlemage"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Bloodlust, flamestrike. Hits hard",
        Location = ".pin Blade's Edge Mountains,65.6,23.2;.mob Bladespire Battlemage"
        },
      }, 
      ["Bladespire Chef"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Knockback, mortal strike. Hits hard",
        Location = ".pin Blade's Edge Mountains,65.6,23.2;.mob Bladespire Chef"
        },
      }, 
      ["Bladespire Enforcer"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Enrage, thunderclap. Hits hard",
        Location = ".pin Blade's Edge Mountains,59.8,22.6;.mob Bladespire Enforcer"
        },
      }, 
      ["Bladespire Ravager"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, infected bite (disease). Hits hard",
        Location = ".pin Blade's Edge Mountains,63.4,21.8;.mob Bladespire Ravager"
        },
      }, 
      ["Obsidia"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,30.8,58.8;.mob Obsidia"
        },
      }, 
      ["Furywing"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,59.4,11.4;.mob Furywing"
        },
      }, 
      ["Insidion"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,50.6,17.0;.mob Insidion"
        },
      }, 
      ["Rivendark"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,29.0,65.2;.mob Rivendark"
        },
      }, 
    },
    ["Hellfire Peninsula"] = {
      ["Doom Lord Kazzak"] = {
        {
        MinLevel = 73,
        MaxLevel = 73,
        Classification = "Boss",
        Movement = "Idle",
        Notes = "WORLD BOSS. DO NOT ENGAGE",
        Location = ".pin Hellfire Peninsula,63.35,15.64;.mob Doom Lord Kazzak"
        },
      },
      ["Fel Reaver"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Fast Patrol",
        Notes = "5 second stun + knockback; hits extremely hard. extremely dangerous",
        Location = ".line Hellfire Peninsula,24.77,65.13,22.78,56.54,18.97,55.85,17.32,50.72,18.81,47.42,17.51,43.18,20.58,46.76,25.89,47.71,28.73,51.07,31.51,50.03,28.99,45.68,27.29,42.60,27.55,40.19,30.17,39.40,32.26,45.02,35.31,47.13,38.44,43.85,40.81,43.33,43.37,45.74,46.32,44.25,46.24,39.72,47.12,35.78,47.97,33.05,48.47,28.23;.line Hellfire Peninsula,71.38,44.04,68.23,40.89,66.69,38.28,65.06,37.84,63.24,34.39,61.19,35.13,59.74,40.22,63.05,48.70,62.61,51.93,61.61,53.83,62.50,56.44,63.91,56.84,66.30,55.58,68.55,56.51,69.40,61.81,66.84,62.03,65.94,63.03,63.25,69.83,61.01,74.72,59.15,74.73,57.71,71.42,54.07,71.88,52.23,72.18,50.60,77.07,49.13,80.31,47.92,76.11,47.77,73.75,46.59,71.67,47.18,69.19,50.19,68.85,49.82,64.17;.mob Fel Reaver"
        },
      },
      ["Drillmaster Zurok"] = {
        {
        MinLevel = 62,
        MaxLevel = 62,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Very large knockback; hits hard",
        Location = ".pin Hellfire Peninsula,48.07,56.17;.mob Drillmaster Zurok"
        },
      },
      ["Tagar Spinebreaker"] = {
        {
        MinLevel = 61,
        MaxLevel = 61,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "8 second stun + knockback; hits extremely hard",
        Location = ".line Hellfire Peninsula,53.09,48.42,53.43,46.83,54.19,46.22,54.92,46.08,55.32,47.91,56.38,47.83,56.80,47.77,57.47,47.24,58.02,47.33,58.41,48.20,58.95,48.17,58.90,46.82,59.25,46.43,59.99,47.11,60.43,47.66,60.85,48.37,61.48,47.89,62.16,48.07,62.50,49.87,62.35,50.37,61.85,51.26,61.52,51.06,61.18,51.09,60.76,50.96,60.41,51.57,60.15,51.52,59.72,51.61,59.35,51.47,59.27,52.58,59.17,53.77,58.98,54.17,58.35,53.44,58.36,51.70,57.70,51.76,57.51,52.51,57.16,52.25,56.80,52.19,56.58,52.68,55.95,53.38,54.78,52.46,54.29,52.54,54.33,54.30,54.18,55.58,53.63,56.80,52.70,56.58;.mob Tagar Spinebreaker"
        },
      },
      ["Arazzius the Cruel"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits extremely hard. extremely dangerous. casts multiple dangerous spells. avoid at all cost",
        Location = ".pin Hellfire Peninsula,43.81,31.56;.mob Arazzius the Cruel"
        },
      },
      ["Raging Colossus"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "2 second stun. hits hard. splits into more mobs as it loses health",
        Location = ".pin Hellfire Peninsula,13.2,45.8;.pin Hellfire Peninsula,18.0,44.2;.pin Hellfire Peninsula,17.8,40.8;.mob Raging Colossus"
        },
      },
      ["Blacktalon the Savage"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits hard; applies stacking armor debuff",
        Location = ".pin Hellfire Peninsula,33.34,65.16;.mob Blacktalon the Savage"
        },
      },
      ["Mekthorg the Wild"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Rare Elite",
        Movement = "Slow Patrol",
        Notes = "Enrages; patrols slighty",
        Location = ".pin Hellfire Peninsula,43.0,63.8;.pin Hellfire Peninsula,50.8,51.6;.pin Hellfire Peninsula,46.6,43.4;.pin Hellfire Peninsula,68.0,71.8;.mob Mekthorg the Wild"
        },
      },
    },
    ["Zangarmarsh"] = {
      ["Boglash"] = {
        {
        MinLevel = 61,
        MaxLevel = 61,
        Classification = "Elite",
        Movement = "Slow Patrol",
        Notes = "Casts tether on player, can run away to break",
        Location = ".line Zangarmarsh,83.89,78.58,82.63,77.98,81.72,75.58,82.11,73.88,81.73,72.94,81.75,72.20;.mob Boglash"
        },
      },
      ["Rajis Fyashe"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Frostbolt, water spout, summons adds. Creates freezing circles",
        Location = ".pin Zangarmarsh,65.142,40.906;.mob Rajis Fyashe"
        },
      },
      ["Rajah Haghazed"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, cleave, mortal strike, shield wall. Hits hard",
        Location = ".pin Zangarmarsh,65.10,68.67;.mob Rajah Haghazed"
        },
      },
      ["Mal'druk the Soulrender"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mind flay, shadowfury. Creates images",
        Location = ".pin Zangarmarsh,20.0,7.6;.mob Mal'druk the Soulrender"
        },
      },
    },
    ["Terokkar Forest"] = {
      ["Okrek"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Fireball, scorch, shadow bolt, shadow nova. Spells hit hard",
        Location = ".pin Terokkar Forest,31.0,43.0;.pin Terokkar Forest,49.8,18.6;.pin Terokkar Forest,58.6,23.8;.pin Terokkar Forest,56.4,68.4;.mob Okrek"
        },
      },
      ["Doomsayer Jurim"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Fear, corruption, shadow bolt, incinerate",
        Location = ".pin Terokkar Forest,36.0,36.6;.pin Terokkar Forest,47.6,26.8;.pin Terokkar Forest,64.6,39.4;.mob Doomsayer Jurim"
        },
      },
      ["Crippler"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Piece armor, bone armor, debilitating strike (reduces phys damage dealt by 75%). Hits hard",
        Location = ".pin Terokkar Forest,31.4,59.4;.pin Terokkar Forest,41.6,54.2;.pin Terokkar Forest,49.2,73.4;.mob Crippler"
        },
      },
      ["Deathskitter"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Poisons. Deals heavy damage",
        Location = ".pin Terokkar Forest,53.8,62.4;.mob Deathskitter"
        },
      },
      ["Luanga the Imprisoner"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Chain lightning, shock, lightning cloud. Deals significant damage",
        Location = ".pin Terokkar Forest,55.6,69.6;.mob Luanga the Imprisoner"
        },
      },
      ["Stonegazer"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "6 second stun. Hits hard",
        Location = ".line Terokkar Forest,71.26,28.70,70.35,29.82,69.63,30.88,69.16,31.22,68.35,31.31,67.93,30.85,66.31,30.54,64.54,30.01,63.72,29.37,63.32,28.38,62.77,27.68,62.10,27.12,61.46,25.43,60.97,24.34,60.77,23.14;.mob Stonegazer"
        },
      },
      ["Terokkarantula"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Poisons and slows. Hits hard",
        Location = ".pin Terokkar Forest,54.2,81.8;.mob Terokkarantula"
        },
      },
    },
    ["Nagrand"] = {
      ["Bro'Gaz the Clanless"] = {
        {
        MinLevel = 66,
        MaxLevel = 66,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Kick, heal, flamestrike",
        Location = ".pin Nagrand,28.6,39.8;.pin Nagrand,52.2,60.0;.pin Nagrand,65.4,76.4;.mob Bro'Gaz the Clanless"
        },
      },
      ["Goretooth"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Bleed, slows",
        Location = ".pin Nagrand,34.8,49.8;.pin Nagrand,45.2,43.6;.pin Nagrand,59.0,28.6;.pin Nagrand,77.0,78.8;.mob Goretooth"
        },
      },
      ["Voidhunter Yar"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Spell damaged reduction based on the damage of spell school taken",
        Location = ".pin Nagrand,36.4,65.2;.mob Voidhunter Yar"
        },
      },
      ["Bach'lor"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Bleed, knockback. Hits hard",
        Location = ".line Nagrand,26.34,51.07,25.93,53.93,25.27,51.74,24.45,50.91,23.69,49.61,24.47,49.04,23.93,48.94,24.36,46.98,23.77,44.47,25.33,41.39,25.72,40.82,26.35,39.23,28.22,38.16,28.35,37.22,28.12,35.92,29.35,34.24,30.07,34.90,30.64,35.79,30.65,37.70,28.90,38.17,28.49,39.43,27.84,42.01,27.25,45.30,26.91,46.66,26.65,48.17,26.34,51.07;.mob Bach'lor"
        },
      },
      ["Banthar"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Aoe stun, charge. Hits hard",
        Location = ".line Nagrand,30.88,63.61,32.53,61.08,33.99,60.44,36.31,58.76,37.39,58.63,38.67,59.52,40.46,60.74,44.52,61.64,46.20,63.09,46.71,66.40,46.31,67.69,45.46,68.24,43.63,68.35,43.05,67.77,42.75,66.72,42.56,64.36,41.98,62.64,40.82,61.30,38.67,59.52;.mob Banthar"
        },
      },
      ["Cho'war the Pillager"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, mortal strike, sunder. Hits extremely hard",
        Location = ".pin Nagrand,25.91,13.72;.mob Cho'war the Pillager"
        },
      },
      ["Deathshadow Overlord"] = {
        {
        MinLevel = 70,
        MaxLevel = 71,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fireball, shadow bolt, impending doom (curse). Hits extremely hard",
        Location = ".pin Nagrand,9.8,40.8;.mob Deathshadow Overlord"
        },
      },
      ["Durn the Hungerer"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Cleave, knockback. Hits extremely hard",
        Location = ".line Nagrand,37.0,77.2,41.2,76.4,43.6,75.8,45.8,72.4,47.6,67.6,47.0,64.0,43.8,60.2,41.4,61.8,36.8,60.6,34.0,60.6,31.6,63.0,30.2,67.0,31.0,69.2,32.6,76.2,34.0,77.6;.mob Durn the Hungerer"
        },
      },
      ["Felguard Legionnaire"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Cleave, knockback. Hits extremely hard",
        Location = ".pin Nagrand,21.6,43.0;.pin Nagrand,25.6,38.2;.pin Nagrand,20.6,51.8;.mob Deathshadow Overlord"
        },
      },
      ["Gutripper"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Flies extremely fast. Hits hard",
        Location = ".line Nagrand,32.66,24.25,33.01,20.84,34.16,20.04,35.46,19.31,36.93,20.77,35.87,23.93,33.32,27.93,31.32,30.74,32.95,28.13,32.66,26.83,32.66,24.25;.mob Gutripper"
        },
      },
      ["Mo'arg Engineer"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Magnetic pull, bleed. Hits hard",
        Location = ".pin Nagrand,24.6,37.6;.pin Nagrand,18.8,51.2;.mob Mo'arg Engineer"
        },
      },
      ["Mo'arg Master Planner"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Magnetic pull. Hits hard",
        Location = ".pin Nagrand,23.6,34.8;.pin Nagrand,17.6,50.2;.mob Mo'arg Master Planner"
        },
      },
      ["Mo'arg Master Planner"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Hits hard",
        Location = ".pin Nagrand,24.3,42.1;.pin Nagrand,23.2,52.6;.mob Mo'arg Master Planner"
        },
      },
      ["Reth'hedron the Subduer"] = {
        {
        MinLevel = 73,
        MaxLevel = 73,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Cripple, shadow bolt. Hits extremely hard",
        Location = ".pin Nagrand,8.8,42.6;.mob Reth'hedron the Subduer"
        },
      },
      ["Tusker"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Knockback, bleed. Hits extremely hard",
        Location = ".pin Nagrand,44.50,65.24;.mob Tusker"
        },
      },
      ["Warmaul Chef Bufferlo"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, mortal strike, bleed. Hits hard",
        Location = ".pin Nagrand,29.0,25.4;.mob Warmaul Chef Bufferlo"
        },
      },
    },
    ["Netherstorm"] = {
      ["Netherock"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Summons adds. Hits hard",
        Location = ".line Netherstorm,18.91,73.08,19.25,74.14,19.67,75.12,20.21,75.45,19.67,75.12,20.16,76.58,20.92,77.73,19.69,78.06,20.92,77.73,21.36,77.60,22.25,78.09,23.03,78.71,22.46,78.73,23.53,79.44,24.23,80.11,25.19,80.83,26.08,81.40,26.78,81.58,27.82,81.09,28.52,80.81,29.70,80.84,30.32,80.66,30.84,80.31,31.32,79.53,31.94,79.56,32.66,79.50,33.55,78.92,34.27,78.64,33.56,79.24,34.27,78.64,35.55,78.65,36.47,79.01,37.83,78.78,38.54,78.67,39.37,78.14,40.02,77.86,41.03,77.33;.mob Netherock"
        },
      },
      ["Chief Engineer Lorthander"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Arcane bolt, slow",
        Location = ".pin Netherstorm,26.4,40.4;.pin Netherstorm,47.6,81.2;.pin Netherstorm,59.8,65.8;.mob Chief Engineer Lorthander"
        },
      },
      ["Ever-Core the Punisher"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Silence, arcane explosion",
        Location = ".pin Netherstorm,20.6,70.0;.pin Netherstorm,27.2,42.0;.pin Netherstorm,62.0,47.0;.mob Ever-Core the Punisher"
        },
      },
      ["Nuramoc"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Silence, arcane explosion",
        Location = ".pin Netherstorm,31.2,78.4;.pin Netherstorm,62.2,61.0;.pin Netherstorm,34.6,27.8;.mob Nuramoc"
        },
      },
      ["Apex"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Thunderclap. Hits hard",
        Location = ".pin Netherstorm,51.6,69.2;.mob Apex"
        },
      },
      ["Arcane Annihilator"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Silence, arcane explosion",
        Location = ".pin Netherstorm,21.6,76.0;.pin Netherstorm,28.2,75.6;.pin Netherstorm,26.8,65.2;.pin Netherstorm,21.6,65.2;.mob Arcane Annihilator"
        },
      },
      ["Cragskaar"] = {
        {
        MinLevel = 69,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Knockback, spawns adds. Hits hard",
        Location = ".line Netherstorm,47.54,21.09,47.59,20.49,47.82,19.69,48.66,19.33,48.98,18.74,49.46,18.15,49.82,17.23;.mob Cragskaar"
        },
      },
      ["Culuthas"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Sleep, knockback, chain felfire. Hits hard",
        Location = ".pin Netherstorm,53.50,21.53;.mob Culuthas"
        },
      },      
      ["Farahlon Breaker"] = {
        {
        MinLevel = 69,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Spawns adds. Hits hard",
        Location = ".line Netherstorm,47.57,20.27,44.88,18.75,45.10,16.70,50.08,17.24,47.57,20.27;.mob Farahlon Breaker"
        },
      },    
      ["Farahlon Giant"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Spawns adds. Hits hard",
        Location = ".pin Netherstorm,40.6,67.4;.mob Farahlon Giant"
        },
      },    
      ["Forgemaster Morug"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Poison. Hits hard",
        Location = ".pin Netherstorm,36.85,27.82;.mob Forgemaster Morug"
        },
      },
      ["Naberius"] = {
        {
        MinLevel = 69,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Frostbolt, knockback, slow, void zone, mind control. Hits very hard",
        Location = ".pin Netherstorm,62.68,78.85;.mob Naberius"
        },
      },
      ["Silroth"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Aoe fire damage. Hits very hard",
        Location = ".pin Netherstorm,40.87,19.54;.mob Silroth"
        },
      },
      ["Socrethar"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Shadowbolt volley, cleave, knockback, anti-magic shield. Hits extremely hard",
        Location = ".pin Netherstorm,29.6,14.2;.mob Socrethar"
        },
      },
    },
    ["Shadowmoon Valley"] = {
      ["Doomwalker"] = {
        {
        MinLevel = 73,
        MaxLevel = 73,
        Classification = "Boss",
        Movement = "Idle",
        Notes = "WORLD BOSS. DO NOT ENGAGE",
        Location = ".pin Shadowmoon Valley,71.8,43.4;.mob Doomwalker"
        },
      },
      ["Ambassador Jerrikar"] = {
        {
        MinLevel = 69,
        MaxLevel = 69,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "4 second silence. 6 second immunity",
        Location = ".pin Shadowmoon Valley,29.8,52.6;.pin Shadowmoon Valley,46.8,29.6;.pin Shadowmoon Valley,58.4,36.4;.pin Shadowmoon Valley,46.0,66.8;.pin Shadowmoon Valley,69.8,62.8;.mob Ambassador Jerrikar"
        },
      },
      ["Collidus the Warp-Watcher"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Fear",
        Location = ".pin Shadowmoon Valley,41.8,47.0;.pin Shadowmoon Valley,57.4,72.8;.pin Shadowmoon Valley,68.4,67.8;.pin Shadowmoon Valley,63.4,23.2;.mob Collidus the Warp-Watcher"
        },
      },
      ["Kraator"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Immolation aura",
        Location = ".pin Shadowmoon Valley,32.0,44.6;.pin Shadowmoon Valley,45.6,12.8;.pin Shadowmoon Valley,43.0,67.4;.pin Shadowmoon Valley,42.6,41.2;.pin Shadowmoon Valley,59.6,47.0;.mob Kraator"
        },
      },
      ["Alandien"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, shadowfury. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,69.58,54.05;.mob Alandien"
        },
      },
      ["Varedis"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, evasion, curse of flames (50% increase fire damage taken). Hits extremely hard",
        Location = ".pin Shadowmoon Valley,72.18,53.69;.mob Varedis"
        },
      },
      ["Theras"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, spell reflect, spellbreaker (75% reduced effectiveness of spells for 6 sec). Hits extremely hard",
        Location = ".pin Shadowmoon Valley,72.37,48.38;.mob Theras"
        },
      },
      ["Netharel"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, evasion. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,68.77,53.92;.mob Netharel"
        },
      },
      ["Arvoar the Rapacious"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, rend, enrage. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,74.2,87.2;.mob Arvoar the Rapacious"
        },
      },
      ["Barash the Den Mother"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, rend, enrage. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,70.2,84.4;.mob Barash the Den Mother"
        },
      },
      ["Crazed Colossus"] = {
        {
        MinLevel = 69,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Spawns adds. Hits hard",
        Location = ".pin Shadowmoon Valley,39.6,69.6;.mob Crazed Colossus"
        },
      },
      ["Illidari Dreadlord"] = {
        {
        MinLevel = 71,
        MaxLevel = 71,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, mind blast, sleep. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,69.6,44.0;.mob Illidari Dreadlord"
        },
      },
      ["Grand Commander Ruusk"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits extremely hard",
        Location = ".pin Shadowmoon Valley,46.46,71.80;.mob Grand Commander Ruusk"
        },
      },
      ["Makazradon"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Cripple, rain of fire, cleave. Hits hard",
        Location = ".pin Shadowmoon Valley,24.0,33.8;.mob Makazradon"
        },
      },
      ["Morgroron"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Knockback, rain of fire, mortal strike. Hits hard",
        Location = ".pin Shadowmoon Valley,22.4,39.6;.mob Morgroron"
        },
      },
      ["Ravenous Flayer Matriarch"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Bleed. Hits hard",
        Location = ".pin Shadowmoon Valley,57.0,18.8;.mob Ravenous Flayer Matriarch"
        },
      },
      ["Ruul the Darkener"] = {
        {
        MinLevel = 71,
        MaxLevel = 71,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Cleave. spellbreaker (75% reduced effectiveness of spells for 6 sec). Hits extremely hard",
        Location = ".pin Shadowmoon Valley,63.4,57.8;.mob Ruul the Darkener"
        },
      },
      ["Shadowsworn Drakonid"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Cleave, mortal strike, sunder armor. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,68.6,39.0;.mob Shadowsworn Drakonid"
        },
      },
      ["Son of Corok"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Knockback, slow. Hits hard",
        Location = ".pin Shadowmoon Valley,52.8,64.8;.mob Son of Corok"
        },
      },
      ["Uvuros"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, double breath. Hits hard",
        Location = ".pin Shadowmoon Valley,54.4,49.8;.mob Uvuros"
        },
      },
      ["Wrathstalker"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Cleave. Hits hard",
        Location = ".pin Shadowmoon Valley,23.8,30.2;.mob Wrathstalker"
        },
      },
    },
  },
  ["Horde"] = {
    ["Blade's Edge Mountains"] = {
      ["Grulloc"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits extremely hard. extremely dangerous",
        Location = ".pin Blade's Edge Mountains,60.92,47.60;.mob Grulloc"
        },
      },
      ["Maggoc"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow Patrol",
        Notes = "Hits extremely hard. extremely dangerous",
        Location = ".line Blade's Edge Mountains,58.06,64.98,57.98,62.98,58.49,60.96,58.75,59.05,59.27,57.22,59.73,56.17,61.08,54.74,62.34,55.09,63.44,55.38,64.23,55.33,65.34,54.82,66.54,56.21,67.51,58.10,67.85,59.58,68.06,61.57,68.35,62.78,67.98,64.20,67.86,66.44,68.08,67.80,68.05,70.16,68.24,71.99,68.06,74.56,67.98,75.06;.mob Maggoc"
        },
      },
      ["Hemathion"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "5 second fear, flame breath. Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,29.8,68.6;.pin Blade's Edge Mountains,30.2,48.2;.mob Hemathion"
        },
      },
      ["Morcrush"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Knockback. Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,67.8,70.2;.pin Blade's Edge Mountains,65.0,49.2;.pin Blade's Edge Mountains,73.6,24.6;.pin Blade's Edge Mountains,61.8,22.6;.mob Morcrush"
        },
      },
      ["Speaker Mar'grom"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Frostbolt, fireball, scorch, fire ward",
        Location = ".pin Blade's Edge Mountains,67.8,70.2;.pin Blade's Edge Mountains,65.0,49.2;.pin Blade's Edge Mountains,73.6,24.6;.pin Blade's Edge Mountains,61.8,22.6;.mob Speaker Mar'grom"
        },
      },
      ["Goc"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Aoe knockdown (20 yards). Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,64.0,18.8;.mob Goc"
        },
      },
      ["Baelmon the Hound-Master"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Cripple, rain of fire, summons wrath hounds. Hits hard",
        Location = ".pin Blade's Edge Mountains,63.62,59.11;.mob Baelmon the Hound-Master"
        },
      }, 
      ["Galvanoth"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Mortal Strike. Hits extremely hard",
        Location = ".pin Blade's Edge Mountains,36.0,39.6;.pin Blade's Edge Mountains,30.2,77.6;.mob Galvanoth"
        },
      }, 
      ["Bladespire Battlemage"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Bloodlust, flamestrike. Hits hard",
        Location = ".pin Blade's Edge Mountains,65.6,23.2;.mob Bladespire Battlemage"
        },
      }, 
      ["Bladespire Chef"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Knockback, mortal strike. Hits hard",
        Location = ".pin Blade's Edge Mountains,65.6,23.2;.mob Bladespire Chef"
        },
      }, 
      ["Bladespire Enforcer"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Enrage, thunderclap. Hits hard",
        Location = ".pin Blade's Edge Mountains,59.8,22.6;.mob Bladespire Enforcer"
        },
      }, 
      ["Bladespire Ravager"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, infected bite (disease). Hits hard",
        Location = ".pin Blade's Edge Mountains,63.4,21.8;.mob Bladespire Ravager"
        },
      }, 
      ["Obsidia"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT PLAYERS IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,30.8,58.8;.mob Obsidia"
        },
      }, 
      ["Furywing"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT PLAYERS IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,59.4,11.4;.mob Furywing"
        },
      }, 
      ["Insidion"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT PLAYERS IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,50.6,17.0;.mob Insidion"
        },
      }, 
      ["Rivendark"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Fear, cleave, hellfire, fiery breath. CAN DISMOUNT PLAYERS IF ON FLYING MOUNT",
        Location = ".pin Blade's Edge Mountains,29.0,65.2;.mob Rivendark"
        },
      }, 
    },
    ["Hellfire Peninsula"] = {
      ["Doom Lord Kazzak"] = {
        {
        MinLevel = 73,
        MaxLevel = 73,
        Classification = "Boss",
        Movement = "Idle",
        Notes = "WORLD BOSS. DO NOT ENGAGE",
        Location = ".pin Hellfire Peninsula,63.35,15.64;.mob Doom Lord Kazzak"
        },
      },
      ["Fel Reaver"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Fast Patrol",
        Notes = "5 second stun + knockback; hits extremely hard. extremely dangerous",
        Location = ".line Hellfire Peninsula,24.77,65.13,22.78,56.54,18.97,55.85,17.32,50.72,18.81,47.42,17.51,43.18,20.58,46.76,25.89,47.71,28.73,51.07,31.51,50.03,28.99,45.68,27.29,42.60,27.55,40.19,30.17,39.40,32.26,45.02,35.31,47.13,38.44,43.85,40.81,43.33,43.37,45.74,46.32,44.25,46.24,39.72,47.12,35.78,47.97,33.05,48.47,28.23;.line Hellfire Peninsula,71.38,44.04,68.23,40.89,66.69,38.28,65.06,37.84,63.24,34.39,61.19,35.13,59.74,40.22,63.05,48.70,62.61,51.93,61.61,53.83,62.50,56.44,63.91,56.84,66.30,55.58,68.55,56.51,69.40,61.81,66.84,62.03,65.94,63.03,63.25,69.83,61.01,74.72,59.15,74.73,57.71,71.42,54.07,71.88,52.23,72.18,50.60,77.07,49.13,80.31,47.92,76.11,47.77,73.75,46.59,71.67,47.18,69.19,50.19,68.85,49.82,64.17;.mob Fel Reaver"
        },
      },
      ["Drillmaster Zurok"] = {
        {
        MinLevel = 62,
        MaxLevel = 62,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Very large knockback; hits hard",
        Location = ".pin Hellfire Peninsula,48.07,56.17;.mob Drillmaster Zurok"
        },
      },
      ["Tagar Spinebreaker"] = {
        {
        MinLevel = 61,
        MaxLevel = 61,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "8 second stun + knockback; hits extremely hard",
        Location = ".line Hellfire Peninsula,53.09,48.42,53.43,46.83,54.19,46.22,54.92,46.08,55.32,47.91,56.38,47.83,56.80,47.77,57.47,47.24,58.02,47.33,58.41,48.20,58.95,48.17,58.90,46.82,59.25,46.43,59.99,47.11,60.43,47.66,60.85,48.37,61.48,47.89,62.16,48.07,62.50,49.87,62.35,50.37,61.85,51.26,61.52,51.06,61.18,51.09,60.76,50.96,60.41,51.57,60.15,51.52,59.72,51.61,59.35,51.47,59.27,52.58,59.17,53.77,58.98,54.17,58.35,53.44,58.36,51.70,57.70,51.76,57.51,52.51,57.16,52.25,56.80,52.19,56.58,52.68,55.95,53.38,54.78,52.46,54.29,52.54,54.33,54.30,54.18,55.58,53.63,56.80,52.70,56.58;.mob Tagar Spinebreaker"
        },
      },
      ["Arazzius the Cruel"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits extremely hard. extremely dangerous. casts multiple dangerous spells. avoid at all cost",
        Location = ".pin Hellfire Peninsula,43.81,31.56;.mob Arazzius the Cruel"
        },
      },
      ["Raging Colossus"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "2 second stun. hits hard. splits into more mobs as it loses health",
        Location = ".pin Hellfire Peninsula,13.2,45.8;.pin Hellfire Peninsula,18.0,44.2;.pin Hellfire Peninsula,17.8,40.8;.mob Raging Colossus"
        },
      },
      ["Blacktalon the Savage"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits hard; applies stacking armor debuff",
        Location = ".pin Hellfire Peninsula,33.34,65.16;.mob Blacktalon the Savage"
        },
      },
      ["Mekthorg the Wild"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Rare Elite",
        Movement = "Slow Patrol",
        Notes = "Enrages; patrols slighty",
        Location = ".pin Hellfire Peninsula,43.0,63.8;.pin Hellfire Peninsula,50.8,51.6;.pin Hellfire Peninsula,46.6,43.4;.pin Hellfire Peninsula,68.0,71.8;.mob Mekthorg the Wild"
        },
      },
    },
    ["Zangarmarsh"] = {
      ["Boglash"] = {
        {
        MinLevel = 61,
        MaxLevel = 61,
        Classification = "Elite",
        Movement = "Slow Patrol",
        Notes = "Casts tether on player, can run away to break",
        Location = ".line Zangarmarsh,83.89,78.58,82.63,77.98,81.72,75.58,82.11,73.88,81.73,72.94,81.75,72.20;.mob Boglash"
        },
      },
      ["Rajis Fyashe"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Frostbolt, water spout, summons adds. Creates freezing circles",
        Location = ".pin Zangarmarsh,65.142,40.906;.mob Rajis Fyashe"
        },
      },
      ["Rajah Haghazed"] = {
        {
        MinLevel = 63,
        MaxLevel = 63,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, cleave, mortal strike, shield wall. Hits hard",
        Location = ".pin Zangarmarsh,65.10,68.67;.mob Rajah Haghazed"
        },
      },
      ["Mal'druk the Soulrender"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mind flay, shadowfury. Creates images",
        Location = ".pin Zangarmarsh,20.0,7.6;.mob Mal'druk the Soulrender"
        },
      },
    },
    ["Terokkar Forest"] = {
      ["Okrek"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Fireball, scorch, shadow bolt, shadow nova. Spells hit hard",
        Location = ".pin Terokkar Forest,31.0,43.0;.pin Terokkar Forest,49.8,18.6;.pin Terokkar Forest,58.6,23.8;.pin Terokkar Forest,56.4,68.4;.mob Okrek"
        },
      },
      ["Doomsayer Jurim"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Fear, corruption, shadow bolt, incinerate",
        Location = ".pin Terokkar Forest,36.0,36.6;.pin Terokkar Forest,47.6,26.8;.pin Terokkar Forest,64.6,39.4;.mob Doomsayer Jurim"
        },
      },
      ["Crippler"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Piece armor, bone armor, debilitating strike (reduces phys damage dealt by 75%). Hits hard",
        Location = ".pin Terokkar Forest,31.4,59.4;.pin Terokkar Forest,41.6,54.2;.pin Terokkar Forest,49.2,73.4;.mob Crippler"
        },
      },
      ["Deathskitter"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Poisons. Deals heavy damage",
        Location = ".pin Terokkar Forest,53.8,62.4;.mob Deathskitter"
        },
      },
      ["Luanga the Imprisoner"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Chain lightning, shock, lightning cloud. Deals significant damage",
        Location = ".pin Terokkar Forest,55.6,69.6;.mob Luanga the Imprisoner"
        },
      },
      ["Stonegazer"] = {
        {
        MinLevel = 64,
        MaxLevel = 64,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "6 second stun. Hits hard",
        Location = ".line Terokkar Forest,71.26,28.70,70.35,29.82,69.63,30.88,69.16,31.22,68.35,31.31,67.93,30.85,66.31,30.54,64.54,30.01,63.72,29.37,63.32,28.38,62.77,27.68,62.10,27.12,61.46,25.43,60.97,24.34,60.77,23.14;.mob Stonegazer"
        },
      },
      ["Terokkarantula"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Poisons and slows. Hits hard",
        Location = ".pin Terokkar Forest,54.2,81.8;.mob Terokkarantula"
        },
      },
    },
    ["Nagrand"] = {
      ["Bro'Gaz the Clanless"] = {
        {
        MinLevel = 66,
        MaxLevel = 66,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Kick, heal, flamestrike",
        Location = ".pin Nagrand,28.6,39.8;.pin Nagrand,52.2,60.0;.pin Nagrand,65.4,76.4;.mob Bro'Gaz the Clanless"
        },
      },
      ["Goretooth"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Bleed, slows",
        Location = ".pin Nagrand,34.8,49.8;.pin Nagrand,45.2,43.6;.pin Nagrand,59.0,28.6;.pin Nagrand,77.0,78.8;.mob Goretooth"
        },
      },
      ["Voidhunter Yar"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Spell damaged reduction based on the damage of spell school taken",
        Location = ".pin Nagrand,36.4,65.2;.mob Voidhunter Yar"
        },
      },
      ["Bach'lor"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Bleed, knockback. Hits hard",
        Location = ".line Nagrand,26.34,51.07,25.93,53.93,25.27,51.74,24.45,50.91,23.69,49.61,24.47,49.04,23.93,48.94,24.36,46.98,23.77,44.47,25.33,41.39,25.72,40.82,26.35,39.23,28.22,38.16,28.35,37.22,28.12,35.92,29.35,34.24,30.07,34.90,30.64,35.79,30.65,37.70,28.90,38.17,28.49,39.43,27.84,42.01,27.25,45.30,26.91,46.66,26.65,48.17,26.34,51.07;.mob Bach'lor"
        },
      },
      ["Banthar"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Aoe stun, charge. Hits hard",
        Location = ".line Nagrand,30.88,63.61,32.53,61.08,33.99,60.44,36.31,58.76,37.39,58.63,38.67,59.52,40.46,60.74,44.52,61.64,46.20,63.09,46.71,66.40,46.31,67.69,45.46,68.24,43.63,68.35,43.05,67.77,42.75,66.72,42.56,64.36,41.98,62.64,40.82,61.30,38.67,59.52;.mob Banthar"
        },
      },
      ["Cho'war the Pillager"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, mortal strike, sunder. Hits extremely hard",
        Location = ".pin Nagrand,25.91,13.72;.mob Cho'war the Pillager"
        },
      },
      ["Deathshadow Overlord"] = {
        {
        MinLevel = 70,
        MaxLevel = 71,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fireball, shadow bolt, impending doom (curse). Hits extremely hard",
        Location = ".pin Nagrand,9.8,40.8;.mob Deathshadow Overlord"
        },
      },
      ["Durn the Hungerer"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Cleave, knockback. Hits extremely hard",
        Location = ".line Nagrand,37.0,77.2,41.2,76.4,43.6,75.8,45.8,72.4,47.6,67.6,47.0,64.0,43.8,60.2,41.4,61.8,36.8,60.6,34.0,60.6,31.6,63.0,30.2,67.0,31.0,69.2,32.6,76.2,34.0,77.6;.mob Durn the Hungerer"
        },
      },
      ["Felguard Legionnaire"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Cleave, knockback. Hits extremely hard",
        Location = ".pin Nagrand,21.6,43.0;.pin Nagrand,25.6,38.2;.pin Nagrand,20.6,51.8;.mob Deathshadow Overlord"
        },
      },
      ["Gutripper"] = {
        {
        MinLevel = 67,
        MaxLevel = 67,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Flies extremely fast. Hits hard",
        Location = ".line Nagrand,32.66,24.25,33.01,20.84,34.16,20.04,35.46,19.31,36.93,20.77,35.87,23.93,33.32,27.93,31.32,30.74,32.95,28.13,32.66,26.83,32.66,24.25;.mob Gutripper"
        },
      },
      ["Mo'arg Engineer"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Magnetic pull, bleed. Hits hard",
        Location = ".pin Nagrand,24.6,37.6;.pin Nagrand,18.8,51.2;.mob Mo'arg Engineer"
        },
      },
      ["Mo'arg Master Planner"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Magnetic pull. Hits hard",
        Location = ".pin Nagrand,23.6,34.8;.pin Nagrand,17.6,50.2;.mob Mo'arg Master Planner"
        },
      },
      ["Mo'arg Master Planner"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Hits hard",
        Location = ".pin Nagrand,24.3,42.1;.pin Nagrand,23.2,52.6;.mob Mo'arg Master Planner"
        },
      },
      ["Reth'hedron the Subduer"] = {
        {
        MinLevel = 73,
        MaxLevel = 73,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Cripple, shadow bolt. Hits extremely hard",
        Location = ".pin Nagrand,8.8,42.6;.mob Reth'hedron the Subduer"
        },
      },
      ["Tusker"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Knockback, bleed. Hits extremely hard",
        Location = ".pin Nagrand,44.50,65.24;.mob Tusker"
        },
      },
      ["Warmaul Chef Bufferlo"] = {
        {
        MinLevel = 65,
        MaxLevel = 65,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Charge, mortal strike, bleed. Hits hard",
        Location = ".pin Nagrand,29.0,25.4;.mob Warmaul Chef Bufferlo"
        },
      },
    },
    ["Netherstorm"] = {
      ["Netherock"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Patrols",
        Notes = "Summons adds. Hits hard",
        Location = ".line Netherstorm,18.91,73.08,19.25,74.14,19.67,75.12,20.21,75.45,19.67,75.12,20.16,76.58,20.92,77.73,19.69,78.06,20.92,77.73,21.36,77.60,22.25,78.09,23.03,78.71,22.46,78.73,23.53,79.44,24.23,80.11,25.19,80.83,26.08,81.40,26.78,81.58,27.82,81.09,28.52,80.81,29.70,80.84,30.32,80.66,30.84,80.31,31.32,79.53,31.94,79.56,32.66,79.50,33.55,78.92,34.27,78.64,33.56,79.24,34.27,78.64,35.55,78.65,36.47,79.01,37.83,78.78,38.54,78.67,39.37,78.14,40.02,77.86,41.03,77.33;.mob Netherock"
        },
      },
      ["Chief Engineer Lorthander"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Arcane bolt, slow",
        Location = ".pin Netherstorm,26.4,40.4;.pin Netherstorm,47.6,81.2;.pin Netherstorm,59.8,65.8;.mob Chief Engineer Lorthander"
        },
      },
      ["Ever-Core the Punisher"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Silence, arcane explosion",
        Location = ".pin Netherstorm,20.6,70.0;.pin Netherstorm,27.2,42.0;.pin Netherstorm,62.0,47.0;.mob Ever-Core the Punisher"
        },
      },
      ["Nuramoc"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Silence, arcane explosion",
        Location = ".pin Netherstorm,31.2,78.4;.pin Netherstorm,62.2,61.0;.pin Netherstorm,34.6,27.8;.mob Nuramoc"
        },
      },
      ["Apex"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Thunderclap. Hits hard",
        Location = ".pin Netherstorm,51.6,69.2;.mob Apex"
        },
      },
      ["Arcane Annihilator"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Silence, arcane explosion",
        Location = ".pin Netherstorm,21.6,76.0;.pin Netherstorm,28.2,75.6;.pin Netherstorm,26.8,65.2;.pin Netherstorm,21.6,65.2;.mob Arcane Annihilator"
        },
      },
      ["Cragskaar"] = {
        {
        MinLevel = 69,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Knockback, spawns adds. Hits hard",
        Location = ".line Netherstorm,47.54,21.09,47.59,20.49,47.82,19.69,48.66,19.33,48.98,18.74,49.46,18.15,49.82,17.23;.mob Cragskaar"
        },
      },
      ["Culuthas"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Sleep, knockback, chain felfire. Hits hard",
        Location = ".pin Netherstorm,53.50,21.53;.mob Culuthas"
        },
      },      
      ["Farahlon Breaker"] = {
        {
        MinLevel = 69,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Spawns adds. Hits hard",
        Location = ".line Netherstorm,47.57,20.27,44.88,18.75,45.10,16.70,50.08,17.24,47.57,20.27;.mob Farahlon Breaker"
        },
      },    
      ["Farahlon Giant"] = {
        {
        MinLevel = 67,
        MaxLevel = 68,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Spawns adds. Hits hard",
        Location = ".pin Netherstorm,40.6,67.4;.mob Farahlon Giant"
        },
      },    
      ["Forgemaster Morug"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Poison. Hits hard",
        Location = ".pin Netherstorm,36.85,27.82;.mob Forgemaster Morug"
        },
      },
      ["Naberius"] = {
        {
        MinLevel = 69,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Frostbolt, knockback, slow, void zone, mind control. Hits very hard",
        Location = ".pin Netherstorm,62.68,78.85;.mob Naberius"
        },
      },
      ["Silroth"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Aoe fire damage. Hits very hard",
        Location = ".pin Netherstorm,40.87,19.54;.mob Silroth"
        },
      },
      ["Socrethar"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Shadowbolt volley, cleave, knockback, anti-magic shield. Hits extremely hard",
        Location = ".pin Netherstorm,29.6,14.2;.mob Socrethar"
        },
      },
    },
    ["Shadowmoon Valley"] = {
      ["Doomwalker"] = {
        {
        MinLevel = 73,
        MaxLevel = 73,
        Classification = "Boss",
        Movement = "Idle",
        Notes = "WORLD BOSS. DO NOT ENGAGE",
        Location = ".pin Shadowmoon Valley,71.8,43.4;.mob Doomwalker"
        },
      },
      ["Ambassador Jerrikar"] = {
        {
        MinLevel = 69,
        MaxLevel = 69,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "4 second silence. 6 second immunity",
        Location = ".pin Shadowmoon Valley,29.8,52.6;.pin Shadowmoon Valley,46.8,29.6;.pin Shadowmoon Valley,58.4,36.4;.pin Shadowmoon Valley,46.0,66.8;.pin Shadowmoon Valley,69.8,62.8;.mob Ambassador Jerrikar"
        },
      },
      ["Collidus the Warp-Watcher"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Patrols slightly",
        Notes = "Fear",
        Location = ".pin Shadowmoon Valley,41.8,47.0;.pin Shadowmoon Valley,57.4,72.8;.pin Shadowmoon Valley,68.4,67.8;.pin Shadowmoon Valley,63.4,23.2;.mob Collidus the Warp-Watcher"
        },
      },
      ["Kraator"] = {
        {
        MinLevel = 68,
        MaxLevel = 68,
        Classification = "Rare",
        Movement = "Idle",
        Notes = "Immolation aura",
        Location = ".pin Shadowmoon Valley,32.0,44.6;.pin Shadowmoon Valley,45.6,12.8;.pin Shadowmoon Valley,43.0,67.4;.pin Shadowmoon Valley,42.6,41.2;.pin Shadowmoon Valley,59.6,47.0;.mob Kraator"
        },
      },
      ["Alandien"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, shadowfury. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,69.58,54.05;.mob Alandien"
        },
      },
      ["Varedis"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, evasion, curse of flames (50% increase fire damage taken). Hits extremely hard",
        Location = ".pin Shadowmoon Valley,72.18,53.69;.mob Varedis"
        },
      },
      ["Theras"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, spell reflect, spellbreaker (75% reduced effectiveness of spells for 6 sec). Hits extremely hard",
        Location = ".pin Shadowmoon Valley,72.37,48.38;.mob Theras"
        },
      },
      ["Netharel"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Mana burn, evasion. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,68.77,53.92;.mob Netharel"
        },
      },
      ["Arvoar the Rapacious"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, rend, enrage. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,74.2,87.2;.mob Arvoar the Rapacious"
        },
      },
      ["Barash the Den Mother"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, rend, enrage. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,70.2,84.4;.mob Barash the Den Mother"
        },
      },
      ["Crazed Colossus"] = {
        {
        MinLevel = 69,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Spawns adds. Hits hard",
        Location = ".pin Shadowmoon Valley,39.6,69.6;.mob Crazed Colossus"
        },
      },
      ["Illidari Dreadlord"] = {
        {
        MinLevel = 71,
        MaxLevel = 71,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, mind blast, sleep. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,69.6,44.0;.mob Illidari Dreadlord"
        },
      },
      ["Grand Commander Ruusk"] = {
        {
        MinLevel = 72,
        MaxLevel = 72,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Hits extremely hard",
        Location = ".pin Shadowmoon Valley,46.46,71.80;.mob Grand Commander Ruusk"
        },
      },
      ["Makazradon"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Cripple, rain of fire, cleave. Hits hard",
        Location = ".pin Shadowmoon Valley,24.0,33.8;.mob Makazradon"
        },
      },
      ["Morgroron"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Knockback, rain of fire, mortal strike. Hits hard",
        Location = ".pin Shadowmoon Valley,22.4,39.6;.mob Morgroron"
        },
      },
      ["Ravenous Flayer Matriarch"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Bleed. Hits hard",
        Location = ".pin Shadowmoon Valley,57.0,18.8;.mob Ravenous Flayer Matriarch"
        },
      },
      ["Ruul the Darkener"] = {
        {
        MinLevel = 71,
        MaxLevel = 71,
        Classification = "Elite",
        Movement = "Patrols slightly",
        Notes = "Cleave. spellbreaker (75% reduced effectiveness of spells for 6 sec). Hits extremely hard",
        Location = ".pin Shadowmoon Valley,63.4,57.8;.mob Ruul the Darkener"
        },
      },
      ["Shadowsworn Drakonid"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Cleave, mortal strike, sunder armor. Hits extremely hard",
        Location = ".pin Shadowmoon Valley,68.6,39.0;.mob Shadowsworn Drakonid"
        },
      },
      ["Son of Corok"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Slow patrol",
        Notes = "Knockback, slow. Hits hard",
        Location = ".pin Shadowmoon Valley,52.8,64.8;.mob Son of Corok"
        },
      },
      ["Uvuros"] = {
        {
        MinLevel = 70,
        MaxLevel = 70,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Fear, double breath. Hits hard",
        Location = ".pin Shadowmoon Valley,54.4,49.8;.mob Uvuros"
        },
      },
      ["Wrathstalker"] = {
        {
        MinLevel = 68,
        MaxLevel = 69,
        Classification = "Elite",
        Movement = "Idle",
        Notes = "Cleave. Hits hard",
        Location = ".pin Shadowmoon Valley,23.8,30.2;.mob Wrathstalker"
        },
      },
    },
  },
}

local factionMobs = outlandDangerousMobs[_G.UnitFactionGroup("player")]
if type(factionMobs) ~= "table" then return end
for zone, records in pairs(factionMobs) do
    if dangerousMobs[zone] == nil then dangerousMobs[zone] = records end
end

