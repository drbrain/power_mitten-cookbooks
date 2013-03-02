namespace :chef do
  task :cook, %w[vm_name] => %w[
         configuration:load
         local_gems
         fog:vms] do |_, args|
    user = @configuration['image']['login_user']
    vm   = find_vm args[:vm_name]

    with_floating_ip vm do |address|
      wait_for_ssh vm, address, quiet: true
      run_knife %W[solo cook -V #{user}@#{address} nodes/image.json]
    end
  end
end
