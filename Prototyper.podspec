Pod::Spec.new do |s|
  s.name             = 'Prototyper'
  s.version          = '0.9.6'
  s.summary          = 'Framework to mix prototypes and real apps.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The Prototyper framework allows you to create a mix between app prototypes and real apps.
                       DESC

  s.homepage         = 'https://github.com/grafele/Prototyper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stefan Kofler' => 'grafele@gmail.com' }
  s.source           = { :git => 'https://github.com/grafele/Prototyper.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/kofse'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Prototyper/Classes/**/*'
  s.resources = 'Prototyper/Assets/*' 
 
  # s.resource_bundles = {
  #   'Prototyper' => ['Prototyper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'NSHash', '~> 1.1'
  s.dependency 'SSZipArchive', '~> 1.6'
  s.dependency 'GCDWebServer', '~> 3.3'
  s.dependency 'jot', '~> 0.1.5'
  s.dependency 'KeychainSwift', '~> 7.0'

end
