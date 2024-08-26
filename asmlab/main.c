#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

int main(void) {
    FILE *fileArray = fopen("prueba_juego_array.txt", "w");
    FILE *fileList = fopen("prueba_juego_list.txt", "w");
    char *oro = "Oro", *basto = "Basto", *espada = "Espada", *copas = "Copas";
    int n1 = 1, n2 = 2, n3 = 3, n4 = 4;
    card_t *c1 = cardNew(oro, &n1), *c2 = cardNew(basto, &n2), *c3 = cardNew(espada, &n3),
           *c4 = cardNew(copas, &n4), *c5 = cardNew(espada, &n1);

    //CASO ARRAY
    array_t *mazoArray = arrayNew(TypeCard, 5);
    arrayAddLast(mazoArray, c1);
    arrayAddLast(mazoArray, c2);
    arrayAddLast(mazoArray, c3);
    arrayAddLast(mazoArray, c4);
    arrayAddLast(mazoArray, c5);
    arrayPrint(mazoArray, fileArray);
    fputc('\n', fileArray);
    cardAddStacked(arrayGet(mazoArray, 0), arrayGet(mazoArray, 2));
    arrayPrint(mazoArray, fileArray);
    arrayDelete(mazoArray);

    //CASO LIST
    list_t *mazoList = listNew(TypeCard);
    listAddLast(mazoList, c1);
    listAddLast(mazoList, c2);
    listAddLast(mazoList, c3);
    listAddLast(mazoList, c4);
    listAddLast(mazoList, c5);
    listPrint(mazoList, fileList);
    fputc('\n', fileList);
    cardAddStacked(listGet(mazoList, 0), listGet(mazoList, 2));
    listPrint(mazoList, fileList);
    listDelete(mazoList);
    
    cardDelete(c1);
    cardDelete(c2);
    cardDelete(c3);
    cardDelete(c4);
    cardDelete(c5);

    fclose(fileArray);
    fclose(fileList);
}

