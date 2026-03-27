extends Panel 

var time: float = 0.0 
var timer_min: int = 0
var timer_sec: int = 0
var timer_minisec: int = 0

func _process(delta: float) -> void:
	time += delta 
	timer_minisec = int(fmod(time, 1) * 100)
	timer_sec = int(fmod(time, 60))
	timer_min = int(fmod(time, 3600) / 60)
	$timer_min.text = "%02d" % timer_min
	$timer_sec.text = "%02d" % timer_sec
	$timer_minisec.text = "%02d" % timer_minisec

func stop() -> void:
	set_process(false)

func get_time_formatted() -> String:
	return "%02d:%02d.%02d" % [timer_min, timer_sec, timer_minisec]
