/obj/structure/destructible/clockwork/ocular_warden
	name = "ocular warden"
	desc = "A clockwork eye turret that burns non-servants in its line of sight."
	icon_state = "pylon"
	max_integrity = 25
	density = FALSE

/obj/structure/destructible/clockwork/ocular_warden/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/ocular_warden/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/destructible/clockwork/ocular_warden/process(seconds_per_tick)
	if(!anchored)
		return
	var/effectiveness = get_effectiveness()
	var/mob/living/target = null
	var/closest_dist = INFINITY
	for(var/mob/living/candidate in range(3, src))
		if(IS_CLOCKWORK(candidate))
			continue
		if(candidate.stat == DEAD)
			continue
		var/dist = get_dist(src, candidate)
		if(dist < closest_dist)
			closest_dist = dist
			target = candidate
	if(!target)
		return
	var/damage = WARDEN_BASE_DAMAGE * seconds_per_tick * effectiveness
	damage *= (1 - closest_dist * WARDEN_DISTANCE_REDUCTION)
	var/obstacles = 0
	var/turf/warden_turf = get_turf(src)
	var/turf/target_turf = get_turf(target)
	for(var/turf/between in get_line(warden_turf, target_turf))
		if(between == warden_turf || between == target_turf)
			continue
		if(between.density)
			obstacles++
			continue
		for(var/obj/obstacle in between)
			if(obstacle.density)
				obstacles++
				break
	damage *= (1 - obstacles * WARDEN_OBSTACLE_REDUCTION)
	damage = max(0, damage)
	if(damage > 0)
		target.adjustFireLoss(damage)
