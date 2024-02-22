local AP = ::RPGR_Avatar_Persistence;
this.elixir_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.m.ID = "misc.elixir";
		this.m.Name = "Elixir";
		this.m.Description = "A caustic and volatile concoction, coveted throughout the realms for its curative powers.";
		this.m.Icon = "special/elixir_01.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.Value = 800;
	},
	Paths =
	{
		Avatar = "scripts/skills/traits/player_character_trait",
		Sick = "scripts/skills/injury/sickness_injury"
	},
	Sounds =
	{
		Move = "sounds/bottle_01.wav",
		Use = "sounds/combat/drink_03.wav",
		Warning = "sounds/move_pot_clay_01.wav"
	},
	Tooltip =
	{
		Icons =
		{
			Special = "ui/icons/special.png",
			Warning = "ui/icons/warning.png"
		},
		Template =
		{
			id = 6,
			type = "text",
			icon = "",
			text = ""
		}
		Text =
		{
			Warnings =
			{
				AvatarAlreadyPresent = "A player character is already present in your roster.",
				ActorIsSick = "This character is currently sick.",
				CharacterNotEligible = "This character does not have player character status.",
				NoInjuriesSustained = "This character has sustained no injuries."
			},
			Conferment = format("The elixir can confer the %s upon the currently selected character.", AP.Standard.colourWrap("player character trait", AP.Standard.Colour.Green)),
			Instruction = format("Will remove all %s, but only for player characters.", AP.Standard.colourWrap("temporary or permanent injuries", AP.Standard.Colour.Green)),
			Use = "Right-click or drag onto the currently selected character in order to drink. This item will be consumed in the process."
		}
	},
	Warnings =
	{
		AvatarAlreadyPresent = false,
		ActorIsSick = false,
		CharacterNotEligible = false,
		NoInjuriesSustained = false
	}

	function consume( _actor )
	{
		this.playUseSound();
		this.updateActor(_actor);
		this.updateSprites(_actor);
	}

	function createConfermentEntry()
	{
		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Special;
		entry.text = this.Tooltip.Text.Conferment;
		return entry;
	}

	function createWarningEntry()
	{
		local warning = this.getActiveWarning();

		if (warning == null)
		{
			return null;
		}

		local entry = clone this.Tooltip.Template;
		entry.icon = this.Tooltip.Icons.Warning;
		entry.text = AP.Standard.colourWrap(this.Tooltip.Text.Warnings[warning], AP.Standard.Colour.Red);
		this.resetWarnings();
		return entry;
	}

	function conferAvatarStatus( _actor )
	{
		_actor.getSkills().add(::new(this.Paths.Avatar));
		AP.Standard.setFlag("IsPlayerCharacter", true, _actor, true);
		AP.Standard.setFlag("AvatarStatusConferred", true, ::World.Statistics);
	}

	function getActiveWarning()
	{
		foreach( warning, warningState in this.Warnings )
		{
			if (warningState) return warning;
		}

		return null;
	}

	function getAllSprites()
	{
		local sprites = [];

		for( local i = 1; i <= 4; i++ )
		{
			sprites.push(format("permanent_injury_%i", i));
		}

		return sprites;
	}

	function getTooltip()
	{
		local tooltipArray = [],
		push = @(_entry) tooltipArray.push(_entry);

		# Create generic entries.
		push({id = 1, type = "title", text = this.getName()});
		push({id = 2, type = "description", text = this.getDescription()});
		push({id = 66, type = "text", text = this.getValueString()});
		push({id = 3, type = "image", image = this.getIcon()});

		# Create instruction entry.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Special, text = this.Tooltip.Text.Instruction});

		# Create conferment entry.
		if (AP.Standard.getSetting("ElixirConfersAvatarStatus"))
		{
			push(this.createConfermentEntry());
		}

		# Create usage entry.
		push({id = 65, type = "text", text = this.Tooltip.Text.Use});

		# If a warning is queued to be displayed, create a warning entry, and reset all warnings to default values.
		local warningEntry = this.createWarningEntry();

		if (warningEntry != null)
		{
			push(warningEntry);
		}

		return tooltipArray;
	}

	function handleInvalidUse( _reasonString )
	{
		this.setWarning(_reasonString);
		this.playWarningSound();
		return false;
	}

	function handleUseForCharacter( _actor )
	{
		if (!AP.Standard.getSetting("ElixirConfersAvatarStatus"))
		{
			return this.handleInvalidUse("CharacterNotEligible");
		}

		if (AP.Persistence.isPlayerInRoster(AP.Persistence.Rosters.World))
		{
			return this.handleInvalidUse("AvatarAlreadyPresent");
		}

		this.conferAvatarStatus(_actor);
		this.consume(_actor);
		return true;
	}

	function handleUseForPlayer( _player )
	{
		if (this.isActorSick(_player))
		{
			return this.handleInvalidUse("ActorIsSick");
		}

		if (!this.isActorInjured(_player))
		{
			return this.handleInvalidUse("NoInjuriesSustained");
		}

		this.consume(_player);
		return true;
	}

	function isActorInjured( _actor )
	{
		if  (!_actor.getSkills().hasSkillOfType(::Const.SkillType.Injury))
		{
			return false;
		}

		return true;
	}

	function isActorSick( _actor )
	{
		if (!_actor.getSkills().hasSkill("injury.sickness"))
		{
			return false;
		}

		return true;
	}

	function isActorViableForConferment( _actor )
	{
		if (!AP.Standard.getSetting("ElixirConfersAvatarStatus"))
		{
			this.setWarning("CharacterNotEligible");
			return false;
		}

		if (AP.Persistence.isPlayerInRoster(AP.Persistence.Rosters.World))
		{
			this.setWarning("AvatarAlreadyPresent");
			return false;
		}

		return true;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play(this.Sounds.Move, ::Const.Sound.Volume.Inventory);
	}

	function playUseSound()
	{
		::Sound.play(this.Sounds.Use, ::Const.Sound.Volume.Inventory);
	}

	function playWarningSound()
	{
		::Sound.play(this.Sounds.Warning, ::Const.Sound.Volume.Inventory);
	}

	function setWarning( _warning, _boolean = true )
	{
		this.Warnings[_warning] = _boolean;
		::Tooltip.reload();
	}

	function resetWarnings()
	{
		foreach( warning, warningState in this.Warnings )
		{
			this.Warnings[warning] = false;
		}
	}

	function onUse( _actor, _item = null )
	{
		if (AP.Persistence.isActorViable(_actor))
		{
			return this.handleUseForPlayer(_actor);
		}

		return this.handleUseForCharacter(_actor);
	}

	function updateActor( _actor )
	{
		_actor.getSkills().removeByType(::Const.SkillType.Injury);
		_actor.getSkills().add(::new(this.Paths.Sick));
		_actor.setHitpoints(_actor.getHitpointsMax());
	}

	function updateSprites( _actor )
	{
		local sprites = this.getAllSprites();

		foreach( sprite in sprites )
		{
			local injurySprite = _actor.getSprite(sprite);
			injurySprite.Visible = false;
			injurySprite.resetBrush();
		}
	}
});

