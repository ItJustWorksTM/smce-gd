#ifndef SMCE_GD_BOARD_HXX
#define SMCE_GD_BOARD_HXX

#include "SMCE/Board.hpp"
#include "SMCE_gd/BoardConfig.hxx"
#include "SMCE_gd/BoardView.hxx"
#include "SMCE_gd/ManifestRegistry.hxx"
#include "SMCE_gd/Result.hxx"
#include "SMCE_gd/Sketch.hxx"
#include "SMCE_gd/gd_class.hxx"

class BoardLogReader : public GdRef<"BoardLogReader", BoardLogReader> {
  public:
    std::shared_ptr<smce::Board> board;

    static void _bind_methods();

    Variant read();
};

class Board : public GdRef<"Board", Board> {
    std::shared_ptr<smce::Board> board;

    Ref<Sketch> m_sketch;

    template <class... Status> bool is_status(Status... x) { return ((board->status() == x) || ...); }

    Ref<BoardView> m_view;

    Ref<BoardLogReader> m_log_reader;

    bool stopped = false;
    int exit_code = 0;
    Ref<Result> exit_code_res = Result::ok();

  public:
    Board();
    static void _bind_methods();

    Ref<Result> initialize(Ref<ManifestRegistry> registry, Ref<BoardConfig> board_config);
    Ref<Result> start(Ref<Sketch> sketch);
    Ref<Result> suspend();
    Ref<Result> resume();
    Ref<Result> stop();

    bool is_active() { return is_status(smce::Board::Status::running, smce::Board::Status::suspended); }

    Ref<BoardLogReader> log_reader() { return m_log_reader; }

    Ref<Result> poll();

    Ref<BoardView> get_view();

    int get_status();

    smce::Board& native();
};

#endif