extends Window

signal activities_pressed
signal pin_pressed
signal launcher_pressed


func _on_activities_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			activities_pressed.emit()

func _on_pin_button_pressed():
	pin_pressed.emit()

func _on_launcher_button_pressed():
	launcher_pressed.emit()
