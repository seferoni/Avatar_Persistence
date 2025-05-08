::AP.Persistence <-
{
	Parameters =
	{
		EventTimingMilliseconds = 500
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

		// TODO: testing virtual instead of real
		::Time.scheduleEvent(::TimeUnit.Real, this.Parameters.EventTimingMilliseconds, function( _dummy )
		{
			::AP.EventHandler.fireDefeatEvent();
		}, null);
	}

	function executeFallbackRoutine()
	{
		local playerCharacter = ::AP.Utilities.getPlayerInRoster(::World.getPlayerRoster());
		::AP.Skills.resetMomentum(playerCharacter);
		::AP.Items.removeItemsFromStashAndPlayerCharacter(playerCharacter, this.getCulledItems(playerCharacter));
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

				if (!::AP.Items.isItemViableForRemoval(item))
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

		foreach( resourceKey in ::AP.Utilities.getCommonField("ResourceKeys") )
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
		local flavourText = ::AP.Utilities.getTooltipString("MoodStruckDownTooltip");
		local moodMagnitude = ::AP.Utilities.getCommonField("MoodChanges").StruckDown;

		if (_permanentInjurySustained)
		{
			flavourText = ::AP.Utilities.getTooltipString("MoodPermanentInjuryTooltip");
			moodMagnitude = ::AP.Utilities.getCommonField("MoodChanges").PermanentInjury;
		}

		_playerObject.worsenMood(moodMagnitude, flavourText);
	}
};