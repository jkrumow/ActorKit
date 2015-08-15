Pod::Spec.new do |s|
  s.name             = "ActorKit"
  s.version          = "0.4.0"
  s.summary          = "A lightweight actor framework in Objective-C."
  s.description      = <<-DESC
                       Brings the actor model to Objective-C.

                       * Actors
                       * Actor Pools
                       * Synchronous and asynchronous invocations
                       * Message subscription and publication
                       * Actor registry
                       DESC
  s.homepage         = "https://github.com/tarbrain/ActorKit"
  s.license          = 'MIT'
  s.author           = { "Julian Krumow" => "julian.krumow@tarbrain.com" }

  s.ios.deployment_target = '5.0'
  s.watchos.deployment_target = '2.0'
  s.osx.deployment_target = '10.7'

  s.requires_arc = true
  s.source = { :git => "https://github.com/tarbrain/ActorKit.git", :tag => s.version.to_s }
  
  s.default_subspec = 'Core'
  s.subspec 'Core' do |core|
    core.source_files = 'Pod/Core'
  end

  s.subspec 'Futures' do |futures|
    futures.source_files = 'Pod/Futures'
    futures.dependency 'ActorKit/Core'
  end
end
