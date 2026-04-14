/obj/ratvar
	name = "Ratvar, the Clockwork Justiciar"
	desc = "An impossibly massive entity of brass and gears."
	icon = 'icons/obj/mining_zones/dead_ratvar.dmi'
	icon_state = "dead_ratvar"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 10000
	light_range = 15
	light_color = "#BE8700"
	light_power = 5
	var/killed = FALSE

/obj/ratvar/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		for(var/datum/mind/servant_mind as anything in team.members)
			if(!servant_mind.current)
				continue
			empower_servant(servant_mind.current)

/obj/ratvar/Destroy()
	STOP_PROCESSING(SSobj, src)
	killed = TRUE
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		team.announce_to_servants(span_bold(span_danger("RATVAR HAS FALLEN!")))
	return ..()

/obj/ratvar/process(seconds_per_tick)
	for(var/turf/nearby in range(3, src))
		if(istype(nearby, /turf/open/floor/clockwork))
			continue
		if(istype(nearby, /turf/open/floor))
			nearby.ChangeTurf(/turf/open/floor/clockwork)
		else if(istype(nearby, /turf/closed/wall) && !istype(nearby, /turf/closed/wall/mineral/bronze))
			nearby.ChangeTurf(/turf/closed/wall/mineral/bronze)
	for(var/mob/living/victim in range(7, src))
		if(IS_CLOCKWORK(victim))
			continue
		if(victim.stat == DEAD)
			continue
		victim.adjust_hallucinations(10 SECONDS * seconds_per_tick)
		if(prob(5 * seconds_per_tick))
			to_chat(victim, span_userdanger("The presence of Ratvar overwhelms your mind!"))
			victim.Paralyze(2 SECONDS)

/obj/ratvar/proc/empower_servant(mob/living/servant)
	ADD_TRAIT(servant, TRAIT_GODMODE, "ratvar_empowerment")
	to_chat(servant, span_bold("<font size='4' color='#BE8700'>The power of Ratvar flows through you!</font>"))
