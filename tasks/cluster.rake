namespace :cluster do
  desc 'checks the cluster configuration'
  task check_configuration: %w[
         configuration:load
         fog:flavors] do
    cluster = @configuration['cluster']

    missing_flavors = cluster.select do |node_definition|
      node_name   = node_definition['name']
      flavor_name = node_definition['flavor']

      @flavors.none? { |flavor| flavor.name == flavor_name }
    end

    unless missing_flavors.empty? then
      message = missing_flavors.sort_by { |node_definition|
        node_definition['name']
      }.map { |node_definition|
        flavor_name, name = node_definition.values_at 'flavor', 'name'
        "\tflavor #{flavor_name} missing for #{name}"
      }.join "\n"

      abort "missing flavors:\n#{message}"
    end
  end

  desc 'attach to the cluster console'
  task console: %w[
         configuration:load
         cluster:start] do
    user = @configuration['image']['login_user']

    console = @vms.find { |vm| /\Agauntlet_console-\d+\z/ =~ vm.name }

    abort 'unable to find console, did you start the cluster?' unless console

    ssh console, user, 'sh', '-l', '-c', 'gauntlet_console'
  end

  desc 'create a shell on [vm_name]'
  task :shell, %w[vm_name] => %w[
         configuration:load
         fog:vms] do |_, args|
    user = @configuration['image']['login_user']
    vm   = find_vm args[:vm_name]

    ssh vm, user
  end

  desc 'shut down the cluster'
  task shutdown: %w[
         configuration:load
         fog:vms] do
    cluster = @configuration['cluster']

    cluster.each do |node_definition|
      name = node_definition['name']

      name_regexp = /\A#{Regexp.escape name}-\d+\z/

      @vms.each do |vm|
        next unless name_regexp =~ vm.name

        vm.destroy
      end
    end
  end

  desc 'starts the cluster'
  task start: %w[
         configuration:load
         cluster:check_configuration
         fog:images:create
         fog:vms] do
    cluster         = @configuration['cluster']
    image_name      = @configuration['image']['name']
    security_groups = @configuration['security_groups'].keys

    cluster.each do |node_definition|
      name, flavor_name, total =
        node_definition.values_at 'name', 'flavor', 'count'

      name_regexp = /\A#{Regexp.escape name}-(?<count>\d+)\z/

      running = @vms.select { |vm| name_regexp =~ vm.name }

      needed = total - running.size

      next if needed <= 0

      puts "launching #{needed} of #{name} (#{flavor_name})"

      flavor = @flavors.find { |flavor| flavor.name == flavor_name }
      image  = @images.find { |image| image.name == image_name }

      highest = running.max_by { |vm|
        name_regexp =~ vm.name
        Integer count
      } || 0

      vms = needed.times.map do |offset|
        vm_name = "#{name}-#{offset + highest}"
        puts "launching #{vm_name}"

        @compute.servers.create \
          name:            vm_name,
          image_ref:       image.id,
          flavor_ref:      flavor.id,
          key_name:        @ssh_key_name,
          security_groups: security_groups
      end

      wait_for_vms vms
    end
  end

end

