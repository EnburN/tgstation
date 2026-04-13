/obj/item/clockwork_slab
	name = "clockwork slab"
	desc = "A strange bronze tablet covered in shifting glyphs and tiny gears."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state = "ereader"
	w_class = WEIGHT_CLASS_SMALL
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	inhand_icon_state = "ereader"

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

	if(team?.ark)
		data["ark_phase"] = team.ark.phase
		data["ark_time_remaining"] = team.ark.get_time_remaining()
	else
		data["ark_phase"] = 0
		data["ark_time_remaining"] = 0

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

/obj/item/clockwork_slab/proc/set_team_from_user(mob/user)
	if(clockwork_team)
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(clock_datum?.clockwork_team)
		clockwork_team = clock_datum.clockwork_team

/obj/item/clockwork_slab/proc/clear_charge()
	charge_type = null
	charge_uses = 0
