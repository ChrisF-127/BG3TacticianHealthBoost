function GetUniqueEntities(entities)
    local set = {}
	-- ensure uniqueness
    for _, entity in pairs(entities) do
		set[entity[1]] = true
    end
    return set
end

function GetPartyMembers()
    local entities = Osi["DB_PartyMembers"]:Get(nil)
    return GetUniqueEntities(entities)
end
function GetInRegion()
    local entities = Osi["DB_InRegion"]:Get(nil, nil)
    return GetUniqueEntities(entities)
end


function ApplyPartyAll()
    local entities = GetPartyMembers()
    for entity, _ in pairs(entities) do
		ApplyPartySingle(entity)
    end
end
function ApplyPartySingle(entity)
	-- add party health boost if using tactician difficulty
	if Osi.GetRulesetModifierString("7d788f28-1df5-474b-b106-4f8d0b6de928") == "STATUS_HARD" 
		and Osi.HasAppliedStatus(entity, "HEALTHBOOST_HARDCORE_PARTY") == 0 then
		-- _P("Apply Party: " .. entity)
		Osi.ApplyStatus(entity, "HEALTHBOOST_HARDCORE_PARTY", -1.0, 0, entity)
	end
end

function RemovePartyAll()
    local entities = GetPartyMembers()
    for entity, _ in pairs(entities) do
		RemovePartySingle(entity)
    end
end
function RemovePartySingle(entity)
	-- _P("Remove Party: " .. entity)
	Osi.RemoveStatus(entity, "HEALTHBOOST_HARDCORE_PARTY", "NULL_00000000-0000-0000-0000-000000000000")
end


function ApplyOtherAll()
    local entities = GetInRegion()
    for entity, _ in pairs(entities) do
		ApplyOtherSingle(entity)
    end
end
function ApplyOtherSingle(entity)
	-- add party health boost if using tactician difficulty
	if Osi.GetRulesetModifierString("7d788f28-1df5-474b-b106-4f8d0b6de928") == "STATUS_HARD" 
		and Osi.HasAppliedStatus(entity, "HEALTHBOOST_HARDCORE_OTHER") == 0 then
		-- _P("Apply Other: " .. entity)
		Osi.ApplyStatus(entity, "HEALTHBOOST_HARDCORE_OTHER", -1.0, 0, entity)
	end
end

function RemoveOtherAll()
    local entities = GetInRegion()
    for entity, _ in pairs(entities) do
		RemoveOtherSingle(entity)
    end
end
function RemoveOtherSingle(entity)
	-- _P("Remove Other: " .. entity)
	Osi.RemoveStatus(entity, "HEALTHBOOST_HARDCORE_OTHER", "NULL_00000000-0000-0000-0000-000000000000")
end


function RemoveNPCSingle(entity)
	-- _P("Remove NPC: " .. entity)
	Osi.RemoveStatus(entity, "HEALTHBOOST_HARDCORE", "NULL_00000000-0000-0000-0000-000000000000")
end


-- LevelGameplayStarted
Ext.Osiris.RegisterListener("LevelGameplayStarted", 2, "after", function(level, isEditorMode)
	ApplyOtherAll()
    ApplyPartyAll()
end)

-- RulesetModifierChangedString
Ext.Osiris.RegisterListener("RulesetModifierChangedString", 3, "after", function(modifier, old, new)
	-- _P("RulesetModifierChangedString: " .. modifier .. " " .. old .. " >> " .. new)
	-- _P("RulesetModifierChangedString: " .. tostring(modifier == "7d788f28-1df5-474b-b106-4f8d0b6de928") .. " " .. tostring(old == "STATUS_HARD") .. " >> " .. tostring(new == "STATUS_HARD"))
		
	if modifier == "7d788f28-1df5-474b-b106-4f8d0b6de928" then
		-- enabled tactician difficulty
		if new == "STATUS_HARD" then
			if old ~= "STATUS_HARD" then
				ApplyOtherAll()
				ApplyPartyAll()
			end
		-- disabled tactician difficulty
		elseif old == "STATUS_HARD" then
			if new ~= "STATUS_HARD" then
				RemoveOtherAll()
				RemovePartyAll()
			end
		end
	end
end)

-- EnteredLevel
Ext.Osiris.RegisterListener("EnteredLevel", 3, "after", function(object, objectRootTemplate, level)
	-- _P("Entered Level: " .. object .. " " .. IsCharacter(object) .. " " .. level)
	if IsCharacter(object) == 1 then
		if IsPartyMember(object, 0) == 1 then
			ApplyPartySingle(object)
		else
			ApplyOtherSingle(object)
		end
	end
end)

-- LongRestFinished
Ext.Osiris.RegisterListener("LongRestFinished", 0, "after", function()
	-- _P("LongRestFinished")
	ApplyOtherAll()
	ApplyPartyAll()
end)

-- CharacterJoinedParty
Ext.Osiris.RegisterListener("CharacterJoinedParty", 1, "after", function(entity)
	-- _P("Joined Party: " .. entity)
	ApplyPartySingle(entity)
end)

-- CharacterLeftParty
Ext.Osiris.RegisterListener("CharacterLeftParty", 1, "after", function(entity)
	-- _P("Left Party: " .. entity)
	RemovePartySingle(entity)
end)