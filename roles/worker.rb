name 'worker'
description 'Runs a ruby process from a queue'

run_list \
  'recipe[ruby_build]',
  'recipe[worker]'

