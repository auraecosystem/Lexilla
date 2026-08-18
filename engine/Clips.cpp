#include "stdafx.h"
#include "CLIPSEngine.h"

STDMETHODIMP CCLIPSEngine::Load(BSTR filePath, VARIANT_BOOL* success) {
    if (!m_clipsEnv) return E_FAIL;
    CW2A asciiPath(filePath);
    int status = EnvLoad(m_clipsEnv, asciiPath);
    *success = (status == 1) ? VARIANT_TRUE : VARIANT_FALSE;
    return S_OK;
}

STDMETHODIMP CCLIPSEngine::Reset() {
    EnvReset(m_clipsEnv);
    return S_OK;
}

STDMETHODIMP CCLIPSEngine::Assert(BSTR factString) {
    CW2A asciiFact(factString);
    EnvAssertString(m_clipsEnv, asciiFact);
    return S_OK;
}

STDMETHODIMP CCLIPSEngine::Run(LONG* rulesExecuted) {
    long count = EnvRun(m_clipsEnv, -1L);
    if (rulesExecuted) *rulesExecuted = count;
    return S_OK;
}

STDMETHODIMP CCLIPSEngine::Eval(BSTR expression, BSTR* result) {
    CW2A asciiExpr(expression);
    DATA_OBJECT doVal;
    EnvEval(m_clipsEnv, asciiExpr, &doVal);
    
    // Parse CLIPS String/Symbol return value
    const char* strRes = DOToString(m_clipsEnv, doVal);
    CComBSTR bstrResult(strRes ? strRes : "");
    *result = bstrResult.Detach();
    return S_OK;
}
