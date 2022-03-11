/* this ALWAYS GENERATED file contains the definitions for the interfaces */


/* File created by MIDL compiler version 5.01.0164 */
/* at Wed Jun 01 15:08:09 2005
 */
/* Compiler settings for C:\Projects\files\XMLSpyExeFolder\Examples\XMLSpyPlugInActiveX\IDEPlugInAsActiveX.idl:
    Oicf (OptLev=i2), W1, Zp8, env=Win32, ms_ext, c_ext
    error checks: allocation ref bounds_check enum stub_data 
*/
//@@MIDL_FILE_HEADING(  )


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 440
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __IDEPlugInAsActiveX_h__
#define __IDEPlugInAsActiveX_h__

#ifdef __cplusplus
extern "C"{
#endif 

/* Forward Declarations */ 

#ifndef __IIDESampleActiveX_FWD_DEFINED__
#define __IIDESampleActiveX_FWD_DEFINED__
typedef interface IIDESampleActiveX IIDESampleActiveX;
#endif 	/* __IIDESampleActiveX_FWD_DEFINED__ */


#ifndef __IDESampleActiveX_FWD_DEFINED__
#define __IDESampleActiveX_FWD_DEFINED__

#ifdef __cplusplus
typedef class IDESampleActiveX IDESampleActiveX;
#else
typedef struct IDESampleActiveX IDESampleActiveX;
#endif /* __cplusplus */

#endif 	/* __IDESampleActiveX_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

void __RPC_FAR * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void __RPC_FAR * ); 

#ifndef __IIDESampleActiveX_INTERFACE_DEFINED__
#define __IIDESampleActiveX_INTERFACE_DEFINED__

/* interface IIDESampleActiveX */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IIDESampleActiveX;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("D4711F68-57BD-44D3-B4D3-A511795D4FB1")
    IIDESampleActiveX : public IDispatch
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IIDESampleActiveXVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IIDESampleActiveX __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IIDESampleActiveX __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IIDESampleActiveX __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            IIDESampleActiveX __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            IIDESampleActiveX __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            IIDESampleActiveX __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            IIDESampleActiveX __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        END_INTERFACE
    } IIDESampleActiveXVtbl;

    interface IIDESampleActiveX
    {
        CONST_VTBL struct IIDESampleActiveXVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IIDESampleActiveX_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IIDESampleActiveX_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IIDESampleActiveX_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IIDESampleActiveX_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IIDESampleActiveX_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IIDESampleActiveX_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IIDESampleActiveX_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IIDESampleActiveX_INTERFACE_DEFINED__ */



#ifndef __IDEPLUGINASACTIVEXLib_LIBRARY_DEFINED__
#define __IDEPLUGINASACTIVEXLib_LIBRARY_DEFINED__

/* library IDEPLUGINASACTIVEXLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_IDEPLUGINASACTIVEXLib;

EXTERN_C const CLSID CLSID_IDESampleActiveX;

#ifdef __cplusplus

class DECLSPEC_UUID("6CBB8B79-357F-4065-92B7-478D8B44B0B6")
IDESampleActiveX;
#endif
#endif /* __IDEPLUGINASACTIVEXLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif
