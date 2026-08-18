#include "MainWindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent) {
    resize(800, 600);
    setWindowTitle("Qt + Lexilla Integration");
    loadLexillaLexer();
}

void MainWindow::loadLexillaLexer() {
#if defined(_WIN32)
    typedef void *(__stdcall *CreateLexerFn)(const char *name);
#else
    typedef void *(*CreateLexerFn)(const char *name);
#endif

    // Resolves "CreateLexer" from lexilla.dll / liblexilla.so / liblexilla.dylib
    QFunctionPointer fn = QLibrary::resolve("lexilla", "CreateLexer");
    
    if (!fn) {
        qWarning() << "Failed to resolve CreateLexer from Lexilla library.";
        return;
    }

    auto createLexer = reinterpret_cast(fn);
    void *lexCpp = createLexer("cpp");

    if (lexCpp) {
        qDebug() << "Successfully created C++ lexer instance:" << lexCpp;
        Call(SCI_SETILEXER, 0, reinterpret_cast(lexCpp));
    }
}

void MainWindow::Call(unsigned int msg, uintptr_t wParam, intptr_t lParam) {
    // Dispatch message to your Scintilla window/widget handle
    qDebug() << "Dispatched message to Scintilla:" << msg << "with lexer ptr:" << lParam;
}
