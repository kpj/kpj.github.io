# ipy_pdcache: Automatically cache results of intensive computations in IPython

When dealing with important, long running computations, it is most often a good idea to save the results as soon as possible.
This can be combined with checking for existing data the next time a cell is executed and simply loading it from disk to avoid more computations.

This is easily implemented, but always requires some boilerplate code. [ipy_pdcache](https://github.com/kpj/ipy_pdcache) strips this away and enables caching of [pandas](https://pandas.pydata.org/) dataframes to CSV files:

```python
In [1]: %load_ext ipy_pdcache

In [2]: import pandas as pd

In [3]: %%pdcache df data.csv
   ...: df = pd.DataFrame({'A': [1, 2, 3], 'B': [4, 5, 6]})
   ...:

In [4]: !cat data.csv
,A,B
0,1,4
1,2,5
2,3,6
```
