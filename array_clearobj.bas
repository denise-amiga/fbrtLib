/' ERASE for static arrays of objects: re-init the elements '/

#include "fb.bi"

extern "C"
sub fb_hArrayCtorObj( array as FBARRAY ptr, ctor as FB_DEFCTOR, base_idx as size_t )
	dim as size_t i, elements, element_len
	dim as FBARRAYDIM ptr _dim
	dim as ubyte ptr this_

	if ( array->_ptr = NULL ) then
		exit sub
	end if
	
	_dim = @array->dimTB(0)
	elements = _dim->elements - base_idx
	_dim += 1

	for i = 1 to array->dimensions
		elements *= _dim->elements
		_dim += 1
	next

	/' call ctors '/
	element_len = array->element_len
	this_ = array->_ptr

	while( elements > 0 )
		/' !!!FIXME!!! check exceptions (only if rewritten in C++) '/
		ctor( this_ )
		this_ += element_len
		elements -= 1
	wend
end sub

function fb_ArrayClearObj FBCALL ( array as FBARRAY ptr, ctor as FB_DEFCTOR, dtor as FB_DEFCTOR, dofill as long ) as long /' dofill = legacy '/
	/' destruct all objects in the array
	   (dtor can be NULL if there only is a ctor) '/
	if ( dtor <> 0 ) then
		fb_ArrayDestructObj( array, dtor )
	end if

	if( dofill <> 0 ) then
		/' re-initialize (ctor can be NULL if there only is a dtor) '/
		if( ctor <> 0) then
			/' if a ctor exists, it should handle the whole initialization '/
			fb_hArrayCtorObj( array, ctor, 0 )
		else
			/' otherwise, just clear '/
			fb_ArrayClear( array, 0 )
		end if
	end if

	return fb_ErrorSetNum( FB_RTERROR_OK )
end function
end extern