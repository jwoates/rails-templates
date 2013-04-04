# my_template.rb

shell.say "================================================================="
shell.say "If you don't know any of the following, just leave it blank"
shell.say "================================================================="


APP_ID = shell.ask "App ID:"
APP_SECRET = shell.ask "App Secret:"
FB_PAGE = shell.ask "Facebook Page:"
MAIN_IMAGE = shell.ask "Main CITWI Image URL:"
LIKE_GATE = shell.ask "Like Gate Image URL:"
BODY_TEXT = shell.ask "Body Text:"
LEGAL_TEXT = shell.ask "Legal Text:"

PLUGIN_DIR = "#{File.dirname(__FILE__)}".gsub('templates', 'plugins') + '/plugin_templates'

ROUTE_HELPERS = <<-HELP

  def match(path, opts={}, &block)
    get(path, opts, &block)
    post(path, opts, &block)
  end

  def base_uri
    base_uri_raw = request.env["HTTP_HOST"]+request.env["SCRIPT_NAME"]
    path = URI.parse(request.env["REQUEST_URI"]).path
    base_uri = "http://"+base_uri_raw.split(path)[0]
  end

  def curr_path
    base_uri_raw = request.env["HTTP_REFERER"]
  end
HELP

FB_CREDS = <<-CREDS

  configure :development do
    FB_APP_SECRET = '#{APP_SECRET}'
    FB_APP_ID = '#{APP_ID}'
    FB_PAGE = '#{FB_PAGE}'
  end

  configure :production do
    FB_APP_SECRET = '#{APP_SECRET}'
    FB_APP_ID = '#{APP_ID}'
    FB_PAGE = '#{FB_PAGE}'
  end

  match '/' do
    redirect '/entries'
  end

CREDS

MAIN_ROUTE = <<-MAINROUTE

      if params[:signed_request] then @like = like(params[:signed_request]) else @like = true end
      if @like then render :public, :layout => :layout else render :like_gate end
MAINROUTE

NEW_ROUTE = <<NEW_ROUTE

    content_type :json,  :charset => 'utf-8'
    entry = Entry.find_by_fb_id(params[:fb_id])
    unless entry
      entry = Entry.create(params)
      {:message => 'user added', :id => entry.id}.to_json
    else
      {:message => 'entry already exists', :id => entry.id}.to_json
    end
NEW_ROUTE

RAKEFILE = <<-RAKEFILE
require File.dirname(__FILE__) + '/config/boot.rb'
require 'thor'
require 'padrino-core/cli/rake'

PadrinoTasks.init
RAKEFILE

AR_CONFIG = <<-AR_CONFIG
postgres = URI.parse(ENV['DATABASE_URL'] || '')
ActiveRecord::Base.configurations[:production] = {
  :adapter  => 'postgresql',
  :encoding => 'utf8',
  :database => postgres.user,
  :username => postgres.user,
  :password => postgres.password,
  :host     => postgres.host
}
AR_CONFIG

FB_HELPERS = File.open("#{PLUGIN_DIR}/fb_helper.rb").read

JAVASCRIPT = File.open("#{PLUGIN_DIR}/citwi/application.js").read

project :test => :rspec, :orm => :activerecord, :renderer => :erb, :script => :jquery

require_dependencies 'fb_graph', 'heroku'
gsub_file 'Gemfile', "gem 'rake'", "gem 'rake', '0.8.7'"
require_dependencies 'rack', :version => '1.3.5'
append_file("Gemfile", "\n# Heroku\ngroup :production do\n gem 'pg'\n gem 'thin'\n gem 'newrelic_rpm'\nend")

run_bundler

create_file "app/helpers/fb_helpers.rb", "#{fetch_app_name("/app")}.helpers do\n#{FB_HELPERS}\nend"
create_file "app/views/layouts/layout.erb", File.open("#{PLUGIN_DIR}/citwi/layout.erb").read
create_file "app/views/public.erb", File.open("#{PLUGIN_DIR}/citwi/public.erb").read
create_file "app/views/like_gate.erb", File.open("#{PLUGIN_DIR}/citwi/like_gate.erb").read
create_file "public/stylesheets/screen.css", File.open("#{PLUGIN_DIR}/citwi/screen.css").read
create_file "Rakefile", RAKEFILE

generate :admin
generate :model, "entry fb_id:string name:string locale:string email:string"
generate :controller, "entries get:index post:new"

inject_into_file 'db/migrate/002_create_entries.rb',"      t.timestamps\n",:after => "t.string :locale\n"
inject_into_file 'app/app.rb',FB_CREDS,:after => "enable :sessions\n\n"
inject_into_file 'public/javascripts/application.js', JAVASCRIPT, :after => "// Put your application scripts here"
inject_into_file "config/boot.rb", ROUTE_HELPERS, :after => "Padrino.before_load do"
inject_into_file "app/controllers/entries.rb", MAIN_ROUTE, :after => "get :index do"
inject_into_file "app/controllers/entries.rb", NEW_ROUTE, :after => "post :new do"

gsub_file 'db/seeds.rb', 'shell.ask "Which email do you want use for logging into admin?"', '"dev@roundhouseagency.com"'
gsub_file 'db/seeds.rb', 'shell.ask "Tell me the password to use:"', '"form like voltron"'
gsub_file 'app/controllers/entries.rb', 'get :index', 'match :index'
gsub_file "config/database.rb", /^.+production.*\{(\n\s+\:.*){2}\n\s\}/, AR_CONFIG

rake "ar:migrate"

generate :admin_page, "entry"

gsub_file "app/views/public.erb", 'MAIN_IMAGE', MAIN_IMAGE if MAIN_IMAGE
gsub_file "app/views/public.erb", 'BODY_TEXT', BODY_TEXT if BODY_TEXT
gsub_file "app/views/public.erb", 'LEGAL_TEXT', LEGAL_TEXT if LEGAL_TEXT
gsub_file "app/views/like_gate.erb", 'LIKE_GATE', LIKE_GATE if LIKE_GATE

rake "seed"

shell.say "================================================================="
shell.say "All Finished, now run these commands from inside your app dir
to deploy the app"
shell.say "================================================================="

shell.say "git init"
shell.say 'git add .'
shell.say 'git commit -m"init"'
shell.say "heroku create"
shell.say "git push heroku master"
shell.say "heroku rake ar:migrate"
shell.say "heroku rake seed"
shell.say "heroku addons:add ssl:piggyback"

shell.say "================================================================="
shell.say "Last but not least, make sure you update the tab URL :)"
shell.say "================================================================="






