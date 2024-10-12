function GetPartyMembers()
    local set = {}
    local entities = Osi["DB_PartyMembers"]:Get(nil)
	-- ensure uniqueness
    for _, entity in pairs(entities) do
		set[entity[1]] = true
    end
    return set
end

function GetInRegion()
    local set = {}
    local entities = Osi["DB_InRegion"]:Get(nil, nil)
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
		RemoveFromEntity(entity) -- ensure boost is removed
		ApplyToPartyMember(entity)
    end
end

function RemoveFromPartyMembers()
    -- get all party members
    local entities = GetPartyMembers()

    -- remove passive from each entity in party
    for entity, _ in pairs(entities) do
		-- _P("Load/diff. remove: " .. entity)
		RemoveFromPartyMember(entity)
    end
end

function ApplyToPartyMember(entity)
	-- add party health boost if using tactician difficulty
	if Osi.GetRulesetModifierString("7d788f28-1df5-474b-b106-4f8d0b6de928") == "STATUS_HARD" then
		-- _P("Apply: " .. entity)
		Osi.AddPassive(entity, "STATBOOST_HEALTH_PARTY")
	end
end

function RemoveFromPartyMember(entity)
	-- _P("Remove Party: " .. entity)
	Osi.RemovePassive(entity, "STATBOOST_HEALTH_PARTY")
end


function ApplyToEntities()
    -- get all in region
    local entities = GetInRegion()

    -- conditionally add passive to each entity
    for entity, _ in pairs(entities) do
		-- _P("Load/diff. add: " .. entity)
		ApplyToEntity(entity)
    end
end

function RemoveFromEntities()
    -- get all in region
    local entities = GetInRegion()

    -- remove passive from each entity
    for entity, _ in pairs(entities) do
		-- _P("Load/diff. remove: " .. entity)
		RemoveFromEntity(entity)
    end
end

function ApplyToEntity(entity)
	-- add entity health boost if using tactician difficulty
	-- _P(not Osi.HasPassive(entity, "STATBOOST_HEALTH_PARTY") and not Osi.HasPassive(entity, "STATBOOST_HEALTH_NPC") .. " " .. entity)
	if Osi.GetRulesetModifierString("7d788f28-1df5-474b-b106-4f8d0b6de928") == "STATUS_HARD" 
		and Osi.HasPassive(entity, "STATBOOST_HEALTH_PARTY") == 0 
		and Osi.HasPassive(entity, "STATBOOST_HEALTH_NPC") == 0 then
		-- _P("ApplyStatus: " .. entity)
		Osi.ApplyStatus(entity, "HEALTHBOOST_HARDCORE", -1.0, 0, entity)
	end
end

function RemoveFromEntity(entity)
	-- _P("Remove Entity: " .. entity)
	Osi.RemoveStatus(entity, "HEALTHBOOST_HARDCORE", "NULL_00000000-0000-0000-0000-000000000000")
end


-- LevelGameplayStarted
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, isEditorMode)
    ApplyToPartyMembers()
	ApplyToEntities()
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
				ApplyToEntities()
			end
		-- disabled tactician difficulty
		elseif old == "STATUS_HARD" then
			if new ~= "STATUS_HARD" then
				RemoveFromPartyMembers()
				RemoveFromEntities()
			end
		end
	end
end)

-- CharacterJoinedParty
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(entity)
	-- _P("Joined Party: " .. entity)
	RemoveFromEntity(entity)
	ApplyToPartyMember(entity)
end)

-- CharacterLeftParty
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(entity)
	-- _P("Left Party: " .. entity)
	RemoveFromPartyMember(entity)
	ApplyToEntity(entity)
end)