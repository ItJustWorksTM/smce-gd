/*
 *  SharedBoardData.hpp
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

#ifndef SMCE_SHAREDBOARDDATA_HPP
#define SMCE_SHAREDBOARDDATA_HPP

#include <boost/interprocess/managed_shared_memory.hpp>
#include "SMCE/internal/BoardData.hpp"

namespace smce {

/// \internal
class SharedBoardData {
    boost::interprocess::managed_shared_memory m_shm;
    std::string m_name;
    BoardData* m_bd = nullptr;
    bool m_master = false;

  public:
    SharedBoardData() = default;
    ~SharedBoardData();
    bool configure(std::string_view, const BoardConfig&);
    bool open_as_child(const char*);
    void reset();

    BoardData* get_board_data() noexcept { return m_bd; }
};

} // namespace smce

#endif // SMCE_SHAREDBOARDDATA_HPP
