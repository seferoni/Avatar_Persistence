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

	function createEventItemRemovalEntries( _itemsArray )
	{

	}

	function createEventResourceReductionEntries( _reductionTable )
	{

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

	function executePersistenceRoutine( _playerObject, _permanentInjurySustained = false )
	{
		this.worsenMoodOnStruckDown(_playerObject, _permanentInjurySustained);
		this.addToSurvivorRoster(_playerObject);
	}

	function fireDefeatEvent()
	{
		::Time.scheduleEvent(::TimeUnit.Real, 1000, function( _dummy )
		{
			::World.Events.fire("event.ap_defeat");
		}, null);
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

	function getPlayerInRoster( _rosterObject )
	{
		local rosterArray = _rosterObject.getAll();

		foreach( brother in rosterArray )
		{
			if (this.isActorViable(brother))
			{
				return brother;
			}
		}

		return null;
	}

	function getCulledItems()
	{
		local removedItems = [];
		local stash = ::World.Assets.getStash().getItems();

		foreach( item in stash )
		{
			if (removedItems.len() == ::AP.Standard.getParameter("ItemRemovalCeiling"))
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

			removedItems.push(item);
		}

		return removedItems;
	}

	function getCulledResources()
	{
		local reductionTable = {};
		local getReducedProportion = function( _resourceString )
		{
			local prefactor = ::AP.Standard.getPercentageParameter(format("%sLossPercentage", _resourceString));

			if (::AP.Standard.getParameter("RandomiseResourceLoss"))
			{
				prefactor = ::AP.Standard.randomFloat(0.0, prefactor);
			}

			return prefactor;
		}

		foreach( resourceString in this.getField("ResourceStrings") )
		{
			reductionTable[resourceString] = ::Math.floor(::World.Assets.m[resourceString] * getReducedProportion(resourceString));
		}

		return reductionTable;
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

	function isWithinInjuryThreshold( _playerObject )
	{
		local permanentInjuryCount = _playerObject.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();
		return permanentInjuryCount <= ::AP.Standard.getParameter("PermanentInjuryThreshold");
	}

	function removeItems( _itemsArray )
	{
		local stash = ::World.Assets.getStash().getItems();

		foreach( item in _itemsArray )
		{
			local index = stash.find(item);
			stash.remove(index);
		}

		::World.Assets.updateFood();
	}

	function reduceResources( _reductionTable )
	{
		foreach( resourceString, reducedMagnitude in _reductionTable )
		{
			::World.Assets.m[resourceString] = ::Math.max(0, ::World.Assets.m[resourceString] - reducedMagnitude);
		}
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