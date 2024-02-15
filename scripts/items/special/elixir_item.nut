local AP = ::RPGR_Avatar_Persistence;
this.elixir_item <- ::inherit("scripts/items/item",
{
	m = {},
	function create()
	{
		this.item.create();
		this.m.ID = "misc.elixir";
		this.m.Name = "Elixir";
		this.m.Description = "A caustic and volatile concoction, notorious throughout the realms for its propensity to both heal and harm in equal measure.";
		this.m.Icon = "special/elixir_01.png";
		this.m.SlotType = ::Const.ItemSlot.None;
		this.m.ItemType = ::Const.Items.ItemType.Usable;
		this.m.IsDroppedAsLoot = true;
		this.m.IsAllowedInBag = false;
		this.m.IsUsable = true;
		this.m.Value = 100; // TODO:
	}
	Tooltip =
	{
		Icons =
		{
			Instruction = "ui/icons/special.png",
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
				CharacterNotEligible = "This character is not the player character.",
				NoInjuriesPresent = "This character has incurred no injuries."
			}
			Instruction = "Will remove all temporary or permanent injuries, but only for player characters.",
			Use = "Right-click or drag onto the currently selected character in order to drink. This item will be consumed in the process."
		}
	}
	Sounds =
	{
		Inventory = "sounds/bottle_01.wav",
		Use = "sounds/combat/drink_03.wav"
	},
	Warnings =
	{
		AvatarAlreadyPresent = false,
		CharacterNotEligible = false,
		NoInjuriesPresent = false
	}

	function consume( _actor )
	{
		this.playUseSound();
		this.updateActor(_actor);
		this.updateSprites(_actor);
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
		entry.text = this.Tooltip.Text.Warnings[warning];
		this.resetWarnings();
		return entry;
	}

	function conferAvatarStatus( _actor )
	{
		_actor.getSkills().add(::new("scripts/skills/traits/player_character_trait"));
		AP.Standard.setFlag("IsPlayerCharacter", true, _actor, true);
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

		# Create instruction entries.
		push({id = 6, type = "text", icon = this.Tooltip.Icons.Instruction, text = this.Tooltip.Text.Instruction});
		push({id = 65, type = "text", text = this.Tooltip.Text.Use});

		local warningEntry = this.createWarningEntry();

		if (warningEntry != null)
		{
			push(warningEntry);
		}

		return tooltipArray;
	}

	function isActorInjured( _actor )
	{
		if (!_actor.getSkills().hasSkillOfType(::Const.SkillType.Injury))
		{
			return false;
		}

		return true;
	}

	function playInventorySound( _eventType )
	{
		::Sound.play(this.Sounds.Inventory, ::Const.Sound.Volume.Inventory);
	}

	function playUseSound()
	{
		::Sound.play(this.Sounds.Use, ::Const.Sound.Volume.Inventory);
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
		if (!this.isActorInjured(_actor))
		{
			this.setWarning("NoInjuriesPresent");
			return false;
		}

		if (AP.Persistence.isActorViable(_actor))
		{
			this.consume(_actor);
			return true;
		}

		if (!AP.Standard.getSetting("ElixirConfersAvatarStatus"))
		{
			this.setWarning("CharacterNotEligible");
			return false;
		}

		if (AP.Persistence.isPlayerInRoster())
		{
			this.setWarning("AvatarAlreadyPresent");
			return false;
		}

		this.conferAvatarStatus(_actor);
		this.consume(_actor);
		return true;
	}

	function updateActor( _actor )
	{
		_actor.getSkills().removeByType(::Const.SkillType.Injury);
		_actor.getSkills().add(::new("scripts/skills/injury/sickness_injury"));
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

