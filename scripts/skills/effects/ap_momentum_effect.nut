this.ap_momentum_effect <- ::inherit("scripts/skills/ap_skill",
{
	m = {},
	function create()
	{
		this.ap_skill.create();
		this.assignPropertiesByName("Momentum");
	}

	function assignGenericProperties()
	{
		this.ap_skill.assignGenericProperties();
		this.m.IsHidden = false;
	}

	function assignSpecialProperties()
	{
		this.ap_skill.assignSpecialProperties();

		if (this.getBattlesSurvived() == false)
		{
			this.setBattlesSurvived(0);
		}
	}

	function createIntervalEntry()
	{
		return ::AP.Standard.constructEntry
		(
			"Time",
			format(::AP.Strings.Skills.MomentumIntervalText, ::AP.Standard.colourWrap(this.getBattlesUntilNextStack(), ::AP.Standard.Colour.Red))
		);
	}

	function createStacksEntry()
	{
		local stacks = this.getCurrentStacks();
		return ::AP.Standard.constructEntry
		(
			"Special",
			format("%s %s", ::AP.Strings.Skills.MomentumValue, ::AP.Standard.colourWrap(stacks, ::AP.Standard.Colour.Green))
		);
	}

	function createStaminaEntry()
	{
		local staminaBonus = this.getStaminaBonus();
		return ::AP.Standard.constructEntry
		(
			"Stamina",
			format("%s %s", ::AP.Standard.colourWrap(format("+%i", staminaBonus), ::AP.Standard.Colour.Green), ::AP.Strings.Generic.Stamina)
		);
	}

	function getBattlesSurvived()
	{
		return ::AP.Standard.getFlag("BattlesSurvived", this);
	}

	function getBattlesUntilNextStack()
	{
		local battlesSurvived = this.getBattlesSurvived();
		return ::AP.Standard.getNearestTen(battlesSurvived, true) - battlesSurvived;
	}

	function getCurrentStacks()
	{
		local battlesSurvived = this.getBattlesSurvived();
		return ::AP.Standard.getNearestTen(battlesSurvived) / 10;
	}

	function getStaminaBonus()
	{
		return this.getCurrentStacks() * ::AP.Persistence.Parameters.MomentumBaseStaminaBonus;
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createStacksEntry());
		push(this.createStaminaEntry());
		push(this.createIntervalEntry());
		return tooltipArray;
	}

	function isViableForEffect()
	{
		if (this.getBattlesSurvived() < ::AP.Persistence.Parameters.MomentumBaseIntervalDays)
		{
			return false;
		}

		return true;
	}

	function incrementBattlesSurvived()
	{
		local battlesSurvived = this.getBattlesSurvived();
		this.setBattlesSurvived(battlesSurvived + 1);
	}

	function refreshStateByConfiguration()
	{
		this.m.IsHidden = !::AP.Standard.getParameter("EnableMomentum");
	}

	function setBattlesSurvived( _integer = 0 )
	{
		::AP.Standard.setFlag("BattlesSurvived", _integer, this);
	}

	function onUpdate( _properties )
	{
		this.ap_skill.onUpdate(_properties);
		this.refreshStateByConfiguration();

		if (this.m.IsHidden)
		{
			return;
		}

		_properties.Stamina += this.getStaminaBonus();
	}
});