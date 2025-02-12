module fms_diag_register_mod

use fms_diag_data_mod, only: diag_files_type, diag_fields_type
use fms_diag_data_mod, only: monthly, daily, diurnal, yearly, no_diag_avergaing, instantaneous, &
     three_hourly, six_hourly, r8, r4, i8, i4, string
use fms_diag_data_mod, only: diag_error,fatal,note,warning

use fms_diag_concur_mod, only: diag_comm_init, fms_write_diag_comm, fms_diag_comm_type
use fms_diag_table_mod !get_diag_table_field

use fms_diag_object_mod



interface fms_register_diag_field
     module procedure fms_register_diag_field_generic
     module procedure fms_register_diag_field_scalar
end interface fms_register_diag_field


integer, allocatable :: diag_var_id_list (:) !< A list of potential diag IDs
integer, allocatable :: diag_var_id_used (:) !< A list of used diag IDs

CONTAINS
subroutine fms_register_diag_init(max_vars)
integer, intent(in) :: max_vars
integer :: i
allocate (integer :: diag_var_id_list (MAX_VARS))
allocate (integer :: diag_var_id_used (MAX_VARS))

!OMP PARALLEL DO shared(diag_var_id_list,diag_var_id_used, max_vars)
do i = 1 , MAX_VARS
     diag_var_id_list(i) = i
     diag_var_id_used(i) = 0
enddo
end subroutine fms_register_diag_init
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!> \description A generic routine to register a diagnostic field.  Here we allocate an unallocated 
!! diag object with some default values, and then we call the porcedure register to get the diag_id.
!! This only allocates the file object to fms_diag_object, and will be reallocated on the first send_data
!! call so that it can be set up for the correct type
 type(fms_diag_object) function fms_register_diag_field_generic (modname,varname,axes, time, longname, &
     units, missing_value, metadata) result(diagob)
 character(*)               , intent(in)               :: modname!< The module name
 character(*)               , intent(in)               :: varname!< The variable name
 integer     , dimension(:) , intent(in)               :: axes   !< The axes 
 integer                    , intent(in)               :: time !< Time placeholder 
 character(*)               , intent(in), optional     :: longname!< The variable long name
 character(*)               , intent(in), optional     :: units  !< Units of the variable
 integer                    , intent(in), optional     :: missing_value !< A missing value to be used 
 character(*), dimension(:) , intent(in), optional     :: metadata
 integer :: diag_id
!> Initialize the object
 call diagob%init_ob()
!> Register the diag_object.  This call has no axis
 call diagob%register_meta(modname, varname, axes, time, longname, units, missing_value, metadata) 
!> Get an ID number for the diagnostic 
  do i = 1,max_diag_vars
     if (diag_var_id_used (i) == 0) then 
          diag_var_id_used(i) = diag_var_id_list(i)
          diag_id = diag_var_id_list(i)
          exit
     endif
     if (i == max_diag_vars) then
          call diag_error("fms_register_diag_field_obj","You have registered too many diagnostics."//&
           "Please increase by setting MAX_DIAG_VARS in the diag_manager_nml",FATAL)
     endif
  enddo
 call diagob%setID(diag_id)
 call diagob%is_registered(.true.)
end function fms_register_diag_field_generic
!> \description A register routine for a scalar.  The scalar does not have any axis information, which is 
!! how you know its a scalar.  The return is an fms_diag_object_scalar.
 type(fms_diag_object_scalar) function fms_register_diag_field_scalar (modname, varname, time, longname, &
     units, missing_value, metadata) result(diagob)
 character(*)               , intent(in)               :: modname!< The module name
 character(*)               , intent(in)               :: varname!< The variable name
 integer                    , intent(in), optional     :: time !< Time placeholder 
 character(*)               , intent(in), optional     :: longname!< The variable long name
 character(*)               , intent(in), optional     :: units  !< Units of the variable
 integer                    , intent(in), optional     :: missing_value !< A missing value to be used 
 character(*), dimension(:) , intent(in), optional     :: metadata
 integer :: diag_id
!> Initialize the object
 call diagob%init_ob()
!> Register the diag_object.  This call has no axis
 call diagob%register_meta(modname, varname, time=time, longname=longname, units=units, &
                           missing_value=missing_value, metadata=metadata) 
!> Get an ID number for the diagnostic 
  do i = 1,max_diag_vars
     if (diag_var_id_used (i) == 0) then 
          diag_var_id_used(i) = diag_var_id_list(i)
          diag_id = diag_var_id_list(i)
          exit
     endif
     if (i == max_diag_vars) then
          call diag_error("fms_register_diag_field_obj","You have registered too many diagnostics."//&
           "Please increase by setting MAX_DIAG_VARS in the diag_manager_nml",FATAL)
     endif
  enddo
 call diagob%setID(diag_id)
 call diagob%is_registered(.true.)
end function fms_register_diag_field_scalar



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



end module fms_diag_register_mod
