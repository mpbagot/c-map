all :
	make libgtkhelp.a
	ponyc
out.o : gtk_helper.c
	gcc -c `pkg-config --cflags gtk+-3.0` -o out.o gtk_helper.c `pkg-config --libs gtk+-3.0`
libgtkhelp.a : out.o
	ar rcs libgtkhelp.a out.o
