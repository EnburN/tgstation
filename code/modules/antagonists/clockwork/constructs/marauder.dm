/obj/structure/clockwork_marauder_shell
	name = "clockwork marauder shell"
	desc = "An empty clockwork construct shell."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	density = TRUE
	anchored = TRUE

/obj/structure/clockwork_marauder_shell/proc/poll_for_ghost()
	var/mob/dead/observer/ghost = SSpolling.poll_ghost_candidates("Do you want to become a Clockwork Marauder?", poll_time = 20 SECONDS, role = ROLE_CULTIST, alert_pic = src)
	if(!ghost)
		visible_message(span_warning("[src] fails to attract a spirit and crumbles."))
		qdel(src)
		return
	create_marauder(ghost)

/obj/structure/clockwork_marauder_shell/proc/create_marauder(mob/dead/observer/ghost)
	var/mob/living/simple_animal/hostile/clockwork/marauder/marauder = new(get_turf(src))
	ghost.mind.transfer_to(marauder)
	var/datum/antagonist/clockwork/construct/construct_datum = new()
	marauder.mind.add_antag_datum(construct_datum)
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		team.add_member(marauder.mind)
		break
	to_chat(marauder, span_bold("You are a Clockwork Marauder! Defend your fellow servants!"))
	qdel(src)

/mob/living/simple_animal/hostile/clockwork/marauder
	name = "Clockwork Marauder"
	desc = "A formidable clockwork construct with a shield."
	icon = 'icons/mob/simple/icemoon/icemoon_monsters.dmi'
	icon_state = "clockwork_defender"
	maxHealth = 120
	health = 120
	melee_damage_lower = 15
	melee_damage_upper = 20
	faction = list(FACTION_CLOCKWORK)
	move_to_delay = 3
	robust_searching = TRUE
	stat_attack = CONSCIOUS
	attack_verb_continuous = "strikes"
	attack_verb_simple = "strike"
	attack_sound = 'sound/effects/magic/clockwork/anima_fragment_attack.ogg'
	death_sound = 'sound/effects/magic/clockwork/anima_fragment_death.ogg'
	var/shield_health = 3
	var/max_shield_health = 3
	COOLDOWN_DECLARE(shield_regen_cooldown)

/mob/living/simple_animal/hostile/clockwork/marauder/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/mob/living/simple_animal/hostile/clockwork/marauder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/living/simple_animal/hostile/clockwork/marauder/process(seconds_per_tick)
	if(shield_health < max_shield_health && COOLDOWN_FINISHED(src, shield_regen_cooldown))
		shield_health = min(shield_health + 1, max_shield_health)
		COOLDOWN_START(src, shield_regen_cooldown, MARAUDER_SHIELD_REGEN_TIME)

/mob/living/simple_animal/hostile/clockwork/marauder/bullet_act(obj/projectile/projectile)
	if(shield_health > 0)
		shield_health--
		visible_message(span_warning("[src]'s shield deflects the projectile!"))
		playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 30, TRUE)
		return BULLET_ACT_BLOCK
	return ..()
