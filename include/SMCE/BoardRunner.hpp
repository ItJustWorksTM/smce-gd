/*
 *  BoardRunner.hpp
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

#ifndef SMCE_BOARDRUNNER_HPP
#define SMCE_BOARDRUNNER_HPP

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

class BoardRunner {
  public:
    enum class Status {
        clean,
        configured,
        built,
        running,
        suspended,
        stopped
    };

    explicit BoardRunner(ExecutionContext& ctx, std::function<void(int)> exit_notify = nullptr) noexcept;
    ~BoardRunner();

    [[nodiscard]] Status status() const noexcept { return m_status; }
    [[nodiscard]] BoardView view() noexcept;

    void tick() noexcept;

    bool reset() noexcept;
    bool configure(std::string_view pp_fqbn, const BoardConfig& bconf) noexcept;
    bool build(const stdfs::path& sketch_src, const SketchConfig& skonf) noexcept;
    bool start() noexcept;
    bool suspend() noexcept;
    bool resume() noexcept;
    bool terminate() noexcept;
    bool stop() noexcept;

    [[nodiscard]] inline std::pair<std::unique_lock<std::mutex>, std::string&> build_log() noexcept { return {std::unique_lock{m_build_log_mtx}, m_build_log}; }
    [[nodiscard]] inline std::pair<std::unique_lock<std::mutex>, std::string&> runtime_log() noexcept { return {std::unique_lock{m_runtime_log_mtx}, m_runtime_log}; }

  private:
    struct Internal;
    enum class Command;

    ExecutionContext& m_exectx;
    Status m_status{};
    stdfs::path m_sketch_dir;
    stdfs::path m_sketch_bin;
    std::string m_build_log;
    std::string m_runtime_log;
    std::mutex m_build_log_mtx;
    std::mutex m_runtime_log_mtx;
    std::function<void(int)> m_exit_notify;
    std::unique_ptr<Internal> m_internal;
};

}

#endif // SMCE_BOARDRUNNER_HPP
