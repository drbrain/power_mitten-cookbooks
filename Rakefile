rake_command = $PROGRAM_NAME

local_gems = []
local_gem_names = %w[
  att-cloud_gauntlet
  att-swift
  RingyDingy
  rdoc
]

def local_gem_package name
  File.join "..", name, "pkg", "#{name}.gem"
end

local_gem_names.each do |name|
  package = local_gem_package name

  task package do
    pwd = File.expand_path Dir.pwd

    cd "../#{name}" do
      sh rake_command, "clean", "package"

      package = Dir["pkg/#{name}*.gem"].first

      mv package, "#{pwd}/cookbooks/#{name}/files/default/#{name}.gem"
    end
  end

  local_gems << package
end

task build: local_gems

