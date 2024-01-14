unit gestion_level;

interface

uses sdl2,sdl2_image, math, sdl2_ttf, sysutils, types_and_constants, SDL2_Mixer;
	
procedure initialise(var sdlwindow: PSDL_Window; var sdlRenderer:PSDL_Renderer; var home_music : PMix_Music);
procedure termine(var sdlwindow: PSDL_WINDOW; var sdlRenderer:PSDL_Renderer; var home_music : PMix_Music);
procedure clean_image(var texture : PSDL_Texture);
procedure load_obj(var obj : objet; var renderer : PSDL_Renderer; img_name : PAnsiChar; x_hb, y_hb, w_hb, h_hb, x_obj, y_obj, w_obj, h_obj, speed : Integer);
procedure affiche_img(var renderer: PSDL_RENDERER; obj : objet);
procedure affiche_cochon(var renderer: PSDL_RENDERER; obj : objet; var anim_state, anim_sens : Integer);
procedure chute_cochon(var cochon : objet);
procedure jump_cochon(var cochon : objet);
procedure move_flamme(var flamme : objet);
function intersect(hb1 : TSDL_Rect; hb2 : TSDL_Rect):Boolean;
function cochon_touche(var cochon : objet; var flamme : objet):Boolean;
function generate_height_flamme(base_ecart, variance_ecart : Integer):tab_f;
function generate_n_flammes(n,base_ecart,variance_ecart : Integer):tab_n_f;
procedure affiche_health_bar(health_points : Integer; renderer : PSDL_Renderer);
procedure ecrire(var renderer : PSDL_Renderer; text : String; x,y, font_size, col_r, col_g, col_b : Integer);
procedure generate_bonus (renderer : PSDL_Renderer; tab_flamme : Array of objet; var map_bo: map_bonus; flamme_number, bonus_number, distance_interflamme : Integer; current_menu_state : menu_state);
function itoa(n : Integer):String;
procedure set_param_level(current_menu_state : menu_state; var img_background : PansiChar; var flame_number, distance_interflamme, health_points, bonus_number, ecart_flamme, variance_flamme : Integer);
procedure gestion_bonus(bonus_number : Integer; var health_points, timer_bonus : Integer; cochon : objet; var bonus_encre : Boolean; var map_bo : map_bonus;bonus_sound : PMix_Chunk);
procedure update_objects_endless_level(var rendu : PSDL_Renderer; var tab_flammes : array_100_objects; distance_interflamme, ecart_flamme, variance_flamme : Integer; var score_endlesslvl : Integer; var hitbox_score_endlesslvl, hb_cochon : TSDL_Rect);

implementation

//cree la fenetre et le renderer et initialise l audio
procedure initialise(var sdlwindow: PSDL_Window; var sdlRenderer:PSDL_Renderer; var home_music : PMix_Music);
begin
	G_GRAVITY := 900;
	G_JUMPSPEED := 300;
	G_SCROLL_SPEED := 150;
	G_BASE_HEALTH_POINTS := 100;
	if (SDL_Init(SDL_INIT_VIDEO) or (SDL_INIT_AUDIO) < 0) then
		writeln('video ou audio echoue');
	if TTF_Init = -1 then
		writeln('ttf echoue');
	if (MIX_OpenAudio(AUDIO_FREQUENCY, AUDIO_FORMAT,AUDIO_CHANNELS, AUDIO_CHUNKSIZE)<> 0) then
		writeln('open audio echoue : ', Mix_GetError);
	SDL_CreateWindowAndRenderer(SURFACEWIDTH, SURFACEHEIGHT, SDL_WINDOW_SHOWN, @sdlwindow, @sdlRenderer);
	home_music := Mix_LoadMUS('assets/menu_music.wav');
	Mix_PlayMusic(home_music, -1);
	Mix_PauseMusic;
end;

//nettoie la memoire allouee a la fenetre et au renderer et decharge la librairie SDL et l audio
procedure termine(var sdlwindow: PSDL_WINDOW; var sdlRenderer:PSDL_Renderer; var home_music : PMix_Music);
begin
	SDL_DestroyRenderer(sdlRenderer);
	SDL_DestroyWindow(sdlwindow);
	Mix_FreeMusic(home_music);
	Mix_CloseAudio;
	Mix_Quit;
	SDL_Quit();
end;

//nettoie la memoire allouee a une texture
procedure clean_image(var texture : PSDL_Texture);
begin
	SDL_DestroyTexture(texture);
end;

//charge un objet dans le renderer a partir de chacun des champs fournis en argument
procedure load_obj(var obj : objet; var renderer : PSDL_Renderer; img_name : PAnsiChar; x_hb, y_hb, w_hb, h_hb, x_obj, y_obj, w_obj, h_obj, speed : Integer);
begin
	obj.texture := IMG_LoadTexture(renderer, img_name);
	obj.hitbox.x := x_hb;
	obj.hitbox.y := y_hb;
	obj.hitbox.w := w_hb;
	obj.hitbox.h := h_hb;
	obj.x_obj := x_obj;
	obj.y_obj := y_obj;
	obj.w_obj := w_obj;
	obj.h_obj := h_obj;
	obj.speed := speed;
end;

//place un objet dans le renderer
procedure affiche_img(var renderer: PSDL_RENDERER; obj : objet);
	var rect_obj : TSDL_RECT;
begin
	rect_obj.x:=obj.x_obj;
	rect_obj.y:=obj.y_obj;
	rect_obj.w:=obj.w_obj;
	rect_obj.h:=obj.h_obj;
	
	SDL_RenderCopy(renderer, obj.texture, nil, @rect_obj);
end;

//affiche une partie de la spritesheet du cochon en fonction de anim_state
procedure affiche_cochon(var renderer: PSDL_RENDERER; obj : objet; var anim_state, anim_sens : Integer);
	var rect_obj, rect_spritesheet : TSDL_RECT;
begin
	rect_obj.x:=obj.x_obj;
	rect_obj.y:=obj.y_obj;
	rect_obj.w:=obj.w_obj;
	rect_obj.h:=obj.h_obj;
	
	rect_spritesheet.x := anim_state * 256;
	rect_spritesheet.y := 0;
	rect_spritesheet.w := 256;
	rect_spritesheet.h := 256;
	
	SDL_RenderCopy(renderer, obj.texture, @rect_spritesheet, @rect_obj);

    if (anim_sens = 1) then
    begin
		if (anim_state = 11) then
			anim_sens := -1
		else
			anim_state := anim_state + 1;
	end
	else if (anim_sens = -1) then
	begin
		if (anim_state = 0) then
			anim_sens := 1
		else
			anim_state := anim_state - 1;
	end;
end;

//actualise la position et vitesse du cochon a chaque frame
procedure chute_cochon(var cochon : objet);
var pixels_fell_speed : Integer;
begin
	if (cochon.hitbox.y < SURFACEHEIGHT - cochon.hitbox.h) then
	begin
		pixels_fell_speed := CEIL(cochon.speed * (1/FPS));
		cochon.hitbox.y := cochon.hitbox.y + pixels_fell_speed;
		cochon.y_obj := cochon.y_obj + pixels_fell_speed;
		if (cochon.hitbox.y < 0) then
		begin
			cochon.hitbox.y := 0;
			cochon.y_obj := -78;
			cochon.speed := 0;
		end;
		cochon.speed := cochon.speed + ROUND((G_GRAVITY * (1/FPS)));
	end;
	if (cochon.hitbox.y + cochon.hitbox.h >= SURFACEHEIGHT) then
	begin
		cochon.hitbox.y := SURFACEHEIGHT - cochon.hitbox.h - 1;
		cochon.y_obj := SURFACEHEIGHT - 144 - 1;
		cochon.speed := 0;
	end;
	if (cochon.hitbox.y <= 0) then
	begin
		cochon.hitbox.y := 1;
		cochon.y_obj := ceil((-112 + 1) * 0.7);
		cochon.speed := 0;
	end;
end;

//changement de la vitesse du cochon
procedure jump_cochon(var cochon : objet);
begin
	if cochon.hitbox.y > 0 then
	begin
		cochon.speed := -G_JUMPSPEED; //une vitesse negative est orientee vers le haut
	end;
end;

//deplacement des obstacles vers la gauche de l'ecran
procedure move_flamme(var flamme : objet);
begin
	if flamme.hitbox.x <> -1000 then
	begin
		flamme.hitbox.x := flamme.hitbox.x - ROUND(1/FPS * G_SCROLL_SPEED);
		flamme.x_obj := flamme.x_obj - ROUND(1/FPS * G_SCROLL_SPEED);
	end;
	if (flamme.hitbox.x < -flamme.hitbox.w) then
	begin
		clean_image(flamme.texture);
		flamme.hitbox.x:= -1000;
		flamme.x_obj := -1000;
	end;
end;

//verfie si deux objets ayant une hitbox s'intersectent
function intersect(hb1 : TSDL_Rect; hb2 : TSDL_Rect):Boolean;
begin
	intersect := (hb1.x < hb2.x + hb2.w) and (hb1.x + hb1.w > hb2.x) and (hb1.y < hb2.y + hb2.h) and (hb1.y + hb1.h > hb2.y)
end;

//verifie si le cochon touche un autre objet
function cochon_touche(var cochon : objet; var flamme : objet):Boolean;
begin
	cochon_touche := intersect(cochon.hitbox, flamme.hitbox);
end;

//genere aleatoirement les positions d'une flamme du haut et du bas
function generate_height_flamme(base_ecart, variance_ecart : Integer):tab_f;
var tab_flamme : tab_f;
	ecart_hautbas, pos_milieu_ecart,pos_mini_haut : Integer;
begin
	ecart_hautbas := random(2*variance_ecart) + (base_ecart - variance_ecart);
	pos_mini_haut := 30;

	pos_milieu_ecart := random(SURFACEHEIGHT - 2*pos_mini_haut - ecart_hautbas) + ceil(ecart_hautbas / 2) + pos_mini_haut;
	tab_flamme[1] := pos_milieu_ecart - ceil(ecart_hautbas / 2);
	tab_flamme[2] := pos_milieu_ecart + ceil(ecart_hautbas / 2);
	generate_height_flamme := tab_flamme;
end;

//cree un tableau de n couples de flammes
function generate_n_flammes(n,base_ecart,variance_ecart : Integer):tab_n_f;
var tab_n_flammes : tab_n_f;
	i : Integer;
begin
	for i:=1 to n do
		tab_n_flammes[i] := generate_height_flamme(base_ecart, variance_ecart);
	generate_n_flammes := tab_n_flammes;
end;

//affiche la barre de vie du cochon
procedure affiche_health_bar(health_points : Integer; renderer : PSDL_Renderer);
var rect_hp, rect_contour : TSDL_Rect;
begin
	
	rect_hp.x := 723;
	rect_hp.y := 33;
	rect_hp.w := ceil(200 * health_points / G_BASE_HEALTH_POINTS);
	rect_hp.h := 14;
	
	rect_contour.x := 720;
	rect_contour.y := 30;
	rect_contour.w := 206;
	rect_contour.h := 20;
	
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
	SDL_RenderFillRect(renderer, @rect_contour);
	
	if (health_points / G_BASE_HEALTH_POINTS < 0.33) then
		SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255) //rouge
	else if (health_points / G_BASE_HEALTH_POINTS < 0.67) then
		SDL_SetRenderDrawColor(renderer, 255, 128, 0, 255) //orange
	else
		SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255); //vert
    SDL_RenderFillRect(renderer, @rect_hp);
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
end;

//ecris un texte a un endroit de l ecran
procedure ecrire(var renderer : PSDL_Renderer; text : String; x, y, font_size, col_r, col_g, col_b : Integer);
var surface_text : PSDL_Surface;
	color_text : TSDL_Color;
	texture_text : PSDL_Texture;
	position_text : TSDL_Rect;
	p_text : PChar;
	ttf_font : PTTF_font;
begin
	ttf_font := TTF_OpenFont(FONT_NAME, font_size);
	color_text.r := col_r;
	color_text.g := col_g;
	color_text.b := col_b;
	color_text.a := 255;
	p_text := StrAlloc(length(text)+1);
	StrPCopy(p_text,text);
	surface_text := TTF_RenderText_Blended(ttf_font, p_text, color_text);
	position_text.x := x;
	position_text.y := y;
	while (surface_text = nil) do
	begin
		surface_text := TTF_RenderText_Blended(ttf_font, p_text, color_text);
	end;
	position_text.w := surface_text^.w;
	position_text.h := surface_text^.h;
	texture_text := SDL_CreateTextureFromSurface(renderer, surface_text);
	SDL_RenderCopy(renderer, texture_text, nil, @position_text);
	TTF_CloseFont(ttf_font);
	SDL_DestroyTexture(texture_text);
	SDL_FreeSurface(surface_text);
	StrDispose(p_text);
end;

//genere tableau de bonus
procedure generate_bonus (renderer : PSDL_Renderer; tab_flamme : Array of objet; var map_bo: map_bonus; flamme_number, bonus_number, distance_interflamme : Integer; current_menu_state : menu_state);
var i, j, k: Integer;
	collision : Boolean;
	img_bonus_name : PAnsiChar;
begin
	for i := 1 to bonus_number do
	begin
		collision := True;
		if (current_menu_state = level5) then
			map_bo[i].type_bonus := random(8) + 1
		else
			map_bo[i].type_bonus := random(4) + 1;
		map_bo[i].objet_bonus.hitbox.w := 60;
		map_bo[i].objet_bonus.hitbox.h := 60;
		repeat
			collision := False;
			map_bo[i].objet_bonus.hitbox.x := random(((flamme_number div 2 + 2) * distance_interflamme) - 600 - distance_interflamme) + 600 + distance_interflamme;
			map_bo[i].objet_bonus.hitbox.y := random (460) + 50;
			for j := 1 to flamme_number do
			begin
				if ((intersect(tab_flamme[j].hitbox, map_bo[i].objet_bonus.hitbox)) or (map_bo[i].objet_bonus.hitbox.y + map_bo[i].objet_bonus.hitbox.h > 540)) then
				begin
					collision := True
				end;
				if (i > 1) then
					for k := 1 to i - 1 do
						if (intersect(map_bo[i].objet_bonus.hitbox, map_bo[k].objet_bonus.hitbox)) then
							collision := True
			end;
		until (collision = False);
		
		case map_bo[i].type_bonus of
			1,5,6 : img_bonus_name := 'assets/coeur.png';
			2 : img_bonus_name := 'assets/slow.png';
			3 : img_bonus_name := 'assets/tubepeinture.png';
			4,7,8 : img_bonus_name := 'assets/fast.png';
		end;
		load_obj(map_bo[i].objet_bonus, renderer, img_bonus_name , map_bo[i].objet_bonus.hitbox.x, map_bo[i].objet_bonus.hitbox.y, map_bo[i].objet_bonus.hitbox.w, map_bo[i].objet_bonus.hitbox.h, map_bo[i].objet_bonus.hitbox.x, map_bo[i].objet_bonus.hitbox.y, map_bo[i].objet_bonus.hitbox.w, map_bo[i].objet_bonus.hitbox.h, G_SCROLL_SPEED);
	end;
end;

//convertit un nombre en string
function itoa(n : Integer):String;
begin
	if ((n >= 0) and (n <= 9)) then
		itoa := chr(n + 48)
	else if ((n >= 10) and (n <= 99)) then
		itoa := (chr(n div 10 + 48) + chr(n mod 10 + 48));
end;

//permet d initialiser les parametres de jeu de chaque niveau
procedure set_param_level(current_menu_state : menu_state; var img_background : PansiChar; var flame_number, distance_interflamme, health_points, bonus_number, ecart_flamme, variance_flamme : Integer);
begin
	case current_menu_state of

		level1 : begin
		img_background := 'assets/fondlvl1.png';
		flame_number := 6;
		G_GRAVITY := 900;
		G_JUMPSPEED := 300;
		distance_interflamme := 400;
		G_BASE_HEALTH_POINTS := 100;
		health_points := G_BASE_HEALTH_POINTS;
		bonus_number := 3;
		ecart_flamme := 170;
		variance_flamme := 20;
		end;
		
		level2 : begin
		img_background := 'assets/fondlvl2.png';
		flame_number := 10;
		G_GRAVITY := 1200;
		G_JUMPSPEED := 300;
		distance_interflamme := 300;
		G_BASE_HEALTH_POINTS := 100;
		health_points := G_BASE_HEALTH_POINTS;
		bonus_number := 4;
		ecart_flamme := 125;
		variance_flamme := 40;
		end;
		
		level3 : begin
		img_background := 'assets/fondlvl3.png';
		flame_number := 14;
		G_GRAVITY := 400;
		G_JUMPSPEED := 300;
		distance_interflamme := 500;
		G_BASE_HEALTH_POINTS := 100;
		health_points := G_BASE_HEALTH_POINTS;
		bonus_number := 5;
		ecart_flamme := 170;
		variance_flamme := 30;
		end;
		
		level4 : begin
		img_background := 'assets/fondlvl4.png';
		flame_number := 16;
		G_GRAVITY := -900;
		G_JUMPSPEED := -300;
		distance_interflamme := 400;
		G_BASE_HEALTH_POINTS := 100;
		health_points := G_BASE_HEALTH_POINTS;
		bonus_number := 6;
		ecart_flamme := 180;
		variance_flamme := 40;
		end;
		
		level5 : begin
		img_background := 'assets/fondlvl5.png';
		flame_number := 15;
		G_GRAVITY := 900;
		G_JUMPSPEED := 300;
		distance_interflamme := 400;
		G_BASE_HEALTH_POINTS := 100;
		health_points := G_BASE_HEALTH_POINTS;
		bonus_number := 50;
		ecart_flamme := 115;
		variance_flamme := 35;
		end;
		
		level_endless : begin
		img_background := 'assets/fondlvl1.png';
		flame_number := 5;
		G_GRAVITY := 900;
		G_JUMPSPEED := 300;
		distance_interflamme := 350;
		G_BASE_HEALTH_POINTS := 50;
		health_points := G_BASE_HEALTH_POINTS;
		bonus_number := 1;
		ecart_flamme := 150;
		variance_flamme := 30;
		end;
	end;
end;

//gere toutes les collisions du cochon avec un bonus et met l effet du bonus si le cochon en touche un
procedure gestion_bonus(bonus_number : Integer; var health_points, timer_bonus : Integer; cochon : objet; var bonus_encre : Boolean; var map_bo : map_bonus;bonus_sound : PMix_Chunk);
var i,type_bonus : Integer;
begin
	type_bonus := 0;
	for i:=1 to bonus_number do
	begin
		if (cochon_touche(cochon, map_bo[i].objet_bonus)) then
		begin
			Mix_PlayChannel(3, bonus_sound, 0);
			type_bonus := map_bo[i].type_bonus;
			clean_image(map_bo[i].objet_bonus.texture);
			map_bo[i].objet_bonus.hitbox.x := -100;
			map_bo[i].objet_bonus.hitbox.y := -100;
		end;
	end;
	
	case type_bonus of
		1, 5, 6 : begin
				health_points := health_points + 20;
				if (health_points >= G_BASE_HEALTH_POINTS) then
					health_points := G_BASE_HEALTH_POINTS;
		end;
		2 : begin
				bonus_encre := False;
				timer_bonus := 1;
				G_SCROLL_SPEED := 50;
		end;
		3 : begin
				G_SCROLL_SPEED := BASE_SCROLL_SPEED;
				timer_bonus := 1;
				bonus_encre := True;
		end;
		4, 7, 8 : begin
				bonus_encre := False;
				timer_bonus := 1;
				G_SCROLL_SPEED := 250;
			end;
	end;
	
	if (timer_bonus >= DURATION_BONUS) then
	begin
		G_SCROLL_SPEED := BASE_SCROLL_SPEED;
		timer_bonus := 0;
		bonus_encre := False;
	end
	else if (timer_bonus >= 1) then
		timer_bonus := timer_bonus + 1;
end;

//met a jour en continu le tableau de flammes lorsque on joue en mode infini, augmente le score si on passe un tuyau
procedure update_objects_endless_level(var rendu : PSDL_Renderer; var tab_flammes : array_100_objects; distance_interflamme, ecart_flamme, variance_flamme : Integer; var score_endlesslvl : Integer; var hitbox_score_endlesslvl, hb_cochon : TSDL_Rect);
var i : Integer;
	tab_new_heights : tab_f;
begin
	if (intersect(hb_cochon, hitbox_score_endlesslvl)) then
	begin
		score_endlesslvl := score_endlesslvl + 1; 
		hitbox_score_endlesslvl.x := hitbox_score_endlesslvl.x + distance_interflamme;
		G_SCROLL_SPEED := G_SCROLL_SPEED + 5;
	end;
	if (tab_flammes[1].x_obj + tab_flammes[1].w_obj < 0) then
	begin
		for i := 1 to 8 do
		begin
			tab_flammes[i] := tab_flammes[i + 2];
		end;
		tab_new_heights := generate_height_flamme(ecart_flamme, variance_flamme);
		load_obj(tab_flammes[9], rendu, 'assets/top.png', tab_flammes[7].hitbox.x + distance_interflamme, tab_new_heights[1] - 700, 100 - 20, 700, tab_flammes[7].x_obj + distance_interflamme, tab_new_heights[1] - 700, 100, 700, G_SCROLL_SPEED);
		load_obj(tab_flammes[10], rendu, 'assets/bottom.png', tab_flammes[8].hitbox.x + distance_interflamme, tab_new_heights[2], 100 - 20, 700, tab_flammes[8].x_obj + distance_interflamme, tab_new_heights[2], 100, 700, G_SCROLL_SPEED);
	end;
end;

end.












