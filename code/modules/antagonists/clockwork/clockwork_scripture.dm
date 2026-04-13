/// Global list of all available scripture types, populated at world init
GLOBAL_LIST_INIT(clockwork_scripture_types, generate_clockwork_scripture_types())

/proc/generate_clockwork_scripture_types()
	return valid_subtypesof(/datum/clockwork_scripture)

/datum/clockwork_scripture
	abstract_type = /datum/clockwork_scripture
	/// Display name
	var/name = "base scripture"
	/// Description shown in slab UI
	var/desc = "A basic scripture."
	/// Scripture tier: SCRIPTURE_DRIVER, SCRIPTURE_SCRIPT, SCRIPTURE_APPLICATION, SCRIPTURE_CYBORG
	var/tier = SCRIPTURE_DRIVER
	/// Power cost in watts
	var/power_cost = 0
	/// Invocation time in deciseconds
	var/invocation_time = 0
	/// Minimum servants required to invoke (usually 1)
	var/invokers_required = 1
	/// Flavor text whispered during invocation
	var/whispered_invocation = "Cog-rathvar!"
	/// Icon state for quickbind HUD button
	var/quickbind_icon = "clockwork_slab"
	/// Whether this scripture is only for cyborgs
	var/cyborg_only = FALSE

/// Checks if this scripture can be invoked by the user with the given slab.
/datum/clockwork_scripture/proc/can_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	if(!IS_CLOCKWORK(user))
		return FALSE
	if(user.incapacitated)
		return FALSE

	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(!clock_datum)
		return FALSE
	var/datum/team/clockwork/team = clock_datum.clockwork_team
	if(!team)
		return FALSE

	// Check tier unlock
	switch(tier)
		if(SCRIPTURE_SCRIPT)
			if(!team.scripture_unlocked_script)
				to_chat(user, span_warning("Script tier scripture requires [CLOCKWORK_SCRIPT_THRESHOLD / 1000]kW of stored power or the Ark to be past halfway."))
				return FALSE
		if(SCRIPTURE_APPLICATION)
			if(!team.scripture_unlocked_application)
				to_chat(user, span_warning("Application tier scripture requires [CLOCKWORK_APPLICATION_THRESHOLD / 1000]kW of stored power or a successful conversion."))
				return FALSE

	// Check power
	var/actual_cost = power_cost
	if(team.herald_activated)
		actual_cost *= HERALD_POWER_COST_MULT
	if(team.power < actual_cost)
		to_chat(user, span_warning("Not enough power! Need [actual_cost]W, have [team.power]W."))
		return FALSE

	// Check invoker count
	if(invokers_required > 1)
		var/invoker_count = count_nearby_servants(user)
		if(invoker_count < invokers_required)
			to_chat(user, span_warning("[name] requires [invokers_required] servants nearby. Only [invoker_count] present."))
			return FALSE

	return TRUE

/// Invokes this scripture. Handles power deduction, invocation delay, and calls do_invoke().
/datum/clockwork_scripture/proc/invoke(mob/living/user, obj/item/clockwork_slab/slab)
	if(!can_invoke(user, slab))
		return FALSE

	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	var/datum/team/clockwork/team = clock_datum.clockwork_team

	// Calculate actual invocation time
	var/actual_time = invocation_time
	if(team.herald_activated)
		actual_time *= HERALD_SCRIPTURE_SPEED_MULT

	// Whisper invocation
	if(whispered_invocation)
		user.whisper(whispered_invocation, language = /datum/language/common, forced = "clockwork invocation")

	// Channel if there's a delay
	if(actual_time > 0)
		playsound(user, 'sound/effects/magic/clockwork/invoke_general.ogg', 30, TRUE)
		if(!do_after(user, actual_time, target = user))
			to_chat(user, span_warning("Your invocation was interrupted!"))
			return FALSE

	// Re-check after channeling
	if(!can_invoke(user, slab))
		return FALSE

	// Deduct power
	var/actual_cost = power_cost
	if(team.herald_activated)
		actual_cost *= HERALD_POWER_COST_MULT
	team.adjust_power(-actual_cost)

	// Execute the effect
	return do_invoke(user, slab)

/// Abstract proc — override in subtypes to implement the actual scripture effect.
/datum/clockwork_scripture/proc/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	return TRUE

/// Counts the number of clockwork servants adjacent to the user (including the user).
/proc/count_nearby_servants(mob/living/user)
	var/count = 1 // Include the user
	for(var/mob/living/nearby in range(1, user))
		if(nearby == user)
			continue
		if(IS_CLOCKWORK(nearby) && !nearby.incapacitated)
			count++
	return count
