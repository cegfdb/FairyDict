import setting from "./setting.coffee"
import ext from "./ext.coffee"
import storage from  "./storage.coffee"
import dictWindow from "./dictwindow.coffee"
import dict from "./dict.coffee"
import message from "./message.coffee"
import "./hot-reload-content-scripts.js"

import './plain-lookup.coffee'

onClickedContextMenu = (info, tab)->
    if info.selectionText
        dictWindow.lookup(info.selectionText)

chrome.browserAction.onClicked.addListener (tab)->
    if setting.getValue('browserActionType') == 'openDictWindow'
        return dictWindow.lookup()

    b = !setting.getValue('enableMinidict')
    setting.setValue('enableMinidict', b)
    ext.setBrowserIcon(b)

setting.init().then (c)->
    ext.setBrowserIcon(c.enableMinidict)

    await storage.init()
    await dict.init()
    await dictWindow.init()

chrome.contextMenus.create {
    title: "使用 FairyDict 查询 '%s'",
    contexts: ["selection"],
    onclick: onClickedContextMenu
}
