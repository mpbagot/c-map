gcc -c `pkg-config --cflags gtk+-3.0` -o out.o gtk_helper.c `pkg-config --libs gtk+-3.0`
ar rcs libgtkhelp.a out.o
ranlib libgtkhelp.a
ponyc
