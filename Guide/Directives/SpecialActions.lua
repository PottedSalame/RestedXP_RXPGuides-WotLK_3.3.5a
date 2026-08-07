local _, addon = ...

addon.directives:RegisterDomain("special-action", {
    "bombdispenser", "cast", "celestial", "choose", "clicknext", "countdown",
    "dailyhub", "disablecheckbox", "emote", "engrave", "enterScenario",
    "gossip", "gossipoption", "ironchain", "link", "logout", "macro", "next",
    "niffelen", "rescue", "scenario", "skipgossip", "skipgossipid", "timer",
    "use", "usespell", "wpbuff", "wptimer"
})
