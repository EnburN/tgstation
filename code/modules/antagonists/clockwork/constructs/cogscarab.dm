/obj/structure/clockwork_cogscarab_shell
	name = "cogscarab shell"
	desc = "A small clockwork drone shell. Any ghost can activate it."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "pylon"
	density = FALSE
	anchored = TRUE

/obj/structure/clockwork_cogscarab_shell/attack_ghost(mob/dead/observer/ghost)
	if(!ghost?.client)
		return
	var/mob/living/simple_animal/hostile/clockwork/cogscarab/scarab = new(get_turf(src))
	ghost.mind.transfer_to(scarab)
	var/datum/antagonist/clockwork/construct/construct_datum = new()
	scarab.mind.add_antag_datum(construct_datum)
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		team.add_member(scarab.mind)
		break
	to_chat(scarab, span_bold("You are a Cogscarab! Build clockwork defenses and assist the cult."))
	qdel(src)

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
