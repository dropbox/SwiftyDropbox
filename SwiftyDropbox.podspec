Pod::Spec.new do |s|
  s.name         = "SwiftyDropbox"
  s.version      = "0.8"
  s.summary      = "Dropbox Swift SDK for APIv2"
  s.homepage     = "https://dropbox.com/developers/"
  s.license      = "MIT"
  s.author       = { "Ryan Pearl" => "rpearl@dropbox.com" }
  s.source    = { :git => "https://github.com/dropbox/SwiftyDropbox.git", :tag => "0.8" }
  s.source_files = "Source/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.dependency "Alamofire", "~> 2.0.2"
end
