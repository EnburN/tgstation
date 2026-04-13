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
	to_chat(scarab, span_bold("You are a Cogscarab! Build defenses on Reebe. You cannot leave."))
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
	var/reebe_locked = TRUE

/mob/living/simple_animal/hostile/clockwork/cogscarab/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(reebe_locked)
		var/turf/destination = get_turf(newloc)
		if(destination)
			var/area/dest_area = get_area(destination)
			if(!istype(dest_area, /area/reebe))
				to_chat(src, span_warning("You cannot leave the City of Cogs!"))
				return FALSE
	return ..()
