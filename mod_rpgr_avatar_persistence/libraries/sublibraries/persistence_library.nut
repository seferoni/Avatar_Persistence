local AP = ::RPGR_Avatar_Persistence;
AP.Persistence <-
{
    function executePersistenceRoutine( _player, _flavourText )
    {
        _player.worsenMood(::Const.MoodChange.PermanentInjury, _flavourText);
        ::Tactical.getSurvivorRoster().add(_player);
        _player.m.IsDying = false;
        return false;
    }

    function generateInjuryCandidates( _player )
    {
        local injuriesToCull = ["injury.missing_nose", "injury.missing_eye", "injury.missing_ear", "injury.brain_damage", "injury.missing_finger"];
        return ::Const.Injury.Permanent.filter(@(_injuryIndex, _injury) injuriesToCull.find(_injury.ID) == null && !_player.getSkills().hasSkill(_injury.ID));
    }

    function getThresholdWarningText()
    {
        local threshold = AP.Standard.getSetting("PermanentInjuryThreshold");
        return threshold == 0 ? "any permanent injuries are sustained" : format("more than %s permanent injuries are sustained at a time", AP.Standard.colourWrap(threshold, "NegativeValue"));
    }

    function removeItemsUponCombatLoss()
    {
        local items = ::World.Assets.getStash().getItems(),
        garbage = items.filter(function( _itemIndex, _item )
        {
            return _item != null && ::Math.rand(1, 100) <= AP.Standard.getSetting("ItemRemovalChance")  && AP.Persistence.isItemViableForRemoval(_item);
        });

        if (garbage.len() == 0)
        {
            return;
        }

        local naiveCeiling = AP.Standard.getSetting("ItemRemovalCeiling"),
        actualCeiling = naiveCeiling >= garbage.len() ? ::Math.rand(1, garbage.len() - 1) : ::Math.rand(1, naiveCeiling);

        for( local i = 0; i <= actualCeiling; i++ )
        {
            local index  = items.find(garbage[i]);
            AP.Standard.log(format("Removing item %s from stash.", item.getName()));
            items.remove(index);
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