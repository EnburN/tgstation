/datum/team/clockwork
	name = "\improper Clockwork Cult"
	member_name = "servant"

	/// Shared power resource in watts
	var/power = 0
	/// Reference to the Ark structure
	var/obj/structure/clockwork_ark/ark
	/// Reference to the Eminence mob if one exists
	var/mob/camera/clockwork_eminence/eminence
	/// Whether the Herald's Beacon has been activated (war declared)
	var/herald_activated = FALSE
	/// Whether Script tier scripture is unlocked
	var/scripture_unlocked_script = FALSE
	/// Whether Application tier scripture is unlocked
	var/scripture_unlocked_application = FALSE
	/// Peak number of servants
	var/size_at_maximum = 0

/datum/team/clockwork/add_member(datum/mind/new_member)
	. = ..()
	if(!isobserver(new_member.current))
		size_at_maximum = max(size_at_maximum, length(members))

/datum/team/clockwork/proc/setup_objectives()
	var/datum/objective/clockwork/defend_ark/ark_objective = new()
	ark_objective.team = src
	objectives += ark_objective

/// Adjusts the shared power pool. Returns the new power value.
/datum/team/clockwork/proc/adjust_power(amount)
	if(herald_activated && amount < 0)
		amount *= HERALD_POWER_COST_MULT
	power = max(0, power + amount)
	check_scripture_tiers()
	return power

/// Checks if scripture tier thresholds have been crossed and unlocks them.
/datum/team/clockwork/proc/check_scripture_tiers()
	if(!scripture_unlocked_script)
		var/ark_halfway = FALSE
		if(ark)
			ark_halfway = ark.is_past_halfway()
		if(power >= CLOCKWORK_SCRIPT_THRESHOLD || ark_halfway)
			scripture_unlocked_script = TRUE
			announce_to_servants(span_bold("Script tier scripture is now available!"))

	if(!scripture_unlocked_application)
		if(power >= CLOCKWORK_APPLICATION_THRESHOLD)
			scripture_unlocked_application = TRUE
			announce_to_servants(span_bold("Application tier scripture is now available!"))

/// Called when a crew member is successfully converted.
/datum/team/clockwork/proc/on_servant_converted(mob/living/new_servant)
	if(!scripture_unlocked_application)
		scripture_unlocked_application = TRUE
		announce_to_servants(span_bold("Application tier scripture is now available!"))

/// Sends a message to all servants via the Hierophant Network.
/datum/team/clockwork/proc/announce_to_servants(message)
	for(var/datum/mind/servant_mind as anything in members)
		if(!servant_mind.current)
			continue
		to_chat(servant_mind.current, message)

/// Checks victory conditions.
/datum/team/clockwork/proc/check_cult_victory()
	for(var/datum/objective/clockwork/defend_ark/ark_obj in objectives)
		if(ark_obj.ark_destroyed)
			return CLOCKWORK_LOSS
		if(ark_obj.ark_completed)
			return CLOCKWORK_VICTORY
	return null

/datum/team/clockwork/roundend_report()
	var/list/report = list()
	var/victory = check_cult_victory()

	switch(victory)
		if(CLOCKWORK_VICTORY)
			report += "<span class='greentext big'>The Clockwork Cult was successful! Ratvar has been summoned!</span>"
		if(CLOCKWORK_LOSS)
			report += "<span class='redtext big'>The Clockwork Cult has failed. The Ark was destroyed.</span>"
		if(CLOCKWORK_RATVAR_KILLED)
			report += "<span class='redtext big'>The Clockwork Cult has failed. Ratvar was destroyed.</span>"
		else
			report += "<span class='redtext big'>The Clockwork Cult has failed.</span>"

	report += "<br><b>The servants of Ratvar were:</b>"
	for(var/datum/mind/servant_mind as anything in members)
		var/datum/antagonist/clockwork/clock_datum = servant_mind.has_antag_datum(/datum/antagonist/clockwork)
		if(!clock_datum)
			continue
		report += "<br>[servant_mind.key] was [servant_mind.name] ([clock_datum.name])"

	report += "<br><b>Peak servant count:</b> [size_at_maximum]"
	report += "<br><b>Maximum power stored:</b> [power]W"

	return report.Join()
