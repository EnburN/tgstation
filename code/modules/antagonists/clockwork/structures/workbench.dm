/// The Forge Workbench: servants use this to craft mechanical components from raw materials.
/obj/structure/clockwork_workbench
	name = "Forge Workbench"
	desc = "A brass-and-clockwork worktable etched with gear-wheels. It hums with mechanical potential."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "replicant_alloy"
	density = TRUE
	anchored = TRUE
	max_integrity = FORGE_WORKBENCH_HP

	/// Stored input materials — assoc list of type path → count/volume
	var/list/material_reserves
	/// The recipe currently being crafted
	var/datum/clockwork_recipe/active_recipe
	/// World time when the current craft completes
	var/craft_completes_at = 0
	/// Reference to the owning clockwork team
	var/datum/team/clockwork/clockwork_team

/obj/structure/clockwork_workbench/Initialize(mapload)
	. = ..()
	material_reserves = list()

/obj/structure/clockwork_workbench/Destroy()
	if(active_recipe)
		STOP_PROCESSING(SSobj, src)
		qdel(active_recipe)
		active_recipe = null
	clockwork_team = null
	return ..()

/obj/structure/clockwork_workbench/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The workbench's mechanisms are incomprehensible to you."))
		return
	set_team_from_user(user)
	ui_interact(user)

/obj/structure/clockwork_workbench/attackby(obj/item/weapon, mob/living/user, params)
	if(!IS_CLOCKWORK(user))
		return ..()
	// Absorb stacks into material reserves
	if(istype(weapon, /obj/item/stack))
		var/obj/item/stack/stack_item = weapon
		var/stack_type = stack_item.type
		if(isnull(material_reserves[stack_type]))
			material_reserves[stack_type] = 0
		material_reserves[stack_type] += stack_item.amount
		to_chat(user, span_brass("You feed [stack_item.amount] [stack_item.name] into the workbench. ([material_reserves[stack_type]] stored)"))
		qdel(stack_item)
		return
	// Absorb reagent containers
	if(istype(weapon, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = weapon
		if(container.reagents.total_volume <= 0)
			to_chat(user, span_warning("The container is empty."))
			return
		for(var/datum/reagent/reagent in container.reagents.reagent_list)
			var/reagent_type = reagent.type
			if(isnull(material_reserves[reagent_type]))
				material_reserves[reagent_type] = 0
			material_reserves[reagent_type] += reagent.volume
			to_chat(user, span_brass("You pour [reagent.volume]u of [reagent.name] into the workbench. ([material_reserves[reagent_type]]u stored)"))
		container.reagents.clear_reagents()
		return
	return ..()

/obj/structure/clockwork_workbench/proc/set_team_from_user(mob/user)
	if(clockwork_team)
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	if(clock_datum?.clockwork_team)
		clockwork_team = clock_datum.clockwork_team

/// Validates inputs and power, consumes them, and starts the craft timer.
/obj/structure/clockwork_workbench/proc/begin_craft(datum/clockwork_recipe/recipe, mob/living/user)
	if(active_recipe)
		to_chat(user, span_warning("The workbench is already crafting something."))
		return FALSE
	if(!clockwork_team)
		to_chat(user, span_warning("The workbench is not linked to a clockwork team."))
		return FALSE
	if(!recipe.has_inputs(material_reserves))
		to_chat(user, span_warning("Insufficient materials: [recipe.input_summary()]"))
		return FALSE
	if(clockwork_team.power < recipe.power_cost)
		to_chat(user, span_warning("Insufficient power. Need [recipe.power_cost]W, have [clockwork_team.power]W."))
		return FALSE
	recipe.consume_inputs(material_reserves)
	clockwork_team.adjust_power(-recipe.power_cost)
	active_recipe = recipe
	craft_completes_at = world.time + COMPONENT_CRAFT_TIME
	START_PROCESSING(SSobj, src)
	to_chat(user, span_brass("You begin crafting [recipe.name]. It will be ready in [COMPONENT_CRAFT_TIME / 10] seconds."))
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_brass("Forging has begun: [recipe.name]."))
	return TRUE

/obj/structure/clockwork_workbench/process(seconds_per_tick)
	if(!active_recipe)
		STOP_PROCESSING(SSobj, src)
		return
	if(world.time < craft_completes_at)
		return
	finish_craft()

/// Spawns the output item and resets the workbench state.
/obj/structure/clockwork_workbench/proc/finish_craft()
	STOP_PROCESSING(SSobj, src)
	if(!active_recipe)
		return
	var/output_path = active_recipe.output_path
	var/recipe_name = active_recipe.name
	qdel(active_recipe)
	active_recipe = null
	craft_completes_at = 0
	new output_path(get_turf(src))
	playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 50, FALSE)
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_brass("The Forge Workbench has completed: [recipe_name]!"))

// ---- TGUI ----

/obj/structure/clockwork_workbench/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ClockworkWorkbench")
		ui.open()

/obj/structure/clockwork_workbench/ui_data(mob/user)
	var/list/data = list()
	data["crafting"] = !isnull(active_recipe)
	data["recipe_name"] = active_recipe ? active_recipe.name : null
	data["time_remaining"] = active_recipe ? max(0, (craft_completes_at - world.time) / 10) : 0
	data["power"] = clockwork_team ? clockwork_team.power : 0

	var/list/reserves_data = list()
	for(var/mat_type in material_reserves)
		var/list/entry = list()
		entry["type"] = "[mat_type]"
		entry["name"] = initial(mat_type.name)
		entry["amount"] = material_reserves[mat_type]
		reserves_data += list(entry)
	data["reserves"] = reserves_data

	var/list/recipe_list = list()
	for(var/recipe_type in subtypesof(/datum/clockwork_recipe))
		var/datum/clockwork_recipe/recipe = new recipe_type()
		var/list/recipe_data = list()
		recipe_data["type"] = "[recipe_type]"
		recipe_data["name"] = recipe.name
		recipe_data["desc"] = recipe.desc
		recipe_data["power_cost"] = recipe.power_cost
		recipe_data["can_craft"] = recipe.has_inputs(material_reserves) && (clockwork_team ? clockwork_team.power >= recipe.power_cost : FALSE)
		recipe_data["inputs"] = recipe.input_summary()
		qdel(recipe)
		recipe_list += list(recipe_data)
	data["recipes"] = recipe_list

	return data

/obj/structure/clockwork_workbench/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr
	if(!IS_CLOCKWORK(user))
		return

	switch(action)
		if("craft")
			var/recipe_path = text2path(params["recipe_type"])
			if(!recipe_path || !ispath(recipe_path, /datum/clockwork_recipe))
				return
			var/datum/clockwork_recipe/recipe = new recipe_path()
			if(!begin_craft(recipe, user))
				qdel(recipe)
			return TRUE
