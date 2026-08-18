import "oaidl.idl";
import "ocidl.idl";

[
    object,
    uuid(9F3E8120-4E2A-4B81-8902-123456789ABC),
    dual,
    nonextensible,
    pointer_default(unique)
]
interface ICLIPSEngine : IDispatch {
    [id(1)] HRESULT Load([in] BSTR filePath, [out, retval] VARIANT_BOOL* success);
    [id(2)] HRESULT Reset();
    [id(3)] HRESULT Assert([in] BSTR factString);
    [id(4)] HRESULT Run([out, retval] LONG* rulesExecuted);
    [id(5)] HRESULT Eval([in] BSTR expression, [out, retval] BSTR* result);
};
