/// The Altar of Reforging: the central structure of the Clockwork Cult.
/// Servants deposit relics, components, and Essence Cogs here to summon Ratvar.
/obj/structure/clockwork_altar
	name = "Altar of Reforging"
	desc = "A towering altar of brass and gears. Its purpose is not yet clear."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "clockwork_wall"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = ALTAR_MAX_INTEGRITY
	/// Current activation state — one of the ALTAR_STATE_* defines
	var/state = ALTAR_STATE_DORMANT
	/// Reference back to the owning clockwork team
	var/datum/team/clockwork/clockwork_team
	/// Set TRUE when the altar is destroyed (allows check_cult_victory to detect loss)
	var/destroyed = FALSE
	/// World.time when the reforging ritual ends
	var/reforging_ends_at = 0
	/// Number of relics deposited so far
	var/relics_deposited = 0
	/// Number of components deposited so far
	var/components_deposited = 0
	/// Number of essence cogs deposited so far
	var/essence_cogs_deposited = 0

/obj/structure/clockwork_altar/Initialize(mapload)
	. = ..()
	GLOB.clockwork_altar = src

/obj/structure/clockwork_altar/Destroy()
	if(GLOB.clockwork_altar == src)
		GLOB.clockwork_altar = null
	if(state >= ALTAR_STATE_EXPOSED && !destroyed)
		destroyed = TRUE
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_bold(span_danger("THE ALTAR HAS BEEN DESTROYED!")))
	clockwork_team = null
	return ..()

/// Advance the altar to a new state. Guards against regression.
/obj/structure/clockwork_altar/proc/advance_state(new_state)
	if(new_state <= state)
		return
	state = new_state
	on_state_changed()

/// Handles side-effects when the altar transitions to a new state.
/obj/structure/clockwork_altar/proc/on_state_changed()
	switch(state)
		if(ALTAR_STATE_AWAKENED)
			if(clockwork_team)
				clockwork_team.announce_to_servants(span_bold("The Altar of Reforging stirs! Bring it the shattered essence of Ratvar."))
			START_PROCESSING(SSobj, src)
		if(ALTAR_STATE_EXPOSED)
			if(clockwork_team)
				clockwork_team.announce_to_servants(span_bold("The Altar glows with awakened power! Continue depositing the required parts."))
		if(ALTAR_STATE_REFORGING)
			reforging_ends_at = world.time + rand(REFORGING_RITUAL_TIME_MIN, REFORGING_RITUAL_TIME_MAX)
			if(clockwork_team)
				clockwork_team.announce_to_servants(span_bold(span_danger("THE REFORGING HAS BEGUN! Protect the altar!")))
			for(var/mob/player in GLOB.player_list)
				SEND_SOUND(player, sound('sound/effects/magic/clockwork/ark_activation_sequence.ogg'))
		if(ALTAR_STATE_COMPLETE)
			STOP_PROCESSING(SSobj, src)
			summon_ratvar()

/// Spawns Ratvar. The announce and sound are handled by /obj/ratvar/Initialize().
/obj/structure/clockwork_altar/proc/summon_ratvar()
	var/turf/spawn_turf = get_turf(src)
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold("<font size='4' color='#BE8700'>RATVAR HAS MANIFESTED!</font>"))
	new /obj/ratvar(spawn_turf)

// ---- Deposit Channel ----

/// Returns TRUE if the altar is currently accepting deposits.
/obj/structure/clockwork_altar/proc/can_accept_deposits()
	return (state >= ALTAR_STATE_AWAKENED && state < ALTAR_STATE_REFORGING)

/// Returns TRUE if the given item is a valid depositable part.
/obj/structure/clockwork_altar/proc/is_valid_part(obj/item/part)
	if(!istype(part))
		return FALSE
	if(istype(part, /obj/item/clockwork/relic))
		// Relics must be identified before they can be deposited
		var/datum/component/clockwork_relic/relic_component = part.GetComponent(/datum/component/clockwork_relic)
		if(!relic_component?.identified)
			return FALSE
		return TRUE
	return istype(part, /obj/item/clockwork)

/// Handle a servant attempting to deposit a part. Returns TRUE on success.
/obj/structure/clockwork_altar/proc/deposit_part(mob/living/depositor, obj/item/part)
	if(!can_accept_deposits())
		to_chat(depositor, span_warning("The altar does not yet stir."))
		return FALSE
	if(!is_valid_part(part))
		to_chat(depositor, span_warning("This is not a piece of Ratvar."))
		return FALSE
	if(!do_after(depositor, PART_DEPOSIT_TIME, target = src))
		return FALSE
	if(QDELETED(part))
		return FALSE
	register_deposit(part)
	qdel(part)
	return TRUE

/// Registers a deposited part — increments counters, announces, and checks for state transitions.
/obj/structure/clockwork_altar/proc/register_deposit(obj/item/part)
	var/part_name = part.name
	if(istype(part, /obj/item/clockwork/relic))
		relics_deposited++
		if(clockwork_team)
			clockwork_team.relics_recovered = relics_deposited
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_brass("A relic has been returned to the altar! ([relics_deposited]/[RELICS_REQUIRED] relics)"))
	else if(istype(part, /obj/item/clockwork/component))
		components_deposited++
		if(clockwork_team)
			clockwork_team.components_forged = components_deposited
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_brass("A component has been delivered to the altar! ([components_deposited]/[COMPONENTS_REQUIRED] components)"))
	else if(istype(part, /obj/item/clockwork/essence_cog))
		essence_cogs_deposited++
		if(clockwork_team)
			clockwork_team.essence_cogs_delivered = essence_cogs_deposited
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_brass("An Essence Cog has been sealed within the altar! ([essence_cogs_deposited]/[ESSENCE_COGS_REQUIRED] cogs)"))
	else
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_brass("[part_name] has been offered to the altar."))
	playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, FALSE)
	check_state_progression()

/// Checks whether the altar should advance to a new state based on deposits.
/obj/structure/clockwork_altar/proc/check_state_progression()
	if(state == ALTAR_STATE_AWAKENED)
		var/total_deposited = relics_deposited + components_deposited + essence_cogs_deposited
		if(total_deposited >= ALTAR_EXPOSE_PARTS_DEPOSITED)
			advance_state(ALTAR_STATE_EXPOSED)
	if(state == ALTAR_STATE_EXPOSED)
		if(relics_deposited >= RELICS_REQUIRED && components_deposited >= COMPONENTS_REQUIRED && essence_cogs_deposited >= ESSENCE_COGS_REQUIRED)
			begin_reforging()

/// Begins the Reforging ritual — transitions the altar to REFORGING state.
/obj/structure/clockwork_altar/proc/begin_reforging()
	advance_state(ALTAR_STATE_REFORGING)

// ---- Interaction Overrides ----

/obj/structure/clockwork_altar/attackby(obj/item/weapon, mob/living/user, params)
	if(IS_CLOCKWORK(user) && is_valid_part(weapon))
		deposit_part(user, weapon)
		return
	return ..()

/obj/structure/clockwork_altar/attack_hand(mob/living/user, list/modifiers)
	if(IS_CLOCKWORK(user))
		ui_interact(user)
		return
	return ..()

/obj/structure/clockwork_altar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClockworkAltar")
		ui.open()

/obj/structure/clockwork_altar/ui_data(mob/user)
	var/list/data = list()
	data["state"] = state
	switch(state)
		if(ALTAR_STATE_DORMANT)
			data["state_name"] = "Dormant"
		if(ALTAR_STATE_AWAKENED)
			data["state_name"] = "Awakened"
		if(ALTAR_STATE_EXPOSED)
			data["state_name"] = "Exposed"
		if(ALTAR_STATE_REFORGING)
			data["state_name"] = "Reforging"
		if(ALTAR_STATE_COMPLETE)
			data["state_name"] = "Complete"
		else
			data["state_name"] = "Unknown"
	data["relics"] = relics_deposited
	data["relics_required"] = RELICS_REQUIRED
	data["components"] = components_deposited
	data["components_required"] = COMPONENTS_REQUIRED
	data["essence_cogs"] = essence_cogs_deposited
	data["essence_cogs_required"] = ESSENCE_COGS_REQUIRED
	// Reforging progress: value from 0-1 based on time elapsed vs total duration
	if(state == ALTAR_STATE_REFORGING && reforging_ends_at > 0)
		var/total_duration = max(1, (REFORGING_RITUAL_TIME_MIN + REFORGING_RITUAL_TIME_MAX) / 2)
		var/elapsed = max(0, total_duration - (reforging_ends_at - world.time))
		data["reforging_progress"] = clamp(elapsed / total_duration, 0, 1)
	else
		data["reforging_progress"] = 0
	return data

/// Cogscarab auto-deposit: instantly registers a part without the do_after channel.
/obj/structure/clockwork_altar/attack_animal(mob/living/user, list/modifiers)
	if(!istype(user, /mob/living/simple_animal/hostile/clockwork/cogscarab))
		return ..()
	if(!can_accept_deposits())
		to_chat(user, span_warning("The altar does not yet stir."))
		return
	// Find first valid clockwork part held by the cogscarab
	var/obj/item/held
	for(var/obj/item/candidate as anything in user.held_items)
		if(is_valid_part(candidate))
			held = candidate
			break
	if(!held)
		to_chat(user, span_warning("You have nothing valid to deposit."))
		return
	user.dropItemToGround(held, force = TRUE)
	register_deposit(held)
	qdel(held)

// ---- Defense Buff Processing (Task 5.4) ----

/obj/structure/clockwork_altar/process(seconds_per_tick)
	if(state == ALTAR_STATE_REFORGING)
		if(world.time >= reforging_ends_at)
			advance_state(ALTAR_STATE_COMPLETE)
		return
	if(state >= ALTAR_STATE_EXPOSED)
		buff_nearby_cogscarabs()

/// Scans for cogscarabs within COGSCARAB_DEFENSE_BUFF_RANGE and applies or clears their defense buff.
/obj/structure/clockwork_altar/proc/buff_nearby_cogscarabs()
	var/list/nearby_scarabs = list()
	for(var/mob/living/simple_animal/hostile/clockwork/cogscarab/scarab in range(COGSCARAB_DEFENSE_BUFF_RANGE, src))
		nearby_scarabs += scarab
		scarab.apply_defense_buff()
	// Clear buff on any cogscarab that has left range
	for(var/mob/living/simple_animal/hostile/clockwork/cogscarab/scarab in world)
		if(!(scarab in nearby_scarabs) && scarab.defense_buffed)
			scarab.clear_defense_buff()
