/obj/structure/clockwork/eminence_spire
	name = "Eminence Spire"
	desc = "A tall clockwork spire. A servant can sacrifice their form to become the Eminence."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/eminence_created = FALSE
	var/datum/mind/volunteer
	var/votes_against = 0
	var/eligible_voters = 0

/obj/structure/clockwork/eminence_spire/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The spire is incomprehensible."))
		return
	if(eminence_created)
		to_chat(user, span_warning("An Eminence has already been appointed."))
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(!clock_datum?.clockwork_team)
		return
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		if(team.eminence)
			to_chat(user, span_warning("An Eminence already exists."))
			eminence_created = TRUE
			return
	if(volunteer)
		if(volunteer == user.mind)
			to_chat(user, span_warning("You are the volunteer!"))
			return
		votes_against++
		to_chat(user, span_brass("You vote against [volunteer.current.name]."))
		clock_datum.clockwork_team.announce_to_servants(span_brass("[user.name] votes against the Eminence candidate."))
		check_vote(clock_datum.clockwork_team)
		return
	volunteer = user.mind
	eligible_voters = length(clock_datum.clockwork_team.members) - 1
	clock_datum.clockwork_team.announce_to_servants(span_bold("[user.name] volunteers to become the Eminence! Interact with the Spire to oppose."))
	addtimer(CALLBACK(src, PROC_REF(resolve_vote), clock_datum.clockwork_team), 30 SECONDS)

/obj/structure/clockwork/eminence_spire/proc/check_vote(datum/team/clockwork/team)
	if(eligible_voters > 0 && votes_against > eligible_voters / 2)
		team.announce_to_servants(span_bold("[volunteer.current.name]'s bid for Eminence has been rejected!"))
		volunteer = null
		votes_against = 0
		eligible_voters = 0

/obj/structure/clockwork/eminence_spire/proc/resolve_vote(datum/team/clockwork/team)
	if(!volunteer || eminence_created)
		return
	if(eligible_voters > 0 && votes_against > eligible_voters / 2)
		return
	eminence_created = TRUE
	var/mob/living/sacrifice = volunteer.current
	if(!sacrifice || sacrifice.stat == DEAD)
		volunteer = null
		eminence_created = FALSE
		return
	var/mob/camera/clockwork_eminence/eminence = new(get_turf(src), team)
	sacrifice.mind.transfer_to(eminence)
	sacrifice.gib()
	team.announce_to_servants(span_bold("<font size='4'>The Eminence has risen!</font>"))
