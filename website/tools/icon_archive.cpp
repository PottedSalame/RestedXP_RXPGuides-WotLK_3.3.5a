// Reuse the terrain reader's read-only MPQ lookup without broadening its
// historical allowlist. Only reviewed UI textures and two metadata tables.
#define main terrain_reader_main
#include "map_archive.cpp"
#undef main
static bool iconAllowed(std::string name) {
    std::transform(name.begin(), name.end(), name.begin(), [](unsigned char c) { return (char)tolower(c); });
    return name == "interface\\gossipframe\\availablequesticon.blp" ||
        name == "interface\\gossipframe\\activequesticon.blp" ||
        name == "interface\\gossipframe\\vendorgossipicon.blp" ||
        name == "interface\\gossipframe\\trainergossipicon.blp" ||
        name == "interface\\minimap\\tracking\\repair.blp" ||
        name == "interface\\pvpframe\\pvp-currency-alliance.blp" ||
        name == "interface\\pvpframe\\pvp-currency-horde.blp" ||
        name == "dbfilesclient\\skillline.dbc" || name == "dbfilesclient\\lock.dbc" ||
        name == "interface\\icons\\trade_alchemy.blp" ||
        name == "interface\\icons\\trade_blacksmithing.blp" ||
        name == "interface\\icons\\trade_engraving.blp" ||
        name == "interface\\icons\\trade_engineering.blp" ||
        name == "interface\\icons\\trade_herbalism.blp" ||
        name == "interface\\icons\\inv_inscription_tradeskill01.blp" ||
        name == "interface\\icons\\inv_misc_gem_01.blp" ||
        name == "interface\\icons\\trade_leatherworking.blp" ||
        name == "interface\\icons\\inv_pick_02.blp" ||
        name == "interface\\icons\\inv_misc_pelt_wolf_01.blp" ||
        name == "interface\\icons\\trade_tailoring.blp" ||
        name == "interface\\icons\\inv_misc_food_15.blp" ||
        name == "interface\\icons\\spell_holy_sealofsacrifice.blp" ||
        name == "interface\\icons\\trade_fishing.blp";
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    _setmode(_fileno(stdout), _O_BINARY);
    std::vector<mpq_archive_s*> archives;
    for (int i = 1; i < argc; ++i) {
        mpq_archive_s* archive = nullptr;
        if (libmpq__archive_open(&archive, argv[i], -1)) return 3;
        archives.push_back(archive);
    }
    char request[1024];
    while (std::fgets(request, sizeof(request), stdin)) {
        std::string name(request);
        while (!name.empty() && (name.back() == '\n' || name.back() == '\r')) name.pop_back();
        int32_t header[3] = {-10, -1, 0}; std::vector<uint8_t> bytes;
        if (!iconAllowed(name)) header[0] = -23;
        else for (size_t i = 0; i < archives.size(); ++i) {
            uint32_t number = 0; header[0] = lookup(archives[i], name.c_str(), number);
            if (header[0] == -10) continue;
            header[1] = (int32_t)i;
            if (header[0]) break;
            libmpq__off_t size = 0, got = 0;
            header[0] = libmpq__file_unpacked_size(archives[i], number, &size);
            if (header[0] || size <= 0 || size > 4*1024*1024) { header[0] = -24; break; }
            bytes.resize((size_t)size);
            header[0] = libmpq__file_read(archives[i], number, bytes.data(), size, &got);
            if (header[0] || got != size) { header[0] = -25; break; }
            header[2] = (int32_t)size; break;
        }
        std::fwrite(header, sizeof(header), 1, stdout);
        if (!header[0]) std::fwrite(bytes.data(), bytes.size(), 1, stdout);
        std::fflush(stdout);
    }
    for (auto archive : archives) libmpq__archive_close(archive);
}
