::AP.Persistence <-
{
	Parameters =
	{
		EventAttempts = 0,
		EventAttemptsNominal = 20,
		MomentumStaminaInterval = 3,
		MomentumBaseIntervalBattles = 10
	}

	function addInjuryByScript( _injuryScript, _playerObject )
	{
		_playerObject.getSkills().add(::new(_injuryScript));
	}

	function addMomentum( _playerObject )
	{
		local skills = _playerObject.getSkills();

		if (skills.hasSkill("effects.ap_momentum"))
		{
			return;
		}

		skills.add(::new(this.getField("SkillPaths").Momentum));
	}

	function addToSurvivorRoster( _playerObject )
	{
		_playerObject.m.IsDying = false;
		::Tactical.getSurvivorRoster().add(_playerObject);
	}

	function canFireEvent()
	{
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
			if (reducedMagnitude == 0)
			{
				continue;
			}

			::AP.Standard.constructEntry
			(
				resourceKey,
				format(::AP.Strings.Events.Defeat.ScreenAListEntry, colourWrap(reducedMagnitude.tostring()), ::AP.Strings.Generic[resourceKey]),
				entries
			);
		}

		return entries;
	}

	function createMomentumResetEntry()
	{
		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return null;
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			::AP.Strings.getFragmentsAsCompiledString("ScreenAMomentumLossFragment", "Events", "Defeat", ::AP.Standard.Colour.Cyan)
		);
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
		local thresholdDifferential = this.getPermanentInjuryThresholdDifferential(_playerObject);

		local iconKey = "Warning";
		local tutorialText = format(::AP.Strings.Persistence.InjuryThresholdTooltip, ::AP.Standard.colourWrap(threshold, ::AP.Standard.Colour.Red));

		if (thresholdDifferential == 0)
		{
			tutorialText = ::AP.Strings.getFragmentsAsCompiledString("InjuryThresholdTooltipBaselineFragment", "Persistence");
		}
		else if (thresholdDifferential > 0)
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
		if (!::AP.Standard.getParameter("EnableDefeatEvent"))
		{
			return;
		}

		if (this.Parameters.EventAttempts > 0)
		{
			::Time.scheduleEvent(::TimeUnit.Real, 1000, function( _dummy )
			{
				::AP.Persistence.fireDefeatEvent();
			}, null);
			return;
		}

		this.executeFallbackRoutine();
		::logInfo("could not fire event!")
	}

	function executeFallbackRoutine()
	{
		local player = this.getPlayerInRoster(::World.getPlayerRoster());
		local culledItems = this.getCulledItems(player);
		local culledResources = this.getCulledResources();
		this.resetMomentum(player);
		this.removeItems(player, culledItems);
		this.reduceResources(culledResources);
	}

	function executePersistenceRoutine( _playerObject, _permanentInjurySustained = false )
	{
		this.worsenMoodOnStruckDown(_playerObject, _permanentInjurySustained);
		this.addToSurvivorRoster(_playerObject);
	}

	function fireDefeatEvent()
	{
		if (!this.canFireEvent())
		{
			::logInfo("attempt " + 22 - this.Parameters.EventAttempts)
			this.Parameters.EventAttempts--;
			this.executeDefeatRoutine();
			return;
		}

		::logInfo("firing event")
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

				if (!::AP.Persistence.isItemViableForRemoval(item))
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

	function getPermanentInjuryCount( _playerObject )
	{
		return _playerObject.getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();
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

	function getPermanentInjuryThresholdDifferential( _playerObject )
	{
		local permanentInjuries = this.getPermanentInjuryCount(_playerObject);
		return permanentInjuries - ::AP.Standard.getParameter("PermanentInjuryThreshold");
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

	function reduceResources( _reductionTable )
	{
		foreach( resourceString, reducedMagnitude in _reductionTable )
		{
			::World.Assets.m[resourceString] = ::Math.max(0, ::World.Assets.m[resourceString] - reducedMagnitude);
		}
	}

	function removeItems( _playerObject, _itemsArray )
	{
		local excess = [];
		local playerContainer = _playerObject.getItems();
		local stash = ::World.Assets.getStash().getItems();

		foreach( item in _itemsArray )
		{
			local index = stash.find(item);

			if (index == null)
			{
				excess.push(item);
				continue;
			}

			stash.remove(index);
		}

		foreach( item in excess )
		{
			local index = playerContainer.getAllItems().find(item);

			if (index != null)
			{
				playerContainer.unequip(item);
			}
		}

		::World.Assets.updateFood();
	}

	function resetEventAttempts()
	{
		this.Parameters.EventAttempts = this.Parameters.EventAttemptsNominal;
	}

	function resetMomentum( _playerObject )
	{
		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return;
		}

		_playerObject.getSkills().getSkillByID("effects.ap_momentum").resetMomentum();
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