$(document).ready ->
  $ ->
    window.documentIsReady = true

  window.MaximumErrorCount = 5
  window.onerror = (errorMsg, file, lineNumber) ->
    window.errorCount or (window.errorCount = 0)
    if window.errorCount <= window.MaximumErrorCount
      window.errorCount += 1
      browserInfo = navigator.userAgent
      $.ajax
        url: '/js_exception_notifier'
        data : {errorMsg, file, lineNumber, browserInfo}
        type : 'POST'
        dataType: 'script'