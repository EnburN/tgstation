/datum/action/innate/clockwork
	button_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/clockwork/IsAvailable(feedback = FALSE)
	if(!IS_CLOCKWORK(owner))
		return FALSE
	return ..()

/datum/action/innate/clockwork/hierophant
	name = "Hierophant Network"
	desc = "Send a whispered message to all other servants. Nearby non-servants can still hear you whisper."
	button_icon_state = "cult_comms"
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/clockwork/hierophant/Activate()
	var/input = tgui_input_text(usr, "Message to relay to all servants", "Hierophant Network", max_length = MAX_MESSAGE_LEN)
	if(!input || !IsAvailable(feedback = TRUE))
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)
		if(tgui_alert(usr, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")

	hierophant_broadcast(usr, input)

/datum/action/innate/clockwork/hierophant/proc/hierophant_broadcast(mob/living/user, message)
	if(!message || !user.mind)
		return

	user.whisper(pick("Cog", "Gear", "Spring", "Pin") + "-" + pick("rath", "var", "bere", "nez") + "!", language = /datum/language/common, forced = "clockwork invocation")
	user.whisper(html_decode(message), filterproof = TRUE)

	var/title = "Servant"
	var/span = "cult italic"
	var/formatted_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"

	for(var/mob/listener as anything in GLOB.player_list)
		if(IS_CLOCKWORK(listener))
			to_chat(listener, formatted_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = listener == user)
		else if(listener in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(listener, user)
			to_chat(listener, "[link] [formatted_message]", type = MESSAGE_TYPE_RADIO)

	user.log_talk(message, LOG_SAY, tag = "clockwork")
