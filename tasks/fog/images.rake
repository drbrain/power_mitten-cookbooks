namespace :fog do

  desc 'loads available images into @images'
  task images: 'fog:compute' do
    @images = @compute.images
  end

  namespace :images do
    desc 'list images available'
    task list: 'fog:images' do
      puts '%-71s  Ready' % 'Image Name' if $stdout.tty?

      @images.each do |image|
        puts '%-72s %-5s' % [image.name, image.ready?]
      end
    end

    desc 'creates an image from config.yaml'
    task create: %w[
           configuration:load
           chef:role:image
           fog:flavors
           fog:images
           fog:security_groups:create
           fog:ssh_keys:create] do
      image_configuration = @configuration['image']
      image_flavor = image_configuration['flavor'] || 'm1.tiny'
      image_name   = image_configuration['name']
      image_parent = image_configuration['parent']

      next if @images.find do |image| image.name == image_name end

      fog_image = @images.find do |image| image.name == image_parent end
      abort 'Unable to find %p in images' % image_parent unless fog_image

      trace "using image #{fog_image.name} (#{fog_image.id})"

      fog_flavor = @flavors.find do |flavor| flavor.name == image_flavor end
      abort 'Unable to find %p in flavors' % image_flavor unless fog_flavor

      trace "using flavor #{fog_flavor.name} (#{fog_flavor.id})"

      create_temporary_server(
        name:            image_configuration['name'],
        image_ref:       fog_image.id,
        flavor_ref:      fog_flavor.id,
        key_name:        @ssh_key_name,
        security_groups: @configuration['security_groups'].keys) do |server|
        trace "booting #{server.name} (#{server.id})"

        cook server

        create_image server, image_name
      end
    end
  end
end

