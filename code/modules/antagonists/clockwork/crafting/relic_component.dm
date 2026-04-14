/// Component attached to items flagged as relics at round start.
/// Tracks identification state and provides the orange glow visual once identified.
/datum/component/clockwork_relic
	/// Whether a servant has identified this relic yet
	var/identified = FALSE
	/// Reference to the owning clockwork team
	var/datum/team/clockwork/clockwork_team

/datum/component/clockwork_relic/Initialize(datum/team/clockwork/team_ref)
	. = ..()
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	clockwork_team = team_ref

/datum/component/clockwork_relic/Destroy(force)
	clockwork_team = null
	return ..()

/// Marks this relic as identified, applies visual cues, and notifies the identifier.
/datum/component/clockwork_relic/proc/identify(mob/living/identifier)
	if(identified)
		return
	identified = TRUE
	var/obj/item/relic_item = parent
	relic_item.add_atom_colour("#FF8C00", TEMPORARY_COLOUR_PRIORITY)
	relic_item.add_filter("relic_glow", 2, list("type" = "outline", "color" = "#FF8C00", "size" = 2))
	to_chat(identifier, span_brass("You have identified [relic_item] as a fragment of Ratvar's essence! Return it to the altar."))
	if(clockwork_team)
		clockwork_team.announce_to_servants(span_brass("[identifier] has identified a relic: [relic_item.name]!"))
