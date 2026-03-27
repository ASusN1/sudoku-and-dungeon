extends RefCounted

static var allow_hints_after_max: bool = true


static func can_use_hint(hints_remaining: int) -> bool:
	return hints_remaining > 0 or allow_hints_after_max


static func consume_hint(hints_remaining: int) -> int:
	if hints_remaining > 0:
		return hints_remaining - 1
	return hints_remaining


static func set_allow_hints_after_max(enabled: bool) -> void:
	allow_hints_after_max = enabled
