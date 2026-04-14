// ---- Relic Candidate Pool ----

/// Pool of item type paths eligible to be flagged as relics at round start.
GLOBAL_LIST_INIT(clockwork_relic_candidates, list(
	/obj/item/nullrod,
	/obj/item/disk/nuclear,
	/obj/item/gun/energy/laser/captain,
))

// ---- Round-Start Flagging ----

/// Iterates the relic candidate pool, finds instances on station z-levels,
/// picks up to RELICS_REQUIRED random ones, and flags each as a relic.
/proc/flag_random_relics(datum/team/clockwork/cult_team)
	var/list/found_candidates = list()
	for(var/relic_type as anything in GLOB.clockwork_relic_candidates)
		for(var/obj/item/candidate as anything in world)
			if(!istype(candidate, relic_type))
				continue
			var/turf/candidate_turf = get_turf(candidate)
			if(!candidate_turf)
				continue
			if(!is_station_level(candidate_turf.z))
				continue
			found_candidates += candidate

	// Shuffle and pick up to RELICS_REQUIRED
	var/list/shuffled = shuffle(found_candidates)
	var/picked = min(RELICS_REQUIRED, length(shuffled))
	for(var/i in 1 to picked)
		flag_item_as_relic(shuffled[i], cult_team)

/// Attaches the clockwork_relic component to an item and registers it with the cult team.
/proc/flag_item_as_relic(obj/item/target, datum/team/clockwork/cult_team)
	if(!istype(target))
		return
	target.AddComponent(/datum/component/clockwork_relic, cult_team)
	cult_team.relics += target

// ---- Essence Target Population ----

/// Scans the player list for mindshielded humans and registers their minds
/// as valid targets for Essence Cog excision.
/proc/populate_essence_targets(datum/team/clockwork/cult_team)
	for(var/mob/living/carbon/human/candidate as anything in GLOB.player_list)
		if(!ishuman(candidate))
			continue
		if(!HAS_TRAIT(candidate, TRAIT_MINDSHIELD))
			continue
		if(!candidate.mind)
			continue
		cult_team.essence_targets += candidate.mind
