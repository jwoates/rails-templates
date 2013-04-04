def get_file(name)
   File.read(File.expand_path(File.join(File.dirname(__FILE__), name)))
end

defaults = ["en_US", "de_DE"]

remove_file "README.rdoc"
remove_file "public/index.html"
remove_file "config/database.yml"
remove_file "config/locales/en.yml"

generate(:controller, "public")

route "root :to => 'public#index'"

initializer "load_config.rb", 'APP_CONFIG = HashWithIndifferentAccess.new YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]'
initializer "locale.rb", get_file("/support_files/locale.rb")
gsub_file "config/initializers/locale.rb", "CHANGE_ME", @app_name.camelize.gsub('-','')

inject_into_file "config/application.rb", :after => "require 'rails/all'" do "\nrequire 'pp'" end

defaults.each do |default|
  file "config/locales/defaults/#{default}.yml", get_file("/support_files/locale/defaults/#{default}.yml")
end
file 'config/locales/models/en_US.yml', get_file("/support_files/locale/defaults/en_US.yml")
file 'config/locales/views/en_US.yml', get_file("/support_files/locale/defaults/en_US.yml")
file 'config/config.yml', get_file("/support_files/default_config.yml")
file 'config/environments/staging.rb', get_file("/support_files/staging.rb")

file 'config/database.yml', get_file("/support_files/database.yml")
gsub_file "config/database.yml", "delete", @app_name.camelize.gsub('-','')

gsub_file "config/environments/staging.rb", "CHANGE_ME", @app_name.camelize.gsub('-','')

file 'README.md', get_file("/support_files/README.md")
gsub_file "README.md", "--project-name--", @app_name.camelize.gsub('-',' ')

addons = ['fonts.less', 'helpers.less']
css = ['animations.less', 'background-clip.less', 'background-size.less', 'border-radius.less', 'box-shadow.less', 'box-sizing.less', 'columns.less', 'flex-box.less', 'gradient.less', 'opacity.less', 'text-shadow.less', 'transform.less', 'transition.less']
functs = ['grid.less', 'timing.less']
(1..5).each do |a|
  get "https://raw.github.com/roundhouse/Beard.less/master/animation/animation#{a}.less", "app/assets/stylesheets/beard/animation/animation#{a}.less"
end
css.each do |c|
  get "https://raw.github.com/roundhouse/Beard.less/master/css3/#{c}", "app/assets/stylesheets/beard/css3/#{c}"
end
addons.each do |a|
  get "https://raw.github.com/roundhouse/Beard.less/master/addons/#{a}", "app/assets/stylesheets/beard/addons/#{a}"
end
functs.each do |f|
  get "https://raw.github.com/roundhouse/Beard.less/master/functions/#{f}", "app/assets/stylesheets/beard/functions/#{f}"
end
get 'https://raw.github.com/roundhouse/Beard.less/master/init.less', 'app/assets/stylesheets/beard/init.less'
file 'app/assets/stylesheets/app.less', "@import 'beard/init';"
gsub_file 'app/assets/stylesheets/application.css', 'require_tree .', 'require app.less'

get 'https://raw.github.com/andyet/ICanHaz.js/master/ICanHaz.min.js', 'vendor/assets/javascripts/ICanHaz.js'
get 'https://raw.github.com/pixelmatrix/uniform/master/jquery.uniform.min.js', 'vendor/assets/javascripts/uniform.js'
get 'https://raw.github.com/aFarkas/html5shiv/master/dist/html5shiv.js', 'vendor/assets/javascripts/html5shiv.js'


gsub_file "Gemfile", "gem 'sqlite3'\n\n\n", ""
gsub_file "Gemfile", /gem 'sass-rails.*\n/, "gem 'less-rails'\n  gem 'therubyracer'\n"
gem 'fb_graph'
gem 'mysql2'
gem 'squeel'
gem 'thin', :group => :development


if yes?("Will you need Active Admin?")
  gem 'activeadmin', '>= 0.5'
  get 'https://raw.github.com/gregbell/active_admin/master/lib/active_admin/locales/en.yml', 'config/locales/active_admin/en_US.yml'
  gsub_file 'config/locales/active_admin/en_US.yml', 'en:', 'en_US:'
else
  if yes?("Will you need pagination?")
    gem 'kaminari'
  end
end

git :init
append_file '.gitignore', 'config.yml'
git :add => "-A"
git :commit => "-a -m 'Initial commit'"

if yes?("Did you set up a repo already?")
  remote = ask("What is the remote url?")
  git :remote => "add origin #{remote}"
  git :push => "-u origin master"
  git :checkout => "-b front-end"
  git :push => "-u origin front-end"
  git :checkout => "-b staging"
  git :push => "-u origin staging"
  git :checkout => "-b develop"
  git :push => "-u origin develop"
end

say "\n\n\n\n\n\n\n\n\n\n"
say "+ -------------------------------------------------------- +"
say "|Roundhouse                                                |"
say "|                                                          |"
say "|              Great, now get to work Newb.                |"
say "|                                                          |"
say "|                                                Roundhouse|"
say "+ -------------------------------------------------------- +"
