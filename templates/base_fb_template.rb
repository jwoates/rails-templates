# my_template.rb

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

FB_HELPERS = File.open("#{PLUGIN_DIR}/fb_helper.rb").read

project :test => :rspec, :orm => :activerecord, :renderer => :erb, :script => :jquery
require_dependencies 'fb_graph'
require_dependencies 'rack', :version => '1.3.5'
gsub_file 'Gemfile', "gem 'rake'", "gem 'rake', '0.8.7'"
run_bundler
generate :admin
generate :model, "user fb_id:string name:string locale:string email:string"
inject_into_file 'db/migrate/002_create_users.rb',"      t.timestamps\n",:after => "t.string :locale\n"
generate :controller, "users get:index get:new post:new"

rake "ar:migrate"

generate :admin_page, "user"

inject_into_file "config/boot.rb", ROUTE_HELPERS, :after => "Padrino.before_load do"
create_file "app/helpers/fb_helpers.rb", "#{fetch_app_name("/app")}.helpers do\n#{FB_HELPERS}\nend"

rake "seed"