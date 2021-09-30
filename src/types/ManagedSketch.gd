#
#  ManagedSketch.gd
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

class_name ManagedSketch
extends Reference

var toolchain: Toolchain = Toolchain.new()
var sketch: Sketch = Sketch.new()

func init(sketch_source: String, patches_dir: String, smce_resource_dir: String) -> Result:
	var tc_res = toolchain.init(smce_resource_dir)
	if tc_res.is_err():
		return tc_res
	
	sketch.init(sketch_source, patches_dir)
	
	return Result.new().set_ok(null)

func compile():
	return toolchain.compile(sketch)
