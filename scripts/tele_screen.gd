extends Node
# Snippet for your Telemetry Screen script
@export var player_mech: CharacterBody3D # Assign your player node in the inspector
@onready var speed_bar: ProgressBar = $VBoxContainer/HBoxContainer/ProgressBar
@onready var heat_bar: ProgressBar = $VBoxContainer/HBoxContainer2/ProgressBar

# Mock variable for now, until we build the real heat system
var mock_heat: float = 20.0 

func _process(delta: float) -> void:
	if player_mech:
		# Convert your raw speed into a percentage (0 to 100) for the UI
		# We use absolute value so reversing still shows as engine output
		var speed_percent = (abs(player_mech.current_speed) / player_mech.max_speed) * 100.0
		speed_bar.value = speed_percent
		
		# We can map the target_speed similarly to move a UI marker, 
		# showing the pilot what gear they just shifted into.
		
		# Simulating heat buildup based on your engine load
		if abs(player_mech.current_speed) > (player_mech.max_speed * 0.8):
			mock_heat += 10.0 * delta # Pushing the engine heats it up
		else:
			mock_heat -= 5.0 * delta  # Idling cools it down
			
		mock_heat = clamp(mock_heat, 0.0, 100.0)
		heat_bar.value = mock_heat
