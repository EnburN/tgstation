/obj/structure/clockwork_ark
	name = "Ark of the Clockwork Justiciar"
	desc = "A massive clockwork device humming with unimaginable power."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	max_integrity = 500
	var/phase = ARK_PHASE_BUILD
	var/phase_time_remaining = 0
	var/total_build_time = 0
	var/datum/team/clockwork/clockwork_team

/obj/structure/clockwork_ark/Initialize(mapload)
	. = ..()
	total_build_time = rand(ARK_BUILD_TIME_MIN, ARK_BUILD_TIME_MAX)
	phase_time_remaining = total_build_time
	GLOB.clockwork_ark = src
	START_PROCESSING(SSobj, src)

/obj/structure/clockwork_ark/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(GLOB.clockwork_ark == src)
		GLOB.clockwork_ark = null
	if(phase != ARK_PHASE_COMPLETE)
		on_ark_destroyed()
	return ..()

/obj/structure/clockwork_ark/process(seconds_per_tick)
	phase_time_remaining -= seconds_per_tick * 10
	if(phase_time_remaining <= 0)
		advance_phase()
		return
	if(phase == ARK_PHASE_BUILD && phase_time_remaining <= ARK_PREP_WARNING && phase_time_remaining > ARK_PREP_WARNING - 10)
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_bold(span_danger("WARNING: The Ark is about to enter preparation phase! Return to Reebe immediately!")))

/obj/structure/clockwork_ark/proc/advance_phase()
	switch(phase)
		if(ARK_PHASE_BUILD)
			phase = ARK_PHASE_PREP
			phase_time_remaining = ARK_PREP_TIME
			on_prep_start()
		if(ARK_PHASE_PREP)
			phase = ARK_PHASE_DEFENSE
			phase_time_remaining = ARK_DEFENSE_TIME
			on_defense_start()
		if(ARK_PHASE_DEFENSE)
			phase = ARK_PHASE_ASSAULT
			phase_time_remaining = ARK_ASSAULT_TIME
			on_assault_start()
		if(ARK_PHASE_ASSAULT)
			phase = ARK_PHASE_CLEANUP
			phase_time_remaining = ARK_CLEANUP_TIME
			on_cleanup_start()
		if(ARK_PHASE_CLEANUP)
			phase = ARK_PHASE_COMPLETE
			phase_time_remaining = 0
			on_complete()

/obj/structure/clockwork_ark/proc/on_prep_start()
	priority_announce("WARNING: Unknown energy signatures detected. A massive clockwork device has been detected on an extradimensional plane. All crew are advised to arm themselves.", "Anomaly Alert", 'sound/effects/magic/clockwork/ark_activation_sequence.ogg')
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold("The Ark enters preparation phase! You have 5 minutes before the crew can invade."))
		for(var/datum/mind/servant_mind as anything in clockwork_team.members)
			if(!servant_mind.current || servant_mind.current.stat == DEAD)
				continue
			var/turf/reebe_turf = get_reebe_landing()
			if(reebe_turf)
				do_teleport(servant_mind.current, reebe_turf, forceMove = TRUE)

/obj/structure/clockwork_ark/proc/on_defense_start()
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold(span_danger("The crew is coming! Defend the Ark!")))
	spawn_invasion_portals()

/obj/structure/clockwork_ark/proc/on_assault_start()
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold("The assault continues. Hold the line!"))

/obj/structure/clockwork_ark/proc/on_cleanup_start()
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold("Almost there! The Ark is nearly complete!"))

/obj/structure/clockwork_ark/proc/on_complete()
	STOP_PROCESSING(SSobj, src)
	if(clockwork_team)
		for(var/datum/objective/clockwork/defend_ark/obj in clockwork_team.objectives)
			obj.on_ark_completed()
		clockwork_team.announce_to_servants(span_bold("<font size='5'>RATVAR HAS BEEN SUMMONED!</font>"))
	playsound(src, 'sound/effects/magic/clockwork/ark_activation.ogg', 100, FALSE, 50)
	new /obj/ratvar(get_turf(src))

/obj/structure/clockwork_ark/proc/on_ark_destroyed()
	if(clockwork_team)
		for(var/datum/objective/clockwork/defend_ark/obj in clockwork_team.objectives)
			obj.on_ark_destroyed()
		clockwork_team.announce_to_servants(span_bold(span_danger("<font size='5'>THE ARK HAS BEEN DESTROYED!</font>")))
	playsound(src, 'sound/machines/clockcult/ark_deathrattle.ogg', 100, FALSE, 50)

/obj/structure/clockwork_ark/proc/is_past_halfway()
	if(phase != ARK_PHASE_BUILD)
		return TRUE
	return phase_time_remaining <= (total_build_time / 2)

/obj/structure/clockwork_ark/proc/get_time_remaining()
	return phase_time_remaining

/obj/structure/clockwork_ark/proc/spawn_invasion_portals()
	var/list/station_areas = list()
	for(var/area/station/station_area in GLOB.areas)
		station_areas += station_area
	var/portals_to_spawn = min(length(station_areas), 30)
	var/list/chosen_areas = list()
	for(var/i in 1 to portals_to_spawn)
		if(!length(station_areas))
			break
		var/area/chosen = pick(station_areas)
		station_areas -= chosen
		chosen_areas += chosen
	for(var/area/target_area in chosen_areas)
		var/list/area_turfs = get_area_turfs(target_area)
		if(!length(area_turfs))
			continue
		var/turf/portal_turf = pick(area_turfs)
		var/turf/invasion_turf
		for(var/area/reebe/invasion_zone/inv_area in GLOB.areas)
			var/list/inv_turfs = get_area_turfs(inv_area)
			if(length(inv_turfs))
				invasion_turf = pick(inv_turfs)
			break
		if(!invasion_turf)
			continue
		addtimer(CALLBACK(src, PROC_REF(create_invasion_portal), portal_turf, invasion_turf), rand(0, 1 MINUTES))

/obj/structure/clockwork_ark/proc/create_invasion_portal(turf/station_turf, turf/reebe_turf)
	if(QDELETED(src))
		return
	new /obj/effect/portal/clockwork/invasion(station_turf, reebe_turf)
