Pod::Spec.new do |s|
	s.name = 'IMYWebLoader'
	s.version = '0.1'
	s.description = 'Web resources loading by Prefetch/Cache/Hook, Support UIWebView/WKWebView ... Orz'
	s.license = 'MIT'
	s.summary = '支持对 UIWebView/WKWebView 的资源， 进行 预加载、缓存、拦截 等操作 ... Orz'
	s.homepage = 'https://github.com/li6185377/IMYWebLoader'
	s.authors = { 'ljh' => '137249466@qq.com' }
	s.source = { :git => 'https://github.com/li6185377/IMYWebLoader', :tag => s.name }
	s.requires_arc = true
	s.ios.deployment_target = '7.0'

	s.source_files = 'Sources/Private/**/*.{h,m}', 'Sources/Public/**/*.{h,m}'
	s.resources = 'Sources/Resources/**/*.{js}'

	s.weak_frameworks = 'JavaScriptCore', 'WebKit'
	
	s.dependency 'XMLDictionary'
end