extends Node3D

@export var stations_list_json : JSON
@onready var stations_list : Array= stations_list_json.data

var stations : Array[Station]
var num_stations : int = 0
var current_station : int = -1
var t : Tween

func _ready():
	print(stations_list)
	for i in range(stations_list.size()):
		var inst = Station.new()
		add_child(inst)
		inst.station_name = stations_list[i].station_name
		inst.frequency = stations_list[i].frequency
		inst.range = stations_list[i].range
		inst.stream = load(stations_list[i].stream)
	num_stations = stations.size()

## Change the 'frequency' of the radio 
func set_frequency(freq:float):
	var index = int(freq)
