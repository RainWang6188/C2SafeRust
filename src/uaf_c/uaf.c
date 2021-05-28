#include<stdio.h>
#include<stdlib.h>

struct A {
    void (*fnptr)(char* arg);
    char* buf;
};

struct B {
    int B1;
    int B2;
};

void vuln(void){
    printf("In vuln function!\n");
}

int main()
{
    struct A *a = (struct A*) malloc(sizeof(struct A));
    free(a);
    struct B *b = (struct B*) malloc(sizeof(struct B));
    b->B1 = &vuln;
    a->fnptr(a->buf);

    return 0;
}
