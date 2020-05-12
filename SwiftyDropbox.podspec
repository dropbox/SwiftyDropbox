Pod::Spec.new do |s|
  s.name         = 'SwiftyDropbox'
  s.version      = '5.1.0'
  s.summary      = 'Dropbox Swift SDK for API v2'
  s.homepage     = 'https://dropbox.com/developers/'
  s.license      = 'MIT'
  s.author       = { 'Stephen Cobbe' => 'scobbe@dropbox.com' }
  s.source       = { :git => 'https://github.com/dropbox/SwiftyDropbox.git', :tag => s.version }

  # A work-around to exclude an import needed when using the Swift Package Manager
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '-DCOCOAPODS_IN_USE'
  }

  s.source_files = 'Source/SwiftyDropbox/Swift/Shared/**/*.{swift,h,m}', 'Source/SwiftyDropbox/ObjectiveC/**/*.{h,m}', 'Source/SwiftyDropbox/Includes/*.h'
  s.osx.source_files = 'Source/SwiftyDropbox/Swift/Platform/SwiftyDropbox_macOS/**/*.{swift}'
  s.ios.source_files = 'Source/SwiftyDropbox/Swift/Platform/SwiftyDropbox_iOS/**/*.{swift}'

  s.requires_arc = true
  s.swift_version = '4.2'

  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.0'

  s.osx.frameworks = 'AppKit', 'WebKit', 'SystemConfiguration', 'Foundation'
  s.ios.frameworks = 'UIKit', 'WebKit', 'SystemConfiguration', 'Foundation'

  s.dependency       'Alamofire', '~> 4.8.2'
end
