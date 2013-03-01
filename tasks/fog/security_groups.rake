namespace :fog do
  desc 'loads available security groups into @security_groups'
  task security_groups: 'fog:compute' do
    @security_groups = @compute.security_groups
  end

  namespace :security_groups do
    desc 'Creates and updates security groups from the configuration'
    task create: %w[configuration:load fog:security_groups] do
      required_groups = @configuration['security_groups']

      required_groups.each do |name, rules|
        fog_group = @security_groups.find do |group|
          group.name == name
        end

        fog_group ||=
          @compute.security_groups.create name: name, description: name

        rules.each do |rule|
          protocol = rule['protocol']
          cidr     = rule['cidr']
          from     = rule['from'] || -1
          to       = rule['to']   || -1

          match = fog_group.rules.find do |fog_rule|
            fog_rule['ip_protocol']        == protocol and
              fog_rule['from_port']        == from     and
              fog_rule['to_port']          == to       and
              fog_rule['ip_range']['cidr'] == cidr
          end

          next if match

          fog_group.create_security_group_rule from, to, protocol, cidr
        end
      end
    end

    desc 'lists available security groups and their rules'
    task list: 'fog:security_groups' do
      puts '%-20s %-55s' % %w[Name Description] if $stdout.tty?
      @security_groups.each do |security_group|
        puts '%-20s %-55s' % [security_group.name, security_group.description]
        puts '  Protocol     From    To Address' if $stdout.tty?
        security_group.rules.each do |rule|
          puts '  %-11s %5d %5d %s' % [
            rule['ip_protocol'], rule['from_port'], rule['to_port'],
            rule['ip_range']['cidr']
          ]
        end
      end
    end
  end
end

