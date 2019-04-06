Pod::Spec.new do |s|
  s.name = 'PropertyKit'
  s.version = '1.1'
  s.license = 'MIT'
  s.swift_version = '5.0'
  s.summary = 'Protocol-First, Type and Key-Safe Swift Property for iOS, macOS and tvOS.'
  s.homepage = 'https://github.com/metasmile/PropertyKit'
  s.authors = { 'Taeho Lee' => 'lee@stells.co' }
  s.source = { :git => 'https://github.com/metasmile/PropertyKit.git', :tag => s.version }
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.source_files = 'Sources/**/*.swift'
end
