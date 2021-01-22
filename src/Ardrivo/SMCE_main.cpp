/*
 *  SMCE_main.cpp
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

#include <cstdio>
#include <cstdlib>
#include <SMCE.hpp>
#include <SMCE/BoardView.hpp>
#include <SMCE/internal/SharedBoardData.hpp>

namespace smce {

smce::SharedBoardData sbd;
smce::BoardView board_view;

void maybe_init() {
    if (sbd.get_board_data())
        return;
    const char* segname = std::getenv("SEGNAME");
    if (!segname)
        segname = ".";
    sbd.open_as_child(segname);
    board_view = smce::BoardView{*sbd.get_board_data()};
}

}

int SMCE__main(int argc, char** argv, SetupSig* setup, LoopSig* loop) noexcept try {
    smce::maybe_init();
    setup();
    for (;;)
        loop();
} catch (const std::exception& e) {
    std::fputs("Exception occurred:", stderr);
    std::fputs(e.what(), stderr);
    std::fputs("Terminating.", stderr);
    return EXIT_FAILURE;
} catch (...) {
    std::fputs("Non C++ exception occurred; terminating", stderr);
    return EXIT_FAILURE;
}