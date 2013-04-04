# Look for the yml files in a nested directory
CHANGE_ME::Application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

# set default locale to something other than :en
I18n.default_locale = :en_US

