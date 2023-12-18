# frozen_string_literal: true

require_relative 'lib/cron_calc/version'

Gem::Specification.new do |spec|
  spec.name = 'cron_calc'
  spec.version = CronCalc::VERSION
  spec.authors = ['Jakub Miziński']
  spec.email = ['jakubmizinski@gmail.com']

  spec.summary = 'calculates cron job occurrences'
  spec.description = 'calculates cron job occurrences within a specified period'
  spec.homepage = 'https://github.com/mizinsky/cron_calc'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/mizinsky/cron_calc'
  spec.metadata['changelog_uri'] = 'https://github.com/mizinsky/cron_calc/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'rspec', '~> 3.12'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
