require 'rake'

WORKSPACE = 'ActorKit/ActorKit.xcworkspace'
SCHEME = 'ActorKitTests'
SDK = 'iphonesimulator'
DESTINATION = 'platform=iOS Simulator,name=iPhone 6'
COVERAGE_ARGS = 'GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES'

desc "Clean the workspace"
task :clean do
  clean_tests
end

desc "Build the workspace"
task :build do
  build_tests
end

desc "Run the workspace"
task :test do
  run_tests
end

desc "Generate coverage report"
task :coverage do
  run_coverage
end

task :default => [:build, :test]

private

def clean_tests
  run_xctool('clean', WORKSPACE, SCHEME, DESTINATION, SDK)
end

def build_tests
  run_xctool('build-tests', WORKSPACE, SCHEME, DESTINATION, SDK, COVERAGE_ARGS)
end

def run_tests
  run_xctool('run-tests', WORKSPACE, SCHEME, DESTINATION, SDK)
end

def run_xctool(command, workspace, scheme, destination, sdk, args='')
    sh("xctool #{command} -workspace #{workspace} -scheme #{scheme} -sdk #{sdk} -destination '#{destination}' ONLY_ACTIVE_ARCH=NO #{args}")
end

def run_coverage
  sh("slather")
end
