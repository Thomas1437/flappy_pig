unit gestion_fichier;

interface

uses sysutils, types_and_constants;

Type tab_score = Array [1..6] of Integer;
Type fichier = Text;

function scores_tab(file_name: String):tab_score;
procedure modifier_score(current_menu_state: menu_state; file_name: String; new_score: Integer);

implementation

//cree un tableau avec les meilleurs scores de l utilisateur
function scores_tab(file_name: String):tab_score;
var i : integer;
	score : String;
	tab : tab_score;
	ft : fichier;
begin
	assign(ft, file_name);
	reset(ft);
	for i:=1 to 6 do
	begin
		readln(ft, score);
		tab[i]:= StrToInt(score);
	end;	
	close(ft);
	scores_tab := tab;
end;

//modifie le fichier si un nouveau meilleur score est fait
procedure modifier_score(current_menu_state: menu_state; file_name: String; new_score: Integer);
var line_to_change, i : Integer;
	ft : fichier;
	scores_user : tab_score;
begin
	scores_user := scores_tab(file_name);
	case current_menu_state of
		level1 : line_to_change := 1;
		level2 : line_to_change := 2;
		level3 : line_to_change := 3;
		level4 : line_to_change := 4;
		level5 : line_to_change := 5;
		level_endless : line_to_change := 6
	end;

	if (new_score > scores_user[line_to_change]) then
	begin
		assign(ft, file_name);
		rewrite(ft);
		for i := 1 to 6 do
		begin
			if (i = line_to_change) then
				writeln(ft, new_score)
			else 
				writeln(ft, scores_user[i]);
		end;
		close(ft);
	end;
end;

end.
