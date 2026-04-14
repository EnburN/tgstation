/datum/objective/clockwork
	name = "clockwork_base"
	team_explanation_text = "Serve Ratvar, the Clockwork Justiciar."
	martyr_compatible = TRUE

/datum/objective/clockwork/summon_ratvar
	name = "summon_ratvar"
	explanation_text = "Recover the shattered essence of Ratvar and summon him through the Altar of Reforging."

/datum/objective/clockwork/summon_ratvar/check_completion()
	var/datum/team/clockwork/cult_team = team
	if(!istype(cult_team))
		return FALSE
	return cult_team.check_cult_victory() == CLOCKWORK_VICTORY
