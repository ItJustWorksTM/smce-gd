/*
 *  SharedBoardData.cpp
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

#include "SMCE/internal/SharedBoardData.hpp"

namespace bip = boost::interprocess;

using ShmSegMan = bip::managed_shared_memory::segment_manager;
using ShmVoidAllocator = bip::allocator<void, ShmSegMan>;

namespace smce {

SharedBoardData::~SharedBoardData() { reset(); }

bool SharedBoardData::configure(std::string_view seg_name, const BoardConfig& bconf) {
    reset();
    m_master = true;
    m_name = seg_name;
    m_shm = bip::managed_shared_memory{bip::create_only, m_name.c_str(), 2 * 1024 * 1024};
    m_bd = m_shm.construct<BoardData>("BoardData")(ShmVoidAllocator{m_shm.get_segment_manager()}, bconf);
    return true;
}

bool SharedBoardData::open_as_child(const char* seg_name) {
    if (m_bd || m_master)
        return false;
    m_name = seg_name;
    m_shm = bip::managed_shared_memory(bip::open_only, seg_name);
    m_bd = m_shm.find<BoardData>("BoardData").first;
    return true;
}

void SharedBoardData::reset() {
    if (m_bd) {
        if (auto [ptr, off] = m_shm.find<BoardData>("BoardData"); ptr)
            m_shm.destroy<BoardData>("BoardData");
    }
    if (m_master)
        bip::shared_memory_object::remove(m_name.c_str());
    m_master = false;
}

} // namespace smce
