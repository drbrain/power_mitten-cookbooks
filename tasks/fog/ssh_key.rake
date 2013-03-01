namespace :fog do
  namespace :ssh_keys do
    desc 'list SSH keys'
    task list: 'fog:compute' do
      @compute.key_pairs.each do |key_pair|
        puts "%-30s %s" % [key_pair.name, key_pair.fingerprint]
      end
    end

    desc 'Create SSH key if it does not exist'
    task create: %w[configuration:load fog:compute] do
      ssh_key = @configuration['ssh_key']
      abort 'Only specify public SSH keys (.pub)' unless
        ssh_key.end_with? '.pub'

      ssh_key_name = File.basename ssh_key, '.pub'
      @ssh_key_name = ssh_key_name.sub(/_(dsa|ecdsa|rsa)$/, '')

      unless @compute.key_pairs.any? { |pair| pair.name == @ssh_key_name } then
        public_key = File.read SSH_KEY

        key_pair =
          @compute.key_pairs.new name: @ssh_key_name, public_key: public_key

        key_pair.save
      end
    end
  end
end

