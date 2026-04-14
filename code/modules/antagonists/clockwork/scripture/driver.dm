// ---- Abscond ----
/datum/clockwork_scripture/abscond
	name = "Abscond"
	desc = "Teleports you to the City of Cogs. Costs extra power if pulling a mob."
	tier = SCRIPTURE_DRIVER
	power_cost = 5
	invocation_time = 5 SECONDS
	whispered_invocation = "Gev-rath var!"

/datum/clockwork_scripture/abscond/can_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	. = ..()
	if(!.)
		return FALSE
	if(user.pulling && isliving(user.pulling))
		var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
		var/extra_cost = 95
		if(clock_datum.clockwork_team.herald_activated)
			extra_cost *= HERALD_POWER_COST_MULT
		if(clock_datum.clockwork_team.power < (power_cost + extra_cost))
			to_chat(user, span_warning("Not enough power to bring [user.pulling] with you! Need [power_cost + 95]W."))
			return FALSE
	return TRUE

/datum/clockwork_scripture/abscond/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	// Stub — full Abscond redesign happens in Phase 6 (Task 6.3).
	to_chat(user, span_warning("Abscond is not yet available."))
	return FALSE

// ---- Kindle ----
/datum/clockwork_scripture/kindle
	name = "Kindle"
	desc = "Charges your slab with energy. Attack a visible tile to fire a short-range stun projectile."
	tier = SCRIPTURE_DRIVER
	power_cost = 125
	invocation_time = 3 SECONDS
	whispered_invocation = "Kin-dle rathar!"

/datum/clockwork_scripture/kindle/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	slab.charge_type = "kindle"
	slab.charge_uses = 1
	to_chat(user, span_brass("Your slab crackles with energy. Attack a tile to fire a stun projectile."))
	return TRUE

// ---- Sigil of Submission ----
/datum/clockwork_scripture/sigil_of_submission
	name = "Sigil of Submission"
	desc = "Creates a glowing sigil that converts non-servants held on it for 8 seconds while another servant is nearby."
	tier = SCRIPTURE_DRIVER
	power_cost = 125
	invocation_time = 6 SECONDS
	whispered_invocation = "Enth-rall sub-mit!"

/datum/clockwork_scripture/sigil_of_submission/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/effect/clockwork_sigil/submission(get_turf(user))
	to_chat(user, span_brass("A Sigil of Submission forms beneath you."))
	return TRUE

// ---- Hateful Manacles ----
/datum/clockwork_scripture/hateful_manacles
	name = "Hateful Manacles"
	desc = "Charges your slab. Hit a non-servant to handcuff them with clockwork restraints that break on removal."
	tier = SCRIPTURE_DRIVER
	power_cost = 25
	invocation_time = 1.5 SECONDS
	whispered_invocation = "Bind-rath!"

/datum/clockwork_scripture/hateful_manacles/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	slab.charge_type = "manacles"
	slab.charge_uses = 1
	to_chat(user, span_brass("Your slab hums with restraining energy. Hit a non-servant to handcuff them."))
	return TRUE

// ---- Vanguard ----
/datum/clockwork_scripture/vanguard
	name = "Vanguard"
	desc = "Grants 20 seconds of stun absorption. On expiry, 25% of absorbed stuns are applied. Over 30 seconds absorbed causes unconsciousness."
	tier = SCRIPTURE_DRIVER
	power_cost = 25
	invocation_time = 3 SECONDS
	whispered_invocation = "Van-guard rath!"

/datum/clockwork_scripture/vanguard/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	user.apply_status_effect(/datum/status_effect/clockwork/vanguard)
	to_chat(user, span_brass("You feel a protective barrier surround you."))
	return TRUE

// ---- Sentinel's Compromise ----
/datum/clockwork_scripture/sentinels_compromise
	name = "Sentinel's Compromise"
	desc = "Charges your slab. Use on a servant to heal brute/burn/oxy damage, but half is reapplied as toxin. Purges holy water."
	tier = SCRIPTURE_DRIVER
	power_cost = 100
	invocation_time = 3 SECONDS
	whispered_invocation = "Sen-tin-el mend!"

/datum/clockwork_scripture/sentinels_compromise/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	slab.charge_type = "sentinels_compromise"
	slab.charge_uses = 1
	to_chat(user, span_brass("Your slab glows with restorative energy. Use it on a servant to heal them."))
	return TRUE

// ---- Integration Cog ----
/datum/clockwork_scripture/integration_cog
	name = "Integration Cog"
	desc = "Creates a cog that can be inserted into any APC to passively drain its power for the cult."
	tier = SCRIPTURE_DRIVER
	power_cost = 10
	invocation_time = 1 SECONDS
	whispered_invocation = "Cog-int!"

/datum/clockwork_scripture/integration_cog/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/obj/item/clockwork_integration_cog/cog = new(user.loc)
	if(!user.put_in_hands(cog))
		to_chat(user, span_warning("You need a free hand!"))
		qdel(cog)
		return FALSE
	to_chat(user, span_brass("An integration cog materializes in your hand."))
	return TRUE

// ---- Replicant ----
/datum/clockwork_scripture/replicant
	name = "Replicant"
	desc = "Creates a new clockwork slab."
	tier = SCRIPTURE_DRIVER
	power_cost = 25
	invocation_time = 1.5 SECONDS
	whispered_invocation = "Rep-lic-ant!"

/datum/clockwork_scripture/replicant/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/obj/item/clockwork_slab/new_slab = new(user.loc)
	if(!user.put_in_hands(new_slab))
		to_chat(user, span_notice("A new clockwork slab materializes at your feet."))
	else
		to_chat(user, span_brass("A new clockwork slab materializes in your hand."))
	return TRUE

// ---- Wraith Spectacles ----
/datum/clockwork_scripture/wraith_spectacles
	name = "Wraith Spectacles"
	desc = "Creates glasses that grant vision through walls. Slowly damages eyes unless the Herald's Beacon is active."
	tier = SCRIPTURE_DRIVER
	power_cost = 50
	invocation_time = 1 SECONDS
	whispered_invocation = "Spect-rath!"

/datum/clockwork_scripture/wraith_spectacles/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/obj/item/clothing/glasses/clockwork/wraith/spectacles = new(user.loc)
	if(!user.put_in_hands(spectacles))
		to_chat(user, span_notice("Wraith spectacles materialize at your feet."))
	else
		to_chat(user, span_brass("Wraith spectacles materialize in your hand."))
	return TRUE

// ---- Sigil of Transgression ----
/datum/clockwork_scripture/sigil_of_transgression
	name = "Sigil of Transgression"
	desc = "Creates a nearly invisible sigil that stuns and blinds non-servants who cross it. Consumed on trigger."
	tier = SCRIPTURE_DRIVER
	power_cost = 50
	invocation_time = 5 SECONDS
	whispered_invocation = "Trans-gress trap!"

/datum/clockwork_scripture/sigil_of_transgression/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	new /obj/effect/clockwork_sigil/transgression(get_turf(user))
	to_chat(user, span_brass("A Sigil of Transgression shimmers into existence beneath you."))
	return TRUE

// ---- Eminence Spire ----
/datum/clockwork_scripture/eminence_spire
	name = "Eminence Spire"
	desc = "Forge an Eminence Spire to choose your leader."
	tier = SCRIPTURE_DRIVER
	power_cost = 1000
	invocation_time = 10 SECONDS
	whispered_invocation = "Em-in-ence rise!"

/datum/clockwork_scripture/eminence_spire/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/turf/target = get_turf(user)
	if(!is_valid_clockwork_placement(target))
		to_chat(user, span_warning("Cannot anchor a Spire here."))
		return FALSE
	var/datum/antagonist/clockwork/cult_datum = GET_CLOCKWORK(user)
	var/obj/structure/clockwork/eminence_spire/spire = new(target)
	spire.clockwork_team = cult_datum?.clockwork_team
	to_chat(user, span_brass("An Eminence Spire materializes before you."))
	return TRUE

// ---- Forge Workbench ----
/datum/clockwork_scripture/forge_workbench
	name = "Forge Workbench"
	desc = "Anchor a Forge Workbench for crafting Ratvar's components."
	tier = SCRIPTURE_DRIVER
	power_cost = 750
	invocation_time = 6 SECONDS
	whispered_invocation = "Forge-rath craft!"

/datum/clockwork_scripture/forge_workbench/do_invoke(mob/living/user, obj/item/clockwork_slab/slab)
	var/turf/target = get_turf(user)
	if(!is_valid_clockwork_placement(target))
		to_chat(user, span_warning("Cannot anchor a Workbench here."))
		return FALSE
	var/datum/antagonist/clockwork/cult_datum = GET_CLOCKWORK(user)
	var/obj/structure/clockwork_workbench/workbench = new(target)
	workbench.clockwork_team = cult_datum?.clockwork_team
	to_chat(user, span_brass("A Forge Workbench materializes before you."))
	return TRUE
