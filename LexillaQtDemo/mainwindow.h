#pragma once

#include 
#include 
#include 

// Scintilla constant definition
#ifndef SCI_SETILEXER
#define SCI_SETILEXER 4033
#endif

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override = default;

private:
    void loadLexillaLexer();
    
    // Mock method signature representing your Scintilla editor control call
    void Call(unsigned int msg, uintptr_t wParam, intptr_t lParam);
};
