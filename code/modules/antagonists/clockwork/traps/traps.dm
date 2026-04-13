/obj/structure/clockwork_trap
	name = "clockwork trap"
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	anchored = TRUE
	density = FALSE
	var/list/obj/structure/clockwork_trap/linked = list()

/obj/structure/clockwork_trap/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You deconstruct [src]."))
	new /obj/item/stack/sheet/bronze(get_turf(src), 1)
	qdel(src)
	return TRUE

/obj/structure/clockwork_trap/proc/link_to(obj/structure/clockwork_trap/other)
	if(other == src)
		return FALSE
	if(other in linked)
		return FALSE
	linked += other
	return TRUE

// ---- Senders ----
/obj/structure/clockwork_trap/sender

/obj/structure/clockwork_trap/sender/proc/send_signal()
	for(var/obj/structure/clockwork_trap/receiver/receiver in linked)
		receiver.receive_signal(src)

/obj/structure/clockwork_trap/sender/lever
	name = "brass lever"
	desc = "A brass lever that activates linked traps."
	max_integrity = 75

/obj/structure/clockwork_trap/sender/lever/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The lever doesn't budge."))
		return
	visible_message(span_warning("[user] pulls [src]!"))
	playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 30, TRUE)
	send_signal()

/obj/structure/clockwork_trap/sender/pressure_sensor
	name = "pressure sensor"
	desc = "A nearly invisible pressure plate."
	max_integrity = 5
	alpha = 20

/obj/structure/clockwork_trap/sender/pressure_sensor/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	for(var/obj/structure/clockwork_trap/receiver/receiver in loc)
		link_to(receiver)

/obj/structure/clockwork_trap/sender/pressure_sensor/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!isliving(arrived))
		return
	var/mob/living/target = arrived
	if(IS_CLOCKWORK(target))
		return
	send_signal()

/obj/structure/clockwork_trap/sender/repeater
	name = "brass repeater"
	desc = "Sends a signal once per second when active."
	max_integrity = 15
	var/active = FALSE

/obj/structure/clockwork_trap/sender/repeater/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/clockwork_trap/sender/repeater/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/clockwork_trap/sender/repeater/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		return
	active = !active
	to_chat(user, span_brass("You [active ? "activate" : "deactivate"] the repeater."))

/obj/structure/clockwork_trap/sender/repeater/process(seconds_per_tick)
	if(!active)
		return
	send_signal()

// ---- Receivers ----
/obj/structure/clockwork_trap/receiver

/obj/structure/clockwork_trap/receiver/receive_signal(obj/structure/clockwork_trap/sender/source)
	return

/obj/structure/clockwork_trap/receiver/skewer
	name = "brass skewer"
	desc = "A retractable brass spear trap."
	max_integrity = 40
	alpha = 50
	var/extended = FALSE

/obj/structure/clockwork_trap/receiver/skewer/receive_signal(obj/structure/clockwork_trap/sender/source)
	if(extended)
		retract()
	else
		extend()

/obj/structure/clockwork_trap/receiver/skewer/proc/extend()
	extended = TRUE
	alpha = 255
	density = TRUE
	for(var/mob/living/victim in loc)
		if(IS_CLOCKWORK(victim))
			continue
		impale(victim)

/obj/structure/clockwork_trap/receiver/skewer/proc/retract()
	extended = FALSE
	alpha = 50
	density = FALSE

/obj/structure/clockwork_trap/receiver/skewer/proc/impale(mob/living/victim)
	visible_message(span_danger("[src] impales [victim]!"))
	victim.adjust_brute_loss(40)
	victim.Paralyze(3 SECONDS)
	to_chat(victim, span_userdanger("You are impaled on the skewer!"))
	victim.Immobilize(30 SECONDS)

/obj/structure/clockwork_trap/receiver/steam_vent
	name = "steam vent"
	desc = "A vent that releases blinding steam."
	max_integrity = 100
	var/venting = FALSE

/obj/structure/clockwork_trap/receiver/steam_vent/receive_signal(obj/structure/clockwork_trap/sender/source)
	venting = !venting
	if(venting)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
		opacity = FALSE

/obj/structure/clockwork_trap/receiver/steam_vent/process(seconds_per_tick)
	if(!venting)
		return
	opacity = TRUE
	for(var/mob/living/victim in loc)
		if(IS_CLOCKWORK(victim))
			continue
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			human_victim.adjust_wet_stacks(20)

/obj/structure/clockwork_trap/receiver/steam_vent/Destroy()
	STOP_PROCESSING(SSobj, src)
	opacity = FALSE
	return ..()
