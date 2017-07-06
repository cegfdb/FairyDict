// Generated by CoffeeScript 1.10.0
chrome.runtime.sendMessage({
  type: 'setting'
}, function(setting) {
  var handleMouseUp;
  jQuery(document).ready(function() {
    return jQuery('<div class="fairydict-tooltip">\n    <div class="fairydict-spinner">\n      <div class="fairydict-bounce1"></div>\n      <div class="fairydict-bounce2"></div>\n      <div class="fairydict-bounce3"></div>\n    </div>\n    <p class="fairydict-tooltip-content">\n    </p>\n</div>').appendTo('body');
  });
  jQuery(document).mousemove(function(e) {
    var mousex, mousey;
    mousex = e.pageX + 20;
    mousey = e.pageY + 10;
    return jQuery('.fairydict-tooltip').css({
      top: mousey,
      left: mousex
    });
  });
  jQuery(document).bind('keyup', function(event) {
    if (utils.checkEventKey(event, setting.openSK1, setting.openSK2, setting.openKey)) {
      return chrome.runtime.sendMessage({
        type: 'look up',
        means: 'keyboard',
        text: window.getSelection().toString()
      });
    }
  });
  handleMouseUp = function(event) {
    var including, selObj, text;
    selObj = window.getSelection();
    text = selObj.toString().trim();
    if (!text) {
      jQuery('.fairydict-tooltip').fadeOut().hide();
      return;
    }
    including = jQuery(event.target).has(selObj.focusNode).length || jQuery(event.target).is(selObj.focusNode);
    if (event.which === 1 && including) {
      jQuery('.fairydict-tooltip').fadeIn('slow');
      jQuery('.fairydict-tooltip .fairydict-spinner').show();
      jQuery('.fairydict-tooltip .fairydict-tooltip-content').empty();
      if (setting.enablePlainLookup) {
        chrome.runtime.sendMessage({
          type: 'look up pain',
          means: 'mouse',
          text: text
        }, function(res) {
          var definition;
          if (res != null ? res.defs : void 0) {
            definition = res.defs.reduce((function(n, m) {
              if (n) {
                n += '<br/>';
              }
              n += m.pos + ' ' + m.def;
              return n;
            }), '');
            console.log("[FairyDict] plain definition: ", definition);
            jQuery('.fairydict-tooltip .fairydict-spinner').hide();
            return jQuery('.fairydict-tooltip .fairydict-tooltip-content').html(definition);
          } else {
            return jQuery('.fairydict-tooltip').fadeOut().hide();
          }
        });
      }
      if (!setting.enableMouseSK1 || (setting.mouseSK1 && utils.checkEventKey(event, setting.mouseSK1))) {
        return chrome.runtime.sendMessage({
          type: 'look up',
          means: 'mouse',
          text: window.getSelection().toString()
        });
      }
    }
  };
  return jQuery(document).mouseup(function(e) {
    return setTimeout((function() {
      return handleMouseUp(e);
    }), 1);
  });
});

chrome.runtime.sendMessage({
  type: 'injected',
  url: location.href
});
