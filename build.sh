nasm -f elf64 ./key-locker-test.S
gcc -no-pie -o key-locker-test key-locker-test.o -lc -g
