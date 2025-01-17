# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/verifications/version"

Gem::Specification.new do |s|
  s.name = "decidim-verifications"
  s.version = Decidim::Verifications.version
  s.authors = ["David Rodriguez"]
  s.email = ["deivid.rodriguez@riseup.net"]
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = "~> 3.3.0"

  s.summary = "Decidim verifications module"
  s.description = "Several verification methods for your decidim instance"
  s.license = "AGPL-3.0-or-later"

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  s.add_dependency "decidim-core", Decidim::Verifications.version

  s.add_development_dependency "decidim-admin", Decidim::Verifications.version
  s.add_development_dependency "decidim-dev", Decidim::Verifications.version
end
