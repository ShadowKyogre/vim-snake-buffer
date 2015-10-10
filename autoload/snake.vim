function! snake#SnakeBuffer(count, closeAll)
	let l:startoffset = &scrolloff
	" let l:winh = winheight(0)
	let l:winnos = []
	call add(l:winnos, winnr())
	set so=0 noscb
	let i = 1
	while i <= a:count
		botright vsplit
		" let l:gohere=l:winh*i
		" echo l:gohere
		normal Ljzt
		call add(l:winnos, winnr())
		let i=i+1
	endwhile

	for l:winno in l:winnos
		" echo l:winno
		exec l:winno . 'wincmd w'
		setlocal scb
		if a:closeAll
			cabbrev <buffer> q bdelete
		endif
	endfor
endfunction
