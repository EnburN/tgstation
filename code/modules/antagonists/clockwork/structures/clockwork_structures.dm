/obj/structure/destructible/clockwork
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE
	resistance_flags = FIRE_PROOF
	var/datum/team/clockwork/clockwork_team

/obj/structure/destructible/clockwork/Initialize(mapload)
	. = ..()
	GLOB.clockwork_structures += src

/obj/structure/destructible/clockwork/Destroy()
	GLOB.clockwork_structures -= src
	clockwork_team = null
	return ..()

/obj/structure/destructible/clockwork/examine(mob/user)
	. = ..()
	if(IS_CLOCKWORK(user))
		. += span_brass("Integrity: [obj_integrity]/[max_integrity]")

/obj/structure/destructible/clockwork/wrench_act(mob/living/user, obj/item/tool)
	if(!IS_CLOCKWORK(user))
		return FALSE
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You begin unsecuring [src]..."))
	if(!tool.use_tool(src, user, 4 SECONDS))
		return FALSE
	to_chat(user, span_notice("You unsecure [src]."))
	set_anchored(FALSE)
	return TRUE

/obj/structure/destructible/clockwork/proc/get_effectiveness()
	var/health_ratio = obj_integrity / max_integrity
	return max(0.5, health_ratio)
