unit gestion_menu;

interface

uses sdl2,sdl2_image, math, sdl2_ttf, sysutils, gestion_fichier, gestion_level, types_and_constants, SDL2_mixer;

procedure load_hitbox(var rect : TSDL_Rect; xhb, yhb, whb, hhb : Integer);
function intersect_mouse_rect(mx, my : Integer; hb : TSDL_Rect):Boolean;
procedure homescreen(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
procedure affiche_levels_finished_assets(var rendu : PSDL_Renderer);
procedure levels_menu(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
procedure affiche_ecran_mort(var rendu : PSDL_Renderer; var current_menu_state : menu_state; game_over : end_game_state);
procedure manager_menu(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
procedure start_level(var rendu : PSDL_Renderer; var current_menu_state : menu_state);

implementation

//charge une hitbox aux coordonnees donnees (utiles pour les boutons du menu)
procedure load_hitbox(var rect : TSDL_Rect; xhb, yhb, whb, hhb : Integer);
begin
	rect.x := xhb;
	rect.y := yhb;
	rect.w := whb;
	rect.h := hhb;
end;

//verifie si la souris est dans une hitbox
function intersect_mouse_rect(mx, my : Integer; hb : TSDL_Rect):Boolean;
begin
	intersect_mouse_rect := (mx > hb.x) and (mx < hb.x + hb.w) and (my > hb.y) and (my < hb.y + hb.h);
end;

//affiche l ecran d accueil du jeu
procedure homescreen(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
var event : TSDL_Event;
	cochon,homescreen: objet;
	Running : Boolean;
	anim_state, anim_sens,x_mid_screen, mouse_x, mouse_y: Integer;
	hb_quitter,hb_jouer : TSDL_Rect;
begin
	Mix_ResumeMusic;
	Running := True;
	anim_state := 1;
	anim_sens := 1;
	x_mid_screen := ceil(SURFACEWIDTH / 2);

	load_obj(cochon, rendu, 'assets/spritesheet3.png', x_mid_screen-SPRITESIZE div 2 -58 , -30, SPRITESIZE, SPRITESIZE, x_mid_screen-SPRITESIZE div 2-58, -30, SPRITESIZE, SPRITESIZE,0);
	load_obj(homescreen, rendu, 'assets/homescreen.png', 0, 0, 960, 540, 0, 0, 960, 540,0);
	load_hitbox(hb_quitter, 537,356,192,112);
	load_hitbox(hb_jouer, 242,352,192,112);
	while Running = True do
	begin
		while SDL_PollEvent(@event)<> 0 do
		begin
			if (event.type_ = SDL_MOUSEBUTTONDOWN) and (event.button.button = SDL_BUTTON_LEFT) then
			begin
				SDL_GetMouseState(@mouse_x, @mouse_y);
				if (intersect_mouse_rect(mouse_x,mouse_y,hb_quitter)) then
				begin
					clean_image(cochon.texture);
					clean_image(homescreen.texture);
					Running := False;
					current_menu_state := closed;
				end;
				if (intersect_mouse_rect(mouse_x,mouse_y,hb_jouer)) then
				begin
					clean_image(cochon.texture);
					clean_image(homescreen.texture);
					Running := False;
					current_menu_state := levels;
				end;
			end;
			if (event.type_=SDL_KEYDOWN) then
				if (event.key.keysym.sym = SDLK_ESCAPE) then
					Running := False;
		end;
		
		SDL_Delay(DELAY_MS);
		
		SDL_RenderClear(rendu);
		affiche_img(rendu,homescreen);
		affiche_cochon(rendu, cochon, anim_state, anim_sens);
		SDL_RenderPresent(rendu);
	end;
	Mix_PauseMusic;
	manager_menu(rendu, current_menu_state);
end;

//affiche les meilleurs scores et les checks verts sur le menu des niveaux
procedure affiche_levels_finished_assets(var rendu : PSDL_Renderer);
var user_scores : tab_score;
	tick : objet;
	i,y_ecriture : Integer;
begin
	user_scores := scores_tab(SCORE_FILE_NAME);
	for i := 1 to 5 do
	begin
		if (user_scores[i] > 0) then
		begin
			load_obj(tick, rendu, 'assets/tick.png', (253 * ((i - 1) mod 3) + 318), 45, 68, 68, (253 * ((i - 1) mod 3) + 318) mod 960, 45, 68, 68, 0);
			if (i >= 4) then
			begin
				tick.y_obj := 276;
				tick.hitbox.y := 276;
			end;
			affiche_img(rendu, tick);
			y_ecriture := 238;
			if (i >= 4) then
				y_ecriture := 469;
			ecrire(rendu, IntToStr(user_scores[i]), (253 * ((i - 1) mod 3) + 240), y_ecriture, 23, 253, 172, 171);
		end;
	end;
	ecrire(rendu, IntToStr(user_scores[6]), 746, 469, 23, 253, 172, 171);
end;

//affiche le menu avec les 6 niveaux
procedure levels_menu(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
var event : TSDL_Event;
	levels: objet;
	Running : Boolean;
	mouse_x, mouse_y, w_button, h_button: Integer;
	hb_retour, hb_lvl1, hb_lvl2, hb_lvl3, hb_lvl4, hb_lvl5, hb_lvl_inf : TSDL_Rect;
begin
	Mix_ResumeMusic;
	Running := True;
	w_button := 192;
	h_button := 125;
	
	load_obj(levels, rendu, 'assets/levels.png', 0, 0, 960, 540, 0, 0, 960, 540,0);
	load_hitbox(hb_retour, 36,36,96,96);
	load_hitbox(hb_lvl1, 159, 78, w_button, h_button);
	load_hitbox(hb_lvl2, 412, 78, w_button, h_button);
	load_hitbox(hb_lvl3, 665, 78, w_button, h_button);
	load_hitbox(hb_lvl4, 159, 310, w_button, h_button);
	load_hitbox(hb_lvl5, 412, 310, w_button, h_button);
	load_hitbox(hb_lvl_inf, 665, 310, w_button, h_button);
	affiche_img(rendu,levels);
	affiche_levels_finished_assets(rendu);
	SDL_RenderPresent(rendu);
	while Running = True do
	begin
		while SDL_PollEvent(@event)<> 0 do
		begin
			if (event.type_ = SDL_MOUSEBUTTONDOWN) and (event.button.button = SDL_BUTTON_LEFT) then
			begin
				SDL_GetMouseState(@mouse_x, @mouse_y);
				if (intersect_mouse_rect(mouse_x,mouse_y,hb_retour)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := home;
				end
				else if (intersect_mouse_rect(mouse_x, mouse_y, hb_lvl1)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := level1;
				end
				else if (intersect_mouse_rect(mouse_x, mouse_y, hb_lvl2)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := level2;
				end
				else if (intersect_mouse_rect(mouse_x, mouse_y, hb_lvl3)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := level3;
				end
				else if (intersect_mouse_rect(mouse_x, mouse_y, hb_lvl4)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := level4;
				end
				else if (intersect_mouse_rect(mouse_x, mouse_y, hb_lvl5)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := level5;
				end
				else if (intersect_mouse_rect(mouse_x, mouse_y, hb_lvl_inf)) then
				begin
					clean_image(levels.texture);
					Running := False;
					current_menu_state := level_endless;
				end;
			end;
			if (event.type_=SDL_KEYDOWN) then
				if (event.key.keysym.sym = SDLK_ESCAPE) then
					Running := False;
		end;
	end;
	Mix_PauseMusic;
	manager_menu(rendu, current_menu_state);
end;

//affiche l ecran de mort apres avoir perdu ou gagne un niveau
procedure affiche_ecran_mort(var rendu : PSDL_Renderer; var current_menu_state : menu_state; game_over : end_game_state);
var hb_replay, hb_menu : TSDL_Rect;
	event : TSDL_event;
	replay_menu_buttons, end_game_text : objet;
	mouse_x, mouse_y : Integer;
	Running : Boolean;
begin
	Running := True;
	
	load_obj(replay_menu_buttons, rendu, 'assets/replay_menu.png', 242, 352, 492, 125, 242, 352, 492, 125, 0);
	load_hitbox(hb_replay, 242, 352, 192, 112);
	load_hitbox(hb_menu, 537, 352, 192, 112);
	affiche_img(rendu, replay_menu_buttons);
	if (game_over = level_won) then
		load_obj(end_game_text, rendu, 'assets/victory_text.png', 0, 155, 960, 128, 0, 155, 960, 128, 0)
	else if (game_over = zero_hp) then
		load_obj(end_game_text, rendu, 'assets/defeat_text.png', 0, 155, 960, 128, 0, 155, 960, 128, 0);
	affiche_img(rendu, end_game_text);
	SDL_RenderPresent(rendu);
	while Running = True do
	begin
		while SDL_PollEvent(@event)<> 0 do
		begin
			if (event.type_ = SDL_MOUSEBUTTONDOWN) and (event.button.button = SDL_BUTTON_LEFT) then
			begin
				SDL_GetMouseState(@mouse_x, @mouse_y);
				if (intersect_mouse_rect(mouse_x,mouse_y,hb_replay)) then
				begin
					clean_image(replay_menu_buttons.texture);
					Running := False;
					current_menu_state := current_menu_state;
				end
				else if (intersect_mouse_rect(mouse_x,mouse_y,hb_menu)) then
				begin
					clean_image(replay_menu_buttons.texture);
					Running := False;
					current_menu_state := levels;
				end;
			end;
		end;
	end;
	manager_menu(rendu, current_menu_state);
end;

//permet de centraliser en une seule fonction tout les changements des niveaux au menu et inversement
//cela permet d eviter d empiler les appels de fonctions
procedure manager_menu(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
begin
	case current_menu_state of 
		home : homescreen(rendu, current_menu_state);
		levels : levels_menu(rendu, current_menu_state);
		level1 : start_level(rendu, current_menu_state);
		level2 : start_level(rendu, current_menu_state);
		level3 : start_level(rendu, current_menu_state);
		level4 : start_level(rendu, current_menu_state);
		level5 : start_level(rendu, current_menu_state);
		level_endless : start_level(rendu, current_menu_state);
	end;
end;

//permet de jouer le niveau selectionne par current_menu_state
procedure start_level(var rendu : PSDL_Renderer; var current_menu_state : menu_state);
var event : TSDL_Event;
	cochon,finish_line, fond, fondfeu, fond_rose, hitbox_score_endlesslvl, bacon: objet;
	Running, space_pressed, touche, bonus_encre : Boolean;
	tab_n_flammes : tab_n_f;
	tab_flammes_niv : array_100_objects;
	i, health_points, flame_number,anim_state, anim_sens, bonus_number, distance_interflamme, ecart_flamme, variance_flamme, timer_bonus, score_endlesslvl : Integer;
	game_over : end_game_state;
	map_bo : map_bonus;
	img_background : PAnsiChar;
	jump_sound, hit_sound, bonus_sound : PMix_Chunk;
begin
	Running := True;
	space_pressed := False;
	touche := False;
	flame_number := 6;
	health_points := G_BASE_HEALTH_POINTS;
	game_over := none;
	anim_state := 1;
	anim_sens := 1;
	bonus_number := 1;
	ecart_flamme := 130;
	variance_flamme := 20;
	timer_bonus := 0;
	bonus_encre := False;
	score_endlesslvl := 0;

	//charge les sons necessaires au niveau
	jump_sound := Mix_LoadWav('assets/wing_sound.mp3');
	if (jump_sound = nil) then
		writeln('echec wing : ', Mix_GetError);
	hit_sound := Mix_LoadWav('assets/frying_steak.mp3');
	if (hit_sound = nil) then
		writeln('echec steak : ', Mix_GetError);
	bonus_sound := Mix_LoadWav('assets/bonus_pickup.mp3');
	Mix_PlayChannel(2, hit_sound, 0);
	Mix_Pause(2);
	
	//charge tout les elements necessaires au niveau : les flammes, le cochon, les bonus
	G_SCROLL_SPEED := BASE_SCROLL_SPEED;
	set_param_level(current_menu_state, img_background, flame_number, distance_interflamme, health_points, bonus_number, ecart_flamme, variance_flamme);

	tab_n_flammes := generate_n_flammes(flame_number, ecart_flamme, variance_flamme);

	load_obj(cochon, rendu, 'assets/spritesheet3.png', 97, 88, 112, 64, 30, 10, 179, 179, 0);
	if (current_menu_state <> level_endless) then
		load_obj(finish_line, rendu, 'assets/finish.jpg', distance_interflamme * flame_number + 1000, 0, 100, SURFACEHEIGHT, distance_interflamme * flame_number + 920, 0, 100, SURFACEHEIGHT, G_SCROLL_SPEED);
	load_obj(fond, rendu, img_background, 0, 0, 960, 540, 0, 0, 960, 540, 0);
	load_obj(fondfeu, rendu, 'assets/fondfeu3.png', 0, 0, 960, 540, 0, 0, 960, 540, 0);
	load_obj(fond_rose, rendu, 'assets/fondpeinture.png', 0, 0, 960, 540, 0, 0, 960, 540,0);
	for i:=1 to flame_number do
	begin
		load_obj(tab_flammes_niv[2*i-1], rendu, 'assets/top.png', 500 + distance_interflamme * i + 10, tab_n_flammes[i][1] - 700, 100 - 20, 700, 500 + distance_interflamme * i, tab_n_flammes[i][1] - 700, 100, 700, G_SCROLL_SPEED);
		load_obj(tab_flammes_niv[2*i], rendu, 'assets/bottom.png', 500 + distance_interflamme * i + 10, tab_n_flammes[i][2], 100 - 20, 700, 500 + distance_interflamme * i, tab_n_flammes[i][2], 100, 700, G_SCROLL_SPEED);
	end;
	if (current_menu_state <> level_endless) then
		generate_bonus(rendu, tab_flammes_niv, map_bo, 2*flame_number, bonus_number, distance_interflamme, current_menu_state)
	else
		load_obj(hitbox_score_endlesslvl, rendu, 'assets/void.png',tab_flammes_niv[1].hitbox.x + tab_flammes_niv[1].hitbox.w, 0, 10, 540,0,0,0,0,G_SCROLL_SPEED);
	
	//verifie si la touche espace est pressee
	while Running = True do
	begin
		while SDL_PollEvent(@event)<> 0 do
		begin
			if (event.type_ = SDL_KEYUP) and (event.key.keysym.sym = SDLK_SPACE) then
				space_pressed := False;
			if (event.type_=SDL_KEYDOWN) then
			begin
				if (event.key.keysym.sym = SDLK_ESCAPE) then
					Running := False;
				if (event.key.keysym.sym = SDLK_SPACE) and (space_pressed = False) then
				begin
					space_pressed := True;
					Mix_PlayChannel(1, jump_sound, 0);
					jump_cochon(cochon);
				end;
			end;
		end;
		
		//deplacement de tout les elements du niveau
		chute_cochon(cochon);
		if (current_menu_state = level_endless) then
		begin
			move_flamme(hitbox_score_endlesslvl);
			update_objects_endless_level(rendu, tab_flammes_niv, distance_interflamme,ecart_flamme, variance_flamme, score_endlesslvl, hitbox_score_endlesslvl.hitbox, cochon.hitbox);
		end;
		for i:=1 to 2*flame_number do
		begin
			move_flamme(tab_flammes_niv[i]);
		end;
		if (current_menu_state <> level_endless) then
		begin
			for i:=1 to bonus_number do
				move_flamme(map_bo[i].objet_bonus);
		end;
		if (current_menu_state <> level_endless) then
		begin
			move_flamme(finish_line);
		end;
		
		//verification des collisions du cochon
		touche := False;
		for i:=1 to 2*flame_number do
		begin
			if (cochon_touche(cochon, tab_flammes_niv[i])) then
			begin
				Mix_Resume(2);
				touche := True;
				health_points := health_points - 1;
			end;
		end;
		
		//verification de la vie du cochon
		if (health_points <= 0) then
		begin;
			Running := False;
			game_over := zero_hp;
		end;
		if (current_menu_state <> level_endless) then
		begin
			if (cochon_touche(cochon, finish_line)) then
			begin
				Running := False;
				game_over := level_won;
			end;
		end;
		
		//gestion des bonus du niveau
		if (current_menu_state <> level_endless) then
		begin
			gestion_bonus(bonus_number, health_points, timer_bonus, cochon, bonus_encre,map_bo, bonus_sound);
		end;
		
		//affichage de tout les elements du niveau
		SDL_Delay(DELAY_MS);
		SDL_RenderClear(rendu);
		
		affiche_img(rendu,fond);
		if (touche = True) then
			affiche_img(rendu, fondfeu)
		else
			Mix_Pause(2);
		if (current_menu_state <> level_endless) then
		begin
			affiche_img(rendu, finish_line);
		end;
		affiche_cochon(rendu, cochon, anim_state, anim_sens);
		for i := 1 to 2*flame_number do
			affiche_img(rendu,tab_flammes_niv[i]);
		if (current_menu_state <> level_endless) then
		begin
			for i := 1 to bonus_number do
				affiche_img(rendu, map_bo[i].objet_bonus);
		end;
		if (bonus_encre = True) then
				affiche_img(rendu, fond_rose);
		if (current_menu_state = level_endless) then
		begin
			ecrire(rendu, itoa(score_endlesslvl), 20, 20, 50, 253, 172, 171);
		end;
		affiche_health_bar(health_points, rendu);

		SDL_RenderPresent(rendu);
	end;

	//si le joueur a perdu on reaffiche tout une derniere fois pour afficher le bacon
	if (game_over = zero_hp) then
	begin
		SDL_RenderClear(rendu);
		affiche_img(rendu,fond);
		affiche_img(rendu, fondfeu);
		if (current_menu_state <> level_endless) then
			affiche_img(rendu, finish_line);
		load_obj(bacon, rendu, 'assets/bacon.png', 0, 0 ,1 ,1, cochon.x_obj, cochon.y_obj, cochon.w_obj, cochon.h_obj, 0);
		for i := 1 to 2*flame_number do
			affiche_img(rendu,tab_flammes_niv[i]);
		if (current_menu_state <> level_endless) then
			for i := 1 to bonus_number do
				affiche_img(rendu, map_bo[i].objet_bonus);
		if (bonus_encre = True) then
			affiche_img(rendu, fond_rose);
		if (current_menu_state = level_endless) then
			ecrire(rendu, itoa(score_endlesslvl), 20, 20, 50, 253, 172, 171);
		affiche_health_bar(health_points, rendu);
		affiche_img(rendu, bacon);
		SDL_RenderPresent(rendu);
	end;
	
	//nettoie toute la memoire allouee pendant le niveau
	Mix_Pause(2);
	Mix_FreeChunk(jump_sound);
	Mix_FreeChunk(hit_sound);
	Mix_FreeChunk(bonus_sound);
	clean_image(cochon.texture);
	clean_image(bacon.texture);
	for i := 1 to 2*flame_number do
		clean_image(tab_flammes_niv[i].texture);
	if (current_menu_state <> level_endless) then
	begin
		for i := 1 to bonus_number do
			clean_image(map_bo[i].objet_bonus.texture);
	end;
	clean_image(fondfeu.texture);
	clean_image(fond.texture);
	if (current_menu_state <> level_endless) then
		clean_image(finish_line.texture);
	
	//gestion d un potentiel nouveau meilleur score
	if (game_over = level_won) then
		modifier_score(current_menu_state, SCORE_FILE_NAME, health_points);
	if (current_menu_state = level_endless) then
		modifier_score(current_menu_state, SCORE_FILE_NAME, score_endlesslvl);
	
	//affichage de l ecran de mort
	if ((game_over = zero_hp) or (game_over = level_won)) then
		affiche_ecran_mort(rendu, current_menu_state, game_over);
end;

end.
