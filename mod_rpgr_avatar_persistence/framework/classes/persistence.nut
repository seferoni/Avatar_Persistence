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

	function canFireEvent()
	{
		if (!::AP.Standard.getSetting("EnableDefeatEvent"))
		{
			return false;
		}

		if (::World.State.getMenuStack().hasBacksteps())
		{
			return false;
		}

		if (::LoadingScreen != null && (::LoadingScreen.isAnimating() || ::LoadingScreen.isVisible()))
		{
			return false;
		}

		if (::World.State.m.EventScreen.isVisible() || ::World.State.m.EventScreen.isAnimating())
		{
			return false;
		}

		if (("State" in ::Tactical) && ::Tactical.State != null)
		{
			return false;
		}

		if (::World.Events.hasActiveEvent())
		{
			return false;
		}

		return true;
	}

	function createEventItemRemovalEntries( _itemsArray )
	{
		local entries = [];
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		foreach( item in _itemsArray )
		{
			local entry = ::AP.Standard.constructEntry
			(
				null,
				format(::AP.Strings.Events.Defeat.ScreenAListEntry, "", item.getName())
			);
			entry.icon <- format("ui/items/%s", item.getIcon());
			push(entry);
		}

		return entries;
	}

	function createEventResourceReductionEntries( _reductionTable )
	{
		local entries = [];
		local colourWrap = @(_string) ::AP.Standard.colourWrap(_string, ::AP.Standard.Colour.Orange);

		foreach( resourceKey, reducedMagnitude in _reductionTable )
		{
			::AP.Standard.constructEntry
			(
				resourceKey,
				format(::AP.Strings.Events.Defeat.ScreenAListEntry, colourWrap(reducedMagnitude.tostring()), ::AP.Strings.Generic[resourceKey]),
				entries
			);
		}

		return entries;
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
			tutorialText = format(::AP.Strings.Persistence.InjuryThresholdTooltip, ::AP.Standard.colourWrap(threshold, ::AP.Standard.Colour.Red));
		}

		local iconKey = "Warning";
		local exceedsThreshold = !this.isWithinInjuryThreshold(_playerObject);

		if (exceedsThreshold)
		{
			iconKey = "Skull";
			tutorialText = ::AP.Standard.colourWrap(::AP.Strings.Persistence.InjuryThresholdExceededTooltip, ::AP.Standard.Colour.Red);
		}

		return ::AP.Standard.constructEntry
		(
			iconKey,
			tutorialText
		);
	}

	function executeDefeatRoutine()
	{
		::AP.Persistence.reduceResources(this.getCulledResources());
		::AP.Persistence.removeItems(this.getCulledItems());
	}

	function executePersistenceRoutine( _playerObject, _permanentInjurySustained = false )
	{
		this.worsenMoodOnStruckDown(_playerObject, _permanentInjurySustained);
		this.addToSurvivorRoster(_playerObject);
	}

	function fireDefeatEvent()
	{	// TODO: this implementation will need to change to prevent staggered item and resource loss
		if (!this.canFireEvent())
		{
			this.executeDefeatRoutine();
			return;
		}

		::World.Events.fire("event.ap_defeat");
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
			reductionTable[resourceString] <- ::Math.floor(::World.Assets.m[resourceString] * getReducedProportion(resourceString));
		}

		return reductionTable;
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

	function getQueueDefeatRoutineState()
	{
		return ::AP.Standard.getFlag("QueueDefeatRoutine", ::World.Statistics);
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

	function setQueueDefeatRoutineState( _boolean )
	{
		::AP.Standard.setFlag("QueueDefeatRoutine", _boolean, ::World.Statistics);
	}

	function worsenMoodOnStruckDown( _playerObject, _permanentInjurySustained )
	{
		local flavourText = ::AP.Strings.Persistence.MoodStruckDownTooltip;
		local moodMagnitude = this.getField("MoodChanges").StruckDown;

		if (_permanentInjurySustained)
		{
			flavourText = ::AP.Strings.Persistence.MoodPermanentInjuryTooltip;
			moodMagnitude = this.getField("MoodChanges").PermanentInjury;
		}

		_playerObject.worsenMood(moodMagnitude, flavourText);
	}
};