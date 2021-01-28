# pyskim: Quick summary statistics for dataframes

When starting out with a new data analysis project, familiarizing yourself with your data set is, of course, crucial (besides obtaining domain specific knowledge, etc).

This typically involves a set of somewhat repetitive steps such as value counts, histograms, scatterplots and so on.

[pyskim](https://github.com/kpj/pyskim) helps you achieve that goal as quickly and comfortably as possible.

Simply locate your CSV (or whichever delimiter is your favorite one) file and call `pyskim` from the commandline:

```bash
$ pyskim iris.csv
── Data Summary ────────────────────────────────────────────────────────────────────────────────────
type                 value
-----------------  -------
Number of rows         150
Number of columns        5
──────────────────────────────────────────────────
Column type frequency:
           Count
-------  -------
float64        4
string         1

── Variable type: number ───────────────────────────────────────────────────────────────────────────
    name            na_count    mean     sd    p0    p25    p50    p75    p100  hist
--  ------------  ----------  ------  -----  ----  -----  -----  -----  ------  ----------
 0  sepal_length           0    5.84  0.828   4.3    5.1   5.8     6.4     7.9  ▂▆▃▇▄▇▅▁▁▁
 1  sepal_width            0    3.06  0.436   2      2.8   3       3.3     4.4  ▁▁▄▅▇▆▂▂▁▁
 2  petal_length           0    3.76  1.77    1      1.6   4.35    5.1     6.9  ▇▃▁▁▂▅▆▄▃▁
 3  petal_width            0    1.2   0.762   0.1    0.3   1.3     1.8     2.5  ▇▂▁▂▂▆▁▄▂▃

── Variable type: string ───────────────────────────────────────────────────────────────────────────
    name               na_count    n_unique  top_counts
--  ---------------  ----------  ----------  -----------------------------------------
 0          species           0           3  versicolor: 50, setosa: 50, virginica: 50
```

It will tell you the most relevant dataframe properties at a glance, and additionally provide statistics for each column.
Which statistics are computed depends on the column's datatype and is customizable to adapt to your own custom datatypes.
