/*
 *  SMCE_dll.hpp
 *  Copyright 2020-2021 ItJustWorksTM
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

#ifndef SMCE__SMCE_DLL_HPP
#define SMCE__SMCE_DLL_HPP

#if defined(_MSC_VER)
#    if defined(SMCE__COMPILING_USERCODE)
#        define SMCE__DLL_API __declspec(dllexport)
#        define SMCE__DLL_RT_API __declspec(dllimport)
#    else
#        define SMCE__DLL_API
#        define SMCE__DLL_RT_API __declspec(dllexport)
#    endif
#else
#    define SMCE__DLL_RT_API
#    define SMCE__DLL_API
#endif

#endif // SMCE__SMCE_DLL_HPP
