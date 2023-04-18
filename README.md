# Benchmarking

Benchmarks in this repository:

* `basic_term_benchmark`: Cashflow generation for a basic term life insurance policy
    * Julia [CacheFlow](https://github.com/actuarialopensource/CacheFlow.jl)
    * Python [LifeLib BasicTerm_M](https://github.com/lifelib-dev/lifelib/tree/main/lifelib/libraries/basiclife/BasicTerm_M)
* `exposures`: Create date partitions for experience studies
    * Julia [ExperienceAnalysis](https://github.com/JuliaActuary/ExperienceAnalysis.jl)
    * Julia [ExperienceAnalysis actuarialopensource fork](https://github.com/JuliaActuary/ExperienceAnalysis.jl)
    * R [actxps](https://github.com/mattheaphy/actxps)
* `mortality`: Read SOA mortality tables and use them in a simple calculation
    * Julia [MortalityTables](https://github.com/JuliaActuary/MortalityTables.jl)
    * Python [Pymort](https://github.com/actuarialopensource/pymort)

The below results are generated by the benchmarking scripts in the folders for each language. These scripts are run automatically by GitHub Actions and populate the results below. 

```yaml 
basic_term_benchmark:
- Julia CacheFlow basic_term:
    mean: TrialEstimate(1.239 s)
- Python lifelib basic_term_m:
    mean: 2601.6149545000003 milliseconds
  Python scratch basic_term_m:
    mean: 1024.7459456000001 milliseconds
exposures:
- Julia JuliaActuary ExperienceAnalysis:
    mean: TrialEstimate(92.349 ms)
    num_rows: 143166
  Julia actuarialopensource fork ExperienceAnalysis:
    mean: TrialEstimate(55.475 ms)
    num_rows: 141281
- R actxps:
    mean: 718.184426 ms
    num_rows: 141281
mortality:
- Julia MortalityTables.jl:
    mean: TrialEstimate(589.501 μs)
    result: 1904.4865526636793
- Python PyMort:
    mean: 2435.5273893000003 milliseconds
    result: 1904.4865526636793
```