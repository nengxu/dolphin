require 'rails/generators'

class Dolphin::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)

  def setup
    target = "bin/dolphin"
    copy_file "dolphin", target
    # make it executable
    chmod(target, 0755)
    puts "Now edit #{target}  to adjust deployment settings\nThen run bin/dolphin to deploy."
  end

end
