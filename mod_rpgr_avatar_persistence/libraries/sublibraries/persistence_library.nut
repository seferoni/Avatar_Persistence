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
	Parameters =
	{
		ElixirChance = 100
	},
	Tooltip =
	{
		Icons =
		{
			Persistence = "ui/icons/obituary.png",
			Warning = "ui/icons/warning.png"
		}
	}

	function executeDefeatRoutine()
	{
		local Standard = AP.Standard,
		get = @(_settingID) 1 - Standard.getPercentageSetting(_settingID);

		# Reduce resources as per user-configured percentage setting.
		::World.Assets.m.Money *= get("MoneyLossPercentage")
		::World.Assets.m.ArmorParts *= get("ToolsLossPercentage");
		::World.Assets.m.Medicine *= get("MedicineLossPercentage");
		::World.Assets.m.Ammo *= get("AmmoLossPercentage");

		# Remove items in stash.
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

	function getThresholdWarningText()
	{
		local threshold = AP.Standard.getSetting("PermanentInjuryThreshold");
		return threshold == 0 ? "any permanent injuries are sustained" : format("more than %s permanent injuries are sustained at a time", AP.Standard.colourWrap(threshold, AP.Standard.Colour.Red));
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