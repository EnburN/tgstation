// ---- Placement Validation ----

/// Checks whether a turf is a valid location to place the Altar of Reforging.
/// Returns TRUE if valid, FALSE otherwise. Does not send feedback.
/proc/is_valid_clockwork_placement(turf/target)
	if(!target)
		return FALSE
	if(isspaceturf(target))
		return FALSE
	if(target.density)
		return FALSE
	// Reject tiles with dense movables (walls, structures, etc. already placed)
	for(var/atom/movable/occupant as anything in target)
		if(occupant.density)
			return FALSE
	// Reject high-security or sacred areas where the Eminence cannot manifest
	var/area/target_area = get_area(target)
	if(istype(target_area, /area/station/service/chapel))
		return FALSE
	if(istype(target_area, /area/station/security))
		return FALSE
	if(istype(target_area, /area/station/command/bridge))
		return FALSE
	if(istype(target_area, /area/station/medical))
		return FALSE
	if(istype(target_area, /area/station/ai))
		return FALSE
	if(istype(target_area, /area/station/hallway))
		return FALSE
	return TRUE

// ---- Placement Preview Overlay ----

/obj/effect/clockwork_placement_preview
	name = "placement preview"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "clockwork_wall"
	alpha = 100
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	density = FALSE

// ---- Place Altar Ability ----

/datum/action/innate/clockwork/eminence/place_altar
	name = "Place Altar of Reforging"
	desc = "Choose a location to manifest the Altar of Reforging. One use."
	button_icon_state = "cult_comms"
	click_action = TRUE
	enable_text = span_brass("Click a valid location to place the Altar of Reforging.")
	disable_text = span_brass("You cancel the altar placement.")
	/// List of sub-actions granted during placement mode
	var/list/placement_sub_actions

/datum/action/innate/clockwork/eminence/place_altar/New(Target)
	. = ..()
	placement_sub_actions = list()

/datum/action/innate/clockwork/eminence/place_altar/IsAvailable(feedback = FALSE)
	var/mob/living/basic/clockwork_eminence/eminence = owner
	if(!istype(eminence))
		return FALSE
	if(eminence.has_placed_altar)
		if(feedback)
			to_chat(owner, span_warning("You have already placed the Altar of Reforging."))
		return FALSE
	return ..()

/// Overrides set_ranged_ability to also spawn the preview and grant sub-actions.
/datum/action/innate/clockwork/eminence/place_altar/set_ranged_ability(mob/living/on_who, text_to_show)
	. = ..()
	var/mob/living/basic/clockwork_eminence/eminence = on_who
	if(!istype(eminence))
		return
	// Spawn a preview at the eminence's current location
	if(!eminence.placement_preview)
		eminence.placement_preview = new /obj/effect/clockwork_placement_preview(get_turf(eminence))
	// Grant rotate and cancel sub-actions if not already granted
	if(placement_sub_actions.len)
		return
	var/list/sub_types = list(
		/datum/action/innate/clockwork/eminence/place_altar/rotate/north,
		/datum/action/innate/clockwork/eminence/place_altar/rotate/east,
		/datum/action/innate/clockwork/eminence/place_altar/rotate/south,
		/datum/action/innate/clockwork/eminence/place_altar/rotate/west,
		/datum/action/innate/clockwork/eminence/place_altar/cancel,
	)
	for(var/sub_type as anything in sub_types)
		var/datum/action/innate/sub_action = new sub_type(eminence)
		sub_action.Grant(eminence)
		placement_sub_actions += sub_action

/// Overrides unset_ranged_ability to also remove the preview and revoke sub-actions.
/datum/action/innate/clockwork/eminence/place_altar/unset_ranged_ability(mob/living/on_who, text_to_show)
	. = ..()
	var/mob/living/basic/clockwork_eminence/eminence = on_who
	if(!istype(eminence))
		return
	QDEL_NULL(eminence.placement_preview)
	// Remove sub-actions
	for(var/datum/action/innate/sub_action as anything in placement_sub_actions)
		if(!QDELETED(sub_action))
			sub_action.Remove(eminence)
			qdel(sub_action)
	placement_sub_actions.Cut()

/datum/action/innate/clockwork/eminence/place_altar/InterceptClickOn(mob/living/clicker, params, atom/clicked_on)
	if(!IsAvailable(feedback = TRUE))
		unset_ranged_ability(clicker, disable_text)
		return FALSE
	if(!clicked_on)
		return FALSE
	return do_ability(clicker, clicked_on)

/datum/action/innate/clockwork/eminence/place_altar/do_ability(mob/living/clicker, atom/clicked_on)
	var/mob/living/basic/clockwork_eminence/eminence = clicker
	var/turf/target_turf = get_turf(clicked_on)
	if(!target_turf)
		return FALSE
	if(!is_valid_clockwork_placement(target_turf))
		to_chat(eminence, span_warning("The altar cannot be placed here."))
		return FALSE
	// Get the facing direction from the preview before cleaning up
	var/altar_dir = NORTH
	if(!QDELETED(eminence.placement_preview))
		altar_dir = eminence.placement_preview.dir
	// Unset click mode — this cleans up preview and sub-actions via unset_ranged_ability
	unset_ranged_ability(eminence, null)
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	// Mark as used
	eminence.has_placed_altar = TRUE
	// Spawn the altar
	var/obj/structure/clockwork_altar/altar = new(target_turf)
	altar.setDir(altar_dir)
	altar.clockwork_team = eminence.clockwork_team
	if(eminence.clockwork_team)
		eminence.clockwork_team.altar = altar
		eminence.clockwork_team.announce_to_servants(span_bold("The Altar of Reforging has manifested! Defend it at all costs."))
	playsound(target_turf, 'sound/effects/magic/clockwork/invoke_general.ogg', 75, FALSE)
	// Remove this ability from the HUD — it's been consumed
	Remove(eminence)
	qdel(src)
	return TRUE

/datum/action/innate/clockwork/eminence/place_altar/Remove(mob/removed_from)
	if(removed_from)
		unset_ranged_ability(removed_from, null)
	return ..()

// ---- Place Altar Sub-Actions ----

/// Rotate sub-action — rotates the placement preview to a given direction.
/datum/action/innate/clockwork/eminence/place_altar/rotate
	check_flags = NONE
	/// Direction this sub-action rotates to
	var/rotate_dir = NORTH

/datum/action/innate/clockwork/eminence/place_altar/rotate/IsAvailable(feedback = FALSE)
	return istype(owner, /mob/living/basic/clockwork_eminence)

/datum/action/innate/clockwork/eminence/place_altar/rotate/Activate()
	var/mob/living/basic/clockwork_eminence/eminence = owner
	if(!istype(eminence) || QDELETED(eminence.placement_preview))
		return
	eminence.placement_preview.setDir(rotate_dir)

/datum/action/innate/clockwork/eminence/place_altar/rotate/north
	name = "Rotate: North"
	desc = "Orient the altar preview to face north."
	button_icon_state = "cult_comms"
	rotate_dir = NORTH

/datum/action/innate/clockwork/eminence/place_altar/rotate/east
	name = "Rotate: East"
	desc = "Orient the altar preview to face east."
	button_icon_state = "cult_comms"
	rotate_dir = EAST

/datum/action/innate/clockwork/eminence/place_altar/rotate/south
	name = "Rotate: South"
	desc = "Orient the altar preview to face south."
	button_icon_state = "cult_comms"
	rotate_dir = SOUTH

/datum/action/innate/clockwork/eminence/place_altar/rotate/west
	name = "Rotate: West"
	desc = "Orient the altar preview to face west."
	button_icon_state = "cult_comms"
	rotate_dir = WEST

/// Cancel sub-action — exits placement mode by triggering the place_altar action again.
/datum/action/innate/clockwork/eminence/place_altar/cancel
	name = "Cancel Placement"
	desc = "Cancel altar placement mode."
	button_icon_state = "cult_comms"
	check_flags = NONE

/datum/action/innate/clockwork/eminence/place_altar/cancel/IsAvailable(feedback = FALSE)
	return istype(owner, /mob/living/basic/clockwork_eminence)

/datum/action/innate/clockwork/eminence/place_altar/cancel/Activate()
	var/mob/living/basic/clockwork_eminence/eminence = owner
	if(!istype(eminence))
		return
	// Find the place_altar action and cancel its click mode
	for(var/datum/action/innate/clockwork/eminence/place_altar/place_action as anything in eminence.actions)
		if(!istype(place_action, /datum/action/innate/clockwork/eminence/place_altar))
			continue
		if(istype(place_action, /datum/action/innate/clockwork/eminence/place_altar/rotate))
			continue
		if(istype(place_action, /datum/action/innate/clockwork/eminence/place_altar/cancel))
			continue
		place_action.unset_ranged_ability(eminence, place_action.disable_text)
		place_action.build_all_button_icons(UPDATE_BUTTON_STATUS)
		break
