class JsExceptionNotifierController < ApplicationController

  before_filter :exception_notification_gem_available?

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

  # Throws exception for some who passed dependency of exception_notification gem but tries to run on different environment.
  def exception_notification_gem_available?
    begin
      Module.const_get('exception_notification')
    rescue NameError => e
      raise("Load exception_notification gem for #{Rails.env.to_s} first!")
    end
  end

end
