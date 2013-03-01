namespace :fog do
  desc 'loads available flavors into @flavors'
  task flavors: 'fog:compute' do
    @flavors = @compute.flavors
  end

  namespace :flavors do
    desc 'list flavors available'
    task list: 'fog:flavors' do
      puts 'ID %-32s VCPUs  Memory   Disk Ephemeral RXTX Public' % 'Name' if
        $stdout.tty?

      @flavors.each do |flavor|
        puts '%2d %-33s %4d %5dMB %4dGB %7dGB %4.1f %6s' % [
          flavor.id, flavor.name, flavor.vcpus, flavor.ram, flavor.disk,
          flavor.ephemeral, flavor.rxtx_factor, flavor.is_public
        ]
      end
    end
  end
end

