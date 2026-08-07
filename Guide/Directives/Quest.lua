local _, addon = ...

addon.directives:RegisterDomain("quest", {
    "abandon", "accept", "acceptmap", "acceptmultiple", "addtoquestdb",
    "complete", "convertquest", "daily", "dailyturnin",
    "disablequestautomation", "hideifcomplete", "isNotOnQuest", "isOnQuest",
    "isQuestAvailable", "isQuestComplete", "isQuestNotComplete",
    "isQuestOffered", "isQuestTurnedIn", "mirrorquest", "questcount",
    "setquestdb", "show25quests", "skipOnQuest", "turnin",
    "turninmultiple"
})
