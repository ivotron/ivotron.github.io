---
layout: post
title: Analysis of second `mode=4` results
category: labnotebook
tags:
  - cephforhpc
  - cephforhpc-exp2
  - msst14
  - phdthesis
---

# Re-run

Based on the QA that was raised by me on the [analysis of the initial run][p], we 
launched a new experiment with the following:

  * fixed the blocksize to two large/small tests: 64mb/256k
  * ran on 32 clients, with up to 256 -np
  * chose `xfersize` for two large/small tests: 1m/4kb

The above is similar to FLASH3-IO. Based on results, we can choose 
other parameters that simulate MADBench2 or VORPAL-IO as in 
[@shan_characterizing_2008].

We're plotting for each test separately (with and without 
checkpointing turned on on each). The results are in [gdoc]. The data 
was prepared using scipy/pandas/etc (see snipet below).

# peak performance

We see peak performance of 250 mb/s at 64 nodes (2 processes per 
node). Can we improve that? Snapshot overhead is minimal, which is 
good.

# next steps

async io

# ipython session

```python

In [101]: e1m = pd.read_csv("/Users/ivo/projects/homepage/images/spreadsheets/expout_1m.csv", sep='\t', header=0)

In [102]: e1m.columns
Out[102]: Index([u'Operation', u'Max(MiB)', u'Min(MiB)', u'Mean(MiB)', u'StdDev', u'Mean(s)', u'Test', u'Tasks', u'tPN', u'reps', u'fPP', u'reord', u'reordoff', u'reordrand', u'seed', u'segcnt', u'blksiz', u'xsize', u'aggsize', u'API', u'RefNum'], dtype='object')

In [104]: e1m = e1m[[1,2,3,4,5,7]]

In [105]: e1m_stkd = pd.DataFrame(np.column_stack((e1m[::4], e1m[1::4], e1m[2::4])))

In [106]: e1m_stkd
Out[106]:
       0       1       2      3         4    5       6       7       8   \
0   48.04   43.20   46.75   1.27   1.37011    1   69.18   66.46   68.26
1   94.57   36.38   82.64  17.81   1.68214    2  138.75  104.90  130.30
2  142.36   82.28  120.42  18.13   2.18273    4  219.63  127.37  183.25
3  251.97   73.28  185.96  60.68   3.29244    8  418.94  172.45  289.29
4  335.72   77.89  243.18  72.69   4.98103   16  438.50  253.33  350.43
5  346.18  156.09  233.32  58.54   9.34267   32  500.68  322.94  388.51
6  361.36  161.95  248.10  56.85  17.42676   64  372.75  125.06  248.48
7  248.71  167.80  211.49  29.69  39.55522  128  332.96  131.13  204.66
8  206.97  140.91  169.88  21.70  97.97678  256  222.43  133.44  165.59

      9          10   11      12      13      14     15        16   17
0   0.75    0.93768    1   37.51   23.68   28.76   4.15   2.26766    1
1  11.65    0.99149    2   74.67   45.60   58.18   7.54   2.23548    2
2  37.37    1.46359    4  113.31   29.80   89.27  22.65   3.29951    4
3  66.29    1.87241    8  172.77  114.45  144.30  17.54   3.60432    8
4  65.79    3.03389   16  230.19   77.22  184.73  43.58   6.10093   16
5  56.50    5.37984   32  318.05  194.55  243.39  34.50   8.57443   32
6  83.20   18.76925   64  306.53  133.01  215.81  59.95  20.55603   64
7  64.74   43.60052  128  334.50  136.15  203.56  58.80  43.31269  128
8  24.35  100.88738  256  268.10  153.16  192.79  36.34  87.63701  256

[9 rows x 18 columns]

In [110]: e1m_stkd = e1m_stkd[[0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16]]

In [111]: e1m_stkd
Out[111]:
       0       1       2      3         4    5       6       7       8   \
0   48.04   43.20   46.75   1.27   1.37011    1   69.18   66.46   68.26
1   94.57   36.38   82.64  17.81   1.68214    2  138.75  104.90  130.30
2  142.36   82.28  120.42  18.13   2.18273    4  219.63  127.37  183.25
3  251.97   73.28  185.96  60.68   3.29244    8  418.94  172.45  289.29
4  335.72   77.89  243.18  72.69   4.98103   16  438.50  253.33  350.43
5  346.18  156.09  233.32  58.54   9.34267   32  500.68  322.94  388.51
6  361.36  161.95  248.10  56.85  17.42676   64  372.75  125.06  248.48
7  248.71  167.80  211.49  29.69  39.55522  128  332.96  131.13  204.66
8  206.97  140.91  169.88  21.70  97.97678  256  222.43  133.44  165.59

      9          10      12      13      14     15        16
0   0.75    0.93768   37.51   23.68   28.76   4.15   2.26766
1  11.65    0.99149   74.67   45.60   58.18   7.54   2.23548
2  37.37    1.46359  113.31   29.80   89.27  22.65   3.29951
3  66.29    1.87241  172.77  114.45  144.30  17.54   3.60432
4  65.79    3.03389  230.19   77.22  184.73  43.58   6.10093
5  56.50    5.37984  318.05  194.55  243.39  34.50   8.57443
6  83.20   18.76925  306.53  133.01  215.81  59.95  20.55603
7  64.74   43.60052  334.50  136.15  203.56  58.80  43.31269
8  24.35  100.88738  268.10  153.16  192.79  36.34  87.63701

[9 rows x 16 columns]

In [112]: e1m_stkd.columns = ['w_max', 'w_min', 'w_mean', 'w_stdev', 'w_mean_s', 'clients', 'r_max', 'r_min', 'r_mean', 'r_stdev', 'r_mean_s', 'ws_mas', 'ws_min', 'ws_mean', 'ws_stdev', 'ws_mean_s']

In [114]: e1m_mean_melted = pd.melt(e1m_stkd[['clients','w_mean', 'r_mean', 'ws_mean']], id_vars=['clients'])

In [115]: e1m_mean_melted
Out[115]:
    clients variable   value
0         1   w_mean   46.75
1         2   w_mean   82.64
2         4   w_mean  120.42
3         8   w_mean  185.96
4        16   w_mean  243.18
5        32   w_mean  233.32
6        64   w_mean  248.10
7       128   w_mean  211.49
8       256   w_mean  169.88
9         1   r_mean   68.26
10        2   r_mean  130.30
11        4   r_mean  183.25
12        8   r_mean  289.29
13       16   r_mean  350.43
14       32   r_mean  388.51
15       64   r_mean  248.48
16      128   r_mean  204.66
17      256   r_mean  165.59
18        1  ws_mean   28.76
19        2  ws_mean   58.18
20        4  ws_mean   89.27
21        8  ws_mean  144.30
22       16  ws_mean  184.73
23       32  ws_mean  243.39
24       64  ws_mean  215.81
25      128  ws_mean  203.56
26      256  ws_mean  192.79

[27 rows x 3 columns]

In [116]: e1m_mean_melted.columns = ['clients', "MiB (avg)", 'value']

In [117]: ggplot(e1m_mean_melted,  aes(x='clients', y='value', colour="MiB (avg)")) + geom_line()
Out[117]: <ggplot: (277392661)>

In [118]: e1m_stkd
Out[118]:
    w_max   w_min  w_mean  w_stdev  w_mean_s  clients   r_max   r_min  r_mean  \
0   48.04   43.20   46.75     1.27   1.37011        1   69.18   66.46   68.26
1   94.57   36.38   82.64    17.81   1.68214        2  138.75  104.90  130.30
2  142.36   82.28  120.42    18.13   2.18273        4  219.63  127.37  183.25
3  251.97   73.28  185.96    60.68   3.29244        8  418.94  172.45  289.29
4  335.72   77.89  243.18    72.69   4.98103       16  438.50  253.33  350.43
5  346.18  156.09  233.32    58.54   9.34267       32  500.68  322.94  388.51
6  361.36  161.95  248.10    56.85  17.42676       64  372.75  125.06  248.48
7  248.71  167.80  211.49    29.69  39.55522      128  332.96  131.13  204.66
8  206.97  140.91  169.88    21.70  97.97678      256  222.43  133.44  165.59

   r_stdev   r_mean_s  ws_mas  ws_min  ws_mean  ws_stdev  ws_mean_s
0     0.75    0.93768   37.51   23.68    28.76      4.15    2.26766
1    11.65    0.99149   74.67   45.60    58.18      7.54    2.23548
2    37.37    1.46359  113.31   29.80    89.27     22.65    3.29951
3    66.29    1.87241  172.77  114.45   144.30     17.54    3.60432
4    65.79    3.03389  230.19   77.22   184.73     43.58    6.10093
5    56.50    5.37984  318.05  194.55   243.39     34.50    8.57443
6    83.20   18.76925  306.53  133.01   215.81     59.95   20.55603
7    64.74   43.60052  334.50  136.15   203.56     58.80   43.31269
8    24.35  100.88738  268.10  153.16   192.79     36.34   87.63701

[9 rows x 16 columns]

In [119]: e4k = pd.read_csv("/Users/ivo/projects/homepage/images/spreadsheets/expout_4k.csv", sep='\t', header=0)

In [120]: e4k = e4k[[1,2,3,4,5,7]]

In [121]: e4k_stkd = pd.DataFrame(np.column_stack((e4k[::4], e4k[1::4], e4k[2::4])))

In [122]: e4k_stkd = e4k_stkd[[0,1,2,3,4,5,6,7,8,9,10,12,13,14,15,16]]

In [123]: e4k_stkd.columns = ['w_max', 'w_min', 'w_mean', 'w_stdev', 'w_mean_s', 'clients', 'r_max', 'r_min', 'r_mean', 'r_stdev', 'r_mean_s', 'ws_mas', 'ws_min', 'ws_mean', 'ws_stdev', 'ws_mean_s']

In [124]: e4k_mean_melted = pd.melt(e4k_stkd[['clients','w_mean', 'r_mean', 'ws_mean']], id_vars=['clients'])

In [125]: e4k_mean_melted.columns = ['clients', "MiB (avg)", 'value']

In [126]: ggplot(e4k_mean_melted,  aes(x='clients', y='value', colour="MiB (avg)")) + geom_line()
Out[126]: <ggplot: (277401077)>

In [128]: e4k_stkd
Out[128]:
   w_max  w_min  w_mean  w_stdev  w_mean_s  clients  r_max  r_min  r_mean  \
0   1.77   1.46    1.63     0.09   0.15387        1   4.52   3.64    4.33
1   3.31   1.54    2.90     0.54   0.18150        2   8.98   6.54    7.67
2   6.38   4.51    5.46     0.59   0.18540        4  15.32  11.72   14.22
3   9.88   4.17    7.74     1.64   0.27404        8  29.29  20.60   25.70
4  14.67  11.02   12.91     1.12   0.31219       16  52.75  32.37   39.66
5  21.08  15.85   18.60     1.75   0.43414       32  61.60  42.64   50.05
6  28.16  15.85   23.56     3.60   0.69842       64  74.77  50.92   66.94
7  30.99  10.43   23.07     6.91   1.58463      128  84.14  51.15   67.33
8  32.46  17.51   24.99     3.89   2.62776      256  84.90  53.34   77.03

   r_stdev  r_mean_s  ws_mas  ws_min  ws_mean  ws_stdev  ws_mean_s
0     0.25   0.05793    0.21    0.19     0.20      0.01    1.27117
1     0.71   0.06574    0.47    0.30     0.39      0.04    1.29578
2     1.19   0.07085    1.41    0.77     0.86      0.19    1.20268
3     2.73   0.07876    1.73    1.12     1.52      0.17    1.33207
4     6.03   0.10303    5.18    1.75     2.98      0.87    1.44441
5     6.87   0.16269    6.76    4.62     6.26      0.58    1.29142
6     6.82   0.24188   13.38    6.77    11.55      2.05    1.44780
7    10.04   0.48646   14.06    7.20    13.04      1.96    2.54918
8     8.74   0.84485   23.37    8.23    16.93      4.89    4.18882

[9 rows x 16 columns]

```

[p]: {% post_url 2014-02-04-cephforhpc-mode4-initial-experiments-analysis  %}
[gdoc]: https://docs.google.com/spreadsheet/ccc?key=0AnohAxx-m2sQdE1zZFZLNGJxMXB6R1UwQldzaEk5Mmc&usp=sharing
