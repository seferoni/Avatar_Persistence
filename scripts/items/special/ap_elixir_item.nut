this.ap_elixir_item <- ::inherit("scripts/items/ap_item",
{
	m = {},
	function create()
	{
		this.ap_item.create();
		this.assignPropertiesByName("Elixir");
	}

	function assignGenericProperties()
	{
		this.ap_item.assignGenericProperties();
		this.m.Value = 800;
	}

	function assignSoundProperties()
	{
		this.ap_item.assignSoundProperties();
		this.m.InventorySound = "sounds/bottle_01.wav",
		this.m.UseSound = "sounds/combat/drink_03.wav";
	}

	function assignSpecialProperties()
	{
		this.ap_item.assignSpecialProperties();
		this.m.Warnings =
		{
			AvatarAlreadyPresent = false,
			ActorIsSick = false,
			CharacterNotEligible = false,
			NoInjuriesSustained = false
		};
	}

	function conferAvatarStatus( _playerObject )
	{
		_playerObject.getSkills().add(::new(::AP.Persistence.getField("SkillPaths").Avatar));
		::AP.Standard.setFlag("IsPlayerCharacter", true, _playerObject, true);
		::AP.Standard.setFlag("AvatarStatusConferred", true, ::World.Statistics);
	}

	function consume( _actor )
	{
		this.playUseSound();
		this.updateActor(_actor);
		this.updateSprites(_actor);
	}

	function createConfermentEntry()
	{
		return ::AP.Standard.constructEntry
		(
			"Special",
			::AP.Strings.Items.ElixirConfermentText
		);
	}

	function createTutorialEntry()
	{
		return ::AP.Standard.constructEntry
		(
			"Special",
			::AP.Strings.Items.ElixirTutorialText
		);
	}

	function createInstructionEntry()
	{
		return ::AP.Standard.constructEntry
		(
			null,
			::AP.Strings.Items.ElixirInstructionText
		);
	}

	function getTooltip()
	{
		local tooltipArray = this.ap_item.getTooltip();
		local push = @(_entry) ::AP.Standard.push(_entry, tooltipArray);

		push(this.createConfermentEntry());
		push(this.createTutorialEntry());
		push(this.createWarningEntries());
		push(this.createInstructionEntry());
		return tooltipArray;
	}

	function handleInvalidUse( _reasonString )
	{
		this.setWarning(_reasonString);
		this.playWarningSound();
		return false;
	}

	function handleUseForCharacter( _playerObject )
	{
		if (!::AP.Standard.getParameter("ElixirConfersAvatarStatus"))
		{
			return this.handleInvalidUse("CharacterNotEligible");
		}

		if (::AP.Persistence.isPlayerInRoster(::World.getPlayerRoster()))
		{
			return this.handleInvalidUse("AvatarAlreadyPresent");
		}

		this.conferAvatarStatus(_playerObject);
		this.consume(_playerObject);
		return true;
	}

	function handleUseForPlayer( _playerObject )
	{
		if (this.isActorSick(_playerObject))
		{
			return this.handleInvalidUse("ActorIsSick");
		}

		if (!this.isActorInjured(_playerObject))
		{
			return this.handleInvalidUse("NoInjuriesSustained");
		}

		this.consume(_playerObject);
		return true;
	}

	function isActorInjured( _playerObject )
	{
		if  (!_playerObject.getSkills().hasSkillOfType(::Const.SkillType.Injury))
		{
			return false;
		}

		return true;
	}

	function isActorSick( _playerObject )
	{
		if (!_playerObject.getSkills().hasSkill("injury.sickness"))
		{
			return false;
		}

		return true;
	}

	function getConfermentViableState( _playerObject )
	{
		if (!::AP.Standard.getParameter("ElixirConfersAvatarStatus"))
		{
			this.setWarning("CharacterNotEligible");
			return false;
		}

		if (::AP.Persistence.isPlayerInRoster(::World.getPlayerRoster()))
		{
			this.setWarning("AvatarAlreadyPresent");
			return false;
		}

		return true;
	}

	function onUse( _playerObject, _item = null )
	{
		if (::AP.Persistence.isActorViable(_playerObject))
		{
			return this.handleUseForPlayer(_playerObject);
		}

		return this.handleUseForCharacter(_playerObject);
	}

	function updateActor( _playerObject )
	{
		_playerObject.getSkills().removeByType(::Const.SkillType.Injury);
		_playerObject.getSkills().add(::new(::AP.Persistence.getField("SkillPaths").Sickness));
		_playerObject.setHitpoints(_playerObject.getHitpointsMax());
	}

	function updateSprites( _playerObject )
	{
		local sprites = ::AP.Persistence.getField("PermanentInjurySprites");

		foreach( sprite in sprites )
		{
			local injurySprite = _playerObject.getSprite(sprite);
			injurySprite.Visible = false;
			injurySprite.resetBrush();
		}
	}
});