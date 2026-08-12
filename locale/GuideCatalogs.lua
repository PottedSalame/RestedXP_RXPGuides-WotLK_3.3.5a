local _, addon = ...

local locale = GetLocale()
local service = addon.guideLocalization
if not service then return end

-- Reviewed common guide grammar.  Values use named tokens so languages may
-- reorder the visible name safely without Lua 5.1 positional formatting.
-- Proper names stay canonical here and are replaced from client/locale data by
-- Guide/Localization.lua at render time.
local selected
if locale == "deDE" then
    selected = {
        ui = {
            ["Guide Language"] = "Guide-Sprache",
            ["Translated (client language)"] = "Übersetzt (Clientsprache)",
            ["Original English"] = "Englisches Original",
            ["This instruction has not yet been reviewed in your language."] = "Diese Anweisung wurde in deiner Sprache noch nicht geprüft.",
        },
        exact = { ["Sell junk/resupply"] = "Plunder verkaufen/Vorräte auffüllen",
            ["Train skills"] = "Fertigkeiten erlernen", ["Stable your pet"] = "Begleiter in den Stall bringen",
            ["Die and respawn at the graveyard"] = "Sterben und am Friedhof wiederbeleben" },
        flightPath = "Flugpunkt {value} holen",
        semantic = {
            xpAway = "Grinde, bis dir {amount} EP bis Stufe {level} fehlen",
            xpInto = "Grinde bis {amount} EP in Stufe {level}",
            xpPercent = "Grinde bis {amount}% in Stufe {level}",
            grindLevel = "Grinde bis Stufe {level}",
            repAway = "Grinde, bis dir {amount} Ruf bis {standing} bei {faction} fehlen",
            repInto = "Grinde bis {amount} Ruf in {standing} bei {faction}",
            repPercent = "Grinde bis {amount}% in {standing} bei {faction}",
            reputation = "Erreiche {standing} bei {faction}",
        },
        verbs = {
            {"Accept", "{value} annehmen"}, {"Turn in", "{value} abgeben"},
            {"Talk to", "Mit {value} sprechen"}, {"Kill", "{value} töten"},
            {"Loot", "{value} plündern"}, {"Collect", "{value} sammeln"},
            {"Use", "{value} benutzen"}, {"Equip", "{value} anlegen"},
            {"Buy", "{value} kaufen"}, {"Train", "{value} erlernen"},
            {"Vendor", "{value} verkaufen"},
            {"Fly to", "Nach {value} fliegen"}, {"Travel to", "Nach {value} reisen"},
            {"Travel toward", "In Richtung {value} reisen"},
            {"Hearth to", "Ruhestein nach {value} benutzen"},
            {"Set your Hearthstone to", "Ruhestein auf {value} setzen"},
            {"Go to", "Zu {value} gehen"}, {"Grind to", "Bis {value} grinden"},
        },
        titles = {{"RestedXP", "RestedXP"}, {"Speedrun Guide", "Speedrun-Guide"},
            {"Leveling Guide", "Levelguide"}, {"Original Guides", "Original-Guides"},
            {"Daily Quests", "Tägliche Quests"}, {"Dungeon Quests", "Dungeonquests"},
            {"Professions", "Berufe"}, {"Reputations", "Ruf"},
            {"Attunements", "Zugangsquests"}, {"Farming Guides", "Farm-Guides"},
            {"Alliance", "Allianz"}, {"Horde", "Horde"}, {"Guide", "Guide"}},
    }
elseif locale == "esES" then
    selected = {
        ui = {
            ["Guide Language"] = "Idioma de las guías",
            ["Translated (client language)"] = "Traducido (idioma del cliente)",
            ["Original English"] = "Inglés original",
            ["This instruction has not yet been reviewed in your language."] = "Esta instrucción todavía no ha sido revisada en tu idioma.",
        },
        exact = { ["Sell junk/resupply"] = "Vende basura/reabastécete",
            ["Train skills"] = "Aprende habilidades", ["Stable your pet"] = "Guarda tu mascota",
            ["Die and respawn at the graveyard"] = "Muere y resucita en el cementerio" },
        flightPath = "Consigue el punto de vuelo de {value}",
        semantic = {
            xpAway = "Combate hasta que te falten {amount} EXP para el nivel {level}",
            xpInto = "Combate hasta alcanzar {amount} EXP en el nivel {level}",
            xpPercent = "Combate hasta alcanzar el {amount}% del nivel {level}",
            grindLevel = "Combate hasta el nivel {level}",
            repAway = "Combate hasta que te falten {amount} de reputación para {standing} con {faction}",
            repInto = "Combate hasta alcanzar {amount} de reputación en {standing} con {faction}",
            repPercent = "Combate hasta alcanzar el {amount}% de {standing} con {faction}",
            reputation = "Alcanza {standing} con {faction}",
        },
        verbs = {
            {"Accept", "Acepta {value}"}, {"Turn in", "Entrega {value}"},
            {"Talk to", "Habla con {value}"}, {"Kill", "Mata a {value}"},
            {"Loot", "Despoja {value}"}, {"Collect", "Recoge {value}"},
            {"Use", "Usa {value}"}, {"Equip", "Equipa {value}"},
            {"Buy", "Compra {value}"}, {"Train", "Aprende {value}"},
            {"Vendor", "Vende {value}"},
            {"Fly to", "Vuela a {value}"}, {"Travel to", "Viaja a {value}"},
            {"Travel toward", "Viaja hacia {value}"},
            {"Hearth to", "Usa la piedra de hogar hacia {value}"},
            {"Set your Hearthstone to", "Vincula la piedra de hogar en {value}"},
            {"Go to", "Ve a {value}"}, {"Grind to", "Sube mediante combate hasta {value}"},
        },
        titles = {{"Speedrun Guide", "Guía de speedrun"}, {"Leveling Guide", "Guía de subida"},
            {"Original Guides", "Guías originales"}, {"Daily Quests", "Misiones diarias"},
            {"Dungeon Quests", "Misiones de mazmorra"}, {"Professions", "Profesiones"},
            {"Reputations", "Reputaciones"}, {"Attunements", "Armonizaciones"},
            {"Farming Guides", "Guías de farmeo"}, {"Alliance", "Alianza"},
            {"Horde", "Horda"}, {"Guide", "Guía"}},
    }
elseif locale == "frFR" then
    selected = {
        ui = {
            ["Guide Language"] = "Langue des guides",
            ["Translated (client language)"] = "Traduit (langue du client)",
            ["Original English"] = "Anglais original",
            ["This instruction has not yet been reviewed in your language."] = "Cette instruction n’a pas encore été révisée dans votre langue.",
        },
        exact = { ["Sell junk/resupply"] = "Vendez les objets inutiles/ravitaillez-vous",
            ["Train skills"] = "Apprenez des compétences", ["Stable your pet"] = "Mettez votre familier à l’écurie",
            ["Die and respawn at the graveyard"] = "Mourez et réapparaissez au cimetière" },
        flightPath = "Prenez le trajet aérien de {value}",
        semantic = {
            xpAway = "Combattez jusqu’à être à {amount} EXP du niveau {level}",
            xpInto = "Combattez jusqu’à {amount} EXP dans le niveau {level}",
            xpPercent = "Combattez jusqu’à {amount}% du niveau {level}",
            grindLevel = "Combattez jusqu’au niveau {level}",
            repAway = "Combattez jusqu’à être à {amount} points de {standing} auprès de {faction}",
            repInto = "Combattez jusqu’à {amount} points dans {standing} auprès de {faction}",
            repPercent = "Combattez jusqu’à {amount}% de {standing} auprès de {faction}",
            reputation = "Atteignez {standing} auprès de {faction}",
        },
        verbs = {
            {"Accept", "Acceptez {value}"}, {"Turn in", "Rendez {value}"},
            {"Talk to", "Parlez à {value}"}, {"Kill", "Tuez {value}"},
            {"Loot", "Fouillez {value}"}, {"Collect", "Récupérez {value}"},
            {"Use", "Utilisez {value}"}, {"Equip", "Équipez {value}"},
            {"Buy", "Achetez {value}"}, {"Train", "Apprenez {value}"},
            {"Vendor", "Vendez {value}"},
            {"Fly to", "Volez vers {value}"}, {"Travel to", "Voyagez vers {value}"},
            {"Travel toward", "Dirigez-vous vers {value}"},
            {"Hearth to", "Utilisez la pierre de foyer vers {value}"},
            {"Set your Hearthstone to", "Fixez votre pierre de foyer à {value}"},
            {"Go to", "Allez à {value}"}, {"Grind to", "Progressez jusqu’à {value}"},
        },
        titles = {{"Speedrun Guide", "Guide de speedrun"}, {"Leveling Guide", "Guide de montée en niveau"},
            {"Original Guides", "Guides originaux"}, {"Daily Quests", "Quêtes journalières"},
            {"Dungeon Quests", "Quêtes de donjon"}, {"Professions", "Métiers"},
            {"Reputations", "Réputations"}, {"Attunements", "Accès"},
            {"Farming Guides", "Guides de farm"}, {"Alliance", "Alliance"},
            {"Horde", "Horde"}, {"Guide", "Guide"}},
    }
elseif locale == "koKR" then
    selected = {
        ui = {
            ["Guide Language"] = "가이드 언어",
            ["Translated (client language)"] = "번역됨 (클라이언트 언어)",
            ["Original English"] = "영어 원문",
            ["This instruction has not yet been reviewed in your language."] = "이 안내는 아직 현재 언어로 검수되지 않았습니다.",
        },
        exact = { ["Sell junk/resupply"] = "잡동사니 판매/보급",
            ["Train skills"] = "기술 배우기", ["Stable your pet"] = "야수 맡기기",
            ["Die and respawn at the graveyard"] = "죽은 뒤 무덤에서 부활" },
        flightPath = "비행 경로 발견: {value}",
        semantic = {
            xpAway = "레벨 {level}까지 경험치 {amount}이 남을 때까지 사냥",
            xpInto = "레벨 {level}에서 경험치 {amount}을 얻을 때까지 사냥",
            xpPercent = "레벨 {level}의 {amount}%까지 사냥",
            grindLevel = "레벨 {level}까지 사냥",
            repAway = "{faction}의 {standing}까지 평판 {amount}이 남을 때까지 사냥",
            repInto = "{faction}의 {standing}에서 평판 {amount}을 얻을 때까지 사냥",
            repPercent = "{faction}의 {standing} {amount}%까지 사냥",
            reputation = "{faction} 평판을 {standing}까지 올리기",
        },
        verbs = {
            {"Accept", "퀘스트 수락: {value}"}, {"Turn in", "퀘스트 완료: {value}"},
            {"Talk to", "대화: {value}"}, {"Kill", "처치: {value}"},
            {"Loot", "전리품 획득: {value}"}, {"Collect", "수집: {value}"},
            {"Use", "사용: {value}"}, {"Equip", "착용: {value}"},
            {"Buy", "구매: {value}"}, {"Train", "배우기: {value}"},
            {"Vendor", "판매: {value}"},
            {"Fly to", "비행: {value}"}, {"Travel to", "이동: {value}"},
            {"Travel toward", "다음 방향으로 이동: {value}"},
            {"Hearth to", "귀환석 사용: {value}"}, {"Go to", "이동: {value}"},
            {"Set your Hearthstone to", "귀환석 위치 설정: {value}"},
            {"Grind to", "사냥 목표: {value}"},
        },
        titles = {{"Speedrun Guide", "스피드런 가이드"}, {"Leveling Guide", "레벨링 가이드"},
            {"Original Guides", "원본 가이드"}, {"Daily Quests", "일일 퀘스트"},
            {"Dungeon Quests", "던전 퀘스트"}, {"Professions", "전문 기술"},
            {"Reputations", "평판"}, {"Attunements", "입장 퀘스트"},
            {"Farming Guides", "파밍 가이드"}, {"Alliance", "얼라이언스"},
            {"Horde", "호드"}, {"Guide", "가이드"}},
    }
elseif locale == "ruRU" then
    selected = {
        ui = {
            ["Guide Language"] = "Язык руководств",
            ["Translated (client language)"] = "Перевод (язык клиента)",
            ["Original English"] = "Оригинал на английском",
            ["This instruction has not yet been reviewed in your language."] = "Эта инструкция ещё не проверена на вашем языке.",
        },
        exact = { ["Sell junk/resupply"] = "Продайте хлам/пополните припасы",
            ["Train skills"] = "Обучитесь навыкам", ["Stable your pet"] = "Оставьте питомца в стойле",
            ["Die and respawn at the graveyard"] = "Умрите и воскресните на кладбище" },
        flightPath = "Откройте маршрут полёта: {value}",
        semantic = {
            xpAway = "Сражайтесь, пока до уровня {level} не останется {amount} опыта",
            xpInto = "Сражайтесь до {amount} опыта на уровне {level}",
            xpPercent = "Сражайтесь до {amount}% уровня {level}",
            grindLevel = "Сражайтесь до уровня {level}",
            repAway = "Сражайтесь, пока до уровня {standing} с {faction} не останется {amount} репутации",
            repInto = "Сражайтесь до {amount} репутации на уровне {standing} с {faction}",
            repPercent = "Сражайтесь до {amount}% уровня {standing} с {faction}",
            reputation = "Достигните уровня {standing} с {faction}",
        },
        verbs = {
            {"Accept", "Примите {value}"}, {"Turn in", "Сдайте {value}"},
            {"Talk to", "Поговорите с {value}"}, {"Kill", "Убейте {value}"},
            {"Loot", "Обыщите {value}"}, {"Collect", "Соберите {value}"},
            {"Use", "Используйте {value}"}, {"Equip", "Наденьте {value}"},
            {"Buy", "Купите {value}"}, {"Train", "Обучитесь: {value}"},
            {"Vendor", "Продайте: {value}"},
            {"Fly to", "Летите в {value}"}, {"Travel to", "Отправляйтесь в {value}"},
            {"Travel toward", "Двигайтесь к {value}"},
            {"Hearth to", "Используйте камень возвращения в {value}"},
            {"Set your Hearthstone to", "Привяжите камень возвращения к {value}"},
            {"Go to", "Идите к {value}"}, {"Grind to", "Сражайтесь до {value}"},
        },
        titles = {{"Speedrun Guide", "Руководство для быстрого прохождения"},
            {"Leveling Guide", "Руководство по прокачке"}, {"Original Guides", "Оригинальные руководства"},
            {"Daily Quests", "Ежедневные задания"}, {"Dungeon Quests", "Задания подземелий"},
            {"Professions", "Профессии"}, {"Reputations", "Репутации"},
            {"Attunements", "Цепочки доступа"}, {"Farming Guides", "Руководства по добыче"},
            {"Alliance", "Альянс"}, {"Horde", "Орда"}, {"Guide", "Руководство"}},
    }
elseif locale == "zhCN" then
    selected = {
        ui = {
            ["Guide Language"] = "指南语言",
            ["Translated (client language)"] = "翻译版（客户端语言）",
            ["Original English"] = "英文原版",
            ["This instruction has not yet been reviewed in your language."] = "此条指南尚未经过当前语言的人工校对。",
        },
        exact = { ["Sell junk/resupply"] = "出售垃圾并补给",
            ["Train skills"] = "学习技能", ["Stable your pet"] = "寄存宠物",
            ["Die and respawn at the graveyard"] = "死亡并在墓地复活" },
        flightPath = "开启{value}飞行点",
        semantic = {
            xpAway = "刷怪直到距离等级{level}还差{amount}点经验",
            xpInto = "刷怪直到等级{level}获得{amount}点经验",
            xpPercent = "刷怪直到等级{level}的{amount}%",
            grindLevel = "刷怪到等级{level}",
            repAway = "刷怪直到距离{faction}的{standing}还差{amount}点声望",
            repInto = "刷怪直到在{faction}的{standing}中获得{amount}点声望",
            repPercent = "刷怪直到{faction}的{standing}达到{amount}%",
            reputation = "将{faction}声望提升至{standing}",
        },
        verbs = {
            {"Accept", "接受 {value}"}, {"Turn in", "交付 {value}"},
            {"Talk to", "与{value}交谈"}, {"Kill", "击杀 {value}"},
            {"Loot", "拾取 {value}"}, {"Collect", "收集 {value}"},
            {"Use", "使用 {value}"}, {"Equip", "装备 {value}"},
            {"Buy", "购买 {value}"}, {"Train", "学习 {value}"},
            {"Vendor", "出售 {value}"},
            {"Fly to", "飞往 {value}"}, {"Travel to", "前往 {value}"},
            {"Travel toward", "向{value}前进"}, {"Hearth to", "使用炉石返回 {value}"},
            {"Set your Hearthstone to", "将炉石绑定至 {value}"},
            {"Go to", "前往 {value}"}, {"Grind to", "刷怪直到 {value}"},
        },
        titles = {{"Speedrun Guide", "速通指南"}, {"Leveling Guide", "升级指南"},
            {"Original Guides", "原版指南"}, {"Daily Quests", "日常任务"},
            {"Dungeon Quests", "地下城任务"}, {"Professions", "专业"},
            {"Reputations", "声望"}, {"Attunements", "门钥匙任务"},
            {"Farming Guides", "刷取指南"}, {"Alliance", "联盟"},
            {"Horde", "部落"}, {"Guide", "指南"}},
    }
elseif locale == "zhTW" then
    selected = {
        ui = {
            ["Guide Language"] = "指南語言",
            ["Translated (client language)"] = "翻譯版（客戶端語言）",
            ["Original English"] = "英文原版",
            ["This instruction has not yet been reviewed in your language."] = "此條指南尚未經過目前語言的人工校對。",
        },
        exact = { ["Sell junk/resupply"] = "出售垃圾並補給",
            ["Train skills"] = "學習技能", ["Stable your pet"] = "寄存寵物",
            ["Die and respawn at the graveyard"] = "死亡並在墓地復活" },
        flightPath = "開啟{value}飛行點",
        semantic = {
            xpAway = "刷怪直到距離等級{level}還差{amount}點經驗",
            xpInto = "刷怪直到等級{level}獲得{amount}點經驗",
            xpPercent = "刷怪直到等級{level}的{amount}%",
            grindLevel = "刷怪到等級{level}",
            repAway = "刷怪直到距離{faction}的{standing}還差{amount}點聲望",
            repInto = "刷怪直到在{faction}的{standing}中獲得{amount}點聲望",
            repPercent = "刷怪直到{faction}的{standing}達到{amount}%",
            reputation = "將{faction}聲望提升至{standing}",
        },
        verbs = {
            {"Accept", "接受 {value}"}, {"Turn in", "交付 {value}"},
            {"Talk to", "與{value}交談"}, {"Kill", "擊殺 {value}"},
            {"Loot", "拾取 {value}"}, {"Collect", "收集 {value}"},
            {"Use", "使用 {value}"}, {"Equip", "裝備 {value}"},
            {"Buy", "購買 {value}"}, {"Train", "學習 {value}"},
            {"Vendor", "出售 {value}"},
            {"Fly to", "飛往 {value}"}, {"Travel to", "前往 {value}"},
            {"Travel toward", "向{value}前進"}, {"Hearth to", "使用爐石返回 {value}"},
            {"Set your Hearthstone to", "將爐石綁定至 {value}"},
            {"Go to", "前往 {value}"}, {"Grind to", "刷怪直到 {value}"},
        },
        titles = {{"Speedrun Guide", "速通指南"}, {"Leveling Guide", "升級指南"},
            {"Original Guides", "原版指南"}, {"Daily Quests", "每日任務"},
            {"Dungeon Quests", "地城任務"}, {"Professions", "專業"},
            {"Reputations", "聲望"}, {"Attunements", "門鑰任務"},
            {"Farming Guides", "刷取指南"}, {"Alliance", "聯盟"},
            {"Horde", "部落"}, {"Guide", "指南"}},
    }
end

-- Only the selected branch is constructed, keeping inactive locale catalogs
-- out of memory on the 3.3.5 client.
if not selected then return end
selected.actions = {}
for _, verb in ipairs(selected.verbs or {}) do
    selected.actions[#selected.actions + 1] = {
        pattern = "^" .. verb[1]:gsub("(%W)", "%%%1") .. "%s+(.+)$",
        template = verb[2],
    }
end
selected.titleWords = {}
for _, title in ipairs(selected.titles or {}) do
    selected.titleWords[#selected.titleWords + 1] = {
        title[1]:gsub("(%W)", "%%%1"), title[2],
    }
end
selected.verbs = nil
selected.titles = nil
service:RegisterCatalog(locale, selected)
