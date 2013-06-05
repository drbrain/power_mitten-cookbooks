require 'yaml'

namespace :configuration do
  desc 'loads configuration from config.yaml into @configuration'
  task load: %w[config.yaml] do
    c = YAML.load_file 'config.yaml'

    abort 'config.yaml seems empty' unless c

    def c.[] key
      return super if include? key

      abort 'could not find key %p in config.yaml' % key
    end

    c['ssh_key'] = File.expand_path c['ssh_key']

    abort "could not find SSH key at #{c['ssh_key']}" unless
      File.exist? c['ssh_key']

    @configuration = c
  end

  task show: 'configuration:load' do
    require 'pp'
    pp @configuration
  end
end

