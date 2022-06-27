pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--main
function _init()
	state=0
	create_stars()
end

function _update60()
	if state==0 then
		updt_title()
	elseif state==1 then
	 updt_game()
	elseif state==2 then
	 updt_gameover()
	end
end

function _draw()
	if (state==0) draw_title()
	if (state==1) draw_game()
	if (state==2) draw_gameover()
end
-->8
--functions

--box collision pos
function abs_box(s)
	box={}
	box.x1 = s.box.x1 + s.x
	box.x2 = s.box.x2 + s.x
	box.y1 = s.box.y1 + s.y
	box.y2 = s.box.y2 + s.y
	return box
end

--detect collision
function coll(a,b)

	box_a = abs_box(a)
	box_b = abs_box(b)
	
	if box_a.x1 > box_b.x2
	or box_a.y1 > box_b.y2
	or box_a.x2 < box_b.x1
	or box_a.y2 < box_b.y1 then
		return false
	else
		return true
	end
end

-- horizontal text center
function h_txt_cntr(str)
	return 64-#str*2
end

-- vertical text center
function v_txt_cntr()
	return 61
end
-->8
--state functions

-- ** title **
function updt_title()
	if (btn(❎)) init_game()
end

function draw_title()
	cls()
	ttlstr="the recycler"
	strtstr="press ❎/x to start"
	print(
		ttlstr,
		h_txt_cntr(ttlstr),
		10,
		7
	)
	print(
		strtstr,
		h_txt_cntr(strtstr),
		v_txt_cntr()+40,
		6
	)
end

-- ** game **
function init_game()
	t=0
	score=0
	bullets={}
	enemies={}
	init_plyr()
	state=1
end

function updt_game()
	t+=1
	
	updt_stars()
	updt_enemies()
	updt_plyr()
	updt_bullets()
	
	if #enemies==0 then
		spwn_enemies(flr(rnd(7))+1)
	end
end

function draw_game()
	cls()
	--stars
	for s in all(stars) do
		pset(s.x,s.y,s.col)
	end
	--enemies
	for e in all(enemies) do
		spr(32,e.x,e.y)
		spr(
			e.flamespr,
			e.x,
			e.y-8
		)
	end
	--ship
	spr(plyr.sprt,plyr.x,plyr.y)
	spr(
		plyr.flamespr,
		plyr.x,
		plyr.y+8
	)
	--bullets
	for b in all(bullets) do 
		spr(48,b.x,b.y)
	end
	--** hud **
	--score
	print(score,64-#tostr(score)*2,2,10)
end

-- ** game over **
function updt_gameover()
	if (btn(❎)) init_game()
end

function draw_gameover()
	cls()
	gmstr="game over"
	scrstr="score: "..score
	rstrtstr="press ❎/x to restart"
	print(
		gmstr,
		h_txt_cntr(gmstr),
		v_txt_cntr()-14,
		10
	)
	print(
		scrstr,
		h_txt_cntr(scrstr),
		v_txt_cntr(),
		7
	)
	print(
		rstrtstr,
		h_txt_cntr(rstrtstr),
		v_txt_cntr()+40,
		6
	)
end
-->8
--stars

function create_stars()
	stars={}
	for i=1,20 do
		star={
			x=rnd(128),
			y=rnd(128),
			col=13,
			speed=0.75
		}
		add(stars,star)
	end
	for i=1,10 do
		star={
			x=rnd(128),
			y=rnd(128),
			col=7,
			speed=3
		}
		add(stars,star)
	end
end

function updt_stars()
	for s in all(stars) do 
		s.y+=s.speed	
		if s.y >= 128 then
			s.y=-rnd(60)
			s.x=rnd(128)
		end
	end
end
-->8
--player

function init_plyr()
	plyr={
		x=60,
		y=90,
		speed=2,
		hp=3,
		box={x1=2,x2=5,y1=1,y2=6},
		sprt=0,
		flamespr=16,
		timetoshoot=8
	}
end

function updt_plyr()
	fsmax=19
	fsmin=16
	plyr.sprt=0
	
	if plyr.timetoshoot>0 then
		plyr.timetoshoot-=1
	end
	
	if btn(➡️) 
	and plyr.x+plyr.speed<=120 then
		plyr.x+=plyr.speed
		plyr.sprt=2
		fsmax=23
		fsmin=20
	end
	if btn(⬅️)
	and plyr.x-plyr.speed>=0 then
	 plyr.x-=plyr.speed
	 plyr.sprt=1
	 fsmax=23
	 fsmin=20
	end
	if btn(⬆️)
	and plyr.y-plyr.speed>=0 then
		plyr.y-=plyr.speed
	end
	if btn(⬇️)
	and plyr.y+plyr.speed<=120 then
		plyr.y+=plyr.speed
	end
	
	if btn(❎)
	and plyr.timetoshoot==0 then
		shoot()
		plyr.timetoshoot=8
	end
	--animate player flame
	if (t%4==0) then
		if (plyr.flamespr>=fsmax)
		or (plyr.flamespr<fsmin) then
			plyr.flamespr=fsmin
		else
		 plyr.flamespr+=1
		end
	end
	
	--check collisions
	for e in all(enemies) do

		if coll(e,plyr) then
			plyr_take_dmg(1)
			e_take_dmg(e,e.hp)
		end
	end	
end

function plyr_take_dmg(dmg)
	plyr.hp-=dmg
	if plyr.hp <= 0 then
		--game over state
		state=2
	end
end
-->8
--enemies

function spwn_enemies(nb)
	gap=(128-8*nb)/(nb+1)
	for i=1,nb do
		enemy={
			x=gap*i+8*(i-1),
			y=-flr(rnd(32)),
			life=4,
			speed=0.3,
			hp=3,
			box={x1=0,x2=7,y1=0,y2=7},
			flamespr=24
		}
		add(enemies,enemy)
	end
end

function updt_enemies()
	for e in all(enemies) do
		e.y+=e.speed
		
		--animate enemy flame
		if (t%4==0) then
			if e.flamespr == 27 then
				e.flamespr=24
			else
			 e.flamespr+=1
			end
		end
		
		--del enemy out of the screen
		if e.y >= 128+8 then
			del(enemies,e)
		end
	end
	
end

function e_take_dmg(e,dmg) 
	e.hp-=dmg
	if e.hp <= 0 then
		del(enemies,e)
		score+=100
	end
end


-->8
--bullets

function shoot()
	bullet={
		x=plyr.x,
		y=plyr.y,
		speed=3,
		box={x1=3,x2=4,y1=0,y2=2}
	}
	add(bullets,bullet)
	sfx(0)
end

function updt_bullets()
	for b in all(bullets) do
		b.y-=b.speed
		if b.y < -7 then
			del(bullets,b)
		end
		
		for e in all(enemies) do
			if coll(b,e) then
				del(bullets,b)
				e_take_dmg(e,1)
			end
		end
	end
end
__gfx__
00066000000066000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd00000ddd0000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd00000ddd0000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80d7cd0808c7dd8008dd7c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d9dccd9d0dccd9d00d9dccd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d9dccd9d0dccd9d00d9dccd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d99dd99d0d9d99d00d99d9d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050dd050005dd500005dd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777007777770077777700777c7c00c7c0777777007777770077777700c7cc7c00000000000000000000000000000000000000000000000000000000000000000
c7c00c7c77700777c7c00c7c0c0000c00c7cc7c0077777700c7cc7c000c00c000000000000000000000000000000000000000000000000000000000000000000
0c0000c0c7c00c7c0c0000c00000000000c00c000c7cc7c000c00c00000000000000000000000000000000000000000000000000000000000000000000000000
000000000c0000c000000000000000000000000000c00c0000000000000000000000000000008000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008000000088000000800000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000008800000877800000880000000800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000087780000777700008778000008800000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000077770000777700007777000087780000000000000000000000000000000000
00055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01211210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21211212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
21288212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01288210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00187100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00122100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000375503c5503d5503b55037550325502c5502855025550215501d5501a55015550115500c5500855004550015501b50000500015000050000500035000150005500025000050001500015000150000500
