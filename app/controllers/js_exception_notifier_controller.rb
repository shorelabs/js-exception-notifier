class JsExceptionNotifierController < ApplicationController
  THROTTLE_MAX_RATE = 10.0          # Max 10 error reports from single user
  THROTTLE_DURATION = 240.0 * 60.0   # per 240*60 sec = 4 hour. Keep these values as floats.

  before_action :enforce_rate_limit
  # skip_before_action :verify_authenticity_token

  class JSException < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
      super(message)
    end
  end

  def javascript_error
    if defined?(ExceptionNotification) && Rails.env.production?

      data = {}
      data[:session] = session.keys.collect{ |k| {:k=> k, :v=> session[k]}.inspect } if session.loaded?
      data[:errorReport] = params['errorReport']

      error_message = params['errorReport'] ? params['errorReport']['message'].to_s : "no error report given"
      ExceptionNotifier.notify_exception(JSException.new(error_message), :data=> data)
      render json: {}, status: 200
    elsif Rails.env.test?
      render json: { status: 'OK', text: params['errorReport'].to_s }, status: 200
    else
      render json: { text: params['errorReport'].to_s }, status: 422
    end
  end

  private

  # Basic rate limiting
  # for inspiration see http://stackoverflow.com/questions/667508/whats-a-good-rate-limiting-algorithm
  def enforce_rate_limit
    allowance = (session[:js_exception_notifier_allowance] || THROTTLE_MAX_RATE).to_f
    last_error_at = (session[:js_exception_notifier_last_error_at] || Time.now).to_i

    current_time = Time.now.to_i
    time_passed = current_time - last_error_at
    session[:js_exception_notifier_last_error_at] = current_time

    allowance += time_passed * (THROTTLE_MAX_RATE / THROTTLE_DURATION)
    allowance = THROTTLE_MAX_RATE if allowance > THROTTLE_MAX_RATE

    if allowance < 1.0
      session[:js_exception_notifier_allowance] = allowance
      if Rails.env.production?
        render json: {}, status: 200
      else
        render json: { text: "You reached error limit!" }, status: 422
      end
    else
      session[:js_exception_notifier_allowance] = allowance - 1.0
    end
  end

end
