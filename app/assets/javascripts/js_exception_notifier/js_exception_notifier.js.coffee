# Excludes JS files from services which generates exceptions we can't help

isExcludedContext = (context)->
  excludedContext = []
  excludedContext.push('NREUMQ')
  result = null

  $.each excludedContext, (index, value) ->
    result = context.match(value)
    return if result

  result

isExcludedFile = (filename)->
  excludedServices = []
  excludedServices.push('newrelic', 'livechatinc', 'selenium-ide', 'firebug', 'tracekit', 'amberjack', 'googleapis')
  result = null

  $.each excludedServices, (index, value) ->
    result = filename.match(value)
    return if result

  result

# Subscribes to TraceKit and sends report via ExceptionNotification gem
TraceKit.report.subscribe JSExceptionNotifierLogger = (errorReport) ->
  if errorReport.message != "" and errorReport.stack[0].line > 0 and isExcludedFile(errorReport.stack[0].url) is null and isExcludedContext(errorReport.stack[0].context.join()) is null
    # Basic rate limiting
    window.errorCount or (window.errorCount = 0)
    return if window.errorCount > 5
    window.errorCount += 1

    $.ajax
      url: '/js_exception_notifier'
      data : { errorReport }
      type : 'POST'
      dataType: 'JSON'
      error: (data, textStatus, jqXHR) ->
        console.log data

# Wraps your code on document.ready
$.fn.ready = TraceKit.wrap($.fn.ready)