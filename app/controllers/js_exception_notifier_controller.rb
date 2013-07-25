class JsExceptionNotifierController < ApplicationController

  class JSException < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
      super(message)
    end
  end

  def javascript_error
    render :nothing=> true and return if params.include?('errorMsg')

    if defined?(ExceptionNotification)
      ExceptionNotifier.notify_exception(JSException.new(params['errorReport']['message'].to_s), :data=> {:errorReport => params['errorReport']})
      render :nothing=> true
    else
      render :text=> params['errorReport']['message'].to_s, :status=> :error
    end
  end

end
