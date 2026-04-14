// ---- Cogscarab Shell (Task 5.5 helper structure) ----

/obj/structure/clockwork_cogscarab_shell
	name = "cogscarab shell"
	desc = "A tiny clockwork drone shell. It seems to be searching for a spirit to inhabit it."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	density = FALSE
	anchored = TRUE

/obj/structure/clockwork_cogscarab_shell/proc/poll_for_occupant()
	var/list/signups = SSpolling.poll_ghost_candidates(
		"Do you want to become a Clockwork Cogscarab?",
		role = ROLE_CULTIST,
		poll_time = 20 SECONDS,
		alert_pic = src,
		role_name_text = "cogscarab",
	)
	var/mob/dead/observer/ghost = length(signups) ? pick(signups) : null
	if(!ghost)
		if(!QDELETED(src))
			visible_message(span_warning("[src] fails to attract a spirit and crumbles."))
			qdel(src)
		return
	if(QDELETED(src))
		return
	var/mob/living/simple_animal/hostile/clockwork/cogscarab/scarab = new(get_turf(src))
	ghost.mind.transfer_to(scarab)
	var/datum/antagonist/clockwork/construct/construct_datum = new()
	scarab.mind.add_antag_datum(construct_datum)
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		team.add_member(scarab.mind)
		break
	to_chat(scarab, span_bold("You are a Cogscarab! Crawl through vents, collect clockwork parts, and deposit them at the Altar of Reforging."))
	qdel(src)

// ---- Cogscarab Mob ----

/mob/living/simple_animal/hostile/clockwork/cogscarab
	name = "Cogscarab"
	desc = "A tiny clockwork construction drone."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "clockwork_defender"
	maxHealth = 50
	health = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	faction = list(FACTION_CLOCKWORK)
	move_to_delay = 5
	stat_attack = CONSCIOUS
	attack_verb_continuous = "pinches"
	attack_verb_simple = "pinch"
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	/// Whether the defense buff is currently active
	var/defense_buffed = FALSE

/mob/living/simple_animal/hostile/clockwork/cogscarab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, INNATE_TRAIT)
	var/datum/action/innate/cogscarab_dim/dim_action = new(src)
	dim_action.Grant(src)

// ---- Dim Gears Stealth Action (Task 5.2) ----

/datum/action/innate/cogscarab_dim
	name = "Dim Gears"
	desc = "Dim your clockwork gears to become semi-transparent. Taking damage or attacking ends the effect."
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cult_comms"
	background_icon_state = "bg_demon"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	/// World.time when the ability can be used again
	var/cooldown_ends = 0
	/// Addtimer handle for natural expiry
	var/timer_handle

/datum/action/innate/cogscarab_dim/IsAvailable(feedback = FALSE)
	if(world.time < cooldown_ends)
		if(feedback)
			to_chat(owner, span_warning("Dim Gears is still recharging."))
		return FALSE
	return ..()

/datum/action/innate/cogscarab_dim/Activate()
	if(!IsAvailable(feedback = TRUE))
		return
	cooldown_ends = world.time + COGSCARAB_DIM_GEARS_COOLDOWN
	owner.alpha = 60
	to_chat(owner, span_brass("Your gears dim. You are difficult to spot."))
	RegisterSignal(owner, COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(owner, COMSIG_LIVING_ADJUST_BURN_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	timer_handle = addtimer(CALLBACK(src, PROC_REF(end_stealth)), COGSCARAB_DIM_GEARS_DURATION, TIMER_STOPPABLE)

/datum/action/innate/cogscarab_dim/proc/end_stealth()
	if(!owner || QDELETED(owner))
		return
	owner.alpha = 255
	to_chat(owner, span_warning("Your gears brighten again."))
	UnregisterSignal(owner, list(COMSIG_LIVING_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_ADJUST_BURN_DAMAGE, COMSIG_ATOM_WAS_ATTACKED))
	if(timer_handle)
		deltimer(timer_handle)
		timer_handle = null

/datum/action/innate/cogscarab_dim/proc/on_damage_taken(datum/source, damage_type, amount, forced)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	INVOKE_ASYNC(src, PROC_REF(end_stealth))

/datum/action/innate/cogscarab_dim/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(end_stealth))

// ---- Defense Buff Procs (Task 5.4) ----

/mob/living/simple_animal/hostile/clockwork/cogscarab/proc/apply_defense_buff()
	if(defense_buffed)
		return
	defense_buffed = TRUE
	ADD_TRAIT(src, TRAIT_COGSCARAB_DEFENDING, INNATE_TRAIT)
	melee_damage_lower += 3
	melee_damage_upper += 3
	maxHealth += 25
	health = min(health + 25, maxHealth)
	to_chat(src, span_brass("The altar's power flows through you! You feel stronger."))

/mob/living/simple_animal/hostile/clockwork/cogscarab/proc/clear_defense_buff()
	if(!defense_buffed)
		return
	defense_buffed = FALSE
	REMOVE_TRAIT(src, TRAIT_COGSCARAB_DEFENDING, INNATE_TRAIT)
	melee_damage_lower = max(melee_damage_lower - 3, 1)
	melee_damage_upper = max(melee_damage_upper - 3, 1)
	maxHealth -= 25
	health = min(health, maxHealth)
