class_name Emotion
extends Node

var value: float

func _init(value: float):
	self.value = value

func add(value: float):
	self.value += value

func subtract(value: float):
	self.value -= value

func set_value(value: float):
	self.value = value

func get_value():
	return value
