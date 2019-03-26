Pod::Spec.new do |s|
  s.name         = "OfficeUIFabric"
  s.version      = "0.1.14"
  s.summary      = "Office UI Fabric is a set of reusable UI controls and tools"
  s.homepage     = "https://github.com/OfficeDev/ui-fabric-ios"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Microsoft" => "vladf@microsoft.com" }

  s.platform     = :ios
  s.ios.deployment_target = "11.0"
  s.swift_version = "4.2"

  s.source       = { :git => "https://github.com/OfficeDev/ui-fabric-ios", :tag => "#{s.version}" }
  s.source_files = "OfficeUIFabric/**/*.{swift,h}"
  s.resources    = "OfficeUIFabric/**/*.{storyboard,xib,ttf,xcassets,strings,stringsdict,json}"
end
