extends Sprite


var location_correct setget set_location_correct


func move_to(position_new):
	$Tween.stop_all()
	var distance = position.distance_to(position_new)
	$Tween.interpolate_property(self, "position", position, position_new, distance / 200)
	$Tween.start()


func set_location_correct(location):
	$Label.text = str(location.x + location.y * 4)
