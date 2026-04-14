/// Eminence: a revenant-style spectral ghost that leads the cult.
/mob/living/basic/clockwork_eminence
	name = "Eminence"
	real_name = "the Eminence"
	desc = "A spectral clockwork presence, glimpsed only by the dead and the devout."
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "clockwork_marauder"
	maxHealth = 500
	health = 500
	density = FALSE
	anchored = FALSE
	movement_type = FLYING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSGLASS | PASSMOB | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS | PASSVEHICLE
	faction = list(FACTION_CLOCKWORK)
	gender = NEUTER
	speak_emote = list("intones")
	melee_damage_lower = 0
	melee_damage_upper = 0
	combat_mode = FALSE
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS
	see_invisible = SEE_INVISIBLE_OBSERVER
	invisibility = INVISIBILITY_REVENANT
	incorporeal_move = INCORPOREAL_MOVE_BASIC
	/// Reference to the clockwork cult team datum
	var/datum/team/clockwork/clockwork_team
	/// Whether the eminence has placed the altar this round
	var/has_placed_altar = FALSE
	/// The current placement preview overlay, if in placement mode
	var/obj/effect/clockwork_placement_preview/placement_preview

/mob/living/basic/clockwork_eminence/Initialize(mapload, datum/team/clockwork/team_ref)
	. = ..()
	if(team_ref)
		clockwork_team = team_ref
		clockwork_team.eminence = src
	add_traits(list(
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOFIRE,
		TRAIT_NOBREATH,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_NEGATES_GRAVITY,
	), INNATE_TRAIT)
	grant_eminence_abilities()

/mob/living/basic/clockwork_eminence/Destroy()
	if(clockwork_team?.eminence == src)
		clockwork_team.eminence = null
	clockwork_team = null
	QDEL_NULL(placement_preview)
	return ..()

/mob/living/basic/clockwork_eminence/Login()
	. = ..()
	to_chat(src, span_bold("You are the Eminence — Ratvar's herald in the mortal realm."))
	to_chat(src, "You are incorporeal and invisible to the living. Use your abilities to direct your servants and place the Altar of Reforging.")

/mob/living/basic/clockwork_eminence/adjust_brute_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(amount > 0 && !forced)
		return 0
	return ..()

/mob/living/basic/clockwork_eminence/adjust_fire_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype = ALL)
	if(amount > 0 && !forced)
		return 0
	return ..()

/mob/living/basic/clockwork_eminence/Move(NewLoc, direct, glide_size_override, update_dir)
	var/area/destination = get_area(NewLoc)
	if(istype(destination, /area/station/service/chapel))
		to_chat(src, span_warning("The chapel's blessings repel you."))
		return FALSE
	return ..()

/mob/living/basic/clockwork_eminence/proc/grant_eminence_abilities()
	var/list/ability_types = list(
		/datum/action/innate/clockwork/eminence/place_altar,
		/datum/action/innate/clockwork/eminence/marker/rally,
		/datum/action/innate/clockwork/eminence/marker/regroup,
		/datum/action/innate/clockwork/eminence/marker/avoid,
		/datum/action/innate/clockwork/eminence/marker/reinforce,
		/datum/action/innate/clockwork/eminence/directive,
		/datum/action/innate/clockwork/eminence/mass_recall,
		/datum/action/innate/clockwork/eminence/superheat,
		/datum/action/innate/clockwork/eminence/trigger_trap,
	)
	for(var/action_type as anything in ability_types)
		var/datum/action/innate/clockwork/eminence/ability = new action_type(src)
		ability.Grant(src)
