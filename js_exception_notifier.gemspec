$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "js_exception_notifier/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "js_exception_notifier"
  s.version     = JsExceptionNotifier::VERSION
  s.authors     = ["Zbigniew Zemla", "Blazej Hadzik"]
  s.email       = ["zbyszek@shorelabs.com","b.hadzik@shorelabs.com"]
  s.homepage    = "http://kanbantool.com"
  s.summary     = "JSExceptionNotifier for KanbanTool"
  s.description = "Exception notifier for Javascript errors"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"
  s.add_dependency "exception_notification"
end
