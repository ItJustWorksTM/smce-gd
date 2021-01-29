/*
 *  SMCE.hpp
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

/// \file This is the interface between Ardrivo and SMCE

#ifndef SMCE_ARDRIVO_SMCE_HPP
#define SMCE_ARDRIVO_SMCE_HPP

#include "SMCE_dll.hpp"

using SetupSig = void();
using LoopSig = void();

SMCE__DLL_RT_API int SMCE__main(int, char**, SetupSig*, LoopSig*) noexcept;

#endif // SMCE_ARDRIVO_SMCE_HPP
