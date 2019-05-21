
Pod::Spec.new do |s|
  s.name             = 'Annotations'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Annotations.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/blackbeltlabs/Annotations'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mirko Kiefer' => 'mail@mirkokiefer.com' }
  s.source           = { :git => 'https://github.com/blackbeltlabs/Annotations.git', :tag => s.version.to_s }

  s.platform = :osx
  s.osx.deployment_target = "10.13"
  s.swift_version = "4.2"
  
  s.dependency 'TextAnnotation', '0.1.1'

  s.source_files = 'Annotations/Classes/**/*'
end
