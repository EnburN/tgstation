// ---- Ocular Warden ----
/datum/clockwork_scripture/ocular_warden
	name = "Ocular Warden"
	desc = "Creates a fragile defensive turret that burns non-servants within 3 tiles."
	tier = SCRIPTURE_SCRIPT
	power_cost = 250
	invocation_time = 10 SECONDS
	whispered_invocation = "Ward-en vigil!"

/datum/clockwork_scripture/ocular_warden/can_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/structure/destructible/clockwork/ocular_warden/existing in range(WARDEN_MIN_SPACING, user))
		to_chat(user, span_warning("Too close to another Ocular Warden!"))
		return FALSE
	return TRUE

/datum/clockwork_scripture/ocular_warden/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/structure/destructible/clockwork/ocular_warden(get_turf(user))
	to_chat(user, span_brass("An Ocular Warden materializes, scanning for intruders."))
	return TRUE

// ---- Vitality Matrix ----
/datum/clockwork_scripture/vitality_matrix
	name = "Vitality Matrix"
	desc = "Creates a sigil that drains non-servants for vitality and heals servants. Can revive dead servants."
	tier = SCRIPTURE_SCRIPT
	power_cost = 1000
	invocation_time = 6 SECONDS
	whispered_invocation = "Vital-ity drain!"

/datum/clockwork_scripture/vitality_matrix/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/effect/clockwork_sigil/vitality_matrix(get_turf(user))
	to_chat(user, span_brass("A Vitality Matrix forms beneath you."))
	return TRUE

// ---- Replica Fabricator ----
/datum/clockwork_scripture/replica_fabricator
	name = "Replica Fabricator"
	desc = "Creates a replica fabricator — an omnitool for building, converting, and producing brass sheets."
	tier = SCRIPTURE_SCRIPT
	power_cost = 250
	invocation_time = 2 SECONDS
	whispered_invocation = "Fab-ric-ate!"

/datum/clockwork_scripture/replica_fabricator/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/obj/item/replica_fabricator/fab = new(user.loc)
	if(!user.put_in_hands(fab))
		to_chat(user, span_notice("A replica fabricator materializes at your feet."))
	else
		to_chat(user, span_brass("A replica fabricator materializes in your hand."))
	return TRUE

// ---- Judicial Visor ----
/datum/clockwork_scripture/judicial_visor
	name = "Judicial Visor"
	desc = "Creates a visor that lets you place 3x3 judicial markers — stunning explosions at range. 30-second cooldown."
	tier = SCRIPTURE_SCRIPT
	power_cost = 400
	invocation_time = 1 SECONDS
	whispered_invocation = "Jud-ice sight!"

/datum/clockwork_scripture/judicial_visor/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/obj/item/clothing/glasses/clockwork/judicial/visor = new(user.loc)
	if(!user.put_in_hands(visor))
		to_chat(user, span_notice("A judicial visor materializes at your feet."))
	else
		to_chat(user, span_brass("A judicial visor materializes in your hand."))
	return TRUE

// ---- Clockwork Armaments ----
/datum/clockwork_scripture/clockwork_armaments
	name = "Clockwork Armaments"
	desc = "Links Ratvarian armor and spear to you as summonable actions."
	tier = SCRIPTURE_SCRIPT
	power_cost = 250
	invocation_time = 2 SECONDS
	whispered_invocation = "Arm-ament link!"

/datum/clockwork_scripture/clockwork_armaments/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/datum/action/innate/clockwork/summon_armor/armor_action = new()
	armor_action.Grant(user)
	var/datum/action/innate/clockwork/summon_spear/spear_action = new()
	spear_action.Grant(user)
	to_chat(user, span_brass("Ratvarian armaments are now linked to you."))
	return TRUE

/// Action to summon clockwork armor
/datum/action/innate/clockwork/summon_armor
	name = "Summon Ratvarian Armor"
	desc = "Summon your linked Ratvarian armor set."
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_CONSCIOUS
	COOLDOWN_DECLARE(armor_cooldown)

/datum/action/innate/clockwork/summon_armor/IsAvailable(feedback = FALSE)
	if(!COOLDOWN_FINISHED(src, armor_cooldown))
		return FALSE
	return ..()

/datum/action/innate/clockwork/summon_armor/Activate()
	var/mob/living/carbon/human/user = owner
	if(!istype(user))
		return
	var/obj/item/clothing/suit/armor/clockwork/suit = new(user.loc)
	var/obj/item/clothing/head/helmet/clockwork/helmet = new(user.loc)
	user.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE)
	user.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD, disable_warning = TRUE)
	to_chat(user, span_brass("Ratvarian armor materializes around you!"))
	COOLDOWN_START(src, armor_cooldown, 2 MINUTES)

/// Action to summon clockwork spear
/datum/action/innate/clockwork/summon_spear
	name = "Summon Ratvarian Spear"
	desc = "Summon or dismiss your linked Ratvarian spear."
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_CONSCIOUS
	COOLDOWN_DECLARE(spear_cooldown)
	var/obj/item/clockwork_spear/linked_spear

/datum/action/innate/clockwork/summon_spear/IsAvailable(feedback = FALSE)
	if(!COOLDOWN_FINISHED(src, spear_cooldown))
		return FALSE
	return ..()

/datum/action/innate/clockwork/summon_spear/Activate()
	var/mob/living/user = owner
	if(linked_spear && !QDELETED(linked_spear))
		qdel(linked_spear)
		linked_spear = null
		to_chat(user, span_brass("Your spear dematerializes."))
		return
	linked_spear = new(user.loc)
	if(!user.put_in_hands(linked_spear))
		to_chat(user, span_notice("A Ratvarian spear materializes at your feet."))
	else
		to_chat(user, span_brass("A Ratvarian spear materializes in your hand."))

// ---- Spatial Gateway ----
/datum/clockwork_scripture/spatial_gateway
	name = "Spatial Gateway"
	desc = "Creates a one-way gateway to a target servant or obelisk."
	tier = SCRIPTURE_SCRIPT
	power_cost = 400
	invocation_time = 8 SECONDS
	whispered_invocation = "Spat-ial bridge!"

/datum/clockwork_scripture/spatial_gateway/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	var/datum/team/clockwork/team = clock_datum.clockwork_team
	var/list/targets = list()
	for(var/datum/mind/servant_mind as anything in team.members)
		if(servant_mind.current && servant_mind.current != user && servant_mind.current.stat != DEAD)
			targets["[servant_mind.current.name]"] = servant_mind.current
	for(var/obj/structure/destructible/clockwork/obelisk/obelisk in GLOB.clockwork_structures)
		targets["Obelisk at [get_area(obelisk)]"] = obelisk
	if(!length(targets))
		to_chat(user, span_warning("No valid targets for a spatial gateway."))
		return FALSE
	var/chosen = tgui_input_list(user, "Choose a gateway destination", "Spatial Gateway", targets)
	if(!chosen || !targets[chosen])
		return FALSE
	var/atom/target = targets[chosen]
	var/turf/target_turf = get_turf(target)
	// TODO: spatial gateway needs rework for station-only gameplay
	do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_CULT)
	to_chat(user, span_brass("A spatial gateway transports you."))
	return TRUE

GLOBAL_LIST_EMPTY(clockwork_structures)

// ---- Vivisection Slab ----
/datum/clockwork_scripture/vivisection_slab
	name = "Vivisection Slab"
	desc = "Anchor a Vivisection Slab for surgical excision of mindshielded subjects."
	tier = SCRIPTURE_SCRIPT
	power_cost = 1500
	invocation_time = 8 SECONDS
	whispered_invocation = "Viv-i-sect soul!"

/datum/clockwork_scripture/vivisection_slab/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/turf/target = get_turf(user)
	if(!is_valid_clockwork_placement(target))
		to_chat(user, span_warning("Cannot anchor a Slab here."))
		return FALSE
	var/datum/antagonist/clockwork/cult_datum = GET_CLOCKWORK(user)
	new /obj/structure/clockwork_vivisection_slab(target, cult_datum?.clockwork_team)
	to_chat(user, span_brass("A Vivisection Slab materializes before you."))
	return TRUE
