/*
 *  SD.cpp
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

#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string_view>
#include <variant>
#include <SMCE/BoardView.hpp>
#include "SMCE_dll.hpp"
#include "SD.h"

namespace smce {
extern BoardView board_view;
extern void maybe_init();
}

using namespace std::literals;
using namespace smce;

class SMCE_SDImpl : public SDClass {
  public:
    constexpr SMCE_SDImpl() noexcept : SDClass{} {}
    std::filesystem::path root() {
        maybe_init();
        return board_view.storage_get_root(BoardView::Link::SPI, m_cspin);
    }
};

SMCE_SDImpl SMCE_SDimpl{};
SMCE__DLL_API SDClass& SD{SMCE_SDimpl};

struct File::Opaque {
    std::filesystem::path path;
    std::string filename;
    std::variant<std::fstream, std::filesystem::directory_iterator> payload;
};

File::~File() = default;

File::operator bool() noexcept {
    return static_cast<bool>(m_u);
}

const char* File::name() {
    if(!m_u)
        return std::cerr << "File::name(): File not opened" << std::endl, nullptr;
    return m_u->filename.c_str();
}

unsigned long File::position() {
    if(!m_u)
        return std::cerr << "File::position(): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::position(): File is a directory" << std::endl, 0;

    return strm_ptr->tellg();
}

bool File::seek(unsigned long pos) {
    if(!m_u)
        return std::cerr << "File::seek(" << pos << "): File not opened" << std::endl, false;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::seek(" << pos << "): File is a directory" << std::endl,  false;

    if(const auto max_pos = size(); pos > max_pos)
        return std::cerr << "File::seek(" << pos << "): Target cursor position is out of bounds (size() == " << max_pos << ")" << std::endl, false;

    strm_ptr->seekg(pos);
    strm_ptr->seekp(pos);
    return true;
}

unsigned long File::size() {
    if(!m_u)
        return std::cerr << "File::size(): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::size(): File is a directory" << std::endl, 0;

    const auto save_gpos = strm_ptr->tellg();
    strm_ptr->seekg(0, std::ios::end);
    const auto ret = strm_ptr->tellg();
    strm_ptr->seekg(save_gpos, std::ios::beg);
    return static_cast<unsigned long>(ret);
}

bool File::isDirectory() {
    if(!m_u)
        return std::cerr << "File::isDirectory(): File not opened" << std::endl, false;
    return std::get_if<std::filesystem::directory_iterator>(&m_u->payload);
}

File File::openNextFile(SMCE_FileOpenMode mode) {
    if(!m_u) {
        std::cerr << "File::openNextFile(): Current file not opened" << std::endl;
        return {};
    }

    auto* const dir_iter_ptr = std::get_if<std::filesystem::directory_iterator>(&m_u->payload);
    if(!dir_iter_ptr) {
        std::cerr << "File::rewindDirectory(): File is not a directory" << std::endl;
        return {};
    }

    auto& dir_iter = *dir_iter_ptr;
    if(dir_iter == std::filesystem::directory_iterator{})
        return {};
    const auto& entry = *dir_iter++;
    auto path = entry.path();

    File ret;
    ret.m_u = std::make_unique<Opaque>();
    std::error_code ec;
    if(entry.is_regular_file(ec)) {
        std::ios::openmode omode{};
        if(mode & FILE_READ)
            omode |= std::ios::in;
        if(mode & FILE_WRITE)
            omode |= std::ios::out;
        std::fstream strm{path, omode};
        if(!strm.is_open())
            return {};
        ret.m_u->payload = std::move(strm);
    } else if (ec)
        return {};
    else if(entry.is_directory(ec)) {
        std::filesystem::directory_iterator nest_dir_iter{path};
        ret.m_u->payload = std::move(nest_dir_iter);
    } else if (ec)
        return {};

    ret.m_u->filename = path.filename().generic_string();
    ret.m_u->path = std::move(path);
    return ret;
}

void File::rewindDirectory() {
    if(!m_u)
        return (void)(std::cerr << "File::rewindDirectory(): File not opened" << std::endl);

    auto* const dir_iter_ptr = std::get_if<std::filesystem::directory_iterator>(&m_u->payload);
    if(!dir_iter_ptr)
        return (void)(std::cerr << "File::rewindDirectory(): File is not a directory" << std::endl);

    *dir_iter_ptr = std::filesystem::directory_iterator{m_u->path};
}

void File::close() {
    if(!m_u)
        std::cerr << "File::close(): File not opened" << std::endl;
    m_u.reset();
}

int File::available() {
    if(!m_u)
        return std::cerr << "File::available(): File not opened" << std::endl, 0;

    if(!std::get_if<std::fstream>(&m_u->payload))
        return std::cerr << "File::available(): File is a directory" << std::endl, 0;

    return size() - position();
}

void File::flush() {
    if(!m_u)
        return (void)(std::cerr << "File::flush(): File not opened" << std::endl);
    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return (void)(std::cerr << "File::flush(): File is a directory" << std::endl);
    strm_ptr->flush();
}

int File::peek() {
    if(!m_u)
        return std::cerr << "File::peek(): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::peek(): File is a directory" << std::endl, 0;

    return strm_ptr->peek();
}

int File::read() {
    if(!m_u)
        return std::cerr << "File::read(): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::read(): File is a directory" << std::endl, 0;

    const auto ret = strm_ptr->get();
    if(ret == std::fstream::traits_type::eof())
        strm_ptr->seekp(1, std::ios::cur);
    return ret;
}

std::size_t File::read(std::uint8_t* buffer, std::size_t size) {
    return read(reinterpret_cast<char*>(buffer), size);
}

std::size_t File::read(char* buffer, std::size_t size) {
    if(!m_u)
        return std::cerr << "File::read(?, " << size << "): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::read(?, " << size << "): File is a directory" << std::endl, 0;

    strm_ptr->read(buffer, size);
    const auto ret = strm_ptr->gcount();
    strm_ptr->seekp(ret, std::ios::cur);
    return ret;
}

std::size_t File::write(std::uint8_t c) {
    if(!m_u)
        return std::cerr << "File::write(" << +c << "): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::write(" << +c << "): File is a directory" << std::endl, 0;

    strm_ptr->put(c);
    if(!strm_ptr->bad()) {
        strm_ptr->seekg(1, std::ios::cur);
        return 1;
    }
    return 0;
}

std::size_t File::write(char c) {
    return write(static_cast<std::uint8_t>(c));
}

std::size_t File::write(const std::uint8_t* buffer, std::size_t size) {
    if(!m_u)
        return std::cerr << "File::write(?, " << size << "): File not opened" << std::endl, 0;

    auto* const strm_ptr = std::get_if<std::fstream>(&m_u->payload);
    if(!strm_ptr)
        return std::cerr << "File::write(?, " << size << "): File is a directory" << std::endl, 0;

    strm_ptr->write(reinterpret_cast<const char*>(buffer), size);
    if(strm_ptr->bad())
        return 0;
    strm_ptr->seekg(size, std::ios::cur);
    return size;
}

bool SDClass::begin(std::uint16_t cspin) {
    if(m_begun)
        return std::cerr << "SDClass::begin(" << cspin << "): already begun" << std::endl, false;

    if(SMCE_SDimpl.root().empty())
        return std::cerr << "SDClass::begin(" << cspin << "): no such device" << std::endl, false;

    m_cspin = cspin;
    return m_begun = true;
}

bool SDClass::exists(const char* path) {
    const auto path_len = std::strlen(path);
    if(path_len == 0)
        return false;

    return std::filesystem::exists(SMCE_SDimpl.root() / (path[0] == '/' ? path + 1 : path));
}

File SDClass::open(const char* path, SMCE_FileOpenMode mode) {
    const auto path_len = std::strlen(path);
    if(path_len == 0)
        return {};

    std::filesystem::path fspath = SMCE_SDimpl.root();
    if(path[0] == '/') {
        fspath /= (path + 1);
    } else
        fspath /= path;

    std::string fname = fspath.filename().generic_string();

    File ret;
    if(std::filesystem::is_directory(fspath)) {
        std::filesystem::directory_iterator nest_dir_iter{fspath};
        ret.m_u.reset(new File::Opaque{std::move(fspath), std::move(fname), std::move(nest_dir_iter)});
        return ret;
    }

    std::ios::openmode omode{};
    if(mode & FILE_READ)
        omode |= std::ios::in;
    if(mode & FILE_WRITE)
        omode |= std::ios::out;
    std::fstream strm{fspath, omode};
    if(!strm.is_open())
        return {};
    ret.m_u.reset(new File::Opaque{std::move(fspath), std::move(fname), std::move(strm)});
    return ret;
}

bool SDClass::remove(const char* path) {
    const auto path_len = std::strlen(path);
    if(path_len == 0)
        return false;

    const auto fspath = SMCE_SDimpl.root() / (path[0] == '/' ? path + 1 : path);

    if(std::filesystem::is_directory(fspath))
        return false;
    std::filesystem::remove(fspath);
    return true;
}

bool SDClass::mkdir(const char* path) {
    const auto path_len = std::strlen(path);
    if(path_len == 0)
        return false;

    if(path == "/"sv)
        return false;

    return std::filesystem::create_directories(SMCE_SDimpl.root() / (path[0] == '/' ? path + 1 : path));
}

bool SDClass::rmdir(const char* path) {
    const auto path_len = std::strlen(path);
    if(path_len == 0)
        return false;

    if(path == "/"sv)
        return false;

    const auto fspath = SMCE_SDimpl.root() / (path[0] == '/' ? path + 1 : path);

    if(std::filesystem::is_directory(fspath))
        return false;
    std::filesystem::remove_all(fspath);
    return true;
}