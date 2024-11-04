local handler = require("__core__/lualib/event_handler")
handler.add_libraries({
    require("scripts.configuration"),
    require("scripts.builder"),
    require("scripts.shortcuts"),
})