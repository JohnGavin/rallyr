# tennis_db_schema() output is stable

    Code
      as.data.frame(schema)
    Output
              table_name            column_name data_type ordinal_position
      1          matches               bh_shots   INTEGER               23
      2          matches           bh_speed_mph    DOUBLE               25
      3          matches           duration_min   INTEGER                6
      4          matches               fh_shots   INTEGER               22
      5          matches           fh_speed_mph    DOUBLE               24
      6          matches             is_doubles   BOOLEAN                9
      7          matches               latitude    DOUBLE               13
      8          matches               location   VARCHAR               10
      9          matches              longitude    DOUBLE               14
      10         matches               match_id   INTEGER                1
      11         matches              me_run_mi    DOUBLE               19
      12         matches               me_shots   INTEGER               16
      13         matches            me_shots_in   INTEGER               17
      14         matches             opp_run_mi    DOUBLE               21
      15         matches              opp_shots   INTEGER               20
      16         matches               opponent   VARCHAR               15
      17         matches                outdoor   BOOLEAN               12
      18         matches              played_at   VARCHAR                3
      19         matches                returns    DOUBLE               28
      20         matches                 serves    DOUBLE               26
      21         matches              serves_in    DOUBLE               27
      22         matches           session_date   VARCHAR                4
      23         matches           session_type   VARCHAR                8
      24         matches            share_token   VARCHAR                2
      25         matches           shots_in_pct    DOUBLE               18
      26         matches                  sport   VARCHAR                7
      27         matches             start_time   VARCHAR                5
      28         matches                surface   VARCHAR               11
      29         matches                 winner   VARCHAR               29
      30         rallies           duration_sec    DOUBLE                4
      31         rallies               end_time   VARCHAR                3
      32         rallies               match_id   INTEGER                9
      33         rallies                n_shots   INTEGER                5
      34         rallies               rally_id   INTEGER                1
      35         rallies                 regime   VARCHAR                7
      36         rallies      regime_occurrence   INTEGER                8
      37         rallies          segment_index    DOUBLE                6
      38         rallies             start_time   VARCHAR                2
      39 session_weather               match_id   INTEGER                1
      40 session_weather                 temp_c    DOUBLE                2
      41 session_weather           wind_avg_kmh    DOUBLE                3
      42 session_weather          wind_gust_kmh    DOUBLE                4
      43     shot_detail               hit_type   VARCHAR                6
      44     shot_detail               hit_wing   VARCHAR                7
      45     shot_detail               match_id   INTEGER                1
      46     shot_detail                 player   VARCHAR                4
      47     shot_detail               rally_id   INTEGER                3
      48     shot_detail                 regime   VARCHAR               12
      49     shot_detail      regime_occurrence   INTEGER               13
      50     shot_detail          segment_index   INTEGER               11
      51     shot_detail                shot_id   INTEGER                2
      52     shot_detail                shot_in   BOOLEAN               10
      53     shot_detail         shot_speed_mph    DOUBLE                9
      54     shot_detail              spin_type   VARCHAR                8
      55     shot_detail             started_at   VARCHAR                5
      56   shot_segments           duration_min    DOUBLE                5
      57   shot_segments               end_time   VARCHAR                4
      58   shot_segments           guest_in_pct    DOUBLE               14
      59   shot_segments   guest_speed_mean_mph    DOUBLE               12
      60   shot_segments guest_speed_median_mph    DOUBLE               13
      61   shot_segments               match_id   INTEGER               15
      62   shot_segments        n_guest_gs_left   INTEGER               10
      63   shot_segments       n_guest_gs_right   INTEGER               11
      64   shot_segments          n_guest_shots   INTEGER                8
      65   shot_segments           n_host_shots   INTEGER                7
      66   shot_segments                n_shots   INTEGER                6
      67   shot_segments                 regime   VARCHAR                2
      68   shot_segments      regime_occurrence   INTEGER                9
      69   shot_segments          segment_index   INTEGER                1
      70   shot_segments             start_time   VARCHAR                3

# merge_same_day_sessions() output is stable

    Code
      as.data.frame(m)
    Output
        session_date           played_at start_times n_parts        opponent
      1   2030-01-05 2030-01-05 16:00:00       16:00       1 Sample Opponent
      2   2030-01-12 2030-01-12 18:00:00       18:00       1 Sample Opponent
      3   2030-01-19 2030-01-19 13:00:00       13:00       1 Sample Opponent
      4   2030-01-26 2030-01-26 18:00:00       18:00       1 Sample Opponent
      5   2030-02-02 2030-02-02 14:00:00       14:00       1 Sample Opponent
      6   2030-02-09 2030-02-09 09:00:00       09:00       1 Sample Opponent
                                location duration_min me_shots me_shots_in me_run_mi
      1   Sample Tennis Club (synthetic)           23      242         203      0.87
      2   Sample Tennis Club (synthetic)           21      228         166      0.45
      3 Sample Sports Centre (synthetic)           22      229         167      0.75
      4 Sample Sports Centre (synthetic)           20      201         167      0.73
      5 Sample Sports Centre (synthetic)           21      232         189      0.97
      6 Sample Sports Centre (synthetic)           23      234         183      1.07
        opp_shots opp_run_mi fh_speed_mph bh_speed_mph fh_shots bh_shots shots_in_pct
      1       240       0.66         44.6         44.2      121      121         83.9
      2       226       0.98         44.8         44.3      117      111         72.8
      3       225       0.56         44.6         43.2      116      113         72.9
      4       198       1.05         43.7         44.6      107       94         83.1
      5       227       1.09         45.2         42.6      121      111         81.5
      6       233       0.65         44.0         42.4      114      120         78.2

# find_rally_splits() on real shot timing is stable

    Code
      splits
    Output
      integer(0)

# dq_corrected_rallies() on the full sample dataset is stable

    Code
      as.data.frame(corrected)
    Output
          match_id rally_id               regime regime_occurrence segment_index
      1    9000001        1          mini_tennis                 1             1
      2    9000001       10          mini_tennis                 1             1
      3    9000001    100_a           net_volley                 2             5
      4    9000001    100_b           net_volley                 2             5
      5    9000001    101_a           net_volley                 2             5
      6    9000001    101_b           net_volley                 2             5
      7    9000001    102_a           net_volley                 2             5
      8    9000001    102_b           net_volley                 2             5
      9    9000001    103_a           net_volley                 2             5
      10   9000001    103_b           net_volley                 2             5
      11   9000001    104_a           net_volley                 2             5
      12   9000001    104_b           net_volley                 2             5
      13   9000001    104_c           net_volley                 2             5
      14   9000001      105           net_volley                 2             5
      15   9000001    106_a           net_volley                 2             5
      16   9000001    106_b           net_volley                 2             5
      17   9000001      107           net_volley                 2             5
      18   9000001      108           net_volley                 2             5
      19   9000001    109_a           net_volley                 2             5
      20   9000001    109_b           net_volley                 2             5
      21   9000001       11          mini_tennis                 1             1
      22   9000001    110_a           net_volley                 2             5
      23   9000001    110_b           net_volley                 2             5
      24   9000001    111_a           net_volley                 2             5
      25   9000001    111_b           net_volley                 2             5
      26   9000001      112           net_volley                 2             5
      27   9000001    113_a           net_volley                 2             5
      28   9000001    113_b           net_volley                 2             5
      29   9000001      114           net_volley                 2             5
      30   9000001    115_a           net_volley                 2             5
      31   9000001    115_b           net_volley                 2             5
      32   9000001      116           net_volley                 2             5
      33   9000001       12          mini_tennis                 1             1
      34   9000001       13          mini_tennis                 1             1
      35   9000001       14          mini_tennis                 1             1
      36   9000001       15          mini_tennis                 1             1
      37   9000001       16          mini_tennis                 1             1
      38   9000001       17          mini_tennis                 1             1
      39   9000001       18           net_volley                 1             2
      40   9000001     19_a           net_volley                 1             2
      41   9000001     19_b           net_volley                 1             2
      42   9000001        2          mini_tennis                 1             1
      43   9000001     20_a           net_volley                 1             2
      44   9000001     20_b           net_volley                 1             2
      45   9000001     20_c           net_volley                 1             2
      46   9000001     21_a           net_volley                 1             2
      47   9000001     21_b           net_volley                 1             2
      48   9000001     21_c           net_volley                 1             2
      49   9000001     22_a           net_volley                 1             2
      50   9000001     22_b           net_volley                 1             2
      51   9000001     22_c           net_volley                 1             2
      52   9000001     23_a           net_volley                 1             2
      53   9000001     23_b           net_volley                 1             2
      54   9000001     24_a           net_volley                 1             2
      55   9000001     24_b           net_volley                 1             2
      56   9000001     25_a           net_volley                 1             2
      57   9000001     25_b           net_volley                 1             2
      58   9000001     25_c           net_volley                 1             2
      59   9000001       26           net_volley                 1             2
      60   9000001     27_a           net_volley                 1             2
      61   9000001     27_b           net_volley                 1             2
      62   9000001     28_a           net_volley                 1             2
      63   9000001     28_b           net_volley                 1             2
      64   9000001     28_c           net_volley                 1             2
      65   9000001       29           net_volley                 1             2
      66   9000001        3          mini_tennis                 1             1
      67   9000001     30_a           net_volley                 1             2
      68   9000001     30_b           net_volley                 1             2
      69   9000001     31_a           net_volley                 1             2
      70   9000001     31_b           net_volley                 1             2
      71   9000001     31_c           net_volley                 1             2
      72   9000001     32_a           net_volley                 1             2
      73   9000001     32_b           net_volley                 1             2
      74   9000001     33_a           net_volley                 1             2
      75   9000001     33_b           net_volley                 1             2
      76   9000001     33_c           net_volley                 1             2
      77   9000001     34_a           net_volley                 1             2
      78   9000001     34_b           net_volley                 1             2
      79   9000001     34_c           net_volley                 1             2
      80   9000001     35_a           net_volley                 1             2
      81   9000001     35_b           net_volley                 1             2
      82   9000001     35_c           net_volley                 1             2
      83   9000001     36_a           net_volley                 1             2
      84   9000001     36_b           net_volley                 1             2
      85   9000001     36_c           net_volley                 1             2
      86   9000001       37           net_volley                 1             2
      87   9000001     38_a           net_volley                 1             2
      88   9000001     38_b           net_volley                 1             2
      89   9000001     39_a           net_volley                 1             2
      90   9000001     39_b           net_volley                 1             2
      91   9000001        4          mini_tennis                 1             1
      92   9000001     40_a           net_volley                 1             2
      93   9000001     40_b           net_volley                 1             2
      94   9000001     41_a           net_volley                 1             2
      95   9000001     41_b           net_volley                 1             2
      96   9000001     41_c           net_volley                 1             2
      97   9000001     42_a           net_volley                 1             2
      98   9000001     42_b           net_volley                 1             2
      99   9000001       43           net_volley                 1             2
      100  9000001       44 forehand_cross_court                 1             3
      101  9000001       45 forehand_cross_court                 1             3
      102  9000001       46 forehand_cross_court                 1             3
      103  9000001       47 forehand_cross_court                 1             3
      104  9000001     48_a forehand_cross_court                 1             3
      105  9000001     48_b forehand_cross_court                 1             3
      106  9000001       49 forehand_cross_court                 1             3
      107  9000001        5          mini_tennis                 1             1
      108  9000001       50 forehand_cross_court                 1             3
      109  9000001     51_a forehand_cross_court                 1             3
      110  9000001     51_b forehand_cross_court                 1             3
      111  9000001     52_a forehand_cross_court                 1             3
      112  9000001     52_b forehand_cross_court                 1             3
      113  9000001       53 forehand_cross_court                 1             3
      114  9000001       54 forehand_cross_court                 1             3
      115  9000001       55 forehand_cross_court                 1             3
      116  9000001       56 forehand_cross_court                 1             3
      117  9000001       57 forehand_cross_court                 1             3
      118  9000001     58_a forehand_cross_court                 1             3
      119  9000001     58_b forehand_cross_court                 1             3
      120  9000001       59 forehand_cross_court                 1             3
      121  9000001        6          mini_tennis                 1             1
      122  9000001       60 forehand_cross_court                 1             3
      123  9000001     61_a forehand_cross_court                 1             3
      124  9000001     61_b forehand_cross_court                 1             3
      125  9000001     61_c forehand_cross_court                 1             3
      126  9000001     62_a forehand_cross_court                 1             3
      127  9000001     62_b forehand_cross_court                 1             3
      128  9000001       63 forehand_cross_court                 1             3
      129  9000001     64_a forehand_cross_court                 1             3
      130  9000001     64_b forehand_cross_court                 1             3
      131  9000001       65 forehand_cross_court                 1             3
      132  9000001     66_a forehand_cross_court                 1             3
      133  9000001     66_b forehand_cross_court                 1             3
      134  9000001       67 forehand_cross_court                 1             3
      135  9000001       68 forehand_cross_court                 1             3
      136  9000001       69 forehand_cross_court                 1             3
      137  9000001        7          mini_tennis                 1             1
      138  9000001       70 backhand_cross_court                 1             4
      139  9000001       71 backhand_cross_court                 1             4
      140  9000001     72_a backhand_cross_court                 1             4
      141  9000001     72_b backhand_cross_court                 1             4
      142  9000001       73 backhand_cross_court                 1             4
      143  9000001       74 backhand_cross_court                 1             4
      144  9000001     75_a backhand_cross_court                 1             4
      145  9000001     75_b backhand_cross_court                 1             4
      146  9000001       76 backhand_cross_court                 1             4
      147  9000001       77 backhand_cross_court                 1             4
      148  9000001     78_a backhand_cross_court                 1             4
      149  9000001     78_b backhand_cross_court                 1             4
      150  9000001     78_c backhand_cross_court                 1             4
      151  9000001     78_d backhand_cross_court                 1             4
      152  9000001     79_a backhand_cross_court                 1             4
      153  9000001     79_b backhand_cross_court                 1             4
      154  9000001        8          mini_tennis                 1             1
      155  9000001     80_a backhand_cross_court                 1             4
      156  9000001     80_b backhand_cross_court                 1             4
      157  9000001       81 backhand_cross_court                 1             4
      158  9000001       82 backhand_cross_court                 1             4
      159  9000001       83 backhand_cross_court                 1             4
      160  9000001     84_a backhand_cross_court                 1             4
      161  9000001     84_b backhand_cross_court                 1             4
      162  9000001       85 backhand_cross_court                 1             4
      163  9000001       86 backhand_cross_court                 1             4
      164  9000001       87 backhand_cross_court                 1             4
      165  9000001     88_a backhand_cross_court                 1             4
      166  9000001     88_b backhand_cross_court                 1             4
      167  9000001       89 backhand_cross_court                 1             4
      168  9000001        9          mini_tennis                 1             1
      169  9000001       90 backhand_cross_court                 1             4
      170  9000001       91 backhand_cross_court                 1             4
      171  9000001     92_a backhand_cross_court                 1             4
      172  9000001     92_b backhand_cross_court                 1             4
      173  9000001     92_c backhand_cross_court                 1             4
      174  9000001     93_a backhand_cross_court                 1             4
      175  9000001     93_b backhand_cross_court                 1             4
      176  9000001       94 backhand_cross_court                 1             4
      177  9000001       95 backhand_cross_court                 1             4
      178  9000001     96_a           net_volley                 2             5
      179  9000001     96_b           net_volley                 2             5
      180  9000001     97_a           net_volley                 2             5
      181  9000001     97_b           net_volley                 2             5
      182  9000001     98_a           net_volley                 2             5
      183  9000001     98_b           net_volley                 2             5
      184  9000001     98_c           net_volley                 2             5
      185  9000001       99           net_volley                 2             5
      186  9000002        1          mini_tennis                 1             1
      187  9000002       10          mini_tennis                 1             1
      188  9000002    100_a           net_volley                 2             7
      189  9000002    100_b           net_volley                 2             7
      190  9000002    101_a           net_volley                 2             7
      191  9000002    101_b           net_volley                 2             7
      192  9000002    101_c           net_volley                 2             7
      193  9000002    102_a           net_volley                 2             7
      194  9000002    102_b           net_volley                 2             7
      195  9000002    103_a           net_volley                 2             7
      196  9000002    103_b           net_volley                 2             7
      197  9000002    103_c           net_volley                 2             7
      198  9000002      104           net_volley                 2             7
      199  9000002      105           net_volley                 2             7
      200  9000002    106_a           net_volley                 2             7
      201  9000002    106_b           net_volley                 2             7
      202  9000002       11          mini_tennis                 1             1
      203  9000002       12          mini_tennis                 1             1
      204  9000002       13          mini_tennis                 1             1
      205  9000002       14          mini_tennis                 1             1
      206  9000002       15          mini_tennis                 1             1
      207  9000002       16          mini_tennis                 1             1
      208  9000002       17           net_volley                 1             2
      209  9000002     18_a           net_volley                 1             2
      210  9000002     18_b           net_volley                 1             2
      211  9000002     18_c           net_volley                 1             2
      212  9000002       19           net_volley                 1             2
      213  9000002        2          mini_tennis                 1             1
      214  9000002     20_a           net_volley                 1             2
      215  9000002     20_b           net_volley                 1             2
      216  9000002     21_a           net_volley                 1             2
      217  9000002     21_b           net_volley                 1             2
      218  9000002     22_a           net_volley                 1             2
      219  9000002     22_b           net_volley                 1             2
      220  9000002     23_a           net_volley                 1             2
      221  9000002     23_b           net_volley                 1             2
      222  9000002     24_a           net_volley                 1             2
      223  9000002     24_b           net_volley                 1             2
      224  9000002     24_c           net_volley                 1             2
      225  9000002       25           net_volley                 1             2
      226  9000002     26_a           net_volley                 1             2
      227  9000002     26_b           net_volley                 1             2
      228  9000002     27_a           net_volley                 1             2
      229  9000002     27_b           net_volley                 1             2
      230  9000002     27_c           net_volley                 1             2
      231  9000002       28           net_volley                 1             2
      232  9000002       29           net_volley                 1             2
      233  9000002        3          mini_tennis                 1             1
      234  9000002     30_a           net_volley                 1             2
      235  9000002     30_b           net_volley                 1             2
      236  9000002     30_c           net_volley                 1             2
      237  9000002     31_a           net_volley                 1             2
      238  9000002     31_b           net_volley                 1             2
      239  9000002     32_a           net_volley                 1             2
      240  9000002     32_b           net_volley                 1             2
      241  9000002     32_c           net_volley                 1             2
      242  9000002     33_a           net_volley                 1             2
      243  9000002     33_b           net_volley                 1             2
      244  9000002     34_a           net_volley                 1             2
      245  9000002     34_b           net_volley                 1             2
      246  9000002     35_a           net_volley                 1             2
      247  9000002     35_b           net_volley                 1             2
      248  9000002     36_a           net_volley                 1             2
      249  9000002     36_b           net_volley                 1             2
      250  9000002     37_a           net_volley                 1             2
      251  9000002     37_b           net_volley                 1             2
      252  9000002       38           net_volley                 1             2
      253  9000002       39                  gap                 1             3
      254  9000002        4          mini_tennis                 1             1
      255  9000002     40_a forehand_cross_court                 1             4
      256  9000002     40_b forehand_cross_court                 1             4
      257  9000002       41 forehand_cross_court                 1             4
      258  9000002       42 forehand_cross_court                 1             4
      259  9000002       43 forehand_cross_court                 1             4
      260  9000002       44 forehand_cross_court                 1             4
      261  9000002     45_a forehand_cross_court                 1             4
      262  9000002     45_b forehand_cross_court                 1             4
      263  9000002       46 forehand_cross_court                 1             4
      264  9000002       47 forehand_cross_court                 1             4
      265  9000002     48_a forehand_cross_court                 1             4
      266  9000002     48_b forehand_cross_court                 1             4
      267  9000002     49_a forehand_cross_court                 1             4
      268  9000002     49_b forehand_cross_court                 1             4
      269  9000002        5          mini_tennis                 1             1
      270  9000002       50 forehand_cross_court                 1             4
      271  9000002       51 forehand_cross_court                 1             4
      272  9000002       52 forehand_cross_court                 1             4
      273  9000002     53_a forehand_cross_court                 1             4
      274  9000002     53_b forehand_cross_court                 1             4
      275  9000002       54 forehand_cross_court                 1             4
      276  9000002     55_a forehand_cross_court                 1             4
      277  9000002     55_b forehand_cross_court                 1             4
      278  9000002       56 forehand_cross_court                 1             4
      279  9000002     57_a forehand_cross_court                 1             4
      280  9000002     57_b forehand_cross_court                 1             4
      281  9000002     58_a forehand_cross_court                 1             4
      282  9000002     58_b forehand_cross_court                 1             4
      283  9000002     59_a forehand_cross_court                 1             4
      284  9000002     59_b forehand_cross_court                 1             4
      285  9000002     59_c forehand_cross_court                 1             4
      286  9000002        6          mini_tennis                 1             1
      287  9000002       60 forehand_cross_court                 1             4
      288  9000002       61 forehand_cross_court                 1             4
      289  9000002       62 forehand_cross_court                 1             4
      290  9000002       63 forehand_cross_court                 1             4
      291  9000002       64 forehand_cross_court                 1             4
      292  9000002       65                mixed                 1             5
      293  9000002       66                mixed                 1             5
      294  9000002       67                mixed                 1             5
      295  9000002     68_a backhand_cross_court                 1             6
      296  9000002     68_b backhand_cross_court                 1             6
      297  9000002     68_c backhand_cross_court                 1             6
      298  9000002       69 backhand_cross_court                 1             6
      299  9000002        7          mini_tennis                 1             1
      300  9000002       70 backhand_cross_court                 1             6
      301  9000002       71 backhand_cross_court                 1             6
      302  9000002       72 backhand_cross_court                 1             6
      303  9000002       73 backhand_cross_court                 1             6
      304  9000002       74 backhand_cross_court                 1             6
      305  9000002       75 backhand_cross_court                 1             6
      306  9000002     76_a backhand_cross_court                 1             6
      307  9000002     76_b backhand_cross_court                 1             6
      308  9000002     77_a backhand_cross_court                 1             6
      309  9000002     77_b backhand_cross_court                 1             6
      310  9000002     78_a backhand_cross_court                 1             6
      311  9000002     78_b backhand_cross_court                 1             6
      312  9000002       79 backhand_cross_court                 1             6
      313  9000002        8          mini_tennis                 1             1
      314  9000002     80_a backhand_cross_court                 1             6
      315  9000002     80_b backhand_cross_court                 1             6
      316  9000002     81_a backhand_cross_court                 1             6
      317  9000002     81_b backhand_cross_court                 1             6
      318  9000002       82 backhand_cross_court                 1             6
      319  9000002     83_a backhand_cross_court                 1             6
      320  9000002     83_b backhand_cross_court                 1             6
      321  9000002     83_c backhand_cross_court                 1             6
      322  9000002       84 backhand_cross_court                 1             6
      323  9000002       85 backhand_cross_court                 1             6
      324  9000002       86 backhand_cross_court                 1             6
      325  9000002       87 backhand_cross_court                 1             6
      326  9000002     88_a backhand_cross_court                 1             6
      327  9000002     88_b backhand_cross_court                 1             6
      328  9000002     88_c backhand_cross_court                 1             6
      329  9000002       89 backhand_cross_court                 1             6
      330  9000002        9          mini_tennis                 1             1
      331  9000002     90_a           net_volley                 2             7
      332  9000002     90_b           net_volley                 2             7
      333  9000002     91_a           net_volley                 2             7
      334  9000002     91_b           net_volley                 2             7
      335  9000002     92_a           net_volley                 2             7
      336  9000002     92_b           net_volley                 2             7
      337  9000002     93_a           net_volley                 2             7
      338  9000002     93_b           net_volley                 2             7
      339  9000002     93_c           net_volley                 2             7
      340  9000002     94_a           net_volley                 2             7
      341  9000002     94_b           net_volley                 2             7
      342  9000002     94_c           net_volley                 2             7
      343  9000002     95_a           net_volley                 2             7
      344  9000002     95_b           net_volley                 2             7
      345  9000002     96_a           net_volley                 2             7
      346  9000002     96_b           net_volley                 2             7
      347  9000002     96_c           net_volley                 2             7
      348  9000002     97_a           net_volley                 2             7
      349  9000002     97_b           net_volley                 2             7
      350  9000002       98           net_volley                 2             7
      351  9000002     99_a           net_volley                 2             7
      352  9000002     99_b           net_volley                 2             7
      353  9000003        1          mini_tennis                 1             1
      354  9000003       10          mini_tennis                 1             1
      355  9000003    100_a           net_volley                 2             7
      356  9000003    100_b           net_volley                 2             7
      357  9000003    100_c           net_volley                 2             7
      358  9000003    101_a           net_volley                 2             7
      359  9000003    101_b           net_volley                 2             7
      360  9000003    101_c           net_volley                 2             7
      361  9000003    102_a           net_volley                 2             7
      362  9000003    102_b           net_volley                 2             7
      363  9000003    103_a           net_volley                 2             7
      364  9000003    103_b           net_volley                 2             7
      365  9000003      104           net_volley                 2             7
      366  9000003       11          mini_tennis                 1             1
      367  9000003       12          mini_tennis                 1             1
      368  9000003       13          mini_tennis                 1             1
      369  9000003       14          mini_tennis                 1             1
      370  9000003       15          mini_tennis                 1             1
      371  9000003       16          mini_tennis                 1             1
      372  9000003       17          mini_tennis                 1             1
      373  9000003       18          mini_tennis                 1             1
      374  9000003       19          mini_tennis                 1             1
      375  9000003        2          mini_tennis                 1             1
      376  9000003       20                  gap                 1             2
      377  9000003       21           net_volley                 1             3
      378  9000003       22           net_volley                 1             3
      379  9000003     23_a           net_volley                 1             3
      380  9000003     23_b           net_volley                 1             3
      381  9000003     23_c           net_volley                 1             3
      382  9000003     24_a           net_volley                 1             3
      383  9000003     24_b           net_volley                 1             3
      384  9000003     24_c           net_volley                 1             3
      385  9000003       25           net_volley                 1             3
      386  9000003     26_a           net_volley                 1             3
      387  9000003     26_b           net_volley                 1             3
      388  9000003     26_c           net_volley                 1             3
      389  9000003     27_a           net_volley                 1             3
      390  9000003     27_b           net_volley                 1             3
      391  9000003     28_a           net_volley                 1             3
      392  9000003     28_b           net_volley                 1             3
      393  9000003     28_c           net_volley                 1             3
      394  9000003     28_d           net_volley                 1             3
      395  9000003     29_a           net_volley                 1             3
      396  9000003     29_b           net_volley                 1             3
      397  9000003     29_c           net_volley                 1             3
      398  9000003        3          mini_tennis                 1             1
      399  9000003     30_a           net_volley                 1             3
      400  9000003     30_b           net_volley                 1             3
      401  9000003     31_a           net_volley                 1             3
      402  9000003     31_b           net_volley                 1             3
      403  9000003     31_c           net_volley                 1             3
      404  9000003       32           net_volley                 1             3
      405  9000003       33           net_volley                 1             3
      406  9000003     34_a           net_volley                 1             3
      407  9000003     34_b           net_volley                 1             3
      408  9000003     35_a           net_volley                 1             3
      409  9000003     35_b           net_volley                 1             3
      410  9000003     35_c           net_volley                 1             3
      411  9000003     36_a           net_volley                 1             3
      412  9000003     36_b           net_volley                 1             3
      413  9000003       37           net_volley                 1             3
      414  9000003       38 forehand_cross_court                 1             4
      415  9000003       39 forehand_cross_court                 1             4
      416  9000003        4          mini_tennis                 1             1
      417  9000003       40 forehand_cross_court                 1             4
      418  9000003       41 forehand_cross_court                 1             4
      419  9000003       42 forehand_cross_court                 1             4
      420  9000003     43_a forehand_cross_court                 1             4
      421  9000003     43_b forehand_cross_court                 1             4
      422  9000003       44 forehand_cross_court                 1             4
      423  9000003     45_a forehand_cross_court                 1             4
      424  9000003     45_b forehand_cross_court                 1             4
      425  9000003       46 forehand_cross_court                 1             4
      426  9000003       47 forehand_cross_court                 1             4
      427  9000003     48_a forehand_cross_court                 1             4
      428  9000003     48_b forehand_cross_court                 1             4
      429  9000003     49_a forehand_cross_court                 1             4
      430  9000003     49_b forehand_cross_court                 1             4
      431  9000003        5          mini_tennis                 1             1
      432  9000003       50 forehand_cross_court                 1             4
      433  9000003       51 forehand_cross_court                 1             4
      434  9000003       52 forehand_cross_court                 1             4
      435  9000003     53_a forehand_cross_court                 1             4
      436  9000003     53_b forehand_cross_court                 1             4
      437  9000003       54 forehand_cross_court                 1             4
      438  9000003       55 forehand_cross_court                 1             4
      439  9000003       56 forehand_cross_court                 1             4
      440  9000003     57_a forehand_cross_court                 1             4
      441  9000003     57_b forehand_cross_court                 1             4
      442  9000003       58 forehand_cross_court                 1             4
      443  9000003       59 forehand_cross_court                 1             4
      444  9000003        6          mini_tennis                 1             1
      445  9000003       60 forehand_cross_court                 1             4
      446  9000003       61 forehand_cross_court                 1             4
      447  9000003       62 forehand_cross_court                 1             4
      448  9000003     63_a backhand_cross_court                 1             5
      449  9000003     63_b backhand_cross_court                 1             5
      450  9000003       64 backhand_cross_court                 1             5
      451  9000003       65 backhand_cross_court                 1             5
      452  9000003       66 backhand_cross_court                 1             5
      453  9000003       67 backhand_cross_court                 1             5
      454  9000003       68 backhand_cross_court                 1             5
      455  9000003       69 backhand_cross_court                 1             5
      456  9000003        7          mini_tennis                 1             1
      457  9000003       70 backhand_cross_court                 1             5
      458  9000003       71 backhand_cross_court                 1             5
      459  9000003     72_a backhand_cross_court                 1             5
      460  9000003     72_b backhand_cross_court                 1             5
      461  9000003       73 backhand_cross_court                 1             5
      462  9000003       74 backhand_cross_court                 1             5
      463  9000003       75 backhand_cross_court                 1             5
      464  9000003       76 backhand_cross_court                 1             5
      465  9000003       77 backhand_cross_court                 1             5
      466  9000003       78 backhand_cross_court                 1             5
      467  9000003     79_a backhand_cross_court                 1             5
      468  9000003     79_b backhand_cross_court                 1             5
      469  9000003     79_c backhand_cross_court                 1             5
      470  9000003        8          mini_tennis                 1             1
      471  9000003       80 backhand_cross_court                 1             5
      472  9000003       81 backhand_cross_court                 1             5
      473  9000003       82 backhand_cross_court                 1             5
      474  9000003       83 backhand_cross_court                 1             5
      475  9000003     84_a backhand_cross_court                 1             5
      476  9000003     84_b backhand_cross_court                 1             5
      477  9000003     84_c backhand_cross_court                 1             5
      478  9000003     85_a backhand_cross_court                 1             5
      479  9000003     85_b backhand_cross_court                 1             5
      480  9000003       86 backhand_cross_court                 1             5
      481  9000003       87                  gap                 2             6
      482  9000003     88_a           net_volley                 2             7
      483  9000003     88_b           net_volley                 2             7
      484  9000003     89_a           net_volley                 2             7
      485  9000003     89_b           net_volley                 2             7
      486  9000003        9          mini_tennis                 1             1
      487  9000003     90_a           net_volley                 2             7
      488  9000003     90_b           net_volley                 2             7
      489  9000003     91_a           net_volley                 2             7
      490  9000003     91_b           net_volley                 2             7
      491  9000003       92           net_volley                 2             7
      492  9000003     93_a           net_volley                 2             7
      493  9000003     93_b           net_volley                 2             7
      494  9000003     94_a           net_volley                 2             7
      495  9000003     94_b           net_volley                 2             7
      496  9000003       95           net_volley                 2             7
      497  9000003     96_a           net_volley                 2             7
      498  9000003     96_b           net_volley                 2             7
      499  9000003     96_c           net_volley                 2             7
      500  9000003     97_a           net_volley                 2             7
      501  9000003     97_b           net_volley                 2             7
      502  9000003     97_c           net_volley                 2             7
      503  9000003       98           net_volley                 2             7
      504  9000003       99           net_volley                 2             7
      505  9000004        1          mini_tennis                 1             1
      506  9000004       10          mini_tennis                 1             1
      507  9000004       11          mini_tennis                 1             1
      508  9000004       12          mini_tennis                 1             1
      509  9000004       13          mini_tennis                 1             1
      510  9000004       14          mini_tennis                 1             1
      511  9000004       15          mini_tennis                 1             1
      512  9000004       16           net_volley                 1             2
      513  9000004     17_a           net_volley                 1             2
      514  9000004     17_b           net_volley                 1             2
      515  9000004     17_c           net_volley                 1             2
      516  9000004       18           net_volley                 1             2
      517  9000004       19           net_volley                 1             2
      518  9000004        2          mini_tennis                 1             1
      519  9000004       20           net_volley                 1             2
      520  9000004       21           net_volley                 1             2
      521  9000004       22           net_volley                 1             2
      522  9000004       23           net_volley                 1             2
      523  9000004     24_a           net_volley                 1             2
      524  9000004     24_b           net_volley                 1             2
      525  9000004     25_a           net_volley                 1             2
      526  9000004     25_b           net_volley                 1             2
      527  9000004     26_a           net_volley                 1             2
      528  9000004     26_b           net_volley                 1             2
      529  9000004     27_a           net_volley                 1             2
      530  9000004     27_b           net_volley                 1             2
      531  9000004     27_c           net_volley                 1             2
      532  9000004       28           net_volley                 1             2
      533  9000004     29_a           net_volley                 1             2
      534  9000004     29_b           net_volley                 1             2
      535  9000004        3          mini_tennis                 1             1
      536  9000004       30           net_volley                 1             2
      537  9000004     31_a           net_volley                 1             2
      538  9000004     31_b           net_volley                 1             2
      539  9000004     32_a           net_volley                 1             2
      540  9000004     32_b           net_volley                 1             2
      541  9000004     33_a           net_volley                 1             2
      542  9000004     33_b           net_volley                 1             2
      543  9000004     34_a           net_volley                 1             2
      544  9000004     34_b           net_volley                 1             2
      545  9000004       35           net_volley                 1             2
      546  9000004     36_a           net_volley                 1             2
      547  9000004     36_b           net_volley                 1             2
      548  9000004     36_c           net_volley                 1             2
      549  9000004     37_a           net_volley                 1             2
      550  9000004     37_b           net_volley                 1             2
      551  9000004       38           net_volley                 1             2
      552  9000004     39_a           net_volley                 1             2
      553  9000004     39_b           net_volley                 1             2
      554  9000004        4          mini_tennis                 1             1
      555  9000004     40_a           net_volley                 1             2
      556  9000004     40_b           net_volley                 1             2
      557  9000004     41_a forehand_cross_court                 1             3
      558  9000004     41_b forehand_cross_court                 1             3
      559  9000004       42 forehand_cross_court                 1             3
      560  9000004       43 forehand_cross_court                 1             3
      561  9000004       44 forehand_cross_court                 1             3
      562  9000004       45 forehand_cross_court                 1             3
      563  9000004       46 forehand_cross_court                 1             3
      564  9000004       47 forehand_cross_court                 1             3
      565  9000004       48 forehand_cross_court                 1             3
      566  9000004     49_a forehand_cross_court                 1             3
      567  9000004     49_b forehand_cross_court                 1             3
      568  9000004     49_c forehand_cross_court                 1             3
      569  9000004        5          mini_tennis                 1             1
      570  9000004     50_a forehand_cross_court                 1             3
      571  9000004     50_b forehand_cross_court                 1             3
      572  9000004       51 forehand_cross_court                 1             3
      573  9000004       52 forehand_cross_court                 1             3
      574  9000004       53 forehand_cross_court                 1             3
      575  9000004     54_a forehand_cross_court                 1             3
      576  9000004     54_b forehand_cross_court                 1             3
      577  9000004       55 forehand_cross_court                 1             3
      578  9000004     56_a forehand_cross_court                 1             3
      579  9000004     56_b forehand_cross_court                 1             3
      580  9000004     57_a forehand_cross_court                 1             3
      581  9000004     57_b forehand_cross_court                 1             3
      582  9000004       58 forehand_cross_court                 1             3
      583  9000004     59_a forehand_cross_court                 1             3
      584  9000004     59_b forehand_cross_court                 1             3
      585  9000004     59_c forehand_cross_court                 1             3
      586  9000004        6          mini_tennis                 1             1
      587  9000004       60 forehand_cross_court                 1             3
      588  9000004       61 forehand_cross_court                 1             3
      589  9000004       62 backhand_cross_court                 1             4
      590  9000004       63 backhand_cross_court                 1             4
      591  9000004       64 backhand_cross_court                 1             4
      592  9000004     65_a backhand_cross_court                 1             4
      593  9000004     65_b backhand_cross_court                 1             4
      594  9000004       66 backhand_cross_court                 1             4
      595  9000004     67_a backhand_cross_court                 1             4
      596  9000004     67_b backhand_cross_court                 1             4
      597  9000004     68_a backhand_cross_court                 1             4
      598  9000004     68_b backhand_cross_court                 1             4
      599  9000004     68_c backhand_cross_court                 1             4
      600  9000004       69 backhand_cross_court                 1             4
      601  9000004        7          mini_tennis                 1             1
      602  9000004       70 backhand_cross_court                 1             4
      603  9000004     71_a backhand_cross_court                 1             4
      604  9000004     71_b backhand_cross_court                 1             4
      605  9000004     72_a backhand_cross_court                 1             4
      606  9000004     72_b backhand_cross_court                 1             4
      607  9000004       73 backhand_cross_court                 1             4
      608  9000004       74 backhand_cross_court                 1             4
      609  9000004     75_a backhand_cross_court                 1             4
      610  9000004     75_b backhand_cross_court                 1             4
      611  9000004       76 backhand_cross_court                 1             4
      612  9000004       77 backhand_cross_court                 1             4
      613  9000004       78 backhand_cross_court                 1             4
      614  9000004       79 backhand_cross_court                 1             4
      615  9000004        8          mini_tennis                 1             1
      616  9000004     80_a backhand_cross_court                 1             4
      617  9000004     80_b backhand_cross_court                 1             4
      618  9000004     81_a           net_volley                 2             5
      619  9000004     81_b           net_volley                 2             5
      620  9000004     82_a           net_volley                 2             5
      621  9000004     82_b           net_volley                 2             5
      622  9000004     83_a           net_volley                 2             5
      623  9000004     83_b           net_volley                 2             5
      624  9000004     83_c           net_volley                 2             5
      625  9000004     84_a           net_volley                 2             5
      626  9000004     84_b           net_volley                 2             5
      627  9000004     84_c           net_volley                 2             5
      628  9000004     85_a           net_volley                 2             5
      629  9000004     85_b           net_volley                 2             5
      630  9000004       86           net_volley                 2             5
      631  9000004     87_a           net_volley                 2             5
      632  9000004     87_b           net_volley                 2             5
      633  9000004     88_a           net_volley                 2             5
      634  9000004     88_b           net_volley                 2             5
      635  9000004       89           net_volley                 2             5
      636  9000004        9          mini_tennis                 1             1
      637  9000004     90_a           net_volley                 2             5
      638  9000004     90_b           net_volley                 2             5
      639  9000004     91_a           net_volley                 2             5
      640  9000004     91_b           net_volley                 2             5
      641  9000004     91_c           net_volley                 2             5
      642  9000004       92           net_volley                 2             5
      643  9000004     93_a           net_volley                 2             5
      644  9000004     93_b           net_volley                 2             5
      645  9000004     94_a           net_volley                 2             5
      646  9000004     94_b           net_volley                 2             5
      647  9000004     94_c           net_volley                 2             5
      648  9000004     95_a           net_volley                 2             5
      649  9000004     95_b           net_volley                 2             5
      650  9000004       96           net_volley                 2             5
      651  9000005        1          mini_tennis                 1             1
      652  9000005       10          mini_tennis                 1             1
      653  9000005    100_a           net_volley                 2             8
      654  9000005    100_b           net_volley                 2             8
      655  9000005    100_c           net_volley                 2             8
      656  9000005    101_a           net_volley                 2             8
      657  9000005    101_b           net_volley                 2             8
      658  9000005    102_a           net_volley                 2             8
      659  9000005    102_b           net_volley                 2             8
      660  9000005    102_c           net_volley                 2             8
      661  9000005    103_a           net_volley                 2             8
      662  9000005    103_b           net_volley                 2             8
      663  9000005      104           net_volley                 2             8
      664  9000005    105_a           net_volley                 2             8
      665  9000005    105_b           net_volley                 2             8
      666  9000005      106           net_volley                 2             8
      667  9000005    107_a           net_volley                 2             8
      668  9000005    107_b           net_volley                 2             8
      669  9000005      108           net_volley                 2             8
      670  9000005    109_a           net_volley                 2             8
      671  9000005    109_b           net_volley                 2             8
      672  9000005       11          mini_tennis                 1             1
      673  9000005      110           net_volley                 2             8
      674  9000005       12          mini_tennis                 1             1
      675  9000005       13          mini_tennis                 1             1
      676  9000005       14          mini_tennis                 1             1
      677  9000005       15          mini_tennis                 1             1
      678  9000005       16          mini_tennis                 1             1
      679  9000005     17_a           net_volley                 1             3
      680  9000005     17_b           net_volley                 1             3
      681  9000005     18_a           net_volley                 1             3
      682  9000005     18_b           net_volley                 1             3
      683  9000005     18_c           net_volley                 1             3
      684  9000005     19_a           net_volley                 1             3
      685  9000005     19_b           net_volley                 1             3
      686  9000005        2          mini_tennis                 1             1
      687  9000005       20           net_volley                 1             3
      688  9000005     21_a           net_volley                 1             3
      689  9000005     21_b           net_volley                 1             3
      690  9000005     21_c           net_volley                 1             3
      691  9000005       22           net_volley                 1             3
      692  9000005       23           net_volley                 1             3
      693  9000005       24           net_volley                 1             3
      694  9000005     25_a           net_volley                 1             3
      695  9000005     25_b           net_volley                 1             3
      696  9000005     26_a           net_volley                 1             3
      697  9000005     26_b           net_volley                 1             3
      698  9000005       27           net_volley                 1             3
      699  9000005     28_a           net_volley                 1             3
      700  9000005     28_b           net_volley                 1             3
      701  9000005       29           net_volley                 1             3
      702  9000005        3          mini_tennis                 1             1
      703  9000005       30           net_volley                 1             3
      704  9000005     31_a           net_volley                 1             3
      705  9000005     31_b           net_volley                 1             3
      706  9000005     32_a           net_volley                 1             3
      707  9000005     32_b           net_volley                 1             3
      708  9000005     32_c           net_volley                 1             3
      709  9000005     33_a           net_volley                 1             3
      710  9000005     33_b           net_volley                 1             3
      711  9000005       34           net_volley                 1             3
      712  9000005     35_a           net_volley                 1             3
      713  9000005     35_b           net_volley                 1             3
      714  9000005       36           net_volley                 1             3
      715  9000005     37_a           net_volley                 1             3
      716  9000005     37_b           net_volley                 1             3
      717  9000005     37_c           net_volley                 1             3
      718  9000005     38_a           net_volley                 1             3
      719  9000005     38_b           net_volley                 1             3
      720  9000005       39                  gap                 2             4
      721  9000005        4          mini_tennis                 1             1
      722  9000005       40 forehand_cross_court                 1             5
      723  9000005     41_a forehand_cross_court                 1             5
      724  9000005     41_b forehand_cross_court                 1             5
      725  9000005     41_c forehand_cross_court                 1             5
      726  9000005       42 forehand_cross_court                 1             5
      727  9000005       43 forehand_cross_court                 1             5
      728  9000005       44 forehand_cross_court                 1             5
      729  9000005       45 forehand_cross_court                 1             5
      730  9000005       46 forehand_cross_court                 1             5
      731  9000005       47 forehand_cross_court                 1             5
      732  9000005       48 forehand_cross_court                 1             5
      733  9000005     49_a forehand_cross_court                 1             5
      734  9000005     49_b forehand_cross_court                 1             5
      735  9000005        5          mini_tennis                 1             1
      736  9000005       50 forehand_cross_court                 1             5
      737  9000005       51 forehand_cross_court                 1             5
      738  9000005       52 forehand_cross_court                 1             5
      739  9000005     53_a forehand_cross_court                 1             5
      740  9000005     53_b forehand_cross_court                 1             5
      741  9000005     53_c forehand_cross_court                 1             5
      742  9000005       54 forehand_cross_court                 1             5
      743  9000005       55 forehand_cross_court                 1             5
      744  9000005     56_a forehand_cross_court                 1             5
      745  9000005     56_b forehand_cross_court                 1             5
      746  9000005       57 forehand_cross_court                 1             5
      747  9000005       58 forehand_cross_court                 1             5
      748  9000005     59_a forehand_cross_court                 1             5
      749  9000005     59_b forehand_cross_court                 1             5
      750  9000005        6          mini_tennis                 1             1
      751  9000005       60 forehand_cross_court                 1             5
      752  9000005       61 forehand_cross_court                 1             5
      753  9000005       62 forehand_cross_court                 1             5
      754  9000005       63 forehand_cross_court                 1             5
      755  9000005       64 forehand_cross_court                 1             5
      756  9000005       65 forehand_cross_court                 1             5
      757  9000005       66 forehand_cross_court                 1             5
      758  9000005       67 forehand_cross_court                 1             5
      759  9000005       68 forehand_cross_court                 1             5
      760  9000005       69 forehand_cross_court                 1             5
      761  9000005        7          mini_tennis                 1             1
      762  9000005       70 forehand_cross_court                 1             5
      763  9000005       71 backhand_cross_court                 1             6
      764  9000005       72 backhand_cross_court                 1             6
      765  9000005       73 backhand_cross_court                 1             6
      766  9000005     74_a backhand_cross_court                 1             6
      767  9000005     74_b backhand_cross_court                 1             6
      768  9000005     75_a backhand_cross_court                 1             6
      769  9000005     75_b backhand_cross_court                 1             6
      770  9000005       76 backhand_cross_court                 1             6
      771  9000005       77 backhand_cross_court                 1             6
      772  9000005       78 backhand_cross_court                 1             6
      773  9000005       79 backhand_cross_court                 1             6
      774  9000005        8          mini_tennis                 1             1
      775  9000005       80 backhand_cross_court                 1             6
      776  9000005     81_a backhand_cross_court                 1             6
      777  9000005     81_b backhand_cross_court                 1             6
      778  9000005       82 backhand_cross_court                 1             6
      779  9000005     83_a backhand_cross_court                 1             6
      780  9000005     83_b backhand_cross_court                 1             6
      781  9000005     83_c backhand_cross_court                 1             6
      782  9000005       84 backhand_cross_court                 1             6
      783  9000005       85 backhand_cross_court                 1             6
      784  9000005     86_a backhand_cross_court                 1             6
      785  9000005     86_b backhand_cross_court                 1             6
      786  9000005       87 backhand_cross_court                 1             6
      787  9000005       88 backhand_cross_court                 1             6
      788  9000005       89 backhand_cross_court                 1             6
      789  9000005        9          mini_tennis                 1             1
      790  9000005       90 backhand_cross_court                 1             6
      791  9000005       91 backhand_cross_court                 1             6
      792  9000005       92 backhand_cross_court                 1             6
      793  9000005     93_a backhand_cross_court                 1             6
      794  9000005     93_b backhand_cross_court                 1             6
      795  9000005       94 backhand_cross_court                 1             6
      796  9000005       95 backhand_cross_court                 1             6
      797  9000005       96 backhand_cross_court                 1             6
      798  9000005       97                  gap                 3             7
      799  9000005     98_a           net_volley                 2             8
      800  9000005     98_b           net_volley                 2             8
      801  9000005     98_c           net_volley                 2             8
      802  9000005     99_a           net_volley                 2             8
      803  9000005     99_b           net_volley                 2             8
      804  9000005     99_c           net_volley                 2             8
      805  9000006        1          mini_tennis                 1             1
      806  9000006       10          mini_tennis                 1             1
      807  9000006      100           net_volley                 2             6
      808  9000006    101_a           net_volley                 2             6
      809  9000006    101_b           net_volley                 2             6
      810  9000006    102_a           net_volley                 2             6
      811  9000006    102_b           net_volley                 2             6
      812  9000006    103_a           net_volley                 2             6
      813  9000006    103_b           net_volley                 2             6
      814  9000006    104_a           net_volley                 2             6
      815  9000006    104_b           net_volley                 2             6
      816  9000006    105_a           net_volley                 2             6
      817  9000006    105_b           net_volley                 2             6
      818  9000006    106_a           net_volley                 2             6
      819  9000006    106_b           net_volley                 2             6
      820  9000006    106_c           net_volley                 2             6
      821  9000006      107           net_volley                 2             6
      822  9000006       11          mini_tennis                 1             1
      823  9000006       12          mini_tennis                 1             1
      824  9000006       13          mini_tennis                 1             1
      825  9000006       14          mini_tennis                 1             1
      826  9000006       15          mini_tennis                 1             1
      827  9000006       16          mini_tennis                 1             1
      828  9000006       17          mini_tennis                 1             1
      829  9000006       18           net_volley                 1             2
      830  9000006     19_a           net_volley                 1             2
      831  9000006     19_b           net_volley                 1             2
      832  9000006     19_c           net_volley                 1             2
      833  9000006     19_d           net_volley                 1             2
      834  9000006        2          mini_tennis                 1             1
      835  9000006     20_a           net_volley                 1             2
      836  9000006     20_b           net_volley                 1             2
      837  9000006     20_c           net_volley                 1             2
      838  9000006     21_a           net_volley                 1             2
      839  9000006     21_b           net_volley                 1             2
      840  9000006     22_a           net_volley                 1             2
      841  9000006     22_b           net_volley                 1             2
      842  9000006     23_a           net_volley                 1             2
      843  9000006     23_b           net_volley                 1             2
      844  9000006     24_a           net_volley                 1             2
      845  9000006     24_b           net_volley                 1             2
      846  9000006     24_c           net_volley                 1             2
      847  9000006     25_a           net_volley                 1             2
      848  9000006     25_b           net_volley                 1             2
      849  9000006     25_c           net_volley                 1             2
      850  9000006     25_d           net_volley                 1             2
      851  9000006     26_a           net_volley                 1             2
      852  9000006     26_b           net_volley                 1             2
      853  9000006     27_a           net_volley                 1             2
      854  9000006     27_b           net_volley                 1             2
      855  9000006     27_c           net_volley                 1             2
      856  9000006     28_a           net_volley                 1             2
      857  9000006     28_b           net_volley                 1             2
      858  9000006     29_a           net_volley                 1             2
      859  9000006     29_b           net_volley                 1             2
      860  9000006        3          mini_tennis                 1             1
      861  9000006     30_a           net_volley                 1             2
      862  9000006     30_b           net_volley                 1             2
      863  9000006     31_a           net_volley                 1             2
      864  9000006     31_b           net_volley                 1             2
      865  9000006     31_c           net_volley                 1             2
      866  9000006     32_a           net_volley                 1             2
      867  9000006     32_b           net_volley                 1             2
      868  9000006     33_a           net_volley                 1             2
      869  9000006     33_b           net_volley                 1             2
      870  9000006     34_a           net_volley                 1             2
      871  9000006     34_b           net_volley                 1             2
      872  9000006     35_a           net_volley                 1             2
      873  9000006     35_b           net_volley                 1             2
      874  9000006     35_c           net_volley                 1             2
      875  9000006     36_a           net_volley                 1             2
      876  9000006     36_b           net_volley                 1             2
      877  9000006     36_c           net_volley                 1             2
      878  9000006       37           net_volley                 1             2
      879  9000006     38_a           net_volley                 1             2
      880  9000006     38_b           net_volley                 1             2
      881  9000006     38_c           net_volley                 1             2
      882  9000006     38_d           net_volley                 1             2
      883  9000006     39_a           net_volley                 1             2
      884  9000006     39_b           net_volley                 1             2
      885  9000006        4          mini_tennis                 1             1
      886  9000006     40_a           net_volley                 1             2
      887  9000006     40_b           net_volley                 1             2
      888  9000006       41 forehand_cross_court                 1             3
      889  9000006       42 forehand_cross_court                 1             3
      890  9000006       43 forehand_cross_court                 1             3
      891  9000006     44_a forehand_cross_court                 1             3
      892  9000006     44_b forehand_cross_court                 1             3
      893  9000006     45_a forehand_cross_court                 1             3
      894  9000006     45_b forehand_cross_court                 1             3
      895  9000006       46 forehand_cross_court                 1             3
      896  9000006       47 forehand_cross_court                 1             3
      897  9000006     48_a forehand_cross_court                 1             3
      898  9000006     48_b forehand_cross_court                 1             3
      899  9000006     49_a forehand_cross_court                 1             3
      900  9000006     49_b forehand_cross_court                 1             3
      901  9000006        5          mini_tennis                 1             1
      902  9000006       50 forehand_cross_court                 1             3
      903  9000006     51_a forehand_cross_court                 1             3
      904  9000006     51_b forehand_cross_court                 1             3
      905  9000006       52 forehand_cross_court                 1             3
      906  9000006     53_a forehand_cross_court                 1             3
      907  9000006     53_b forehand_cross_court                 1             3
      908  9000006     53_c forehand_cross_court                 1             3
      909  9000006       54 forehand_cross_court                 1             3
      910  9000006     55_a forehand_cross_court                 1             3
      911  9000006     55_b forehand_cross_court                 1             3
      912  9000006     56_a forehand_cross_court                 1             3
      913  9000006     56_b forehand_cross_court                 1             3
      914  9000006       57 forehand_cross_court                 1             3
      915  9000006       58 forehand_cross_court                 1             3
      916  9000006       59 forehand_cross_court                 1             3
      917  9000006        6          mini_tennis                 1             1
      918  9000006       60 forehand_cross_court                 1             3
      919  9000006       61 forehand_cross_court                 1             3
      920  9000006       62 forehand_cross_court                 1             3
      921  9000006       63 forehand_cross_court                 1             3
      922  9000006       64 forehand_cross_court                 1             3
      923  9000006     65_a forehand_cross_court                 1             3
      924  9000006     65_b forehand_cross_court                 1             3
      925  9000006       66 forehand_cross_court                 1             3
      926  9000006       67 forehand_cross_court                 1             3
      927  9000006       68 forehand_cross_court                 1             3
      928  9000006       69 backhand_cross_court                 1             4
      929  9000006        7          mini_tennis                 1             1
      930  9000006       70 backhand_cross_court                 1             4
      931  9000006       71 backhand_cross_court                 1             4
      932  9000006       72 backhand_cross_court                 1             4
      933  9000006       73 backhand_cross_court                 1             4
      934  9000006       74 backhand_cross_court                 1             4
      935  9000006       75 backhand_cross_court                 1             4
      936  9000006       76 backhand_cross_court                 1             4
      937  9000006       77 backhand_cross_court                 1             4
      938  9000006       78 backhand_cross_court                 1             4
      939  9000006       79 backhand_cross_court                 1             4
      940  9000006        8          mini_tennis                 1             1
      941  9000006       80 backhand_cross_court                 1             4
      942  9000006       81 backhand_cross_court                 1             4
      943  9000006       82 backhand_cross_court                 1             4
      944  9000006       83 backhand_cross_court                 1             4
      945  9000006       84 backhand_cross_court                 1             4
      946  9000006       85 backhand_cross_court                 1             4
      947  9000006       86 backhand_cross_court                 1             4
      948  9000006       87 backhand_cross_court                 1             4
      949  9000006     88_a backhand_cross_court                 1             4
      950  9000006     88_b backhand_cross_court                 1             4
      951  9000006       89 backhand_cross_court                 1             4
      952  9000006        9          mini_tennis                 1             1
      953  9000006     90_a backhand_cross_court                 1             4
      954  9000006     90_b backhand_cross_court                 1             4
      955  9000006       91                  gap                 1             5
      956  9000006     92_a           net_volley                 2             6
      957  9000006     92_b           net_volley                 2             6
      958  9000006     92_c           net_volley                 2             6
      959  9000006     93_a           net_volley                 2             6
      960  9000006     93_b           net_volley                 2             6
      961  9000006     93_c           net_volley                 2             6
      962  9000006     94_a           net_volley                 2             6
      963  9000006     94_b           net_volley                 2             6
      964  9000006     95_a           net_volley                 2             6
      965  9000006     95_b           net_volley                 2             6
      966  9000006     95_c           net_volley                 2             6
      967  9000006     96_a           net_volley                 2             6
      968  9000006     96_b           net_volley                 2             6
      969  9000006       97           net_volley                 2             6
      970  9000006     98_a           net_volley                 2             6
      971  9000006     98_b           net_volley                 2             6
      972  9000006     99_a           net_volley                 2             6
      973  9000006     99_b           net_volley                 2             6
          n_shots me_shots duration_sec          start_time            end_time
      1         2        1     3.500000 2030-01-05 16:00:00 2030-01-05 16:00:03
      2         6        3    11.200000 2030-01-05 16:01:40 2030-01-05 16:01:52
      3         2        1     1.902122 2030-01-05 16:20:19 2030-01-05 16:20:21
      4         3        1     4.898617 2030-01-05 16:20:24 2030-01-05 16:20:29
      5         1        1     0.000000 2030-01-05 16:20:32 2030-01-05 16:20:32
      6         3        1     3.017331 2030-01-05 16:20:35 2030-01-05 16:20:38
      7         5        3     7.674694 2030-01-05 16:20:41 2030-01-05 16:20:48
      8         1        0     0.000000 2030-01-05 16:20:52 2030-01-05 16:20:52
      9         1        1     0.000000 2030-01-05 16:20:55 2030-01-05 16:20:55
      10        2        1     1.727698 2030-01-05 16:20:57 2030-01-05 16:20:58
      11        2        1     2.454815 2030-01-05 16:21:02 2030-01-05 16:21:04
      12        2        1     1.669891 2030-01-05 16:21:06 2030-01-05 16:21:08
      13        2        1     2.318023 2030-01-05 16:21:10 2030-01-05 16:21:13
      14        2        1     2.400000 2030-01-05 16:21:15 2030-01-05 16:21:17
      15        2        1     2.375599 2030-01-05 16:21:19 2030-01-05 16:21:21
      16        3        1     5.179270 2030-01-05 16:21:24 2030-01-05 16:21:30
      17        2        1     1.800000 2030-01-05 16:21:31 2030-01-05 16:21:33
      18        3        2     3.700000 2030-01-05 16:21:36 2030-01-05 16:21:39
      19        2        1     2.120899 2030-01-05 16:21:41 2030-01-05 16:21:43
      20        1        0     0.000000 2030-01-05 16:21:46 2030-01-05 16:21:46
      21        5        3     8.700000 2030-01-05 16:01:54 2030-01-05 16:02:03
      22        3        2     4.547370 2030-01-05 16:21:47 2030-01-05 16:21:51
      23        1        0     0.000000 2030-01-05 16:21:54 2030-01-05 16:21:54
      24        1        1     0.000000 2030-01-05 16:21:56 2030-01-05 16:21:56
      25        2        1     2.233947 2030-01-05 16:21:59 2030-01-05 16:22:01
      26        4        2     5.800000 2030-01-05 16:22:04 2030-01-05 16:22:10
      27        2        1     3.469632 2030-01-05 16:22:13 2030-01-05 16:22:16
      28        2        1     1.885653 2030-01-05 16:22:19 2030-01-05 16:22:21
      29        2        1     3.600000 2030-01-05 16:22:23 2030-01-05 16:22:26
      30        2        1     3.479817 2030-01-05 16:22:28 2030-01-05 16:22:31
      31        2        1     1.381903 2030-01-05 16:22:33 2030-01-05 16:22:35
      32        1        0     0.900000 2030-01-05 16:22:37 2030-01-05 16:22:38
      33        7        3    14.600000 2030-01-05 16:02:04 2030-01-05 16:02:19
      34        6        3     9.900000 2030-01-05 16:02:22 2030-01-05 16:02:32
      35        2        1     1.500000 2030-01-05 16:02:33 2030-01-05 16:02:35
      36        3        2     4.000000 2030-01-05 16:02:36 2030-01-05 16:02:40
      37        2        1     2.700000 2030-01-05 16:02:41 2030-01-05 16:02:43
      38        3        1     5.000000 2030-01-05 16:02:46 2030-01-05 16:02:52
      39        1        1     0.600000 2030-01-05 16:03:40 2030-01-05 16:03:40
      40        2        1     2.988055 2030-01-05 16:03:42 2030-01-05 16:03:45
      41        5        2     8.446652 2030-01-05 16:03:48 2030-01-05 16:03:56
      42        4        2     9.200000 2030-01-05 16:00:05 2030-01-05 16:00:14
      43        1        1     0.000000 2030-01-05 16:03:59 2030-01-05 16:03:59
      44        2        1     1.649639 2030-01-05 16:04:02 2030-01-05 16:04:04
      45        2        1     1.798998 2030-01-05 16:04:06 2030-01-05 16:04:08
      46        2        1     3.280568 2030-01-05 16:04:11 2030-01-05 16:04:14
      47        2        1     2.068209 2030-01-05 16:04:17 2030-01-05 16:04:19
      48        1        0     0.000000 2030-01-05 16:04:21 2030-01-05 16:04:21
      49        1        1     0.000000 2030-01-05 16:04:24 2030-01-05 16:04:24
      50        2        1     2.964329 2030-01-05 16:04:27 2030-01-05 16:04:30
      51        1        0     0.000000 2030-01-05 16:04:32 2030-01-05 16:04:32
      52        3        2     3.755043 2030-01-05 16:04:34 2030-01-05 16:04:37
      53        1        0     0.000000 2030-01-05 16:04:40 2030-01-05 16:04:40
      54        1        1     0.000000 2030-01-05 16:04:41 2030-01-05 16:04:41
      55        2        1     1.149162 2030-01-05 16:04:44 2030-01-05 16:04:45
      56        2        1     2.159122 2030-01-05 16:04:49 2030-01-05 16:04:51
      57        2        1     3.384651 2030-01-05 16:04:53 2030-01-05 16:04:57
      58        1        0     0.000000 2030-01-05 16:05:00 2030-01-05 16:05:00
      59        3        2     4.400000 2030-01-05 16:05:02 2030-01-05 16:05:07
      60        2        1     1.010858 2030-01-05 16:05:08 2030-01-05 16:05:09
      61        2        1     3.287893 2030-01-05 16:05:12 2030-01-05 16:05:15
      62        2        1     3.364549 2030-01-05 16:05:18 2030-01-05 16:05:21
      63        2        1     2.475030 2030-01-05 16:05:24 2030-01-05 16:05:27
      64        2        1     1.595165 2030-01-05 16:05:30 2030-01-05 16:05:32
      65        2        1     1.800000 2030-01-05 16:05:34 2030-01-05 16:05:35
      66        7        4    14.800000 2030-01-05 16:00:16 2030-01-05 16:00:31
      67        2        1     3.387810 2030-01-05 16:05:38 2030-01-05 16:05:41
      68        2        1     1.387138 2030-01-05 16:05:44 2030-01-05 16:05:45
      69        2        1     2.564463 2030-01-05 16:05:49 2030-01-05 16:05:51
      70        2        1     2.372880 2030-01-05 16:05:54 2030-01-05 16:05:57
      71        1        0     0.000000 2030-01-05 16:06:00 2030-01-05 16:06:00
      72        1        1     0.000000 2030-01-05 16:06:03 2030-01-05 16:06:03
      73        3        1     3.869979 2030-01-05 16:06:05 2030-01-05 16:06:09
      74        1        1     0.000000 2030-01-05 16:06:12 2030-01-05 16:06:12
      75        4        2     5.250851 2030-01-05 16:06:14 2030-01-05 16:06:19
      76        2        1     2.512541 2030-01-05 16:06:22 2030-01-05 16:06:25
      77        2        1     1.569312 2030-01-05 16:06:26 2030-01-05 16:06:28
      78        4        2     5.548231 2030-01-05 16:06:31 2030-01-05 16:06:37
      79        1        0     0.000000 2030-01-05 16:06:40 2030-01-05 16:06:40
      80        1        1     0.000000 2030-01-05 16:06:41 2030-01-05 16:06:41
      81        2        1     2.884873 2030-01-05 16:06:44 2030-01-05 16:06:46
      82        1        0     0.000000 2030-01-05 16:06:49 2030-01-05 16:06:49
      83        1        1     0.000000 2030-01-05 16:06:50 2030-01-05 16:06:50
      84        2        1     1.079098 2030-01-05 16:06:53 2030-01-05 16:06:54
      85        2        1     2.629314 2030-01-05 16:06:56 2030-01-05 16:06:59
      86        2        1     1.800000 2030-01-05 16:07:00 2030-01-05 16:07:02
      87        2        1     1.377840 2030-01-05 16:07:04 2030-01-05 16:07:06
      88        2        1     1.129746 2030-01-05 16:07:09 2030-01-05 16:07:10
      89        2        1     1.046234 2030-01-05 16:07:11 2030-01-05 16:07:12
      90        2        1     1.525012 2030-01-05 16:07:15 2030-01-05 16:07:17
      91        4        2     7.400000 2030-01-05 16:00:31 2030-01-05 16:00:39
      92        2        1     3.139314 2030-01-05 16:07:20 2030-01-05 16:07:23
      93        1        0     0.000000 2030-01-05 16:07:26 2030-01-05 16:07:26
      94        1        1     0.000000 2030-01-05 16:07:29 2030-01-05 16:07:29
      95        2        1     2.347657 2030-01-05 16:07:32 2030-01-05 16:07:35
      96        2        1     2.654693 2030-01-05 16:07:37 2030-01-05 16:07:40
      97        2        1     2.685528 2030-01-05 16:07:43 2030-01-05 16:07:45
      98        1        0     0.000000 2030-01-05 16:07:48 2030-01-05 16:07:48
      99        1        1     0.400000 2030-01-05 16:07:50 2030-01-05 16:07:50
      100       1        1     0.700000 2030-01-05 16:09:11 2030-01-05 16:09:12
      101       5        2    10.000000 2030-01-05 16:09:13 2030-01-05 16:09:23
      102       5        3     7.800000 2030-01-05 16:09:24 2030-01-05 16:09:32
      103       6        3    12.000000 2030-01-05 16:09:34 2030-01-05 16:09:46
      104       2        1     2.065072 2030-01-05 16:09:48 2030-01-05 16:09:50
      105       1        0     0.000000 2030-01-05 16:09:53 2030-01-05 16:09:53
      106       7        4    13.300000 2030-01-05 16:09:56 2030-01-05 16:10:09
      107       3        1     3.300000 2030-01-05 16:00:42 2030-01-05 16:00:45
      108       2        1     2.000000 2030-01-05 16:10:10 2030-01-05 16:10:12
      109       4        2     7.697971 2030-01-05 16:10:15 2030-01-05 16:10:23
      110       2        1     2.796140 2030-01-05 16:10:26 2030-01-05 16:10:29
      111       2        1     2.960015 2030-01-05 16:10:32 2030-01-05 16:10:35
      112       2        1     1.941216 2030-01-05 16:10:38 2030-01-05 16:10:40
      113       3        1     4.500000 2030-01-05 16:10:43 2030-01-05 16:10:48
      114       2        1     2.100000 2030-01-05 16:10:49 2030-01-05 16:10:52
      115       4        2     5.300000 2030-01-05 16:10:53 2030-01-05 16:10:58
      116       4        2     8.700000 2030-01-05 16:11:01 2030-01-05 16:11:10
      117       3        2     5.300000 2030-01-05 16:11:12 2030-01-05 16:11:18
      118       2        1     2.326057 2030-01-05 16:11:18 2030-01-05 16:11:20
      119       6        3     9.624296 2030-01-05 16:11:24 2030-01-05 16:11:33
      120       7        3    12.500000 2030-01-05 16:11:35 2030-01-05 16:11:47
      121       7        4    15.300000 2030-01-05 16:00:45 2030-01-05 16:01:01
      122       3        2     4.700000 2030-01-05 16:11:49 2030-01-05 16:11:53
      123       2        1     2.533072 2030-01-05 16:11:55 2030-01-05 16:11:58
      124       2        1     3.249823 2030-01-05 16:12:01 2030-01-05 16:12:04
      125       1        0     0.000000 2030-01-05 16:12:08 2030-01-05 16:12:08
      126       3        2     2.715474 2030-01-05 16:12:10 2030-01-05 16:12:13
      127       2        1     1.158041 2030-01-05 16:12:16 2030-01-05 16:12:17
      128       2        1     2.800000 2030-01-05 16:12:19 2030-01-05 16:12:22
      129       2        1     2.960239 2030-01-05 16:12:23 2030-01-05 16:12:26
      130       3        1     4.363851 2030-01-05 16:12:29 2030-01-05 16:12:34
      131       6        3    12.600000 2030-01-05 16:12:36 2030-01-05 16:12:48
      132       1        1     0.000000 2030-01-05 16:12:49 2030-01-05 16:12:49
      133       5        2     9.324721 2030-01-05 16:12:52 2030-01-05 16:13:01
      134       5        3    10.500000 2030-01-05 16:13:03 2030-01-05 16:13:13
      135       3        1     5.100000 2030-01-05 16:13:15 2030-01-05 16:13:20
      136       1        1     0.800000 2030-01-05 16:13:22 2030-01-05 16:13:22
      137       6        3    12.500000 2030-01-05 16:01:02 2030-01-05 16:01:14
      138       1        1     0.300000 2030-01-05 16:14:32 2030-01-05 16:14:33
      139       7        3    11.900000 2030-01-05 16:14:35 2030-01-05 16:14:47
      140       3        2     4.519976 2030-01-05 16:14:47 2030-01-05 16:14:52
      141       3        1     3.735198 2030-01-05 16:14:55 2030-01-05 16:14:59
      142       6        3    12.900000 2030-01-05 16:15:01 2030-01-05 16:15:14
      143       3        2     3.000000 2030-01-05 16:15:16 2030-01-05 16:15:19
      144       2        1     1.804156 2030-01-05 16:15:22 2030-01-05 16:15:24
      145       2        1     2.750423 2030-01-05 16:15:27 2030-01-05 16:15:30
      146       4        2     6.500000 2030-01-05 16:15:31 2030-01-05 16:15:37
      147       2        1     2.700000 2030-01-05 16:15:39 2030-01-05 16:15:42
      148       2        1     3.210784 2030-01-05 16:15:42 2030-01-05 16:15:45
      149       2        1     1.395816 2030-01-05 16:15:48 2030-01-05 16:15:50
      150       2        1     1.116176 2030-01-05 16:15:53 2030-01-05 16:15:54
      151       1        0     0.000000 2030-01-05 16:15:58 2030-01-05 16:15:58
      152       1        1     0.000000 2030-01-05 16:16:00 2030-01-05 16:16:00
      153       2        1     3.304581 2030-01-05 16:16:03 2030-01-05 16:16:06
      154       3        1     5.400000 2030-01-05 16:01:15 2030-01-05 16:01:21
      155       4        2     8.977044 2030-01-05 16:16:08 2030-01-05 16:16:17
      156       2        1     1.291937 2030-01-05 16:16:21 2030-01-05 16:16:22
      157       4        2     5.500000 2030-01-05 16:16:25 2030-01-05 16:16:30
      158       2        1     2.700000 2030-01-05 16:16:33 2030-01-05 16:16:35
      159       4        2     6.200000 2030-01-05 16:16:36 2030-01-05 16:16:42
      160       2        1     2.580165 2030-01-05 16:16:43 2030-01-05 16:16:46
      161       4        2     9.396743 2030-01-05 16:16:49 2030-01-05 16:16:59
      162       6        3    10.900000 2030-01-05 16:17:00 2030-01-05 16:17:11
      163       4        2     6.600000 2030-01-05 16:17:12 2030-01-05 16:17:19
      164       3        1     4.200000 2030-01-05 16:17:20 2030-01-05 16:17:24
      165       3        2     4.772883 2030-01-05 16:17:25 2030-01-05 16:17:30
      166       1        0     0.000000 2030-01-05 16:17:33 2030-01-05 16:17:33
      167       2        1     2.800000 2030-01-05 16:17:36 2030-01-05 16:17:38
      168       8        4    16.700000 2030-01-05 16:01:23 2030-01-05 16:01:40
      169       2        1     2.100000 2030-01-05 16:17:40 2030-01-05 16:17:42
      170       2        1     2.900000 2030-01-05 16:17:44 2030-01-05 16:17:47
      171       1        1     0.000000 2030-01-05 16:17:50 2030-01-05 16:17:50
      172       2        1     1.101789 2030-01-05 16:17:53 2030-01-05 16:17:54
      173       3        1     4.224228 2030-01-05 16:17:57 2030-01-05 16:18:01
      174       3        2     4.143621 2030-01-05 16:18:04 2030-01-05 16:18:08
      175       3        1     5.647804 2030-01-05 16:18:11 2030-01-05 16:18:17
      176       4        2     6.000000 2030-01-05 16:18:18 2030-01-05 16:18:24
      177       2        1     2.400000 2030-01-05 16:18:26 2030-01-05 16:18:29
      178       1        1     0.000000 2030-01-05 16:19:40 2030-01-05 16:19:40
      179       3        1     3.495196 2030-01-05 16:19:43 2030-01-05 16:19:46
      180       3        2     2.947890 2030-01-05 16:19:47 2030-01-05 16:19:50
      181       2        1     1.911428 2030-01-05 16:19:53 2030-01-05 16:19:55
      182       2        1     2.003303 2030-01-05 16:19:58 2030-01-05 16:20:00
      183       2        1     2.615042 2030-01-05 16:20:03 2030-01-05 16:20:05
      184       1        0     0.000000 2030-01-05 16:20:09 2030-01-05 16:20:09
      185       5        3     8.400000 2030-01-05 16:20:10 2030-01-05 16:20:19
      186       3        2     4.900000 2030-01-12 18:00:00 2030-01-12 18:00:04
      187       6        3     9.300000 2030-01-12 18:01:15 2030-01-12 18:01:25
      188       1        1     0.000000 2030-01-12 18:20:06 2030-01-12 18:20:06
      189       6        3    11.122575 2030-01-12 18:20:09 2030-01-12 18:20:20
      190       2        1     1.809844 2030-01-12 18:20:23 2030-01-12 18:20:25
      191       2        1     1.164075 2030-01-12 18:20:28 2030-01-12 18:20:29
      192       3        1     3.976506 2030-01-12 18:20:32 2030-01-12 18:20:36
      193       1        1     0.000000 2030-01-12 18:20:39 2030-01-12 18:20:39
      194       1        0     0.000000 2030-01-12 18:20:41 2030-01-12 18:20:41
      195       1        1     0.000000 2030-01-12 18:20:43 2030-01-12 18:20:43
      196       2        1     1.070816 2030-01-12 18:20:47 2030-01-12 18:20:48
      197       2        1     3.108430 2030-01-12 18:20:50 2030-01-12 18:20:53
      198       2        1     3.100000 2030-01-12 18:20:56 2030-01-12 18:20:59
      199       2        1     2.800000 2030-01-12 18:21:00 2030-01-12 18:21:03
      200       2        1     3.180618 2030-01-12 18:21:04 2030-01-12 18:21:07
      201       1        0     0.000000 2030-01-12 18:21:10 2030-01-12 18:21:10
      202       8        4    17.000000 2030-01-12 18:01:26 2030-01-12 18:01:43
      203       3        2     5.800000 2030-01-12 18:01:45 2030-01-12 18:01:51
      204       6        3     9.800000 2030-01-12 18:01:52 2030-01-12 18:02:02
      205       3        1     4.500000 2030-01-12 18:02:02 2030-01-12 18:02:07
      206       3        2     5.100000 2030-01-12 18:02:08 2030-01-12 18:02:13
      207       1        0     0.700000 2030-01-12 18:02:13 2030-01-12 18:02:14
      208       2        1     1.900000 2030-01-12 18:03:20 2030-01-12 18:03:22
      209       1        1     0.000000 2030-01-12 18:03:23 2030-01-12 18:03:23
      210       2        1     2.736682 2030-01-12 18:03:26 2030-01-12 18:03:29
      211       2        1     2.756085 2030-01-12 18:03:32 2030-01-12 18:03:35
      212       3        1     5.000000 2030-01-12 18:03:37 2030-01-12 18:03:42
      213       4        2     6.600000 2030-01-12 18:00:05 2030-01-12 18:00:11
      214       3        2     3.287733 2030-01-12 18:03:43 2030-01-12 18:03:47
      215       1        0     0.000000 2030-01-12 18:03:49 2030-01-12 18:03:49
      216       1        1     0.000000 2030-01-12 18:03:52 2030-01-12 18:03:52
      217       2        1     1.402202 2030-01-12 18:03:54 2030-01-12 18:03:56
      218       2        1     1.848931 2030-01-12 18:03:59 2030-01-12 18:04:01
      219       2        1     3.459990 2030-01-12 18:04:04 2030-01-12 18:04:07
      220       4        2     4.712779 2030-01-12 18:04:08 2030-01-12 18:04:13
      221       2        1     1.531132 2030-01-12 18:04:16 2030-01-12 18:04:18
      222       2        1     1.302540 2030-01-12 18:04:21 2030-01-12 18:04:22
      223       2        1     1.887556 2030-01-12 18:04:25 2030-01-12 18:04:27
      224       2        1     1.826424 2030-01-12 18:04:30 2030-01-12 18:04:32
      225       6        3     7.000000 2030-01-12 18:04:34 2030-01-12 18:04:41
      226       2        1     3.225265 2030-01-12 18:04:43 2030-01-12 18:04:46
      227       1        0     0.000000 2030-01-12 18:04:49 2030-01-12 18:04:49
      228       1        1     0.000000 2030-01-12 18:04:51 2030-01-12 18:04:51
      229       2        1     2.730263 2030-01-12 18:04:55 2030-01-12 18:04:57
      230       2        1     1.648295 2030-01-12 18:05:00 2030-01-12 18:05:01
      231       3        1     5.400000 2030-01-12 18:05:03 2030-01-12 18:05:08
      232       3        2     4.500000 2030-01-12 18:05:10 2030-01-12 18:05:14
      233       6        3     9.600000 2030-01-12 18:00:14 2030-01-12 18:00:23
      234       2        1     2.662334 2030-01-12 18:05:16 2030-01-12 18:05:19
      235       2        1     3.323382 2030-01-12 18:05:22 2030-01-12 18:05:25
      236       2        1     2.884742 2030-01-12 18:05:28 2030-01-12 18:05:31
      237       2        1     3.073073 2030-01-12 18:05:32 2030-01-12 18:05:35
      238       1        0     0.000000 2030-01-12 18:05:37 2030-01-12 18:05:37
      239       3        2     2.830276 2030-01-12 18:05:39 2030-01-12 18:05:42
      240       2        1     1.243147 2030-01-12 18:05:45 2030-01-12 18:05:46
      241       2        1     2.672515 2030-01-12 18:05:49 2030-01-12 18:05:51
      242       2        1     3.377877 2030-01-12 18:05:54 2030-01-12 18:05:57
      243       4        2     3.916240 2030-01-12 18:06:00 2030-01-12 18:06:04
      244       2        1     3.158223 2030-01-12 18:06:06 2030-01-12 18:06:09
      245       1        0     0.000000 2030-01-12 18:06:11 2030-01-12 18:06:11
      246       3        2     5.102767 2030-01-12 18:06:14 2030-01-12 18:06:19
      247       2        1     2.542565 2030-01-12 18:06:21 2030-01-12 18:06:24
      248       2        1     1.531337 2030-01-12 18:06:26 2030-01-12 18:06:27
      249       3        1     3.127378 2030-01-12 18:06:30 2030-01-12 18:06:34
      250       5        3     5.169358 2030-01-12 18:06:36 2030-01-12 18:06:41
      251       1        0     0.000000 2030-01-12 18:06:44 2030-01-12 18:06:44
      252       5        3    10.100000 2030-01-12 18:06:45 2030-01-12 18:06:55
      253       6        3    12.700000 2030-01-12 18:07:52 2030-01-12 18:08:05
      254       2        1     2.600000 2030-01-12 18:00:24 2030-01-12 18:00:27
      255       5        3     7.561265 2030-01-12 18:08:07 2030-01-12 18:08:14
      256       1        0     0.000000 2030-01-12 18:08:18 2030-01-12 18:08:18
      257       3        2     5.400000 2030-01-12 18:08:20 2030-01-12 18:08:25
      258       3        1     5.000000 2030-01-12 18:08:26 2030-01-12 18:08:31
      259       3        2     5.800000 2030-01-12 18:08:32 2030-01-12 18:08:37
      260       3        1     4.400000 2030-01-12 18:08:38 2030-01-12 18:08:43
      261       3        2     3.096777 2030-01-12 18:08:44 2030-01-12 18:08:47
      262       2        1     1.527421 2030-01-12 18:08:51 2030-01-12 18:08:52
      263       2        1     2.600000 2030-01-12 18:08:55 2030-01-12 18:08:58
      264       4        2     6.900000 2030-01-12 18:09:00 2030-01-12 18:09:07
      265       2        1     1.314013 2030-01-12 18:09:10 2030-01-12 18:09:11
      266       4        2     6.937209 2030-01-12 18:09:14 2030-01-12 18:09:21
      267       2        1     3.341973 2030-01-12 18:09:24 2030-01-12 18:09:28
      268       5        2     9.200827 2030-01-12 18:09:31 2030-01-12 18:09:40
      269       4        2     7.500000 2030-01-12 18:00:28 2030-01-12 18:00:36
      270       3        2     4.500000 2030-01-12 18:09:42 2030-01-12 18:09:47
      271       5        2    10.300000 2030-01-12 18:09:50 2030-01-12 18:10:00
      272       2        1     2.000000 2030-01-12 18:10:01 2030-01-12 18:10:03
      273       3        2     5.886021 2030-01-12 18:10:05 2030-01-12 18:10:11
      274       3        1     4.337725 2030-01-12 18:10:14 2030-01-12 18:10:19
      275       3        2     4.200000 2030-01-12 18:10:20 2030-01-12 18:10:24
      276       4        2     6.212980 2030-01-12 18:10:26 2030-01-12 18:10:33
      277       2        1     2.002401 2030-01-12 18:10:36 2030-01-12 18:10:38
      278       4        2     6.400000 2030-01-12 18:10:41 2030-01-12 18:10:47
      279       6        3     8.641519 2030-01-12 18:10:49 2030-01-12 18:10:58
      280       1        0     0.000000 2030-01-12 18:11:01 2030-01-12 18:11:01
      281       5        3     9.774942 2030-01-12 18:11:03 2030-01-12 18:11:12
      282       3        1     3.722835 2030-01-12 18:11:15 2030-01-12 18:11:19
      283       3        2     5.226430 2030-01-12 18:11:20 2030-01-12 18:11:25
      284       2        1     1.898425 2030-01-12 18:11:28 2030-01-12 18:11:30
      285       2        1     2.414275 2030-01-12 18:11:33 2030-01-12 18:11:36
      286       5        2     7.000000 2030-01-12 18:00:38 2030-01-12 18:00:45
      287       4        2     8.000000 2030-01-12 18:11:37 2030-01-12 18:11:45
      288       3        1     3.000000 2030-01-12 18:11:47 2030-01-12 18:11:50
      289       3        2     4.500000 2030-01-12 18:11:51 2030-01-12 18:11:56
      290       7        3    15.900000 2030-01-12 18:11:57 2030-01-12 18:12:13
      291       5        3     6.900000 2030-01-12 18:12:15 2030-01-12 18:12:22
      292       3        2     5.900000 2030-01-12 18:13:36 2030-01-12 18:13:42
      293       2        1     3.600000 2030-01-12 18:13:44 2030-01-12 18:13:47
      294       5        2     9.900000 2030-01-12 18:13:49 2030-01-12 18:13:59
      295       1        1     0.000000 2030-01-12 18:14:00 2030-01-12 18:14:00
      296       2        1     1.505355 2030-01-12 18:14:03 2030-01-12 18:14:04
      297       2        1     2.376395 2030-01-12 18:14:07 2030-01-12 18:14:10
      298       5        2    11.000000 2030-01-12 18:14:12 2030-01-12 18:14:23
      299       4        2     9.900000 2030-01-12 18:00:48 2030-01-12 18:00:58
      300       3        2     5.100000 2030-01-12 18:14:24 2030-01-12 18:14:29
      301       2        1     2.700000 2030-01-12 18:14:32 2030-01-12 18:14:35
      302       4        2     5.500000 2030-01-12 18:14:36 2030-01-12 18:14:42
      303       2        1     3.800000 2030-01-12 18:14:43 2030-01-12 18:14:46
      304       3        1     4.300000 2030-01-12 18:14:49 2030-01-12 18:14:53
      305       3        2     5.000000 2030-01-12 18:14:55 2030-01-12 18:15:00
      306       4        2     5.419077 2030-01-12 18:15:01 2030-01-12 18:15:06
      307       3        1     3.719069 2030-01-12 18:15:10 2030-01-12 18:15:13
      308       1        1     0.000000 2030-01-12 18:15:15 2030-01-12 18:15:15
      309       3        1     5.476950 2030-01-12 18:15:18 2030-01-12 18:15:24
      310       1        1     0.000000 2030-01-12 18:15:26 2030-01-12 18:15:26
      311       3        1     3.962130 2030-01-12 18:15:29 2030-01-12 18:15:33
      312       5        3     8.700000 2030-01-12 18:15:35 2030-01-12 18:15:44
      313       3        2     5.500000 2030-01-12 18:00:59 2030-01-12 18:01:05
      314       2        1     3.169741 2030-01-12 18:15:45 2030-01-12 18:15:48
      315       1        0     0.000000 2030-01-12 18:15:51 2030-01-12 18:15:51
      316       1        1     0.000000 2030-01-12 18:15:54 2030-01-12 18:15:54
      317       3        1     4.479933 2030-01-12 18:15:57 2030-01-12 18:16:02
      318       4        2     6.800000 2030-01-12 18:16:04 2030-01-12 18:16:11
      319       1        1     0.000000 2030-01-12 18:16:13 2030-01-12 18:16:13
      320       2        1     1.544947 2030-01-12 18:16:16 2030-01-12 18:16:17
      321       3        1     3.406495 2030-01-12 18:16:21 2030-01-12 18:16:24
      322       7        4    13.800000 2030-01-12 18:16:28 2030-01-12 18:16:41
      323       2        1     2.600000 2030-01-12 18:16:44 2030-01-12 18:16:47
      324       6        3    12.400000 2030-01-12 18:16:49 2030-01-12 18:17:01
      325       5        2     8.700000 2030-01-12 18:17:02 2030-01-12 18:17:11
      326       1        1     0.000000 2030-01-12 18:17:12 2030-01-12 18:17:12
      327       4        2     7.130767 2030-01-12 18:17:15 2030-01-12 18:17:22
      328       2        1     1.824595 2030-01-12 18:17:26 2030-01-12 18:17:28
      329       1        0     0.700000 2030-01-12 18:17:29 2030-01-12 18:17:30
      330       3        1     6.000000 2030-01-12 18:01:07 2030-01-12 18:01:13
      331       1        1     0.000000 2030-01-12 18:18:30 2030-01-12 18:18:30
      332       2        1     1.640284 2030-01-12 18:18:32 2030-01-12 18:18:34
      333       2        1     1.943919 2030-01-12 18:18:37 2030-01-12 18:18:39
      334       2        1     2.540260 2030-01-12 18:18:42 2030-01-12 18:18:45
      335       6        3     9.715496 2030-01-12 18:18:46 2030-01-12 18:18:56
      336       1        0     0.000000 2030-01-12 18:19:00 2030-01-12 18:19:00
      337       1        1     0.000000 2030-01-12 18:19:02 2030-01-12 18:19:02
      338       2        1     2.487464 2030-01-12 18:19:05 2030-01-12 18:19:08
      339       1        0     0.000000 2030-01-12 18:19:10 2030-01-12 18:19:10
      340       1        1     0.000000 2030-01-12 18:19:14 2030-01-12 18:19:14
      341       2        1     1.160519 2030-01-12 18:19:16 2030-01-12 18:19:17
      342       1        0     0.000000 2030-01-12 18:19:20 2030-01-12 18:19:20
      343       3        2     3.934464 2030-01-12 18:19:22 2030-01-12 18:19:26
      344       1        0     0.000000 2030-01-12 18:19:29 2030-01-12 18:19:29
      345       3        2     5.139489 2030-01-12 18:19:32 2030-01-12 18:19:37
      346       2        1     1.576331 2030-01-12 18:19:39 2030-01-12 18:19:41
      347       1        0     0.000000 2030-01-12 18:19:44 2030-01-12 18:19:44
      348       1        1     0.000000 2030-01-12 18:19:46 2030-01-12 18:19:46
      349       1        0     0.000000 2030-01-12 18:19:49 2030-01-12 18:19:49
      350       3        2     4.600000 2030-01-12 18:19:51 2030-01-12 18:19:56
      351       2        1     3.407587 2030-01-12 18:19:58 2030-01-12 18:20:01
      352       1        0     0.000000 2030-01-12 18:20:04 2030-01-12 18:20:04
      353       7        4    12.000000 2030-01-19 13:00:00 2030-01-19 13:00:12
      354       2        1     3.600000 2030-01-19 13:01:33 2030-01-19 13:01:37
      355       1        1     0.000000 2030-01-19 13:20:54 2030-01-19 13:20:54
      356       4        2     8.526939 2030-01-19 13:20:57 2030-01-19 13:21:05
      357       1        0     0.000000 2030-01-19 13:21:09 2030-01-19 13:21:09
      358       3        2     4.930609 2030-01-19 13:21:11 2030-01-19 13:21:16
      359       2        1     1.363159 2030-01-19 13:21:18 2030-01-19 13:21:19
      360       1        0     0.000000 2030-01-19 13:21:22 2030-01-19 13:21:22
      361       1        1     0.000000 2030-01-19 13:21:25 2030-01-19 13:21:25
      362       2        1     2.717394 2030-01-19 13:21:27 2030-01-19 13:21:30
      363       2        1     1.929924 2030-01-19 13:21:33 2030-01-19 13:21:35
      364       4        2     6.283252 2030-01-19 13:21:38 2030-01-19 13:21:44
      365       2        1     2.800000 2030-01-19 13:21:47 2030-01-19 13:21:50
      366       3        2     4.600000 2030-01-19 13:01:40 2030-01-19 13:01:44
      367       4        2     6.300000 2030-01-19 13:01:47 2030-01-19 13:01:53
      368       4        2     8.200000 2030-01-19 13:01:54 2030-01-19 13:02:03
      369       4        2     7.200000 2030-01-19 13:02:03 2030-01-19 13:02:10
      370       3        1     5.100000 2030-01-19 13:02:13 2030-01-19 13:02:18
      371       6        3     9.800000 2030-01-19 13:02:19 2030-01-19 13:02:29
      372       2        1     3.600000 2030-01-19 13:02:30 2030-01-19 13:02:33
      373       6        3    16.200000 2030-01-19 13:02:35 2030-01-19 13:02:51
      374       4        2     8.900000 2030-01-19 13:02:52 2030-01-19 13:03:01
      375       3        1     6.400000 2030-01-19 13:00:13 2030-01-19 13:00:20
      376       1        1     0.900000 2030-01-19 13:03:04 2030-01-19 13:03:05
      377       1        1     0.500000 2030-01-19 13:04:22 2030-01-19 13:04:22
      378       3        1     4.700000 2030-01-19 13:04:24 2030-01-19 13:04:29
      379       1        1     0.000000 2030-01-19 13:04:31 2030-01-19 13:04:31
      380       2        1     3.494438 2030-01-19 13:04:34 2030-01-19 13:04:37
      381       2        1     1.047330 2030-01-19 13:04:40 2030-01-19 13:04:41
      382       2        1     1.848619 2030-01-19 13:04:43 2030-01-19 13:04:45
      383       2        1     1.902763 2030-01-19 13:04:47 2030-01-19 13:04:49
      384       2        1     1.219508 2030-01-19 13:04:52 2030-01-19 13:04:53
      385       4        2     5.400000 2030-01-19 13:04:55 2030-01-19 13:05:00
      386       2        1     1.989836 2030-01-19 13:05:00 2030-01-19 13:05:02
      387       2        1     3.010116 2030-01-19 13:05:05 2030-01-19 13:05:08
      388       1        0     0.000000 2030-01-19 13:05:12 2030-01-19 13:05:12
      389       3        2     3.942474 2030-01-19 13:05:13 2030-01-19 13:05:17
      390       4        2     6.106177 2030-01-19 13:05:21 2030-01-19 13:05:27
      391       2        1     1.442313 2030-01-19 13:05:29 2030-01-19 13:05:30
      392       2        1     2.411176 2030-01-19 13:05:33 2030-01-19 13:05:36
      393       2        1     2.337169 2030-01-19 13:05:38 2030-01-19 13:05:40
      394       2        1     1.005145 2030-01-19 13:05:42 2030-01-19 13:05:43
      395       2        1     1.777099 2030-01-19 13:05:45 2030-01-19 13:05:47
      396       2        1     1.285550 2030-01-19 13:05:49 2030-01-19 13:05:51
      397       2        1     3.406435 2030-01-19 13:05:53 2030-01-19 13:05:57
      398       5        3    13.200000 2030-01-19 13:00:22 2030-01-19 13:00:35
      399       2        1     1.968480 2030-01-19 13:05:58 2030-01-19 13:06:00
      400       2        1     1.613353 2030-01-19 13:06:02 2030-01-19 13:06:04
      401       2        1     1.260627 2030-01-19 13:06:06 2030-01-19 13:06:07
      402       2        1     2.322351 2030-01-19 13:06:09 2030-01-19 13:06:11
      403       1        0     0.000000 2030-01-19 13:06:14 2030-01-19 13:06:14
      404       5        3     9.200000 2030-01-19 13:06:15 2030-01-19 13:06:25
      405       5        2     7.300000 2030-01-19 13:06:25 2030-01-19 13:06:33
      406       3        2     4.385394 2030-01-19 13:06:34 2030-01-19 13:06:39
      407       2        1     2.581063 2030-01-19 13:06:41 2030-01-19 13:06:43
      408       2        1     1.013063 2030-01-19 13:06:46 2030-01-19 13:06:47
      409       2        1     1.680684 2030-01-19 13:06:49 2030-01-19 13:06:51
      410       1        0     0.000000 2030-01-19 13:06:54 2030-01-19 13:06:54
      411       1        1     0.000000 2030-01-19 13:06:58 2030-01-19 13:06:58
      412       2        1     3.200846 2030-01-19 13:07:00 2030-01-19 13:07:03
      413       2        1     3.300000 2030-01-19 13:07:06 2030-01-19 13:07:09
      414       2        1     2.600000 2030-01-19 13:08:31 2030-01-19 13:08:34
      415       3        2     4.300000 2030-01-19 13:08:34 2030-01-19 13:08:39
      416       6        3    10.700000 2030-01-19 13:00:38 2030-01-19 13:00:48
      417       3        1     3.900000 2030-01-19 13:08:41 2030-01-19 13:08:45
      418       3        2     4.400000 2030-01-19 13:08:45 2030-01-19 13:08:50
      419       6        3    10.300000 2030-01-19 13:08:52 2030-01-19 13:09:02
      420       4        2     8.371129 2030-01-19 13:09:03 2030-01-19 13:09:11
      421       1        0     0.000000 2030-01-19 13:09:14 2030-01-19 13:09:14
      422       4        2     9.000000 2030-01-19 13:09:17 2030-01-19 13:09:26
      423       5        3     8.531805 2030-01-19 13:09:27 2030-01-19 13:09:36
      424       2        1     1.083719 2030-01-19 13:09:39 2030-01-19 13:09:40
      425       6        3    10.700000 2030-01-19 13:09:41 2030-01-19 13:09:52
      426       3        1     4.300000 2030-01-19 13:09:53 2030-01-19 13:09:57
      427       1        1     0.000000 2030-01-19 13:10:00 2030-01-19 13:10:00
      428       2        1     2.285660 2030-01-19 13:10:03 2030-01-19 13:10:05
      429       4        2     7.027679 2030-01-19 13:10:07 2030-01-19 13:10:14
      430       1        0     0.000000 2030-01-19 13:10:17 2030-01-19 13:10:17
      431       3        1     6.700000 2030-01-19 13:00:49 2030-01-19 13:00:56
      432       4        2     6.200000 2030-01-19 13:10:20 2030-01-19 13:10:26
      433       4        2     6.200000 2030-01-19 13:10:28 2030-01-19 13:10:34
      434       5        3     9.800000 2030-01-19 13:10:34 2030-01-19 13:10:44
      435       2        1     1.152861 2030-01-19 13:10:46 2030-01-19 13:10:47
      436       3        1     4.214407 2030-01-19 13:10:51 2030-01-19 13:10:55
      437       5        3    10.300000 2030-01-19 13:10:58 2030-01-19 13:11:08
      438       6        3    10.800000 2030-01-19 13:11:10 2030-01-19 13:11:21
      439       5        2     9.300000 2030-01-19 13:11:23 2030-01-19 13:11:32
      440       3        2     4.335341 2030-01-19 13:11:35 2030-01-19 13:11:39
      441       2        1     2.343490 2030-01-19 13:11:43 2030-01-19 13:11:45
      442       3        1     6.900000 2030-01-19 13:11:48 2030-01-19 13:11:55
      443       2        1     1.800000 2030-01-19 13:11:57 2030-01-19 13:11:59
      444       5        3    10.100000 2030-01-19 13:00:57 2030-01-19 13:01:07
      445       6        3    11.900000 2030-01-19 13:12:01 2030-01-19 13:12:13
      446       2        1     3.300000 2030-01-19 13:12:16 2030-01-19 13:12:19
      447       1        1     0.800000 2030-01-19 13:12:20 2030-01-19 13:12:21
      448       1        1     0.000000 2030-01-19 13:13:44 2030-01-19 13:13:44
      449       1        0     0.000000 2030-01-19 13:13:47 2030-01-19 13:13:47
      450       8        4    12.400000 2030-01-19 13:13:50 2030-01-19 13:14:02
      451       5        3     9.600000 2030-01-19 13:14:05 2030-01-19 13:14:15
      452       4        2     5.700000 2030-01-19 13:14:16 2030-01-19 13:14:21
      453       5        2     8.600000 2030-01-19 13:14:22 2030-01-19 13:14:30
      454       5        3    10.000000 2030-01-19 13:14:31 2030-01-19 13:14:41
      455       5        2     7.700000 2030-01-19 13:14:44 2030-01-19 13:14:51
      456       5        2     9.900000 2030-01-19 13:01:08 2030-01-19 13:01:17
      457       4        2     6.800000 2030-01-19 13:14:53 2030-01-19 13:15:00
      458       7        4    14.200000 2030-01-19 13:15:02 2030-01-19 13:15:17
      459       2        1     2.787739 2030-01-19 13:15:18 2030-01-19 13:15:21
      460       5        2     7.023891 2030-01-19 13:15:24 2030-01-19 13:15:32
      461       5        3     7.800000 2030-01-19 13:15:33 2030-01-19 13:15:41
      462       3        1     3.000000 2030-01-19 13:15:42 2030-01-19 13:15:45
      463       5        3     9.500000 2030-01-19 13:15:46 2030-01-19 13:15:55
      464       3        1     4.200000 2030-01-19 13:15:56 2030-01-19 13:16:01
      465       2        1     3.300000 2030-01-19 13:16:01 2030-01-19 13:16:05
      466       6        3    10.200000 2030-01-19 13:16:06 2030-01-19 13:16:17
      467       1        1     0.000000 2030-01-19 13:16:18 2030-01-19 13:16:18
      468       4        2     7.579179 2030-01-19 13:16:21 2030-01-19 13:16:28
      469       1        0     0.000000 2030-01-19 13:16:32 2030-01-19 13:16:32
      470       2        1     1.900000 2030-01-19 13:01:19 2030-01-19 13:01:21
      471       4        2     5.800000 2030-01-19 13:16:35 2030-01-19 13:16:41
      472       7        4    11.600000 2030-01-19 13:16:41 2030-01-19 13:16:53
      473       4        2     6.900000 2030-01-19 13:16:55 2030-01-19 13:17:02
      474       3        1     3.800000 2030-01-19 13:17:03 2030-01-19 13:17:07
      475       1        1     0.000000 2030-01-19 13:17:10 2030-01-19 13:17:10
      476       2        1     1.673456 2030-01-19 13:17:13 2030-01-19 13:17:15
      477       2        1     2.286322 2030-01-19 13:17:18 2030-01-19 13:17:21
      478       2        1     3.004808 2030-01-19 13:17:23 2030-01-19 13:17:26
      479       2        1     3.304498 2030-01-19 13:17:30 2030-01-19 13:17:33
      480       5        2     9.800000 2030-01-19 13:17:34 2030-01-19 13:17:44
      481       2        1     4.100000 2030-01-19 13:18:59 2030-01-19 13:19:03
      482       1        1     0.000000 2030-01-19 13:19:04 2030-01-19 13:19:04
      483       3        1     3.708152 2030-01-19 13:19:07 2030-01-19 13:19:10
      484       1        1     0.000000 2030-01-19 13:19:14 2030-01-19 13:19:14
      485       4        2     5.903265 2030-01-19 13:19:16 2030-01-19 13:19:22
      486       4        2     9.200000 2030-01-19 13:01:24 2030-01-19 13:01:33
      487       4        2     3.905565 2030-01-19 13:19:23 2030-01-19 13:19:27
      488       1        0     0.000000 2030-01-19 13:19:30 2030-01-19 13:19:30
      489       1        1     0.000000 2030-01-19 13:19:31 2030-01-19 13:19:31
      490       3        1     2.952069 2030-01-19 13:19:33 2030-01-19 13:19:36
      491       3        2     2.900000 2030-01-19 13:19:38 2030-01-19 13:19:41
      492       2        1     2.559544 2030-01-19 13:19:43 2030-01-19 13:19:46
      493       2        1     2.621899 2030-01-19 13:19:49 2030-01-19 13:19:51
      494       2        1     2.667640 2030-01-19 13:19:54 2030-01-19 13:19:56
      495       2        1     2.355112 2030-01-19 13:19:59 2030-01-19 13:20:01
      496       3        1     4.400000 2030-01-19 13:20:04 2030-01-19 13:20:08
      497       1        1     0.000000 2030-01-19 13:20:09 2030-01-19 13:20:09
      498       2        1     1.779632 2030-01-19 13:20:11 2030-01-19 13:20:13
      499       2        1     2.075860 2030-01-19 13:20:15 2030-01-19 13:20:17
      500       2        1     2.138028 2030-01-19 13:20:18 2030-01-19 13:20:20
      501       4        2     5.474508 2030-01-19 13:20:23 2030-01-19 13:20:29
      502       1        0     0.000000 2030-01-19 13:20:32 2030-01-19 13:20:32
      503       5        3     8.500000 2030-01-19 13:20:36 2030-01-19 13:20:44
      504       5        2     8.200000 2030-01-19 13:20:45 2030-01-19 13:20:53
      505       3        2     6.400000 2030-01-26 18:00:00 2030-01-26 18:00:06
      506       5        3     7.600000 2030-01-26 18:01:17 2030-01-26 18:01:24
      507       4        2     6.800000 2030-01-26 18:01:25 2030-01-26 18:01:32
      508       6        3    13.900000 2030-01-26 18:01:33 2030-01-26 18:01:47
      509       5        2     7.700000 2030-01-26 18:01:49 2030-01-26 18:01:57
      510       2        1     2.600000 2030-01-26 18:01:58 2030-01-26 18:02:01
      511       4        2     6.300000 2030-01-26 18:02:02 2030-01-26 18:02:08
      512       5        3     8.800000 2030-01-26 18:03:13 2030-01-26 18:03:22
      513       2        1     1.326308 2030-01-26 18:03:25 2030-01-26 18:03:26
      514       2        1     2.665057 2030-01-26 18:03:28 2030-01-26 18:03:31
      515       1        0     0.000000 2030-01-26 18:03:34 2030-01-26 18:03:34
      516       3        2     5.000000 2030-01-26 18:03:37 2030-01-26 18:03:42
      517       6        3     9.200000 2030-01-26 18:03:45 2030-01-26 18:03:54
      518       3        1     6.200000 2030-01-26 18:00:07 2030-01-26 18:00:13
      519       2        1     3.600000 2030-01-26 18:03:56 2030-01-26 18:04:00
      520       5        2     8.100000 2030-01-26 18:04:01 2030-01-26 18:04:09
      521       3        2     4.900000 2030-01-26 18:04:10 2030-01-26 18:04:15
      522       4        2     7.900000 2030-01-26 18:04:16 2030-01-26 18:04:24
      523       2        1     1.645228 2030-01-26 18:04:27 2030-01-26 18:04:29
      524       2        1     3.050684 2030-01-26 18:04:32 2030-01-26 18:04:35
      525       2        1     1.866643 2030-01-26 18:04:37 2030-01-26 18:04:39
      526       2        1     2.961670 2030-01-26 18:04:42 2030-01-26 18:04:45
      527       2        1     1.511286 2030-01-26 18:04:47 2030-01-26 18:04:48
      528       1        0     0.000000 2030-01-26 18:04:51 2030-01-26 18:04:51
      529       1        1     0.000000 2030-01-26 18:04:54 2030-01-26 18:04:54
      530       2        1     1.126685 2030-01-26 18:04:57 2030-01-26 18:04:58
      531       2        1     1.799658 2030-01-26 18:05:00 2030-01-26 18:05:02
      532       2        1     4.000000 2030-01-26 18:05:05 2030-01-26 18:05:09
      533       2        1     2.939333 2030-01-26 18:05:09 2030-01-26 18:05:12
      534       2        1     2.465312 2030-01-26 18:05:15 2030-01-26 18:05:18
      535       3        2     4.700000 2030-01-26 18:00:14 2030-01-26 18:00:18
      536       5        2     7.900000 2030-01-26 18:05:19 2030-01-26 18:05:27
      537       3        2     3.203179 2030-01-26 18:05:27 2030-01-26 18:05:31
      538       2        1     1.834683 2030-01-26 18:05:33 2030-01-26 18:05:35
      539       2        1     3.075218 2030-01-26 18:05:37 2030-01-26 18:05:41
      540       2        1     1.467582 2030-01-26 18:05:43 2030-01-26 18:05:45
      541       2        1     1.700939 2030-01-26 18:05:47 2030-01-26 18:05:49
      542       2        1     1.541591 2030-01-26 18:05:51 2030-01-26 18:05:53
      543       4        2     5.421024 2030-01-26 18:05:54 2030-01-26 18:05:59
      544       1        0     0.000000 2030-01-26 18:06:02 2030-01-26 18:06:02
      545       4        2     7.900000 2030-01-26 18:06:04 2030-01-26 18:06:12
      546       3        2     3.872504 2030-01-26 18:06:13 2030-01-26 18:06:17
      547       2        1     2.235141 2030-01-26 18:06:20 2030-01-26 18:06:22
      548       1        0     0.000000 2030-01-26 18:06:24 2030-01-26 18:06:24
      549       3        2     3.636357 2030-01-26 18:06:26 2030-01-26 18:06:30
      550       1        0     0.000000 2030-01-26 18:06:32 2030-01-26 18:06:32
      551       3        2     3.100000 2030-01-26 18:06:35 2030-01-26 18:06:38
      552       2        1     1.481775 2030-01-26 18:06:39 2030-01-26 18:06:41
      553       2        1     1.818270 2030-01-26 18:06:44 2030-01-26 18:06:46
      554       7        3    12.100000 2030-01-26 18:00:20 2030-01-26 18:00:32
      555       4        2     3.990304 2030-01-26 18:06:47 2030-01-26 18:06:51
      556       1        0     0.000000 2030-01-26 18:06:54 2030-01-26 18:06:54
      557       1        1     0.000000 2030-01-26 18:08:16 2030-01-26 18:08:16
      558       4        2     4.215260 2030-01-26 18:08:20 2030-01-26 18:08:24
      559       2        1     2.100000 2030-01-26 18:08:27 2030-01-26 18:08:29
      560       5        2     8.600000 2030-01-26 18:08:31 2030-01-26 18:08:40
      561       3        2     3.100000 2030-01-26 18:08:41 2030-01-26 18:08:45
      562       4        2     7.400000 2030-01-26 18:08:45 2030-01-26 18:08:52
      563       3        1     5.700000 2030-01-26 18:08:54 2030-01-26 18:08:59
      564       2        1     2.100000 2030-01-26 18:09:01 2030-01-26 18:09:04
      565       4        2     9.300000 2030-01-26 18:09:05 2030-01-26 18:09:14
      566       1        1     0.000000 2030-01-26 18:09:15 2030-01-26 18:09:15
      567       2        1     1.322973 2030-01-26 18:09:18 2030-01-26 18:09:20
      568       1        0     0.000000 2030-01-26 18:09:23 2030-01-26 18:09:23
      569       3        2     5.600000 2030-01-26 18:00:35 2030-01-26 18:00:40
      570       3        2     4.437952 2030-01-26 18:09:26 2030-01-26 18:09:30
      571       2        1     1.054193 2030-01-26 18:09:33 2030-01-26 18:09:34
      572       4        2     9.200000 2030-01-26 18:09:38 2030-01-26 18:09:47
      573       6        3    11.800000 2030-01-26 18:09:48 2030-01-26 18:10:00
      574       4        2     6.200000 2030-01-26 18:10:02 2030-01-26 18:10:08
      575       4        2     4.142363 2030-01-26 18:10:11 2030-01-26 18:10:15
      576       1        0     0.000000 2030-01-26 18:10:18 2030-01-26 18:10:18
      577       4        2     6.900000 2030-01-26 18:10:21 2030-01-26 18:10:28
      578       1        1     0.000000 2030-01-26 18:10:30 2030-01-26 18:10:30
      579       3        1     3.517130 2030-01-26 18:10:33 2030-01-26 18:10:37
      580       5        3     7.110513 2030-01-26 18:10:39 2030-01-26 18:10:46
      581       2        1     2.544097 2030-01-26 18:10:50 2030-01-26 18:10:52
      582       3        1     4.300000 2030-01-26 18:10:53 2030-01-26 18:10:58
      583       1        1     0.000000 2030-01-26 18:10:58 2030-01-26 18:10:58
      584       2        1     1.345915 2030-01-26 18:11:02 2030-01-26 18:11:03
      585       4        2     5.897689 2030-01-26 18:11:06 2030-01-26 18:11:12
      586       4        2     7.800000 2030-01-26 18:00:42 2030-01-26 18:00:50
      587       5        2     8.900000 2030-01-26 18:11:13 2030-01-26 18:11:22
      588       7        4    14.400000 2030-01-26 18:11:24 2030-01-26 18:11:38
      589       2        1     2.500000 2030-01-26 18:12:51 2030-01-26 18:12:54
      590       3        2     4.800000 2030-01-26 18:12:56 2030-01-26 18:13:01
      591       3        1     6.700000 2030-01-26 18:13:01 2030-01-26 18:13:08
      592       1        1     0.000000 2030-01-26 18:13:09 2030-01-26 18:13:09
      593       1        0     0.000000 2030-01-26 18:13:12 2030-01-26 18:13:12
      594       4        2     5.500000 2030-01-26 18:13:15 2030-01-26 18:13:20
      595       3        2     5.967961 2030-01-26 18:13:22 2030-01-26 18:13:28
      596       6        3    11.914043 2030-01-26 18:13:32 2030-01-26 18:13:43
      597       2        1     1.602714 2030-01-26 18:13:46 2030-01-26 18:13:48
      598       2        1     3.387677 2030-01-26 18:13:51 2030-01-26 18:13:54
      599       2        1     1.214537 2030-01-26 18:13:58 2030-01-26 18:13:59
      600       5        2    11.900000 2030-01-26 18:14:01 2030-01-26 18:14:13
      601       3        1     6.400000 2030-01-26 18:00:51 2030-01-26 18:00:57
      602       6        3    10.800000 2030-01-26 18:14:15 2030-01-26 18:14:26
      603       1        1     0.000000 2030-01-26 18:14:28 2030-01-26 18:14:28
      604       4        2     9.648526 2030-01-26 18:14:31 2030-01-26 18:14:41
      605       2        1     2.551962 2030-01-26 18:14:44 2030-01-26 18:14:47
      606       2        1     1.362956 2030-01-26 18:14:50 2030-01-26 18:14:51
      607       4        2     8.500000 2030-01-26 18:14:53 2030-01-26 18:15:02
      608       2        1     3.100000 2030-01-26 18:15:04 2030-01-26 18:15:07
      609       2        1     1.597798 2030-01-26 18:15:09 2030-01-26 18:15:10
      610       1        0     0.000000 2030-01-26 18:15:14 2030-01-26 18:15:14
      611       7        4    12.600000 2030-01-26 18:15:16 2030-01-26 18:15:29
      612       7        3    12.900000 2030-01-26 18:15:31 2030-01-26 18:15:44
      613       3        2     6.900000 2030-01-26 18:15:45 2030-01-26 18:15:52
      614       4        2     7.100000 2030-01-26 18:15:54 2030-01-26 18:16:01
      615       5        3     9.500000 2030-01-26 18:00:58 2030-01-26 18:01:08
      616       2        1     1.380843 2030-01-26 18:16:03 2030-01-26 18:16:04
      617       4        2     7.649650 2030-01-26 18:16:07 2030-01-26 18:16:15
      618       1        1     0.000000 2030-01-26 18:17:37 2030-01-26 18:17:37
      619       5        2     8.351102 2030-01-26 18:17:40 2030-01-26 18:17:49
      620       1        1     0.000000 2030-01-26 18:17:52 2030-01-26 18:17:52
      621       1        0     0.000000 2030-01-26 18:17:55 2030-01-26 18:17:55
      622       1        1     0.000000 2030-01-26 18:17:56 2030-01-26 18:17:56
      623       2        1     1.257328 2030-01-26 18:17:59 2030-01-26 18:18:00
      624       5        2     8.175193 2030-01-26 18:18:03 2030-01-26 18:18:11
      625       3        2     3.055294 2030-01-26 18:18:13 2030-01-26 18:18:16
      626       2        1     1.119682 2030-01-26 18:18:19 2030-01-26 18:18:21
      627       1        0     0.000000 2030-01-26 18:18:24 2030-01-26 18:18:24
      628       1        1     0.000000 2030-01-26 18:18:26 2030-01-26 18:18:26
      629       1        0     0.000000 2030-01-26 18:18:28 2030-01-26 18:18:28
      630       2        1     2.800000 2030-01-26 18:18:31 2030-01-26 18:18:34
      631       1        1     0.000000 2030-01-26 18:18:35 2030-01-26 18:18:35
      632       1        0     0.000000 2030-01-26 18:18:38 2030-01-26 18:18:38
      633       3        2     2.506250 2030-01-26 18:18:41 2030-01-26 18:18:44
      634       2        1     1.517064 2030-01-26 18:18:47 2030-01-26 18:18:48
      635       3        1     3.700000 2030-01-26 18:18:49 2030-01-26 18:18:53
      636       3        1     5.700000 2030-01-26 18:01:09 2030-01-26 18:01:14
      637       1        1     0.000000 2030-01-26 18:18:55 2030-01-26 18:18:55
      638       3        1     2.674021 2030-01-26 18:18:57 2030-01-26 18:19:00
      639       1        1     0.000000 2030-01-26 18:19:02 2030-01-26 18:19:02
      640       2        1     3.416287 2030-01-26 18:19:05 2030-01-26 18:19:09
      641       1        0     0.000000 2030-01-26 18:19:11 2030-01-26 18:19:11
      642       2        1     1.800000 2030-01-26 18:19:14 2030-01-26 18:19:15
      643       1        1     0.000000 2030-01-26 18:19:18 2030-01-26 18:19:18
      644       2        1     2.983489 2030-01-26 18:19:21 2030-01-26 18:19:24
      645       2        1     2.791586 2030-01-26 18:19:26 2030-01-26 18:19:29
      646       2        1     1.466003 2030-01-26 18:19:31 2030-01-26 18:19:33
      647       1        0     0.000000 2030-01-26 18:19:35 2030-01-26 18:19:35
      648       1        1     0.000000 2030-01-26 18:19:36 2030-01-26 18:19:36
      649       1        0     0.000000 2030-01-26 18:19:39 2030-01-26 18:19:39
      650       1        1     0.500000 2030-01-26 18:19:41 2030-01-26 18:19:41
      651       5        3     8.800000 2030-02-02 14:00:00 2030-02-02 14:00:08
      652       3        1     4.700000 2030-02-02 14:01:33 2030-02-02 14:01:37
      653       1        1     0.000000 2030-02-02 14:19:26 2030-02-02 14:19:26
      654       2        1     3.449225 2030-02-02 14:19:29 2030-02-02 14:19:33
      655       1        0     0.000000 2030-02-02 14:19:35 2030-02-02 14:19:35
      656       1        1     0.000000 2030-02-02 14:19:39 2030-02-02 14:19:39
      657       3        1     2.805108 2030-02-02 14:19:41 2030-02-02 14:19:44
      658       1        1     0.000000 2030-02-02 14:19:48 2030-02-02 14:19:48
      659       2        1     1.900974 2030-02-02 14:19:51 2030-02-02 14:19:53
      660       1        0     0.000000 2030-02-02 14:19:56 2030-02-02 14:19:56
      661       3        2     4.456482 2030-02-02 14:19:57 2030-02-02 14:20:01
      662       2        1     1.557995 2030-02-02 14:20:04 2030-02-02 14:20:06
      663       2        1     3.100000 2030-02-02 14:20:07 2030-02-02 14:20:10
      664       4        2     5.155609 2030-02-02 14:20:13 2030-02-02 14:20:18
      665       4        2     6.376724 2030-02-02 14:20:21 2030-02-02 14:20:27
      666       6        3    11.800000 2030-02-02 14:20:29 2030-02-02 14:20:41
      667       2        1     3.330065 2030-02-02 14:20:43 2030-02-02 14:20:46
      668       2        1     3.344256 2030-02-02 14:20:49 2030-02-02 14:20:53
      669       3        1     3.600000 2030-02-02 14:20:55 2030-02-02 14:20:59
      670       5        3     6.779280 2030-02-02 14:21:00 2030-02-02 14:21:07
      671       2        1     2.461938 2030-02-02 14:21:09 2030-02-02 14:21:12
      672       8        4    16.300000 2030-02-02 14:01:38 2030-02-02 14:01:54
      673       2        1     3.600000 2030-02-02 14:21:14 2030-02-02 14:21:18
      674       2        1     2.900000 2030-02-02 14:01:55 2030-02-02 14:01:58
      675       3        2     3.900000 2030-02-02 14:02:01 2030-02-02 14:02:04
      676       5        2     8.800000 2030-02-02 14:02:06 2030-02-02 14:02:15
      677       8        4    15.500000 2030-02-02 14:02:16 2030-02-02 14:02:31
      678       3        2     6.300000 2030-02-02 14:02:33 2030-02-02 14:02:39
      679       3        2     3.931573 2030-02-02 14:03:58 2030-02-02 14:04:02
      680       1        0     0.000000 2030-02-02 14:04:05 2030-02-02 14:04:05
      681       1        1     0.000000 2030-02-02 14:04:06 2030-02-02 14:04:06
      682       2        1     1.762615 2030-02-02 14:04:08 2030-02-02 14:04:10
      683       1        0     0.000000 2030-02-02 14:04:13 2030-02-02 14:04:13
      684       1        1     0.000000 2030-02-02 14:04:15 2030-02-02 14:04:15
      685       3        1     3.125866 2030-02-02 14:04:17 2030-02-02 14:04:20
      686       2        1     3.300000 2030-02-02 14:00:08 2030-02-02 14:00:12
      687       3        2     4.300000 2030-02-02 14:04:23 2030-02-02 14:04:27
      688       4        2     6.554116 2030-02-02 14:04:29 2030-02-02 14:04:35
      689       2        1     3.496854 2030-02-02 14:04:38 2030-02-02 14:04:41
      690       1        0     0.000000 2030-02-02 14:04:45 2030-02-02 14:04:45
      691       3        2     4.300000 2030-02-02 14:04:46 2030-02-02 14:04:50
      692       3        1     5.200000 2030-02-02 14:04:51 2030-02-02 14:04:56
      693       3        2     2.800000 2030-02-02 14:04:58 2030-02-02 14:05:01
      694       2        1     1.651119 2030-02-02 14:05:01 2030-02-02 14:05:02
      695       2        1     1.295846 2030-02-02 14:05:05 2030-02-02 14:05:06
      696       2        1     1.848299 2030-02-02 14:05:09 2030-02-02 14:05:10
      697       2        1     1.322136 2030-02-02 14:05:13 2030-02-02 14:05:14
      698       5        2     6.000000 2030-02-02 14:05:18 2030-02-02 14:05:24
      699       1        1     0.000000 2030-02-02 14:05:26 2030-02-02 14:05:26
      700       2        1     2.702145 2030-02-02 14:05:28 2030-02-02 14:05:31
      701       2        1     1.900000 2030-02-02 14:05:34 2030-02-02 14:05:35
      702       5        2     9.600000 2030-02-02 14:00:14 2030-02-02 14:00:23
      703       3        1     5.600000 2030-02-02 14:05:37 2030-02-02 14:05:43
      704       3        2     3.027706 2030-02-02 14:05:45 2030-02-02 14:05:48
      705       1        0     0.000000 2030-02-02 14:05:50 2030-02-02 14:05:50
      706       1        1     0.000000 2030-02-02 14:05:53 2030-02-02 14:05:53
      707       2        1     1.629629 2030-02-02 14:05:55 2030-02-02 14:05:57
      708       3        1     3.894083 2030-02-02 14:06:00 2030-02-02 14:06:04
      709       1        1     0.000000 2030-02-02 14:06:07 2030-02-02 14:06:07
      710       1        0     0.000000 2030-02-02 14:06:10 2030-02-02 14:06:10
      711       2        1     2.200000 2030-02-02 14:06:13 2030-02-02 14:06:16
      712       1        1     0.000000 2030-02-02 14:06:17 2030-02-02 14:06:17
      713       3        1     4.624533 2030-02-02 14:06:19 2030-02-02 14:06:23
      714       5        3     8.200000 2030-02-02 14:06:25 2030-02-02 14:06:33
      715       2        1     2.090508 2030-02-02 14:06:34 2030-02-02 14:06:36
      716       2        1     2.635558 2030-02-02 14:06:39 2030-02-02 14:06:41
      717       1        0     0.000000 2030-02-02 14:06:44 2030-02-02 14:06:44
      718       3        2     5.091355 2030-02-02 14:06:47 2030-02-02 14:06:52
      719       1        0     0.000000 2030-02-02 14:06:54 2030-02-02 14:06:54
      720       5        3     8.100000 2030-02-02 14:06:57 2030-02-02 14:07:05
      721       7        4    11.300000 2030-02-02 14:00:24 2030-02-02 14:00:35
      722       2        1     2.700000 2030-02-02 14:08:26 2030-02-02 14:08:28
      723       1        1     0.000000 2030-02-02 14:08:31 2030-02-02 14:08:31
      724       2        1     2.957451 2030-02-02 14:08:34 2030-02-02 14:08:37
      725       2        1     1.599659 2030-02-02 14:08:40 2030-02-02 14:08:42
      726       7        3    15.400000 2030-02-02 14:08:44 2030-02-02 14:08:59
      727       7        4    13.100000 2030-02-02 14:09:00 2030-02-02 14:09:13
      728       2        1     2.300000 2030-02-02 14:09:15 2030-02-02 14:09:17
      729       4        2     6.500000 2030-02-02 14:09:19 2030-02-02 14:09:25
      730       7        3    10.800000 2030-02-02 14:09:28 2030-02-02 14:09:39
      731       5        3    10.900000 2030-02-02 14:09:40 2030-02-02 14:09:51
      732       3        1     4.500000 2030-02-02 14:09:52 2030-02-02 14:09:56
      733       1        1     0.000000 2030-02-02 14:09:58 2030-02-02 14:09:58
      734       2        1     3.062090 2030-02-02 14:10:02 2030-02-02 14:10:05
      735       9        4    18.100000 2030-02-02 14:00:38 2030-02-02 14:00:56
      736       6        3    11.500000 2030-02-02 14:10:06 2030-02-02 14:10:18
      737       3        1     5.100000 2030-02-02 14:10:18 2030-02-02 14:10:23
      738       2        1     2.500000 2030-02-02 14:10:23 2030-02-02 14:10:26
      739       1        1     0.000000 2030-02-02 14:10:28 2030-02-02 14:10:28
      740       2        1     2.349558 2030-02-02 14:10:32 2030-02-02 14:10:34
      741       1        0     0.000000 2030-02-02 14:10:37 2030-02-02 14:10:37
      742       5        3     8.600000 2030-02-02 14:10:40 2030-02-02 14:10:49
      743       7        3    14.000000 2030-02-02 14:10:50 2030-02-02 14:11:04
      744       1        1     0.000000 2030-02-02 14:11:07 2030-02-02 14:11:07
      745       1        0     0.000000 2030-02-02 14:11:10 2030-02-02 14:11:10
      746       2        1     1.900000 2030-02-02 14:11:13 2030-02-02 14:11:15
      747       4        2     7.400000 2030-02-02 14:11:15 2030-02-02 14:11:23
      748       1        1     0.000000 2030-02-02 14:11:24 2030-02-02 14:11:24
      749       8        4    13.612740 2030-02-02 14:11:28 2030-02-02 14:11:42
      750       2        1     3.900000 2030-02-02 14:00:58 2030-02-02 14:01:02
      751       5        2    10.000000 2030-02-02 14:11:43 2030-02-02 14:11:53
      752       3        2     5.500000 2030-02-02 14:11:54 2030-02-02 14:11:59
      753       2        1     3.800000 2030-02-02 14:12:00 2030-02-02 14:12:04
      754       3        1     6.200000 2030-02-02 14:12:06 2030-02-02 14:12:13
      755       2        1     3.200000 2030-02-02 14:12:14 2030-02-02 14:12:17
      756       5        3     8.800000 2030-02-02 14:12:18 2030-02-02 14:12:27
      757       2        1     3.000000 2030-02-02 14:12:28 2030-02-02 14:12:31
      758       2        1     3.900000 2030-02-02 14:12:33 2030-02-02 14:12:37
      759       3        1     6.400000 2030-02-02 14:12:39 2030-02-02 14:12:46
      760      10        5    18.300000 2030-02-02 14:12:47 2030-02-02 14:13:06
      761       5        3    10.300000 2030-02-02 14:01:05 2030-02-02 14:01:15
      762       3        2     6.000000 2030-02-02 14:13:08 2030-02-02 14:13:14
      763       1        1     0.300000 2030-02-02 14:14:01 2030-02-02 14:14:02
      764       5        2     9.100000 2030-02-02 14:14:04 2030-02-02 14:14:13
      765       3        2     5.000000 2030-02-02 14:14:15 2030-02-02 14:14:20
      766       2        1     1.320247 2030-02-02 14:14:22 2030-02-02 14:14:24
      767       3        1     4.811336 2030-02-02 14:14:27 2030-02-02 14:14:32
      768       1        1     0.000000 2030-02-02 14:14:35 2030-02-02 14:14:35
      769       4        2     7.799438 2030-02-02 14:14:38 2030-02-02 14:14:46
      770       3        1     3.700000 2030-02-02 14:14:48 2030-02-02 14:14:51
      771       2        1     3.300000 2030-02-02 14:14:54 2030-02-02 14:14:57
      772       4        2     7.500000 2030-02-02 14:14:58 2030-02-02 14:15:06
      773       3        2     6.100000 2030-02-02 14:15:09 2030-02-02 14:15:15
      774       6        3    10.600000 2030-02-02 14:01:17 2030-02-02 14:01:27
      775       2        1     2.500000 2030-02-02 14:15:17 2030-02-02 14:15:20
      776       2        1     2.203844 2030-02-02 14:15:21 2030-02-02 14:15:23
      777       3        1     2.814854 2030-02-02 14:15:26 2030-02-02 14:15:29
      778       5        3    10.000000 2030-02-02 14:15:32 2030-02-02 14:15:42
      779       2        1     2.833405 2030-02-02 14:15:44 2030-02-02 14:15:47
      780       2        1     3.440753 2030-02-02 14:15:50 2030-02-02 14:15:53
      781       1        0     0.000000 2030-02-02 14:15:57 2030-02-02 14:15:57
      782       6        3    11.900000 2030-02-02 14:15:59 2030-02-02 14:16:11
      783       4        2     7.500000 2030-02-02 14:16:11 2030-02-02 14:16:18
      784       1        1     0.000000 2030-02-02 14:16:20 2030-02-02 14:16:20
      785       4        2     9.231564 2030-02-02 14:16:23 2030-02-02 14:16:32
      786       5        2     9.200000 2030-02-02 14:16:33 2030-02-02 14:16:43
      787       4        2     5.400000 2030-02-02 14:16:44 2030-02-02 14:16:50
      788       4        2     7.500000 2030-02-02 14:16:51 2030-02-02 14:16:59
      789       2        1     2.900000 2030-02-02 14:01:28 2030-02-02 14:01:31
      790       4        2     5.900000 2030-02-02 14:16:59 2030-02-02 14:17:05
      791       6        3    11.400000 2030-02-02 14:17:06 2030-02-02 14:17:17
      792       2        1     3.500000 2030-02-02 14:17:19 2030-02-02 14:17:23
      793       1        1     0.000000 2030-02-02 14:17:24 2030-02-02 14:17:24
      794       1        0     0.000000 2030-02-02 14:17:28 2030-02-02 14:17:28
      795       5        3     8.400000 2030-02-02 14:17:31 2030-02-02 14:17:39
      796       6        3     8.900000 2030-02-02 14:17:40 2030-02-02 14:17:49
      797       4        2     8.300000 2030-02-02 14:17:50 2030-02-02 14:17:58
      798       2        1     1.800000 2030-02-02 14:18:59 2030-02-02 14:19:00
      799       1        1     0.000000 2030-02-02 14:19:02 2030-02-02 14:19:02
      800       2        1     1.667876 2030-02-02 14:19:06 2030-02-02 14:19:07
      801       1        0     0.000000 2030-02-02 14:19:10 2030-02-02 14:19:10
      802       1        1     0.000000 2030-02-02 14:19:13 2030-02-02 14:19:13
      803       4        2     4.711243 2030-02-02 14:19:16 2030-02-02 14:19:21
      804       1        0     0.000000 2030-02-02 14:19:24 2030-02-02 14:19:24
      805       5        3     8.500000 2030-02-09 09:00:00 2030-02-09 09:00:08
      806       5        3     9.400000 2030-02-09 09:01:44 2030-02-09 09:01:53
      807       4        2     4.700000 2030-02-09 09:21:26 2030-02-09 09:21:30
      808       2        1     2.629100 2030-02-09 09:21:33 2030-02-09 09:21:35
      809       3        1     5.200365 2030-02-09 09:21:38 2030-02-09 09:21:44
      810       1        1     0.000000 2030-02-09 09:21:47 2030-02-09 09:21:47
      811       1        0     0.000000 2030-02-09 09:21:49 2030-02-09 09:21:49
      812       1        1     0.000000 2030-02-09 09:21:51 2030-02-09 09:21:51
      813       1        0     0.000000 2030-02-09 09:21:54 2030-02-09 09:21:54
      814       1        1     0.000000 2030-02-09 09:21:56 2030-02-09 09:21:56
      815       1        0     0.000000 2030-02-09 09:21:59 2030-02-09 09:21:59
      816       1        1     0.000000 2030-02-09 09:22:02 2030-02-09 09:22:02
      817       3        1     4.482484 2030-02-09 09:22:05 2030-02-09 09:22:09
      818       1        1     0.000000 2030-02-09 09:22:12 2030-02-09 09:22:12
      819       2        1     3.370131 2030-02-09 09:22:14 2030-02-09 09:22:17
      820       4        2     5.379113 2030-02-09 09:22:20 2030-02-09 09:22:26
      821       5        2     7.600000 2030-02-09 09:22:29 2030-02-09 09:22:36
      822       3        1     5.100000 2030-02-09 09:01:55 2030-02-09 09:02:00
      823       7        4    13.700000 2030-02-09 09:02:00 2030-02-09 09:02:14
      824       5        2     8.300000 2030-02-09 09:02:15 2030-02-09 09:02:24
      825       8        4    14.900000 2030-02-09 09:02:25 2030-02-09 09:02:40
      826       2        1     3.300000 2030-02-09 09:02:41 2030-02-09 09:02:44
      827       3        2     5.700000 2030-02-09 09:02:45 2030-02-09 09:02:50
      828       2        1     3.900000 2030-02-09 09:02:53 2030-02-09 09:02:57
      829       1        1     0.500000 2030-02-09 09:04:11 2030-02-09 09:04:11
      830       2        1     2.645939 2030-02-09 09:04:13 2030-02-09 09:04:15
      831       2        1     3.137116 2030-02-09 09:04:18 2030-02-09 09:04:21
      832       2        1     1.259329 2030-02-09 09:04:24 2030-02-09 09:04:25
      833       1        0     0.000000 2030-02-09 09:04:28 2030-02-09 09:04:28
      834       3        1     5.000000 2030-02-09 09:00:10 2030-02-09 09:00:15
      835       1        1     0.000000 2030-02-09 09:04:30 2030-02-09 09:04:30
      836       2        1     1.846103 2030-02-09 09:04:33 2030-02-09 09:04:35
      837       1        0     0.000000 2030-02-09 09:04:37 2030-02-09 09:04:37
      838       1        1     0.000000 2030-02-09 09:04:40 2030-02-09 09:04:40
      839       1        0     0.000000 2030-02-09 09:04:43 2030-02-09 09:04:43
      840       1        1     0.000000 2030-02-09 09:04:44 2030-02-09 09:04:44
      841       2        1     1.452163 2030-02-09 09:04:47 2030-02-09 09:04:48
      842       2        1     2.643573 2030-02-09 09:04:50 2030-02-09 09:04:53
      843       1        0     0.000000 2030-02-09 09:04:55 2030-02-09 09:04:55
      844       1        1     0.000000 2030-02-09 09:04:57 2030-02-09 09:04:57
      845       4        2     5.280738 2030-02-09 09:05:00 2030-02-09 09:05:05
      846       2        1     1.102731 2030-02-09 09:05:08 2030-02-09 09:05:09
      847       4        2     5.236358 2030-02-09 09:05:12 2030-02-09 09:05:17
      848       2        1     1.404465 2030-02-09 09:05:20 2030-02-09 09:05:22
      849       2        1     1.909155 2030-02-09 09:05:25 2030-02-09 09:05:27
      850       1        0     0.000000 2030-02-09 09:05:29 2030-02-09 09:05:29
      851       1        1     0.000000 2030-02-09 09:05:32 2030-02-09 09:05:32
      852       6        3    10.759091 2030-02-09 09:05:35 2030-02-09 09:05:46
      853       2        1     2.122969 2030-02-09 09:05:48 2030-02-09 09:05:50
      854       2        1     1.740249 2030-02-09 09:05:53 2030-02-09 09:05:54
      855       1        0     0.000000 2030-02-09 09:05:57 2030-02-09 09:05:57
      856       1        1     0.000000 2030-02-09 09:05:59 2030-02-09 09:05:59
      857       2        1     2.698250 2030-02-09 09:06:02 2030-02-09 09:06:05
      858       2        1     2.931502 2030-02-09 09:06:06 2030-02-09 09:06:09
      859       1        0     0.000000 2030-02-09 09:06:11 2030-02-09 09:06:11
      860       5        3    11.100000 2030-02-09 09:00:16 2030-02-09 09:00:27
      861       1        1     0.000000 2030-02-09 09:06:14 2030-02-09 09:06:14
      862       4        2     5.650673 2030-02-09 09:06:17 2030-02-09 09:06:22
      863       2        1     3.303230 2030-02-09 09:06:24 2030-02-09 09:06:28
      864       2        1     2.941113 2030-02-09 09:06:31 2030-02-09 09:06:34
      865       3        1     3.216690 2030-02-09 09:06:37 2030-02-09 09:06:40
      866       3        2     4.392993 2030-02-09 09:06:43 2030-02-09 09:06:47
      867       1        0     0.000000 2030-02-09 09:06:50 2030-02-09 09:06:50
      868       1        1     0.000000 2030-02-09 09:06:52 2030-02-09 09:06:52
      869       1        0     0.000000 2030-02-09 09:06:54 2030-02-09 09:06:54
      870       1        1     0.000000 2030-02-09 09:06:56 2030-02-09 09:06:56
      871       1        0     0.000000 2030-02-09 09:06:59 2030-02-09 09:06:59
      872       1        1     0.000000 2030-02-09 09:07:02 2030-02-09 09:07:02
      873       2        1     3.395570 2030-02-09 09:07:05 2030-02-09 09:07:08
      874       2        1     1.128194 2030-02-09 09:07:10 2030-02-09 09:07:11
      875       2        1     1.328106 2030-02-09 09:07:15 2030-02-09 09:07:16
      876       2        1     3.428358 2030-02-09 09:07:19 2030-02-09 09:07:22
      877       2        1     2.414083 2030-02-09 09:07:25 2030-02-09 09:07:27
      878       6        3    12.600000 2030-02-09 09:07:30 2030-02-09 09:07:43
      879       2        1     1.017270 2030-02-09 09:07:44 2030-02-09 09:07:45
      880       2        1     2.354024 2030-02-09 09:07:48 2030-02-09 09:07:50
      881       2        1     2.566914 2030-02-09 09:07:53 2030-02-09 09:07:56
      882       1        0     0.000000 2030-02-09 09:07:59 2030-02-09 09:07:59
      883       1        1     0.000000 2030-02-09 09:08:02 2030-02-09 09:08:02
      884       4        2     5.299435 2030-02-09 09:08:04 2030-02-09 09:08:09
      885       2        1     4.100000 2030-02-09 09:00:27 2030-02-09 09:00:31
      886       2        1     3.004417 2030-02-09 09:08:13 2030-02-09 09:08:16
      887       1        0     0.000000 2030-02-09 09:08:19 2030-02-09 09:08:19
      888       1        1     0.500000 2030-02-09 09:09:40 2030-02-09 09:09:41
      889       5        2     9.500000 2030-02-09 09:09:42 2030-02-09 09:09:52
      890       2        1     1.800000 2030-02-09 09:09:53 2030-02-09 09:09:54
      891       1        1     0.000000 2030-02-09 09:09:55 2030-02-09 09:09:55
      892       2        1     3.371938 2030-02-09 09:09:58 2030-02-09 09:10:02
      893       2        1     3.393739 2030-02-09 09:10:04 2030-02-09 09:10:07
      894       3        1     4.085392 2030-02-09 09:10:11 2030-02-09 09:10:15
      895       2        1     3.100000 2030-02-09 09:10:18 2030-02-09 09:10:21
      896       4        2     6.000000 2030-02-09 09:10:24 2030-02-09 09:10:30
      897       1        1     0.000000 2030-02-09 09:10:31 2030-02-09 09:10:31
      898       5        2     9.504447 2030-02-09 09:10:34 2030-02-09 09:10:44
      899       1        1     0.000000 2030-02-09 09:10:47 2030-02-09 09:10:47
      900       1        0     0.000000 2030-02-09 09:10:50 2030-02-09 09:10:50
      901       5        2     9.700000 2030-02-09 09:00:33 2030-02-09 09:00:43
      902       5        3     9.700000 2030-02-09 09:10:53 2030-02-09 09:11:03
      903       2        1     2.478796 2030-02-09 09:11:05 2030-02-09 09:11:08
      904       3        1     4.572445 2030-02-09 09:11:11 2030-02-09 09:11:16
      905       3        2     6.600000 2030-02-09 09:11:17 2030-02-09 09:11:23
      906       2        1     1.966287 2030-02-09 09:11:24 2030-02-09 09:11:26
      907       2        1     2.824788 2030-02-09 09:11:29 2030-02-09 09:11:32
      908       1        0     0.000000 2030-02-09 09:11:35 2030-02-09 09:11:35
      909       2        1     1.800000 2030-02-09 09:11:39 2030-02-09 09:11:41
      910       1        1     0.000000 2030-02-09 09:11:41 2030-02-09 09:11:41
      911       1        0     0.000000 2030-02-09 09:11:45 2030-02-09 09:11:45
      912       3        2     2.668557 2030-02-09 09:11:47 2030-02-09 09:11:50
      913       4        2     5.217882 2030-02-09 09:11:53 2030-02-09 09:11:58
      914       5        2     9.700000 2030-02-09 09:12:00 2030-02-09 09:12:10
      915       3        2     4.000000 2030-02-09 09:12:11 2030-02-09 09:12:15
      916       6        3    10.700000 2030-02-09 09:12:16 2030-02-09 09:12:27
      917       8        4    16.000000 2030-02-09 09:00:45 2030-02-09 09:01:01
      918       4        2     6.300000 2030-02-09 09:12:29 2030-02-09 09:12:36
      919       6        3    11.600000 2030-02-09 09:12:37 2030-02-09 09:12:48
      920       4        2     7.100000 2030-02-09 09:12:49 2030-02-09 09:12:56
      921       4        2     7.700000 2030-02-09 09:12:58 2030-02-09 09:13:05
      922       3        1     5.500000 2030-02-09 09:13:07 2030-02-09 09:13:12
      923       3        2     4.200608 2030-02-09 09:13:13 2030-02-09 09:13:17
      924       1        0     0.000000 2030-02-09 09:13:20 2030-02-09 09:13:20
      925       5        3     9.700000 2030-02-09 09:13:21 2030-02-09 09:13:31
      926       4        2     9.700000 2030-02-09 09:13:33 2030-02-09 09:13:42
      927       1        0     0.600000 2030-02-09 09:13:44 2030-02-09 09:13:44
      928       3        2     4.600000 2030-02-09 09:15:07 2030-02-09 09:15:12
      929       6        3    13.500000 2030-02-09 09:01:03 2030-02-09 09:01:16
      930       2        1     1.500000 2030-02-09 09:15:15 2030-02-09 09:15:16
      931       4        2     9.500000 2030-02-09 09:15:19 2030-02-09 09:15:28
      932       6        3    11.200000 2030-02-09 09:15:28 2030-02-09 09:15:39
      933       6        3    12.800000 2030-02-09 09:15:41 2030-02-09 09:15:53
      934       2        1     2.500000 2030-02-09 09:15:56 2030-02-09 09:15:58
      935       4        2     7.700000 2030-02-09 09:15:59 2030-02-09 09:16:06
      936       5        2     9.400000 2030-02-09 09:16:09 2030-02-09 09:16:19
      937       3        2     4.800000 2030-02-09 09:16:21 2030-02-09 09:16:26
      938       8        4    17.100000 2030-02-09 09:16:28 2030-02-09 09:16:45
      939       5        2     8.800000 2030-02-09 09:16:46 2030-02-09 09:16:55
      940       6        3     8.800000 2030-02-09 09:01:19 2030-02-09 09:01:27
      941       7        4    13.100000 2030-02-09 09:16:58 2030-02-09 09:17:11
      942       2        1     2.000000 2030-02-09 09:17:13 2030-02-09 09:17:15
      943       2        1     2.600000 2030-02-09 09:17:17 2030-02-09 09:17:19
      944       5        2     8.700000 2030-02-09 09:17:21 2030-02-09 09:17:29
      945       6        3    10.600000 2030-02-09 09:17:32 2030-02-09 09:17:42
      946       5        3     8.700000 2030-02-09 09:17:44 2030-02-09 09:17:53
      947       3        1     5.100000 2030-02-09 09:17:54 2030-02-09 09:17:59
      948       6        3    10.600000 2030-02-09 09:18:00 2030-02-09 09:18:11
      949       1        1     0.000000 2030-02-09 09:18:13 2030-02-09 09:18:13
      950       4        2     8.897214 2030-02-09 09:18:16 2030-02-09 09:18:25
      951       5        2     7.900000 2030-02-09 09:18:27 2030-02-09 09:18:35
      952       8        4    14.000000 2030-02-09 09:01:29 2030-02-09 09:01:43
      953       1        1     0.000000 2030-02-09 09:18:35 2030-02-09 09:18:35
      954       3        1     3.209775 2030-02-09 09:18:38 2030-02-09 09:18:41
      955       4        2     6.900000 2030-02-09 09:19:55 2030-02-09 09:20:02
      956       3        2     4.442260 2030-02-09 09:20:03 2030-02-09 09:20:07
      957       2        1     3.462575 2030-02-09 09:20:10 2030-02-09 09:20:14
      958       1        0     0.000000 2030-02-09 09:20:17 2030-02-09 09:20:17
      959       1        1     0.000000 2030-02-09 09:20:19 2030-02-09 09:20:19
      960       2        1     1.787270 2030-02-09 09:20:21 2030-02-09 09:20:23
      961       1        0     0.000000 2030-02-09 09:20:26 2030-02-09 09:20:26
      962       3        2     2.688341 2030-02-09 09:20:27 2030-02-09 09:20:30
      963       2        1     2.698548 2030-02-09 09:20:33 2030-02-09 09:20:36
      964       2        1     2.833231 2030-02-09 09:20:38 2030-02-09 09:20:41
      965       2        1     2.505919 2030-02-09 09:20:44 2030-02-09 09:20:47
      966       3        1     3.409885 2030-02-09 09:20:50 2030-02-09 09:20:54
      967       1        1     0.000000 2030-02-09 09:20:55 2030-02-09 09:20:55
      968       4        2     3.878423 2030-02-09 09:20:58 2030-02-09 09:21:02
      969       2        1     4.400000 2030-02-09 09:21:04 2030-02-09 09:21:08
      970       2        1     1.708051 2030-02-09 09:21:09 2030-02-09 09:21:11
      971       2        1     1.205146 2030-02-09 09:21:13 2030-02-09 09:21:14
      972       2        1     2.601337 2030-02-09 09:21:15 2030-02-09 09:21:18
      973       2        1     3.184449 2030-02-09 09:21:21 2030-02-09 09:21:25
          speed_kmh
      1    41.36014
      2    45.11528
      3    61.47694
      4    87.87018
      5    64.85656
      6    57.77545
      7    68.55805
      8          NA
      9    77.89225
      10   83.52495
      11   64.69563
      12   71.29394
      13   74.67356
      14   88.03112
      15   85.45617
      16   74.19076
      17   58.90199
      18   73.78842
      19   64.85656
      20         NA
      21   40.12631
      22   84.41009
      23         NA
      24   82.72028
      25   85.77804
      26   68.79946
      27   71.93768
      28   56.48797
      29   83.84682
      30   71.13300
      31   62.28161
      32         NA
      33   44.68612
      34   44.47154
      35   36.69304
      36   33.39389
      37   47.79752
      38   49.24593
      39   81.91561
      40   61.47694
      41   59.94806
      42   40.47500
      43   69.52366
      44   66.94871
      45   70.65020
      46   78.37505
      47   74.02982
      48         NA
      49   81.75468
      50   80.14533
      51         NA
      52   66.22451
      53         NA
      54   66.30497
      55   59.70666
      56   83.20308
      57   82.55935
      58         NA
      59   83.76636
      60   57.29265
      61   82.88122
      62   76.12197
      63   58.09732
      64   76.28291
      65   76.60477
      66   43.17065
      67   66.30497
      68   61.31601
      69   78.37505
      70   69.68460
      71         NA
      72   76.28291
      73   66.46591
      74   57.93638
      75   76.68524
      76   68.23619
      77   76.60477
      78   76.20244
      79         NA
      80   82.88122
      81   56.32704
      82         NA
      83   60.67227
      84   78.37505
      85   84.97336
      86   63.89096
      87   69.84553
      88   60.51133
      89   77.08758
      90   78.53599
      91   41.76248
      92   68.71899
      93         NA
      94   74.19076
      95   79.98440
      96   86.58271
      97   63.73002
      98         NA
      99   75.80010
      100  91.24980
      101  81.59374
      102  84.65149
      103  90.55242
      104  70.97207
      105        NA
      106  82.23748
      107  43.45229
      108  77.08758
      109  80.70860
      110  91.24980
      111  69.52366
      112  95.59503
      113  84.65149
      114  64.37376
      115  75.07590
      116  87.46785
      117  82.55935
      118  88.03112
      119  85.45617
      120  81.27187
      121  36.85398
      122  94.30756
      123  99.29652
      124  93.18102
      125        NA
      126  88.59439
      127  99.45746
      128  90.44513
      129  82.72028
      130  67.43151
      131  87.49467
      132  67.27058
      133  90.12326
      134  92.00083
      135  79.98440
      136  74.67356
      137  41.36014
      138  85.93897
      139  66.30497
      140  77.40945
      141  75.96104
      142  76.49748
      143  73.30562
      144  79.01879
      145  76.76571
      146  76.84618
      147  81.27187
      148  63.73002
      149  84.81243
      150  90.92794
      151        NA
      152  62.76442
      153  81.75468
      154  43.77416
      155  72.82282
      156  74.99543
      157  82.55935
      158  79.17972
      159  70.89160
      160  89.47953
      161  83.76636
      162  78.05318
      163  72.90328
      164  76.60477
      165  79.42113
      166        NA
      167  79.82346
      168  41.84294
      169  72.25955
      170  79.01879
      171  68.71899
      172  84.81243
      173  70.32833
      174  83.76636
      175  88.03112
      176  67.02918
      177  65.50030
      178  70.65020
      179  61.31601
      180  84.41009
      181  70.65020
      182  75.15636
      183  84.16869
      184        NA
      185  85.08065
      186  42.96948
      187  41.09192
      188  72.25955
      189  62.92535
      190  57.61452
      191  62.92535
      192  57.45358
      193  69.20179
      194        NA
      195  68.23619
      196  68.07525
      197  60.18947
      198  71.29394
      199  70.16740
      200  58.25825
      201        NA
      202  42.00388
      203  40.79687
      204  41.89659
      205  42.64762
      206  45.30303
      207        NA
      208  83.04215
      209  75.47823
      210  61.31601
      211  56.64891
      212  67.59245
      213  42.88902
      214  74.75403
      215        NA
      216  87.38738
      217  58.58012
      218  85.45617
      219  84.81243
      220  76.92664
      221  70.32833
      222  79.01879
      223  61.47694
      224  86.74364
      225  78.80421
      226  70.97207
      227        NA
      228  82.72028
      229  84.97336
      230  68.71899
      231  64.37376
      232  69.52366
      233  45.38350
      234  87.54831
      235  79.34066
      236  85.13430
      237  63.24722
      238        NA
      239  81.27187
      240  84.32963
      241  72.90328
      242  58.25825
      243  59.54573
      244  81.43281
      245        NA
      246  59.86760
      247  63.89096
      248  72.58141
      249  62.12068
      250  81.75468
      251        NA
      252  80.52084
      253  76.76571
      254  44.57883
      255  79.76982
      256        NA
      257  71.85721
      258  95.43410
      259  81.91561
      260  88.99672
      261  77.08758
      262  72.42048
      263  73.22515
      264  76.04150
      265  99.29652
      266  77.57038
      267  88.51392
      268  84.08822
      269  43.77416
      270  82.23748
      271  84.73196
      272  92.21541
      273  84.89290
      274  68.39712
      275  82.55935
      276  73.86889
      277  70.16740
      278  81.43281
      279  89.10401
      280        NA
      281  86.74364
      282  69.68460
      283  74.43216
      284  91.08887
      285  65.82217
      286  34.84230
      287  84.49056
      288  65.66124
      289  85.37570
      290  84.65149
      291  72.58141
      292  82.47888
      293  93.02008
      294  72.17908
      295  90.60607
      296  64.21283
      297  66.14404
      298  84.32963
      299  37.65865
      300  63.24722
      301  77.24851
      302  83.04215
      303  84.00776
      304  76.28291
      305  82.72028
      306  74.91496
      307  78.69692
      308  75.63917
      309  70.81114
      310  81.91561
      311  91.89354
      312  71.13300
      313  43.29135
      314  93.02008
      315        NA
      316  67.59245
      317  79.98440
      318  83.60542
      319  74.02982
      320  65.82217
      321  80.78907
      322  82.68005
      323  91.41074
      324  82.82757
      325  85.61710
      326  92.21541
      327  84.00776
      328  88.83579
      329        NA
      330  33.47436
      331  71.45487
      332  60.67227
      333  83.04215
      334  77.08758
      335  65.33937
      336        NA
      337  78.69692
      338  57.29265
      339        NA
      340  70.48927
      341  66.30497
      342        NA
      343  69.20179
      344        NA
      345  76.36337
      346  80.62813
      347        NA
      348  59.54573
      349        NA
      350  65.50030
      351  84.97336
      352        NA
      353  45.50420
      354  40.23360
      355  82.07654
      356  86.26084
      357        NA
      358  67.59245
      359  81.91561
      360        NA
      361  77.40945
      362  82.72028
      363  84.65149
      364  59.86760
      365  81.27187
      366  44.09603
      367  42.00388
      368  43.37182
      369  48.03892
      370  47.47565
      371  44.20332
      372  42.80855
      373  48.54854
      374  37.90005
      375  46.51004
      376  38.62426
      377  61.47694
      378  67.43151
      379  75.80010
      380  85.29523
      381  80.46720
      382  60.67227
      383  88.19205
      384  61.47694
      385  62.76442
      386  59.86760
      387  83.20308
      388        NA
      389  72.17908
      390  58.58012
      391  72.58141
      392  81.11094
      393  60.51133
      394  84.65149
      395  81.43281
      396  86.42177
      397  65.33937
      398  44.68612
      399  75.96104
      400  78.53599
      401  84.49056
      402  79.50159
      403        NA
      404  77.78496
      405  65.98310
      406  77.16804
      407  58.74106
      408  61.31601
      409  77.57038
      410        NA
      411  74.19076
      412  84.00776
      413  72.09861
      414  78.21412
      415  78.77739
      416  45.86630
      417  70.16740
      418  96.23877
      419  82.18383
      420  87.22644
      421        NA
      422  73.14468
      423  88.88943
      424  77.73132
      425  84.38327
      426  80.30627
      427  90.12326
      428  76.28291
      429  81.75468
      430        NA
      431  42.80855
      432  83.92729
      433  71.05254
      434  85.45617
      435  67.75338
      436  90.76700
      437  68.02161
      438  74.67356
      439  69.76506
      440  80.54767
      441  86.09990
      442  80.46720
      443  76.12197
      444  41.03827
      445  88.62121
      446  98.16998
      447  87.38738
      448  71.61581
      449        NA
      450  76.72548
      451  72.09861
      452  72.50095
      453  77.24851
      454  69.09450
      455  79.09926
      456  37.65865
      457  79.26019
      458  81.03047
      459  92.69821
      460  71.69628
      461  74.61992
      462  84.32963
      463  66.78778
      464  71.45487
      465  63.24722
      466  86.74364
      467  84.81243
      468  76.20244
      469        NA
      470  41.19921
      471  83.60542
      472  78.45552
      473  79.58206
      474  65.33937
      475  64.69563
      476  62.44255
      477  80.78907
      478  81.11094
      479  69.36273
      480  67.19011
      481  78.53599
      482  68.55805
      483  73.06422
      484  74.67356
      485  68.96039
      486  45.54444
      487  64.13236
      488        NA
      489  84.65149
      490  88.35299
      491  73.30562
      492  63.24722
      493  79.34066
      494  83.68589
      495  84.81243
      496  69.52366
      497  74.35169
      498  69.36273
      499  81.75468
      500  75.15636
      501  73.30562
      502        NA
      503  76.65842
      504  58.49965
      505  48.03892
      506  48.97770
      507  35.48604
      508  41.14556
      509  38.70472
      510  37.33678
      511  37.65865
      512  72.68870
      513  81.27187
      514  84.65149
      515        NA
      516  80.78907
      517  76.28291
      518  36.85398
      519  74.99543
      520  80.22580
      521  74.83450
      522  73.70796
      523  77.89225
      524  77.40945
      525  58.90199
      526  61.47694
      527  74.99543
      528        NA
      529  83.52495
      530  59.70666
      531  72.09861
      532  64.69563
      533  86.26084
      534  77.89225
      535  35.24463
      536  76.04150
      537  84.65149
      538  61.15507
      539  64.37376
      540  72.25955
      541  56.80984
      542  71.29394
      543  68.07525
      544        NA
      545  72.90328
      546  68.07525
      547  73.86889
      548        NA
      549  66.94871
      550        NA
      551  80.06486
      552  70.65020
      553  80.62813
      554  39.58986
      555  66.14404
      556        NA
      557  75.15636
      558  82.47888
      559  95.11223
      560  74.67356
      561  77.48991
      562  69.12132
      563  84.49056
      564  71.13300
      565  92.45681
      566  85.45617
      567  89.15766
      568        NA
      569  40.79687
      570  93.58335
      571  92.69821
      572  83.60542
      573  82.98851
      574  77.81178
      575  83.04215
      576        NA
      577  81.99608
      578  82.23748
      579  66.30497
      580  86.04626
      581  88.67485
      582  73.06422
      583  94.79036
      584  95.59503
      585  83.04215
      586  45.94677
      587  79.90393
      588  73.66772
      589  82.39841
      590  73.86889
      591  62.92535
      592  77.89225
      593        NA
      594  81.67421
      595  83.04215
      596  84.97336
      597  69.68460
      598  70.48927
      599  87.54831
      600  77.08758
      601  33.63529
      602  81.70103
      603  63.08628
      604  79.50159
      605  86.74364
      606  62.44255
      607  71.61581
      608  76.28291
      609  72.42048
      610        NA
      611  71.45487
      612  79.39430
      613  81.75468
      614  83.28355
      615  42.37939
      616  65.33937
      617  72.25955
      618  59.22386
      619  75.71964
      620  67.75338
      621        NA
      622  76.92664
      623  67.10964
      624  72.50095
      625  73.86889
      626  82.88122
      627        NA
      628  61.31601
      629        NA
      630  68.87992
      631  67.75338
      632        NA
      633  80.14533
      634  73.22515
      635  59.54573
      636  40.07267
      637  60.35040
      638  86.26084
      639  61.31601
      640  67.43151
      641        NA
      642  74.67356
      643  81.27187
      644  82.55935
      645  57.13171
      646  77.40945
      647        NA
      648  57.45358
      649        NA
      650  65.33937
      651  44.79341
      652  44.73976
      653  80.62813
      654  83.20308
      655        NA
      656  60.51133
      657  82.72028
      658  60.83320
      659  80.46720
      660        NA
      661  85.37570
      662  66.94871
      663  77.24851
      664  74.02982
      665  61.31601
      666  72.42048
      667  56.64891
      668  71.77674
      669  78.21412
      670  68.02161
      671  68.71899
      672  45.58467
      673  70.97207
      674  44.25696
      675  37.81958
      676  44.73976
      677  45.86630
      678  41.11874
      679  58.66059
      680        NA
      681  70.48927
      682  56.80984
      683        NA
      684  77.57038
      685  65.01750
      686  39.10706
      687  62.60348
      688  76.36337
      689  82.88122
      690        NA
      691  76.76571
      692  87.06551
      693  69.36273
      694  65.66124
      695  56.48797
      696  73.86889
      697  67.43151
      698  61.07460
      699  81.43281
      700  70.16740
      701  59.54573
      702  44.17649
      703  75.96104
      704  70.00646
      705        NA
      706  74.19076
      707  86.58271
      708  67.59245
      709  80.46720
      710        NA
      711  84.49056
      712  69.52366
      713  81.27187
      714  76.81935
      715  61.63788
      716  84.00776
      717        NA
      718  66.46591
      719        NA
      720  77.73132
      721  43.93509
      722  79.82346
      723  77.89225
      724  89.47953
      725  77.89225
      726  71.13300
      727  88.03112
      728  70.48927
      729  67.10964
      730  70.91843
      731  88.24570
      732  79.98440
      733  81.43281
      734  89.15766
      735  41.92341
      736  77.19487
      737  69.36273
      738  67.91432
      739  91.08887
      740  72.09861
      741        NA
      742  84.81243
      743  80.89636
      744  76.60477
      745        NA
      746  78.53599
      747  81.83514
      748  74.19076
      749  80.18556
      750  44.73976
      751  83.04215
      752  88.83579
      753  98.97466
      754  98.81372
      755  75.15636
      756  78.32141
      757  79.50159
      758  66.14404
      759  75.15636
      760  85.48835
      761  44.63247
      762  91.00840
      763  75.47823
      764  78.45552
      765  77.40945
      766  78.69692
      767  88.99672
      768  64.21283
      769  77.24851
      770  83.36402
      771  76.76571
      772  69.60413
      773  81.35234
      774  44.57883
      775  67.10964
      776  74.02982
      777  89.64046
      778  71.93768
      779  77.73132
      780  78.37505
      781        NA
      782  72.31319
      783  76.84618
      784  69.04086
      785  80.95000
      786  79.74300
      787  86.50224
      788  78.45552
      789  34.76183
      790  84.24916
      791  70.38198
      792  69.20179
      793  76.44384
      794        NA
      795  66.94871
      796  74.67356
      797  80.14533
      798  77.08758
      799  59.06292
      800  85.29523
      801        NA
      802  70.97207
      803  67.51198
      804        NA
      805  45.54444
      806  47.58294
      807  69.20179
      808  58.25825
      809  68.55805
      810  76.28291
      811        NA
      812  84.97336
      813        NA
      814  78.21412
      815        NA
      816  66.78778
      817  56.97078
      818  85.61710
      819  57.93638
      820  74.75403
      821  80.54767
      822  41.03827
      823  41.56131
      824  41.76248
      825  39.54963
      826  34.27903
      827  40.79687
      828  45.86630
      829  65.17843
      830  63.08628
      831  69.84553
      832  58.41919
      833        NA
      834  33.63529
      835  59.38479
      836  58.58012
      837        NA
      838  85.77804
      839        NA
      840  74.51263
      841  69.68460
      842  79.82346
      843        NA
      844  68.39712
      845  67.02918
      846  71.61581
      847  70.97207
      848  75.15636
      849  58.41919
      850        NA
      851  58.09732
      852  75.96104
      853  88.19205
      854  77.89225
      855        NA
      856  80.62813
      857  83.04215
      858  68.39712
      859        NA
      860  38.57061
      861  88.35299
      862  72.01814
      863  69.68460
      864  60.35040
      865  72.25955
      866  75.07590
      867        NA
      868  56.64891
      869        NA
      870  62.12068
      871        NA
      872  75.96104
      873  65.01750
      874  75.31730
      875  74.83450
      876  59.70666
      877  73.22515
      878  63.40815
      879  86.09990
      880  81.91561
      881  58.74106
      882        NA
      883  60.99414
      884  73.06422
      885  36.85398
      886  76.92664
      887        NA
      888  91.57167
      889  80.78907
      890  90.60607
      891  92.05448
      892  98.00905
      893  70.97207
      894  98.97466
      895  78.05318
      896  85.77804
      897  86.58271
      898  90.12326
      899  98.16998
      900        NA
      901  41.36014
      902  82.55935
      903  77.73132
      904  68.87992
      905  69.84553
      906  66.94871
      907  74.02982
      908        NA
      909  91.89354
      910  96.07784
      911        NA
      912  80.30627
      913  69.44319
      914  81.91561
      915  81.59374
      916  70.91843
      917  42.32575
      918  75.55870
      919  84.65149
      920  75.47823
      921  74.19076
      922  88.51392
      923  84.81243
      924        NA
      925  82.61299
      926  79.09926
      927        NA
      928  82.31795
      929  45.22257
      930  77.73132
      931  81.27187
      932  77.51674
      933  73.06422
      934  82.23748
      935  78.13365
      936  87.87018
      937  70.65020
      938  73.94936
      939  63.89096
      940  38.46332
      941  78.77739
      942  78.37505
      943  93.02008
      944  76.68524
      945  83.47131
      946  71.66945
      947  82.23748
      948  77.99954
      949  73.38609
      950  73.46655
      951  72.98375
      952  43.29135
      953  79.66253
      954  73.06422
      955  73.30562
      956  63.16675
      957  81.43281
      958        NA
      959  81.27187
      960  72.58141
      961        NA
      962  77.00711
      963  71.93768
      964  62.44255
      965  81.43281
      966  63.40815
      967  76.28291
      968  77.16804
      969  60.83320
      970  68.55805
      971  57.45358
      972  81.75468
      973  73.86889

# segment_session_shots() on one match's shots is stable

    Code
      as.data.frame(segs)
    Output
        segment_index               regime          start_time            end_time
      1             1          mini_tennis 2030-01-05 16:00:00 2030-01-05 16:02:52
      2             2           net_volley 2030-01-05 16:03:40 2030-01-05 16:07:51
      3             3 forehand_cross_court 2030-01-05 16:09:11 2030-01-05 16:13:23
      4             4 backhand_cross_court 2030-01-05 16:14:32 2030-01-05 16:18:29
      5             5           net_volley 2030-01-05 16:19:40 2030-01-05 16:22:38
        duration_min n_shots n_host_shots n_guest_shots
      1          2.9      78           39            39
      2          4.2     107           53            54
      3          4.2     111           55            56
      4          3.9     106           53            53
      5          3.0      80           40            40

# session_effort_metrics() on the full sample dataset is stable

    Code
      as.data.frame(effort[, c("session_date", "z_distance", "z_shots", "z_speed",
        "z_pace", "effort_z")])
    Output
        session_date z_distance     z_shots    z_speed      z_pace    effort_z
      1   2030-01-05  0.2913096  1.02520531  0.8016322  0.03063756  0.53719618
      2   2030-01-12 -1.6405332  0.02384198  1.1153144  0.89988751  0.09962765
      3   2030-01-19 -0.2606455  0.09536794 -0.2439750 -0.26130749 -0.16764001
      4   2030-01-26 -0.3526380 -1.90735872  0.2788286 -1.19194638 -0.79327862
      5   2030-02-02  0.7512722  0.30994579 -0.2439750  1.39353562  0.55269466
      6   2030-02-09  1.2112348  0.45299770 -1.7078251 -0.87080682 -0.22859986

# session_standard_metrics() + session_metric_ranks() on the full sample dataset are stable

    Code
      as.data.frame(sm)
    Output
         session_date      metric            label        unit       value direction
      1    2030-01-05    accuracy  Stroke accuracy           % 83.90000000         1
      2    2030-01-12    accuracy  Stroke accuracy           % 72.80000000         1
      3    2030-01-19    accuracy  Stroke accuracy           % 72.90000000         1
      4    2030-01-26    accuracy  Stroke accuracy           % 83.10000000         1
      5    2030-02-02    accuracy  Stroke accuracy           % 81.50000000         1
      6    2030-02-09    accuracy  Stroke accuracy           % 78.20000000         1
      7    2030-01-05 stroke_rate      Stroke rate strokes/min 10.52173913         1
      8    2030-01-12 stroke_rate      Stroke rate strokes/min 10.85714286         1
      9    2030-01-19 stroke_rate      Stroke rate strokes/min 10.40909091         1
      10   2030-01-26 stroke_rate      Stroke rate strokes/min 10.05000000         1
      11   2030-02-02 stroke_rate      Stroke rate strokes/min 11.04761905         1
      12   2030-02-09 stroke_rate      Stroke rate strokes/min 10.17391304         1
      13   2030-01-05       speed     Stroke speed         mph 44.40000000         1
      14   2030-01-12       speed     Stroke speed         mph 44.55000000         1
      15   2030-01-19       speed     Stroke speed         mph 43.90000000         1
      16   2030-01-26       speed     Stroke speed         mph 44.15000000         1
      17   2030-02-02       speed     Stroke speed         mph 43.90000000         1
      18   2030-02-09       speed     Stroke speed         mph 43.20000000         1
      19   2030-01-05    run_rate   Court coverage      mi/min  0.03782609         1
      20   2030-01-12    run_rate   Court coverage      mi/min  0.02142857         1
      21   2030-01-19    run_rate   Court coverage      mi/min  0.03409091         1
      22   2030-01-26    run_rate   Court coverage      mi/min  0.03650000         1
      23   2030-02-02    run_rate   Court coverage      mi/min  0.04619048         1
      24   2030-02-09    run_rate   Court coverage      mi/min  0.04652174         1
      25   2030-01-05  shot_share Share of strokes           % 50.20746888         1
      26   2030-01-12  shot_share Share of strokes           % 50.22026432         1
      27   2030-01-19  shot_share Share of strokes           % 50.44052863         1
      28   2030-01-26  shot_share Share of strokes           % 50.37593985         1
      29   2030-02-02  shot_share Share of strokes           % 50.54466231         1
      30   2030-02-09  shot_share Share of strokes           % 50.10706638         1
      31   2030-01-05    fh_share   Forehand share           % 50.00000000        NA
      32   2030-01-12    fh_share   Forehand share           % 51.31578947        NA
      33   2030-01-19    fh_share   Forehand share           % 50.65502183        NA
      34   2030-01-26    fh_share   Forehand share           % 53.23383085        NA
      35   2030-02-02    fh_share   Forehand share           % 52.15517241        NA
      36   2030-02-09    fh_share   Forehand share           % 48.71794872        NA
         pct
      1  100
      2    0
      3   20
      4   80
      5   60
      6   40
      7   60
      8   80
      9   40
      10   0
      11 100
      12  20
      13  80
      14 100
      15  30
      16  60
      17  30
      18   0
      19  60
      20   0
      21  20
      22  40
      23  80
      24 100
      25  20
      26  40
      27  80
      28  60
      29 100
      30   0
      31  20
      32  60
      33  40
      34 100
      35  80
      36   0

---

    Code
      as.data.frame(ranks)
    Output
         session_date      metric            label pct score rank
      1    2030-01-05    accuracy  Stroke accuracy 100   100    1
      2    2030-01-05       speed     Stroke speed  80    80    2
      3    2030-01-05 stroke_rate      Stroke rate  60    60    3
      4    2030-01-05    run_rate   Court coverage  60    60    4
      5    2030-01-05  shot_share Share of strokes  20    20    5
      6    2030-01-12       speed     Stroke speed 100   100    1
      7    2030-01-12 stroke_rate      Stroke rate  80    80    2
      8    2030-01-12  shot_share Share of strokes  40    40    3
      9    2030-01-12    accuracy  Stroke accuracy   0     0    4
      10   2030-01-12    run_rate   Court coverage   0     0    5
      11   2030-01-19  shot_share Share of strokes  80    80    1
      12   2030-01-19 stroke_rate      Stroke rate  40    40    2
      13   2030-01-19       speed     Stroke speed  30    30    3
      14   2030-01-19    accuracy  Stroke accuracy  20    20    4
      15   2030-01-19    run_rate   Court coverage  20    20    5
      16   2030-01-26    accuracy  Stroke accuracy  80    80    1
      17   2030-01-26       speed     Stroke speed  60    60    2
      18   2030-01-26  shot_share Share of strokes  60    60    3
      19   2030-01-26    run_rate   Court coverage  40    40    4
      20   2030-01-26 stroke_rate      Stroke rate   0     0    5
      21   2030-02-02 stroke_rate      Stroke rate 100   100    1
      22   2030-02-02  shot_share Share of strokes 100   100    2
      23   2030-02-02    run_rate   Court coverage  80    80    3
      24   2030-02-02    accuracy  Stroke accuracy  60    60    4
      25   2030-02-02       speed     Stroke speed  30    30    5
      26   2030-02-09    run_rate   Court coverage 100   100    1
      27   2030-02-09    accuracy  Stroke accuracy  40    40    2
      28   2030-02-09 stroke_rate      Stroke rate  20    20    3
      29   2030-02-09       speed     Stroke speed   0     0    4
      30   2030-02-09  shot_share Share of strokes   0     0    5

# fmt_speed_mph()/fmt_mmss() formatting is stable

    Code
      fmt_speed_mph(c(0, 10.5, 47.3, NA))
    Output
      [1] "0 km/h (0 mph)"   "17 km/h (10 mph)" "76 km/h (47 mph)" "-"               

---

    Code
      fmt_mmss(c(0, 0.1, 7.5, 62.25, NA))
    Output
      [1] "0m 00s"  "0m 06s"  "7m 30s"  "62m 15s" "-"      

