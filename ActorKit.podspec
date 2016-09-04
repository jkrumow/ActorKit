Pod::Spec.new do |s|
  s.name             = "ActorKit"
  s.version          = "0.55.0"
  s.summary          = "A lightweight actor framework in Objective-C."
  s.description      = <<-DESC
                       Brings the actor model to Objective-C.

                       * Actors
                       * Actor Pools
                       * Synchronous and asynchronous invocations
                       * Promises
                       * Notification subscription and publication
                       * Supervision
                       * Linking
                       DESC
  s.homepage         = "https://github.com/jkrumow/ActorKit"
  s.license          = 'MIT'
  s.author           = { "Julian Krumow" => "julian.krumow@bogusmachine.com" }

  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.9'

  s.requires_arc = true
  s.source = { :git => "https://github.com/jkrumow/ActorKit.git", :tag => s.version.to_s }
  
  s.default_subspec = 'Core'
  s.subspec 'Core' do |core|
    core.source_files = 'Pod/Core'
  end

  s.subspec 'Supervision' do |supervision|
    supervision.source_files = 'Pod/Supervision'
    supervision.dependency 'ActorKit/Core'
  end

  s.subspec 'Promises' do |promises|
    promises.source_files = 'Pod/Promises'
    promises.dependency 'ActorKit/Core'
    promises.dependency 'PromiseKit/CorePromise', '~> 3.0'
  end
end
