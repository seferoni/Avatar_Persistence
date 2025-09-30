::AP.Strings.Skills.Momentum <-
{
	Name = "Momentum",
	Description = "This character's indomitable spirit permits their vigour to be raised for each powerful foe felled by their hand. This effect is fortified for as long as they remain in a small company, but is diminished upon each defeat.",

	ActiveScalingChance = "Has a %s%% chance to gain an attribute bonus upon slaying a stronger enemy.",
	PassiveScalingChance = "Has a %s%% chance to gain a defensive attribute bonus each day, up to a maximum bonus of %s.",
	PassiveScalingThresholdExceeded = "Can no longer gain passive bonuses to defensive attributes.",

	StatePrefix = "Momentum: ",
	StateBelowRosterThreshold = "Fortified",
	StateDisabled = "Disabled",
	StateRosterThresholdExceeded = "Weakened",

	NoBonuses = "This character currently possesses no Momentum.",
	RosterThresholdTooltip = "Fortified until the company hires %s more brothers.",
	RosterThresholdExceededTooltip = "Weakened until the company is reduced to a size of %s brothers or fewer.",
	RosterThresholdTooltipBaseline = "Fortified until any additional brothers are hired.",
};