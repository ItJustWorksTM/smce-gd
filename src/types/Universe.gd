#
#  Universe.gd
#  Copyright 2021 ItJustWorksTM
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

class_name Universe
extends Spatial

signal active_world_changed(node)
signal world_list_changed

var world_map := {}

var active_world: String
var active_world_node

func current_world() -> UniverseWorld:
	return null

# Change the world
func set_world_to(name: String) -> bool:
	if !world_map.has(name):
		return false
	destroy_current_world()
	
	active_world = name
	active_world_node = world_map[name].instance()
	
	add_child(active_world_node)
	emit_signal("active_world_changed", active_world_node)
	return true
	

# Will free the current world if one is loaded
func destroy_current_world():
	if active_world != "":
		active_world = ""
		active_world_node.queue_free()
		active_world_node = null

# Add a world to the universe, packedscene needs to be a UniverseWorld (or interface identical)
func add_world(name: String, scene: PackedScene):
	assert(scene != null && scene.can_instance())
#		assert(scene.get_state().get_node_type(0) == "Spatial")
	world_map[name] = scene
	emit_signal("world_list_changed")

func remove_world(name: String) -> bool: return world_map.erase(name)

# Should return a list of environment descriptors (names)
func list_worlds() -> Array: return world_map.keys()
