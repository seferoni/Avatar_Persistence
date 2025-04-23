::AP.Persistence <-
{
	Parameters =
	{
		EventTimingMilliseconds = 1250
	}

	function addToSurvivorRoster( _playerObject )
	{
		_playerObject.m.IsDying = false;
		::Tactical.getSurvivorRoster().add(_playerObject);
	}

	function executeDefeatRoutine()
	{
		if (!::AP.Standard.getParameter("EnableDefeatEvent"))
		{
			return;
		}

		::Time.scheduleEvent(::TimeUnit.Real, this.Parameters.EventTimingMilliseconds, function( _dummy )
		{
			::AP.EventHandler.fireDefeatEvent();
		}, null);
	}

	function executeFallbackRoutine()
	{
		local playerCharacter = this.getPlayerInRoster(::World.getPlayerRoster());
		::AP.Skills.resetMomentum(playerCharacter);
		::AP.StashHandler.removeItems(playerCharacter, this.getCulledItems(playerCharacter));
		::AP.Utilities.reduceResources(this.getCulledResources());
	}

	function executePersistenceRoutine( _playerObject, _permanentInjurySustained = false )
	{
		this.worsenMoodOnStruckDown(_playerObject, _permanentInjurySustained);
		this.addToSurvivorRoster(_playerObject);
	}

	function getCulledItems( _playerObject )
	{
		local removedItems = [];
		local removalCount = ::Math.rand(0, ::AP.Standard.getParameter("ItemRemovalCeiling"));
		local collate = function( _itemsArray )
		{
			foreach( item in _itemsArray )
			{
				if (removedItems.len() == removalCount)
				{
					return;
				}

				if (item == null)
				{
					continue;
				}

				if (!::AP.StashHandler.isItemViableForRemoval(item))
				{
					continue;
				}

				removedItems.push(item);
			}
		};

		collate(_playerObject.getItems().getAllItems());
		collate(::World.Assets.getStash().getItems());
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
		};

		foreach( resourceKey in ::AP.Utilities.getField("ResourceKeys") )
		{
			reductionTable[resourceKey] <- ::Math.floor(::World.Assets.m[resourceKey] * getReducedProportion(resourceKey));
		}

		return reductionTable;
	}

	function getQueueDefeatRoutineState()
	{
		return ::AP.Standard.getFlag("QueueDefeatRoutine", ::World.Statistics);
	}

	function setQueueDefeatRoutineState( _boolean )
	{
		::AP.Standard.setFlag("QueueDefeatRoutine", _boolean, ::World.Statistics);
	}

	function worsenMoodOnStruckDown( _playerObject, _permanentInjurySustained )
	{
		local flavourText = ::AP.Strings.Generic.PersistenceTooltips.MoodStruckDownTooltip;
		local moodMagnitude = ::AP.Utilities.getField("MoodChanges").StruckDown;

		if (_permanentInjurySustained)
		{
			flavourText = ::AP.Strings.Generic.PersistenceTooltips.MoodPermanentInjuryTooltip;
			moodMagnitude = ::AP.Utilities.getField("MoodChanges").PermanentInjury;
		}

		_playerObject.worsenMood(moodMagnitude, flavourText);
	}
};