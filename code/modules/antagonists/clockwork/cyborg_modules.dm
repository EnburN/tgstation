/proc/convert_cyborg_to_clockwork(mob/living/silicon/robot/borg, datum/team/clockwork/team)
	if(!borg || !team)
		return FALSE
	var/datum/antagonist/clockwork/construct/clock_datum = new()
	borg.mind.add_antag_datum(clock_datum, team)
	if(borg.model)
		var/obj/item/clockwork_slab/slab = new(borg.model)
		borg.model.add_module(slab, nonstandard = TRUE, requires_rebuild = TRUE)
	to_chat(borg, span_bold("You have been converted to serve Ratvar!"))
	return TRUE
