def local_gem_package name
  File.join "..", name, "pkg", "#{name}.gem"
end

desc 'builds local gems'
task local_gems: 'configuration:load' do
  pwd = File.expand_path Dir.pwd

  local_gems = @configuration['local_gems']

  local_gems.each do |name|
    package = local_gem_package name

    cd "../#{name}" do
      sh $PROGRAM_NAME, '--silent', 'clean', 'package'

      package = Dir["pkg/#{name}*.gem"].first

      mv package, "#{pwd}/cookbooks/#{name}/files/default/#{name}.gem"
    end
  end
end

