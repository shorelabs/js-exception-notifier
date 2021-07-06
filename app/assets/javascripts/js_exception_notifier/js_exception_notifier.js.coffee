# Excludes JS files from services which generates exceptions we can't help

isExcludedContext = (context)->
  return false unless context

  excludedContext = []
  excludedContext.push('NREUMQ')

  $.each excludedContext, (index, value) ->
    result = context.match(value)
    return true if result

  false

isExcludedFile = (filename)->
  return false unless filename

  excludedServices = []
  excludedServices.push('newrelic', 'livechatinc', 'selenium-ide', 'firebug', 'tracekit', 'amberjack', 'googleapis')

  $.each excludedServices, (index, value) ->
    result = filename.match(value)
    return true if result

  false

# Subscribes to TraceKit and sends report via ExceptionNotification gem
TraceKit.report.subscribe JSExceptionNotifierLogger = (errorReport) ->
  if errorReport.message != '' &&
      errorReport.stack && errorReport.stack[0] &&
      errorReport.stack[0].line > 0 &&
      ! isExcludedFile(errorReport.stack[0].url) &&
      ! isExcludedContext(errorReport.stack[0].context?.join())

    # Basic rate limiting
    window.errorCount or (window.errorCount = 0)
    return if window.errorCount > 5
    window.errorCount += 1

    # Add information about href and user agent
    errorReport.url = document.location.href
    errorReport.useragent = navigator.userAgent
    
    $.ajax
      url: '/js_exception_notifier'
      headers: {
        'X-CSRF-Token': jQuery?('meta[name="csrf-token"]').attr('content')
      }
      data : { errorReport }
      type : 'POST'
      dataType: 'JSON'
      error: (data, textStatus, jqXHR) ->
        console.log data

# Wraps your code on document.ready
$.fn.ready = TraceKit.wrap($.fn.ready)
