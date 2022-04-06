class_name ConeRaycaster extends Node

var output: SR04

func _ready():
    pass

func _process(delta):
    output.distance += 0.05
