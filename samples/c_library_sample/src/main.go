package main

/*
#include <stdlib.h>
#cgo LDFLAGS: -L../build -lsample

extern int main_instance(int argc, char *argv[]);
*/
import "C"
import (
	"os"
	"unsafe"
)

func main() {
	argv := os.Args
	argc := len(argv)

	cArgv := make([]*C.char, argc)
	for i, s := range argv {
		cArgv[i] = C.CString(s)
	}
	defer func() {
		for _, ptr := range cArgv {
			C.free(unsafe.Pointer(ptr))
		}
	}()

	C.main_instance(C.int(argc), &cArgv[0])
}
