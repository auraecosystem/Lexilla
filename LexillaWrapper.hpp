#pragma once

#include <string>
#include <vector>
#include <memory>
#include <stdexcept>
#include <iostream>

#if defined(_WIN32)
  #define WIN32_LEAN_AND_MEAN
  #include <windows.h>
#else
  #include <dlfcn.h>
#endif

// Scintilla ILexer5 Minimal Abstract Interface
class ILexer5 {
public:
    virtual int Version() const = 0;
    virtual void Release() = 0;
    virtual void PropertySet(const char *key, const char *val) = 0;
    virtual void *PrivateCall(int operation, void *pointer) = 0;
    virtual int LineState(int line) = 0;
    virtual void Lex(unsigned int startPos, int lengthDoc, int initStyle, void *pAccess) = 0;
    virtual void Fold(unsigned int startPos, int lengthDoc, int initStyle, void *pAccess) = 0;
    virtual const char * DescribeProperty(const char *name) = 0;
    virtual const char * PropertyGet(const char *key) = 0;
    virtual const char * PropertyNames() = 0;
    virtual int PropertyType(const char *name) = 0;
    virtual const char * DescribeWordListSets() = 0;
};

// Custom deleter ensuring ILexer5 instances are released correctly
struct ILexerDeleter {
    void operator()(ILexer5* lexer) const noexcept {
        if (lexer) {
            lexer->Release();
        }
    }
};

using LexerHandle = std::unique_ptr<ILexer5, ILexerDeleter>;

class LexillaLibrary {
public:
    using GetLexerCountFn         = int (*)();
    using GetLexerNameFn          = void (*)(unsigned int, char *, int);
    using CreateLexerFn           = ILexer5 * (*)(const char *);
    using LexerNameFromIDFn       = const char * (*)(int);
    using GetLibraryPropertyNamesFn = const char * (*)();
    using SetLibraryPropertyFn    = void (*)(const char *, const char *);
    using GetNameSpaceFn          = const char * (*)();

    explicit LexillaLibrary(const std::string& path) {
#if defined(_WIN32)
        m_module = LoadLibraryA(path.c_str());
        if (!m_module) {
            throw std::runtime_error("Failed to load Lexilla DLL: " + path);
        }
        #define LOAD_FUNC(name) fn##name = reinterpret_cast<name##Fn>(GetProcAddress(m_module, #name))
#else
        m_module = dlopen(path.c_str(), RTLD_LAZY);
        if (!m_module) {
            throw std::runtime_error("Failed to load Lexilla dynamic library: " + std::string(dlerror()));
        }
        #define LOAD_FUNC(name) fn##name = reinterpret_cast<name##Fn>(dlsym(m_module, #name))
#endif

        LOAD_FUNC(GetLexerCount);
        LOAD_FUNC(GetLexerName);
        LOAD_FUNC(CreateLexer);
        LOAD_FUNC(LexerNameFromID);
        LOAD_FUNC(GetLibraryPropertyNames);
        LOAD_FUNC(SetLibraryProperty);
        LOAD_FUNC(GetNameSpace);

#undef LOAD_FUNC
    }

    ~LexillaLibrary() noexcept {
        if (m_module) {
#if defined(_WIN32)
            FreeLibrary(m_module);
#else
            dlclose(m_module);
#endif
        }
    }

    LexillaLibrary(const LexillaLibrary&) = delete;
    LexillaLibrary& operator=(const LexillaLibrary&) = delete;

    LexillaLibrary(LexillaLibrary&& other) noexcept : m_module(other.m_module) {
        other.m_module = nullptr;
    }

    // Enumerates all available lexers in the dynamic library
    [[nodiscard]] std::vector<std::string> GetAvailableLexers() const {
        std::vector<std::string> lexers;
        if (!fnGetLexerCount || !fnGetLexerName) return lexers;

        const int count = fnGetLexerCount();
        char buffer[256] = {};

        lexers.reserve(count);
        for (int i = 0; i < count; ++i) {
            fnGetLexerName(static_cast<unsigned int>(i), buffer, sizeof(buffer));
            lexers.emplace_back(buffer);
        }
        return lexers;
    }

    // Safely instantiates a lexer wrapped in an RAII smart pointer
    [[nodiscard]] LexerHandle CreateLexer(const std::string& lexerName) const {
        if (!fnCreateLexer) return nullptr;
        return LexerHandle(fnCreateLexer(lexerName.c_str()));
    }

    void SetProperty(const std::string& key, const std::string& value) const {
        if (fnSetLibraryProperty) {
            fnSetLibraryProperty(key.c_str(), value.c_str());
        }
    }

    [[nodiscard]] std::string GetNamespace() const {
        return fnGetNameSpace ? fnGetNameSpace() : "";
    }

private:
#if defined(_WIN32)
    HMODULE m_module = nullptr;
#else
    void* m_module = nullptr;
#endif

    GetLexerCountFn          fnGetLexerCount = nullptr;
    GetLexerNameFn           fnGetLexerName = nullptr;
    CreateLexerFn            fnCreateLexer = nullptr;
    LexerNameFromIDFn        fnLexerNameFromID = nullptr;
    GetLibraryPropertyNamesFn fnGetLibraryPropertyNames = nullptr;
    SetLibraryPropertyFn     fnSetLibraryProperty = nullptr;
    GetNameSpaceFn           fnGetNameSpace = nullptr;
};
