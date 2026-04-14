/// The Vivisection Slab: servants use this to extract an Essence Cog from a mindshielded crew member.
/obj/structure/clockwork_vivisection_slab
	name = "Vivisection Slab"
	desc = "A gleaming brass slab etched with intricate gear-work. Its purpose is unsettling."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "fallen_armor"
	density = TRUE
	anchored = TRUE
	max_integrity = VIVISECTION_SLAB_HP
	can_buckle = TRUE
	max_buckled_mobs = 1
	/// Whether a surgical excision is currently in progress
	var/surgery_in_progress = FALSE
	/// Reference to the owning clockwork team
	var/datum/team/clockwork/clockwork_team

/obj/structure/clockwork_vivisection_slab/Initialize(mapload, datum/team/clockwork/team_ref)
	. = ..()
	src.clockwork_team = team_ref

/obj/structure/clockwork_vivisection_slab/Destroy()
	clockwork_team = null
	return ..()

/obj/structure/clockwork_vivisection_slab/attack_hand(mob/living/user, list/modifiers)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The slab's mechanisms are incomprehensible to you."))
		return
	if(surgery_in_progress)
		to_chat(user, span_warning("An excision is already in progress."))
		return
	var/mob/living/target = length(buckled_mobs) ? buckled_mobs[1] : null
	if(!target)
		to_chat(user, span_warning("Buckle a target to the slab first."))
		return
	begin_excision(user)

/// Validates and begins the surgical excision process.
/obj/structure/clockwork_vivisection_slab/proc/begin_excision(mob/living/primary_servant)
	var/mob/living/target = length(buckled_mobs) ? buckled_mobs[1] : null
	if(!validate_target(target, primary_servant))
		return
	if(!has_assistant(primary_servant))
		to_chat(primary_servant, span_warning("You need another servant nearby or the Herald's Beacon active to perform an excision."))
		return
	surgery_in_progress = TRUE
	to_chat(primary_servant, span_brass("You begin the excision ritual. This will take [ESSENCE_EXCISION_TIME / 10] seconds."))
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_brass("An excision ritual has begun at the Vivisection Slab!"))
	if(!do_after(primary_servant, ESSENCE_EXCISION_TIME, target = src, extra_checks = CALLBACK(src, PROC_REF(excision_continue_check), primary_servant)))
		surgery_in_progress = FALSE
		to_chat(primary_servant, span_warning("The excision was interrupted."))
		return
	complete_excision(target)

/// Returns TRUE if the excision can continue — servant is still here and target still buckled.
/obj/structure/clockwork_vivisection_slab/proc/excision_continue_check(mob/living/primary_servant)
	if(QDELETED(src))
		return FALSE
	if(!IS_CLOCKWORK(primary_servant))
		return FALSE
	var/mob/living/buckled = length(buckled_mobs) ? buckled_mobs[1] : null
	if(!buckled || buckled.stat == DEAD)
		return FALSE
	return TRUE

/// Returns TRUE if a second clockwork servant is adjacent, or the Herald's Beacon is active.
/obj/structure/clockwork_vivisection_slab/proc/has_assistant(mob/living/primary)
	if(clockwork_team?.herald_activated)
		return TRUE
	for(var/mob/living/nearby in range(1, src))
		if(nearby == primary)
			continue
		if(IS_CLOCKWORK(nearby) && nearby.stat != DEAD)
			return TRUE
	return FALSE

/// Returns TRUE if the target is a valid excision subject.
/obj/structure/clockwork_vivisection_slab/proc/validate_target(mob/living/target, mob/living/servant)
	if(!target)
		to_chat(servant, span_warning("There is no target on the slab."))
		return FALSE
	if(target.stat == DEAD)
		to_chat(servant, span_warning("The target is already dead — there is nothing to extract."))
		return FALSE
	if(!ishuman(target))
		to_chat(servant, span_warning("The excision ritual requires a human subject."))
		return FALSE
	if(!HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(servant, span_warning("The target must bear a mindshield — their soul holds no essence."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_BLESSED_CORPSE))
		to_chat(servant, span_warning("This soul is blessed — the ritual cannot proceed."))
		return FALSE
	return TRUE

/// Spawns an Essence Cog, gibs the target, and announces the result.
/obj/structure/clockwork_vivisection_slab/proc/complete_excision(mob/living/target)
	surgery_in_progress = FALSE
	if(!target || QDELETED(target))
		return
	var/turf/spawn_turf = get_turf(src)
	new /obj/item/clockwork/essence_cog(spawn_turf)
	playsound(src, 'sound/effects/magic/clockwork/invoke_general.ogg', 75, TRUE)
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_brass("<b>The excision is complete! An Essence Cog has been extracted.</b>"))
	target.gib()
