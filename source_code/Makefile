# Compilateur Pascal
PASCAL_COMPILER = fpc

# Noms des unités et du programme principal
UNITS = types_and_constants gestion_fichier gestion_level gestion_menu
PROGRAM = flappy_pig

# Règle par défaut
all: $(UNITS) $(PROGRAM)

# Règle pour compiler chaque unité
$(UNITS):
	$(PASCAL_COMPILER) $@.pas

# Règle pour compiler le programme principal
$(PROGRAM):
	$(PASCAL_COMPILER) $@.pas

# Règle pour exécuter le programme principal
run: $(PROGRAM)
	./$(PROGRAM)

# Règle pour nettoyer les fichiers générés lors de la compilation
clean:
	rm -f $(UNITS) *.o
	rm -f $(PROGRAM) *.o *.ppu

.PHONY: all clean run

