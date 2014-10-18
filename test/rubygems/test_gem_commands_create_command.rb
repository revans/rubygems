require 'rubygems/test_case'
require 'rubygems/commands/create_command'

class TestGemCommandsCreateCommand < Gem::TestCase
  def setup
    super

    @cmd = Gem::Commands::CreateCommand.new
  end

  def test_execute
    @cmd.options[:args] = %w[foo]

    use_ui @ui do
      @cmd.execute
    end

    assert_equal "foo", @cmd.gem_name
    assert_equal "foo", @cmd.name
    assert_equal "foo", @cmd.target.basename.to_s
    assert_equal "create_gem", @cmd.template_dir.basename.to_s
    assert_equal "foo", @cmd.underscored_name
    assert_equal "foo", @cmd.namespaced_path
    assert_equal "Foo", @cmd.constant_name
    assert_equal ["Foo"], @cmd.constant_array
    assert_equal "", @cmd.user_name
    assert_equal "", @cmd.user_email


    assert_file "Gemfile" do |contents|
      assert_match "gemspec", contents
    end

    assert_file "MIT-LICENSE" do |contents|
      assert contents.include?(Time.now.year.to_s)
    end

    assert_file "README.md" do |contents|
      assert_match "Foo", contents
    end

    assert_file "Rakefile" do |contents|
      assert_match "foo.gemspec", contents
    end

    assert_file "foo.gemspec" do |contents|
      assert_match "'foo/version'", contents
      assert_match "Foo.version", contents
    end

    assert_file "test/test_helper.rb" do |contents|
      assert_match "require 'foo'", contents
    end

    assert_file "lib/foo.rb" do |contents|
      assert_match "require 'foo/version'", contents
    end

    assert_file "lib/foo/gem_version.rb" do |contents|
      expected_content = <<-EOF
module Foo
  module VERSION
    MAJOR = 0
    MINOR = 0
    TINY  = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].join(".")
  end

  def self.gem_version
    ::Gem::Version.new(VERSION::STRING)
  end
end
      EOF

      assert_equal expected_content, contents
    end

    assert_file "lib/foo/version.rb" do |contents|
      expected_content = <<-EOF
require_relative 'gem_version'

module Foo
  def self.version
    gem_version
  end
end
      EOF
      assert_equal expected_content, contents
    end
  end


  def assert_file(filename, &block)
    assert @cmd.target.join(filename).exist?
    yield(@cmd.target.join(filename).read) if block_given?
  end
end
