extends Node

const TASKBAR_HEIGHT = 55

var screen_size: Vector2i = DisplayServer.screen_get_size() - Vector2i(0, TASKBAR_HEIGHT)
