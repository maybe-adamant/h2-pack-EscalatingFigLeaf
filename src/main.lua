-- =============================================================================
-- BOILERPLATE (do not modify)
-- =============================================================================

local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']

config = chalk.auto('config.lua')
public.config = config

local NIL = {}
local backups = {}

local function backup(tbl, key)
    if not backups[tbl] then backups[tbl] = {} end
    if backups[tbl][key] == nil then
        local v = tbl[key]
        backups[tbl][key] = v == nil and NIL or (type(v) == "table" and DeepCopyTable(v) or v)
    end
end

local function restore()
    for tbl, keys in pairs(backups) do
        for key, v in pairs(keys) do
            tbl[key] = v == NIL and nil or (type(v) == "table" and DeepCopyTable(v) or v)
        end
    end
end

local function isEnabled()
    return config.Enabled
end

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "EscalatingFigLeaf",
    name     = "Incrementing Fig Leaf",
    category = "RunModifiers",
    group    = "World & Combat Tweaks",
    tooltip  = "Dionysus Skip Chance starts at default value and increases by 13% after every encounter, resetting on biome start.",
    default  = false,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
end

local function disable()
    restore()
end

local function registerHooks()
    modutil.mod.Path.Wrap("DionysusSkipTrait", function(baseFunc, args, traitData)
        if not isEnabled() then return baseFunc(args, traitData) end
        baseFunc(args, traitData)
        for _, trait in ipairs(CurrentRun.Hero.Traits) do
            if trait.Name == "PersistentDionysusSkipKeepsake" then
                trait.InitialSkipEncounterChance = trait.SkipEncounterChance
                trait.SkipEncounterGrowthPerRoom = 0.13
                break
            end
        end
    end)

    modutil.mod.Path.Wrap("EndEncounterEffects", function(baseFunc, currentRun, currentRoom, currentEncounter)
        if not isEnabled() then return baseFunc(currentRun, currentRoom, currentEncounter) end
        baseFunc(currentRun, currentRoom, currentEncounter)
        if currentEncounter == currentRoom.Encounter or currentEncounter == MapState.EncounterOverride then
            if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                if traitData.SkipEncounterChance and traitData.SkipEncounterGrowthPerRoom then
                    traitData.SkipEncounterChance = math.min(1, traitData.SkipEncounterChance + traitData.SkipEncounterGrowthPerRoom)
                end
            end
        end
    end)

    modutil.mod.Path.Wrap("StartRoom", function(baseFunc, currentRun, currentRoom)
        if not isEnabled() then return baseFunc(currentRun, currentRoom) end
        baseFunc(currentRun, currentRoom)
        if currentRoom.BiomeStartRoom then
            if HeroHasTrait("PersistentDionysusSkipKeepsake") then
                local traitData = GetHeroTrait("PersistentDionysusSkipKeepsake")
                if traitData.InitialSkipEncounterChance then
                    traitData.SkipEncounterChance = traitData.InitialSkipEncounterChance
                end
            end
        end
    end)
end

-- =============================================================================
-- PUBLIC API (do not modify)
-- =============================================================================

public.definition.enable = function()
    apply()
end

public.definition.disable = function()
    disable()
end

-- =============================================================================
-- LIFECYCLE (do not modify)
-- =============================================================================

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if config.Enabled then apply() end
    end)
end)

-- =============================================================================
-- STANDALONE UI (do not modify)
-- =============================================================================
-- When adamant-core is NOT installed, renders a minimal ImGui toggle.
-- When adamant-core IS installed, the core handles UI — this is skipped.

local imgui = rom.ImGui

local showWindow = false

rom.gui.add_imgui(function()
    if mods['adamant-Core'] then return end
    if not showWindow then return end

    if imgui.Begin(public.definition.name, true) then
        local val, chg = imgui.Checkbox("Enabled", config.Enabled)
        if chg then
            config.Enabled = val
            if val then apply() else disable() end
        end
        if imgui.IsItemHovered() and public.definition.tooltip ~= "" then
            imgui.SetTooltip(public.definition.tooltip)
        end
        imgui.End()
    else
        showWindow = false
    end
end)

rom.gui.add_to_menu_bar(function()
    if mods['adamant-Core'] then return end
    if imgui.BeginMenu("adamant") then
        if imgui.MenuItem(public.definition.name) then
            showWindow = not showWindow
        end
        imgui.EndMenu()
    end
end)
