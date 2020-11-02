
Pod::Spec.new do |s|
  s.name             = 'Annotations'
  s.version          = '0.9.4'
  s.summary          = 'Swift shape and text annotation component for macOS.'
  s.description      = <<-DESC
A component that can be used for apps providing visual annotation support of screenshots or other images.
The component supports free-hand drawing, text boxes as well as shape annotations via arrows or rectangles.
                       DESC

  s.homepage         = 'https://github.com/blackbeltlabs/Annotations'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mirko Kiefer' => 'mail@mirkokiefer.com' }
  s.source           = { :git => 'https://github.com/blackbeltlabs/Annotations.git', :tag => s.version.to_s }

  s.platform = :osx
  s.osx.deployment_target = "10.13"
  s.swift_version = "5.0"
  
  s.source_files = 'Annotations/Classes/**/*'
  s.resources = 'Annotations/Assets/Assets.xcassets'
end
