chrome.runtime.sendMessage {
    type: 'setting',
}, (setting)->
    # $('.masterTooltip').hover (()->
    #     title = $(this).attr('title')
    #     $(this).data('tipText', title).removeAttr('title')

    # ), ()->
    #     $('.tooltip').remove()
    jQuery(document).ready ()->
        jQuery('''
            <div class="fairydict-tooltip">
                <div class="fairydict-spinner">
                  <div class="fairydict-bounce1"></div>
                  <div class="fairydict-bounce2"></div>
                  <div class="fairydict-bounce3"></div>
                </div>
                <p class="fairydict-tooltip-content">
                </p>
            </div>
                ''').appendTo('body')

    jQuery(document).mousemove (e)->
        mousex = e.pageX + 20
        mousey = e.pageY + 10
        jQuery('.fairydict-tooltip').css({ top: mousey, left: mousex })

    jQuery(document).bind 'keyup', (event)->
        if utils.checkEventKey event, setting.openSK1, setting.openSK2, setting.openKey
            chrome.runtime.sendMessage({
                type: 'look up',
                means: 'keyboard',
                text: window.getSelection().toString()
            })

    handleMouseUp = (event)->
        selObj = window.getSelection()
        text = selObj.toString().trim()
        unless text
            jQuery('.fairydict-tooltip').fadeOut().hide()
            return

        # issue #4
        including = jQuery(event.target).has(selObj.focusNode).length or jQuery(event.target).is(selObj.focusNode)

        if event.which == 1 and including
            jQuery('.fairydict-tooltip').fadeIn('slow')
            jQuery('.fairydict-tooltip .fairydict-spinner').show()
            jQuery('.fairydict-tooltip .fairydict-tooltip-content').empty()


            if setting.enablePlainLookup
                chrome.runtime.sendMessage({
                    type: 'look up pain',
                    means: 'mouse',
                    text: text
                }, (res)->
                    if res?.defs
                        definition = res.defs.reduce ((n, m)->
                            n += '<br/>' if n
                            n += m.pos + ' ' + m.def
                            return n
                        ), ''
                        console.log "[FairyDict] plain definition: ", definition
                        # jQuery(event.target).attr('title', definition)
                        jQuery('.fairydict-tooltip .fairydict-spinner').hide()
                        jQuery('.fairydict-tooltip .fairydict-tooltip-content').html(definition)
                    else
                        jQuery('.fairydict-tooltip').fadeOut().hide()

            )

            if !setting.enableMouseSK1 or (setting.mouseSK1 and utils.checkEventKey(event, setting.mouseSK1))
                chrome.runtime.sendMessage({
                    type: 'look up',
                    means: 'mouse',
                    text: window.getSelection().toString()
                })

    jQuery(document).mouseup (e)->
        # 对 mouseup 事件做一个延时处理，
        # 以避免取消选中后getSelection依然能获得文字。
        setTimeout (()->handleMouseUp(e)), 1


chrome.runtime.sendMessage {
    type: 'injected',
    url: location.href
}
