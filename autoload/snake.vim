let s:wingroups = {}

function! snake#SnakeToggle(...)
	if exists('w:snakegroup')
		call snake#SnakeClose(0)
	else
		if a:0 == 0
			call snake#SnakeBuffer(snake#SnakeGuess(), 0)
		else
			call snake#SnakeBuffer(a:1, 0)
		endif
	endif
endfunction

function! snake#SnakeGuess()
	let l:maxwidth = &columns
	let l:longestlineln = max(map(range(1, line('$')), "col([v:val, '$'])")) - 1
	let l:colwidth = l:longestlineln+&numberwidth+&foldcolumn
	let l:maxforlinewidth = l:maxwidth / l:colwidth
	let curpos = getpos('.')
	let tmpcurpos = curpos
	let lastline = getpos('$')[1]
	let screenfuls = -1
	while curpos[1] != lastline
		let prevpos = curpos
		normal Ljzt
		let curpos = getpos('.')
		if curpos[1] != prevpos[1]
			let screenfuls = screenfuls + 1
		endif
	endwhile
	call setpos('.', tmpcurpos)

	" echo l:screenfuls l:maxforlinewidth

	if l:screenfuls < l:maxforlinewidth
		return l:screenfuls
	else
		return l:maxforlinewidth
	endif
endfunction

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
			exe l:winno . 'wincmd w'
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
