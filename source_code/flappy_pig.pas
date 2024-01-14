program flappy_pig;

uses types_and_constants, gestion_level, gestion_menu, sdl2,sdl2_image, math, sdl2_ttf, sysutils, SDL2_mixer;

var	fenetre: PSDL_WINDOW;
	rendu: PSDL_Renderer;
	current_menu_state : menu_state;
	home_music : PMix_Music;
begin
	Randomize;
	initialise(fenetre, rendu, home_music);
	current_menu_state := home;
	manager_menu(rendu,current_menu_state);
	termine(fenetre, rendu, home_music);
end.
