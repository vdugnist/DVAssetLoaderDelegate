#
# Be sure to run `pod lib lint DVAssetLoaderDelegate.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DVAssetLoaderDelegate'
  s.version          = '0.3.1'
  s.summary          = 'Delegate for loading resources for AVAsset.'
  s.description      = <<-DESC
This pod can help you play and cache AVAsset data with one request.
                       DESC

  s.homepage         = 'https://github.com/vdugnist/DVAssetLoaderDelegate'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vdugnist' => 'vdugnist@gmail.com' }
  s.source           = { :git => 'https://github.com/vdugnist/DVAssetLoaderDelegate.git', :tag => s.version.to_s }
  s.social_media_url = 'https://fb.com/vdugnist'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DVAssetLoaderDelegate/Classes/**/*'
  s.frameworks = 'AVFoundation', 'MobileCoreServices', 'SystemConfiguration'
end
