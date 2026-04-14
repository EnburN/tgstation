/// Eminence: a revenant-derived ghost mob that leads the cult.
/// Full implementation (abilities, formation, placement) lives in Phase 2.
/mob/living/basic/clockwork_eminence
	name = "Eminence"
	desc = "A spectral clockwork presence."
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "clockwork_marauder"
	maxHealth = 9999
	health = 9999
	density = FALSE
	anchored = FALSE
	movement_type = FLYING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSGLASS | PASSMOB
	faction = list(FACTION_CLOCKWORK)
	gender = NEUTER

/mob/living/basic/clockwork_eminence/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NOCRITDAMAGE, TRAIT_NOFIRE, TRAIT_NOBREATH), INNATE_TRAIT)
