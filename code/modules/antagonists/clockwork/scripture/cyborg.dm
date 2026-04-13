/datum/clockwork_scripture/cyborg/judicial_marker
	name = "Judicial Marker"
	desc = "Charges your slab for 5 seconds. Click a turf to place a judicial marker."
	tier = SCRIPTURE_CYBORG
	power_cost = 0
	invocation_time = 3 SECONDS
	cyborg_only = TRUE

/datum/clockwork_scripture/cyborg/judicial_marker/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	slab.charge_type = "judicial_marker"
	slab.charge_uses = 1
	to_chat(user, span_brass("Your slab charges with judicial force."))
	addtimer(CALLBACK(slab, TYPE_PROC_REF(/obj/item/clockwork_slab, clear_charge)), 5 SECONDS)
	return TRUE

/datum/clockwork_scripture/cyborg/linked_vanguard
	name = "Linked Vanguard"
	desc = "Charges your slab for 5 seconds. Use on another servant to grant both of you Vanguard."
	tier = SCRIPTURE_CYBORG
	power_cost = 0
	invocation_time = 3 SECONDS
	cyborg_only = TRUE

/datum/clockwork_scripture/cyborg/linked_vanguard/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	slab.charge_type = "linked_vanguard"
	slab.charge_uses = 1
	to_chat(user, span_brass("Your slab charges with defensive energy."))
	addtimer(CALLBACK(slab, TYPE_PROC_REF(/obj/item/clockwork_slab, clear_charge)), 5 SECONDS)
	return TRUE
