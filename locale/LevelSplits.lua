-- Presentation-only localization for manual recovery of a missed automatic
-- level split. Timing and report data remain locale-independent.
local addonName = ...
local locale = GetLocale()

local translations = {
    deDE = {
        ["Split"] = "Split",
        ["Record missed level split"] = "Verpassten Level-Split erfassen",
        ["Requests /played and records the previous level if its automatic split was missed."] = "Fordert /played an und erfasst die vorherige Stufe, falls der automatische Split verpasst wurde.",
        ["No previous level split is available."] = "Kein vorheriger Level-Split ist verfuegbar.",
        ["That level split is already recorded."] = "Dieser Level-Split wurde bereits erfasst.",
        ["Unable to reconstruct that level split from played time."] = "Der Level-Split konnte nicht aus der Spielzeit rekonstruiert werden.",
        ["Played time is still loading. Try again in a moment."] = "Die Spielzeit wird noch geladen. Versuche es gleich erneut.",
        ["Level %d split recorded manually."] = "Level-%d-Split wurde manuell erfasst."
    },
    esES = {
        ["Split"] = "Dividir",
        ["Record missed level split"] = "Registrar division de nivel omitida",
        ["Requests /played and records the previous level if its automatic split was missed."] = "Solicita /played y registra el nivel anterior si se omitio su division automatica.",
        ["No previous level split is available."] = "No hay una division de nivel anterior disponible.",
        ["That level split is already recorded."] = "Esa division de nivel ya esta registrada.",
        ["Unable to reconstruct that level split from played time."] = "No se pudo reconstruir esa division con el tiempo jugado.",
        ["Played time is still loading. Try again in a moment."] = "El tiempo jugado aun se esta cargando. Intentalo de nuevo en un momento.",
        ["Level %d split recorded manually."] = "Division del nivel %d registrada manualmente."
    },
    frFR = {
        ["Split"] = "Temps",
        ["Record missed level split"] = "Enregistrer un temps de niveau manque",
        ["Requests /played and records the previous level if its automatic split was missed."] = "Demande /played et enregistre le niveau precedent si son temps automatique a ete manque.",
        ["No previous level split is available."] = "Aucun temps de niveau precedent n'est disponible.",
        ["That level split is already recorded."] = "Ce temps de niveau est deja enregistre.",
        ["Unable to reconstruct that level split from played time."] = "Impossible de reconstruire ce temps de niveau a partir du temps de jeu.",
        ["Played time is still loading. Try again in a moment."] = "Le temps de jeu est encore en cours de chargement. Reessayez dans un instant.",
        ["Level %d split recorded manually."] = "Temps du niveau %d enregistre manuellement."
    },
    koKR = {
        ["Split"] = "구간",
        ["Record missed level split"] = "누락된 레벨 구간 기록",
        ["Requests /played and records the previous level if its automatic split was missed."] = "/played를 요청하여 자동 구간 기록이 누락된 이전 레벨을 기록합니다.",
        ["No previous level split is available."] = "기록할 이전 레벨 구간이 없습니다.",
        ["That level split is already recorded."] = "해당 레벨 구간은 이미 기록되었습니다.",
        ["Unable to reconstruct that level split from played time."] = "플레이 시간으로 해당 레벨 구간을 복원할 수 없습니다.",
        ["Played time is still loading. Try again in a moment."] = "플레이 시간을 불러오는 중입니다. 잠시 후 다시 시도하세요.",
        ["Level %d split recorded manually."] = "%d레벨 구간을 수동으로 기록했습니다."
    },
    ruRU = {
        ["Split"] = "Отсечка",
        ["Record missed level split"] = "Записать пропущенную отсечку уровня",
        ["Requests /played and records the previous level if its automatic split was missed."] = "Запрашивает /played и записывает предыдущий уровень, если автоматическая отсечка была пропущена.",
        ["No previous level split is available."] = "Предыдущая отсечка уровня недоступна.",
        ["That level split is already recorded."] = "Эта отсечка уровня уже записана.",
        ["Unable to reconstruct that level split from played time."] = "Не удалось восстановить отсечку уровня по игровому времени.",
        ["Played time is still loading. Try again in a moment."] = "Игровое время еще загружается. Повторите попытку через несколько секунд.",
        ["Level %d split recorded manually."] = "Отсечка уровня %d записана вручную."
    },
    zhCN = {
        ["Split"] = "分段",
        ["Record missed level split"] = "记录遗漏的等级分段",
        ["Requests /played and records the previous level if its automatic split was missed."] = "请求 /played，并在自动分段遗漏时记录上一个等级。",
        ["No previous level split is available."] = "没有可记录的上一个等级分段。",
        ["That level split is already recorded."] = "该等级分段已经记录。",
        ["Unable to reconstruct that level split from played time."] = "无法根据游戏时间重建该等级分段。",
        ["Played time is still loading. Try again in a moment."] = "游戏时间仍在载入，请稍后重试。",
        ["Level %d split recorded manually."] = "已手动记录等级 %d 分段。"
    },
    zhTW = {
        ["Split"] = "分段",
        ["Record missed level split"] = "記錄遺漏的等級分段",
        ["Requests /played and records the previous level if its automatic split was missed."] = "要求 /played，並在自動分段遺漏時記錄上一個等級。",
        ["No previous level split is available."] = "沒有可記錄的上一個等級分段。",
        ["That level split is already recorded."] = "該等級分段已經記錄。",
        ["Unable to reconstruct that level split from played time."] = "無法根據遊戲時間重建該等級分段。",
        ["Played time is still loading. Try again in a moment."] = "遊戲時間仍在載入，請稍後再試。",
        ["Level %d split recorded manually."] = "已手動記錄等級 %d 分段。"
    }
}

local entries = translations[locale]
if not entries then return end

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, locale, false)
if not L then return end
for english, translated in pairs(entries) do L[english] = translated end
