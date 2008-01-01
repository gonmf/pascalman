program pacman5;
uses wincrt;
const
versao='0.5';
velocbase=0.2;
axisdiff=1.545;
extratime=100;
pmanspeed=2;
pman='£';
wallsection='#';
plus='.';
extraplus='o';
door1='-';
door2='|';
teclaup='W';
teclaleft='A';
tecladown='S';
teclaright='D';
teclapause='P';
checksys=true;
ghost='W';
ghostflick=5;
ghostspeed=4;
ghostcountmax=999;
dirmapas='maps/';
filestats='data.ini';
mapaoriginal='classic.ini';
type
tiporecorde=record
pontos,jogos,total: longint;
end;
var
bin1: file of tiporecorde;
recorde: tiporecorde;
goghost: array[1..ghostcountmax] of record
mapx,mapy,dir1,dir2,pers: byte;
previous: char;
end;
mapa: string[12];
map: array[1..40,1..20] of char;
tecla: array[1..5] of char;
dir3,menu: char;
file1: text;
ghostai,checkable,loop,legit,defeat,victory,axissync,auxbool,auxbool2: boolean;
ghostcount,score,scoreturn,velocidade,vidas,cont1,cont2,cont3,clock,extraclock: longint;
scoretemp,ghostpers,dir1,dir2,mapx,mapy: byte;
function ismapok(mapok: string): boolean;
begin
ismapok:=true;
assign(file1,dirmapas+mapok);
reset(file1);
cont3:=0;
for cont2:=1 to 20 do begin
for cont1:=1 to 40 do begin
read(file1,map[cont1,cont2]);
if (map[cont1,cont2]<'0') or (map[cont1,cont2]>'5') then ismapok:=false;
if (map[cont1,cont2]<>'1') and ((cont1=1) or (cont2=1) or (cont1=40) or (cont2=20)) then ismapok:=false;
if (map[cont1,cont2]='2') or (map[cont1,cont2]='3') then cont3:=cont3+1;
end;
readln(file1);
end;
if cont3=0 then ismapok:=false;
readln(file1,cont1);
if (cont1<2) or (cont1>39) then ismapok:=false;
readln(file1,cont2);
if (cont2<2) or (cont2>19) then ismapok:=false;
if (map[cont1,cont2]<>'0') and (map[cont1,cont2]<>'2') and (map[cont1,cont2]<>'3') then ismapok:=false;
readln(file1,cont1);
if (cont1<1) or (cont1>4) then ismapok:=false;
readln(file1,cont1);
if (cont1<2) or (cont1>39) then ismapok:=false;
readln(file1,cont1);
if (cont1<2) or (cont1>19) then ismapok:=false;
readln(file1,cont1);
if (cont1<1) or (cont1>4) then ismapok:=false;
close(file1);
end;
procedure resetscore;
begin
assign(bin1,filestats);
rewrite(bin1);
recorde.pontos:=0;
recorde.jogos:=0;
recorde.total:=0;
write(bin1,recorde);
close(bin1);
write('Registos limpos');
readkey;
donewincrt;
end;
procedure block3(b3num: byte);
begin
gotoxy(45,11+b3num);
write('Nova Tecla: _  ');
gotoxy(57,11+b3num);
read(dir3);
dir3:=upcase(dir3);
auxbool:=true;
for cont1:=1 to 5 do
if (tecla[cont1]=dir3) and (cont1<>b3num) then auxbool:=false;
if not (((dir3>='A') and (dir3<='Z')) xor ((dir3>='0') and (dir3<='9'))) then auxbool:=false;
if auxbool=true then tecla[b3num]:=dir3;
end;
procedure block2;
begin
write(' ');
if map[mapx,mapy]=plus then begin
map[mapx,mapy]:=' ';
score:=score+1;
scoretemp:=scoretemp+1;
end;
if map[mapx,mapy]=extraplus then begin
map[mapx,mapy]:=' ';
extraclock:=extratime;
score:=score+10;
scoretemp:=scoretemp+10;
end;
if scoretemp>=100 then begin
scoretemp:=scoretemp-100;
vidas:=vidas+1;
end;
gotoxy(mapx+19,mapy+1);
write(pman);
end;
procedure block1;
begin
repeat
goghost[cont1].dir2:=random(4)+1;
case goghost[cont1].dir2 of
1: if map[goghost[cont1].mapx,goghost[cont1].mapy-1]=wallsection then goghost[cont1].dir2:=goghost[cont1].dir1;
2: if map[goghost[cont1].mapx-1,goghost[cont1].mapy]=wallsection then goghost[cont1].dir2:=goghost[cont1].dir1;
3: if map[goghost[cont1].mapx,goghost[cont1].mapy+1]=wallsection then goghost[cont1].dir2:=goghost[cont1].dir1;
4: if map[goghost[cont1].mapx+1,goghost[cont1].mapy]=wallsection then goghost[cont1].dir2:=goghost[cont1].dir1;
end;
until goghost[cont1].dir2<>goghost[cont1].dir1;
goghost[cont1].dir1:=goghost[cont1].dir2;
end;
procedure timer(space: byte);
var
taux: longint;
begin
clock:=clock+1;
if (axissync=true) and (dir1 mod 2<>0) then
for taux:=1 to round(99999*(10-velocidade)*axisdiff*velocbase*space) do write('')
else
for taux:=1 to round(99999*(10-velocidade)*1*velocbase*space) do write('');
end;
procedure savestats;
begin
assign(bin1,filestats);
rewrite(bin1);
write(bin1,recorde);
close(bin1);
end;
procedure ai_on;
var
aion1int,aion2int,aion3int,aion4int,aion5int: longint;
aion1bool,aion2bool: boolean;
begin
aion1bool:=false;
case goghost[cont1].dir1 of
1: if map[goghost[cont1].mapx,goghost[cont1].mapy-1]=wallsection then aion1bool:=true;
2: if map[goghost[cont1].mapx-1,goghost[cont1].mapy]=wallsection then aion1bool:=true;
3: if map[goghost[cont1].mapx,goghost[cont1].mapy+1]=wallsection then aion1bool:=true;
4: if map[goghost[cont1].mapx+1,goghost[cont1].mapy]=wallsection then aion1bool:=true;
end;
aion5int:=0;
if map[goghost[cont1].mapx,goghost[cont1].mapy-1]<>wallsection then aion5int:=aion5int+1;
if map[goghost[cont1].mapx-1,goghost[cont1].mapy]<>wallsection then aion5int:=aion5int+1;
if map[goghost[cont1].mapx,goghost[cont1].mapy+1]<>wallsection then aion5int:=aion5int+1;
if map[goghost[cont1].mapx+1,goghost[cont1].mapy]<>wallsection then aion5int:=aion5int+1;
aion1int:=mapx-goghost[cont1].mapx;
aion2int:=mapy-goghost[cont1].mapy;
if axissync=true then aion1int:=round(aion1int*axisdiff);
if (aion1int=0) and (aion2int=0) then aion4int:=random(4)+1 else
if (aion1int=0) and (aion2int<0) then aion4int:=3 else
if (aion1int=0) and (aion2int>0) then aion4int:=1 else
if (aion1int<0) and (aion2int=0) then aion4int:=2 else
if (aion1int>0) and (aion2int=0) then aion4int:=4 else
begin
aion4int:=2;
if (abs(aion1int))=(abs(aion2int)) then begin
if random(2)=0 then aion4int:=aion4int-1;
aion3int:=aion1int;
end;
if (abs(aion1int))>(abs(aion2int)) then begin
if random(2)=0 then aion4int:=aion4int-1;
aion3int:=aion1int;
end;
if (abs(aion1int))<(abs(aion2int)) then aion3int:=aion2int;
if aion3int<0 then aion4int:=aion4int+2;
end;
if goghost[cont1].pers=1 then aion4int:=random(4)+1;
if goghost[cont1].pers=3 then aion4int:=aion4int+2;
if aion4int=5 then aion4int:=1;
if aion4int=6 then aion4int:=2;
aion2bool:=false;
case aion4int of
1: if map[goghost[cont1].mapx,goghost[cont1].mapy-1]=wallsection then aion2bool:=true;
2: if map[goghost[cont1].mapx-1,goghost[cont1].mapy]=wallsection then aion2bool:=true;
3: if map[goghost[cont1].mapx,goghost[cont1].mapy+1]=wallsection then aion2bool:=true;
4: if map[goghost[cont1].mapx+1,goghost[cont1].mapy]=wallsection then aion2bool:=true;
end;
goghost[cont1].dir2:=random(ghostflick);
if aion1bool=true then goghost[cont1].dir2:=0;
if goghost[cont1].dir2=0 then begin
if aion2bool=false then goghost[cont1].dir1:=aion4int else
if aion5int=1 then begin
goghost[cont1].dir1:=goghost[cont1].dir1+2;
if goghost[cont1].dir1=5 then goghost[cont1].dir1:=1;
if goghost[cont1].dir1=6 then goghost[cont1].dir1:=2;
end else begin
repeat
goghost[cont1].dir2:=random(4)+1;
case goghost[cont1].dir2 of
1: if map[goghost[cont1].mapx,goghost[cont1].mapy-1]=wallsection then goghost[cont1].dir2:=0;
2: if map[goghost[cont1].mapx-1,goghost[cont1].mapy]=wallsection then goghost[cont1].dir2:=0;
3: if map[goghost[cont1].mapx,goghost[cont1].mapy+1]=wallsection then goghost[cont1].dir2:=0;
4: if map[goghost[cont1].mapx+1,goghost[cont1].mapy]=wallsection then goghost[cont1].dir2:=0;
end;
until goghost[cont1].dir2<>0;
goghost[cont1].dir1:=goghost[cont1].dir2;
end;
end;
end;
procedure ai_off;
begin
goghost[cont1].dir2:=random(ghostflick);
case goghost[cont1].dir1 of
1: if (goghost[cont1].dir2=0) or (map[goghost[cont1].mapx,goghost[cont1].mapy-1]=wallsection) then block1;
2: if (goghost[cont1].dir2=0) or (map[goghost[cont1].mapx-1,goghost[cont1].mapy]=wallsection) then block1;
3: if (goghost[cont1].dir2=0) or (map[goghost[cont1].mapx,goghost[cont1].mapy+1]=wallsection) then block1;
4: if (goghost[cont1].dir2=0) or (map[goghost[cont1].mapx+1,goghost[cont1].mapy]=wallsection) then block1;
end;
end;
procedure startup;
begin
cont2:=5;
repeat
clrscr;
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
gotoxy(34,15);
write('a - Começar');
gotoxy(33,17);
write('b - Controlos');
gotoxy(34,19);
write('c - Recordes');
timer(4);
until keypressed;
menu:=upcase(readkey);
if menu='B' then begin
repeat
clrscr;
repeat
loop:=true;
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
timer(4);
gotoxy(20,11);
write('Teclas:');
gotoxy(21,12);
write('Tecla Cima');
gotoxy(40,12);
write(tecla[1],'    (a - Modificar)');
gotoxy(21,13);
write('Tecla Esquerda');
gotoxy(40,13);
write(tecla[2],'    (b - Modificar)');
gotoxy(21,14);
write('Tecla Baixo');
gotoxy(40,14);
write(tecla[3],'    (c - Modificar)');
gotoxy(21,15);
write('Tecla Direita');
gotoxy(40,15);
write(tecla[4],'    (d - Modificar)');
gotoxy(21,16);
write('Tecla Pausa');
gotoxy(40,16);
write(tecla[5],'    (e - Modificar)');
gotoxy(10,19);
write('1. Coma as pastilhas super para aumentar a sua pontuação');
gotoxy(10,20);
write('   e velocidade, ou guarde-as para os momentos mais complicados;');
gotoxy(10,22);
write('2. Cuidado com as portas dos fantasmas, eles podem atravessá-las');
gotoxy(10,23);
write('   mas você não;');
until keypressed;
menu:=upcase(readkey);
if (menu<'A') or (menu>'E') then loop:=false;
case menu of
'A': block3(1);
'B': block3(2);
'C': block3(3);
'D': block3(4);
'E': block3(5);
end;
until loop=false;
end;
if menu='C' then begin
clrscr;
gotoxy(27,14);
write('Recordes de jogos oficiais');
gotoxy(30,17);
write('Máximo de pontos: ',recorde.pontos);
gotoxy(30,19);
write('Máximo de turnos: ',recorde.jogos);
gotoxy(30,21);
write('Total de jogos: ',recorde.total);
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
timer(4);
until keypressed;
end;
until menu='A';
end;
procedure engine;
begin
repeat
gotoxy(8,5);
write(score,'     ');
gotoxy(68,5);
if legit=true then write(recorde.pontos,'     ');
if loop=true then begin
gotoxy(8,8);
write('#',scoreturn/1:3:0);
gotoxy(69,8);
if legit=true then write(recorde.jogos/1:3:0);
end;
if legit=true then begin
if score>recorde.pontos then recorde.pontos:=score;
if scoreturn>recorde.jogos then recorde.jogos:=scoreturn;
end;
for cont1:=1 to 5 do begin
gotoxy(10,22-cont1*2);
write(' ');
end;
if vidas<=5 then begin
for cont1:=1 to vidas do begin
gotoxy(10,22-cont1*2);
write('$');
end;
end else begin
gotoxy(8,21);
write('$ x ',vidas);
end;
for cont1:=1 to ghostcount do
if (goghost[cont1].mapx=mapx) and (goghost[cont1].mapy=mapy) then defeat:=true
else begin
if (goghost[cont1].mapx=mapx) and (goghost[cont1].mapy-1=mapy) and (dir1=1) then defeat:=true;
if (goghost[cont1].mapy=mapy) and (goghost[cont1].mapx-1=mapx) and (dir1=2) then defeat:=true;
if (goghost[cont1].mapx=mapx) and (goghost[cont1].mapy+1=mapy) and (dir1=3) then defeat:=true;
if (goghost[cont1].mapy=mapy) and (goghost[cont1].mapx+1=mapx) and (dir1=4) then defeat:=true;
end;
timer(1);
if extraclock>0 then begin
cont1:=round(pmanspeed/2);
extraclock:=extraclock-1;
end else cont1:=pmanspeed;
if clock mod cont1=0 then
case dir2 of
1: if (map[mapx,mapy-1]<>wallsection) and (map[mapx,mapy-1]<>door1) and (map[mapx,mapy-1]<>door2) then begin
dir1:=dir2;
dir2:=0;
end;
2: if (map[mapx-1,mapy]<>wallsection) and (map[mapx-1,mapy]<>door1) and (map[mapx-1,mapy]<>door2) then begin
dir1:=dir2;
dir2:=0;
end;
3: if (map[mapx,mapy+1]<>wallsection) and (map[mapx,mapy+1]<>door1) and (map[mapx,mapy+1]<>door2) then begin
dir1:=dir2;
dir2:=0;
end;
4: if (map[mapx+1,mapy]<>wallsection) and (map[mapx+1,mapy]<>door1) and (map[mapx+1,mapy]<>door2) then begin
dir1:=dir2;
dir2:=0;
end;
end;
if clock mod cont1=0 then
case dir1 of
1: if (map[mapx,mapy-1]<>wallsection) and (map[mapx,mapy-1]<>door1) and (map[mapx,mapy-1]<>door2) then begin
gotoxy(mapx+19,mapy+1);
mapy:=mapy-1;
block2;
end;
2: if (map[mapx-1,mapy]<>wallsection) and (map[mapx-1,mapy]<>door1) and (map[mapx-1,mapy]<>door2) then begin
gotoxy(mapx+19,mapy+1);
mapx:=mapx-1;
block2;
end;
3: if (map[mapx,mapy+1]<>wallsection) and (map[mapx,mapy+1]<>door1) and (map[mapx,mapy+1]<>door2) then begin
gotoxy(mapx+19,mapy+1);
mapy:=mapy+1;
block2;
end;
4: if (map[mapx+1,mapy]<>wallsection) and (map[mapx+1,mapy]<>door1) and (map[mapx+1,mapy]<>door2) then begin
gotoxy(mapx+19,mapy+1);
mapx:=mapx+1;
block2;
end;
end;
if clock mod ghostspeed=0 then begin
for cont1:=1 to ghostcount do begin
gotoxy(goghost[cont1].mapx+19,goghost[cont1].mapy+1);
write(' ');
if ghostai=false then ai_off else ai_on;
cont3:=-1;
for cont2:=1 to ghostcount do
if (goghost[cont1].mapx=goghost[cont2].mapx) and (goghost[cont1].mapy=goghost[cont2].mapy) then cont3:=cont3+1;
goghost[cont1].previous:=map[goghost[cont1].mapx,goghost[cont1].mapy];
if cont3>0 then goghost[cont1].previous:=ghost;
if goghost[cont1].previous=pman then goghost[cont1].previous:=' ';
gotoxy(goghost[cont1].mapx+19,goghost[cont1].mapy+1);
write(goghost[cont1].previous);
case goghost[cont1].dir1 of
1: goghost[cont1].mapy:=goghost[cont1].mapy-1;
2: goghost[cont1].mapx:=goghost[cont1].mapx-1;
3: goghost[cont1].mapy:=goghost[cont1].mapy+1;
4: goghost[cont1].mapx:=goghost[cont1].mapx+1;
end;
gotoxy(goghost[cont1].mapx+19,goghost[cont1].mapy+1);
write(ghost);
end;
end;
until keypressed;
dir3:=upcase(readkey);
if dir3=tecla[1] then if map[mapx,mapy-1]<>wallsection then dir1:=1 else dir2:=1;
if dir3=tecla[2] then if map[mapx-1,mapy]<>wallsection then dir1:=2 else dir2:=2;
if dir3=tecla[3] then if map[mapx,mapy+1]<>wallsection then dir1:=3 else dir2:=3;
if dir3=tecla[4] then if map[mapx+1,mapy]<>wallsection then dir1:=4 else dir2:=4;
if dir3=tecla[5] then begin
gotoxy(1,1);
readkey;
end;
for cont1:=1 to 40 do
for cont2:=1 to 20 do
if (map[cont1,cont2]=plus) or (map[cont1,cont2]=extraplus) then victory:=false;
end;
procedure setup;
begin
repeat
clrscr;
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
gotoxy(35,15);
write('Começar...');
gotoxy(31,17);
write('a - Partida livre');
gotoxy(30,19);
write('b - Partida oficial');
timer(4);
until keypressed;
menu:=upcase(readkey);
until (menu='A') or (menu='B');
clrscr;
legit:=false;
scoreturn:=0;
ghostcount:=4;
vidas:=2;
velocidade:=5;
mapa:=mapaoriginal;
loop:=true;
axissync:=true;
ghostai:=true;
ghostpers:=0;
score:=0;
scoreturn:=0;
scoretemp:=0;
if menu='A' then begin
repeat
clrscr;
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
gotoxy(29,13);
write('Começar... partida livre');
gotoxy(30,15);
write('a - Velocidade=',velocidade);
gotoxy(30,16);
write('b - Vidas=',vidas);
gotoxy(30,17);
write('c - Fantasmas=',ghostcount);
gotoxy(30,18);
write('d - Mapa="',mapa,'"');
gotoxy(30,19);
write('e - Repetição=');
if loop=true then write('Sim') else write('Não');
gotoxy(30,20);
write('f - AxisSync=');
if axissync=true then write('Sim') else write('Não');
gotoxy(30,21);
write('g - IA Fantasma=');
if ghostai=true then write('Sim') else write('Não');
gotoxy(30,22);
write('h - IA Pers.=');
if ghostai=false then write('Não Possui') else
case ghostpers of
0: write('Normal');
1: write('Agressiva');
2: write('Defensiva');
3: write('Aleatória');
end;
gotoxy(29,23);
write('i - Aceitar & Continuar');
timer(4);
until keypressed;
menu:=upcase(readkey);
if menu='A' then begin
gotoxy(45,15);
write('_        ');
gotoxy(45,15);
read(velocidade);
if velocidade<1 then velocidade:=1;
if velocidade>9 then velocidade:=9;
end;
if menu='B' then begin
gotoxy(40,16);
write('__        ');
gotoxy(40,16);
read(vidas);
if vidas<0 then vidas:=0;
if vidas>99 then vidas:=99;
end;
if menu='C' then begin
gotoxy(44,17);
if ghostcountmax mod 10000=0 then write('_');
if ghostcountmax mod 1000=0 then write('_');
if ghostcountmax mod 100=0 then write('_');
if ghostcountmax mod 10=0 then write('_');
write('_        ');
gotoxy(44,17);
read(ghostcount);
if ghostcount<1 then ghostcount:=1;
if ghostcount>ghostcountmax then ghostcount:=ghostcountmax;
end;
if menu='D' then begin
gotoxy(40,18);
write('________.ini"        ');
gotoxy(40,18);
readln(mapa);
mapa:=mapa+'.ini';
end;
if menu='E' then if loop=true then loop:=false else loop:=true;
if menu='F' then if axissync=true then axissync:=false else axissync:=true;
if menu='G' then if ghostai=true then ghostai:=false else ghostai:=true;
if menu='H' then begin
ghostpers:=ghostpers+1;
if ghostpers=4 then ghostpers:=0;
end;
until menu='I';
clrscr;
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
gotoxy(28,15);
write('Começar... partida livre');
gotoxy(21,17);
write('Os parâmetros anteriores são aplicados');
gotoxy(17,19);
write('Neste modo não são registados recordes de jogo');
timer(4);
until keypressed;
end else begin
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
gotoxy(27,15);
write('Começar... partida oficial');
gotoxy(14,17);
write('Todos os parâmetros originais do jogo são aplicados');
gotoxy(17,19);
write('Neste modo são registados os recordes de jogo');
timer(4);
legit:=true;
until keypressed;
recorde.total:=recorde.total+1;
end;
auxbool2:=true;
end;
procedure load;
begin
clrscr;
scoreturn:=scoreturn+1;
write('A verificar mapa ... mapa não existe');
assign(file1,dirmapas+mapa);
reset(file1);
close(file1);
clrscr;
write('A verificar mapa ... mapa incorrecto');
assign(file1,dirmapas+mapa);
reset(file1);
for cont2:=1 to 20 do begin
for cont1:=1 to 40 do begin
read(file1,map[cont1,cont2]);
if map[cont1,cont2]='0' then map[cont1,cont2]:=' ';
if map[cont1,cont2]='1' then map[cont1,cont2]:=wallsection;
if map[cont1,cont2]='2' then map[cont1,cont2]:=plus;
if map[cont1,cont2]='3' then map[cont1,cont2]:=extraplus;
if map[cont1,cont2]='4' then map[cont1,cont2]:=door1;
if map[cont1,cont2]='5' then map[cont1,cont2]:=door2;
end;
readln(file1);
end;
readln(file1,mapx);
readln(file1,mapy);
map[mapx,mapy]:=pman;
readln(file1,dir1);
readln(file1,goghost[1].mapx);
readln(file1,goghost[1].mapy);
readln(file1,goghost[1].dir1);
goghost[1].dir2:=goghost[1].dir1;
for cont1:=2 to ghostcount do begin
goghost[cont1].mapx:=goghost[1].mapx;
goghost[cont1].mapy:=goghost[1].mapy;
goghost[cont1].dir1:=goghost[1].dir1;
goghost[cont1].dir2:=goghost[1].dir2;
end;
for cont1:=1 to ghostcount do
if ghostpers=0 then begin
cont2:=random(4);
if cont2<=1 then goghost[cont1].pers:=2;
if cont2=2 then goghost[cont1].pers:=1;
if cont2=3 then goghost[cont1].pers:=3;
end else
if ghostpers=1 then begin
cont2:=random(10);
if cont2<=7 then goghost[cont1].pers:=2;
if cont2=8 then goghost[cont1].pers:=1;
if cont2=9 then goghost[cont1].pers:=3;
end else
if ghostpers=2 then begin
cont2:=random(10);
if cont2<=7 then goghost[cont1].pers:=3;
if cont2=8 then goghost[cont1].pers:=1;
if cont2=9 then goghost[cont1].pers:=2;
end else begin
cont2:=random(3);
if cont2=0 then goghost[cont1].pers:=1;
if cont2=1 then goghost[cont1].pers:=2;
if cont2=2 then goghost[cont1].pers:=3;
end;
close(file1);
if (auxbool2=true) and (ghostai=true) then begin
auxbool2:=false;
for cont1:=1 to 39 do
for cont2:=1 to 19 do
if
((map[cont1,cont2]<>wallsection) and (map[cont1,cont2]<>door1) and (map[cont1,cont2]<>door2)) and
((map[cont1+1,cont2]<>wallsection) and (map[cont1+1,cont2]<>door1) and (map[cont1+1,cont2]<>door2)) and
((map[cont1,cont2+1]<>wallsection) and (map[cont1,cont2+1]<>door1) and (map[cont1,cont2+1]<>door2)) and
((map[cont1+1,cont2+1]<>wallsection) and (map[cont1+1,cont2+1]<>door1) and (map[cont1+1,cont2+1]<>door2)) then
auxbool2:=true;
if auxbool2=true then begin
repeat
clrscr;
repeat
if cont2>8 then cont2:=0;
cont2:=cont2+1;
gotoxy(34,5);
write('P A C M A N');
gotoxy(28,8);
write(ghost,' ',ghost,' ',ghost,' ',ghost,'  ',pman,' ');
for cont1:=1 to cont2 do write(' ');
write('.         ');
gotoxy(16,15);
write('Foi encontrado um problema com o mapa seleccionado:');
gotoxy(18,17);
write('# Possui demasiado espaçamento livre');
gotoxy(16,19);
write('Isto pode prejudicar a IA fantasma, é aconselhável');
gotoxy(16,20);
write('desligá-la e usar a aleatória, deseja fazê-lo?');
gotoxy(35,22);
write('S/N');
timer(4);
until keypressed;
dir3:=upcase(readkey);
until (dir3='S') xor (dir3='N');
if dir3='S' then ghostai:=false;
end;
auxbool2:=false;
end;
clrscr;
for cont2:=1 to 20 do
for cont1:=1 to 40 do begin
gotoxy(cont1+19,cont2+1);
write(map[cont1,cont2]);
end;
gotoxy(6,4);
write('Pontuação');
gotoxy(67,4);
if legit=true then write('Recorde');
if loop=true then begin
gotoxy(8,7);
write('Jogo');
gotoxy(68,7);
if legit=true then write('Jogos');
end;
gotoxy(38,24);
write('v',versao);
end;
procedure syscheck;
begin
writeln(':: Rotina de detecção de problemas ::');
writeln;
write('Passo 1/6: A conferir atributo "read-only"...');
assign(file1,'temp001');
rewrite(file1);
close(file1);
assign(file1,'temp001');
reset(file1);
erase(file1);
close(file1);
writeln(' Concluido');
write('Passo 2/6: A localizar ficheiro "',filestats,'"...');
assign(bin1,filestats);
reset(bin1);
close(bin1);
writeln(' Concluido');
write('Passo 3/6: A localizar directoria de mapas...');
assign(file1,dirmapas+'temp001');
rewrite(file1);
close(file1);
assign(file1,dirmapas+'temp001');
reset(file1);
erase(file1);
close(file1);
writeln(' Concluido');
write('Passo 4/6: A conferir ficheiro "',filestats,'"...');
assign(bin1,filestats);
reset(bin1);
read(bin1,recorde);
close(bin1);
writeln(' Concluido');
write('Passo 5/6: A localizar ficheiro "',dirmapas+mapaoriginal,'"...');
assign(file1,dirmapas+mapaoriginal);
reset(file1);
close(file1);
writeln(' Concluido');
write('Passo 6/6: A conferir ficheiro "',dirmapas+mapaoriginal,'"...');
if ismapok(mapaoriginal)=false then begin
writeln;
writeln;
writeln('(!) Ficheiro "',mapaoriginal,'" não obedece aos padrões oficiais de jogo.');
writeln('Desligar a revisão de sistema automática e continuar? Não aconselhável.');
write('  S/N ');
repeat
menu:=upcase(readkey);
if menu='N' then donewincrt else checkable:=false;
until menu='S';
end;
writeln(' Concluido');
clrscr;
end;
begin
randomize;
if checksys=true then checkable:=true else checkable:=false;
repeat
if checkable=true then syscheck;
tecla[1]:=teclaup;
tecla[2]:=teclaleft;
tecla[3]:=tecladown;
tecla[4]:=teclaright;
tecla[5]:=teclapause;
velocidade:=5;
startup;
setup;
if loop=false then begin
load;
repeat
defeat:=false;
victory:=true;
engine;
if (defeat=true) and (vidas>0) then begin
defeat:=false;
vidas:=vidas-1;
end;
savestats;
until (defeat=true) or (victory=true);
end else
repeat
load;
repeat
defeat:=false;
victory:=true;
engine;
if (defeat=true) and (vidas>0) then begin
defeat:=false;
vidas:=vidas-1;
end;
savestats;
until (defeat=true) or (victory=true);
until (defeat=true) and (vidas<=0);
gotoxy(1,1);
readkey;
until cont1=-1;
write('Se está a ler isto houve um bug, parabéns');
readkey;
donewincrt;
end.
{                       F I M                       }






