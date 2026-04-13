/datum/objective/clockwork
	name = "clockwork objective"

/datum/objective/clockwork/defend_ark
	name = "Defend the Ark"
	explanation_text = "Defend the Ark of the Clockwork Justiciar until it fully activates and summons Ratvar."
	/// Whether the Ark was destroyed
	var/ark_destroyed = FALSE
	/// Whether the Ark completed activation
	var/ark_completed = FALSE

/datum/objective/clockwork/defend_ark/check_completion()
	if(ark_completed)
		return TRUE
	return FALSE

/// Called by the Ark when it is destroyed
/datum/objective/clockwork/defend_ark/proc/on_ark_destroyed()
	ark_destroyed = TRUE

/// Called by the Ark when it completes activation
/datum/objective/clockwork/defend_ark/proc/on_ark_completed()
	ark_completed = TRUE
