Pod::Spec.new do |s|
  s.name = 'MixedObject'
  s.version = '1.0.1'
  s.license = 'MIT'
  s.summary = 'A flexible Swift Decodable solution for handling mixed-type JSON decoding'
  s.homepage = 'https://github.com/mithyer/MixedObject'
  s.authors = { 'Ray' => 'brightmar@gmail.com' }
  s.source = { :git => 'https://github.com/mithyer/MixedObject.git', :tag => s.version }
  s.documentation_url = 'https://github.com/mithyer/MixedObject/'

  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5']
  s.source_files = 'Source/**/*.swift'
  s.frameworks = 'Foundation'
end