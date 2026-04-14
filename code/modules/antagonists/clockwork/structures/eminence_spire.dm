/obj/structure/clockwork/eminence_spire
	name = "Eminence Spire"
	desc = "A tall clockwork spire. A servant can sacrifice their form to become the Eminence."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	density = TRUE
	anchored = TRUE
	max_integrity = EMINENCE_SPIRE_HP
	/// Whether a vote is currently in progress
	var/vote_in_progress = FALSE
	/// The candidate mind for the current vote
	var/datum/mind/candidate
	/// World time when the vote ends
	var/vote_ends_at = 0
	/// List of minds that have voted against
	var/list/votes = list()
	/// Reference to the clockwork team
	var/datum/team/clockwork/clockwork_team

/obj/structure/clockwork/eminence_spire/Initialize(mapload)
	. = ..()
	GLOB.eminence_spires += src

/obj/structure/clockwork/eminence_spire/Destroy()
	GLOB.eminence_spires -= src
	clockwork_team = null
	candidate = null
	QDEL_NULL(votes)
	return ..()

/obj/structure/clockwork/eminence_spire/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The spire is incomprehensible."))
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(!clock_datum?.clockwork_team)
		return
	clockwork_team = clock_datum.clockwork_team
	// Check if an eminence already exists on this team or globally
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		if(team.eminence)
			to_chat(user, span_warning("An Eminence already exists."))
			return
	if(vote_in_progress)
		if(candidate == user.mind)
			to_chat(user, span_warning("You are the candidate!"))
			return
		register_opposition(user)
		return
	begin_vote(user.mind, clock_datum.clockwork_team)

/obj/structure/clockwork/eminence_spire/proc/begin_vote(datum/mind/applicant, datum/team/clockwork/team)
	candidate = applicant
	votes = list()
	vote_in_progress = TRUE
	vote_ends_at = world.time + EMINENCE_VOTE_WINDOW
	team.announce_to_servants(span_bold("[applicant.current?.name] volunteers to become the Eminence! Interact with the Spire to oppose within [DisplayTimeText(EMINENCE_VOTE_WINDOW)]."))
	addtimer(CALLBACK(src, PROC_REF(resolve_vote)), EMINENCE_VOTE_WINDOW)

/obj/structure/clockwork/eminence_spire/proc/register_opposition(mob/living/voter)
	if(!vote_in_progress || !candidate)
		return
	if(voter.mind in votes)
		to_chat(voter, span_warning("You have already voted against this candidate."))
		return
	votes += voter.mind
	to_chat(voter, span_brass("You vote against [candidate.current?.name]."))
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_brass("[voter.name] votes against the Eminence candidate."))
	// Check if majority already opposed
	var/eligible = clockwork_team ? max(1, length(clockwork_team.members) - 1) : 1
	if(length(votes) > eligible / 2)
		resolve_vote()

/obj/structure/clockwork/eminence_spire/proc/resolve_vote()
	if(!vote_in_progress || !candidate)
		return
	vote_in_progress = FALSE
	var/datum/mind/chosen = candidate
	candidate = null
	var/eligible = clockwork_team ? max(1, length(clockwork_team.members) - 1) : 1
	var/no_votes = length(votes)
	var/yes_votes = eligible - no_votes
	if(no_votes >= yes_votes)
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_bold("[chosen.current?.name]'s bid for Eminence has been rejected!"))
		votes = list()
		return
	votes = list()
	consume_candidate(chosen)

/obj/structure/clockwork/eminence_spire/proc/consume_candidate(datum/mind/chosen)
	var/mob/living/sacrifice = chosen.current
	if(!sacrifice || sacrifice.stat == DEAD || QDELETED(sacrifice))
		if(clockwork_team)
			clockwork_team.announce_to_servants(span_bold("The Eminence candidate was lost before they could ascend."))
		return
	visible_message(span_bold("[sacrifice.name] is consumed by the spire in a cascade of clockwork light!"))
	playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 75, TRUE)
	var/mob/living/basic/clockwork_eminence/eminence = new(get_turf(src), clockwork_team)
	chosen.transfer_to(eminence)
	sacrifice.gib()
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_bold("<font size='4'>The Eminence has risen!</font>"))
