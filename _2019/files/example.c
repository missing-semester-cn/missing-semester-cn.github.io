#include <stdio.h>

const char *numbers[] = {
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten"
};

void say(int i)
{
    const char *msg = numbers[i-1];
    printf("%s\n", msg);
}

int main()
{
    for (int i = 1; i <= 10; i++) {
        say(i);
    }
}
