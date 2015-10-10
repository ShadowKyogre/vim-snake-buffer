let s:wingroups = {}

function! snake#SnakeAdjust()
	if exists('w:snakegroup')
		let l:curwinno = winnr()
		let l:winnos = s:wingroups[w:snakegroup]
		let l:nitems = len(l:winnos)
		exec w:snakegroup . 'wincmd w'
		let l:cursorpos = getpos('.')

		let i = 1
		while i < l:nitems
			exec l:winnos[i] . 'wincmd w'
			setl noscb
			call setpos('.', l:cursorpos)
			
			let j = 0
			while j < i
				normal Ljzt
				let j = j + 1
			endwhile

			let i = i + 1
		endwhile

		let i = 0
		for l:winno in l:winnos
			setl scb
		endfor
		exe l:curwinno . 'wincmd w'
	endif
endfunction

function! snake#SnakeClose(closeOriginator)
	if exists('w:snakegroup')
		let l:snakegrouptmp = w:snakegroup
		let l:winnos = s:wingroups[l:snakegrouptmp]
		call reverse(l:winnos)
		for l:winno in l:winnos
			" always called last
			if l:winno == l:snakegrouptmp
				unlet s:wingroups[l:snakegrouptmp]
				unlet w:snakegroup
			endif
			if !a:closeOriginator && l:winno == l:snakegrouptmp
				continue
			endif
			exec l:winno . 'wincmd q'
		endfor
	endif
endfunction

function! snake#SnakeBuffer(count, forceNew)
	if exists('w:snakegroup')
		if a:forceNew
			call snake#SnakeClose(0)
		else
			return
		endif
	endif
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
		let i = i + 1
	endwhile

	let s:wingroups[l:winnos[0]] = l:winnos

	for l:winno in l:winnos
		" echo l:winno
		exec l:winno . 'wincmd w'
		setlocal scb
		let w:snakegroup = l:winnos[0]
	endfor
endfunction
