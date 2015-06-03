Pod::Spec.new do |s|
  s.name         = "SwiftyDropbox"
  s.version      = "0.2"
  s.summary      = "Dropbox Swift SDK for APIv2"
  s.homepage     = "https://dropbox.com/developers/"
  s.license      = "MIT"
  s.author       = { "Ryan Pearl" => "rpearl@dropbox.com" }
  s.source_files = "Source/*.swift"
  s.requires_arc = true
  s.ios.deployment_target = "8.0"
  s.dependency "Alamofire", "~> 1.2.0"
end
