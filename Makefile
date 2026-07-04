
TARGET      ?= usage.cast
OUTPUT       = output.txt

NORMAL       = -s 1.0
RAPIDO       = -s 1.5
INTANTANEO   = -s 4.5
ULTRA        = -s 6.5
#SPEED        = $(NORMAL)
#SPEED        = $(RAPIDO)
#SPEED        = $(INTANTANEO)
SPEED        = $(ULTRA)

ASCIINEMA_240 = asciinema
ASCIINEMA_321 = ~/git/asciinema

play:
	$(ASCIINEMA_240) play $(SPEED) $(TARGET)
record:
	$(ASCIINEMA_240) rec $(TARGET)
cat:
	$(ASCIINEMA_240) cat $(TARGET)
totext:
	~/git/asciinema convert $(TARGET) $(OUTPUT)

clean:
	rm $(OUTPUT)
