Pod::Spec.new do |s|
  s.name         = 'SwiftyDropbox'
  s.version      = '6.0.3'
  s.summary      = 'Dropbox Swift SDK for API v2'
  s.homepage     = 'https://dropbox.com/developers/'
  s.license      = 'MIT'
  s.author       = { 'Stephen Cobbe' => 'scobbe@dropbox.com' }
  s.source       = { :git => 'https://github.com/dropbox/SwiftyDropbox.git', :tag => s.version }

  s.source_files = 'Source/SwiftyDropbox/Shared/**/*.{swift,h,m}'
  s.osx.source_files = 'Source/SwiftyDropbox/Platform/SwiftyDropbox_macOS/**/*.{swift,h,m}'
  s.ios.source_files = 'Source/SwiftyDropbox/Platform/SwiftyDropbox_iOS/**/*.{swift,h,m}'

  s.requires_arc = true
  s.swift_version = '5.0'

  s.osx.deployment_target = '10.11'
  s.ios.deployment_target = '9.0'

  s.osx.frameworks = 'AppKit', 'WebKit', 'SystemConfiguration', 'Foundation'
  s.ios.frameworks = 'UIKit', 'WebKit', 'SystemConfiguration', 'Foundation'

  s.dependency       'Alamofire', '~> 4.8.2'
end
