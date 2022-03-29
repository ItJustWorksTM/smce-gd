
#include "SMCE_gd/Board.hxx"

Board::Board()
    : board{std::make_shared<smce::Board>([&](int res) {
          exit_code = res;
          exit_code_res->set_err(exit_code);
          m_view->valid = false;
          //   m_view->emit_signal("invalidated");
      })} {
    m_view = make_ref<BoardView>();
    m_log_reader = make_ref<BoardLogReader>();
    m_log_reader->board = board;
}

smce::Board& Board::native() { return *board; }

Ref<Result> Board::initialize(Ref<ManifestRegistry> registry, Ref<BoardConfig> board_config) {
    if (!is_status(smce::Board::Status::clean))
        return Result::err("Board already in use");

    const auto native_config = board_config->resolve_native(registry);

    if (!board->configure(native_config))
        return Result::err("Failed to configure board");
    if (!board->prepare())
        return Result::err("Failed to prepare board");

    auto bv = board->view();
    m_view = BoardView::from_native(native_config, bv);

    return Result::ok();
}

Ref<Result> Board::start(Ref<Sketch> sketch) {
    if (!sketch->get_compiled())
        return Result::err("Sketch is not compiled");
    if (!board)
        return Result::err("Bruh wtf no board?");
    if (!board->attach_sketch(sketch->as_native()))
        return Result::err("Failed to attach sketch");
    if (!board->start())
        return Result::err("Failed to start internal runner");

    m_sketch = sketch;

    return Result::ok();
}

Ref<Result> Board::suspend() {
    if (!is_status(smce::Board::Status::running))
        return Result::err("Sketch is not running");
    if (!board->suspend())
        return Result::err("Failed to suspend internal runner");
    return Result::ok();
}

Ref<Result> Board::resume() {
    if (!is_status(smce::Board::Status::suspended))
        return Result::err("Sketch is not suspended");
    if (!board->resume())
        return Result::err("Failed to resume internal runner");
    return Result::ok();
}

Ref<Result> Board::poll() {

    if (stopped)
        return exit_code_res;

    if (!is_active())
        return exit_code_res;

    // Should cause side effects if sketch has crashed
    board->tick();

    if (is_active()) {
        m_view->poll();
    }

    return exit_code_res;
}

Ref<Result> Board::stop() {
    if (is_status(smce::Board::Status::clean))
        return Result::err("Board has not run yet");

    if (stopped)
        return exit_code_res;

    poll();

    if (is_active()) {
        board->terminate();
    }

    m_view->valid = false;
    m_view->emit_signal("invalidated");

    stopped = true;
    return exit_code_res;
}

int Board::get_status() { return static_cast<int>(board->status()); }

Ref<BoardView> Board::get_view() { return m_view; }

void Board::_bind_methods() {
    bind_method("initialize", &This::initialize);
    bind_method("start", &This::start);
    bind_method("suspend", &This::suspend);
    bind_method("resume", &This::resume);
    bind_method("stop", &This::stop);
    bind_method("get_status", &This::get_status);
    bind_method("get_view", &This::get_view);
    bind_method("poll", &This::poll);
    bind_method("log_reader", &This::log_reader);
    bind_method("is_active", &This::is_active);
}

void BoardLogReader::_bind_methods() { bind_method("read", &BoardLogReader::read); }

Variant BoardLogReader::read() {
    if (auto [_, str] = board->runtime_log(); !str.empty()) {
        std::replace_if(
            str.begin(), str.end(), [](const auto& c) { return c == '\r'; }, '\t');
        auto ret = String{str.c_str()};
        str.clear();

        return ret;
    }
    return Variant{};
}
