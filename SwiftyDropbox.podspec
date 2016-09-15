Pod::Spec.new do |s|
  s.name         = "SwiftyDropbox"
  s.version      = "3.3.1"
  s.summary      = "Dropbox Swift SDK for API v2"
  s.homepage     = "https://dropbox.com/developers/"
  s.license      = "MIT"
  s.author       = { "Stephen Cobbe" => "scobbe@dropbox.com" }
  s.source    = { :git => "https://github.com/dropbox/SwiftyDropbox.git", :tag => s.version }
  s.osx.source_files = 'Source/SwiftyDropbox/SwiftyDropbox_macOS/SwiftyDropbox_macOS.h', 'Source/Source/PlatformNeutral/*.{h,m,swift}', 'Source/Source/PlatformDependent/macOS/*.{h,m,swift}'
  s.ios.source_files = 'Source/SwiftyDropbox/SwiftyDropbox/SwiftyDropbox.h', 'Source/Source/PlatformNeutral/*.{h,m,swift}', 'Source/Source/PlatformDependent/iOS/*.{h,m,swift}'
  s.requires_arc = true
  s.osx.deployment_target = "10.10"
  s.ios.deployment_target = "8.0"
  s.osx.frameworks = 'AppKit', 'Foundation'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.dependency "Alamofire", "~> 3.5"
end
