this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{	// TODO: need to revise this from a design perspective. momentum should decay per time, and skill gain should be agnostic to character stats. focus on entity instead.
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

		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return entries;
		}

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
				::AP.Standard.colourWrap(this.getString("NoBonusesText"), ::AP.Standard.Colour.Red),
				entries
			);
		}

		return entries;
	}

	function createMomentumStateEntry()
	{
		local colour = ::AP.Standard.Colour.Red;
		local suffix = this.getString("StateRosterThresholdExceeded");

		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			suffix = this.getString("StateDisabled");
		}
		else if (this.isWithinRosterThreshold())
		{
			colour = ::AP.Standard.Colour.Green;
			suffix = this.getString("StateBelowRosterThreshold");
		}

		return ::AP.Standard.constructEntry
		(
			"Momentum",
			format("%s %s", this.getString("StatePrefix"), ::AP.Standard.colourWrap(suffix, colour))
		);
	}

	function getAttributeBonus( _attributeKey )
	{
		return this.getNaiveAttributeBonus(_attributeKey) * this.getAttributeBonusMultiplier();
	}

	function getAttributeBonusMultiplier()
	{
		local nominalMultiplier = 1;
		local injuryCount = ::AP.Skills.getPermanentInjuryCount(this.getContainer().getActor());

		if (injuryCount > 0)
		{
			nominalMultiplier++;
		}

		if (this.isWithinRosterThreshold())
		{
			nominalMultiplier++;
		}

		return nominalMultiplier;
	}

	function getEligibleAttributeByEntity( _targetEntity )
	{
		local eligibleAttributes = [];
		local viableAttributes = this.getViableAttributesForScaling();
		local targetProperties = _targetEntity.getBaseProperties();

		// TODO: need to sort the target's attributes from highest to lowest, choose from the highest three

		if (eligibleAttributes.len() == 0)
		{
			return null;
		}

		return eligibleAttributes[::Math.rand(0, eligibleAttributes.len() - 1)];
	}

	function getNaiveAttributeBonus( _attributeKey )
	{
		return ::AP.Standard.getFlag(_attributeKey, this);
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createMomentumStateEntry());
		push(this.createAttributeEntries());
		return tooltipArray;
	}

	function getViableAttributesForScaling()
	{
		return this.getSkillData().ScalableAttributes;
	}

	function incrementAttributeBonus( _attributeKey )
	{
		this.setAttributeBonus(_attributeKey, this.getAttributeBonus(_attributeKey) + 1);
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

	function isWithinRosterThreshold()
	{
		return ::World.getPlayerRoster().getAll().len() <= ::AP.Standard.getParameter("MomentumRosterThreshold");
	}

	function onTargetKilled( _targetEntity, _skill )
	{
		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return;
		}

		local eligibleAttribute = this.getEligibleAttributeByEntity(_targetEntity);

		if (eligibleAttribute == null)
		{
			return;
		}

		this.spawnOverlayOnCurrentTile();
		this.incrementAttributeBonus(eligibleAttribute);
	}

	function onUpdate( _properties )
	{
		this.ap_skill.onUpdate(_properties);

		if (!::AP.Standard.getParameter("EnableMomentum"))
		{
			return;
		}

		this.applySkillBonuses(_properties);
	}

	function resetMomentum()
	{
		local viableAttributes = this.getViableAttributesForScaling();

		foreach( attribute in viableAttributes )
		{
			this.setAttributeBonus(attribute, 0);
		}
	}

	function setAttributeBonus( _attributeKey, _attributeBonus )
	{
		::AP.Standard.setFlag(_attributeKey, _attributeBonus, this);
	}
});