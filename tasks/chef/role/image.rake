require 'json'

namespace :chef do
  namespace :role do
    desc 'Creates roles/image.json'
    task image: 'roles/image.json'
  end
end

file 'roles/image.json' => %w[fog:compute configuration:load] do
  credentials = @configuration['extra_credentials']
  credentials = credentials.merge @fog_credentials

  definition = {
    'chef_type' => 'role',
    'json_class' => 'Chef::Role',

    'name' => 'image',
    'description' => 'image creation role',

    'default_attributes' => {
      'ruby_version' => @configuration['ruby_version'],
      'credentials' => credentials
    },

    'run_list' => @configuration['run_list'],
  }

  open 'roles/image.json', 'w' do |io|
    JSON.dump definition, io
  end
end

CLOBBER.add 'roles/image.json'

