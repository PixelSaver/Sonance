extends Node3D

@export var static_stream : AudioStreamPlayer3D
@export var stations_list_json : JSON
@onready var stations_list : Array= stations_list_json.data
const STATION_SCENE = preload("res://Scenes/station.tscn")

var stations : Array[Station]
var num_stations : int = 0
var current_station : int = -1
var t : Tween

func _ready():
	print(stations_list)
	for i in range(stations_list.size()):
		var inst = STATION_SCENE.instantiate()
		add_child(inst)
		inst.station_name = stations_list[i].station_name
		inst.frequency = stations_list[i].frequency
		inst.freq_range = stations_list[i].range
		inst.stream = load(stations_list[i].stream)
	num_stations = stations.size()

## Change the 'frequency' of the radio 
func set_frequency(freq:float):
	for s in stations:
		var dist = abs(freq - s.frequency)
		var strength : float = clamp(1. - (dist / s.freq_range), 0., 1.)
		s.volume_db = lerpf(-80, 0., strength)
		static_stream.volume_db = lerpf(0., -80., strength)
		
