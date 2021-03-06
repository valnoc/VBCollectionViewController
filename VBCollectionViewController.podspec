#
# Be sure to run `pod lib lint MyLib.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "VBCollectionViewController"
  s.version          = "0.4.1"
  s.summary          = "VBCollectionViewController extends UICollectionViewController by adding pagination, pull-to-refresh and other useful features."
  s.description      = <<-DESC
VBCollectionViewController extends UICollectionViewController by adding pagination, pull-to-refresh and other useful features.

VBCollectionViewCell is a base class for cells. Each cell contains only apporpriate VBCollectionViewCellView as a subview. The idea is to setup UI of VBCollectionViewCellView by setting its item property (which calls updateUI).

VBCollectionViewHeader uses the same idea as VBCollectionViewCell.
                       DESC
  s.homepage         = "https://github.com/valnoc/VBCollectionViewController"
  s.license          = 'MIT'
  s.author           = { "Valeriy Bezuglyy" => "valnocorner@gmail.com" }
  s.source           = { :git => "https://github.com/valnoc/VBCollectionViewController.git", :tag => "v#{s.version}" }

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files = 'VBCollectionViewController/**/*{.h,.m}'

  s.dependency 'WZProtocolInterceptor', '~> 0.1'
  s.dependency 'VBException', '~> 1.0'
  s.dependency 'VBAutolayout', '~> 2.0'
  s.dependency 'UIKit+VBProgrammaticCreation', '~> 1.0'

end
