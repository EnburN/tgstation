/obj/structure/clockwork/herald_beacon
	name = "Herald's Beacon"
	desc = "A massive clockwork beacon. Activating it declares war."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/vote_open = TRUE
	var/votes_for = 0
	var/list/datum/mind/voters = list()

/obj/structure/clockwork/herald_beacon/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(close_vote)), HERALD_VOTE_WINDOW)

/obj/structure/clockwork/herald_beacon/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The beacon is incomprehensible."))
		return
	if(!vote_open)
		to_chat(user, span_warning("The voting period has ended."))
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(!clock_datum?.clockwork_team)
		return
	if(user.mind in voters)
		to_chat(user, span_warning("You have already voted."))
		return
	voters += user.mind
	votes_for++
	clock_datum.clockwork_team.announce_to_servants(span_bold("[user.name] votes to activate the Herald's Beacon! ([votes_for]/[max(1, length(clock_datum.clockwork_team.members))])"))
	check_activation(clock_datum.clockwork_team)

/obj/structure/clockwork/herald_beacon/proc/check_activation(datum/team/clockwork/team)
	var/needed = max(1, length(team.members) / 2)
	if(votes_for >= needed)
		activate_herald(team)

/obj/structure/clockwork/herald_beacon/proc/close_vote()
	vote_open = FALSE

/obj/structure/clockwork/herald_beacon/proc/activate_herald(datum/team/clockwork/team)
	vote_open = FALSE
	team.herald_activated = TRUE
	priority_announce("ALERT: A massive energy surge has been detected from an extradimensional source.", "Clockwork Cult Alert", 'sound/effects/magic/clockwork/ark_activation.ogg')
	team.announce_to_servants(span_bold("<font size='4' color='#BE8700'>THE HERALD HAS BEEN ACTIVATED! WAR IS DECLARED!</font>"))
	team.announce_to_servants(span_brass("Scripture 30% faster. Power costs reduced 50%. You are now clockwork golems."))
	for(var/datum/mind/servant_mind as anything in team.members)
		if(!servant_mind.current || servant_mind.current.stat == DEAD)
			continue
		transform_to_golem(servant_mind.current)

/obj/structure/clockwork/herald_beacon/proc/transform_to_golem(mob/living/servant)
	ADD_TRAIT(servant, TRAIT_RESISTCOLD, "clockwork_golem")
	ADD_TRAIT(servant, TRAIT_RESISTHEAT, "clockwork_golem")
	ADD_TRAIT(servant, TRAIT_NOBREATH, "clockwork_golem")
	ADD_TRAIT(servant, TRAIT_RADIMMUNE, "clockwork_golem")
	ADD_TRAIT(servant, TRAIT_NO_SLIP_ALL, "clockwork_golem")
	to_chat(servant, span_bold("<font color='#BE8700'>Your body transforms into living clockwork!</font>"))
