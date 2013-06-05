require 'json'

namespace :chef do
  namespace :role do
    desc 'Creates roles/image.json'
    task image: 'roles/image.json'
  end
end

file 'roles/image.json' => %w[fog:compute configuration:load] do
  extra_configuration = @configuration['extra_configuration']
  extra_configuration ||= {}

  credentials = @configuration['credentials']

  definition = {
    'chef_type' => 'role',
    'json_class' => 'Chef::Role',

    'name' => 'image',
    'description' => 'image creation role',

    'default_attributes' => {
      'ruby_version' => @configuration['ruby_version'],
      'credentials' => credentials,
      'extra_configuration' => extra_configuration,
    },

    'run_list' => @configuration['run_list'],
  }

  open 'roles/image.json', 'w' do |io|
    JSON.dump definition, io
  end
end

CLOBBER.add 'roles/image.json'

