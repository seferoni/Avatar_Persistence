::mods_hookExactClass("skills/traits/player_character_trait", function( object )
    {
        local gT_nullCheck = "getTooltip" in object ? object.getTooltip : null;
        local parentName = object.SuperName;
        object.getTooltip <- function()
        {
            local tooltipArray = gT_nullCheck == null ? this[parentName].getTooltip() : gT_nullCheck();
            local injuryCount = this.getContainer().getActor().getSkills().getAllSkillsOfType(::Const.SkillType.PermanentInjury).len();

            if (::Avatar_Persistence.Mod.ModSettings.getSetting("ModifyTooltip").getValue() == false)
            {
                return tooltipArray;
            }

            if (injuryCount > ::Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue())
            {
                return tooltipArray;
            }

            tooltipArray.extend([
                {
                    id = 10,
                    type = "text",
                    icon = "ui/icons/obituary.png",
                    text = "[color=" + ::Const.UI.Color.PositiveValue + "]" + "Will survive[/color] being struck down by most foes"
                }
            ]);

            if (!::RPGR_AR_ModuleFound || ::RPGR_AR_ModuleFound && ::Avatar_Resistances.Mod.ModSettings.getSetting("ModifyTooltip").getValue() == false)
            {
                tooltipArray.extend([
                    {
                        id = 10,
                        type = "text",
                        icon = "ui/icons/warning.png",
                        text = "Loses persistence when more than [color=" + ::Const.UI.Color.NegativeValue + "]" + ::Avatar_Persistence.Mod.ModSettings.getSetting("PermanentInjuryThreshold").getValue() + "[/color] permanent injuries are suffered at a time"
                    }
                ]);
            }

            return tooltipArray;
        }
    });