Pod::Spec.new do |s|
  s.name         = 'SwiftyDropboxObjC'
  s.version      = '10.0.0-beta.3'
  s.summary      = 'Objective-C Wrapper for Dropbox Swift SDK for API v2'
  s.homepage     = 'https://dropbox.com/developers/'
  s.license      = 'MIT'
  s.author       = { 'Stephen Cobbe' => 'scobbe@dropbox.com' }
  s.source       = { :git => 'https://github.com/dropbox/SwiftyDropbox.git', :tag => s.version }

  s.source_files = 'Source/SwiftyDropboxObjC/Shared/**/*.{swift,h,m}'
  s.osx.source_files = 'Source/SwiftyDropboxObjC/Platform/SwiftyDropbox_macOS/**/*.{swift,h,m}'
  s.ios.source_files = 'Source/SwiftyDropboxObjC/Platform/SwiftyDropbox_iOS/**/*.{swift,h,m}'

  s.requires_arc = true
  s.swift_version = '5.6'

  s.osx.deployment_target = '10.13'
  s.ios.deployment_target = '11.0'

  s.osx.frameworks = 'AppKit', 'WebKit', 'SystemConfiguration', 'Foundation'
  s.ios.frameworks = 'UIKit', 'WebKit', 'SystemConfiguration', 'Foundation'

  s.dependency 'SwiftyDropbox', '~> 10.0.0-beta.3'
end
