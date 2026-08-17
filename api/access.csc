#if _WIN32
    typedef void *(__stdcall *CreateLexerFn)(const char *name);
#else
    typedef void *(*CreateLexerFn)(const char *name);
#endif
    QFunctionPointer fn = QLibrary::resolve("lexilla", "CreateLexer");
    void *lexCpp = ((CreateLexerFn)fn)("cpp");
    Call(SCI_SETILEXER, 0, (sptr_t)(void *)lexCpp);
