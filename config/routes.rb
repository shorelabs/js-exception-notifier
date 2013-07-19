Rails.application.routes.draw do
  match 'js_exception_notifier' => 'js_exception_notifier#javascript_error', :via=> [:post]
end
