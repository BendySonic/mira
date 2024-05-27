extends Window


signal pin_pressed
signal launcher_pressed

signal dj_pressed


func _on_pin_button_pressed():
	pin_pressed.emit()

func _on_launcher_button_pressed():
	launcher_pressed.emit()


func _on_dj_button_pressed():
	dj_pressed.emit()
