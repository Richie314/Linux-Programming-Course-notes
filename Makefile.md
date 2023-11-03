# GNU Makefile 

Lezione 03/11/2023

### Comandi da sapere bene
- ```grep```
- ```sed```
- ```awk```
- ```find```

Ricordarsi anche comandi ```top```, ```htop``` e ```taskset```, utili per troubleshooting, per esempio, sui server

### File system ```/sys/```
È virtuale serve per vedere/cambiare impostazioni varie
```cd /sys/devices/system/cpu/cpu{number}/``` permette di vedere cambiare parametri di una singola CPU, o almeno dovrebbe: molti produttori di hardware (es: Intel) non permetono di controllare frequenza in maniera definitiva.
```cd ./cpufreq``` e ```cd ./cpuidle``` contengono molte info utili su (rispettivamente) frequenze e latency.
```/sys/sysctl``` contiene altre impostazioni utili, es: riguardo swappiness, configurabile da ```/etc/fstab```, creabile da comando ```mkswap```

## Struttura di un Makefile
### Nome e sintassi comando
Il nome del file deve essere ```Makefile```, per avviare la compilazione lanciare ```make <nome_target>``` nella stessa cartella dove si trova il Makefile.
Make cercherà di creare il target utilizzando gli oggetti (prerequisiti) necessari, se sno già presenti (e non vanno aggiornati perché i loro sorgenti sono stati modificati) vengono linkati senza essere ricompilati, se non sono presenti cerca un target che li generi e si riapplica ricorsivamente.

Make può essere lanciato specificandogli il numeo di thread che può utilizzare in questo modo: ```make -jN <target>```, dove *N* è il numero dei thread da usare; omettendo *N* verranno usati tutti i core possibili (non è raccomandabile). Per una compilazione veloce si possono indicare anche più core di quelli disponibili sulla macchina (quelli in più andranno idle ogni tanto). È consigliabile, per progeti grossi, impostare comunque un *N* alto. 

Make senza target specificato eseguirà il primo target che trova nel Makefile.
Usare target ```all``` come primo del file, deve richiamare la compilazione principale
### Sintassi del file
```
target: <prerequisiti>
    comando 1
    comando 2
```
Le linee devono essere indentate con TAB, non con spazi!
#### Esempio semplice:
```Makefile
hello_world: hello_world.c main.c
    gcc -o hello_world hello_world.c main.c
```

#### Esempio più complesso:
hello_world.h:
```c
void hello_world();
```
hello_world.c:
```c
#include <stdio.h>
#include "hello_world.h"
void hello_world()
{
    printf("Hello, World\n");
}
```
main.c:
```c
#include "hello_world.h"
int main()
{
    hello_world();
    return 0;
}
```
Makefile:
```Makefile
# Definisco i flag da passare a gcc qui
GCC_FLAG = Wall -O3 -g
hello_world: hello_world.o main.o
    @echo "Linking the whole program..."
    gcc $(GCC_FLAG) -o hello_world hello_world.o main.o
hello_world.o: hello_world.c hello_world.h
    @echo "Compiling hello_world.c"
    gcc $(GCC_FLAG) -c -o hello_world.o hello_world.c
main.o: main.c hello_world.h
    @echo "Compiling main.c"
    gcc $(GCC_FLAG) -c -o main.o main.c
clean:
    rm -f hello_world *.o
```
Oppure (più corto ma complesso):
```Makefile
GCC_FLAG = Wall -O3 -g
LIBS = -lm # Librerie da passare a gcc
OUTPUT_NAME = hello_world
all: $(OUTPUT_NAME) # Richiama la compilazione principale
$(OUTPUT_NAME): hello_world.o main.o
    @echo "Linking the whole program..."
    gcc $(GCC_FLAG) -o $@ $^ $(LIBS)
%.o: %.c hello_world.h
    gcc $(GCC_FLAG) -c -o $@ $<
clean:
    rm -f hello_world *.o *.d
```
**Nota**: usare @<istruzione bash> per impedire che Make scriva sul terminale "Sto per eseguire <istruzione bash>" e fargli eseguire direttamente l'istruzione
Altri target utili possono essere *install*, *test*

### Dipendenze
```makedepend -- -Y *.c``` aggiunge le dipendenze (header) per ogni file sorgente al Makefile ma è più una funzione legacy, ignorando i file di sistema. A *makedepend* vanno passati gli stessi flag della compilazione.
```gcc -M``` aggiunge dipendenze al Makefile in maniera migliore
```Makefile
# Genereo dipendenze di ogni file .c in file con estenzione d (che verranno salvati su disco)
%.d: %.c
    gcc -M $(GCC_FLAG)-o $@ $<
# Listo i nomi dei sorgenti
SOURCE_FILES = $(wildcard *.c)
# Ottengo i nomi dei file di dipendenze dai nomi dei sorgenti
DEPENDENCY_FILES = $(patsubst %.c,%.d,$(SOURCE_FILES))
# Incorporo file di dipendenze nel Makefile
include $(DEPENDENCY_FILES)
```

### Vantaggi di Make
- Non compila file che sono già stati compilati
- Parallelismo: le dipendenze (prerequisititi) vengono organizzate in un grafo e i rami possono essere distribuiti tra diversi core
- Gestione di dipendenze
- Uno script bash gestirebbe la cosa con molta più complessità
