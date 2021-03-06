Pod::Spec.new do |s|
  s.name         = "DependencyInjection"
  s.version      = "2.0.2"
  s.summary      = "Microframework in Swift for dependency injection based on property wrappers."
  s.description  = <<-DESC
  DependencyInjection is a small framework that allows to register dependencies that resolve either to shared or new instances. Resolving is done either via `@Inject` and `@LazyInject` property wrappers or by calling `DIContainer.resolve()`.
DESC
  s.homepage     = "https://github.com/sebastianpixel/DependencyInjection"
  s.authors            = "Sebastian Pickl"
  s.social_media_url   = "https://twitter.com/SebastianPickl"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.swift_versions = "5.3"
  s.ios.deployment_target  = '9.0'
  s.osx.deployment_target  = '10.10'
  s.source       = { :git => "https://github.com/sebastianpixel/DependencyInjection.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/DependencyInjection/**/*.swift"
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/DependencyInjectionTests'
  end
end
