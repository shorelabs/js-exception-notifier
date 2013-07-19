class JsExceptionNotifierController < ApplicationController
  class JSException < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
      super(message)
    end
  end

  def javascript_error
    ExceptionNotifier.notify_exception(JSException.new(params['errorMsg'].to_s), :data => {:error => params['errorMsg'], :file=> params['file'], :line=> params['lineNumber'], :browser=> params['browserInfo']})
    render :nothing=> true
  end
end
