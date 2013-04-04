LOCALE_CONFIG = {
  :remote_directory => "https://raw.github.com/svenfuchs/rails-i18n/master/rails/locale/",
  :codes => [
    {:remote_code => 'en',    :code => 'en_US'},
    {:remote_code => 'en-GB', :code => 'en_GB'},
    {:remote_code => 'fr',    :code => 'fr_FR'},
    {:remote_code => 'de',    :code => 'de_DE'},
    {:remote_code => 'es',    :code => 'es_ES'},
    {:remote_code => 'nl',    :code => 'de_NL'},
    {:remote_code => 'en-CA', :code => 'en_CA'},
    {:remote_code => 'es-MX', :code => 'es_MX'},
    {:remote_code => 'en-GB', :code => 'en_IR'},
    {:remote_code => 'en-AU', :code => 'en_AU'}
  ]
}

def get_file(name)
   File.read(File.expand_path(File.join(File.dirname(__FILE__), name)))
end

def create_locale_defaults
  initializer "locale.rb", get_file("/support_files/locale.rb")
  gsub_file "config/initializers/locale.rb", "CHANGE_ME", @app_name.camelize.gsub('-','')

  #  ***********************************************
  #   FETCH THE STANDARD DEFAULTS FROM A REMOTE LOCATION PUTS THEM IN THE DEFAULTS DIRECTORY IN LOCALES       --- 11-08-2012
  # ***********************************************
  LOCALE_CONFIG[:codes].each do |locale|
    # puts "#{LOCALE_CONFIG[:remote_directory]}#{locale[:remote_code]}.yml"
    get "#{LOCALE_CONFIG[:remote_directory]}#{locale[:remote_code]}.yml", "config/locales/defaults/#{locale[:code]}.yml"
    gsub_file "config/locales/defaults/#{locale[:code]}.yml", "#{locale[:remote_code]}:", "#{locale[:code]}:"
  end

  #  ***********************************************
  #   CREATE DEFAULT VIEW YMLS FOR EACH LOCALE       --- 11-08-2012
  # ***********************************************
  LOCALE_CONFIG[:codes].each do |locale|
    file "config/locales/views/#{locale[:code]}.yml", get_file("support_files/locale/en.yml")
    gsub_file "config/locales/views/#{locale[:code]}.yml", "# Sample localization file for English. Add more files in this directory for other locales.\n# See https://github.com/svenfuchs/rails-i18n/tree/master/rails%2Flocale for starting points.\n", "# View Translations for locale #{locale[:code]}"
    gsub_file "config/locales/views/#{locale[:code]}.yml", "en:", "#{locale[:code]}:"
    gsub_file "config/locales/views/#{locale[:code]}.yml", "Hello world", "Hello #{locale[:code]}"
  end
  remove_file "config/locales/en.yml"

end

def add_active_admin?
  if yes?("Will you need Active Admin?")
    gem 'activeadmin', '>= 0.5'
    get 'https://raw.github.com/gregbell/active_admin/master/lib/active_admin/locales/en.yml', 'config/locales/active_admin/en_US.yml'
    gsub_file 'config/locales/active_admin/en_US.yml', 'en:', 'en_US:'
  else
    if yes?("Will you need pagination?")
      gem 'kaminari'
    end
  end
end


def auth_stage
  un = ask('Enter a username for stage:')
  pass = ask('Enter a password for stage:')

  inject_into_file 'app/controllers/application_controller.rb', :after => "protect_from_forgery" do
  <<-eos



  # Add authentication to the stage and prod environments
  before_filter :authenticate

  def authenticate
    if Rails.env == 'staging' && !is_facebook?(request.remote_ip)
      authenticate_or_request_with_http_basic do |username, password|
        username == "#{un}" && password == "#{pass}"
      end
    end
  end

  def is_facebook?(_ip)
    require "ipaddr"
    low  = IPAddr.new("66.220.144.0").to_i
    high = IPAddr.new("66.220.159.255").to_i
    ip   = IPAddr.new(_ip).to_i
    (low..high)===ip
  end
  eos
  end

end

def add_gems?
  if yes?("Would you like to add gems?")
    gemname = ""
    say "Type the name of the gem and hit enter, type 'done' when finished..."
    while gemname != "done"
      gemname = ask("")
      if gemname != "done"
        gem gemname
      else
        say "Ok, gems added."
        if yes?("Want to run bundle install?")
          run 'bundle install'
        end
      end
    end
  end
end


def add_application_authentication
  if yes?("Want to use devise?")
    # authentication and authorization
    gem "devise"
    gem "cancan"

    # authentication and authorization setup
    generate "devise:install"

    devise_user_model = ask("What model do you want to use for your devise users?")
    devise_user_model = "User" unless devise_user_model != ""

    generate "devise #{devise_user_model}"
    generate "devise:views"

    rake "db:migrate"
    generate "cancan:ability"
  end
end

def initialize_git_repo
  git :init
  append_file '.gitignore', <<-eos
config.yml
/.bundle
/vendor/bundle
/vendor/bundle/*
/.rvmrc
.tm_properties
.DS_Store
eos
  git :add => '-A'
  git :commit => "-am 'Initial Commit'"
end


#  ***********************************************
#   START TEMPLATE      --- 11-08-2012
# ***********************************************

# Application config file for storing secret API keys and other private config data.
file 'config/config.yml', get_file("/support_files/default_config.yml")
initializer "load_config.rb", 'APP_CONFIG = HashWithIndifferentAccess.new YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]'

# Adding staging environment config
file 'config/environments/staging.rb', get_file("/support_files/staging.rb")
gsub_file "config/environments/staging.rb", "CHANGE_ME", @app_name.camelize.gsub('-','')

# Application server for development
gem 'thin', :group => :development

gem_group :development, :test do
  gem "rspec-rails"
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'faker'
end

generate("rspec:install")

# create locale files for internationalization
create_locale_defaults


# Lock the stage environment down for only people with the UN/PASS
auth_stage

# Add 'pp' for printing objects to the terminal
inject_into_file "config/application.rb", :after => "require 'rails/all'" do "\nrequire 'pp'" end


# prep DB for developmemnt
run 'cp config/database.yml config/database.example'
remove_file 'config/database.yml'
file 'config/database.yml', get_file("/support_files/database.yml")
gsub_file "config/database.yml", "delete", app_name.camelize.gsub('-','')
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'

# Propmt for active admin
add_active_admin?

# Adding application authentication and roles
# add_application_authentication

# create rvmrc file
create_file ".rvmrc", "rvm default@#{app_name} --create"

# create tm_properties file
create_file ".tm_properties", "projectDirectory = '$CWD'"

initialize_git_repo

say <<-eos



+ -------------------------------------------------------- +
|Roundhouse                                                |
|                                                          |
|              Great, now get to work Newb.                |
|                                                          |
|                                                Roundhouse|
+ -------------------------------------------------------- +
eos