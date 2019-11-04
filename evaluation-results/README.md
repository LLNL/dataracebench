## Database table list

|DB Table                    | Tool-Compiler                 |
|--------------------------- | ----------------------------- |
|archer10                    | archer1.0-clang3.9.1          |
|archer20_orig               | archer2.0-clang6.0.0          |
|archer20_rev                | archer2.0-clang6.0.0*         |
|inspector2018intel1702      | inspector2018-Intel17.0.2     |
|inspector2018intel1802      | inspector2018-Intel18.0.2     |
|inspector2018intel1900      | inspector2018-Intel19.0.0.117 |
|inspector2018intel1904      | inspector2018-Intel19.0.4.227 |
|inspector2019intel1702      | inspector2019-Intel17.0.2     |
|inspector2019intel1802      | inspector2019-Intel18.0.2     |
|inspector2019intel1900      | inspector2019-Intel19.0.0.117 |
|inspector2019intel1904      | inspector2019-Intel19.0.4.227 |
|romp                        | romp-clang8.0.0               |
|llvm5                       | tsan5.0.2-clang5.0.2          |
|llvm6                       | tsan6.0.1-clang6.0.1          |
|llvm7                       | tsan7.1.0-clang7.1.0          |
|llvm8                       | tsan8.0.1-clang8.0.1          |

\* Archer 2.0 with "export TSAN_OPTIONS="ignore_noninstrumented_modules=1" 


## Evaluation notes
Evaluations for ThreadSanitizer have OpenMP runtime with LIBOMP_TSAN_SUPPORT turned on.
