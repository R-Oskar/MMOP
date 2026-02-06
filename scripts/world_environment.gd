extends WorldEnvironment

# Day-night cycle settings
@export var day_length_seconds := 180.0  # Duration of a full day in seconds
@export var sun_max_intensity := 1.0
@export var moon_max_intensity := 0.05
@export var sun_color := Color(1, 1, 0.9)
@export var moon_color := Color(0.6, 0.7, 1)

# References to lights
@export var sun_pivot: Node3D
@onready var sun_light: DirectionalLight3D = sun_pivot.get_node("SunLight")
@export var moon_pivot: Node3D
@onready var moon_light: DirectionalLight3D =  moon_pivot.get_node("MoonLight")

var is_day:bool

# Internal time tracking
@export var time := 0.0  # 0.0 - 1.0 represents full day cycle

func _ready():
	moon_light.light_color = moon_color
func _process(delta):
	# Advance time
	time += delta / day_length_seconds
	if time > 1.0:
		time -= 1.0
	
	_update_lights()

func _update_lights():

	# Rotate sun
	sun_pivot.rotation_degrees.x = lerp(-90, 270, time)
	moon_pivot.rotation_degrees.x = sun_pivot.rotation_degrees.x - 180
	
	# Sun height factor: 0 = below horizon, 1 = overhead
	var sun_height_factor = clamp((sun_pivot.rotation_degrees.x + 90) / 180, 0, 1)
	
	# Sun intensity
	sun_light.light_energy = sun_max_intensity * sun_height_factor
	
	# Moon intensity: stronger at night, weaker when sun is up
	var moon_height_factor = 1.0 - sun_height_factor  # complementary to sun
	moon_light.light_energy = moon_max_intensity * moon_height_factor
	
	var min_ambient = 0.05
	moon_light.light_energy = max(moon_light.light_energy, min_ambient)
	
	# Sunrise/sunset color for sun
	var sunrise_color = Color(1, 0.7, 0.5)
	sun_light.light_color = sun_color.lerp(sunrise_color, 1 - sun_height_factor)
	
	is_day = sun_height_factor > 0

func get_day():
	return is_day
