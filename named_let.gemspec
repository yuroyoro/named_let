# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "named_let/version"

Gem::Specification.new do |s|
  s.name        = "named_let"
  s.version     = NamedLet::VERSION
  s.authors     = ["Tomohito Ozaki"]
  s.email       = ["ozaki@yuroyoro.com"]
  s.homepage    = ""
  s.summary     = %q{named_let can be used to make the rspec's output easier to read.}
  s.description = %q{`named_let(:name){ obj }` changes the value which returns 'obj#to_s' and 'obj#inspect' to :name, then output of 'rspec -format d' be improved more readable.}

  s.rubyforge_project = "named_let"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # dependencies
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "rspec-core"
end
