/mob/camera/clockwork_eminence
	name = "The Eminence"
	icon = 'icons/mob/eyemob.dmi'
	icon_state = "youreyemob"
	invisibility = INVISIBILITY_OBSERVER
	see_invisible = SEE_INVISIBLE_OBSERVER
	interaction_range = INFINITY
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
	var/datum/team/clockwork/clockwork_team
	var/recall_used = FALSE

/mob/camera/clockwork_eminence/Initialize(mapload, datum/team/clockwork/team)
	. = ..()
	clockwork_team = team
	if(team)
		team.eminence = src
	var/datum/action/innate/clockwork_eminence/rally/rally_action = new()
	rally_action.Grant(src)
	var/datum/action/innate/clockwork_eminence/mass_recall/recall_action = new()
	recall_action.Grant(src)

/mob/camera/clockwork_eminence/Destroy()
	if(clockwork_team?.eminence == src)
		clockwork_team.eminence = null
	clockwork_team = null
	return ..()

/mob/camera/clockwork_eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode)
	if(!message)
		return
	var/formatted = "<span class='cult_large'><b>The Eminence:</b> [message]</span>"
	if(clockwork_team)
		clockwork_team.announce_to_servants(formatted)

/mob/camera/clockwork_eminence/Move(atom/newloc, direct, glide_size_override, update_dir)
	var/turf/destination = get_turf(newloc)
	if(destination)
		var/area/dest_area = get_area(destination)
		if(istype(dest_area, /area/station/service/chapel))
			to_chat(src, span_warning("Holy ground repels you!"))
			return FALSE
	return ..()

// ---- Eminence Actions ----
/datum/action/innate/clockwork_eminence
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	check_flags = NONE

/datum/action/innate/clockwork_eminence/rally
	name = "Issue Command"
	desc = "Issue a cult-wide command at your location."
	button_icon_state = "cult_comms"

/datum/action/innate/clockwork_eminence/rally/Activate()
	var/mob/camera/clockwork_eminence/eminence = owner
	if(!istype(eminence))
		return
	var/command = tgui_input_list(owner, "Choose a command", "Eminence Command", list("Rally", "Regroup", "Avoid", "Reinforce", "Defend the Ark", "Advance", "Retreat", "Generate Power", "Build Defenses"))
	if(!command)
		return
	var/formatted = "<span class='cult_large'><b>The Eminence commands: [command]!</b></span>"
	if(eminence.clockwork_team)
		eminence.clockwork_team.announce_to_servants(formatted)
		for(var/datum/mind/servant_mind as anything in eminence.clockwork_team.members)
			if(servant_mind.current)
				SEND_SOUND(servant_mind.current, sound('sound/effects/magic/clockwork/invoke_general.ogg'))

/datum/action/innate/clockwork_eminence/mass_recall
	name = "Mass Recall"
	desc = "Once per round: teleport every living servant to the Ark after 10 seconds."
	button_icon_state = "cult_comms"

/datum/action/innate/clockwork_eminence/mass_recall/Activate()
	var/mob/camera/clockwork_eminence/eminence = owner
	if(!istype(eminence) || eminence.recall_used)
		to_chat(owner, span_warning("Mass recall has already been used."))
		return
	eminence.recall_used = TRUE
	for(var/mob/player in GLOB.player_list)
		SEND_SOUND(player, sound('sound/effects/magic/clockwork/ark_activation_sequence.ogg'))
	if(eminence.clockwork_team)
		eminence.clockwork_team.announce_to_servants(span_bold(span_danger("MASS RECALL INITIATED!")))
	sleep(10 SECONDS)
	if(QDELETED(eminence) || !eminence.clockwork_team)
		return
	var/turf/ark_turf = get_turf(GLOB.clockwork_ark)
	if(!ark_turf)
		return
	for(var/datum/mind/servant_mind as anything in eminence.clockwork_team.members)
		if(!servant_mind.current || servant_mind.current.stat == DEAD)
			continue
		do_teleport(servant_mind.current, ark_turf, forceMove = TRUE)
