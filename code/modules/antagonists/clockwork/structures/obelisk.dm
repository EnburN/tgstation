/obj/structure/destructible/clockwork/obelisk
	name = "clockwork obelisk"
	desc = "A tall brass obelisk covered in shifting glyphs."
	icon_state = "pylon"
	max_integrity = 150

/obj/structure/destructible/clockwork/obelisk/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IS_CLOCKWORK(user))
		return
	var/choice = tgui_input_list(user, "Choose an obelisk function", "Clockwork Obelisk", list("Hierophant Broadcast", "Spatial Gateway"))
	if(!choice)
		return
	switch(choice)
		if("Hierophant Broadcast")
			obelisk_broadcast(user)
		if("Spatial Gateway")
			obelisk_gateway(user)

/obj/structure/destructible/clockwork/obelisk/proc/obelisk_broadcast(mob/living/user)
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	var/datum/team/clockwork/team = clock_datum?.clockwork_team
	if(!team)
		return
	if(team.power < OBELISK_BROADCAST_COST)
		to_chat(user, span_warning("Not enough power! Need [OBELISK_BROADCAST_COST]W."))
		return
	var/message = tgui_input_text(user, "Enter broadcast message", "Hierophant Broadcast", max_length = MAX_MESSAGE_LEN)
	if(!message)
		return
	team.adjust_power(-OBELISK_BROADCAST_COST)
	var/formatted = "<span class='cult_large'><b>Obelisk Broadcast:</b> [message]</span>"
	team.announce_to_servants(formatted)

/obj/structure/destructible/clockwork/obelisk/proc/obelisk_gateway(mob/living/user)
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	var/datum/team/clockwork/team = clock_datum?.clockwork_team
	if(!team)
		return
	if(team.power < OBELISK_GATEWAY_COST)
		to_chat(user, span_warning("Not enough power! Need [OBELISK_GATEWAY_COST]W."))
		return
	var/list/targets = list()
	for(var/datum/mind/servant_mind as anything in team.members)
		if(servant_mind.current && servant_mind.current != user && servant_mind.current.stat != DEAD)
			targets["[servant_mind.current.name]"] = servant_mind.current
	for(var/obj/structure/destructible/clockwork/obelisk/other in GLOB.clockwork_structures)
		if(other == src)
			continue
		targets["Obelisk at [get_area(other)]"] = other
	if(!length(targets))
		to_chat(user, span_warning("No valid targets."))
		return
	var/chosen = tgui_input_list(user, "Choose destination", "Spatial Gateway", targets)
	if(!chosen || !targets[chosen])
		return
	team.adjust_power(-OBELISK_GATEWAY_COST)
	var/atom/target = targets[chosen]
	var/turf/target_turf = get_turf(target)
	// TODO: spatial gateway needs rework for station-only gameplay
	do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_CULT)
	to_chat(user, span_brass("A spatial gateway transports you!"))
