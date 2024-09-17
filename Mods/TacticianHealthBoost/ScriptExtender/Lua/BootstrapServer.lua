function GetPartyMembers()
    local set = {}
    local entities = Osi["DB_PartyMembers"]:Get(nil)
	-- ensure uniqueness
    for _, entity in pairs(entities) do
		set[entity[1]] = true
    end
    return set
end

function ApplyToPartyMembers()
    -- get all party members
    local entities = GetPartyMembers()

    -- add passive to each entity in party
    for entity, _ in pairs(entities) do
		-- _P("Load/diff. add: " .. entity)
		ApplyToEntity(entity)
    end
end

function RemoveFromPartyMembers()
    -- get all party members
    local entities = GetPartyMembers()

    -- add passive to each entity in party
    for entity, _ in pairs(entities) do
		-- _P("Load/diff. remove: " .. entity)
		RemoveFromEntity(entity)
    end
end

function ApplyToEntity(entity)
	-- add party health boost if using tactician difficulty
	if Osi.GetRulesetModifierString("7d788f28-1df5-474b-b106-4f8d0b6de928") == "STATUS_HARD" then
		-- _P("Apply: " .. entity)
		Osi.RemoveStatus(entity, "HEALTHBOOST_HARDCORE", "NULL_00000000-0000-0000-0000-000000000000") -- ensure boost is removed
		Osi.AddPassive(entity, "STATBOOST_HEALTH_PARTY")
	end
end

function RemoveFromEntity(entity)
	-- _P("Remove: " .. entity)
	Osi.RemovePassive(entity, "STATBOOST_HEALTH_PARTY")
end


-- LevelGameplayStarted
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, isEditorMode)
    ApplyToPartyMembers()
end)

-- RulesetModifierChangedString
Ext.Osiris.RegisterListener("RulesetModifierChangedString", 3, "after", function(modifier, old, new)
	-- _P("RulesetModifierChangedString: " .. modifier .. " " .. old .. " >> " .. new)
	-- _P("RulesetModifierChangedString: " .. tostring(modifier == "7d788f28-1df5-474b-b106-4f8d0b6de928") .. " " .. tostring(old == "STATUS_HARD") .. " >> " .. tostring(new == "STATUS_HARD"))
		
	if modifier == "7d788f28-1df5-474b-b106-4f8d0b6de928" then
		-- enabled tactician difficulty
		if new == "STATUS_HARD" then
			if old ~= "STATUS_HARD" then
				ApplyToPartyMembers()
			end
		-- disabled tactician difficulty
		elseif old == "STATUS_HARD" then
			if new ~= "STATUS_HARD" then
				RemoveFromPartyMembers()
			end
		end
	end
end)

-- CharacterJoinedParty
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(entity)
	-- _P("Joined Party: " .. entity)
	ApplyToEntity(entity)
end)

-- CharacterLeftParty
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(entity)
	-- _P("Left Party: " .. entity)
	Osi.ApplyStatus(entity, "HEALTHBOOST_HARDCORE", -1.0, 0, entity) -- should be added automatically by the game when applicable
	
	RemoveFromEntity(entity)
end)