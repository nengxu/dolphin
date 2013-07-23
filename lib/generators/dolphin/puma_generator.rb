require 'rails/generators'

class Dolphin::PumaGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def setup
    target = "config/puma.rb"
    copy_file "puma.rb", target
    puts "Now edit #{target} to adjust settings for Puma"
  end

end
