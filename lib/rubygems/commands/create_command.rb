require 'rubygems/command'
require 'erb'
require 'fileutils'
require 'pathname'
require 'time'

class Gem::Commands::CreateCommand < Gem::Command
  attr_reader :target, :template_dir, :gem_name, :name, :underscored_name, :namespaced_path, :constant_name, :constant_array, :user_name, :user_email

  def initialize
    super 'create',
          'Create a new RubyGem skeleton'
  end

  def arguments # :nodoc:
    "GEMNAME     name of your new rubygem"
  end

  def description # :nodoc:
    <<-EOF
        The create command creates the gem structure needed to create a new
        RubyGem.
    EOF
  end

  def usage # :nodoc:
    "#{program_name} GEMNAME"
  end

  def execute
    formatter
    template "Gemfile.tt", "Gemfile"
    template "MIT-LICENSE.tt", "MIT-LICENSE"
    template "README.tt", "README.md"
    template "Rakefile.tt", "Rakefile"
    template "newgem.gemspec.tt", "#{underscored_name}.gemspec"
    template "test/helper.rb.tt", "test/test_helper.rb"
    template "lib/newgem.rb.tt", "lib/#{underscored_name}.rb"
    template "lib/newgem/gem_version.rb.tt", "lib/#{underscored_name}/gem_version.rb"
    template "lib/newgem/version.rb.tt", "lib/#{underscored_name}/version.rb"

    say "New gem created..."
  end




  def template(source, destination)
    source      = template_dir.join(source)
    destination = target.join(destination)
    content     = ::ERB.new(source.binread, nil, "-", "@output_buffer").result(binding)

    ::FileUtils.mkdir_p(destination.dirname)
    ::File.open(destination.to_s, "wb") { |f| f.write content }
  end


  def formatter
    @gem_name         = get_one_gem_name
    @name             = gem_name.chomp("/")
    @target           = ::Pathname.pwd.join(name)
    @template_dir     = ::Pathname.new(__dir__).join("../templates/create_gem")
    @underscored_name = name.tr('-', '_')
    @namespaced_path  = name.tr('-', '/')
    @constant_name    = name.split('_').map { |p| p[0..0].upcase + p[1..-1] }.join
    @constant_name    = @constant_name.split('-').map{|q| q[0..0].upcase + q[1..-1] }.join('::') if @constant_name =~ /-/
    @constant_array   = constant_name.split('::')
    @user_name        = `git config user.name`.chomp || "TODO: Write your name"
    @user_email       = `git config user.email`.chomp || "TODO: Write your email address"
  end


  attr_accessor :output_buffer
  private :output_buffer, :output_buffer=

  def concat(string)
    @output_buffer.concat(string)
  end

  def capture(*args, &block)
    with_output_buffer { block.call(*args) }
  end

  def with_output_buffer(buff = "")
    self.output_buffer, old_buffer = buf, output_buffer
    yield
    output_buffer
  ensure
    self.output_buffer = old_buffer
  end

end
