Pod::Spec.new do |s|
  s.name            = "GameSparks"
  s.summary         = "The Objective C SDK for the GameSparks platform"
  s.homepage        = "https://bitbucket.org/gamesparks/gamesparks-ios-sdk"
  s.license         = 'Apache License, Version 2.0'
  s.version         = '0.5.0'
  s.author          = { "GameSparks Ltd" => "info@gamesparks.com" }
  s.source          = { :git => "https://bitbucket.org/gamesparks/gamesparks-ios-sdk.git", :tag => "0.5.0", :branch => "master" }
  s.platform        = :ios, '6.0'
  s.requires_arc    = true
  s.frameworks      = 'UIKit'
  s.source_files    = '*.{h,m}'
end
