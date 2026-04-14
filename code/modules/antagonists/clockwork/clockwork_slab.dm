/obj/item/clockwork_slab
	name = "clockwork slab"
	desc = "A strange bronze tablet covered in shifting glyphs and tiny gears."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	inhand_icon_state = "book"

	/// Reference to the clockwork team (set on first use by a servant)
	var/datum/team/clockwork/clockwork_team
	/// List of quickbound scripture type paths (up to 5)
	var/list/quickbinds = list()
	/// Temporary charge state for scripture that charge the slab
	var/charge_type = null
	/// Remaining charge uses
	var/charge_uses = 0

/obj/item/clockwork_slab/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clockwork_slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clockwork_slab/process(seconds_per_tick)
	if(!isliving(loc))
		return
	var/mob/living/holder = loc
	if(!IS_CLOCKWORK(holder))
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(holder)
	if(!clock_datum?.clockwork_team)
		return
	clock_datum.clockwork_team.adjust_power(SLAB_PASSIVE_POWER * seconds_per_tick)

/obj/item/clockwork_slab/attack_self(mob/user)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The slab's glyphs are incomprehensible to you."))
		return
	set_team_from_user(user)
	ui_interact(user)

/obj/item/clockwork_slab/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClockworkSlab")
		ui.open()

/obj/item/clockwork_slab/ui_data(mob/user)
	var/list/data = list()

	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	var/datum/team/clockwork/team = clock_datum?.clockwork_team

	data["power"] = team ? team.power : 0
	data["herald_active"] = team ? team.herald_activated : FALSE
	data["script_unlocked"] = team ? team.scripture_unlocked_script : FALSE
	data["application_unlocked"] = team ? team.scripture_unlocked_application : FALSE
	data["quickbinds"] = quickbinds.Copy()

	if(team?.altar)
		data["altar_state"] = team.altar.state
	else
		data["altar_state"] = 0

	data["servant_count"] = team ? length(team.members) : 0

	var/list/scripture_list = list()
	for(var/datum/clockwork_scripture/scripture_type as anything in GLOB.clockwork_scripture_types)
		if(initial(scripture_type.cyborg_only) && !iscyborg(user))
			continue
		var/list/scripture_data = list()
		scripture_data["type"] = "[scripture_type]"
		scripture_data["name"] = initial(scripture_type.name)
		scripture_data["desc"] = initial(scripture_type.desc)
		scripture_data["tier"] = initial(scripture_type.tier)
		scripture_data["power_cost"] = initial(scripture_type.power_cost)
		scripture_data["invocation_time"] = initial(scripture_type.invocation_time) / 10
		scripture_data["invokers_required"] = initial(scripture_type.invokers_required)
		scripture_data["quickbind_icon"] = initial(scripture_type.quickbind_icon)

		var/tier = initial(scripture_type.tier)
		var/is_locked = FALSE
		if(tier == SCRIPTURE_SCRIPT && !data["script_unlocked"])
			is_locked = TRUE
		if(tier == SCRIPTURE_APPLICATION && !data["application_unlocked"])
			is_locked = TRUE
		scripture_data["locked"] = is_locked

		scripture_list += list(scripture_data)
	data["scriptures"] = scripture_list

	return data

/obj/item/clockwork_slab/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr
	if(!IS_CLOCKWORK(user))
		return

	switch(action)
		if("recite")
			var/scripture_path = text2path(params["scripture_type"])
			if(!scripture_path)
				return
			var/datum/clockwork_scripture/scripture = new scripture_path()
			scripture.invoke(user, src)
			qdel(scripture)
			return TRUE

		if("quickbind")
			var/scripture_path = params["scripture_type"]
			if(length(quickbinds) >= 5)
				to_chat(user, span_warning("You can only have 5 quickbinds!"))
				return
			if(scripture_path in quickbinds)
				quickbinds -= scripture_path
				to_chat(user, span_notice("Scripture unbound."))
			else
				quickbinds += scripture_path
				to_chat(user, span_notice("Scripture quickbound."))
			return TRUE

/obj/item/clockwork_slab/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!IS_CLOCKWORK(user))
		return
	if(!istype(target, /obj/item))
		return
	var/obj/item/target_item = target
	var/datum/component/clockwork_relic/relic_component = target_item.GetComponent(/datum/component/clockwork_relic)
	if(!relic_component)
		return
	if(relic_component.identified)
		to_chat(user, span_notice("[target_item] has already been identified."))
		return
	to_chat(user, span_brass("You begin channeling through [target_item], searching for Ratvar's essence..."))
	if(!do_after(user, RELIC_IDENTIFICATION_TIME, target = target_item))
		return
	if(QDELETED(target_item) || relic_component.identified)
		return
	relic_component.identify(user)

/obj/item/clockwork_slab/proc/set_team_from_user(mob/user)
	if(clockwork_team)
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(clock_datum?.clockwork_team)
		clockwork_team = clock_datum.clockwork_team

/obj/item/clockwork_slab/proc/clear_charge()
	charge_type = null
	charge_uses = 0

// ---- Locate Relic Action ----

/// Scans the cult team's relic list for unidentified relics and reports their direction.
/datum/action/innate/clockwork/locate_relic
	name = "Locate Relic"
	desc = "Focus your mind to sense the nearest unidentified relic fragment."
	button_icon_state = "cult_comms"
	/// World time when the locate cooldown expires
	var/cooldown_ends = 0

/datum/action/innate/clockwork/locate_relic/IsAvailable(feedback = FALSE)
	if(world.time < cooldown_ends)
		if(feedback)
			to_chat(owner, span_warning("You must wait before locating another relic."))
		return FALSE
	return ..()

/datum/action/innate/clockwork/locate_relic/Activate()
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(owner)
	var/datum/team/clockwork/team = clock_datum?.clockwork_team
	if(!team)
		to_chat(owner, span_warning("You are not connected to a clockwork team."))
		return

	var/list/unidentified = list()
	for(var/obj/item/relic_item as anything in team.relics)
		if(QDELETED(relic_item))
			continue
		var/datum/component/clockwork_relic/relic_component = relic_item.GetComponent(/datum/component/clockwork_relic)
		if(relic_component && !relic_component.identified)
			unidentified += relic_item

	if(!length(unidentified))
		to_chat(owner, span_brass("All relics have been identified."))
		return

	// Find closest unidentified relic
	var/obj/item/nearest_relic
	var/nearest_dist = INFINITY
	for(var/obj/item/relic_item as anything in unidentified)
		var/dist = get_dist(owner, relic_item)
		if(dist < nearest_dist)
			nearest_dist = dist
			nearest_relic = relic_item

	if(!nearest_relic)
		to_chat(owner, span_warning("You cannot sense any relics."))
		return

	var/direction = get_dir(owner, nearest_relic)
	var/dir_text = dir2text(direction)
	var/dist_text
	if(nearest_dist <= 5)
		dist_text = "very close"
	else if(nearest_dist <= 15)
		dist_text = "nearby"
	else if(nearest_dist <= 30)
		dist_text = "some distance away"
	else
		dist_text = "far away"

	to_chat(owner, span_brass("You sense an unidentified relic fragment [dist_text] to the [dir_text]. ([length(unidentified)] unidentified remaining)"))
	cooldown_ends = world.time + RELIC_LOCATE_COOLDOWN
	addtimer(CALLBACK(src, PROC_REF(build_all_button_icons)), RELIC_LOCATE_COOLDOWN)
