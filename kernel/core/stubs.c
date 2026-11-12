/* Stubs de compatibilidade para isolar o runtime do KOF no KoffOS bare-metal */
void* __kof_heap_start = (void*)0x200000;
void* __kof_heap_end   = (void*)0x400000;
void* _end             = (void*)0x400000;

int pthread_create(void* thread, const void* attr, void* (*start_routine)(void*), void* arg) { return -1; }
int pthread_join(void* thread, void** retval) { return 0; }
unsigned long pthread_self(void) { return 1; }
int usleep(unsigned int usec) { return 0; }

/* Stub para satisfazer a chamada do entry.asm caso o símbolo gerado seja diferente */
void kof_main(void) {
    while (1) { __asm__("hlt"); }
}
