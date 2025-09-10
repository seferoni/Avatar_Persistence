this.ap_dilute_elixir_item <- ::inherit("scripts/items/special/ap_elixir_item",
{
	m = {},
	function create()
	{
		this.ap_item.create();
		this.assignPropertiesByName("Dilute Elixir");
	}

	function assignGenericProperties()
	{
		this.ap_item.assignGenericProperties();
		this.m.Value = 25;
	}

	function createTutorialEntry()
	{
		return null;
	}

	function consume( _actor )
	{
		this.playUseSound();
		_actor.getSkills().add(::new(::AP.Utilities.getCommonField("SkillPaths").Sickness));
	}

	function handleUseForCharacter( _playerObject )
	{
		if (::AP.Utilities.getPlayerInRoster(::World.getPlayerRoster()) != null)
		{
			return this.handleInvalidUse("AvatarAlreadyPresent");
		}

		this.conferAvatarStatus(_playerObject);
		this.consume(_playerObject);
		return true;
	}
});