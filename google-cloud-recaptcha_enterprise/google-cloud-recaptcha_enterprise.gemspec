# -*- ruby -*-
# encoding: utf-8
require File.expand_path("../lib/google/cloud/recaptcha_enterprise/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "google-cloud-recaptcha_enterprise"
  gem.version       = Google::Cloud::RecaptchaEnterprise::VERSION

  gem.authors       = ["Google LLC"]
  gem.email         = "googleapis-packages@google.com"
  gem.description   = "google-cloud-recaptcha_enterprise is the official library for reCAPTCHA Enterprise API."
  gem.summary       = "API Client library for reCAPTCHA Enterprise API"
  gem.homepage      = "https://github.com/googleapis/googleapis"
  gem.license       = "Apache-2.0"

  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files -- lib/*`.split("\n") +
                      ["README.md", "AUTHENTICATION.md", "LICENSE", ".yardopts"]
  gem.require_paths = ["lib"]

  gem.required_ruby_version = ">= 2.4"

  gem.add_dependency "google-gax", "~> 1.8"
  gem.add_dependency "grpc-google-iam-v1", "~> 0.6.9"

  gem.add_development_dependency "minitest", "~> 5.10"
  gem.add_development_dependency "redcarpet", "~> 3.0"
  gem.add_development_dependency "google-style", "~> 1.24.0"
  gem.add_development_dependency "simplecov", "~> 0.9"
  gem.add_development_dependency "yard", "~> 0.9"
end
