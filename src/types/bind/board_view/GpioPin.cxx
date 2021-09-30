/*
*  GpioPin.hxx
*  Copyright 2021 ItJustWorksTM
*
*  Licensed under the Apache License, Version 2.0 (the "License");
*  you may not use this file except in compliance with the License.
*  You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and
*  limitations under the License.
*
*/

#include "GpioPin.hxx"
#include "util/Extensions.hxx"

using namespace godot;

void GpioPin::_register_methods() {
  register_method("analog_read", &GpioPin::analog_read);
  register_method("analog_write", &GpioPin::analog_write);
  register_method("digital_read", &GpioPin::digital_read);
  register_method("digital_write", &GpioPin::digital_write);
}
Ref<GpioPin> GpioPin::FromNative(smce::VirtualPin pin) {
  auto ret = make_ref<GpioPin>();
  ret->vpin = pin;
  return ret;
}

int GpioPin::analog_read() { return vpin.analog().read(); }
void GpioPin::analog_write(int value) {
  vpin.analog().write(static_cast<uint16_t>(value));
}

bool GpioPin::digital_read() { return vpin.digital().read(); }
void GpioPin::digital_write(bool value) { return vpin.digital().write(value); }