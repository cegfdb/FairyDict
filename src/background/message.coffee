import utils from "utils"
import setting from "./setting.coffee"
import ext from "./ext.coffee"

console.log "[message] init"

listeners = {}

chrome.runtime.onMessage.addListener (request, sender, sendResponse)->
    if request.type == 'getJson'
        utils.getJson(request.url, request.data).then ((res)->
            sendResponse(res)), sendResponse
    else if request.type == 'postJson'
        utils.postJson(request.url, request.data).then ((res)->
            sendResponse(res)), sendResponse

    else if request.type == 'setting'
        sendResponse setting.configCache

    else if request.type == 'save setting'
        setting.setValue(request.key, request.value)
        if request.key == 'enableMinidict'
            ext.setBrowserIcon request.value

    else if request.type == 'open options'
        chrome.tabs.create({url: chrome.extension.getURL('options.html')})

    else if request.type in Object.keys(listeners)
        ret = listeners[request.type](request, sender)
        if ret?.then
            ret.then sendResponse
        else if ret?
            sendResponse ret

    # sendResponse becomes invalid when the event listener returns,
    # unless you return true from the event listener to indicate you wish to send a response asynchronously
    return true


export default {
    on: (type, callback) ->
        listeners[type] = callback
}