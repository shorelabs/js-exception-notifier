require 'test_helper'

class JsExceptionNotifierControllerTest < ActionController::TestCase
  
  def json_response
    ActiveSupport::JSON.decode @response.body
  end

  test "Should be a Module!" do
    assert_kind_of Module, JsExceptionNotifier
  end

  test 'Should be nil then initialized to constant!' do    
    assert_equal JsExceptionNotifierController::THROTTLE_MAX_RATE.to_i, cookies[:js_exception_notifier_allowance].to_i

    post :javascript_error
    assert_equal JsExceptionNotifierController::THROTTLE_MAX_RATE.to_i-1, cookies[:js_exception_notifier_allowance].to_i

    for i in 0..JsExceptionNotifierController::THROTTLE_MAX_RATE.to_i
      post :javascript_error
    end

    assert_equal 0, cookies[:js_exception_notifier_allowance].to_i
  end

  test 'Should not accept this parameter!' do
    post :javascript_error, errorMsg: 'error'
    assert_equal "old version not supported", json_response['text']
  end

  test 'Should return error desc!' do
    post :javascript_error, errorReport: 'Test Error'
    assert_equal "Test Error", json_response['text']
  end

  test 'Should return notice about error limit! ' do
    for i in 0..JsExceptionNotifierController::THROTTLE_MAX_RATE.to_i + 1
      post :javascript_error, errorReport: 'Test Error'
    end

    assert_equal "You reached error limit!", json_response['text']
  end 

  def setup
    @request.cookies[:js_exception_notifier_allowance] = JsExceptionNotifierController::THROTTLE_MAX_RATE.to_i  
  end

end
