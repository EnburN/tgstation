/// Checks if a mob can be converted to the clockwork cult
/proc/is_convertable_to_clockwork(mob/living/target, datum/team/clockwork/specific_team)
	if(!target.mind)
		return FALSE
	if(IS_CLOCKWORK(target))
		return FALSE
	if(IS_CULTIST(target))
		return FALSE
	if(IS_HERETIC(target))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.mind?.holy_role)
			return FALSE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_UNCONVERTABLE))
		return FALSE
	if(issilicon(target) && !iscyborg(target))
		return FALSE
	if(isbot(target))
		return FALSE
	if(isdrone(target))
		return FALSE
	return TRUE

#define LANGUAGE_CLOCKWORK "clockwork_cult"

/datum/antagonist/clockwork
	name = "Servant of Ratvar"
	roundend_category = "servants of Ratvar"
	antagpanel_category = "Clockwork Cult"
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = "FOR RATVAR!!"
	pref_flag = ROLE_CULTIST
	antag_hud_name = "clockwork"
	show_to_ghosts = TRUE
	stinger_sound = 'sound/effects/magic/clockwork/invoke_general.ogg'

	/// Whether to give starting equipment (clockwork slab)
	var/give_equipment = FALSE
	/// Reference to the clockwork cult team
	var/datum/team/clockwork/clockwork_team

/datum/antagonist/clockwork/can_be_owned(datum/mind/new_owner)
	if(!is_convertable_to_clockwork(new_owner.current))
		return FALSE
	return ..()

/datum/antagonist/clockwork/get_team()
	return clockwork_team

/datum/antagonist/clockwork/create_team(datum/team/clockwork/new_team)
	if(!new_team)
		clockwork_team = new
	else
		clockwork_team = new_team

/datum/antagonist/clockwork/on_gain()
	if(clockwork_team)
		objectives |= clockwork_team.objectives
	owner.current.grant_language(/datum/language/clockwork, source = LANGUAGE_CLOCKWORK)
	if(give_equipment)
		equip_servant()
	grant_servant_actions()
	. = ..()

/datum/antagonist/clockwork/on_removal()
	owner.current.remove_language(/datum/language/clockwork, source = LANGUAGE_CLOCKWORK)
	remove_servant_actions()
	. = ..()

/datum/antagonist/clockwork/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/servant = mob_override || owner.current
	servant.add_faction(FACTION_CLOCKWORK)
	ADD_TRAIT(servant, TRAIT_HEALS_ON_CLOCKWORK_FLOOR, INNATE_TRAIT)
	ADD_TRAIT(servant, TRAIT_CLOCKWORK_SERVANT, INNATE_TRAIT)

/datum/antagonist/clockwork/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/servant = mob_override || owner.current
	servant.remove_faction(FACTION_CLOCKWORK)
	REMOVE_TRAIT(servant, TRAIT_HEALS_ON_CLOCKWORK_FLOOR, INNATE_TRAIT)
	REMOVE_TRAIT(servant, TRAIT_CLOCKWORK_SERVANT, INNATE_TRAIT)

/datum/antagonist/clockwork/greet()
	. = ..()
	to_chat(owner.current, span_bold("You are a Servant of Ratvar, the Clockwork Justiciar!"))
	to_chat(owner.current, span_bold("Your goal is to defend the Ark of the Clockwork Justiciar until it activates and summons Ratvar."))
	to_chat(owner.current, "Use your <b>clockwork slab</b> to access scripture — your special abilities.")
	to_chat(owner.current, "Use the <b>Hierophant Network</b> to communicate with other servants.")
	owner.announce_objectives()

/datum/antagonist/clockwork/proc/equip_servant()
	var/mob/living/carbon/human/servant = owner.current
	if(!istype(servant))
		return
	var/obj/item/clockwork_slab/slab = new(servant.loc)
	servant.put_in_hands(slab)

/datum/antagonist/clockwork/proc/grant_servant_actions()
	var/datum/action/innate/clockwork/hierophant/hierophant_action = new(owner.current)
	hierophant_action.Grant(owner.current)
	var/datum/action/innate/clockwork/oppose_eminence/oppose_action = new(owner.current)
	oppose_action.Grant(owner.current)

/datum/antagonist/clockwork/proc/remove_servant_actions()
	for(var/datum/action/innate/clockwork/action in owner.current.actions)
		action.Remove(owner.current)

/datum/antagonist/clockwork/get_admin_commands()
	. = ..()
	.["Give Slab"] = CALLBACK(src, PROC_REF(admin_give_slab))
	.["Give Slab + Fabricator"] = CALLBACK(src, PROC_REF(admin_give_full_kit))

/datum/antagonist/clockwork/proc/admin_give_slab(mob/admin)
	equip_servant()
	to_chat(admin, span_notice("Gave clockwork slab to [owner.current]."))

/datum/antagonist/clockwork/proc/admin_give_full_kit(mob/admin)
	equip_servant()
	var/obj/item/replica_fabricator/fab = new(owner.current.loc)
	if(ishuman(owner.current))
		var/mob/living/carbon/human/human_servant = owner.current
		human_servant.put_in_hands(fab)
	to_chat(admin, span_notice("Gave clockwork slab and replica fabricator to [owner.current]."))

/datum/antagonist/clockwork/admin_add(datum/mind/new_owner, mob/admin)
	// Create a team if one doesn't exist
	if(!clockwork_team)
		var/datum/team/clockwork/existing = locate() in GLOB.antagonist_teams
		if(existing)
			clockwork_team = existing
		else
			clockwork_team = new /datum/team/clockwork()
			clockwork_team.setup_objectives()
			// Give starting power so scripture is usable
			clockwork_team.adjust_power(10000)
	give_equipment = TRUE
	. = ..()

/// Subtype for constructs (marauders, cogscarabs)
/datum/antagonist/clockwork/construct
	name = "Clockwork Construct"
	give_equipment = FALSE
	show_to_ghosts = FALSE
