#pragma once
#include "ClipsCom_i.h"
extern "C" {
    #include "clips.h"
}

class ATL_NO_VTABLE CCLIPSEngine :
    public CComObjectRootEx<CComSingleThreadModel>,
    public CComCoClass<CCLIPSEngine, &CLSID_CLIPSEngine>,
    public IDispatchImpl<ICLIPSEngine, &IID_ICLIPSEngine, &LIBID_ClipsComLib, 1, 0>
{
private:
    void* m_clipsEnv;

public:
    CCLIPSEngine() {
        m_clipsEnv = CreateEnvironment();
    }

    ~CCLIPSEngine() {
        if (m_clipsEnv) DestroyEnvironment(m_clipsEnv);
    }

    BEGIN_COM_MAP(CCLIPSEngine)
        COM_INTERFACE_ENTRY(ICLIPSEngine)
        COM_INTERFACE_ENTRY(IDispatch)
    END_COM_MAP()

    DECLARE_REGISTRY_RESOURCEID(IDR_CLIPSENGINE)

    STDMETHOD(Load)(BSTR filePath, VARIANT_BOOL* success);
    STDMETHOD(Reset)();
    STDMETHOD(Assert)(BSTR factString);
    STDMETHOD(Run)(LONG* rulesExecuted);
    STDMETHOD(Eval)(BSTR expression, BSTR* result);
};
