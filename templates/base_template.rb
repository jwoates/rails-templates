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

project :test => :rspec, :orm => :activerecord, :renderer => :erb, :script => :jquery
require_dependencies 'rack', :version => '1.3.5'
gsub_file 'Gemfile', "gem 'rake'", "gem 'rake', '0.8.7'"
run_bundler
run_bundler
generate :admin

inject_into_file "config/boot.rb", ROUTE_HELPERS, :after => "Padrino.before_load do"

rake "ar:migrate"

rake "seed"

