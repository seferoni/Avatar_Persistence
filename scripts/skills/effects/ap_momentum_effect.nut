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
		this.ap_skill.create();
		this.m.IsHidden = ::AP.Standard.getSetting("EnableMomentum") && this.isViableForEffect();
	}

	function createIntervalEntry()
	{
		return ::AP.Standard.constructEntry
		(
			"Time",
			format()::AP.Strings.Skills.MomentumIntervalText
		);
	}

	function createSkillEntry()
	{

	}

	function getBattlesSurvived()
	{
		return ::AP.Standard.getFlag("BattlesSurvived", this);
	}

	function getBattlesUntilNextStack()
	{
		local battlesSurvived = this.getBattlesSurvived();
		// TODO: think about implementation here
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_skill.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, entries);

		push(this.createSkillEntry());
		push(this.createIntervalEntry());
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

	function setBattlesSurvived( _integer = 0 )
	{
		::AP.Standard.setFlag("BattlesSurvived", _integer, this);
	}

	function onUpdate( _properties )
	{

	}
});