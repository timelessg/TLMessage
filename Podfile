#use_frameworks!

platform :ios, '8.0'

#inhibit_all_warnings!

target "TLMessageView" do
	pod 'Masonry'
	pod 'RongCloudIMLib'
    pod 'UITableView+FDTemplateLayoutCell', '~> 1.6'
    pod 'SDWebImage'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
