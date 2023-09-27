local AP = ::RPGR_Avatar_Persistence;
AP.Persistence <-
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
        return ::Const.Injury.Permanent.filter(@(injuryIndex, injury) injuriesToCull.find(injury.ID) == null && !_player.getSkills().hasSkill(injury.ID));
    }

    function getThresholdWarningText()
    {
        local permanentInjuryThreshold = AP.Standard.getSetting("PermanentInjuryThreshold");
        return permanentInjuryThreshold == 0 ? "any permanent injuries are sustained" : "more than [color=" + ::Const.UI.Color.NegativeValue + "]" + permanentInjuryThreshold + "[/color] permanent injuries are sustained at a time";
    }

    function removeItemsUponCombatLoss()
    {
        local items = ::World.Assets.getStash().getItems(),
        garbage = items.filter(function( _itemIndex, _item )
        {
            return _item != null && ::Math.rand(1, 100) <= AP.Standard.getSetting("ItemRemovalChance")  && AP.Persistence.isItemEligibleForRemoval(_item);
        });

        if (garbage.len() == 0)
        {
            return;
        }

        local naiveItemRemovalCeiling = AP.Standard.getSetting("ItemRemovalCeiling");
        local actualItemRemovalCeiling = naiveItemRemovalCeiling >= garbage.len() ? ::Math.rand(1, garbage.len()) : ::Math.rand(1, naiveItemRemovalCeiling); // TODO: sanity check this

        for( local i = 0; i <= actualItemRemovalCeiling - 1; i++ )
        {
            local index  = items.find(garbage[i]);
            this.logWrapper(format("Removing item %s from stash.", item.getName()));
            items.remove(index); // TODO: write a method for this in standard with validation
        }
    }

    function isActorViable( _actor )
    {
        return _actor.getFlags().get("IsPlayerCharacter");
    }

    function isPlayerInSurvivorRoster()
    {
        local survivorRoster = ::Tactical.getSurvivorRoster().getAll();

        foreach( brother in survivorRoster )
        {
            if (this.isActorViable(brother))
            {
                return true;
            }
        }

        return false;
    }

    function isItemViableForRemoval( _item )
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
        return _player.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len() <= AP.Standard.getSetting("PermanentInjuryThreshold");
    }
}