module bias_predictors
!$$$  module documentation block
!
! abstract: define predictors and basic operators
!
! program history log:
!   2007-04-16  tremolet - initial code
!
!$$$

use kinds, only: r_kind,i_kind
use constants, only : zero

implicit none
save
private
public predictors, allocate_preds, deallocate_preds, &
     & assignment(=), setup_predictors

type predictors
  real(r_kind), pointer :: values(:) => NULL()

  real(r_kind), pointer :: predr(:) => NULL()
  real(r_kind), pointer :: predp(:) => NULL()

  logical :: lallocated = .false.
end type predictors

integer(i_kind) :: nrclen,nsclen,npclen

logical :: llinit = .false.

! ----------------------------------------------------------------------
INTERFACE ASSIGNMENT (=)
MODULE PROCEDURE assign_scalar2preds, assign_preds2preds
END INTERFACE
! ----------------------------------------------------------------------
contains
! ----------------------------------------------------------------------
subroutine setup_predictors(krclen,ksclen,kpclen)
  implicit none
  integer(i_kind), intent(in) :: krclen,ksclen,kpclen

  nrclen=krclen
  nsclen=ksclen
  npclen=kpclen

  llinit = .true.

  return
end subroutine setup_predictors
! ----------------------------------------------------------------------
subroutine allocate_preds(yst)
  implicit none
  type(predictors), intent(inout) :: yst
  integer(i_kind) :: ii

  if (yst%lallocated) call abor1('allocate_preds: vector already allocated')

  ALLOCATE(yst%values(nrclen))
  yst%values = zero

  ii=0
  yst%predr => yst%values(ii+1:ii+nsclen)
  ii=ii+nsclen
  yst%predp => yst%values(ii+1:ii+npclen)
  ii=ii+npclen

  if (ii/=nrclen) CALL abor1("allocate_preds: error length")
  yst%lallocated = .true.

  return
end subroutine allocate_preds
! ----------------------------------------------------------------------
subroutine deallocate_preds(yst)
  implicit none
  type(predictors), intent(inout) :: yst

  if (yst%lallocated) then 
    NULLIFY(yst%predr)
    NULLIFY(yst%predp)
    DEALLOCATE(yst%values)
    yst%lallocated = .false.
  else
    write(6,*) 'deallocate_preds warning: trying to dealloc() vector not allocated'
  endif

  return
end subroutine deallocate_preds
! ----------------------------------------------------------------------
subroutine assign_scalar2preds(yst,pval)
  implicit none
  type(predictors), intent(inout) :: yst
  real(r_kind), intent(in) :: pval
  integer(i_kind) :: ii

  DO ii=1,nrclen
    yst%values(ii)=pval
  ENDDO

  return
end subroutine assign_scalar2preds
! ----------------------------------------------------------------------
subroutine assign_preds2preds(yst,xst)
  implicit none
  type(predictors), intent(inout) :: yst
  type(predictors), intent(in) :: xst
  integer(i_kind) :: ii

  DO ii=1,nrclen
    yst%values(ii)=xst%values(ii)
  ENDDO

  return
end subroutine assign_preds2preds
! ----------------------------------------------------------------------
end module bias_predictors
