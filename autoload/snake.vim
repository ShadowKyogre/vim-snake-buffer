let s:wingroups = {}

function! snake#SnakeDetach(forceQuit)
	" echo s:wingroups
	if exists('w:snakegroup')
		unlet s:wingroups[w:snakegroup][-1]
		if len(s:wingroups[w:snakegroup]) == 0
			unlet s:wingroups[w:snakegroup]
			cuna <script> <silent> <buffer> q
			cuna <script> <silent> <buffer> quit
		endif
	endif
	" echo s:wingroups

	if (a:forceQuit)
		quit!
	else
		quit
	endif
endfunction

function! snake#SnakeToggle(useTextWidth, ...)
	"if exists('a:1')
	"	echo a:useTextWidth a:0 a:1
	"else
	"	echo a:useTextWidth a:0
	"endif
	if exists('w:snakegroup')
		call snake#SnakeClose(0)
	else
		if a:0 == 0
			call snake#SnakeBuffer(snake#SnakeGuess(a:useTextWidth), 0)
		else
			call snake#SnakeBuffer(a:1, 0)
		endif
	endif
endfunction

function! snake#SnakeVisibleLines(start, end)
	let result=0
	let i=a:start

	while (i <= a:end)
	if foldclosed(i) > 0
		let i = foldclosedend(i)+1
		continue
		endif
		let i+=1
		let result += 1
	endw
	return result
endfunction

function! snake#SnakeGuess(useTextWidth)
	let l:maxwidth = winwidth(0)
	let l:height = winheight(0)
	if a:useTextWidth
		let l:colwidth = &textwidth+&numberwidth+&foldcolumn
	else
		let l:longestlineln = max(map(range(1, line('$')), "col([v:val, '$'])")) - 1
		let l:colwidth = l:longestlineln+&numberwidth+&foldcolumn
	endif
	let l:maxforlinewidth = (l:maxwidth / l:colwidth) - 1
	let lastline = getpos('$')[1]
	let visilines = snake#SnakeVisibleLines(1, lastline)
	let screenfuls = visilines / l:height
	let screenfulsasf = (visilines + 0.0) / l:height

	if screenfuls != screenfulsasf
		let screenfuls = screenfuls+1
	endif

	" echo l:screenfuls l:maxforlinewidth

	if l:screenfuls < l:maxforlinewidth && l:screenfuls >= 1
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
				cuna <script> <silent> <buffer> q
				cuna <script> <silent> <buffer> quit
			endif
			if !a:closeOriginator && l:winno == l:snakegrouptmp
				continue
			endif
			exec l:winno . 'wincmd q'
		endfor
	endif
endfunction

function! snake#SnakeBuffer(count, forceNew)
	if a:count == 0 && !a:forceNew
		return
	endif
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
	cabbrev <script> <silent> <buffer> q SnakeDetach
	cabbrev <script> <silent> <buffer> quit SnakeDetach
	set so=0 noscb
	let i = 1
	while i <= a:count
		belowright vsplit
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
