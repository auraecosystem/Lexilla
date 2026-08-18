int main() {
    try {
#if defined(_WIN32)
        LexillaLibrary lexilla("lexilla.dll");
#else
        LexillaLibrary lexilla("./liblexilla.so");
#endif

        // Configure library options
        lexilla.SetProperty("fold", "1");

        // Enumerate lexers
        std::cout << "Namespace: " << lexilla.GetNamespace() << "\nAvailable Lexers:\n";
        for (const auto& name : lexilla.GetAvailableLexers()) {
            std::cout << " - " << name << "\n";
        }

        // Instantiate C++ Lexer with automatic RAII management
        LexerHandle cppLexer = lexilla.CreateLexer("cpp");
        if (cppLexer) {
            cppLexer->PropertySet("fold.comment", "1");
            std::cout << "Successfully instantiated C++ lexer (Version " 
                      << cppLexer->Version() << ")\n";
        }
    } 
    catch (const std::exception& ex) {
        std::cerr << "Error: " << ex.what() << std::endl;
    }
    return 0; // Lexer and shared library automatically cleaned up here
}
