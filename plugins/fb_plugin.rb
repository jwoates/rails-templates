FB_HELPERS = File.open("#{File.dirname(__FILE__)}/fb_helper.rb").read

create_file "app/helpers/fb_helpers.rb", "#{fetch_app_name("/app")}.helpers do\n#{FB_HELPERS}\nend"

require_dependencies 'fb_graph'

# fb_connection(app_id,app_secret) ***********************************************
  # => Create the initial FbGraph::Auth object
    # Params:
    # +app_id+:: String for the app id from facebook
    # +app_secret+:: String for the app secret from facebook

# fb_parse_data(fb) ***********************************************
  # => Parses the data either from the signed request or from the cookies depending on how the user is authenticated (javascript FB SDK or the Normal OAuth Flow)
    # Params:
    # +fb+:: FbGraph::Auth Object - From fb_connection

# fb_get_authorization(fb,redirect_uri,scope) ***********************************************
  # => Sets up the parameters for performing the Facebook Authentication - Used when doing a Normal OAuth Authentication
    # Params:
    # +fb+:: FbGraph::Auth Object - From fb_connection
    # +redirect_uri+:: URI to the location the user should return to after authentication
    # +scope+:: Hash that has the scope requirments for the facebook app Ex.

# fb_like(fb) ***********************************************
  # => Should be used to determine if the content has been liked. Currently only supports the page like status
    # Params:
    # +fb+:: FbGraph::Auth Object - From fb_parse_data