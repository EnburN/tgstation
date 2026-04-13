/obj/structure/destructible/clockwork/mania_motor
	name = "mania motor"
	desc = "A clockwork device that emits maddening vibrations."
	icon_state = "pylon"
	max_integrity = 100
	var/active = FALSE

/obj/structure/destructible/clockwork/mania_motor/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/mania_motor/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/clockwork/mania_motor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!IS_CLOCKWORK(user))
		return
	active = !active
	to_chat(user, span_brass("You [active ? "activate" : "deactivate"] the mania motor."))

/obj/structure/destructible/clockwork/mania_motor/process(seconds_per_tick)
	if(!active || !anchored)
		return
	var/power_needed = MANIA_MOTOR_POWER_DRAIN * seconds_per_tick
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		if(team.power < power_needed)
			active = FALSE
			visible_message(span_warning("[src] sputters and shuts down!"))
			return
		team.adjust_power(-power_needed)
		break
	var/effectiveness = get_effectiveness()
	for(var/mob/living/carbon/victim in range(5, src))
		if(IS_CLOCKWORK(victim))
			continue
		if(victim.stat == DEAD)
			continue
		victim.adjust_brute_loss(1 * seconds_per_tick * effectiveness)
		if(prob(15 * seconds_per_tick * effectiveness))
			victim.adjust_hallucinations(30 SECONDS)
		if(prob(10 * seconds_per_tick * effectiveness))
			victim.set_confusion_if_lower(10 SECONDS)
