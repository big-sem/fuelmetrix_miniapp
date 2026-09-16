#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fuelmetrix_miniapp.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fuelmetrix_miniapp'
  s.version          = '0.0.1'
  s.summary          = 'Embeds the fuelmetrix native mini app inside a host Flutter app.'
  s.description      = <<-DESC
Embeds the fuelmetrix mini app (wallet, refuel, purchase history, QPay)
inside a host Flutter app as a native PlatformView.
                       DESC
  s.homepage         = 'https://github.com/big-sem/fuelmetrix_miniapp'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'fuelmetrix' => 'noreply@fuelmetrix.example' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # The vendor's mini app SDK — compiled .xcframework only, no source.
  # Bundled directly in this package so a host app gets it just by adding
  # fuelmetrix_miniapp as a pub.dev dependency; no separate pod/install
  # step on the host side.
  s.vendored_frameworks = 'MiniNativeLib.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'fuelmetrix_miniapp_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
