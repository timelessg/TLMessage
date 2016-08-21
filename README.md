##Welcome to TLMessage

##TODO
>1·聊天历史记录数据库持久化
>
>2·群聊逻辑
>
>3·文件消息
>
>4·地理位置消息

##介绍
>只要是接触过融云IMKit的开发者想必都会有一种想砸键盘的冲动，其封闭性会限制大部分需求的实现。如果你需要使用IMLib来自己实现UI逻辑，不妨Clone下来这个轮子参考下。这个轮子我会一直维护，实现更多的功能，最终的目的是造一个开源的IMkit。


##特性
>1·接入融云IMLib，目前支持Text/Image/Voice三种消息
>
>2·支持发送状态提示，失败后可点击重发
>
>3·布局完全使用Masonry（AutoLayout）
>
>4·支持扩展面板扩展
>
>5·支持Emoji面板输入

##依赖框架
>FMDB SQLite持久化历史消息
>
>Masonry AutoLayout框架
>
>UITableView+FDTemplateLayoutCell cell自适应高度框架
>
>SDWebImage 只是用了UIImageView + WebCache

##使用说明
>克隆项目后，需要使用Cocoapods updte/install

##截图

![ScreenShot](https://github.com/timelessg/TLMessage/blob/master/ScreenShot/1.png?raw=true)