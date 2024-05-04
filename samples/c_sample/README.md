# Style

```c++
typedef struct _MyClass MyClass;
extern "C" MyClass *myclass_allocate(args) { return new MyClass(args); }
extern "C" void myclass_some_function();
extern "C" void myclass_delete(MyClass *obj) { delete obj; }
```
