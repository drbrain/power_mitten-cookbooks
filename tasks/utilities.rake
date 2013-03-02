##
# Cooks +vm+ using knife solo cook

def cook vm
  wait_for_vm vm

  with_floating_ip vm do |address|
    wait_for_ssh vm, address

    user = @configuration['image']['login_user']

    # This is knife stuff.  You can put any script after these lines
    run_knife %W[solo prepare #{user}@#{address}]
    puts 'VM prepared on %s' % vm.name

#    run_knife %W[cook -V --skip-syntax-check root@#{address} nodes/upgrade.json]
#    puts 'chef upgraded to prerelease'

    run_knife %W[solo cook -V #{user}@#{address} nodes/image.json]
    puts 'VM cooked on %s' % vm.name

    # This lets you SSH to the image and check it out for testing.  A ^C will
    # release the floating-ip, but not destroy the image.
    puts "VM built on #{address}, press return to continue"
    $stdin.gets
  end
end

##
# Creates an image called +name+ from +vm+

def create_image vm, name
  response = @compute.create_image vm.id, 'gauntlet'
  image = @compute.images.get response.body['image']['id']

  image.wait_for do
    print '.'
    image.ready?
  end

  puts 'image %s created from %s' % [name, vm.name]
end

##
# Creates a temporary vm sending +params+ to Fog's
# <code>vm.create</code>

def create_temporary_vm **params
  vm = @compute.servers.create params

  yield vm
ensure
  vm.destroy if vm
end

##
# Finds a VM with +name+

def find_vm name
  abort "provide a vm name like for this task" unless name

  vm = @vms.find { |vm| name == vm.name }

  abort "unable to find vm #{name}, check fog:vms:list" unless vm

  vm
end

##
# Runs knife for `knife cook` and `knife solo`

def run_knife args
  knife_command = Gem.default_exec_format % 'knife'

  ruby '-S', knife_command, *args
end

##
# Attaches a floating ip to +vm+ as +user+ and runs SSH with the given
# +command+

def ssh vm, user, *command
  with_floating_ip vm do |address|
    wait_for_ssh vm, address, quiet: true

    system 'ssh', "#{user}@#{address}", *command
  end
end

##
# Attempts to connect to +address+ on port 22.  Returns true if the connection
# succeeds.
#
# Used to wait for SSH to come up after OpenStack says the address is alive

def ssh_alive? address
  socket = TCPSocket.open address, 22
rescue SystemCallError
ensure
  socket.close if socket
end

##
# Wrapper for Rake.application.trace, outputs +items+ only if rake tracing is
# enabled.

def trace *items
  Rake.application.trace(*items)
end

##
# Waits for +vms+ to boot in threads

def wait_for_vms vms
  vms.map do |vm|
    Thread.start do
      wait_for_vm vm
    end
  end.each do |thread|
    thread.join
  end
end

##
# Waits for +vm+ to boot

def wait_for_vm vm
  vm.wait_for do
    print '.'

    # When there's an ERROR fog merrily continues to check for readiness even
    # when it will never happen.  Destroy the image and return the fault
    # instead.
    if vm.state == 'ERROR' then
      vm.destroy
      abort vm.fault.inspect
    end

    ready?
  end

  puts 'VM %s booted' % vm.name
end

##
# Waits for +vm+ to be accessible via SSH at +address+

def wait_for_ssh vm, address, quiet: false
  vm.wait_for do
    print '.' unless quiet

    ssh_alive? address
  end

  return if quiet

  puts
  puts 'VM %s SSH accessible at %s' % [vm.name, address]
end

##
# Attaches a floating IP to +vm+ for the duration of a block and removes
# the floating IP when the block terminates.
#
# This prevents you from needing to clean up tens of floating IPs as you test
# out chef recipes

def with_floating_ip vm
  service  = vm.service
  response = service.allocate_address
  id       = response.body['floating_ip']['id']
  address  = response.body['floating_ip']['ip']

  begin
    vm.associate_address address

    yield address

  ensure
    service.disassociate_address vm.id, address
    service.release_address id
  end
end

