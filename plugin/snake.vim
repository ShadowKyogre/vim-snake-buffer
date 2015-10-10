if exists('g:snake_buffer_loaded')
	finish
endif

let g:snake_buffer_loaded = 1
com! -nargs=1 -bang SnakeBuffer call snake#SnakeBuffer(<f-args>, <bang>0)
com! -nargs=?       SnakeToggle call snake#SnakeToggle(<f-args>)
com! -nargs=0       SnakeAdjust call snake#SnakeAdjust()
com! -nargs=0 -bang SnakeClose  call snake#SnakeClose(<bang>0)
