unit types_and_constants;

interface

uses sdl2, sdl2_image;

//gravite en px/s^2, vitesse de defilement des elements dans le niveau en px/s, vitesse de saut du cochon en px/s, points de vie du cochon
var G_GRAVITY, G_SCROLL_SPEED, G_JUMPSPEED, G_BASE_HEALTH_POINTS : Integer;

//un objet a une texture une boite de collision et une vitesse
Type
	objet = record
	texture : PSDL_Texture;
	hitbox : TSDL_Rect;
	x_obj : Integer;
	y_obj : Integer;
	w_obj : Integer;
	h_obj : Integer;
	speed : Integer;
	//on affiche la texture avec les coordonnees de obj et on gere les collisions avec les coordonnees de la hitbox
end;

//un bonus est un objet avec un identifiant associe au type du bonus
Type
	bonus = record
	type_bonus : Integer;
	objet_bonus : objet;
end;

Type tab_f = Array[1..2] of Integer; //tableau contenant les positions de la flamme du haut et du bas
Type tab_n_f = Array[1..50] of tab_f; //tableau contenant les positions des couples de flamme du niveau
Type end_game_state = (zero_hp, level_won, none); //etat du joueur a la fin du niveau
Type map_bonus = Array[1..70] of bonus; //tableau avec tout les bonus du niveau
Type menu_state = (home, levels, level1, level2, level3, level4, level5, level_endless, closed); //etat du menu dans lequel le joueur est
Type array_100_objects = Array[1..100] of objet; //tableau de 100 objets

const
	SURFACEWIDTH = 960; 
	SURFACEHEIGHT = 540; //largeur et hauteur correspondant a la moitie de 1920 * 1080
	FPS = 30; //frequence de rafraichissement du jeu en frame/s
	DELAY_MS = ROUND(1/FPS*1000); //1/FPS en ms
	SPRITESIZE = 256; //taille des sprites du cochon
	DURATION_BONUS = 100; //duree des bonus (nombre de passages dans la boucle de jeu a 30 fps)
	BASE_SCROLL_SPEED = 150; //vitesse de defilement de base des elements du jeu
	SCORE_FILE_NAME = 'assets/fichier_score.txt'; //fichier contenant les scores du joueur
	FONT_NAME = 'assets/OpenSans-Bold.ttf'; //police de caractere du jeu
	AUDIO_FREQUENCY:WORD=44100; //frequence d echantillonnage
	AUDIO_FORMAT:WORD=AUDIO_S16; //format audio des sons joues
	AUDIO_CHANNELS:INTEGER=2; //sons joues en stereo
	AUDIO_CHUNKSIZE:INTEGER=1024; //latence a jouer un son
	
implementation
end.
