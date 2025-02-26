::AP.Persistence <-
{
	Parameters =
	{
		SkippedTimePrefactor = 1.5,
	}

	function addInjuryByScript( _injuryScript, _playerObject )
	{
		_playerObject.getSkills().add(::new(_injuryScript));
	}

	function addToSurvivorRoster( _playerObject )
	{
		_playerObject.m.IsDying = false;
		::Tactical.getSurvivorRoster().add(_playerObject);
	}

	function createTooltipEntries( _playerObject )
	{
		local entries = [];
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		push(this.createTutorialEntry(_playerObject));
		return entries;
	}

	function createTutorialEntry( _playerObject )
	{
		local threshold = ::AP.Standard.getParameter("PermanentInjuryThreshold");
		local tutorialText = ::AP.Strings.getFragmentsAsCompiledString("InjuryThresholdTooltipBaselineFragment", "Generic");

		if (threshold != 0)
		{
			tutorialText = format(::AP.Strings.Generic.InjuryThresholdTooltip, ::AP.Standard.colourWrap(threshold, ::AP.Standard.Colour.Red));
		}

		local iconKey = "Warning";
		local exceedsThreshold = !this.isWithinInjuryThreshold(_playerObject);

		if (exceedsThreshold)
		{
			iconKey = "Skull";
			tutorialText = ::AP.Standard.colourWrap(::AP.Strings.Generic.InjuryThresholdExceededTooltip, ::AP.Standard.Colour.Red);
		}

		return ::AP.Standard.constructEntry
		(
			iconKey,
			tutorialText
		);
	}

	function displaceParty()
	{
		// TODO:
	}

	function executeDefeatRoutine()
	{
		this.reduceResources();
		this.removeItemsUponCombatLoss();
	}

	function executePersistenceRoutine( _playerObject, _permanentInjurySustained = false )
	{
		this.worsenMoodOnStruckDown(_playerObject, _permanentInjurySustained);
		this.addToSurvivorRoster(_playerObject);
	}

	function generateInjuryCandidates( _player )
	{
		return ::Const.Injury.Permanent.filter(function(_injuryIndex, _injuryTable)
		{
			if (::AP.Persistence.getField("ExcludedInjuries").find(_injuryTable.ID) != null)
			{
				return false;
			}

			if (_player.getSkills().hasSkill(_injuryTable.ID))
			{
				return false;
			}

			return true;
		});
	}

	function getField( _fieldName )
	{
		return ::AP.Database.getField("Generic", _fieldName);
	}

	function isActorViable( _actor )
	{
		return ::AP.Standard.getFlag("IsPlayerCharacter", _actor);
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

		if (this.getField("ExcludedItems").find(_item.getID()) != null)
		{
			return false;
		}

		return true;
	}

	function isPlayerInRoster( _rosterObject )
	{
		local rosterArray = _rosterObject.getAll();

		foreach( brother in rosterArray )
		{
			if (this.isActorViable(brother))
			{
				return true;
			}
		}

		return false;
	}

	function isWithinInjuryThreshold( _playerObject )
	{
		local permanentInjuryCount = _playerObject.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();
		return permanentInjuryCount <= ::AP.Standard.getParameter("PermanentInjuryThreshold");
	}

	function reduceResources()
	{
		local getRetainedProportion = @(_resourceString) 1 - ::AP.Standard.getPercentageParameter(format("%sLossPercentage", _resourceString));

		foreach( resourceString in this.getField("ResourceStrings") )
		{
			::World.Assets.m[resourceString] = ::Math.floor(::World.Assets.m[resourceString] * getRetainedProportion(resourceString));
		}
	}

	function removeItemsUponCombatLoss()
	{
		local garbage = [];
		local stash = ::World.Assets.getStash().getItems();

		foreach( item in stash )
		{
			if (garbage.len() == ::AP.Standard.getParameter("ItemRemovalCeiling"))
			{
				break;
			}

			if (item == null)
			{
				continue;
			}

			if (!this.isItemViableForRemoval(item))
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

		::World.Assets.updateFood();
	}

	function skipTime()
	{	// TODO: this has yet to be implemented
		local newTime = ::Time.getVirtualTimeF() + ::World.getTime().SecondsPerDay * this.Parameters.SkippedTimePrefactor;
		::Time.setVirtualTime(newTime);
	}

	function worsenMoodOnStruckDown( _playerObject, _permanentInjurySustained )
	{
		local flavourText = ::AP.Strings.Generic.MoodStruckDownTooltip;
		local moodChanges = this.getField("MoodChanges");
		local moodMagnitude = moodChanges.StruckDown;

		if (_permanentInjurySustained)
		{
			flavourText = ::AP.Strings.Generic.MoodPermanentInjuryTooltip;
			moodMagnitude = moodChanges.PermanentInjury;
		}

		_playerObject.worsenMood(moodMagnitude, flavourText);
	}
};