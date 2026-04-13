/obj/effect/clockwork_sigil
	name = "clockwork sigil"
	desc = "A glowing clockwork sigil inscribed into the floor."
	icon = 'icons/obj/antags/cult/rune.dmi'
	icon_state = "yourune"
	anchored = TRUE
	layer = RUNE_LAYER
	plane = FLOOR_PLANE
	resistance_flags = FIRE_PROOF

/obj/effect/clockwork_sigil/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/clockwork_sigil/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.combat_mode)
		to_chat(user, span_notice("You scrub away the sigil."))
		qdel(src)
		return TRUE

/obj/effect/clockwork_sigil/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	return

// ---- Sigil of Submission ----
/obj/effect/clockwork_sigil/submission
	name = "Sigil of Submission"
	desc = "A glowing clockwork sigil. Non-servants held upon it will be converted."
	color = "#BE8700"
	var/converting = FALSE

/obj/effect/clockwork_sigil/submission/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!isliving(arrived))
		return
	var/mob/living/target = arrived
	if(IS_CLOCKWORK(target))
		return
	INVOKE_ASYNC(src, PROC_REF(try_convert), target)

/obj/effect/clockwork_sigil/submission/proc/try_convert(mob/living/target)
	if(converting)
		return
	converting = TRUE
	var/has_servant_nearby = FALSE
	for(var/mob/living/nearby in range(1, src))
		if(IS_CLOCKWORK(nearby) && nearby != target)
			has_servant_nearby = TRUE
			break
	if(!has_servant_nearby)
		converting = FALSE
		return
	visible_message(span_warning("[src] begins to pulse with energy beneath [target]!"))
	if(!do_after(target, 8 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(check_conversion_valid), target)))
		converting = FALSE
		return
	if(!is_convertable_to_clockwork(target))
		visible_message(span_warning("[src] flashes and rejects [target]!"))
		target.Paralyze(4 SECONDS)
		converting = FALSE
		for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
			team.announce_to_servants(span_bold("A conversion attempt on [target] has failed!"))
			break
		return
	var/datum/team/clockwork/team
	for(var/datum/team/clockwork/found_team in GLOB.antagonist_teams)
		team = found_team
		break
	if(!team)
		converting = FALSE
		return
	var/datum/antagonist/clockwork/new_servant = new()
	new_servant.give_equipment = TRUE
	target.mind.add_antag_datum(new_servant, team)
	target.Paralyze(4 SECONDS)
	visible_message(span_warning("[src] flares brilliantly as [target] is enlightened!"))
	team.on_servant_converted(target)
	team.announce_to_servants(span_bold("[target] has been converted to the cause!"))
	converting = FALSE

/obj/effect/clockwork_sigil/submission/proc/check_conversion_valid(mob/living/target)
	if(QDELETED(src) || QDELETED(target))
		return FALSE
	if(get_turf(target) != get_turf(src))
		return FALSE
	for(var/mob/living/nearby in range(1, src))
		if(IS_CLOCKWORK(nearby) && nearby != target)
			return TRUE
	return FALSE

// ---- Sigil of Transgression ----
/obj/effect/clockwork_sigil/transgression
	name = "Sigil of Transgression"
	desc = "A nearly invisible clockwork sigil."
	alpha = 30
	color = "#BE8700"

/obj/effect/clockwork_sigil/transgression/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!isliving(arrived))
		return
	var/mob/living/target = arrived
	if(IS_CLOCKWORK(target))
		return
	INVOKE_ASYNC(src, PROC_REF(trigger_trap), target)

/obj/effect/clockwork_sigil/transgression/proc/trigger_trap(mob/living/target)
	target.Paralyze(7 SECONDS)
	target.flash_act(affect_silicon = TRUE)
	visible_message(span_warning("[src] flares with blinding light!"))
	playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, TRUE)
	qdel(src)

// ---- Vitality Matrix ----
/obj/effect/clockwork_sigil/vitality_matrix
	name = "Vitality Matrix"
	desc = "A sigil that drains the life force of non-servants and uses it to heal servants."
	alpha = 60
	color = "#FF4444"
	COOLDOWN_DECLARE(revive_cooldown)

/obj/effect/clockwork_sigil/vitality_matrix/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!isliving(arrived))
		return
	var/mob/living/target = arrived
	if(IS_CLOCKWORK(target))
		INVOKE_ASYNC(src, PROC_REF(heal_servant), target)
	else
		INVOKE_ASYNC(src, PROC_REF(drain_victim), target)

/obj/effect/clockwork_sigil/vitality_matrix/proc/drain_victim(mob/living/target)
	while(!QDELETED(src) && !QDELETED(target) && get_turf(target) == get_turf(src) && !IS_CLOCKWORK(target))
		if(target.stat == DEAD)
			visible_message(span_warning("[src] consumes [target]'s remains!"))
			GLOB.clockwork_vitality += VITALITY_CORPSE_BURST
			target.gib()
			return
		var/damage = min(5, target.health)
		target.adjustToxLoss(damage)
		GLOB.clockwork_vitality += damage
		sleep(1 SECONDS)

/obj/effect/clockwork_sigil/vitality_matrix/proc/heal_servant(mob/living/target)
	if(target.stat == DEAD)
		try_revive(target)
		return
	while(!QDELETED(src) && !QDELETED(target) && get_turf(target) == get_turf(src) && GLOB.clockwork_vitality > 0)
		var/heal_amount = min(10, GLOB.clockwork_vitality)
		target.adjustBruteLoss(-heal_amount * 0.5)
		target.adjustFireLoss(-heal_amount * 0.5)
		GLOB.clockwork_vitality -= heal_amount
		sleep(0.5 SECONDS)

/obj/effect/clockwork_sigil/vitality_matrix/proc/try_revive(mob/living/target)
	if(!COOLDOWN_FINISHED(src, revive_cooldown))
		return
	if(GLOB.clockwork_vitality < VITALITY_REVIVE_COST)
		return
	GLOB.clockwork_vitality -= VITALITY_REVIVE_COST
	target.revive(ADMIN_REVIVE)
	COOLDOWN_START(src, revive_cooldown, 1 MINUTES)
	visible_message(span_warning("[src] blazes with energy as [target] is brought back!"))
	qdel(src)

// ---- Sigil of Transmission ----
/obj/effect/clockwork_sigil/transmission
	name = "Sigil of Transmission"
	desc = "A sigil that acts as a power access point, powering nearby structures and draining electronics."
	color = "#4444FF"
	var/active = FALSE

/obj/effect/clockwork_sigil/transmission/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/clockwork_sigil/transmission/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/clockwork_sigil/transmission/attack_hand(mob/living/user, list/modifiers)
	if(IS_CLOCKWORK(user) && !user.combat_mode)
		active = !active
		to_chat(user, span_brass("You [active ? "activate" : "deactivate"] the sigil."))
		return TRUE
	return ..()

/obj/effect/clockwork_sigil/transmission/process(seconds_per_tick)
	if(!active)
		return
	for(var/obj/machinery/power/apc/nearby_apc in range(2, src))
		if(!nearby_apc.cell || nearby_apc.cell.charge <= 0)
			continue
		var/drained = min(nearby_apc.cell.charge, 10 * seconds_per_tick)
		nearby_apc.cell.use(drained)
		for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
			team.adjust_power(drained)
			break

/obj/effect/clockwork_sigil/transmission/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!iscyborg(arrived))
		return
	var/mob/living/silicon/robot/borg = arrived
	if(IS_CLOCKWORK(borg))
		INVOKE_ASYNC(src, PROC_REF(recharge_borg), borg)

/obj/effect/clockwork_sigil/transmission/proc/recharge_borg(mob/living/silicon/robot/borg)
	if(!borg.cell)
		return
	var/recharge = min(borg.cell.maxcharge - borg.cell.charge, 500)
	borg.cell.give(recharge)
	to_chat(borg, span_brass("The sigil recharges your power cell."))
