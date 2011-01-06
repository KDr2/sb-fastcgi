#
#
#

all: libfcgi.so

LDFLAGS += -shared -fPIC

SRCS = fcgiapp.c  fcgi_stdio.c  os_unix.c

OBJS = $(patsubst %.c, %.o, $(SRCS))

libfcgi.so: $(OBJS)
	$(CC) $(LDFLAGS) $^ $(LIBS) -o $@
	rm -f *.o 

clean:
	rm -f *.o libfcgi.so

