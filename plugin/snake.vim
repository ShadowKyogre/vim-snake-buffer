if exists('g:snake_buffer_loaded')
	finish
endif

let g:snake_buffer_loaded = 1
com! -nargs=1 SnakeBuffer call snake#SnakeBuffer(<f-args>, 0)
com! -nargs=1 SnakeBufferBClose call snake#SnakeBuffer(<f-args>, 1)
