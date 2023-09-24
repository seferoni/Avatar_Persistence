::RPGR_Avatar_Persistence.Persistence <-
{
    function executePersistenceRoutine( _player, _injuryFlavourText )
    {
        _player.worsenMood(::Const.MoodChange.PermanentInjury, _injuryFlavourText);
        ::Tactical.getSurvivorRoster().add(_player);
        _player.m.IsDying = false;
        return false;
    }

    function generateInjuryCandidates( _player )
    {
        local injuriesToCull = ["injury.missing_nose", "injury.missing_eye", "injury.missing_ear", "injury.brain_damage", "injury.missing_finger"];
        local filteredInjuries = ::Const.Injury.Permanent.filter(@(injuryIndex, injury) injuriesToCull.find(injury.ID) == null && !_player.getSkills().hasSkill(injury.ID));
        return filteredInjuries;
    }

    function getThresholdWarningText()
    {
        local permanentInjuryThreshold = ::RPGR_Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue();
        return permanentInjuryThreshold == 0 ? "any permanent injuries are sustained" : "more than [color=" + ::Const.UI.Color.NegativeValue + "]" + permanentInjuryThreshold + "[/color] permanent injuries are sustained at a time";
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

        local naiveItemRemovalCeiling = ::RPGR_Avatar_Persistence.Standard.getSetting("ItemRemovalCeiling");
        local actualItemRemovalCeiling = naiveItemRemovalCeiling >= garbage.len() ? ::Math.rand(1, garbage.len()) : ::Math.rand(1, naiveItemRemovalCeiling); // TODO: sanity check this

        for( local i = 0; i <= actualItemRemovalCeiling - 1; i++ )
        {
            local item = garbage[i];
            local index  = items.find(item);
            this.logWrapper("Removing item " + item.getName() + " from stash.");
            items.remove(index);
        }
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
}