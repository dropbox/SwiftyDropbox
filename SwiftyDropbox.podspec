Pod::Spec.new do |s|
  s.name         = "SwiftyDropbox"
  s.version      = "3.0.0"
  s.summary      = "Dropbox Swift SDK for APIv2"
  s.homepage     = "https://dropbox.com/developers/"
  s.license      = "MIT"
  s.author       = { "Ryan Pearl" => "rpearl@dropbox.com" }
  s.source    = { :git => "https://github.com/dropbox/SwiftyDropbox.git", :tag => s.version }
  s.source_files = "Source/*.{h,m,swift}"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.dependency "Alamofire", "~> 3.1"
end
