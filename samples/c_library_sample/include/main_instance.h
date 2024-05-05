#ifndef MAIN_INSTANCE_H
#define MAIN_INSTANCE_H

#include <gdextension_interface.h>
#include <godot_cpp/classes/godot_instance.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

extern "C" {

typedef struct {
  void *handle;
  GDExtensionObjectPtr (*func_gdextension_create_godot_instance)(
      int, char *[], GDExtensionInitializationFunction);
} LibGodot;

static void initialize_default_module(godot::ModuleInitializationLevel p_level);
static void uninitialize_default_module(godot::ModuleInitializationLevel p_level);

GDExtensionBool GDE_EXPORT gdextension_default_init(GDExtensionInterfaceGetProcAddress p_get_proc_address,
                         GDExtensionClassLibraryPtr p_library,
                         GDExtensionInitialization *r_initialization);

LibGodot *libgodot_new(const char *p_path);
void libgodot_delete(LibGodot *self);
int main_instance(int argc, char **argv);

}

#endif // MAIN_INSTANCE_H
