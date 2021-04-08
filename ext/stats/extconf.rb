require 'mkmf'
$CFLAGS << ' -O3 -mtune=native -march=native'

create_makefile 'sunburst/stats'
