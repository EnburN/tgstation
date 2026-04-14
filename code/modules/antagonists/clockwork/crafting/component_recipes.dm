// ---- Base Recipe Datum ----

/// Base class for all Forge Workbench crafting recipes.
/datum/clockwork_recipe
	/// Display name for this recipe
	var/name = "Unknown Recipe"
	/// Short description shown in the workbench UI
	var/desc = "An unspecified recipe."
	/// Shared power cost in watts
	var/power_cost = 0
	/// Type path of the item produced when the recipe completes
	var/output_path = /obj/item/clockwork/component
	/// Assoc list of input type → required amount/volume
	var/list/inputs

/datum/clockwork_recipe/New()
	inputs = list()

/// Returns TRUE if the given reserves list contains sufficient inputs.
/datum/clockwork_recipe/proc/has_inputs(list/reserves)
	for(var/input_type in inputs)
		var/required = inputs[input_type]
		if(isnull(reserves[input_type]) || reserves[input_type] < required)
			return FALSE
	return TRUE

/// Deducts input costs from the reserves list.
/datum/clockwork_recipe/proc/consume_inputs(list/reserves)
	for(var/input_type in inputs)
		reserves[input_type] -= inputs[input_type]
		if(reserves[input_type] <= 0)
			reserves -= input_type

/// Returns a human-readable summary of required inputs.
/datum/clockwork_recipe/proc/input_summary()
	var/list/parts = list()
	for(var/input_type in inputs)
		var/required = inputs[input_type]
		parts += "[input_type] x[required]"
	return parts.Join(", ")

// ---- Recipe Subtypes ----

/// Rib — a curved mechanical strut. Requires plasma reagent, bronze tiles, and a micro-laser.
/datum/clockwork_recipe/rib
	name = "Ratvar's Rib"
	desc = "A curved skeletal strut of living brass, suffused with plasma energy."
	power_cost = 2000
	output_path = /obj/item/clockwork/component

/datum/clockwork_recipe/rib/New()
	. = ..()
	inputs[/datum/reagent/toxin/plasma] = 20
	inputs[/obj/item/stack/tile/bronze] = 5
	inputs[/obj/item/stock_parts/micro_laser] = 1

/// Vertebra — a joint segment. Requires uranium sheets, a power cell, and a scanning module.
/datum/clockwork_recipe/vertebra
	name = "Ratvar's Vertebra"
	desc = "A segmented joint of uranium-laced alloy, pulsing with latent energy."
	power_cost = 2000
	output_path = /obj/item/clockwork/component

/datum/clockwork_recipe/vertebra/New()
	. = ..()
	inputs[/obj/item/stack/sheet/mineral/uranium] = 2
	inputs[/obj/item/stock_parts/power_store/cell] = 1
	inputs[/obj/item/stock_parts/scanning_module] = 1

/// Clavicle — a precision linking bone. Requires bluespace crystals, bronze sheets, and a scanning module.
/datum/clockwork_recipe/clavicle
	name = "Ratvar's Clavicle"
	desc = "A precision linking bone of bluespace-infused brass, bridging dimensions."
	power_cost = 3000
	output_path = /obj/item/clockwork/component

/datum/clockwork_recipe/clavicle/New()
	. = ..()
	inputs[/obj/item/stack/ore/bluespace_crystal] = 2
	inputs[/obj/item/stack/sheet/bronze] = 3
	inputs[/obj/item/stock_parts/scanning_module] = 1
