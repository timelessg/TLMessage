#use_frameworks!

platform :ios, '8.0'

#inhibit_all_warnings!

target "TLMessageView" do
	pod 'Masonry'
	pod 'MJRefresh'
	pod 'FMDB'
	pod 'RongCloudIMLib'
    pod 'UITableView+FDTemplateLayoutCell'
    pod 'SDWebImage'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
