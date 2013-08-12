class JsExceptionNotifierController < ApplicationController
  THROTTLE_MAX_RATE = 10.0          # Max 10 error reports from single user
  THROTTLE_DURATION = 60.0 * 60.0   # per 60*60 sec = 1 hour. Keep these values as floats.

  before_filter :discard_meaningless_reports, :enforce_rate_limit

  class JSException < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
      super(message)
    end
  end

  def javascript_error
    if defined?(ExceptionNotification)
      ExceptionNotifier.notify_exception(JSException.new(params['errorReport']['message'].to_s), :data=> {:errorReport => params['errorReport']})
      render :nothing=> true
    else
      if Rails.env.match('development')
        render :text=> params['errorReport']['message'].to_s, :status=> :error
      else
        render :nothing=> true
      end
    end
  end

  private

  # Discards meaningless reports from old version of JSExceptionNotifier
  def discard_meaningless_reports
    render :nothing=> true and return if params.include?('errorMsg')
  end

  # Basic rate limiting
  # for inspiration see http://stackoverflow.com/questions/667508/whats-a-good-rate-limiting-algorithm
  def enforce_rate_limit
    allowance = session[:js_exception_notifier_allowance] || THROTTLE_MAX_RATE
    last_error_at = session[:js_exception_notifier_last_error_at] || Time.now.to_i

    current_time = Time.now.to_i
    time_passed = current_time - last_error_at
    session[:js_exception_notifier_last_error_at] = current_time

    allowance += time_passed * (THROTTLE_MAX_RATE / THROTTLE_DURATION)
    allowance = THROTTLE_MAX_RATE if allowance > THROTTLE_MAX_RATE

    if allowance < 1.0
      session[:js_exception_notifier_allowance] = allowance
      render :nothing=> true
    else
      session[:js_exception_notifier_allowance] = allowance - 1.0
    end
  end

end
