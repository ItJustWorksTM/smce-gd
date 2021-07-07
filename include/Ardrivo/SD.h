/*
 *  SD.h
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

#ifndef LIBSMCE_ARDRIVO_SD_H
#define LIBSMCE_ARDRIVO_SD_H

#include <cstdint>
#include <memory>
#include "SMCE_dll.hpp"
#include "Stream.h"

// clang-format off
enum SMCE_FileOpenMode : std::uint8_t {
    FILE_READ = 1 << 0,
    FILE_WRITE = 1 << 1,
};
// clang-format on

class SMCE__DLL_RT_API File : public Stream {
    friend class SDClass;

    struct Opaque;
#if _MSC_VER
#    pragma warning(push)
#    pragma warning(disable : 4251)
#endif
    std::unique_ptr<Opaque> m_u;
#if _MSC_VER
#    pragma warning(pop)
#endif
  public:
    File() noexcept = default;
    File(File&&) noexcept = default;
    ~File(); // required by PIMPL
    explicit operator bool() noexcept;

    const char* name();
    unsigned long position(); // file cursor
    bool seek(unsigned long); // file cursor
    unsigned long size();     // full size
    bool isDirectory();
    File openNextFile(SMCE_FileOpenMode mode = FILE_READ);
    void rewindDirectory();
    void close();

    int available() override; // bytes avail to read
    void flush() override;
    int peek() override; // read next char without advancing cursor
    int read() override;
    std::size_t read(std::uint8_t* buffer, std::size_t size);
    std::size_t read(char* buffer, std::size_t size);
    std::size_t write(std::uint8_t c) override;
    std::size_t write(char c);
    std::size_t write(const std::uint8_t* buffer, std::size_t size) override;
};

class SMCE__DLL_RT_API SDClass {
    friend class SMCE_SDImpl;

    bool m_begun = false;
    std::uint16_t m_cspin;

    SDClass() noexcept = default;

  public:
    bool begin(std::uint16_t cspin = 0);
    bool exists(const char* path);
    File open(const char* path, SMCE_FileOpenMode mode = FILE_READ);
    bool remove(const char* path);
    bool mkdir(const char* path);
    bool rmdir(const char* path);
};

extern SMCE__DLL_RT_API SDClass& SD;

#endif // LIBSMCE_ARDRIVO_SD_H
