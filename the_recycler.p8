pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
function _init()
	plyr={
		x=60,
		y=90,
		speed=2,
		hp=3,
		box={x1=2,x2=5,y1=1,y2=6}
	}
	bullets={}
	enemies={}
	create_stars()
end

function _update60()
	
	updt_plyr(plyr)
	
	if #enemies==0 then
		spwn_enemies(flr(rnd(5))+1)
	end
	
	updt_bullets()
	updt_stars()
	updt_enemies()
end

function _draw()
	cls()
	--stars
	for s in all(stars) do
		pset(s.x,s.y,s.col)
	end
	--ship
	spr(0,plyr.x,plyr.y)
	--enemies
	for e in all(enemies) do
		spr(2,e.x,e.y)
	end
	--bullets
	for b in all(bullets) do 
		spr(1,b.x,b.y)
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
				e.hp-=1
				if e.hp <= 0 then
					del(enemies,e)
				end
			end
		end
	end
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
			speed=1
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
--enemies

function spwn_enemies(nb)
	for i=1,nb do
		enemy={
			x=flr(rnd(112)) + 8,
			y=-24,
			life=4,
			speed=0.3,
			hp=3,
			box={x1=0,x2=7,y1=0,y2=7}
		}
		add(enemies,enemy)
	end
end

function updt_enemies()
	for e in all(enemies) do
		e.y+=e.speed
		if e.y >= 128 then
			del(enemies,e)
		end
		
		if coll(e,plyr) then
			del(enemies,e)
		end
	end
end
-->8
--player

function updt_plyr(p)
	if btn(➡️) 
	   and p.x+p.speed<=120 then
		p.x+=p.speed
	end
	if btn(⬅️)
			 and p.x-p.speed>=0 then
	 p.x-=p.speed
	end
	if btn(⬆️)
			 and p.y-p.speed>=0 then
			 p.y-=p.speed
	end
	if btn(⬇️)
	   and p.y+p.speed<=120 then
	   p.y+=p.speed
	end
	
	if (btnp(❎)) shoot()
end
-->8
--functions
function abs_box(s)
	box={}
	box.x1 = s.box.x1 + s.x
	box.x2 = s.box.x2 + s.x
	box.y1 = s.box.y1 + s.y
	box.y2 = s.box.y2 + s.y
	return box
end

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
__gfx__
00066000000bb0000502205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd00000bb0002122221200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd00000330002122221200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
80d7cd08000000000128821000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d9dccd9d000000000128821000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d9dccd9d000000000018710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d99dd99d000000000012210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
050dd050000000000002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000375503c5503d5503b55037550325502c5502855025550215501d5501a55015550115500c5500855004550015501b50000500015000050000500035000150005500025000050001500015000150000500
