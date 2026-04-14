/// The Altar of Reforging: the central structure of the Clockwork Cult.
/// Servants deposit relics, components, and Essence Cogs here to summon Ratvar.
/// Full deposit and TGUI implementation lives in Phase 3/6.
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

/obj/structure/clockwork_altar/process(seconds_per_tick)
	if(state != ALTAR_STATE_REFORGING)
		return
	if(world.time >= reforging_ends_at)
		advance_state(ALTAR_STATE_COMPLETE)

/// Announces Ratvar's arrival and spawns the Ratvar object.
/obj/structure/clockwork_altar/proc/summon_ratvar()
	var/turf/spawn_turf = get_turf(src)
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold("<font size='4' color='#BE8700'>RATVAR HAS MANIFESTED!</font>"))
	priority_announce("An incomprehensible clockwork entity has appeared on the station!", "EMERGENCY", 'sound/effects/magic/clockwork/ark_activation_sequence.ogg')
	playsound(spawn_turf, 'sound/effects/magic/clockwork/ark_activation_sequence.ogg', 100, FALSE)
	new /obj/ratvar(spawn_turf)

/// Attempt to deposit a part at the altar. Stub — full logic in Phase 3.
/obj/structure/clockwork_altar/proc/deposit_part(mob/living/depositor, obj/item/part)
	return FALSE
