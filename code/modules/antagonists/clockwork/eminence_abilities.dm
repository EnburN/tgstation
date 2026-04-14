// ---- Eminence Base Action ----

/// Base class for all Eminence abilities. Enforces ownership check.
/datum/action/innate/clockwork/eminence
	check_flags = NONE
	/// Length of the cooldown in deciseconds
	var/cooldown_length = 0
	/// World time when the cooldown ends
	var/cooldown_ends = 0

/datum/action/innate/clockwork/eminence/IsAvailable(feedback = FALSE)
	if(!istype(owner, /mob/living/basic/clockwork_eminence))
		return FALSE
	if(world.time < cooldown_ends)
		if(feedback)
			to_chat(owner, span_warning("That ability is still on cooldown."))
		return FALSE
	return TRUE

/// Starts the cooldown for this ability.
/datum/action/innate/clockwork/eminence/proc/start_cooldown()
	cooldown_ends = world.time + cooldown_length
	addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), cooldown_length)

// ---- Marker Visual ----

/obj/effect/temp_visual/clockwork_marker
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame"
	randomdir = FALSE
	duration = 30 SECONDS
	/// Color of the marker (set by subtype)
	var/marker_color = "#FFFFFF"

/obj/effect/temp_visual/clockwork_marker/Initialize(mapload, set_color)
	. = ..()
	if(set_color)
		marker_color = set_color
	color = marker_color

// ---- Marker Base Action ----

/datum/action/innate/clockwork/eminence/marker
	click_action = TRUE
	cooldown_length = 10 SECONDS
	/// Word shown in the marker broadcast
	var/marker_word = "here"
	/// Color of the placed marker visual
	var/marker_color = "#FFFFFF"
	enable_text = span_brass("Click a location to place your marker.")
	disable_text = span_brass("You cancel the marker.")

/datum/action/innate/clockwork/eminence/marker/do_ability(mob/living/clicker, atom/clicked_on)
	var/mob/living/basic/clockwork_eminence/eminence = clicker
	var/turf/target_turf = get_turf(clicked_on)
	if(!target_turf)
		return FALSE
	unset_ranged_ability(clicker, null)
	new /obj/effect/temp_visual/clockwork_marker(target_turf, marker_color)
	playsound(target_turf, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, TRUE)
	var/datum/team/clockwork/team = eminence.clockwork_team
	if(team)
		team.announce_to_servants(span_brass("The Eminence marks: [marker_word]!"))
	start_cooldown()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

// ---- Marker Subtypes ----

/datum/action/innate/clockwork/eminence/marker/rally
	name = "Rally Here"
	desc = "Mark a location and broadcast 'rally here' to all servants."
	button_icon_state = "cult_comms"
	marker_word = "RALLY HERE"
	marker_color = "#FFFF00"

/datum/action/innate/clockwork/eminence/marker/regroup
	name = "Regroup Here"
	desc = "Mark a location and broadcast 'regroup here' to all servants."
	button_icon_state = "cult_comms"
	marker_word = "REGROUP HERE"
	marker_color = "#4488FF"

/datum/action/innate/clockwork/eminence/marker/avoid
	name = "Avoid This Area"
	desc = "Mark a location and broadcast 'avoid this area' to all servants."
	button_icon_state = "cult_comms"
	marker_word = "AVOID THIS AREA"
	marker_color = "#FF4444"

/datum/action/innate/clockwork/eminence/marker/reinforce
	name = "Reinforce Here"
	desc = "Mark a location and broadcast 'reinforce here' to all servants."
	button_icon_state = "cult_comms"
	marker_word = "REINFORCE HERE"
	marker_color = "#BB44FF"

// ---- Goal Directive ----

/datum/action/innate/clockwork/eminence/directive
	name = "Issue Directive"
	desc = "Broadcast a strategic goal to all servants."
	button_icon_state = "cult_comms"
	cooldown_length = 60 SECONDS

/datum/action/innate/clockwork/eminence/directive/Activate()
	var/mob/living/basic/clockwork_eminence/eminence = owner
	if(!IsAvailable(feedback = TRUE))
		return
	var/list/directives = list(
		"Defend the Altar",
		"Advance",
		"Retreat",
		"Generate Power",
		"Build Defenses",
		"Harvest Essence",
	)
	var/chosen = tgui_input_list(usr, "Issue a directive to all servants", "Eminence Directive", directives)
	if(!chosen || !IsAvailable(feedback = TRUE))
		return
	var/datum/team/clockwork/team = eminence.clockwork_team
	if(team)
		team.announce_to_servants(span_bold("DIRECTIVE: [chosen]"))
	playsound(eminence, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, FALSE)
	start_cooldown()
	build_all_button_icons(UPDATE_BUTTON_STATUS)

// ---- Mass Recall ----

/datum/action/innate/clockwork/eminence/mass_recall
	name = "Mass Recall"
	desc = "After a windup, teleport all living servants to the Altar of Reforging. Once per round."
	button_icon_state = "cult_comms"
	cooldown_length = 99999 SECONDS
	/// Whether this ability has been used this round
	var/used = FALSE

/datum/action/innate/clockwork/eminence/mass_recall/IsAvailable(feedback = FALSE)
	if(used)
		if(feedback)
			to_chat(owner, span_warning("Mass Recall can only be used once per round."))
		return FALSE
	return ..()

/datum/action/innate/clockwork/eminence/mass_recall/Activate()
	var/mob/living/basic/clockwork_eminence/eminence = owner
	if(!IsAvailable(feedback = TRUE))
		return
	var/datum/team/clockwork/team = eminence.clockwork_team
	if(!team?.altar)
		to_chat(eminence, span_warning("There is no Altar of Reforging to recall to."))
		return
	used = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	team.announce_to_servants(span_bold("<font size='3'>Mass Recall initiated! All servants will be recalled in 10 seconds!</font>"))
	playsound(eminence, 'sound/effects/magic/clockwork/invoke_general.ogg', 100, FALSE)
	INVOKE_ASYNC(src, PROC_REF(do_mass_recall), eminence, team)

/datum/action/innate/clockwork/eminence/mass_recall/proc/do_mass_recall(mob/living/basic/clockwork_eminence/eminence, datum/team/clockwork/team)
	sleep(10 SECONDS)
	if(QDELETED(src) || QDELETED(eminence) || !team?.altar || QDELETED(team.altar))
		return
	var/turf/altar_turf = get_turf(team.altar)
	if(!altar_turf)
		return
	var/recall_count = 0
	for(var/datum/mind/servant_mind as anything in team.members)
		if(!servant_mind.current)
			continue
		var/mob/living/servant = servant_mind.current
		if(!isliving(servant) || servant.stat == DEAD)
			continue
		servant.forceMove(altar_turf)
		recall_count++
	team.announce_to_servants(span_brass("Mass Recall complete. [recall_count] servant[recall_count == 1 ? "" : "s"] recalled."))

// ---- Superheat Wall ----

/datum/action/innate/clockwork/eminence/superheat
	name = "Superheat Wall"
	desc = "Click a clockwork wall to double its hardness. 30 second cooldown."
	button_icon_state = "cult_comms"
	click_action = TRUE
	cooldown_length = 30 SECONDS
	enable_text = span_brass("Click a clockwork wall to superheat it.")
	disable_text = span_brass("You cancel the superheat.")

/datum/action/innate/clockwork/eminence/superheat/do_ability(mob/living/clicker, atom/clicked_on)
	if(!istype(clicked_on, /turf/closed/wall/mineral/bronze))
		to_chat(clicker, span_warning("You can only superheat clockwork walls."))
		return FALSE
	var/turf/closed/wall/mineral/bronze/target_wall = clicked_on
	if(target_wall.color == "#FF8800")
		to_chat(clicker, span_warning("That wall is already superheated."))
		return FALSE
	unset_ranged_ability(clicker, null)
	target_wall.hardness = max(1, target_wall.hardness * 2)
	target_wall.slicing_duration = target_wall.slicing_duration * 2
	target_wall.color = "#FF8800"
	target_wall.visible_message(span_warning("[target_wall] glows with intense heat!"))
	playsound(target_wall, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, TRUE)
	start_cooldown()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

// ---- Trigger Trap ----

/datum/action/innate/clockwork/eminence/trigger_trap
	name = "Trigger Trap"
	desc = "Click a clockwork trap sender to activate it remotely. 5 second cooldown."
	button_icon_state = "cult_comms"
	click_action = TRUE
	cooldown_length = 5 SECONDS
	enable_text = span_brass("Click a clockwork trap sender to trigger it.")
	disable_text = span_brass("You cancel the trigger.")

/datum/action/innate/clockwork/eminence/trigger_trap/do_ability(mob/living/clicker, atom/clicked_on)
	if(!istype(clicked_on, /obj/structure/clockwork_trap/sender))
		to_chat(clicker, span_warning("That is not a clockwork trap sender."))
		return FALSE
	var/obj/structure/clockwork_trap/sender/trap_sender = clicked_on
	unset_ranged_ability(clicker, null)
	trap_sender.send_signal()
	playsound(trap_sender, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, TRUE)
	start_cooldown()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE
