require 'fog'
require 'yaml'

@compute = nil

def create_compute credential_name
  raise ArgumentError,
        "already initialized compute as #{@compute.current_tenant}" if
    @compute

  @compute =
    begin
      Fog.credential = credential_name
      Fog.credentials
      Fog::Compute[:OpenStack]
    end
end

fog_credential_path = File.expand_path '~/.fog'

fog_credentials = YAML.load_file fog_credential_path

namespace :fog do
  desc 'Checks if a fog credential was loaded, aborts if not'
  task :compute do
    abort <<-MESSAGE unless @compute
You must invoke a fog credentials task when using this recipe.  For example:

  rake fog:whatever ssh_key
    MESSAGE
  end

  namespace :cred do
    fog_credentials.each_key do |credential_name|
      desc "use #{credential_name} fog credentials"
      task credential_name do
        @fog_credentials = fog_credentials[credential_name.to_sym]
        create_compute credential_name
      end
    end
  end
end

