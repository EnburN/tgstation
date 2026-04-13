// ---- Integration Cog ----
/obj/item/clockwork_integration_cog
	name = "integration cog"
	desc = "A small bronze cog that can be inserted into an APC to siphon power."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state = "ereader"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/power/apc/host_apc

/obj/item/clockwork_integration_cog/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clockwork_integration_cog/Destroy()
	host_apc = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clockwork_integration_cog/process(seconds_per_tick)
	if(!host_apc)
		return
	if(!host_apc.cell || host_apc.cell.charge <= 0)
		return
	var/drained = min(host_apc.cell.charge, INTEGRATION_COG_DRAIN_RATE * seconds_per_tick)
	host_apc.cell.use(drained)
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		team.adjust_power(drained)
		break

// ---- Wraith Spectacles ----
/obj/item/clothing/glasses/clockwork
	name = "clockwork glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "yourshades"

/obj/item/clothing/glasses/clockwork/wraith
	name = "wraith spectacles"
	desc = "Bronze-rimmed glasses that allow the wearer to see through walls."
	vision_flags = SEE_TURFS | SEE_MOBS | SEE_OBJS

/obj/item/clothing/glasses/clockwork/wraith/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_EYES)
		START_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/clockwork/wraith/dropped(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/glasses/clockwork/wraith/process(seconds_per_tick)
	if(!isliving(loc))
		STOP_PROCESSING(SSobj, src)
		return
	for(var/datum/team/clockwork/team in GLOB.antagonist_teams)
		if(team.herald_activated)
			return
		break
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		var/obj/item/organ/eyes/eyes = human_wearer.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes)
			eyes.apply_organ_damage(0.5 * seconds_per_tick)

// ---- Judicial Visor ----
/obj/item/clothing/glasses/clockwork/judicial
	name = "judicial visor"
	desc = "A bronze visor that allows the wearer to place judicial markers."
	COOLDOWN_DECLARE(judicial_cooldown)

// ---- Replica Fabricator ----
/obj/item/replica_fabricator
	name = "replica fabricator"
	desc = "A clockwork omnitool that converts structures, consumes materials for power, and produces brass sheets."
	icon = 'icons/obj/antags/cult/items.dmi'
	icon_state = "ereader"
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'

/obj/item/replica_fabricator/attack_self(mob/user)
	if(!IS_CLOCKWORK(user))
		to_chat(user, span_warning("The device is incomprehensible to you."))
		return
	var/datum/antagonist/clockwork/clock_datum = GET_CLOCKWORK(user)
	var/datum/team/clockwork/team = clock_datum?.clockwork_team
	if(!team)
		return
	var/cost = FABRICATOR_BRASS_COST
	if(team.herald_activated)
		cost *= HERALD_POWER_COST_MULT
	if(team.power < cost)
		to_chat(user, span_warning("Not enough power! Need [cost]W."))
		return
	team.adjust_power(-cost)
	new /obj/item/stack/sheet/bronze(user.loc, 5)
	to_chat(user, span_brass("You fabricate 5 brass sheets."))

// ---- Clockwork Manacles ----
/obj/item/restraints/handcuffs/clockwork
	name = "clockwork manacles"
	desc = "Restraints of interlocking bronze gears. They fall apart once removed."
	icon_state = "cablecuff"
	breakouttime = 30 SECONDS
	var/disposable = TRUE

/obj/item/restraints/handcuffs/clockwork/on_uncuffed(datum/source, mob/living/wearer)
	. = ..()
	if(disposable)
		qdel(src)

// ---- Ratvarian Spear ----
/obj/item/clockwork_spear
	name = "ratvarian spear"
	desc = "A spear forged from otherworldly brass."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "spear"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	force = 15
	armour_penetration = 10
	throwforce = 25
	throw_speed = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("stabs", "pokes", "jabs", "skewers")
	attack_verb_simple = list("stab", "poke", "jab", "skewer")
	sharpness = SHARP_POINTY

/obj/item/clockwork_spear/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isliving(target))
		return
	var/mob/living/victim = target
	victim.adjust_fire_loss(5)
	GLOB.clockwork_vitality += 5

// ---- Ratvarian Armor ----
/obj/item/clothing/suit/armor/clockwork
	name = "ratvarian armor"
	desc = "Heavy brass armor offering excellent physical protection but vulnerable to lasers."
	icon = 'icons/obj/clothing/suits/chaplain.dmi'
	icon_state = "clockwork_cuirass"
	worn_icon_state = "clockwork_cuirass"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor_type = /datum/armor/clockwork_armor
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 8 SECONDS
	equip_delay_self = 4 SECONDS

/datum/armor/clockwork_armor
	melee = 50
	bullet = 40
	laser = 10
	energy = 20
	bomb = 30
	fire = 80
	acid = 50

/obj/item/clothing/head/helmet/clockwork
	name = "ratvarian helmet"
	desc = "A heavy brass helmet decorated with clockwork motifs."
	icon = 'icons/obj/clothing/head/chaplain.dmi'
	icon_state = "clockwork_helmet"
	worn_icon_state = "clockwork_helmet"
	armor_type = /datum/armor/clockwork_armor
