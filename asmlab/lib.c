#include "lib.h"

funcCmp_t *getCompareFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcCmp_t *)&intCmp;
        break;
    case TypeString:
        return (funcCmp_t *)&strCmp;
        break;
    case TypeCard:
        return (funcCmp_t *)&cardCmp;
        break;
    default:
        break;
    }
    return 0;
}
funcClone_t *getCloneFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcClone_t *)&intClone;
        break;
    case TypeString:
        return (funcClone_t *)&strClone;
        break;
    case TypeCard:
        return (funcClone_t *)&cardClone;
        break;
    default:
        break;
    }
    return 0;
}
funcDelete_t *getDeleteFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcDelete_t *)&intDelete;
        break;
    case TypeString:
        return (funcDelete_t *)&strDelete;
        break;
    case TypeCard:
        return (funcDelete_t *)&cardDelete;
        break;
    default:
        break;
    }
    return 0;
}
funcPrint_t *getPrintFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcPrint_t *)&intPrint;
        break;
    case TypeString:
        return (funcPrint_t *)&strPrint;
        break;
    case TypeCard:
        return (funcPrint_t *)&cardPrint;
        break;
    default:
        break;
    }
    return 0;
}

/** Int **/

int32_t intCmp(int32_t *a, int32_t *b)
{
    if (*b < *a)
        return -1;
    return *a < *b;
}

void intDelete(int32_t *a)
{
    free(a);
}

void intPrint(int32_t *a, FILE *pFile)
{
    fprintf(pFile, "%i", *a);
}

int32_t *intClone(int32_t *a)
{
    int32_t *cloneA = (int32_t *)malloc(sizeof(int32_t));
    if (cloneA != NULL) {
        *cloneA = *a;
    }
    return cloneA;
}

/** Lista **/

list_t *listNew(type_t t)
{
    list_t *l = calloc(1, sizeof(list_t));
    l->type = t;
    return l;
}

uint8_t listGetSize(list_t *l)
{
    return l->size;
}

void *listGet(list_t *l, uint8_t i)
{
    if (!l || i >= l->size)
        return 0;
    struct s_listElem *elem = l->first;
    for (int j = 0; j < i; j++)
        elem = elem->next;
    return elem->data;
}

/**
 * Reserva memoria para un elemento de lista y lo inicializa con sus elementos en 0.
 * Realiza una copia del dato pasado por parámetro y lo almacena en el elemento.
 * Devuelve el elemento.
*/
struct s_listElem *elemNew(type_t t, void *data) {
    struct s_listElem *elem = calloc(1, sizeof(struct s_listElem));
    funcClone_t *funcClone = getCloneFunction(t);
    void *dataCopy = funcClone(data);
    elem->data = dataCopy;
    return elem;
}

void listAddFirst(list_t *l, void *data)
{
    if (!l)
        return;
    struct s_listElem *newElem = elemNew(l->type, data);
    if (l->size == 0) {
        l->last = newElem;
    } else {
        l->first->prev = newElem;
    }    
    newElem->next = l->first;
    l->first = newElem;
    l->size++;
}

void listAddLast(list_t *l, void *data)
{
    if (!l)
        return;
    if (l->size == 0) {
        listAddFirst(l, data);
        return;
    }
    struct s_listElem *newElem = elemNew(l->type, data);
    l->last->next = newElem;
    newElem->prev = l->last;
    l->last = newElem;
    l->size++;
}

list_t *listClone(list_t *l)
{
    if (!l)
        return 0;
    list_t *newList = listNew(l->type);
    newList->type = l->type;
    struct s_listElem *elem = l->first;
    for (int i = 0; i < l->size; i++) {
        listAddLast(newList, elem->data);
        elem = elem->next;
    }
    return newList;
}

void *listRemove(list_t *l, uint8_t i)
{
    void *removedData = 0;
    if (!l || i >= l->size || l->size == 0)
        return removedData;
    struct s_listElem *removedElem = l->first;
    if (i == 0) {
        l->first = removedElem->next;
        if (l->first)
            l->first->prev = 0;
    } else if (i == l->size - 1) {
        removedElem = l->last;
        l->last = removedElem->prev;
        l->last->next = 0;
    } else {
        for (int j = 0; j < i; j++)
            removedElem = removedElem->next;
        struct s_listElem *prevElem = removedElem->prev;
        struct s_listElem *nextElem = removedElem->next;
        prevElem->next = nextElem;
        nextElem->prev = prevElem;
    }
    removedData = removedElem->data;
    l->size--;
    free(removedElem);
    return removedData;
}

void listSwap(list_t *l, uint8_t i, uint8_t j)
{
    if (!l || i >= l->size || j >= l->size)
        return;
    struct s_listElem *iElem = l->first;
    struct s_listElem *jElem = l->first;
    for (int a = 0; a < i; a++)
        iElem = iElem->next;
    for (int b = 0; b < j; b++)
        jElem = jElem->next;
    void *iElemData = iElem->data;
    iElem->data = jElem->data;
    jElem->data = iElemData;
}

void listDelete(list_t *l)
{
    if (!l)
        return;
    funcDelete_t *deleteData = getDeleteFunction(l->type);
    int size = listGetSize(l);
    for (int i = 0; i < size; i++) {
        void *removedData = listRemove(l, 0);
        deleteData(removedData);
    }
    free(l);
}

void listPrint(list_t *l, FILE *pFile)
{
    if (!l || l->size == 0) {
        fprintf(pFile, "[]");
        return;
    }
    funcPrint_t *printData = getPrintFunction(l->type);
    fprintf(pFile, "[");
    struct s_listElem *elem = l->first;
    while (elem->next) {
        printData(elem->data, pFile);
        fprintf(pFile, ",");
        elem = elem->next;
    }
    if (elem)
        printData(elem->data, pFile);
    fprintf(pFile, "]");
}

/** Game **/

game_t *gameNew(void *cardDeck, funcGet_t *funcGet, funcRemove_t *funcRemove, funcSize_t *funcSize, funcPrint_t *funcPrint, funcDelete_t *funcDelete)
{
    game_t *game = (game_t *)malloc(sizeof(game_t));
    game->cardDeck = cardDeck;
    game->funcGet = funcGet;
    game->funcRemove = funcRemove;
    game->funcSize = funcSize;
    game->funcPrint = funcPrint;
    game->funcDelete = funcDelete;
    return game;
}
int gamePlayStep(game_t *g)
{
    int applied = 0;
    uint8_t i = 0;
    while (applied == 0 && i + 2 < g->funcSize(g->cardDeck))
    {
        card_t *a = g->funcGet(g->cardDeck, i);
        card_t *b = g->funcGet(g->cardDeck, i + 1);
        card_t *c = g->funcGet(g->cardDeck, i + 2);
        if (strCmp(cardGetSuit(a), cardGetSuit(c)) == 0 || intCmp(cardGetNumber(a), cardGetNumber(c)) == 0)
        {
            card_t *removed = g->funcRemove(g->cardDeck, i);
            cardAddStacked(b, removed);
            cardDelete(removed);
            applied = 1;
        }
        i++;
    }
    return applied;
}
uint8_t gameGetCardDeckSize(game_t *g)
{
    return g->funcSize(g->cardDeck);
}
void gameDelete(game_t *g)
{
    g->funcDelete(g->cardDeck);
    free(g);
}
void gamePrint(game_t *g, FILE *pFile)
{
    g->funcPrint(g->cardDeck, pFile);
}
