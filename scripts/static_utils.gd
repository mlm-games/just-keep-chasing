class_name Utils

static func get_augment_description(augment: AugmentsData) -> String:
	if not augment.auto_generate_description and not augment.custom_description.is_empty():
		return augment.custom_description

	var description_lines: Array[String] = []
	for modifier in augment.stats_to_modify:
		description_lines.append(get_modifier_description(modifier))
	
	return "\n".join(description_lines)

## Generates a description for a single StatModifier.
static func get_modifier_description(modifier: StatModifier) -> String:
	var stat_name = C.STAT_NAMES.get(modifier.key, "Stat")
	var operation_text = ""
	var value_text = ""

	# Determine the verb and format the value
	match modifier.operation:
		CharacterStats.Operation.ADD:
			operation_text = "Increases" if modifier.value >= 0 else "Decreases"
			value_text = str(abs(modifier.value))
			
			# Special handling for certain stats to show a sign
			if modifier.value >= 0:
				value_text = "+" + value_text
			else:
				value_text = "-" + value_text

		CharacterStats.Operation.MULTIPLY:
			# Convert multiplier to a percentage change for better readability
			var percentage = (modifier.value - 1.0) * 100.0
			operation_text = "Increases" if percentage >= 0 else "Decreases"
			value_text = "%s%.0f%%" % ["+" if percentage >= 0 else "", percentage]

		CharacterStats.Operation.REPLACE:
			operation_text = "Sets"
			value_text = str(modifier.value)
	
	# Handle special cases for more natural language
	if modifier.key == CharacterStats.Stats.RELOAD_SPEED_REDUCTION_MULT:
		# For reload speed, a value of 0.8 (multiplier) should read as "+20% Reload Speed"
		var percentage = (1.0 - modifier.value) * 100.0
		operation_text = "Improves" # Or "Increases"
		stat_name = "Reload Speed" # Overrides the default for clarity
		value_text = "+%.0f%%" % percentage
	
	# Assemble the final string
	return "%s %s by %s." % [operation_text, stat_name, value_text]
