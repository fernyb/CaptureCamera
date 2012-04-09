# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capture_camera/version"

Gem::Specification.new do |s|
  s.name        = "capture_camera"
  s.version     = CaptureCamera::VERSION
  s.authors     = ["Fernando Barajas"]
  s.email       = ["fernyb@fernyb.net"]
  s.homepage    = ""
  s.summary     = %q{Take a photo from the macbook camera}
  s.description = %q{Take a photo from the macbook camera}

  s.rubyforge_project = "capture_camera"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extensions    = ["ext/extconf.rb"]
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
