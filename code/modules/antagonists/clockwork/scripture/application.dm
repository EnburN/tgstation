// ---- Clockwork Marauder ----
/datum/clockwork_scripture/clockwork_marauder
	name = "Clockwork Marauder"
	desc = "Creates a shell for a clockwork marauder — a combat construct that can deflect projectiles."
	tier = SCRIPTURE_APPLICATION
	power_cost = 8000
	invocation_time = 8 SECONDS
	whispered_invocation = "Mar-aud-er arise!"

/datum/clockwork_scripture/clockwork_marauder/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/obj/structure/clockwork_marauder_shell/shell = new(get_turf(user))
	to_chat(user, span_brass("A clockwork marauder shell materializes."))
	shell.poll_for_ghost()
	return TRUE

// ---- Sigil of Transmission (scripture) ----
/datum/clockwork_scripture/sigil_of_transmission
	name = "Sigil of Transmission"
	desc = "Creates a sigil that powers nearby structures, drains electronics, and recharges servant cyborgs."
	tier = SCRIPTURE_APPLICATION
	power_cost = 200
	invocation_time = 7 SECONDS
	whispered_invocation = "Trans-mit power!"

/datum/clockwork_scripture/sigil_of_transmission/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/effect/clockwork_sigil/transmission(get_turf(user))
	to_chat(user, span_brass("A Sigil of Transmission forms beneath you."))
	return TRUE

// ---- Mania Motor ----
/datum/clockwork_scripture/mania_motor
	name = "Mania Motor"
	desc = "Creates a structure that causes hallucinations and damage to nearby non-servants. Consumes 150W/sec."
	tier = SCRIPTURE_APPLICATION
	power_cost = 750
	invocation_time = 8 SECONDS
	invokers_required = 2
	whispered_invocation = "Man-ia engine roar!"

/datum/clockwork_scripture/mania_motor/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/structure/destructible/clockwork/mania_motor(get_turf(user))
	to_chat(user, span_brass("A mania motor rises from the floor."))
	return TRUE

// ---- Clockwork Obelisk ----
/datum/clockwork_scripture/clockwork_obelisk
	name = "Clockwork Obelisk"
	desc = "Creates an obelisk for broadcasting messages and opening two-way spatial gateways."
	tier = SCRIPTURE_APPLICATION
	power_cost = 300
	invocation_time = 8 SECONDS
	invokers_required = 2
	whispered_invocation = "Ob-el-isk manifest!"

/datum/clockwork_scripture/clockwork_obelisk/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/structure/destructible/clockwork/obelisk(get_turf(user))
	to_chat(user, span_brass("A clockwork obelisk rises from the floor."))
	return TRUE
