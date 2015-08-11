require 'rake'

WORKSPACE = 'ActorKit/ActorKit.xcworkspace'
SCHEME = 'ActorKitTests'
SDK = 'iphonesimulator'
COVERAGE_ARGS = 'GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES'
STRESS_TEST_ITERATIONS = 20

desc "Run the tests"
task :test do
  build_tests
  run_tests
end

desc "Run stress test"
task :stress_test do
	puts "Will perform #{STRESS_TEST_ITERATIONS} iterations"
  
  for i in 1..STRESS_TEST_ITERATIONS
  	puts "Running iteration #{i}"
  	run_tests
  end
end

desc "Generate coverage report"
task :coverage do
  run_coverage
end

task :default => [:test, :stress_test, :coverage]

private

def build_tests
  run_xctool('build-tests', WORKSPACE, SCHEME, SDK, COVERAGE_ARGS)
end

def run_tests
  run_xctool('run-tests', WORKSPACE, SCHEME, SDK)
end

def run_xctool(command, workspace, scheme, sdk, args='')
  sh("xctool #{command} -workspace #{workspace} -scheme #{scheme} -sdk #{sdk} ONLY_ACTIVE_ARCH=NO #{args}")
end

def run_coverage
  sh("slather")
end
