/*
 *  Board.hpp
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

#ifndef SMCE_BOARD_HPP
#define SMCE_BOARD_HPP

#include <functional>
#include <memory>
#include <mutex>
#include <string_view>
#include <utility>
#include <SMCE/fwd.hpp>
#include <SMCE/SMCE_fs.hpp>
#include <SMCE/BoardConf.hpp>
#include <SMCE/BoardView.hpp>
#include <SMCE/SketchConf.hpp>

namespace smce {

class Board {
  public:
    enum class Status {
        clean,
        configured,
        running,
        suspended,
        stopped
    };

    using LockedLog = std::pair<std::unique_lock<std::mutex>, std::string&>;

    /**
     * Constructor
     * \param ctx - execution context to use for the sketches run in this runner
     * \param exit_notify - optional notification handler of the sketch's unexpected exit; called by `tick`
     **/
    explicit Board(std::function<void(int)> exit_notify = nullptr) noexcept;
    ~Board();

    [[nodiscard]] Status status() const noexcept { return m_status; }
    [[nodiscard]] BoardView view() noexcept;

    /**
     * Attaches a sketch to this board
     * \param sketch - the sketch to attach
     * \return whether the operation succeeded or not
     **/
    bool attach_sketch(const Sketch& sketch) noexcept;

    /// Getter for the attached sketch
    [[nodiscard]] const Sketch* get_sketch() const noexcept { return m_sketch_ptr; }


    /// Tick runner; call in your frontend physics loop
    void tick() noexcept;

    bool reset() noexcept;
    bool configure(BoardConfig bconf) noexcept;
    bool start() noexcept;
    bool suspend() noexcept;
    bool resume() noexcept;
    bool terminate() noexcept;
    bool stop() noexcept;

    [[nodiscard]] inline LockedLog runtime_log() noexcept { return {std::unique_lock{m_runtime_log_mtx}, m_runtime_log}; }

  private:
    struct Internal;
    enum class Command;

    void do_spawn() noexcept;
    void do_sweep() noexcept;
    void do_reap() noexcept;

    Status m_status{};
    std::optional<BoardConfig> m_conf_opt;
    const Sketch* m_sketch_ptr = nullptr;
    std::string m_runtime_log;
    std::mutex m_runtime_log_mtx;
    std::function<void(int)> m_exit_notify;
    std::unique_ptr<Internal> m_internal;
};

}

#endif // SMCE_BOARD_HPP
