// ---- Clockwork Part Items ----

/// Base type for all depositable clockwork parts.
/obj/item/clockwork
	name = "clockwork part"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "replicant_alloy"
	w_class = WEIGHT_CLASS_SMALL

/// A relic shard — recovered from flagged items around the station.
/obj/item/clockwork/relic
	name = "Ratvar's Cog"
	icon_state = "guvax_capacitor"

/// A crafted mechanical component produced at the Forge Workbench.
/obj/item/clockwork/component
	name = "Ratvar's Bone"
	icon_state = "replicant_alloy"

/// An essence cog excised from a living victim at the Vivisection Slab.
/obj/item/clockwork/essence_cog
	name = "Essence Cog"
	icon_state = "vanguard_cogwheel"
