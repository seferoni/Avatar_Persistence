local AP = ::RPGR_Avatar_Persistence;
AP.Persistence <-
{
	Excluded =
	[
		"injury.missing_nose",
		"injury.missing_eye",
		"injury.missing_ear",
		"injury.missing_finger"
	],
	FlavourText =
	{
		Uninjured = "Was struck down",
		Injured = "Was grievously struck down"
	},
	Resources =
	[
		"Ammo",
		"ArmorParts",
		"Medicine",
		"Money"
	],
	Tooltip =
	{
		Icons =
		{
			Warning = "ui/icons/warning.png"
		}
	}

	function createTooltipEntries()
	{
		local tooltipArray = [],
		push = @(_entry) tooltipArray.push(_entry);

		local threshold = AP.Standard.getSetting("PermanentInjuryThreshold"),
		warningText = "Loses persistence when any permanent injuries are sustained";

		# Amend entry text if user-configured permanent injury threshold is non-zero - that is, if some allowance can be made before persistence is lost.
		if (threshold != 0)
		{
			warningText = format("Loses persistence when more than %s permanent injuries are sustained at a time", AP.Standard.colourWrap(threshold, AP.Standard.Colour.Red));
		}

		# Create warning entry.
		push({id = 10, type = "text", icon = this.Tooltip.Icons.Warning, text = warningText});
		return tooltipArray;
	}

	function executeDefeatRoutine()
	{
		this.reduceResources();
		this.removeItemsUponCombatLoss();
	}

	function executePersistenceRoutine( _player, _flavourText )
	{
		_player.worsenMood(::Const.MoodChange.PermanentInjury, _flavourText);
		::Tactical.getSurvivorRoster().add(_player);
		_player.m.IsDying = false;
		return false;
	}

	function generateInjuryCandidates( _player )
	{
		local injuriesToCull = this.Excluded;
		return ::Const.Injury.Permanent.filter(@(_injuryIndex, _injury) injuriesToCull.find(_injury.ID) == null && !_player.getSkills().hasSkill(_injury.ID));
	}

	function reduceResources()
	{
		local get = @(_settingID) 1 - AP.Standard.getPercentageSetting(_settingID);

		foreach( resource in this.Resources )
		{
			local currentValue = ::World.Assets.m[resource];
			::World.Assets.m[resource] = ::Math.floor(currentValue * get(format("%sLossPercentage", resource)));
		}
	}

	function removeItemsUponCombatLoss()
	{
		local items = ::World.Assets.getStash().getItems(),
		candidates = items.filter(function( _itemIndex, _item )
		{
			return _item != null && AP.Persistence.isItemViableForRemoval(_item);
		});

		if (candidates.len() == 0)
		{
			return;
		}

		local count = 0,
		naiveCeiling = AP.Standard.getSetting("ItemRemovalCeiling"),
		actualCeiling = ::Math.rand(1, ::Math.min(candidates.len(), naiveCeiling));

		while( count < actualCeiling )
		{
			local index  = items.find(candidates[::Math.rand(0, candidates.len() - 1)]);
			items.remove(index);
			count++;
		}
	}

	function isActorViable( _actor )
	{
		return AP.Standard.getFlag("IsPlayerCharacter", _actor);
	}

	function isPlayerInRoster()
	{
		local roster = ::World.getPlayerRoster().getAll();

		foreach( brother in roster )
		{
			if (this.isActorViable(brother))
			{
				return true;
			}
		}

		return false;
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