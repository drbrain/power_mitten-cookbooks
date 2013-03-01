require 'json'

namespace :chef do
  namespace :node do
    desc 'Creates nodes/image.json'
    task image: %w[nodes/image.json chef:role:image]
  end
end

file 'nodes/image.json' => %w[fog:compute configuration:load] do
  definition = {
    'run_list' => %w[
      role[image]
    ]
  }

  open 'nodes/image.json', 'w' do |io|
    JSON.dump definition, io
  end
end

CLOBBER.add 'nodes/image.json'


