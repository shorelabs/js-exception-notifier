class JsExceptionNotifierController < ApplicationController
  THROTTLE_MAX_RATE = 10.0          # Max 10 error reports from single user
  THROTTLE_DURATION = 240.0 * 60.0   # per 240*60 sec = 4 hour. Keep these values as floats.

  before_filter :discard_meaningless_reports, :enforce_rate_limit

  class JSException < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
      super(message)
    end
  end

  def javascript_error
    if defined?(ExceptionNotification) && Rails.env.production?
      ExceptionNotifier.notify_exception(JSException.new(params['errorReport']['message'].to_s), :data=> {:errorReport => params['errorReport']})
      render :nothing=> true
    else
      render json: { text: params['errorReport'].to_s }, status: 200
    end
  end

  private

  # Discards meaningless reports from old version of JSExceptionNotifier
  def discard_meaningless_reports
    render json: { text: 'old version not supported' }, status: 200 if params.include?('errorMsg')
  end

  # Basic rate limiting
  # for inspiration see http://stackoverflow.com/questions/667508/whats-a-good-rate-limiting-algorithm
  def enforce_rate_limit
    allowance = cookies[:js_exception_notifier_allowance].to_i || THROTTLE_MAX_RATE.to_i
    last_error_at = cookies[:js_exception_notifier_last_error_at].to_i || Time.now.to_i

    current_time = Time.now.to_i
    time_passed = current_time - last_error_at
    cookies[:js_exception_notifier_last_error_at] = current_time

    allowance += time_passed * (THROTTLE_MAX_RATE.to_i / THROTTLE_DURATION.to_i)
    allowance = THROTTLE_MAX_RATE.to_i if allowance > THROTTLE_MAX_RATE.to_i

    if allowance < 1.0
      cookies[:js_exception_notifier_allowance] = allowance
      render json: { text: "You reached error limit!" }, status: 200
    else
      cookies[:js_exception_notifier_allowance] = allowance - 1.0
      # raise cookies[:js_exception_notifier_allowance].inspect
    end
  end

end
