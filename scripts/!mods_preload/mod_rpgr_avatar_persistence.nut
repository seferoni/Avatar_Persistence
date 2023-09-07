::RPGR_Avatar_Persistence <-
{
    ID = "mod_rpgr_avatar_persistence",
    Name = "RPG Rebalance - Avatar Persistence",
    Version = "1.1.3",

    function executePersistenceRoutine( _player, _injuryFlavourText )
    {
        _player.worsenMood(::Const.MoodChange.PermanentInjury, _injuryFlavourText);
        ::Tactical.getSurvivorRoster().add(_player);
        _player.m.IsDying = false;
        return false;
    }

    function generateInjuryCandidates( _player )
    {
        local permanentInjuries = ::Const.Injury.Permanent;
        local injuriesToCull = ["injury.missing_nose", "injury.missing_eye", "injury.missing_ear", "injury.brain_damage", "injury.missing_finger"];

        local filteredInjuries = permanentInjuries.filter(function( injuryIndex, injury )
        {
            local injuryID = injury.ID;
            return injuriesToCull.find(injuryID) == null && !_player.getSkills().hasSkill(injuryID);
        });

        return filteredInjuries;
    }

    function generateTooltipTableEntry( _id, _type, _icon, _text )
    {
        local tableEntry =
        {
            id = _id,
            type = _type,
            icon = "ui/icons/" + _icon,
            text = _text
        }

        return tableEntry;
    }

    function logWrapper( _string, _isError = false )
    {
        if (_isError)
        {
            ::logError("[Avatar Persistence] " + _string);
        }

        if (!::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("VerboseLogging").getValue())
        {
            return;
        }

        ::logInfo("[Avatar Persistence] " + _string);
    }

    function removeItemsUponCombatLoss()
    {
        local items = ::World.Assets.getStash().getItems();
        local garbage = items.filter(function( itemIndex, item )
        {
            return item != null && ::Math.rand(0, 100) <= ::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("ItemRemovalChance").getValue()  && ::RPGR_Avatar_Persistence.isItemEligibleForRemoval(item);
        });

        if (garbage.len() == 0)
        {
            return;
        }

        local naiveItemRemovalCeiling = ::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("ItemRemovalCeiling").getValue();
        local actualItemRemovalCeiling = naiveItemRemovalCeiling >= garbage.len() ? ::Math.rand(1, garbage.len()) : ::Math.rand(1, naiveItemRemovalCeiling); // TODO: sanity check this

        for( local i = 0; i <= actualItemRemovalCeiling - 1; i++ )
        {
            local item = garbage[i];
            local index  = items.find(item);
            this.logWrapper("Removing item " + item.getName() + " from stash.");
            items.remove(index);
        }
    }

    function retrieveThresholdWarningText()
    {
        local permanentInjuryThreshold = ::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue();
        return permanentInjuryThreshold == 0 ? "any permanent injuries are sustained" : "more than [color=" + ::Const.UI.Color.NegativeValue + "]" + permanentInjuryThreshold + "[/color] permanent injuries are sustained at a time";
    }

    function isActorEligible( _flags )
    {
        return _flags.get("IsPlayerCharacter");
    }

    function isPlayerInSurvivorRoster()
    {
        local survivorRoster = ::Tactical.getSurvivorRoster().getAll();

        foreach( brother in survivorRoster )
        {
            if (this.isActorEligible(brother.getFlags()))
            {
                return true;
            }
        }

        return false;
    }

    function isItemEligibleForRemoval( _item )
    {
        if (_item.isItemType(::Const.Items.ItemType.Legendary))
        {
            return false;
        }

        if (_item.m.ItemType == ::Const.Items.ItemType.Misc)
        {
            return false;
        }

        if (_item.getID() == "weapon.player_banner")
        {
            return false;
        }

        return true;
    }

    function isWithinInjuryThreshold( _player )
    {
        return _player.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len() <= this.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue();
    }
};

::mods_registerMod(::RPGR_Avatar_Persistence.ID, ::RPGR_Avatar_Persistence.Version, ::RPGR_Avatar_Persistence.Name);
::mods_queue(::RPGR_Avatar_Persistence.ID, "mod_msu(>=1.2.6)", function()
{
    ::RPGR_Avatar_Persistence.Mod <- ::MSU.Class.Mod(::RPGR_Avatar_Persistence.ID, ::RPGR_Avatar_Persistence.Version, ::RPGR_Avatar_Persistence.Name);
    ::RPGR_AR_ModuleFound <- ::mods_getRegisteredMod("mod_rpgr_avatar_resistances") != null;

    local pageGeneral = ::RPGR_Avatar_Persistence.Mod.ModSettings.addPage("General");
    local pageItemLoss = ::RPGR_Avatar_Persistence.Mod.ModSettings.addPage("Item Loss");

    local permanentInjuryChance = pageGeneral.addRangeSetting("PermanentInjuryChance", 100, 1, 100, 1, "Permanent Injury Chance");
    permanentInjuryChance.setDescription("Determines the percentage chance for the player character to suffer permanent injuries upon defeat.");

    local permanentInjuryThreshold = pageGeneral.addRangeSetting("PermanentInjuryThreshold", 1, 0, 8, 1, "Permanent Injury Threshold");
    permanentInjuryThreshold.setDescription("Determines the threshold value of the number of permanent injuries the player character can have before persistence is lost.");

    local itemRemovalChance = pageItemLoss.addRangeSetting("ItemRemovalChance", 33, 1, 100, 1, "Item Removal Chance");
    itemRemovalChance.setDescription("Determines the percentage chance for individual items to be removed from the player's stash. Does nothing if Lose Items Upon Defeat is disabled.");

    local itemRemovalCeiling = pageItemLoss.addRangeSetting("ItemRemovalCeiling", 6, 1, 10, 1, "Item Removal Ceiling");
    itemRemovalCeiling.setDescription("Determines the maximum number of items that may be removed per instance of player defeat. Does nothing if Lose Items Upon Defeat is disabled.");

    local loseItemsUponDefeat = pageGeneral.addBooleanSetting("LoseItemsUponDefeat", false, "Lose Items Upon Defeat");
    loseItemsUponDefeat.setDescription("Determines whether items kept in the player's stash are removed at random upon defeat, in the case of persistence.");

    local modifyTooltip = pageGeneral.addBooleanSetting("ModifyTooltip", true, "Modify Tooltip");
    modifyTooltip.setDescription("Determines whether the player character trait tooltip reflects changes brought about by this mod.");

    local verboseLogging = pageGeneral.addBooleanSetting("VerboseLogging", false, "Verbose Logging");
    verboseLogging.setDescription("Enables verbose logging. Recommended for testing purposes only, as the volume of logged messages can make parsing the log more difficult for general use and debugging.");

    foreach( file in ::IO.enumerateFiles("mod_rpgr_avatar_persistence/hooks") )
    {
        ::include(file);
    }
});