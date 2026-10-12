Pod::Spec.new do |s|
  s.name             = 'adaptive_video_player'
  s.version          = '2.0.0'
  s.summary          = 'Adaptive Video Player Flutter Plugin'
  s.description      = <<-DESC
Adaptive Video Player plugin for PiP and screen protection.
                       DESC
  s.homepage         = 'https://github.com/ahmedalam782/vidoes_player'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ahmed Mohamed Osman' => 'ahmedalam782@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'adaptive_video_player/Sources/adaptive_video_player/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
