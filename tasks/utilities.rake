##
# Cooks +server+ using knife solo cook

def cook server
  wait_for_server server

  with_floating_ip server do |address|
    wait_for_ssh server, address

    user = @configuration['image']['login_user']

    # This is knife stuff.  You can put any script after these lines
    run_knife %W[solo prepare #{user}@#{address}]
    puts 'VM prepared on %s' % server.name

#    run_knife %W[cook -V --skip-syntax-check root@#{address} nodes/upgrade.json]
#    puts 'chef upgraded to prerelease'

    run_knife %W[solo cook -V #{user}@#{address} nodes/image.json]
    puts 'VM cooked on %s' % server.name

    # This lets you SSH to the image and check it out for testing.  A ^C will
    # release the floating-ip, but not destroy the image.
    puts "VM built on #{address}, press return to continue"
    $stdin.gets
  end
end

##
# Creates an image called +name+ from +server+

def create_image server, name
  response = @compute.create_image server.id, 'gauntlet'
  image = @compute.images.get response.body['image']['id']

  image.wait_for do
    print '.'
    image.ready?
  end

  puts 'image %s created from %s' % [name, server.name]
end

##
# Creates a temporary server sending +params+ to Fog's
# <code>server.create</code>

def create_temporary_server **params
  server = @compute.servers.create params

  yield server
ensure
  server.destroy if server
end

##
# Runs knife for `knife cook` and `knife solo`

def run_knife args
  knife_command = Gem.default_exec_format % 'knife'

  ruby '-S', knife_command, *args
end

##
# Attempts to connect to +address+ on port 22.  Returns true if the connection
# succeeds.
#
# Used to wait for SSH to come up after OpenStack says the server is alive

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
# Waits for +server+ to boot

def wait_for_server server
  server.wait_for do
    print '.'

    # When there's an ERROR fog merrily continues to check for readiness even
    # when it will never happen.  Destroy the image and return the fault
    # instead.
    if server.state == 'ERROR' then
      server.destroy
      abort server.fault.inspect
    end

    ready?
  end

  puts 'server %s booted' % server.name
end

##
# Waits for +server+ to be accessible via SSH at +address+

def wait_for_ssh server, address
  server.wait_for do
    print '.'

    ssh_alive? address
  end

  puts
  puts 'server %s SSH accessible at %s' % [server.name, address]
end

##
# Attaches a floating IP to +server+ for the duration of a block and removes
# the floating IP when the block terminates.
#
# This prevents you from needing to clean up tens of floating IPs as you test
# out chef recipes

def with_floating_ip server
  service  = server.service
  response = service.allocate_address
  id       = response.body['floating_ip']['id']
  address  = response.body['floating_ip']['ip']

  begin
    server.associate_address address

    yield address

  ensure
    puts "Exception: #{$!}" if $!
    $stdin.gets if $!
    service.disassociate_address server.id, address
    service.release_address id
  end
end

