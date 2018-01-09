Gem::Specification.new do |s|
  s.name               = "Xpt"
  s.version            = "0.2.0"
  s.default_executable = "Xpt"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johannes Ulander"]
  s.date = %q{2017-05-23}
  s.description = %q{A simple read/create xpt file metadata gem}
  s.email = %q{johannes.ulander@gmail.com}
#  s.files = ["Rakefile", "lib/hola.rb", "lib/hola/translator.rb", "bin/hola"]
#  s.files = ["lib/xpt.rb", "lib/xpt/read.rb"]
  s.files = ["lib/xpt.rb", "lib/xpt/read_data.rb", "lib/xpt/read_meta.rb", "lib/xpt/read_supp_meta.rb", "lib/xpt/create_data.rb", "lib/xpt/create_meta.rb"]
  s.homepage = %q{http://rubygems.org/gems/}
  s.license       = "Nonstandard"
  s.require_paths = ["lib"]
#  s.rubygems_version = %q{1.6.2}
  s.summary = %q{Xpt!}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
