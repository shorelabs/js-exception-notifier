require 'test_helper'

class JsExceptionNotifierControllerTest < ActionController::TestCase
  test 'Action should return success' do
    post :javascript_error, :errorMsg=> 'Something wrong happened', :data => {:error => 'Something wrong happened', :file=> 'File Path', :line=> '12345', :browser=> 'Your favourite browser'}
    assert_response :success
  end
end
