require 'ipaddr'

namespace :fog do
  desc 'loads avaliable vms into @vms'
  task vms: %w[fog:compute] do
    @vms = @compute.servers
  end

  namespace :vms do
    desc 'list running VMs'
    task list: %w[fog:vms fog:flavors] do
      puts '%-35s %-10s %15s %15s' %
        %w[VM\ Name Flavor Public\ IP Private\ IP] if $stdout.tty?

      @vms.sort_by { |vm| vm.name }.each do |vm|
        flavor    = @flavors.find { |flavor| flavor.id == vm.flavor['id'] }
        addresses = vm.addresses.values.flatten.map { |address|
          IPAddr.new address['addr']
        }

        private_network = IPAddr.new '10.0.0.0/8'
        private_addrs, public_addrs = addresses.partition { |address|
          private_network.include? address
        }

        puts '%-35s %-10s %15s %15s' % [
          vm.name, flavor.name,
          private_addrs.first, public_addrs.first
        ]
      end
    end

    desc 'list running VM IDs'
    task list_ids: %w[fog:vms] do
      puts '%-41s %s' % %w[VM\ Name ID] if $stdout.tty?

      @vms.sort_by { |vm| vm.name }.each do |vm|
        puts '%-41s %s' % [vm.name, vm.id]
      end
    end
  end
end
