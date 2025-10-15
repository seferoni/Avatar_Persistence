this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{
	m = {},
	function create()
	{
		this.ap_skill.create();
		this.assignPropertiesByName("Momentum");
		this.initialiseFlags();
	}

	function applySkillBonuses( _currentProperties )
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			_currentProperties[attribute] += this.getAttributeBonus(attribute);
		}
	}

	function createAttributeEntries()
	{
		local entries = [];
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			local bonus = this.getAttributeBonus(attribute);

			if (bonus == 0)
			{
				continue;
			}

			::AP.Standard.constructEntry
			(
				attribute,
				format("%s %s", ::AP.Standard.colourWrap(format("+%i", bonus), ::AP.Standard.Colour.Green), ::AP.Utilities.getAttributeString(attribute)),
				entries
			);
		}

		if (entries.len() == 0)
		{
			::AP.Standard.constructEntry
			(
				"Warning",
				::AP.Standard.colourWrap(this.getString("NoBonuses"), ::AP.Standard.Colour.Red),
				entries
			);
		}

		return entries;
	}

	function createMomentumStateEntry()
	{
		local colour = ::AP.Standard.Colour.Red;
		local suffix = this.getString("StateRosterThresholdExceeded");
		local bonusMultiplier = this.getAttributeBonusMultiplier();

		if (this.isWithinRosterThreshold())
		{
			colour = ::AP.Standard.Colour.Green;
			suffix = this.getString("StateBelowRosterThreshold");
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			format("%s %s (x%i)", this.getString("StatePrefix"), ::AP.Standard.colourWrap(suffix, colour), bonusMultiplier)
		);
	}

	function createMomentumTutorialEntry()
	{
		local rosterDifferential = this.getRosterThresholdDifferential();
		local colour = @(_string) ::AP.Standard.colourWrap(_string, ::AP.Standard.Colour.Red);

		local iconKey = "Warning";
		local text = format(this.getString("RosterThresholdTooltip"), colour(::Math.abs(rosterDifferential) + 1));

		if (rosterDifferential >= 1)
		{
			iconKey = "Locked";
			text = format(this.getString("RosterThresholdExceededTooltip"), colour(::AP.Standard.getParameter("MomentumRosterThreshold")));
		}
		else if (rosterDifferential == 0)
		{
			text = colour(this.getString("RosterThresholdTooltipBaseline"));
		}

		return ::AP.Standard.constructEntry
		(
			iconKey,
			text
		);
	}

	function createScalingChanceEntries()
	{
		local entries = [];
		local push = @(_entry) ::AP.Standard.push(_entry, entries);
		local colour = @(_string, _colour) ::AP.Standard.colourWrap(_string, ::AP.Standard.Colour[_colour]);
		local activeScalingChance = ::AP.Standard.getParameter("MomentumActiveScalingChance");

		::AP.Standard.constructEntry
		(
			"Special",
			format(this.getString("ActiveScalingChance"), colour(activeScalingChance, "Green")),
			entries
		);

		local passiveScalingChance = ::AP.Standard.getParameter("MomentumPassiveScalingChance");
		local passiveScalingCap = ::AP.Standard.getParameter("MomentumPassiveScalingCap") * this.getAttributeBonusMultiplier();
		local passiveScalingText = format(this.getString("PassiveScalingChance"), colour(passiveScalingChance, "Green"), colour(format("+%i", passiveScalingCap), "Green"));

		if (!this.isPlayerEligibleForPassiveScaling())
		{
			passiveScalingText = colour(this.getString("PassiveScalingCapExceeded"), "Red");
		}

		::AP.Standard.constructEntry
		(
			"Time",
			passiveScalingText,
			entries
		);

		return entries;
	}

	function getAttributeBonus( _attributeKey )
	{
		return this.getNaiveAttributeBonus(_attributeKey) * this.getAttributeBonusMultiplier();
	}

	function getAttributeBonusMultiplier()
	{
		local nominalMultiplier = 1;

		if (!this.isWithinRosterThreshold())
		{
			return nominalMultiplier;
		}

		nominalMultiplier++;
		local permanentInjuryCount = ::AP.Skills.getPermanentInjuryCount(this.getContainer().getActor());

		if (permanentInjuryCount > 0)
		{
			nominalMultiplier += ::Math.min(permanentInjuryCount, 3);
		}

		return nominalMultiplier;
	}

	function getNaiveAttributeBonus( _attributeKey )
	{
		local baseBonus = ::AP.Standard.getFlag(_attributeKey, this);

		if (baseBonus == false)
		{	# Rendered entirely redundant by initialiseFlags, but left for posterity.
			return 0;
		}

		return baseBonus;
	}

	function getRosterThresholdDifferential()
	{
		local currentRosterSize = ::AP.Utilities.getCurrentRosterSize();
		return currentRosterSize - ::AP.Standard.getParameter("MomentumRosterThreshold");
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createMomentumStateEntry());
		push(this.createMomentumTutorialEntry());
		push(this.createScalingChanceEntries());
		push(this.createAttributeEntries());
		return tooltipArray;
	}

	function getScalableAttributesByEntity( _targetEntity )
	{
		local scalableAttributes = [];
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			if (!this.isAttributeEligibleForScaling(_targetEntity, attribute))
			{
				continue;
			}

			scalableAttributes.push(attribute);
		}

		return scalableAttributes;
	}

	function getViableAttributesForScaling()
	{
		return this.getSkillData().ScalableAttributes;
	}

	function getViableAttributesForPassiveScaling()
	{
		return this.getSkillData().PassiveScalableAttributes;
	}

	function incrementAttributeBonus( _attributeKey )
	{
		this.setAttributeBonus(_attributeKey, this.getNaiveAttributeBonus(_attributeKey) + 1);
	}

	function initialiseFlags()
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			if (this.getNaiveAttributeBonus(attribute) != false)
			{
				continue;
			}

			this.setAttributeBonus(attribute, 0);
		}
	}

	function isAttributeEligibleForScaling( _targetEntity, _attribute )
	{
		local playerProperties = this.getContainer().getActor().getBaseProperties();
		local baseBonus = this.getNaiveAttributeBonus(_attribute);
		local targetProperties = _targetEntity.getBaseProperties();

		if (playerProperties[_attribute] + baseBonus >= targetProperties[_attribute])
		{
			return false;
		}

		return true;
	}

	function isPlayerEligibleForPassiveScaling()
	{
		local scalableAttributes = this.getViableAttributesForPassiveScaling();

		foreach( attribute in scalableAttributes )
		{
			local baseBonus = this.getNaiveAttributeBonus(attribute);
			local passiveScalingCap = ::AP.Standard.getParameter("MomentumPassiveScalingCap");

			if (baseBonus < passiveScalingCap)
			{
				return true;
			}
		}

		return false;
	}

	function isWithinRosterThreshold()
	{
		return this.getRosterThresholdDifferential() <= 0;
	}

	function onNewDay()
	{
		if (::Math.rand(1, 100) > ::AP.Standard.getParameter("MomentumPassiveScalingChance"))
		{
			return;
		}

		if (!this.isPlayerEligibleForPassiveScaling())
		{
			return;
		}

		local scalableAttributes = this.getViableAttributesForPassiveScaling();

		foreach( attribute in scalableAttributes )
		{
			local baseBonus = this.getNaiveAttributeBonus(attribute);

			if (baseBonus > ::AP.Standard.getParameter("MomentumPassiveScalingCap"))
			{
				continue;
			}

			this.incrementAttributeBonus(attribute);
		}
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		if (_targetEntity == null)
		{
			return;
		}

		if (::Math.rand(1, 100) > ::AP.Standard.getParameter("MomentumActiveScalingChance"))
		{
			return;
		}

		local scalableAttributes = this.getScalableAttributesByEntity(_targetEntity);

		if (scalableAttributes.len() == 0)
		{
			return;
		}

		this.spawnOverlayOnCurrentTile();
		this.incrementAttributeBonus(scalableAttributes[::Math.rand(0, scalableAttributes.len() - 1)]);
	}

	function onUpdate( _properties )
	{
		this.ap_skill.onUpdate(_properties);
		this.applySkillBonuses(_properties);
	}

	function resetMomentum()
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			local currentValue = this.getNaiveAttributeBonus(attribute);

			if (currentValue == 0)
			{
				continue;
			}

			this.setAttributeBonus(attribute, ::Math.rand(0, currentValue));
		}
	}

	function setAttributeBonus( _attributeKey, _attributeBonus )
	{
		::AP.Standard.setFlag(_attributeKey, _attributeBonus, this);
	}
});