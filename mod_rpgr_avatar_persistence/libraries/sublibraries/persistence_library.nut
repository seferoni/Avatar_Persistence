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
	Paths =
	{
		Elixir = "scripts/items/special/elixir_item"
	},
	Resources =
	[
		"Ammo",
		"ArmorParts",
		"Medicine",
		"Money"
	],
	Rosters =
	{
		Survivor = ::Tactical.getSurvivorRoster,
		World = ::World.getPlayerRoster
	},
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
		local filteredInjuries = ::Const.Injury.Permanent.filter(@(_injuryIndex, _injuryTable) AP.Persistence.Excluded.find(_injuryTable.ID) == null && !_player.getSkills().hasSkill(_injuryTable.ID));
		return filteredInjuries;
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
		local garbage = [],
		skipCurrent = @() ::Math.rand(1, 100) > 50,
		itemRemovalCount = AP.Standard.getSetting("ItemRemovalCeiling"),
		stash = ::World.Assets.getStash().getItems();
		
		foreach( item in stash )
		{
			if (garbage.len() == itemRemovalCount)
			{
				break;
			}

			if (item == null)
			{
				continue;
			}

			if (!AP.Persistence.isItemViableForRemoval(item))
			{
				continue;
			}

			if (skipCurrent())
			{
				continue;
			}

			garbage.push(item);
		}

		foreach( item in garbage )
		{
			local index = stash.find(item);
			stash.remove(index);
		}
	}

	function isActorViable( _actor )
	{
		return AP.Standard.getFlag("IsPlayerCharacter", _actor);
	}

	function isCombatInArena()
	{
		return ::Tactical.State.m.StrategicProperties != null && ::Tactical.State.m.StrategicProperties.IsArenaMode;
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

	function isPlayerInRoster( _rosterType )
	{
		local roster = _rosterType().getAll();

		foreach( brother in roster )
		{
			if (this.isActorViable(brother))
			{
				return true;
			}
		}

		return false;
	}

	function isWithinInjuryThreshold( _player )
	{
		return _player.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len() <= AP.Standard.getSetting("PermanentInjuryThreshold");
	}
}