/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "A floor made of interlocking gears and cogs. It hums with latent energy."
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"
	floor_tile = null
	baseturfs = /turf/open/floor/plating
	tiled_dirt = FALSE

/turf/open/floor/clockwork/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/turf/open/floor/clockwork/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/floor/clockwork/process(seconds_per_tick)
	for(var/mob/living/servant in src)
		if(!HAS_TRAIT(servant, TRAIT_HEALS_ON_CLOCKWORK_FLOOR))
			continue
		if(servant.stat == DEAD)
			continue
		servant.adjustToxLoss(-CLOCKWORK_FLOOR_HEAL_RATE * seconds_per_tick, FALSE)

/// Indestructible variant for Reebe's pre-built floors
/turf/open/floor/clockwork/reebe
	name = "ancient clockwork floor"
	desc = "An ancient floor of interlocking gears. It seems indestructible."
	resistance_flags = INDESTRUCTIBLE

/turf/open/floor/clockwork/reebe/attackby(obj/item/attacking_item, mob/user, params)
	return

/turf/open/floor/clockwork/reebe/try_decon(obj/item/attacking_item, mob/user, params)
	return FALSE
