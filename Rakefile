require "bundler/gem_tasks" # build/install/release
require "open3"

desc "Run RSpec tests"
task :spec do
  sh "bundle exec rspec"
end

task default: :spec

desc "Clean generated files"
task :clean do
  rm_rf "pkg"
end

desc "Show current gem version"
task :version do
  require_relative "lib/my_last_cv/version"
  puts "Current version: #{MyLastCV::VERSION}"
end

# -------------------------
#  Preflight checks definitions
# -------------------------
def sh_capture(cmd)
  out, err, status = Open3.capture3(cmd)
  [out.strip, err.strip, status.success?]
end

def ensure_cmd_ok!(cmd, message)
  out, err, ok = sh_capture(cmd)
  abort("#{message}\n> #{cmd}\n#{out}\n#{err}") unless ok
  out
end

def file_changed?(path)
  out, _err, _ok = sh_capture("git status --porcelain -- #{path}")
  !out.empty?
end

def on_main_branch?
  out, _err, _ok = sh_capture("git rev-parse --abbrev-ref HEAD")
  %w[main master].include?(out)
end

def git_clean_working_tree?
  out, _err, _ok = sh_capture("git status --porcelain")
  out.empty?
end

def tag_exists?(tag)
  _out, _err, ok = sh_capture("git rev-parse -q --verify refs/tags/#{tag}")
  ok
end

desc "Preflight checks before releasing"
task :preflight do
  require_relative "lib/my_last_cv/version"
  version = MyLastCV::VERSION
  tag     = "v#{version}"

  # 1) Git clean
  abort("✖ Working tree not clean. Commit or stash your changes.") unless git_clean_working_tree?

  # 2) Not on master
  abort("✖ Not on main/master branch.") unless on_main_branch?

  # 3) Not existing tag
  abort("✖ Tag #{tag} already exists. Bump version before releasing.") if tag_exists?(tag)

  # 4) version.rb changed
  abort("✖ lib/my_last_cv/version.rb has uncommitted changes.") if file_changed?("lib/my_last_cv/version.rb")

  # 5) Valid Gemspec
  ensure_cmd_ok!("ruby -c my_last_cv.gemspec", "✖ Gemspec has Ruby syntax errors.")

  # 6) Bundle ok
  ensure_cmd_ok!("bundle check || bundle install", "✖ Bundler failed to install dependencies.")

  # 7) All tests pass
  Rake::Task[:spec].invoke

  puts "✓ Preflight passed for #{version} on #{`git rev-parse --abbrev-ref HEAD`.strip}"
end

desc "Safe release: preflight → build → push gem → git tag+push"
task :release_safe => [:preflight] do
  require_relative "lib/my_last_cv/version"
  version = MyLastCV::VERSION
  tag     = "v#{version}"

  # Build gem
  Rake::Task[:build].invoke

  # Push gem
  gem_file = Dir["pkg/*.gem"].find { |p| p.include?(version) } or abort("✖ Built gem not found in pkg/")
  sh "gem push #{gem_file}"

  # Tag + git push
  sh "git tag #{tag}"
  sh "git push origin #{tag}"
  sh "git push"

  puts "✅ Released #{version} (tag #{tag})"
end
