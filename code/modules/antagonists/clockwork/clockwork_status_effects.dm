/datum/status_effect/clockwork
	abstract_type = /datum/status_effect/clockwork

/datum/status_effect/clockwork/vanguard
	id = "clockwork_vanguard"
	duration = VANGUARD_DURATION
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/clockwork/vanguard
	var/stuns_absorbed = 0

/datum/status_effect/clockwork/vanguard/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_STATUS_STUN, PROC_REF(on_stun))
	RegisterSignal(owner, COMSIG_LIVING_STATUS_PARALYZE, PROC_REF(on_stun))
	RegisterSignal(owner, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_stun))

/datum/status_effect/clockwork/vanguard/on_remove()
	UnregisterSignal(owner, list(COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_KNOCKDOWN))
	if(stuns_absorbed > VANGUARD_OVERLOAD_THRESHOLD)
		to_chat(owner, span_userdanger("Your vanguard overloads!"))
		owner.Unconscious(stuns_absorbed * 2)
	else if(stuns_absorbed > 0)
		var/reapply = stuns_absorbed * VANGUARD_REAPPLY_PERCENT
		to_chat(owner, span_warning("Your vanguard expires."))
		owner.Paralyze(reapply)
	return ..()

/datum/status_effect/clockwork/vanguard/proc/on_stun(datum/source, amount)
	SIGNAL_HANDLER
	stuns_absorbed += amount
	return COMPONENT_NO_STUN

/atom/movable/screen/alert/status_effect/clockwork/vanguard
	name = "Vanguard"
	desc = "Absorbing stuns. A fraction will be applied when this expires."
