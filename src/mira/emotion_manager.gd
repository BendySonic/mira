class_name EmotionManager
extends Node

# Dynamic feel
signal happy
signal sad
signal angry
signal feared

enum Event {HAPPY, SAD, ANGER, SCARY}

# Main feel
# 0%-100% (0.0-1.0)
var happiness: Emotion = Emotion.new(0.70)
var sadness: Emotion = Emotion.new(0.05)
var anger: Emotion = Emotion.new(0.05)
var fear: Emotion = Emotion.new(0.20)


func feel(event: Event, importance: float):
	match event:
		Event.HAPPY:
			pass
		Event.SCARY:
			fear.add(importance)
			equal_subtract_emotions(sadness, anger, happiness, importance)
			feared.emit()

# Samples value evenly (i.e. a=2, b=1, c=2, value=1 => a=1, b=0, c=1)
func equal_subtract_emotions(a: Emotion, b: Emotion, c: Emotion, value: float):
	var negative_overvalue: float = 0.0
	var negative_count: int = 0
	for emotion in [a, b, c]:
		emotion.subtract(value / 3)
		if emotion.get_value() < 0:
			negative_overvalue += -emotion.value
			emotion.set_value(0)
			negative_count += 1
	for emotion in [a, b, c]:
		if emotion.get_value() > 0:
			emotion.subtract(negative_overvalue / (3 - negative_count))

func print_info():
	print(happiness.value, " ", sadness.value, " ", anger.value, " ", fear.value)
