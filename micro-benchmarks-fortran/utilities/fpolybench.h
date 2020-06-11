/**
 * polybench.h: This file is part of the PolyBench/Fortran 1.0 test suite.
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
/*
 * Polybench header for instrumentation.
 *
 * Programs must be compiled with `-I utilities utilities/polybench.c'
 *
 * Optionally, one can define:
 *
 * -DPOLYBENCH_TIME, to report the execution time,
 *   OR (exclusive):
 * -DPOLYBENCH_PAPI, to use PAPI H/W counters (defined in polybench.c)
 *
 *
 * See README or utilities/polybench.c for additional options.
 *
 */
#ifndef FPOLYBENCH_H
# define FPOLYBENCH_H

/* Array padding. By default, none is used. */
# ifndef POLYBENCH_PADDING_FACTOR
/* default: */
#  define POLYBENCH_PADDING_FACTOR 0
# endif


/* Initialize instruments macros to nothing */
#define polybench_start_instruments
#define polybench_stop_instruments
#define polybench_print_instruments
#define polybench_declare_instruments 
#define polybench_declare_prevent_dce_vars


/* PAPI support */
#ifdef POLYBENCH_PAPI
#undef polybench_start_instruments
#undef polybench_stop_instruments
#undef polybench_print_instruments
#undef polybench_declare_instruments 
#define polybench_declare_instruments \
      integer papi_evid, papi_estatus, polybench_setup_papi_event

#define polybench_start_instruments                            \
      call polybench_prepare_instruments();                    \
      call polybench_papi_init();                              \
      papi_evid = 0;                                           \
      do ;                                                     \
         papi_estatus = polybench_setup_papi_event(papi_evid); \
         if(papi_estatus == PAPI_EVENT_END) exit;              \
         if(papi_estatus == PAPI_START_FAIL) cycle;  

#define polybench_stop_instruments                             \
      call polybench_papi_stop_counter(papi_evid);             \
      papi_evid = papi_evid + 1;                               \
      end do;                                                  \
      call polybench_papi_close()

#define polybench_print_instruments call polybench_papi_print()

#define PAPI_EVENT_END 0
#define PAPI_START_FAIL 1
#define PAPI_START_SUCCESS 2
#endif


/* Timing support. */
#ifdef POLYBENCH_TIME
#undef polybench_start_instruments
#undef polybench_stop_instruments
#undef polybench_print_instruments
# define polybench_start_instruments call polybench_timer_start();
# define polybench_stop_instruments call polybench_timer_stop();
# define polybench_print_instruments call polybench_timer_print();
#endif


/* Scalar loop bounds in SCoPs. By default, use parametric loop bounds. */
# ifdef POLYBENCH_USE_SCALAR_LB
#  define POLYBENCH_LOOP_BOUND(x,y) x
# else
/* default: */
#  define POLYBENCH_LOOP_BOUND(x,y) y
# endif


/* Dead-code elimination macros. Use argc/argv for the run-time check. */
# ifndef POLYBENCH_DUMP_ARRAYS
#undef polybench_declare_prevent_dce_vars
#define polybench_declare_prevent_dce_vars \
      integer :: i;\
      character(LEN = 30) :: arg
#  define POLYBENCH_DCE_ONLY_CODE_BEGIN            \
      call getarg(1, arg);                         \
      if( IARGC() > 42 .AND.  arg .EQ. '' ) then;  
#  define POLYBENCH_DCE_ONLY_CODE_END              \
      end if
# else
#undef polybench_declare_prevent_dce_vars
#define polybench_declare_prevent_dce_vars \
      integer :: i
#  define POLYBENCH_DCE_ONLY_CODE_BEGIN
#  define POLYBENCH_DCE_ONLY_CODE_END
# endif

# define polybench_prevent_dce(func)\
  POLYBENCH_DCE_ONLY_CODE_BEGIN\
      call func;\
  POLYBENCH_DCE_ONLY_CODE_END



/* Macros for array declaration */
#ifndef POLYBENCH_STACK_ARRAYS
/* Heap */
#define POLYBENCH_1D_ARRAY_DECL(NAME, TYPE, SIZE) TYPE, dimension(:), allocatable :: NAME
#define POLYBENCH_2D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2) TYPE, dimension(:,:), allocatable :: NAME
#define POLYBENCH_3D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2, SIZE3) TYPE, dimension(:,:,:), allocatable :: NAME
#define POLYBENCH_4D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2, SIZE3, SIZE4) TYPE, dimension(:,:,:,:), allocatable :: NAME
#define POLYBENCH_5D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2, SIZE3, SIZE4, SIZE5) TYPE, dimension(:,:,:,:,:), allocatable :: NAME

#define POLYBENCH_ALLOC_1D_ARRAY(NAME, SIZE) allocate(NAME(SIZE+POLYBENCH_PADDING_FACTOR), STAT=I); call check_err(I) 
#define POLYBENCH_ALLOC_2D_ARRAY(NAME, SIZE1, SIZE2) allocate(NAME(SIZE1+POLYBENCH_PADDING_FACTOR,SIZE2+POLYBENCH_PADDING_FACTOR), STAT=I); call check_err(I) 
#define POLYBENCH_ALLOC_3D_ARRAY(NAME, SIZE1, SIZE2, SIZE3) allocate(NAME(SIZE1+POLYBENCH_PADDING_FACTOR,SIZE2+POLYBENCH_PADDING_FACTOR,SIZE3+POLYBENCH_PADDING_FACTOR), STAT=I); call check_err(I) 
#define POLYBENCH_ALLOC_4D_ARRAY(NAME, SIZE1, SIZE2, SIZE3, SIZE4) allocate(NAME(SIZE1+POLYBENCH_PADDING_FACTOR,SIZE2+POLYBENCH_PADDING_FACTOR,SIZE3+POLYBENCH_PADDING_FACTOR,SIZE4+POLYBENCH_PADDING_FACTOR), STAT=I); call check_err(I) 
#define POLYBENCH_ALLOC_5D_ARRAY(NAME, SIZE1, SIZE2, SIZE3, SIZE4, SIZE5) allocate(NAME(SIZE1+POLYBENCH_PADDING_FACTOR,SIZE2+POLYBENCH_PADDING_FACTOR,SIZE3+POLYBENCH_PADDING_FACTOR,SIZE4+POLYBENCH_PADDING_FACTOR,SIZE5+POLYBENCH_PADDING_FACTOR), STAT=I); call check_err(I) 

#define POLYBENCH_DEALLOC_ARRAY(NAME) deallocate(NAME)
#define POLYBENCH_FREE_ARRAY(NAME) deallocate(NAME)

#else
/* Stack */
#define POLYBENCH_1D_ARRAY_DECL(NAME, TYPE, SIZE) TYPE, dimension(SIZE+POLYBENCH_PADDING_FACTOR) :: NAME
#define POLYBENCH_2D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2) TYPE, dimension(SIZE1+POLYBENCH_PADDING_FACTOR, SIZE2+POLYBENCH_PADDING_FACTOR) :: NAME
#define POLYBENCH_3D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2, SIZE3) TYPE, dimension(SIZE1+POLYBENCH_PADDING_FACTOR, SIZE2+POLYBENCH_PADDING_FACTOR, SIZE3+POLYBENCH_PADDING_FACTOR) :: NAME
#define POLYBENCH_4D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2, SIZE3, SIZE4) TYPE, dimension(SIZE1+POLYBENCH_PADDING_FACTOR, SIZE2+POLYBENCH_PADDING_FACTOR, SIZE3+POLYBENCH_PADDING_FACTOR, SIZE4+POLYBENCH_PADDING_FACTOR) :: NAME
#define POLYBENCH_5D_ARRAY_DECL(NAME, TYPE, SIZE1, SIZE2, SIZE3, SIZE4, SIZE5) TYPE, dimension(SIZE1+POLYBENCH_PADDING_FACTOR, SIZE2+POLYBENCH_PADDING_FACTOR, SIZE3+POLYBENCH_PADDING_FACTOR, SIZE4+POLYBENCH_PADDING_FACTOR, SIZE5+POLYBENCH_PADDING_FACTOR) :: NAME

#define POLYBENCH_ALLOC_1D_ARRAY(NAME, SIZE)
#define POLYBENCH_ALLOC_2D_ARRAY(NAME, SIZE1, SIZE2)
#define POLYBENCH_ALLOC_3D_ARRAY(NAME, SIZE1, SIZE2, SIZE3)
#define POLYBENCH_ALLOC_4D_ARRAY(NAME, SIZE1, SIZE2, SIZE3, SIZE4)
#define POLYBENCH_ALLOC_5D_ARRAY(NAME, SIZE1, SIZE2, SIZE3, SIZE4, SIZE5)

#define POLYBENCH_DEALLOC_ARRAY(NAME)
#define POLYBENCH_FREE_ARRAY(NAME)
#endif

#endif
