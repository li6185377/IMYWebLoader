# IMYWebLoader

支持对 UIWebView/WKWebView 的资源， 进行 预加载、缓存、拦截 等操作 ... Orz

### 屁话
UIWebView 缓存控制这块本身很弱，几乎无法用系统API 来完成我们的扩展，于是大家找到了 NSURLProtcol 来进行缓存或者拦截的操作， 总体来说还是满足了大家的需求

iOS8 除了WKWebView 之后更是连 NSURLProtocol 都不支持了，还好 WebKit 是开源的，大家通过搜索发现了 通过注册 CustomScheme，来拦截相应scheme的请求，于是大家进行了 http、https 的拦截

但是由于 WebKit 源码的限制，request body 永远都没法互相传递，

通过大量尝试，使用 fishhook，hook c++虚函数，均已失败告终 最终放弃了在 Native 层的拦截

突然有一天...

突然想到 前端的 post body 请求，大都都是通过 XMLHttpRequest 来请求的，为何我不能在 JS 层去 hook 呢？ （还在使用 from 表单的，就让它去屎吧）


懒得写 readme ... 了

### 功能

- 支持对 UIWebView/WKWebView 的数据缓存
- 支持 WKWebView 带 request body 的 AJAX 请求
- 支持断网后阅读
- 支持预加载方法，直接解析 html，提前下载其中的静态资源
- 支持功能实现替换，没写死，都使用协议编程
- ...

### 参考

- [WKWebView 那些坑](https://mp.weixin.qq.com/s/rhYKLIbXOsUJC_n6dt9UfA)<br/>
- [WebKit::WKCustomProtocolLoader](https://github.com/WebKit/webkit/blob/11c7bf06fa29f362a5ebd620bca4b703dc7f733a/Source/WebKit2/UIProcess/Cocoa/LegacyCustomProtocolManagerClient.mm#L51)
- [让 WKWebView 支持 NSURLProtocol](https://blog.yeatse.com/2016/10/26/support-nsurlprotocol-in-wkwebview)
- [Hook-Ajax](https://github.com/wendux/Ajax-hook)