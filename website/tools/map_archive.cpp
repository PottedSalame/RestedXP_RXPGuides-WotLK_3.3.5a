// RXPGuides offline map reader. Links the authorized local AzerothCore libmpq
// (GPL-2.0-or-later); this helper follows this repository's GPL-3.0 license.
// Archives are opened read-only. Protocol: newline member request -> three
// little-endian int32 values (status, archive index, length), then raw bytes.
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <algorithm>
#include <cctype>
#include <io.h>
#include <fcntl.h>
extern "C" {
#include "mpq.h"
#include "mpq-internal.h"
#include "common.h"
}
static bool allowed(std::string name) {
    std::transform(name.begin(), name.end(), name.begin(), [](unsigned char c) { return (char)tolower(c); });
    if (name.find("..") != std::string::npos || name.size() > 260) return false;
    return name == "textures\\minimap\\md5translate.trs" ||
        (name.rfind("textures\\minimap\\", 0) == 0 && name.size() > 4 && name.substr(name.size()-4) == ".blp") ||
        name == "dbfilesclient\\worldmaparea.dbc" || name == "dbfilesclient\\map.dbc";
}
// Do not let the library's compressed file-number mapping hide a deletion or
// unsupported binary patch and accidentally resurrect an older version.
static int lookup(mpq_archive_s* archive, const char* name, uint32_t& number) {
    const auto count = archive->mpq_header.hash_table_count;
    const auto a = libmpq__hash_string(name, 0x100), b = libmpq__hash_string(name, 0x200);
    auto i = libmpq__hash_string(name, 0) & (count - 1);
    for (uint32_t n = 0; n < count; ++n, i = (i + 1) & (count - 1)) {
        const auto& h = archive->mpq_hash[i];
        if (h.block_table_index == 0xffffffff) return -10;
        if (h.block_table_index == 0xfffffffe || h.hash_a != a || h.hash_b != b) continue;
        if ((h.locale != 0 && h.locale != 0x409) || h.platform != 0) continue;
        if (h.block_table_index >= archive->mpq_header.block_table_count) return -21;
        const auto flags = archive->mpq_block[h.block_table_index].flags;
        if (!(flags & 0x80000000) || (flags & 0x02000000)) return -20;
        if (flags & 0x00100000) return -22;
        number = h.block_table_index - archive->mpq_map[h.block_table_index].block_table_diff;
        return 0;
    }
    return -10;
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    _setmode(_fileno(stdout), _O_BINARY);
    std::vector<mpq_archive_s*> archives;
    for (int i = 1; i < argc; ++i) {
        mpq_archive_s* archive = nullptr;
        if (libmpq__archive_open(&archive, argv[i], -1)) { std::fputs("Cannot open archive read-only\n", stderr); return 3; }
        archives.push_back(archive);
    }
    char request[1024];
    while (std::fgets(request, sizeof(request), stdin)) {
        std::string name(request); while (!name.empty() && (name.back() == '\n' || name.back() == '\r')) name.pop_back();
        int32_t header[3] = {-10, -1, 0}; std::vector<uint8_t> bytes;
        if (!allowed(name)) header[0] = -23;
        else for (size_t i = 0; i < archives.size(); ++i) {
            uint32_t number = 0; header[0] = lookup(archives[i], name.c_str(), number);
            if (header[0] == -10) continue;
            header[1] = (int32_t)i;
            if (header[0]) break;
            libmpq__off_t size = 0, got = 0;
            header[0] = libmpq__file_unpacked_size(archives[i], number, &size);
            if (header[0] || size <= 0 || size > 64*1024*1024) { header[0] = -24; break; }
            bytes.resize((size_t)size);
            header[0] = libmpq__file_read(archives[i], number, bytes.data(), size, &got);
            if (header[0] || got != size) { header[0] = -25; bytes.clear(); break; }
            header[2] = (int32_t)size; break;
        }
        std::fwrite(header, sizeof(header), 1, stdout);
        if (!header[0]) std::fwrite(bytes.data(), bytes.size(), 1, stdout);
        std::fflush(stdout);
    }
    for (auto archive : archives) libmpq__archive_close(archive);
}
