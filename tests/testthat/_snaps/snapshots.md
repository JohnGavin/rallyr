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
      43     shot_detail      bounce_court_side   VARCHAR               14
      44     shot_detail    bounce_location_lat   VARCHAR               17
      45     shot_detail   bounce_location_long   VARCHAR               16
      46     shot_detail               bounce_x    DOUBLE               21
      47     shot_detail               bounce_y    DOUBLE               22
      48     shot_detail               bounce_z    DOUBLE               23
      49     shot_detail         hit_court_side   VARCHAR               13
      50     shot_detail              hit_frame    DOUBLE               11
      51     shot_detail               hit_type   VARCHAR                6
      52     shot_detail         hit_velocity_x    DOUBLE               24
      53     shot_detail         hit_velocity_y    DOUBLE               25
      54     shot_detail         hit_velocity_z    DOUBLE               26
      55     shot_detail               hit_wing   VARCHAR                7
      56     shot_detail                  hit_x    DOUBLE               18
      57     shot_detail                  hit_y    DOUBLE               19
      58     shot_detail                  hit_z    DOUBLE               20
      59     shot_detail               match_id   INTEGER                1
      60     shot_detail        net_clearance_m    DOUBLE               15
      61     shot_detail                 player   VARCHAR                4
      62     shot_detail               rally_id   INTEGER                3
      63     shot_detail                 regime   VARCHAR               28
      64     shot_detail      regime_occurrence   INTEGER               29
      65     shot_detail          segment_index   INTEGER               27
      66     shot_detail                shot_id   INTEGER                2
      67     shot_detail                shot_in   BOOLEAN               10
      68     shot_detail         shot_speed_mph    DOUBLE                9
      69     shot_detail              spin_type   VARCHAR                8
      70     shot_detail             started_at   VARCHAR                5
      71     shot_detail      video_elapsed_sec    DOUBLE               12
      72   shot_segments           duration_min    DOUBLE                5
      73   shot_segments               end_time   VARCHAR                4
      74   shot_segments           guest_in_pct    DOUBLE               14
      75   shot_segments   guest_speed_mean_mph    DOUBLE               12
      76   shot_segments guest_speed_median_mph    DOUBLE               13
      77   shot_segments               match_id   INTEGER               15
      78   shot_segments        n_guest_gs_left   INTEGER               10
      79   shot_segments       n_guest_gs_right   INTEGER               11
      80   shot_segments          n_guest_shots   INTEGER                8
      81   shot_segments           n_host_shots   INTEGER                7
      82   shot_segments                n_shots   INTEGER                6
      83   shot_segments                 regime   VARCHAR                2
      84   shot_segments      regime_occurrence   INTEGER                9
      85   shot_segments          segment_index   INTEGER                1
      86   shot_segments             start_time   VARCHAR                3

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
      1    9000001        1                  gap                 1             1
      2    9000001       10                  gap                 1             1
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
      21   9000001       11                  gap                 1             1
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
      33   9000001       12                  gap                 1             1
      34   9000001       13                  gap                 1             1
      35   9000001       14                  gap                 1             1
      36   9000001       15                  gap                 1             1
      37   9000001       16                  gap                 1             1
      38   9000001       17                  gap                 1             1
      39   9000001       18           net_volley                 1             2
      40   9000001     19_a           net_volley                 1             2
      41   9000001     19_b           net_volley                 1             2
      42   9000001        2                  gap                 1             1
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
      66   9000001        3                  gap                 1             1
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
      91   9000001        4                  gap                 1             1
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
      107  9000001        5                  gap                 1             1
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
      121  9000001        6                  gap                 1             1
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
      137  9000001        7                  gap                 1             1
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
      154  9000001        8                  gap                 1             1
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
      168  9000001        9                  gap                 1             1
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
      186  9000002        1                  gap                 1             1
      187  9000002       10                  gap                 1             1
      188  9000002      100                  gap                 4             7
      189  9000002      101                  gap                 4             7
      190  9000002      102                  gap                 4             7
      191  9000002      103                  gap                 4             7
      192  9000002      104                  gap                 4             7
      193  9000002      105                  gap                 4             7
      194  9000002      106                  gap                 4             7
      195  9000002       11                  gap                 1             1
      196  9000002       12                  gap                 1             1
      197  9000002       13                  gap                 1             1
      198  9000002       14                  gap                 1             1
      199  9000002       15                  gap                 1             1
      200  9000002       16                  gap                 1             1
      201  9000002       17           net_volley                 1             2
      202  9000002     18_a           net_volley                 1             2
      203  9000002     18_b           net_volley                 1             2
      204  9000002     18_c           net_volley                 1             2
      205  9000002       19           net_volley                 1             2
      206  9000002        2                  gap                 1             1
      207  9000002     20_a           net_volley                 1             2
      208  9000002     20_b           net_volley                 1             2
      209  9000002     21_a           net_volley                 1             2
      210  9000002     21_b           net_volley                 1             2
      211  9000002     22_a           net_volley                 1             2
      212  9000002     22_b           net_volley                 1             2
      213  9000002     23_a           net_volley                 1             2
      214  9000002     23_b           net_volley                 1             2
      215  9000002     24_a           net_volley                 1             2
      216  9000002     24_b           net_volley                 1             2
      217  9000002     24_c           net_volley                 1             2
      218  9000002       25           net_volley                 1             2
      219  9000002     26_a           net_volley                 1             2
      220  9000002     26_b           net_volley                 1             2
      221  9000002     27_a           net_volley                 1             2
      222  9000002     27_b           net_volley                 1             2
      223  9000002     27_c           net_volley                 1             2
      224  9000002       28           net_volley                 1             2
      225  9000002       29           net_volley                 1             2
      226  9000002        3                  gap                 1             1
      227  9000002     30_a           net_volley                 1             2
      228  9000002     30_b           net_volley                 1             2
      229  9000002     30_c           net_volley                 1             2
      230  9000002     31_a           net_volley                 1             2
      231  9000002     31_b           net_volley                 1             2
      232  9000002     32_a           net_volley                 1             2
      233  9000002     32_b           net_volley                 1             2
      234  9000002     32_c           net_volley                 1             2
      235  9000002     33_a           net_volley                 1             2
      236  9000002     33_b           net_volley                 1             2
      237  9000002     34_a           net_volley                 1             2
      238  9000002     34_b           net_volley                 1             2
      239  9000002     35_a           net_volley                 1             2
      240  9000002     35_b           net_volley                 1             2
      241  9000002     36_a           net_volley                 1             2
      242  9000002     36_b           net_volley                 1             2
      243  9000002     37_a           net_volley                 1             2
      244  9000002     37_b           net_volley                 1             2
      245  9000002       38           net_volley                 1             2
      246  9000002       39                  gap                 2             3
      247  9000002        4                  gap                 1             1
      248  9000002     40_a forehand_cross_court                 1             4
      249  9000002     40_b forehand_cross_court                 1             4
      250  9000002       41 forehand_cross_court                 1             4
      251  9000002       42 forehand_cross_court                 1             4
      252  9000002       43 forehand_cross_court                 1             4
      253  9000002       44 forehand_cross_court                 1             4
      254  9000002     45_a forehand_cross_court                 1             4
      255  9000002     45_b forehand_cross_court                 1             4
      256  9000002       46 forehand_cross_court                 1             4
      257  9000002       47 forehand_cross_court                 1             4
      258  9000002     48_a forehand_cross_court                 1             4
      259  9000002     48_b forehand_cross_court                 1             4
      260  9000002     49_a forehand_cross_court                 1             4
      261  9000002     49_b forehand_cross_court                 1             4
      262  9000002        5                  gap                 1             1
      263  9000002       50 forehand_cross_court                 1             4
      264  9000002       51 forehand_cross_court                 1             4
      265  9000002       52 forehand_cross_court                 1             4
      266  9000002     53_a forehand_cross_court                 1             4
      267  9000002     53_b forehand_cross_court                 1             4
      268  9000002       54 forehand_cross_court                 1             4
      269  9000002     55_a forehand_cross_court                 1             4
      270  9000002     55_b forehand_cross_court                 1             4
      271  9000002       56 forehand_cross_court                 1             4
      272  9000002     57_a forehand_cross_court                 1             4
      273  9000002     57_b forehand_cross_court                 1             4
      274  9000002     58_a forehand_cross_court                 1             4
      275  9000002     58_b forehand_cross_court                 1             4
      276  9000002     59_a forehand_cross_court                 1             4
      277  9000002     59_b forehand_cross_court                 1             4
      278  9000002     59_c forehand_cross_court                 1             4
      279  9000002        6                  gap                 1             1
      280  9000002       60 forehand_cross_court                 1             4
      281  9000002       61 forehand_cross_court                 1             4
      282  9000002       62 forehand_cross_court                 1             4
      283  9000002       63 forehand_cross_court                 1             4
      284  9000002       64 forehand_cross_court                 1             4
      285  9000002       65                  gap                 3             5
      286  9000002       66                  gap                 3             5
      287  9000002       67                  gap                 3             5
      288  9000002     68_a backhand_cross_court                 1             6
      289  9000002     68_b backhand_cross_court                 1             6
      290  9000002     68_c backhand_cross_court                 1             6
      291  9000002       69 backhand_cross_court                 1             6
      292  9000002        7                  gap                 1             1
      293  9000002       70 backhand_cross_court                 1             6
      294  9000002       71 backhand_cross_court                 1             6
      295  9000002       72 backhand_cross_court                 1             6
      296  9000002       73 backhand_cross_court                 1             6
      297  9000002       74 backhand_cross_court                 1             6
      298  9000002       75 backhand_cross_court                 1             6
      299  9000002     76_a backhand_cross_court                 1             6
      300  9000002     76_b backhand_cross_court                 1             6
      301  9000002     77_a backhand_cross_court                 1             6
      302  9000002     77_b backhand_cross_court                 1             6
      303  9000002     78_a backhand_cross_court                 1             6
      304  9000002     78_b backhand_cross_court                 1             6
      305  9000002       79 backhand_cross_court                 1             6
      306  9000002        8                  gap                 1             1
      307  9000002     80_a backhand_cross_court                 1             6
      308  9000002     80_b backhand_cross_court                 1             6
      309  9000002     81_a backhand_cross_court                 1             6
      310  9000002     81_b backhand_cross_court                 1             6
      311  9000002       82 backhand_cross_court                 1             6
      312  9000002     83_a backhand_cross_court                 1             6
      313  9000002     83_b backhand_cross_court                 1             6
      314  9000002     83_c backhand_cross_court                 1             6
      315  9000002       84 backhand_cross_court                 1             6
      316  9000002       85 backhand_cross_court                 1             6
      317  9000002       86 backhand_cross_court                 1             6
      318  9000002       87 backhand_cross_court                 1             6
      319  9000002     88_a backhand_cross_court                 1             6
      320  9000002     88_b backhand_cross_court                 1             6
      321  9000002     88_c backhand_cross_court                 1             6
      322  9000002       89 backhand_cross_court                 1             6
      323  9000002        9                  gap                 1             1
      324  9000002       90                  gap                 4             7
      325  9000002       91                  gap                 4             7
      326  9000002       92                  gap                 4             7
      327  9000002       93                  gap                 4             7
      328  9000002       94                  gap                 4             7
      329  9000002       95                  gap                 4             7
      330  9000002       96                  gap                 4             7
      331  9000002       97                  gap                 4             7
      332  9000002       98                  gap                 4             7
      333  9000002       99                  gap                 4             7
      334  9000003        1          mini_tennis                 1             1
      335  9000003       10          mini_tennis                 1             1
      336  9000003      100                  gap                 4             7
      337  9000003      101                  gap                 4             7
      338  9000003      102                  gap                 4             7
      339  9000003      103                  gap                 4             7
      340  9000003      104                  gap                 4             7
      341  9000003       11          mini_tennis                 1             1
      342  9000003       12          mini_tennis                 1             1
      343  9000003       13          mini_tennis                 1             1
      344  9000003       14          mini_tennis                 1             1
      345  9000003       15          mini_tennis                 1             1
      346  9000003       16          mini_tennis                 1             1
      347  9000003       17          mini_tennis                 1             1
      348  9000003       18          mini_tennis                 1             1
      349  9000003       19          mini_tennis                 1             1
      350  9000003        2          mini_tennis                 1             1
      351  9000003       20                  gap                 1             2
      352  9000003       21                  gap                 2             3
      353  9000003       22                  gap                 2             3
      354  9000003       23                  gap                 2             3
      355  9000003       24                  gap                 2             3
      356  9000003       25                  gap                 2             3
      357  9000003       26                  gap                 2             3
      358  9000003       27                  gap                 2             3
      359  9000003       28                  gap                 2             3
      360  9000003       29                  gap                 2             3
      361  9000003        3          mini_tennis                 1             1
      362  9000003       30                  gap                 2             3
      363  9000003       31                  gap                 2             3
      364  9000003       32                  gap                 2             3
      365  9000003       33                  gap                 2             3
      366  9000003       34                  gap                 2             3
      367  9000003       35                  gap                 2             3
      368  9000003       36                  gap                 2             3
      369  9000003       37                  gap                 2             3
      370  9000003       38 forehand_cross_court                 1             4
      371  9000003       39 forehand_cross_court                 1             4
      372  9000003        4          mini_tennis                 1             1
      373  9000003       40 forehand_cross_court                 1             4
      374  9000003       41 forehand_cross_court                 1             4
      375  9000003       42 forehand_cross_court                 1             4
      376  9000003     43_a forehand_cross_court                 1             4
      377  9000003     43_b forehand_cross_court                 1             4
      378  9000003       44 forehand_cross_court                 1             4
      379  9000003     45_a forehand_cross_court                 1             4
      380  9000003     45_b forehand_cross_court                 1             4
      381  9000003       46 forehand_cross_court                 1             4
      382  9000003       47 forehand_cross_court                 1             4
      383  9000003     48_a forehand_cross_court                 1             4
      384  9000003     48_b forehand_cross_court                 1             4
      385  9000003     49_a forehand_cross_court                 1             4
      386  9000003     49_b forehand_cross_court                 1             4
      387  9000003        5          mini_tennis                 1             1
      388  9000003       50 forehand_cross_court                 1             4
      389  9000003       51 forehand_cross_court                 1             4
      390  9000003       52 forehand_cross_court                 1             4
      391  9000003     53_a forehand_cross_court                 1             4
      392  9000003     53_b forehand_cross_court                 1             4
      393  9000003       54 forehand_cross_court                 1             4
      394  9000003       55 forehand_cross_court                 1             4
      395  9000003       56 forehand_cross_court                 1             4
      396  9000003     57_a forehand_cross_court                 1             4
      397  9000003     57_b forehand_cross_court                 1             4
      398  9000003       58 forehand_cross_court                 1             4
      399  9000003       59 forehand_cross_court                 1             4
      400  9000003        6          mini_tennis                 1             1
      401  9000003       60 forehand_cross_court                 1             4
      402  9000003       61 forehand_cross_court                 1             4
      403  9000003       62 forehand_cross_court                 1             4
      404  9000003     63_a backhand_cross_court                 1             5
      405  9000003     63_b backhand_cross_court                 1             5
      406  9000003       64 backhand_cross_court                 1             5
      407  9000003       65 backhand_cross_court                 1             5
      408  9000003       66 backhand_cross_court                 1             5
      409  9000003       67 backhand_cross_court                 1             5
      410  9000003       68 backhand_cross_court                 1             5
      411  9000003       69 backhand_cross_court                 1             5
      412  9000003        7          mini_tennis                 1             1
      413  9000003       70 backhand_cross_court                 1             5
      414  9000003       71 backhand_cross_court                 1             5
      415  9000003     72_a backhand_cross_court                 1             5
      416  9000003     72_b backhand_cross_court                 1             5
      417  9000003       73 backhand_cross_court                 1             5
      418  9000003       74 backhand_cross_court                 1             5
      419  9000003       75 backhand_cross_court                 1             5
      420  9000003       76 backhand_cross_court                 1             5
      421  9000003       77 backhand_cross_court                 1             5
      422  9000003       78 backhand_cross_court                 1             5
      423  9000003     79_a backhand_cross_court                 1             5
      424  9000003     79_b backhand_cross_court                 1             5
      425  9000003     79_c backhand_cross_court                 1             5
      426  9000003        8          mini_tennis                 1             1
      427  9000003       80 backhand_cross_court                 1             5
      428  9000003       81 backhand_cross_court                 1             5
      429  9000003       82 backhand_cross_court                 1             5
      430  9000003       83 backhand_cross_court                 1             5
      431  9000003     84_a backhand_cross_court                 1             5
      432  9000003     84_b backhand_cross_court                 1             5
      433  9000003     84_c backhand_cross_court                 1             5
      434  9000003     85_a backhand_cross_court                 1             5
      435  9000003     85_b backhand_cross_court                 1             5
      436  9000003       86 backhand_cross_court                 1             5
      437  9000003       87                  gap                 3             6
      438  9000003       88                  gap                 4             7
      439  9000003       89                  gap                 4             7
      440  9000003        9          mini_tennis                 1             1
      441  9000003       90                  gap                 4             7
      442  9000003       91                  gap                 4             7
      443  9000003       92                  gap                 4             7
      444  9000003       93                  gap                 4             7
      445  9000003       94                  gap                 4             7
      446  9000003       95                  gap                 4             7
      447  9000003       96                  gap                 4             7
      448  9000003       97                  gap                 4             7
      449  9000003       98                  gap                 4             7
      450  9000003       99                  gap                 4             7
      451  9000004        1                  gap                 1             1
      452  9000004       10                  gap                 1             1
      453  9000004       11                  gap                 1             1
      454  9000004       12                  gap                 1             1
      455  9000004       13                  gap                 1             1
      456  9000004       14                  gap                 1             1
      457  9000004       15                  gap                 1             1
      458  9000004       16           net_volley                 1             2
      459  9000004     17_a           net_volley                 1             2
      460  9000004     17_b           net_volley                 1             2
      461  9000004     17_c           net_volley                 1             2
      462  9000004       18           net_volley                 1             2
      463  9000004       19           net_volley                 1             2
      464  9000004        2                  gap                 1             1
      465  9000004       20           net_volley                 1             2
      466  9000004       21           net_volley                 1             2
      467  9000004       22           net_volley                 1             2
      468  9000004       23           net_volley                 1             2
      469  9000004     24_a           net_volley                 1             2
      470  9000004     24_b           net_volley                 1             2
      471  9000004     25_a           net_volley                 1             2
      472  9000004     25_b           net_volley                 1             2
      473  9000004     26_a           net_volley                 1             2
      474  9000004     26_b           net_volley                 1             2
      475  9000004     27_a           net_volley                 1             2
      476  9000004     27_b           net_volley                 1             2
      477  9000004     27_c           net_volley                 1             2
      478  9000004       28           net_volley                 1             2
      479  9000004     29_a           net_volley                 1             2
      480  9000004     29_b           net_volley                 1             2
      481  9000004        3                  gap                 1             1
      482  9000004       30           net_volley                 1             2
      483  9000004     31_a           net_volley                 1             2
      484  9000004     31_b           net_volley                 1             2
      485  9000004     32_a           net_volley                 1             2
      486  9000004     32_b           net_volley                 1             2
      487  9000004     33_a           net_volley                 1             2
      488  9000004     33_b           net_volley                 1             2
      489  9000004     34_a           net_volley                 1             2
      490  9000004     34_b           net_volley                 1             2
      491  9000004       35           net_volley                 1             2
      492  9000004     36_a           net_volley                 1             2
      493  9000004     36_b           net_volley                 1             2
      494  9000004     36_c           net_volley                 1             2
      495  9000004     37_a           net_volley                 1             2
      496  9000004     37_b           net_volley                 1             2
      497  9000004       38           net_volley                 1             2
      498  9000004     39_a           net_volley                 1             2
      499  9000004     39_b           net_volley                 1             2
      500  9000004        4                  gap                 1             1
      501  9000004     40_a           net_volley                 1             2
      502  9000004     40_b           net_volley                 1             2
      503  9000004     41_a forehand_cross_court                 1             3
      504  9000004     41_b forehand_cross_court                 1             3
      505  9000004       42 forehand_cross_court                 1             3
      506  9000004       43 forehand_cross_court                 1             3
      507  9000004       44 forehand_cross_court                 1             3
      508  9000004       45 forehand_cross_court                 1             3
      509  9000004       46 forehand_cross_court                 1             3
      510  9000004       47 forehand_cross_court                 1             3
      511  9000004       48 forehand_cross_court                 1             3
      512  9000004     49_a forehand_cross_court                 1             3
      513  9000004     49_b forehand_cross_court                 1             3
      514  9000004     49_c forehand_cross_court                 1             3
      515  9000004        5                  gap                 1             1
      516  9000004     50_a forehand_cross_court                 1             3
      517  9000004     50_b forehand_cross_court                 1             3
      518  9000004       51 forehand_cross_court                 1             3
      519  9000004       52 forehand_cross_court                 1             3
      520  9000004       53 forehand_cross_court                 1             3
      521  9000004     54_a forehand_cross_court                 1             3
      522  9000004     54_b forehand_cross_court                 1             3
      523  9000004       55 forehand_cross_court                 1             3
      524  9000004     56_a forehand_cross_court                 1             3
      525  9000004     56_b forehand_cross_court                 1             3
      526  9000004     57_a forehand_cross_court                 1             3
      527  9000004     57_b forehand_cross_court                 1             3
      528  9000004       58 forehand_cross_court                 1             3
      529  9000004     59_a forehand_cross_court                 1             3
      530  9000004     59_b forehand_cross_court                 1             3
      531  9000004     59_c forehand_cross_court                 1             3
      532  9000004        6                  gap                 1             1
      533  9000004       60 forehand_cross_court                 1             3
      534  9000004       61 forehand_cross_court                 1             3
      535  9000004       62 backhand_cross_court                 1             4
      536  9000004       63 backhand_cross_court                 1             4
      537  9000004       64 backhand_cross_court                 1             4
      538  9000004     65_a backhand_cross_court                 1             4
      539  9000004     65_b backhand_cross_court                 1             4
      540  9000004       66 backhand_cross_court                 1             4
      541  9000004     67_a backhand_cross_court                 1             4
      542  9000004     67_b backhand_cross_court                 1             4
      543  9000004     68_a backhand_cross_court                 1             4
      544  9000004     68_b backhand_cross_court                 1             4
      545  9000004     68_c backhand_cross_court                 1             4
      546  9000004       69 backhand_cross_court                 1             4
      547  9000004        7                  gap                 1             1
      548  9000004       70 backhand_cross_court                 1             4
      549  9000004     71_a backhand_cross_court                 1             4
      550  9000004     71_b backhand_cross_court                 1             4
      551  9000004     72_a backhand_cross_court                 1             4
      552  9000004     72_b backhand_cross_court                 1             4
      553  9000004       73 backhand_cross_court                 1             4
      554  9000004       74 backhand_cross_court                 1             4
      555  9000004     75_a backhand_cross_court                 1             4
      556  9000004     75_b backhand_cross_court                 1             4
      557  9000004       76 backhand_cross_court                 1             4
      558  9000004       77 backhand_cross_court                 1             4
      559  9000004       78 backhand_cross_court                 1             4
      560  9000004       79 backhand_cross_court                 1             4
      561  9000004        8                  gap                 1             1
      562  9000004     80_a backhand_cross_court                 1             4
      563  9000004     80_b backhand_cross_court                 1             4
      564  9000004       81                  gap                 2             5
      565  9000004       82                  gap                 2             5
      566  9000004       83                  gap                 2             5
      567  9000004       84                  gap                 2             5
      568  9000004       85                  gap                 2             5
      569  9000004       86                  gap                 2             5
      570  9000004       87                  gap                 2             5
      571  9000004       88                  gap                 2             5
      572  9000004       89                  gap                 2             5
      573  9000004        9                  gap                 1             1
      574  9000004       90                  gap                 2             5
      575  9000004       91                  gap                 2             5
      576  9000004       92                  gap                 2             5
      577  9000004       93                  gap                 2             5
      578  9000004       94                  gap                 2             5
      579  9000004       95                  gap                 2             5
      580  9000004       96                  gap                 2             5
      581  9000005        1                  gap                 1             1
      582  9000005       10                  gap                 1             1
      583  9000005      100                  gap                 5             8
      584  9000005      101                  gap                 5             8
      585  9000005      102                  gap                 5             8
      586  9000005      103                  gap                 5             8
      587  9000005      104                  gap                 5             8
      588  9000005      105                  gap                 5             8
      589  9000005      106                  gap                 5             8
      590  9000005      107                  gap                 5             8
      591  9000005      108                  gap                 5             8
      592  9000005      109                  gap                 5             8
      593  9000005       11                  gap                 1             1
      594  9000005      110                  gap                 5             8
      595  9000005       12                  gap                 1             1
      596  9000005       13                  gap                 1             1
      597  9000005       14                  gap                 1             1
      598  9000005       15                  gap                 1             1
      599  9000005       16                  gap                 1             1
      600  9000005     17_a           net_volley                 1             3
      601  9000005     17_b           net_volley                 1             3
      602  9000005     18_a           net_volley                 1             3
      603  9000005     18_b           net_volley                 1             3
      604  9000005     18_c           net_volley                 1             3
      605  9000005     19_a           net_volley                 1             3
      606  9000005     19_b           net_volley                 1             3
      607  9000005        2                  gap                 1             1
      608  9000005       20           net_volley                 1             3
      609  9000005     21_a           net_volley                 1             3
      610  9000005     21_b           net_volley                 1             3
      611  9000005     21_c           net_volley                 1             3
      612  9000005       22           net_volley                 1             3
      613  9000005       23           net_volley                 1             3
      614  9000005       24           net_volley                 1             3
      615  9000005     25_a           net_volley                 1             3
      616  9000005     25_b           net_volley                 1             3
      617  9000005     26_a           net_volley                 1             3
      618  9000005     26_b           net_volley                 1             3
      619  9000005       27           net_volley                 1             3
      620  9000005     28_a           net_volley                 1             3
      621  9000005     28_b           net_volley                 1             3
      622  9000005       29           net_volley                 1             3
      623  9000005        3                  gap                 1             1
      624  9000005       30           net_volley                 1             3
      625  9000005     31_a           net_volley                 1             3
      626  9000005     31_b           net_volley                 1             3
      627  9000005     32_a           net_volley                 1             3
      628  9000005     32_b           net_volley                 1             3
      629  9000005     32_c           net_volley                 1             3
      630  9000005     33_a           net_volley                 1             3
      631  9000005     33_b           net_volley                 1             3
      632  9000005       34           net_volley                 1             3
      633  9000005     35_a           net_volley                 1             3
      634  9000005     35_b           net_volley                 1             3
      635  9000005       36           net_volley                 1             3
      636  9000005     37_a           net_volley                 1             3
      637  9000005     37_b           net_volley                 1             3
      638  9000005     37_c           net_volley                 1             3
      639  9000005     38_a           net_volley                 1             3
      640  9000005     38_b           net_volley                 1             3
      641  9000005       39                  gap                 3             4
      642  9000005        4                  gap                 1             1
      643  9000005       40 forehand_cross_court                 1             5
      644  9000005     41_a forehand_cross_court                 1             5
      645  9000005     41_b forehand_cross_court                 1             5
      646  9000005     41_c forehand_cross_court                 1             5
      647  9000005       42 forehand_cross_court                 1             5
      648  9000005       43 forehand_cross_court                 1             5
      649  9000005       44 forehand_cross_court                 1             5
      650  9000005       45 forehand_cross_court                 1             5
      651  9000005       46 forehand_cross_court                 1             5
      652  9000005       47 forehand_cross_court                 1             5
      653  9000005       48 forehand_cross_court                 1             5
      654  9000005     49_a forehand_cross_court                 1             5
      655  9000005     49_b forehand_cross_court                 1             5
      656  9000005        5                  gap                 1             1
      657  9000005       50 forehand_cross_court                 1             5
      658  9000005       51 forehand_cross_court                 1             5
      659  9000005       52 forehand_cross_court                 1             5
      660  9000005     53_a forehand_cross_court                 1             5
      661  9000005     53_b forehand_cross_court                 1             5
      662  9000005     53_c forehand_cross_court                 1             5
      663  9000005       54 forehand_cross_court                 1             5
      664  9000005       55 forehand_cross_court                 1             5
      665  9000005     56_a forehand_cross_court                 1             5
      666  9000005     56_b forehand_cross_court                 1             5
      667  9000005       57 forehand_cross_court                 1             5
      668  9000005       58 forehand_cross_court                 1             5
      669  9000005     59_a forehand_cross_court                 1             5
      670  9000005     59_b forehand_cross_court                 1             5
      671  9000005        6                  gap                 1             1
      672  9000005       60 forehand_cross_court                 1             5
      673  9000005       61 forehand_cross_court                 1             5
      674  9000005       62 forehand_cross_court                 1             5
      675  9000005       63 forehand_cross_court                 1             5
      676  9000005       64 forehand_cross_court                 1             5
      677  9000005       65 forehand_cross_court                 1             5
      678  9000005       66 forehand_cross_court                 1             5
      679  9000005       67 forehand_cross_court                 1             5
      680  9000005       68 forehand_cross_court                 1             5
      681  9000005       69 forehand_cross_court                 1             5
      682  9000005        7                  gap                 1             1
      683  9000005       70 forehand_cross_court                 1             5
      684  9000005       71 backhand_cross_court                 1             6
      685  9000005       72 backhand_cross_court                 1             6
      686  9000005       73 backhand_cross_court                 1             6
      687  9000005     74_a backhand_cross_court                 1             6
      688  9000005     74_b backhand_cross_court                 1             6
      689  9000005     75_a backhand_cross_court                 1             6
      690  9000005     75_b backhand_cross_court                 1             6
      691  9000005       76 backhand_cross_court                 1             6
      692  9000005       77 backhand_cross_court                 1             6
      693  9000005       78 backhand_cross_court                 1             6
      694  9000005       79 backhand_cross_court                 1             6
      695  9000005        8                  gap                 1             1
      696  9000005       80 backhand_cross_court                 1             6
      697  9000005     81_a backhand_cross_court                 1             6
      698  9000005     81_b backhand_cross_court                 1             6
      699  9000005       82 backhand_cross_court                 1             6
      700  9000005     83_a backhand_cross_court                 1             6
      701  9000005     83_b backhand_cross_court                 1             6
      702  9000005     83_c backhand_cross_court                 1             6
      703  9000005       84 backhand_cross_court                 1             6
      704  9000005       85 backhand_cross_court                 1             6
      705  9000005     86_a backhand_cross_court                 1             6
      706  9000005     86_b backhand_cross_court                 1             6
      707  9000005       87 backhand_cross_court                 1             6
      708  9000005       88 backhand_cross_court                 1             6
      709  9000005       89 backhand_cross_court                 1             6
      710  9000005        9                  gap                 1             1
      711  9000005       90 backhand_cross_court                 1             6
      712  9000005       91 backhand_cross_court                 1             6
      713  9000005       92 backhand_cross_court                 1             6
      714  9000005     93_a backhand_cross_court                 1             6
      715  9000005     93_b backhand_cross_court                 1             6
      716  9000005       94 backhand_cross_court                 1             6
      717  9000005       95 backhand_cross_court                 1             6
      718  9000005       96 backhand_cross_court                 1             6
      719  9000005       97                  gap                 4             7
      720  9000005       98                  gap                 5             8
      721  9000005       99                  gap                 5             8
      722  9000006        1          mini_tennis                 1             1
      723  9000006       10          mini_tennis                 1             1
      724  9000006      100                  gap                 2             6
      725  9000006      101                  gap                 2             6
      726  9000006      102                  gap                 2             6
      727  9000006      103                  gap                 2             6
      728  9000006      104                  gap                 2             6
      729  9000006      105                  gap                 2             6
      730  9000006      106                  gap                 2             6
      731  9000006      107                  gap                 2             6
      732  9000006       11          mini_tennis                 1             1
      733  9000006       12          mini_tennis                 1             1
      734  9000006       13          mini_tennis                 1             1
      735  9000006       14          mini_tennis                 1             1
      736  9000006       15          mini_tennis                 1             1
      737  9000006       16          mini_tennis                 1             1
      738  9000006       17          mini_tennis                 1             1
      739  9000006       18           net_volley                 1             2
      740  9000006     19_a           net_volley                 1             2
      741  9000006     19_b           net_volley                 1             2
      742  9000006     19_c           net_volley                 1             2
      743  9000006     19_d           net_volley                 1             2
      744  9000006        2          mini_tennis                 1             1
      745  9000006     20_a           net_volley                 1             2
      746  9000006     20_b           net_volley                 1             2
      747  9000006     20_c           net_volley                 1             2
      748  9000006     21_a           net_volley                 1             2
      749  9000006     21_b           net_volley                 1             2
      750  9000006     22_a           net_volley                 1             2
      751  9000006     22_b           net_volley                 1             2
      752  9000006     23_a           net_volley                 1             2
      753  9000006     23_b           net_volley                 1             2
      754  9000006     24_a           net_volley                 1             2
      755  9000006     24_b           net_volley                 1             2
      756  9000006     24_c           net_volley                 1             2
      757  9000006     25_a           net_volley                 1             2
      758  9000006     25_b           net_volley                 1             2
      759  9000006     25_c           net_volley                 1             2
      760  9000006     25_d           net_volley                 1             2
      761  9000006     26_a           net_volley                 1             2
      762  9000006     26_b           net_volley                 1             2
      763  9000006     27_a           net_volley                 1             2
      764  9000006     27_b           net_volley                 1             2
      765  9000006     27_c           net_volley                 1             2
      766  9000006     28_a           net_volley                 1             2
      767  9000006     28_b           net_volley                 1             2
      768  9000006     29_a           net_volley                 1             2
      769  9000006     29_b           net_volley                 1             2
      770  9000006        3          mini_tennis                 1             1
      771  9000006     30_a           net_volley                 1             2
      772  9000006     30_b           net_volley                 1             2
      773  9000006     31_a           net_volley                 1             2
      774  9000006     31_b           net_volley                 1             2
      775  9000006     31_c           net_volley                 1             2
      776  9000006     32_a           net_volley                 1             2
      777  9000006     32_b           net_volley                 1             2
      778  9000006     33_a           net_volley                 1             2
      779  9000006     33_b           net_volley                 1             2
      780  9000006     34_a           net_volley                 1             2
      781  9000006     34_b           net_volley                 1             2
      782  9000006     35_a           net_volley                 1             2
      783  9000006     35_b           net_volley                 1             2
      784  9000006     35_c           net_volley                 1             2
      785  9000006     36_a           net_volley                 1             2
      786  9000006     36_b           net_volley                 1             2
      787  9000006     36_c           net_volley                 1             2
      788  9000006       37           net_volley                 1             2
      789  9000006     38_a           net_volley                 1             2
      790  9000006     38_b           net_volley                 1             2
      791  9000006     38_c           net_volley                 1             2
      792  9000006     38_d           net_volley                 1             2
      793  9000006     39_a           net_volley                 1             2
      794  9000006     39_b           net_volley                 1             2
      795  9000006        4          mini_tennis                 1             1
      796  9000006     40_a           net_volley                 1             2
      797  9000006     40_b           net_volley                 1             2
      798  9000006       41 forehand_cross_court                 1             3
      799  9000006       42 forehand_cross_court                 1             3
      800  9000006       43 forehand_cross_court                 1             3
      801  9000006     44_a forehand_cross_court                 1             3
      802  9000006     44_b forehand_cross_court                 1             3
      803  9000006     45_a forehand_cross_court                 1             3
      804  9000006     45_b forehand_cross_court                 1             3
      805  9000006       46 forehand_cross_court                 1             3
      806  9000006       47 forehand_cross_court                 1             3
      807  9000006     48_a forehand_cross_court                 1             3
      808  9000006     48_b forehand_cross_court                 1             3
      809  9000006     49_a forehand_cross_court                 1             3
      810  9000006     49_b forehand_cross_court                 1             3
      811  9000006        5          mini_tennis                 1             1
      812  9000006       50 forehand_cross_court                 1             3
      813  9000006     51_a forehand_cross_court                 1             3
      814  9000006     51_b forehand_cross_court                 1             3
      815  9000006       52 forehand_cross_court                 1             3
      816  9000006     53_a forehand_cross_court                 1             3
      817  9000006     53_b forehand_cross_court                 1             3
      818  9000006     53_c forehand_cross_court                 1             3
      819  9000006       54 forehand_cross_court                 1             3
      820  9000006     55_a forehand_cross_court                 1             3
      821  9000006     55_b forehand_cross_court                 1             3
      822  9000006     56_a forehand_cross_court                 1             3
      823  9000006     56_b forehand_cross_court                 1             3
      824  9000006       57 forehand_cross_court                 1             3
      825  9000006       58 forehand_cross_court                 1             3
      826  9000006       59 forehand_cross_court                 1             3
      827  9000006        6          mini_tennis                 1             1
      828  9000006       60 forehand_cross_court                 1             3
      829  9000006       61 forehand_cross_court                 1             3
      830  9000006       62 forehand_cross_court                 1             3
      831  9000006       63 forehand_cross_court                 1             3
      832  9000006       64 forehand_cross_court                 1             3
      833  9000006     65_a forehand_cross_court                 1             3
      834  9000006     65_b forehand_cross_court                 1             3
      835  9000006       66 forehand_cross_court                 1             3
      836  9000006       67 forehand_cross_court                 1             3
      837  9000006       68 forehand_cross_court                 1             3
      838  9000006       69 backhand_cross_court                 1             4
      839  9000006        7          mini_tennis                 1             1
      840  9000006       70 backhand_cross_court                 1             4
      841  9000006       71 backhand_cross_court                 1             4
      842  9000006       72 backhand_cross_court                 1             4
      843  9000006       73 backhand_cross_court                 1             4
      844  9000006       74 backhand_cross_court                 1             4
      845  9000006       75 backhand_cross_court                 1             4
      846  9000006       76 backhand_cross_court                 1             4
      847  9000006       77 backhand_cross_court                 1             4
      848  9000006       78 backhand_cross_court                 1             4
      849  9000006       79 backhand_cross_court                 1             4
      850  9000006        8          mini_tennis                 1             1
      851  9000006       80 backhand_cross_court                 1             4
      852  9000006       81 backhand_cross_court                 1             4
      853  9000006       82 backhand_cross_court                 1             4
      854  9000006       83 backhand_cross_court                 1             4
      855  9000006       84 backhand_cross_court                 1             4
      856  9000006       85 backhand_cross_court                 1             4
      857  9000006       86 backhand_cross_court                 1             4
      858  9000006       87 backhand_cross_court                 1             4
      859  9000006     88_a backhand_cross_court                 1             4
      860  9000006     88_b backhand_cross_court                 1             4
      861  9000006       89 backhand_cross_court                 1             4
      862  9000006        9          mini_tennis                 1             1
      863  9000006     90_a backhand_cross_court                 1             4
      864  9000006     90_b backhand_cross_court                 1             4
      865  9000006       91                  gap                 1             5
      866  9000006       92                  gap                 2             6
      867  9000006       93                  gap                 2             6
      868  9000006       94                  gap                 2             6
      869  9000006       95                  gap                 2             6
      870  9000006       96                  gap                 2             6
      871  9000006       97                  gap                 2             6
      872  9000006       98                  gap                 2             6
      873  9000006       99                  gap                 2             6
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
      188       7        4    14.500000 2030-01-12 18:20:06 2030-01-12 18:20:21
      189       7        3    13.500000 2030-01-12 18:20:23 2030-01-12 18:20:37
      190       2        1     2.900000 2030-01-12 18:20:39 2030-01-12 18:20:42
      191       5        3    10.800000 2030-01-12 18:20:43 2030-01-12 18:20:54
      192       2        1     3.100000 2030-01-12 18:20:56 2030-01-12 18:20:59
      193       2        1     2.800000 2030-01-12 18:21:00 2030-01-12 18:21:03
      194       3        1     6.900000 2030-01-12 18:21:04 2030-01-12 18:21:11
      195       8        4    17.000000 2030-01-12 18:01:26 2030-01-12 18:01:43
      196       3        2     5.800000 2030-01-12 18:01:45 2030-01-12 18:01:51
      197       6        3     9.800000 2030-01-12 18:01:52 2030-01-12 18:02:02
      198       3        1     4.500000 2030-01-12 18:02:02 2030-01-12 18:02:07
      199       3        2     5.100000 2030-01-12 18:02:08 2030-01-12 18:02:13
      200       1        0     0.700000 2030-01-12 18:02:13 2030-01-12 18:02:14
      201       2        1     1.900000 2030-01-12 18:03:20 2030-01-12 18:03:22
      202       1        1     0.000000 2030-01-12 18:03:23 2030-01-12 18:03:23
      203       2        1     2.736682 2030-01-12 18:03:26 2030-01-12 18:03:29
      204       2        1     2.756085 2030-01-12 18:03:32 2030-01-12 18:03:35
      205       3        1     5.000000 2030-01-12 18:03:37 2030-01-12 18:03:42
      206       4        2     6.600000 2030-01-12 18:00:05 2030-01-12 18:00:11
      207       3        2     3.287733 2030-01-12 18:03:43 2030-01-12 18:03:47
      208       1        0     0.000000 2030-01-12 18:03:49 2030-01-12 18:03:49
      209       1        1     0.000000 2030-01-12 18:03:52 2030-01-12 18:03:52
      210       2        1     1.402202 2030-01-12 18:03:54 2030-01-12 18:03:56
      211       2        1     1.848931 2030-01-12 18:03:59 2030-01-12 18:04:01
      212       2        1     3.459990 2030-01-12 18:04:04 2030-01-12 18:04:07
      213       4        2     4.712779 2030-01-12 18:04:08 2030-01-12 18:04:13
      214       2        1     1.531132 2030-01-12 18:04:16 2030-01-12 18:04:18
      215       2        1     1.302540 2030-01-12 18:04:21 2030-01-12 18:04:22
      216       2        1     1.887556 2030-01-12 18:04:25 2030-01-12 18:04:27
      217       2        1     1.826424 2030-01-12 18:04:30 2030-01-12 18:04:32
      218       6        3     7.000000 2030-01-12 18:04:34 2030-01-12 18:04:41
      219       2        1     3.225265 2030-01-12 18:04:43 2030-01-12 18:04:46
      220       1        0     0.000000 2030-01-12 18:04:49 2030-01-12 18:04:49
      221       1        1     0.000000 2030-01-12 18:04:51 2030-01-12 18:04:51
      222       2        1     2.730263 2030-01-12 18:04:55 2030-01-12 18:04:57
      223       2        1     1.648295 2030-01-12 18:05:00 2030-01-12 18:05:01
      224       3        1     5.400000 2030-01-12 18:05:03 2030-01-12 18:05:08
      225       3        2     4.500000 2030-01-12 18:05:10 2030-01-12 18:05:14
      226       6        3     9.600000 2030-01-12 18:00:14 2030-01-12 18:00:23
      227       2        1     2.662334 2030-01-12 18:05:16 2030-01-12 18:05:19
      228       2        1     3.323382 2030-01-12 18:05:22 2030-01-12 18:05:25
      229       2        1     2.884742 2030-01-12 18:05:28 2030-01-12 18:05:31
      230       2        1     3.073073 2030-01-12 18:05:32 2030-01-12 18:05:35
      231       1        0     0.000000 2030-01-12 18:05:37 2030-01-12 18:05:37
      232       3        2     2.830276 2030-01-12 18:05:39 2030-01-12 18:05:42
      233       2        1     1.243147 2030-01-12 18:05:45 2030-01-12 18:05:46
      234       2        1     2.672515 2030-01-12 18:05:49 2030-01-12 18:05:51
      235       2        1     3.377877 2030-01-12 18:05:54 2030-01-12 18:05:57
      236       4        2     3.916240 2030-01-12 18:06:00 2030-01-12 18:06:04
      237       2        1     3.158223 2030-01-12 18:06:06 2030-01-12 18:06:09
      238       1        0     0.000000 2030-01-12 18:06:11 2030-01-12 18:06:11
      239       3        2     5.102767 2030-01-12 18:06:14 2030-01-12 18:06:19
      240       2        1     2.542565 2030-01-12 18:06:21 2030-01-12 18:06:24
      241       2        1     1.531337 2030-01-12 18:06:26 2030-01-12 18:06:27
      242       3        1     3.127378 2030-01-12 18:06:30 2030-01-12 18:06:34
      243       5        3     5.169358 2030-01-12 18:06:36 2030-01-12 18:06:41
      244       1        0     0.000000 2030-01-12 18:06:44 2030-01-12 18:06:44
      245       5        3    10.100000 2030-01-12 18:06:45 2030-01-12 18:06:55
      246       6        3    12.700000 2030-01-12 18:07:52 2030-01-12 18:08:05
      247       2        1     2.600000 2030-01-12 18:00:24 2030-01-12 18:00:27
      248       5        3     7.561265 2030-01-12 18:08:07 2030-01-12 18:08:14
      249       1        0     0.000000 2030-01-12 18:08:18 2030-01-12 18:08:18
      250       3        2     5.400000 2030-01-12 18:08:20 2030-01-12 18:08:25
      251       3        1     5.000000 2030-01-12 18:08:26 2030-01-12 18:08:31
      252       3        2     5.800000 2030-01-12 18:08:32 2030-01-12 18:08:37
      253       3        1     4.400000 2030-01-12 18:08:38 2030-01-12 18:08:43
      254       3        2     3.096777 2030-01-12 18:08:44 2030-01-12 18:08:47
      255       2        1     1.527421 2030-01-12 18:08:51 2030-01-12 18:08:52
      256       2        1     2.600000 2030-01-12 18:08:55 2030-01-12 18:08:58
      257       4        2     6.900000 2030-01-12 18:09:00 2030-01-12 18:09:07
      258       2        1     1.314013 2030-01-12 18:09:10 2030-01-12 18:09:11
      259       4        2     6.937209 2030-01-12 18:09:14 2030-01-12 18:09:21
      260       2        1     3.341973 2030-01-12 18:09:24 2030-01-12 18:09:28
      261       5        2     9.200827 2030-01-12 18:09:31 2030-01-12 18:09:40
      262       4        2     7.500000 2030-01-12 18:00:28 2030-01-12 18:00:36
      263       3        2     4.500000 2030-01-12 18:09:42 2030-01-12 18:09:47
      264       5        2    10.300000 2030-01-12 18:09:50 2030-01-12 18:10:00
      265       2        1     2.000000 2030-01-12 18:10:01 2030-01-12 18:10:03
      266       3        2     5.886021 2030-01-12 18:10:05 2030-01-12 18:10:11
      267       3        1     4.337725 2030-01-12 18:10:14 2030-01-12 18:10:19
      268       3        2     4.200000 2030-01-12 18:10:20 2030-01-12 18:10:24
      269       4        2     6.212980 2030-01-12 18:10:26 2030-01-12 18:10:33
      270       2        1     2.002401 2030-01-12 18:10:36 2030-01-12 18:10:38
      271       4        2     6.400000 2030-01-12 18:10:41 2030-01-12 18:10:47
      272       6        3     8.641519 2030-01-12 18:10:49 2030-01-12 18:10:58
      273       1        0     0.000000 2030-01-12 18:11:01 2030-01-12 18:11:01
      274       5        3     9.774942 2030-01-12 18:11:03 2030-01-12 18:11:12
      275       3        1     3.722835 2030-01-12 18:11:15 2030-01-12 18:11:19
      276       3        2     5.226430 2030-01-12 18:11:20 2030-01-12 18:11:25
      277       2        1     1.898425 2030-01-12 18:11:28 2030-01-12 18:11:30
      278       2        1     2.414275 2030-01-12 18:11:33 2030-01-12 18:11:36
      279       5        2     7.000000 2030-01-12 18:00:38 2030-01-12 18:00:45
      280       4        2     8.000000 2030-01-12 18:11:37 2030-01-12 18:11:45
      281       3        1     3.000000 2030-01-12 18:11:47 2030-01-12 18:11:50
      282       3        2     4.500000 2030-01-12 18:11:51 2030-01-12 18:11:56
      283       7        3    15.900000 2030-01-12 18:11:57 2030-01-12 18:12:13
      284       5        3     6.900000 2030-01-12 18:12:15 2030-01-12 18:12:22
      285       3        2     5.900000 2030-01-12 18:13:36 2030-01-12 18:13:42
      286       2        1     3.600000 2030-01-12 18:13:44 2030-01-12 18:13:47
      287       5        2     9.900000 2030-01-12 18:13:49 2030-01-12 18:13:59
      288       1        1     0.000000 2030-01-12 18:14:00 2030-01-12 18:14:00
      289       2        1     1.505355 2030-01-12 18:14:03 2030-01-12 18:14:04
      290       2        1     2.376395 2030-01-12 18:14:07 2030-01-12 18:14:10
      291       5        2    11.000000 2030-01-12 18:14:12 2030-01-12 18:14:23
      292       4        2     9.900000 2030-01-12 18:00:48 2030-01-12 18:00:58
      293       3        2     5.100000 2030-01-12 18:14:24 2030-01-12 18:14:29
      294       2        1     2.700000 2030-01-12 18:14:32 2030-01-12 18:14:35
      295       4        2     5.500000 2030-01-12 18:14:36 2030-01-12 18:14:42
      296       2        1     3.800000 2030-01-12 18:14:43 2030-01-12 18:14:46
      297       3        1     4.300000 2030-01-12 18:14:49 2030-01-12 18:14:53
      298       3        2     5.000000 2030-01-12 18:14:55 2030-01-12 18:15:00
      299       4        2     5.419077 2030-01-12 18:15:01 2030-01-12 18:15:06
      300       3        1     3.719069 2030-01-12 18:15:10 2030-01-12 18:15:13
      301       1        1     0.000000 2030-01-12 18:15:15 2030-01-12 18:15:15
      302       3        1     5.476950 2030-01-12 18:15:18 2030-01-12 18:15:24
      303       1        1     0.000000 2030-01-12 18:15:26 2030-01-12 18:15:26
      304       3        1     3.962130 2030-01-12 18:15:29 2030-01-12 18:15:33
      305       5        3     8.700000 2030-01-12 18:15:35 2030-01-12 18:15:44
      306       3        2     5.500000 2030-01-12 18:00:59 2030-01-12 18:01:05
      307       2        1     3.169741 2030-01-12 18:15:45 2030-01-12 18:15:48
      308       1        0     0.000000 2030-01-12 18:15:51 2030-01-12 18:15:51
      309       1        1     0.000000 2030-01-12 18:15:54 2030-01-12 18:15:54
      310       3        1     4.479933 2030-01-12 18:15:57 2030-01-12 18:16:02
      311       4        2     6.800000 2030-01-12 18:16:04 2030-01-12 18:16:11
      312       1        1     0.000000 2030-01-12 18:16:13 2030-01-12 18:16:13
      313       2        1     1.544947 2030-01-12 18:16:16 2030-01-12 18:16:17
      314       3        1     3.406495 2030-01-12 18:16:21 2030-01-12 18:16:24
      315       7        4    13.800000 2030-01-12 18:16:28 2030-01-12 18:16:41
      316       2        1     2.600000 2030-01-12 18:16:44 2030-01-12 18:16:47
      317       6        3    12.400000 2030-01-12 18:16:49 2030-01-12 18:17:01
      318       5        2     8.700000 2030-01-12 18:17:02 2030-01-12 18:17:11
      319       1        1     0.000000 2030-01-12 18:17:12 2030-01-12 18:17:12
      320       4        2     7.130767 2030-01-12 18:17:15 2030-01-12 18:17:22
      321       2        1     1.824595 2030-01-12 18:17:26 2030-01-12 18:17:28
      322       1        0     0.700000 2030-01-12 18:17:29 2030-01-12 18:17:30
      323       3        1     6.000000 2030-01-12 18:01:07 2030-01-12 18:01:13
      324       3        2     5.100000 2030-01-12 18:18:30 2030-01-12 18:18:35
      325       4        2     8.400000 2030-01-12 18:18:37 2030-01-12 18:18:46
      326       7        3    13.700000 2030-01-12 18:18:46 2030-01-12 18:19:00
      327       4        2     8.900000 2030-01-12 18:19:02 2030-01-12 18:19:11
      328       4        2     6.800000 2030-01-12 18:19:14 2030-01-12 18:19:20
      329       4        2     8.200000 2030-01-12 18:19:22 2030-01-12 18:19:30
      330       6        3    12.600000 2030-01-12 18:19:32 2030-01-12 18:19:44
      331       2        1     3.200000 2030-01-12 18:19:46 2030-01-12 18:19:49
      332       3        2     4.600000 2030-01-12 18:19:51 2030-01-12 18:19:56
      333       3        1     6.500000 2030-01-12 18:19:58 2030-01-12 18:20:04
      334       7        4    12.000000 2030-01-19 13:00:00 2030-01-19 13:00:12
      335       2        1     3.600000 2030-01-19 13:01:33 2030-01-19 13:01:37
      336       6        3    14.800000 2030-01-19 13:20:54 2030-01-19 13:21:09
      337       6        3    11.700000 2030-01-19 13:21:11 2030-01-19 13:21:23
      338       3        2     6.100000 2030-01-19 13:21:25 2030-01-19 13:21:31
      339       6        3    11.500000 2030-01-19 13:21:33 2030-01-19 13:21:44
      340       2        1     2.800000 2030-01-19 13:21:47 2030-01-19 13:21:50
      341       3        2     4.600000 2030-01-19 13:01:40 2030-01-19 13:01:44
      342       4        2     6.300000 2030-01-19 13:01:47 2030-01-19 13:01:53
      343       4        2     8.200000 2030-01-19 13:01:54 2030-01-19 13:02:03
      344       4        2     7.200000 2030-01-19 13:02:03 2030-01-19 13:02:10
      345       3        1     5.100000 2030-01-19 13:02:13 2030-01-19 13:02:18
      346       6        3     9.800000 2030-01-19 13:02:19 2030-01-19 13:02:29
      347       2        1     3.600000 2030-01-19 13:02:30 2030-01-19 13:02:33
      348       6        3    16.200000 2030-01-19 13:02:35 2030-01-19 13:02:51
      349       4        2     8.900000 2030-01-19 13:02:52 2030-01-19 13:03:01
      350       3        1     6.400000 2030-01-19 13:00:13 2030-01-19 13:00:20
      351       1        1     0.900000 2030-01-19 13:03:04 2030-01-19 13:03:05
      352       1        1     0.500000 2030-01-19 13:04:22 2030-01-19 13:04:22
      353       3        1     4.700000 2030-01-19 13:04:24 2030-01-19 13:04:29
      354       5        3    11.100000 2030-01-19 13:04:31 2030-01-19 13:04:42
      355       6        3    10.500000 2030-01-19 13:04:43 2030-01-19 13:04:54
      356       4        2     5.400000 2030-01-19 13:04:55 2030-01-19 13:05:00
      357       5        2    12.000000 2030-01-19 13:05:00 2030-01-19 13:05:12
      358       7        4    13.800000 2030-01-19 13:05:13 2030-01-19 13:05:27
      359       8        4    15.100000 2030-01-19 13:05:29 2030-01-19 13:05:44
      360       6        3    11.800000 2030-01-19 13:05:45 2030-01-19 13:05:57
      361       5        3    13.200000 2030-01-19 13:00:22 2030-01-19 13:00:35
      362       4        2     6.300000 2030-01-19 13:05:58 2030-01-19 13:06:04
      363       5        2     9.100000 2030-01-19 13:06:06 2030-01-19 13:06:15
      364       5        3     9.200000 2030-01-19 13:06:15 2030-01-19 13:06:25
      365       5        2     7.300000 2030-01-19 13:06:25 2030-01-19 13:06:33
      366       5        3    10.000000 2030-01-19 13:06:34 2030-01-19 13:06:44
      367       5        2     9.500000 2030-01-19 13:06:46 2030-01-19 13:06:55
      368       3        2     6.400000 2030-01-19 13:06:58 2030-01-19 13:07:04
      369       2        1     3.300000 2030-01-19 13:07:06 2030-01-19 13:07:09
      370       2        1     2.600000 2030-01-19 13:08:31 2030-01-19 13:08:34
      371       3        2     4.300000 2030-01-19 13:08:34 2030-01-19 13:08:39
      372       6        3    10.700000 2030-01-19 13:00:38 2030-01-19 13:00:48
      373       3        1     3.900000 2030-01-19 13:08:41 2030-01-19 13:08:45
      374       3        2     4.400000 2030-01-19 13:08:45 2030-01-19 13:08:50
      375       6        3    10.300000 2030-01-19 13:08:52 2030-01-19 13:09:02
      376       4        2     8.371129 2030-01-19 13:09:03 2030-01-19 13:09:11
      377       1        0     0.000000 2030-01-19 13:09:14 2030-01-19 13:09:14
      378       4        2     9.000000 2030-01-19 13:09:17 2030-01-19 13:09:26
      379       5        3     8.531805 2030-01-19 13:09:27 2030-01-19 13:09:36
      380       2        1     1.083719 2030-01-19 13:09:39 2030-01-19 13:09:40
      381       6        3    10.700000 2030-01-19 13:09:41 2030-01-19 13:09:52
      382       3        1     4.300000 2030-01-19 13:09:53 2030-01-19 13:09:57
      383       1        1     0.000000 2030-01-19 13:10:00 2030-01-19 13:10:00
      384       2        1     2.285660 2030-01-19 13:10:03 2030-01-19 13:10:05
      385       4        2     7.027679 2030-01-19 13:10:07 2030-01-19 13:10:14
      386       1        0     0.000000 2030-01-19 13:10:17 2030-01-19 13:10:17
      387       3        1     6.700000 2030-01-19 13:00:49 2030-01-19 13:00:56
      388       4        2     6.200000 2030-01-19 13:10:20 2030-01-19 13:10:26
      389       4        2     6.200000 2030-01-19 13:10:28 2030-01-19 13:10:34
      390       5        3     9.800000 2030-01-19 13:10:34 2030-01-19 13:10:44
      391       2        1     1.152861 2030-01-19 13:10:46 2030-01-19 13:10:47
      392       3        1     4.214407 2030-01-19 13:10:51 2030-01-19 13:10:55
      393       5        3    10.300000 2030-01-19 13:10:58 2030-01-19 13:11:08
      394       6        3    10.800000 2030-01-19 13:11:10 2030-01-19 13:11:21
      395       5        2     9.300000 2030-01-19 13:11:23 2030-01-19 13:11:32
      396       3        2     4.335341 2030-01-19 13:11:35 2030-01-19 13:11:39
      397       2        1     2.343490 2030-01-19 13:11:43 2030-01-19 13:11:45
      398       3        1     6.900000 2030-01-19 13:11:48 2030-01-19 13:11:55
      399       2        1     1.800000 2030-01-19 13:11:57 2030-01-19 13:11:59
      400       5        3    10.100000 2030-01-19 13:00:57 2030-01-19 13:01:07
      401       6        3    11.900000 2030-01-19 13:12:01 2030-01-19 13:12:13
      402       2        1     3.300000 2030-01-19 13:12:16 2030-01-19 13:12:19
      403       1        1     0.800000 2030-01-19 13:12:20 2030-01-19 13:12:21
      404       1        1     0.000000 2030-01-19 13:13:44 2030-01-19 13:13:44
      405       1        0     0.000000 2030-01-19 13:13:47 2030-01-19 13:13:47
      406       8        4    12.400000 2030-01-19 13:13:50 2030-01-19 13:14:02
      407       5        3     9.600000 2030-01-19 13:14:05 2030-01-19 13:14:15
      408       4        2     5.700000 2030-01-19 13:14:16 2030-01-19 13:14:21
      409       5        2     8.600000 2030-01-19 13:14:22 2030-01-19 13:14:30
      410       5        3    10.000000 2030-01-19 13:14:31 2030-01-19 13:14:41
      411       5        2     7.700000 2030-01-19 13:14:44 2030-01-19 13:14:51
      412       5        2     9.900000 2030-01-19 13:01:08 2030-01-19 13:01:17
      413       4        2     6.800000 2030-01-19 13:14:53 2030-01-19 13:15:00
      414       7        4    14.200000 2030-01-19 13:15:02 2030-01-19 13:15:17
      415       2        1     2.787739 2030-01-19 13:15:18 2030-01-19 13:15:21
      416       5        2     7.023891 2030-01-19 13:15:24 2030-01-19 13:15:32
      417       5        3     7.800000 2030-01-19 13:15:33 2030-01-19 13:15:41
      418       3        1     3.000000 2030-01-19 13:15:42 2030-01-19 13:15:45
      419       5        3     9.500000 2030-01-19 13:15:46 2030-01-19 13:15:55
      420       3        1     4.200000 2030-01-19 13:15:56 2030-01-19 13:16:01
      421       2        1     3.300000 2030-01-19 13:16:01 2030-01-19 13:16:05
      422       6        3    10.200000 2030-01-19 13:16:06 2030-01-19 13:16:17
      423       1        1     0.000000 2030-01-19 13:16:18 2030-01-19 13:16:18
      424       4        2     7.579179 2030-01-19 13:16:21 2030-01-19 13:16:28
      425       1        0     0.000000 2030-01-19 13:16:32 2030-01-19 13:16:32
      426       2        1     1.900000 2030-01-19 13:01:19 2030-01-19 13:01:21
      427       4        2     5.800000 2030-01-19 13:16:35 2030-01-19 13:16:41
      428       7        4    11.600000 2030-01-19 13:16:41 2030-01-19 13:16:53
      429       4        2     6.900000 2030-01-19 13:16:55 2030-01-19 13:17:02
      430       3        1     3.800000 2030-01-19 13:17:03 2030-01-19 13:17:07
      431       1        1     0.000000 2030-01-19 13:17:10 2030-01-19 13:17:10
      432       2        1     1.673456 2030-01-19 13:17:13 2030-01-19 13:17:15
      433       2        1     2.286322 2030-01-19 13:17:18 2030-01-19 13:17:21
      434       2        1     3.004808 2030-01-19 13:17:23 2030-01-19 13:17:26
      435       2        1     3.304498 2030-01-19 13:17:30 2030-01-19 13:17:33
      436       5        2     9.800000 2030-01-19 13:17:34 2030-01-19 13:17:44
      437       2        1     4.100000 2030-01-19 13:18:59 2030-01-19 13:19:03
      438       4        2     7.200000 2030-01-19 13:19:04 2030-01-19 13:19:11
      439       5        3     9.100000 2030-01-19 13:19:14 2030-01-19 13:19:23
      440       4        2     9.200000 2030-01-19 13:01:24 2030-01-19 13:01:33
      441       5        2     7.400000 2030-01-19 13:19:23 2030-01-19 13:19:31
      442       4        2     5.700000 2030-01-19 13:19:31 2030-01-19 13:19:37
      443       3        2     2.900000 2030-01-19 13:19:38 2030-01-19 13:19:41
      444       4        2     8.400000 2030-01-19 13:19:43 2030-01-19 13:19:52
      445       4        2     8.100000 2030-01-19 13:19:54 2030-01-19 13:20:02
      446       3        1     4.400000 2030-01-19 13:20:04 2030-01-19 13:20:08
      447       5        3     8.700000 2030-01-19 13:20:09 2030-01-19 13:20:18
      448       7        3    15.100000 2030-01-19 13:20:18 2030-01-19 13:20:33
      449       5        3     8.500000 2030-01-19 13:20:36 2030-01-19 13:20:44
      450       5        2     8.200000 2030-01-19 13:20:45 2030-01-19 13:20:53
      451       3        2     6.400000 2030-01-26 18:00:00 2030-01-26 18:00:06
      452       5        3     7.600000 2030-01-26 18:01:17 2030-01-26 18:01:24
      453       4        2     6.800000 2030-01-26 18:01:25 2030-01-26 18:01:32
      454       6        3    13.900000 2030-01-26 18:01:33 2030-01-26 18:01:47
      455       5        2     7.700000 2030-01-26 18:01:49 2030-01-26 18:01:57
      456       2        1     2.600000 2030-01-26 18:01:58 2030-01-26 18:02:01
      457       4        2     6.300000 2030-01-26 18:02:02 2030-01-26 18:02:08
      458       5        3     8.800000 2030-01-26 18:03:13 2030-01-26 18:03:22
      459       2        1     1.326308 2030-01-26 18:03:25 2030-01-26 18:03:26
      460       2        1     2.665057 2030-01-26 18:03:28 2030-01-26 18:03:31
      461       1        0     0.000000 2030-01-26 18:03:34 2030-01-26 18:03:34
      462       3        2     5.000000 2030-01-26 18:03:37 2030-01-26 18:03:42
      463       6        3     9.200000 2030-01-26 18:03:45 2030-01-26 18:03:54
      464       3        1     6.200000 2030-01-26 18:00:07 2030-01-26 18:00:13
      465       2        1     3.600000 2030-01-26 18:03:56 2030-01-26 18:04:00
      466       5        2     8.100000 2030-01-26 18:04:01 2030-01-26 18:04:09
      467       3        2     4.900000 2030-01-26 18:04:10 2030-01-26 18:04:15
      468       4        2     7.900000 2030-01-26 18:04:16 2030-01-26 18:04:24
      469       2        1     1.645228 2030-01-26 18:04:27 2030-01-26 18:04:29
      470       2        1     3.050684 2030-01-26 18:04:32 2030-01-26 18:04:35
      471       2        1     1.866643 2030-01-26 18:04:37 2030-01-26 18:04:39
      472       2        1     2.961670 2030-01-26 18:04:42 2030-01-26 18:04:45
      473       2        1     1.511286 2030-01-26 18:04:47 2030-01-26 18:04:48
      474       1        0     0.000000 2030-01-26 18:04:51 2030-01-26 18:04:51
      475       1        1     0.000000 2030-01-26 18:04:54 2030-01-26 18:04:54
      476       2        1     1.126685 2030-01-26 18:04:57 2030-01-26 18:04:58
      477       2        1     1.799658 2030-01-26 18:05:00 2030-01-26 18:05:02
      478       2        1     4.000000 2030-01-26 18:05:05 2030-01-26 18:05:09
      479       2        1     2.939333 2030-01-26 18:05:09 2030-01-26 18:05:12
      480       2        1     2.465312 2030-01-26 18:05:15 2030-01-26 18:05:18
      481       3        2     4.700000 2030-01-26 18:00:14 2030-01-26 18:00:18
      482       5        2     7.900000 2030-01-26 18:05:19 2030-01-26 18:05:27
      483       3        2     3.203179 2030-01-26 18:05:27 2030-01-26 18:05:31
      484       2        1     1.834683 2030-01-26 18:05:33 2030-01-26 18:05:35
      485       2        1     3.075218 2030-01-26 18:05:37 2030-01-26 18:05:41
      486       2        1     1.467582 2030-01-26 18:05:43 2030-01-26 18:05:45
      487       2        1     1.700939 2030-01-26 18:05:47 2030-01-26 18:05:49
      488       2        1     1.541591 2030-01-26 18:05:51 2030-01-26 18:05:53
      489       4        2     5.421024 2030-01-26 18:05:54 2030-01-26 18:05:59
      490       1        0     0.000000 2030-01-26 18:06:02 2030-01-26 18:06:02
      491       4        2     7.900000 2030-01-26 18:06:04 2030-01-26 18:06:12
      492       3        2     3.872504 2030-01-26 18:06:13 2030-01-26 18:06:17
      493       2        1     2.235141 2030-01-26 18:06:20 2030-01-26 18:06:22
      494       1        0     0.000000 2030-01-26 18:06:24 2030-01-26 18:06:24
      495       3        2     3.636357 2030-01-26 18:06:26 2030-01-26 18:06:30
      496       1        0     0.000000 2030-01-26 18:06:32 2030-01-26 18:06:32
      497       3        2     3.100000 2030-01-26 18:06:35 2030-01-26 18:06:38
      498       2        1     1.481775 2030-01-26 18:06:39 2030-01-26 18:06:41
      499       2        1     1.818270 2030-01-26 18:06:44 2030-01-26 18:06:46
      500       7        3    12.100000 2030-01-26 18:00:20 2030-01-26 18:00:32
      501       4        2     3.990304 2030-01-26 18:06:47 2030-01-26 18:06:51
      502       1        0     0.000000 2030-01-26 18:06:54 2030-01-26 18:06:54
      503       1        1     0.000000 2030-01-26 18:08:16 2030-01-26 18:08:16
      504       4        2     4.215260 2030-01-26 18:08:20 2030-01-26 18:08:24
      505       2        1     2.100000 2030-01-26 18:08:27 2030-01-26 18:08:29
      506       5        2     8.600000 2030-01-26 18:08:31 2030-01-26 18:08:40
      507       3        2     3.100000 2030-01-26 18:08:41 2030-01-26 18:08:45
      508       4        2     7.400000 2030-01-26 18:08:45 2030-01-26 18:08:52
      509       3        1     5.700000 2030-01-26 18:08:54 2030-01-26 18:08:59
      510       2        1     2.100000 2030-01-26 18:09:01 2030-01-26 18:09:04
      511       4        2     9.300000 2030-01-26 18:09:05 2030-01-26 18:09:14
      512       1        1     0.000000 2030-01-26 18:09:15 2030-01-26 18:09:15
      513       2        1     1.322973 2030-01-26 18:09:18 2030-01-26 18:09:20
      514       1        0     0.000000 2030-01-26 18:09:23 2030-01-26 18:09:23
      515       3        2     5.600000 2030-01-26 18:00:35 2030-01-26 18:00:40
      516       3        2     4.437952 2030-01-26 18:09:26 2030-01-26 18:09:30
      517       2        1     1.054193 2030-01-26 18:09:33 2030-01-26 18:09:34
      518       4        2     9.200000 2030-01-26 18:09:38 2030-01-26 18:09:47
      519       6        3    11.800000 2030-01-26 18:09:48 2030-01-26 18:10:00
      520       4        2     6.200000 2030-01-26 18:10:02 2030-01-26 18:10:08
      521       4        2     4.142363 2030-01-26 18:10:11 2030-01-26 18:10:15
      522       1        0     0.000000 2030-01-26 18:10:18 2030-01-26 18:10:18
      523       4        2     6.900000 2030-01-26 18:10:21 2030-01-26 18:10:28
      524       1        1     0.000000 2030-01-26 18:10:30 2030-01-26 18:10:30
      525       3        1     3.517130 2030-01-26 18:10:33 2030-01-26 18:10:37
      526       5        3     7.110513 2030-01-26 18:10:39 2030-01-26 18:10:46
      527       2        1     2.544097 2030-01-26 18:10:50 2030-01-26 18:10:52
      528       3        1     4.300000 2030-01-26 18:10:53 2030-01-26 18:10:58
      529       1        1     0.000000 2030-01-26 18:10:58 2030-01-26 18:10:58
      530       2        1     1.345915 2030-01-26 18:11:02 2030-01-26 18:11:03
      531       4        2     5.897689 2030-01-26 18:11:06 2030-01-26 18:11:12
      532       4        2     7.800000 2030-01-26 18:00:42 2030-01-26 18:00:50
      533       5        2     8.900000 2030-01-26 18:11:13 2030-01-26 18:11:22
      534       7        4    14.400000 2030-01-26 18:11:24 2030-01-26 18:11:38
      535       2        1     2.500000 2030-01-26 18:12:51 2030-01-26 18:12:54
      536       3        2     4.800000 2030-01-26 18:12:56 2030-01-26 18:13:01
      537       3        1     6.700000 2030-01-26 18:13:01 2030-01-26 18:13:08
      538       1        1     0.000000 2030-01-26 18:13:09 2030-01-26 18:13:09
      539       1        0     0.000000 2030-01-26 18:13:12 2030-01-26 18:13:12
      540       4        2     5.500000 2030-01-26 18:13:15 2030-01-26 18:13:20
      541       3        2     5.967961 2030-01-26 18:13:22 2030-01-26 18:13:28
      542       6        3    11.914043 2030-01-26 18:13:32 2030-01-26 18:13:43
      543       2        1     1.602714 2030-01-26 18:13:46 2030-01-26 18:13:48
      544       2        1     3.387677 2030-01-26 18:13:51 2030-01-26 18:13:54
      545       2        1     1.214537 2030-01-26 18:13:58 2030-01-26 18:13:59
      546       5        2    11.900000 2030-01-26 18:14:01 2030-01-26 18:14:13
      547       3        1     6.400000 2030-01-26 18:00:51 2030-01-26 18:00:57
      548       6        3    10.800000 2030-01-26 18:14:15 2030-01-26 18:14:26
      549       1        1     0.000000 2030-01-26 18:14:28 2030-01-26 18:14:28
      550       4        2     9.648526 2030-01-26 18:14:31 2030-01-26 18:14:41
      551       2        1     2.551962 2030-01-26 18:14:44 2030-01-26 18:14:47
      552       2        1     1.362956 2030-01-26 18:14:50 2030-01-26 18:14:51
      553       4        2     8.500000 2030-01-26 18:14:53 2030-01-26 18:15:02
      554       2        1     3.100000 2030-01-26 18:15:04 2030-01-26 18:15:07
      555       2        1     1.597798 2030-01-26 18:15:09 2030-01-26 18:15:10
      556       1        0     0.000000 2030-01-26 18:15:14 2030-01-26 18:15:14
      557       7        4    12.600000 2030-01-26 18:15:16 2030-01-26 18:15:29
      558       7        3    12.900000 2030-01-26 18:15:31 2030-01-26 18:15:44
      559       3        2     6.900000 2030-01-26 18:15:45 2030-01-26 18:15:52
      560       4        2     7.100000 2030-01-26 18:15:54 2030-01-26 18:16:01
      561       5        3     9.500000 2030-01-26 18:00:58 2030-01-26 18:01:08
      562       2        1     1.380843 2030-01-26 18:16:03 2030-01-26 18:16:04
      563       4        2     7.649650 2030-01-26 18:16:07 2030-01-26 18:16:15
      564       6        3    12.000000 2030-01-26 18:17:37 2030-01-26 18:17:49
      565       2        1     2.900000 2030-01-26 18:17:52 2030-01-26 18:17:55
      566       8        4    15.900000 2030-01-26 18:17:56 2030-01-26 18:18:12
      567       6        3    11.500000 2030-01-26 18:18:13 2030-01-26 18:18:24
      568       2        1     2.600000 2030-01-26 18:18:26 2030-01-26 18:18:29
      569       2        1     2.800000 2030-01-26 18:18:31 2030-01-26 18:18:34
      570       2        1     4.200000 2030-01-26 18:18:35 2030-01-26 18:18:39
      571       5        3     7.600000 2030-01-26 18:18:41 2030-01-26 18:18:49
      572       3        1     3.700000 2030-01-26 18:18:49 2030-01-26 18:18:53
      573       3        1     5.700000 2030-01-26 18:01:09 2030-01-26 18:01:14
      574       4        2     5.400000 2030-01-26 18:18:55 2030-01-26 18:19:00
      575       4        2     9.900000 2030-01-26 18:19:02 2030-01-26 18:19:12
      576       2        1     1.800000 2030-01-26 18:19:14 2030-01-26 18:19:15
      577       3        2     6.700000 2030-01-26 18:19:18 2030-01-26 18:19:24
      578       5        2    10.200000 2030-01-26 18:19:26 2030-01-26 18:19:36
      579       2        1     3.800000 2030-01-26 18:19:36 2030-01-26 18:19:40
      580       1        1     0.500000 2030-01-26 18:19:41 2030-01-26 18:19:41
      581       5        3     8.800000 2030-02-02 14:00:00 2030-02-02 14:00:08
      582       3        1     4.700000 2030-02-02 14:01:33 2030-02-02 14:01:37
      583       4        2    10.000000 2030-02-02 14:19:26 2030-02-02 14:19:36
      584       4        2     6.300000 2030-02-02 14:19:39 2030-02-02 14:19:45
      585       4        2     8.700000 2030-02-02 14:19:48 2030-02-02 14:19:56
      586       5        3     9.300000 2030-02-02 14:19:57 2030-02-02 14:20:06
      587       2        1     3.100000 2030-02-02 14:20:07 2030-02-02 14:20:10
      588       8        4    15.000000 2030-02-02 14:20:13 2030-02-02 14:20:28
      589       6        3    11.800000 2030-02-02 14:20:29 2030-02-02 14:20:41
      590       4        2    10.400000 2030-02-02 14:20:43 2030-02-02 14:20:53
      591       3        1     3.600000 2030-02-02 14:20:55 2030-02-02 14:20:59
      592       7        4    12.400000 2030-02-02 14:21:00 2030-02-02 14:21:12
      593       8        4    16.300000 2030-02-02 14:01:38 2030-02-02 14:01:54
      594       2        1     3.600000 2030-02-02 14:21:14 2030-02-02 14:21:18
      595       2        1     2.900000 2030-02-02 14:01:55 2030-02-02 14:01:58
      596       3        2     3.900000 2030-02-02 14:02:01 2030-02-02 14:02:04
      597       5        2     8.800000 2030-02-02 14:02:06 2030-02-02 14:02:15
      598       8        4    15.500000 2030-02-02 14:02:16 2030-02-02 14:02:31
      599       3        2     6.300000 2030-02-02 14:02:33 2030-02-02 14:02:39
      600       3        2     3.931573 2030-02-02 14:03:58 2030-02-02 14:04:02
      601       1        0     0.000000 2030-02-02 14:04:05 2030-02-02 14:04:05
      602       1        1     0.000000 2030-02-02 14:04:06 2030-02-02 14:04:06
      603       2        1     1.762615 2030-02-02 14:04:08 2030-02-02 14:04:10
      604       1        0     0.000000 2030-02-02 14:04:13 2030-02-02 14:04:13
      605       1        1     0.000000 2030-02-02 14:04:15 2030-02-02 14:04:15
      606       3        1     3.125866 2030-02-02 14:04:17 2030-02-02 14:04:20
      607       2        1     3.300000 2030-02-02 14:00:08 2030-02-02 14:00:12
      608       3        2     4.300000 2030-02-02 14:04:23 2030-02-02 14:04:27
      609       4        2     6.554116 2030-02-02 14:04:29 2030-02-02 14:04:35
      610       2        1     3.496854 2030-02-02 14:04:38 2030-02-02 14:04:41
      611       1        0     0.000000 2030-02-02 14:04:45 2030-02-02 14:04:45
      612       3        2     4.300000 2030-02-02 14:04:46 2030-02-02 14:04:50
      613       3        1     5.200000 2030-02-02 14:04:51 2030-02-02 14:04:56
      614       3        2     2.800000 2030-02-02 14:04:58 2030-02-02 14:05:01
      615       2        1     1.651119 2030-02-02 14:05:01 2030-02-02 14:05:02
      616       2        1     1.295846 2030-02-02 14:05:05 2030-02-02 14:05:06
      617       2        1     1.848299 2030-02-02 14:05:09 2030-02-02 14:05:10
      618       2        1     1.322136 2030-02-02 14:05:13 2030-02-02 14:05:14
      619       5        2     6.000000 2030-02-02 14:05:18 2030-02-02 14:05:24
      620       1        1     0.000000 2030-02-02 14:05:26 2030-02-02 14:05:26
      621       2        1     2.702145 2030-02-02 14:05:28 2030-02-02 14:05:31
      622       2        1     1.900000 2030-02-02 14:05:34 2030-02-02 14:05:35
      623       5        2     9.600000 2030-02-02 14:00:14 2030-02-02 14:00:23
      624       3        1     5.600000 2030-02-02 14:05:37 2030-02-02 14:05:43
      625       3        2     3.027706 2030-02-02 14:05:45 2030-02-02 14:05:48
      626       1        0     0.000000 2030-02-02 14:05:50 2030-02-02 14:05:50
      627       1        1     0.000000 2030-02-02 14:05:53 2030-02-02 14:05:53
      628       2        1     1.629629 2030-02-02 14:05:55 2030-02-02 14:05:57
      629       3        1     3.894083 2030-02-02 14:06:00 2030-02-02 14:06:04
      630       1        1     0.000000 2030-02-02 14:06:07 2030-02-02 14:06:07
      631       1        0     0.000000 2030-02-02 14:06:10 2030-02-02 14:06:10
      632       2        1     2.200000 2030-02-02 14:06:13 2030-02-02 14:06:16
      633       1        1     0.000000 2030-02-02 14:06:17 2030-02-02 14:06:17
      634       3        1     4.624533 2030-02-02 14:06:19 2030-02-02 14:06:23
      635       5        3     8.200000 2030-02-02 14:06:25 2030-02-02 14:06:33
      636       2        1     2.090508 2030-02-02 14:06:34 2030-02-02 14:06:36
      637       2        1     2.635558 2030-02-02 14:06:39 2030-02-02 14:06:41
      638       1        0     0.000000 2030-02-02 14:06:44 2030-02-02 14:06:44
      639       3        2     5.091355 2030-02-02 14:06:47 2030-02-02 14:06:52
      640       1        0     0.000000 2030-02-02 14:06:54 2030-02-02 14:06:54
      641       5        3     8.100000 2030-02-02 14:06:57 2030-02-02 14:07:05
      642       7        4    11.300000 2030-02-02 14:00:24 2030-02-02 14:00:35
      643       2        1     2.700000 2030-02-02 14:08:26 2030-02-02 14:08:28
      644       1        1     0.000000 2030-02-02 14:08:31 2030-02-02 14:08:31
      645       2        1     2.957451 2030-02-02 14:08:34 2030-02-02 14:08:37
      646       2        1     1.599659 2030-02-02 14:08:40 2030-02-02 14:08:42
      647       7        3    15.400000 2030-02-02 14:08:44 2030-02-02 14:08:59
      648       7        4    13.100000 2030-02-02 14:09:00 2030-02-02 14:09:13
      649       2        1     2.300000 2030-02-02 14:09:15 2030-02-02 14:09:17
      650       4        2     6.500000 2030-02-02 14:09:19 2030-02-02 14:09:25
      651       7        3    10.800000 2030-02-02 14:09:28 2030-02-02 14:09:39
      652       5        3    10.900000 2030-02-02 14:09:40 2030-02-02 14:09:51
      653       3        1     4.500000 2030-02-02 14:09:52 2030-02-02 14:09:56
      654       1        1     0.000000 2030-02-02 14:09:58 2030-02-02 14:09:58
      655       2        1     3.062090 2030-02-02 14:10:02 2030-02-02 14:10:05
      656       9        4    18.100000 2030-02-02 14:00:38 2030-02-02 14:00:56
      657       6        3    11.500000 2030-02-02 14:10:06 2030-02-02 14:10:18
      658       3        1     5.100000 2030-02-02 14:10:18 2030-02-02 14:10:23
      659       2        1     2.500000 2030-02-02 14:10:23 2030-02-02 14:10:26
      660       1        1     0.000000 2030-02-02 14:10:28 2030-02-02 14:10:28
      661       2        1     2.349558 2030-02-02 14:10:32 2030-02-02 14:10:34
      662       1        0     0.000000 2030-02-02 14:10:37 2030-02-02 14:10:37
      663       5        3     8.600000 2030-02-02 14:10:40 2030-02-02 14:10:49
      664       7        3    14.000000 2030-02-02 14:10:50 2030-02-02 14:11:04
      665       1        1     0.000000 2030-02-02 14:11:07 2030-02-02 14:11:07
      666       1        0     0.000000 2030-02-02 14:11:10 2030-02-02 14:11:10
      667       2        1     1.900000 2030-02-02 14:11:13 2030-02-02 14:11:15
      668       4        2     7.400000 2030-02-02 14:11:15 2030-02-02 14:11:23
      669       1        1     0.000000 2030-02-02 14:11:24 2030-02-02 14:11:24
      670       8        4    13.612740 2030-02-02 14:11:28 2030-02-02 14:11:42
      671       2        1     3.900000 2030-02-02 14:00:58 2030-02-02 14:01:02
      672       5        2    10.000000 2030-02-02 14:11:43 2030-02-02 14:11:53
      673       3        2     5.500000 2030-02-02 14:11:54 2030-02-02 14:11:59
      674       2        1     3.800000 2030-02-02 14:12:00 2030-02-02 14:12:04
      675       3        1     6.200000 2030-02-02 14:12:06 2030-02-02 14:12:13
      676       2        1     3.200000 2030-02-02 14:12:14 2030-02-02 14:12:17
      677       5        3     8.800000 2030-02-02 14:12:18 2030-02-02 14:12:27
      678       2        1     3.000000 2030-02-02 14:12:28 2030-02-02 14:12:31
      679       2        1     3.900000 2030-02-02 14:12:33 2030-02-02 14:12:37
      680       3        1     6.400000 2030-02-02 14:12:39 2030-02-02 14:12:46
      681      10        5    18.300000 2030-02-02 14:12:47 2030-02-02 14:13:06
      682       5        3    10.300000 2030-02-02 14:01:05 2030-02-02 14:01:15
      683       3        2     6.000000 2030-02-02 14:13:08 2030-02-02 14:13:14
      684       1        1     0.300000 2030-02-02 14:14:01 2030-02-02 14:14:02
      685       5        2     9.100000 2030-02-02 14:14:04 2030-02-02 14:14:13
      686       3        2     5.000000 2030-02-02 14:14:15 2030-02-02 14:14:20
      687       2        1     1.320247 2030-02-02 14:14:22 2030-02-02 14:14:24
      688       3        1     4.811336 2030-02-02 14:14:27 2030-02-02 14:14:32
      689       1        1     0.000000 2030-02-02 14:14:35 2030-02-02 14:14:35
      690       4        2     7.799438 2030-02-02 14:14:38 2030-02-02 14:14:46
      691       3        1     3.700000 2030-02-02 14:14:48 2030-02-02 14:14:51
      692       2        1     3.300000 2030-02-02 14:14:54 2030-02-02 14:14:57
      693       4        2     7.500000 2030-02-02 14:14:58 2030-02-02 14:15:06
      694       3        2     6.100000 2030-02-02 14:15:09 2030-02-02 14:15:15
      695       6        3    10.600000 2030-02-02 14:01:17 2030-02-02 14:01:27
      696       2        1     2.500000 2030-02-02 14:15:17 2030-02-02 14:15:20
      697       2        1     2.203844 2030-02-02 14:15:21 2030-02-02 14:15:23
      698       3        1     2.814854 2030-02-02 14:15:26 2030-02-02 14:15:29
      699       5        3    10.000000 2030-02-02 14:15:32 2030-02-02 14:15:42
      700       2        1     2.833405 2030-02-02 14:15:44 2030-02-02 14:15:47
      701       2        1     3.440753 2030-02-02 14:15:50 2030-02-02 14:15:53
      702       1        0     0.000000 2030-02-02 14:15:57 2030-02-02 14:15:57
      703       6        3    11.900000 2030-02-02 14:15:59 2030-02-02 14:16:11
      704       4        2     7.500000 2030-02-02 14:16:11 2030-02-02 14:16:18
      705       1        1     0.000000 2030-02-02 14:16:20 2030-02-02 14:16:20
      706       4        2     9.231564 2030-02-02 14:16:23 2030-02-02 14:16:32
      707       5        2     9.200000 2030-02-02 14:16:33 2030-02-02 14:16:43
      708       4        2     5.400000 2030-02-02 14:16:44 2030-02-02 14:16:50
      709       4        2     7.500000 2030-02-02 14:16:51 2030-02-02 14:16:59
      710       2        1     2.900000 2030-02-02 14:01:28 2030-02-02 14:01:31
      711       4        2     5.900000 2030-02-02 14:16:59 2030-02-02 14:17:05
      712       6        3    11.400000 2030-02-02 14:17:06 2030-02-02 14:17:17
      713       2        1     3.500000 2030-02-02 14:17:19 2030-02-02 14:17:23
      714       1        1     0.000000 2030-02-02 14:17:24 2030-02-02 14:17:24
      715       1        0     0.000000 2030-02-02 14:17:28 2030-02-02 14:17:28
      716       5        3     8.400000 2030-02-02 14:17:31 2030-02-02 14:17:39
      717       6        3     8.900000 2030-02-02 14:17:40 2030-02-02 14:17:49
      718       4        2     8.300000 2030-02-02 14:17:50 2030-02-02 14:17:58
      719       2        1     1.800000 2030-02-02 14:18:59 2030-02-02 14:19:00
      720       4        2     8.700000 2030-02-02 14:19:02 2030-02-02 14:19:11
      721       6        3    12.300000 2030-02-02 14:19:13 2030-02-02 14:19:25
      722       5        3     8.500000 2030-02-09 09:00:00 2030-02-09 09:00:08
      723       5        3     9.400000 2030-02-09 09:01:44 2030-02-09 09:01:53
      724       4        2     4.700000 2030-02-09 09:21:26 2030-02-09 09:21:30
      725       5        2    11.700000 2030-02-09 09:21:33 2030-02-09 09:21:44
      726       2        1     3.100000 2030-02-09 09:21:47 2030-02-09 09:21:50
      727       2        1     3.600000 2030-02-09 09:21:51 2030-02-09 09:21:55
      728       2        1     3.600000 2030-02-09 09:21:56 2030-02-09 09:22:00
      729       4        2     7.400000 2030-02-09 09:22:02 2030-02-09 09:22:10
      730       7        4    14.700000 2030-02-09 09:22:12 2030-02-09 09:22:27
      731       5        2     7.600000 2030-02-09 09:22:29 2030-02-09 09:22:36
      732       3        1     5.100000 2030-02-09 09:01:55 2030-02-09 09:02:00
      733       7        4    13.700000 2030-02-09 09:02:00 2030-02-09 09:02:14
      734       5        2     8.300000 2030-02-09 09:02:15 2030-02-09 09:02:24
      735       8        4    14.900000 2030-02-09 09:02:25 2030-02-09 09:02:40
      736       2        1     3.300000 2030-02-09 09:02:41 2030-02-09 09:02:44
      737       3        2     5.700000 2030-02-09 09:02:45 2030-02-09 09:02:50
      738       2        1     3.900000 2030-02-09 09:02:53 2030-02-09 09:02:57
      739       1        1     0.500000 2030-02-09 09:04:11 2030-02-09 09:04:11
      740       2        1     2.645939 2030-02-09 09:04:13 2030-02-09 09:04:15
      741       2        1     3.137116 2030-02-09 09:04:18 2030-02-09 09:04:21
      742       2        1     1.259329 2030-02-09 09:04:24 2030-02-09 09:04:25
      743       1        0     0.000000 2030-02-09 09:04:28 2030-02-09 09:04:28
      744       3        1     5.000000 2030-02-09 09:00:10 2030-02-09 09:00:15
      745       1        1     0.000000 2030-02-09 09:04:30 2030-02-09 09:04:30
      746       2        1     1.846103 2030-02-09 09:04:33 2030-02-09 09:04:35
      747       1        0     0.000000 2030-02-09 09:04:37 2030-02-09 09:04:37
      748       1        1     0.000000 2030-02-09 09:04:40 2030-02-09 09:04:40
      749       1        0     0.000000 2030-02-09 09:04:43 2030-02-09 09:04:43
      750       1        1     0.000000 2030-02-09 09:04:44 2030-02-09 09:04:44
      751       2        1     1.452163 2030-02-09 09:04:47 2030-02-09 09:04:48
      752       2        1     2.643573 2030-02-09 09:04:50 2030-02-09 09:04:53
      753       1        0     0.000000 2030-02-09 09:04:55 2030-02-09 09:04:55
      754       1        1     0.000000 2030-02-09 09:04:57 2030-02-09 09:04:57
      755       4        2     5.280738 2030-02-09 09:05:00 2030-02-09 09:05:05
      756       2        1     1.102731 2030-02-09 09:05:08 2030-02-09 09:05:09
      757       4        2     5.236358 2030-02-09 09:05:12 2030-02-09 09:05:17
      758       2        1     1.404465 2030-02-09 09:05:20 2030-02-09 09:05:22
      759       2        1     1.909155 2030-02-09 09:05:25 2030-02-09 09:05:27
      760       1        0     0.000000 2030-02-09 09:05:29 2030-02-09 09:05:29
      761       1        1     0.000000 2030-02-09 09:05:32 2030-02-09 09:05:32
      762       6        3    10.759091 2030-02-09 09:05:35 2030-02-09 09:05:46
      763       2        1     2.122969 2030-02-09 09:05:48 2030-02-09 09:05:50
      764       2        1     1.740249 2030-02-09 09:05:53 2030-02-09 09:05:54
      765       1        0     0.000000 2030-02-09 09:05:57 2030-02-09 09:05:57
      766       1        1     0.000000 2030-02-09 09:05:59 2030-02-09 09:05:59
      767       2        1     2.698250 2030-02-09 09:06:02 2030-02-09 09:06:05
      768       2        1     2.931502 2030-02-09 09:06:06 2030-02-09 09:06:09
      769       1        0     0.000000 2030-02-09 09:06:11 2030-02-09 09:06:11
      770       5        3    11.100000 2030-02-09 09:00:16 2030-02-09 09:00:27
      771       1        1     0.000000 2030-02-09 09:06:14 2030-02-09 09:06:14
      772       4        2     5.650673 2030-02-09 09:06:17 2030-02-09 09:06:22
      773       2        1     3.303230 2030-02-09 09:06:24 2030-02-09 09:06:28
      774       2        1     2.941113 2030-02-09 09:06:31 2030-02-09 09:06:34
      775       3        1     3.216690 2030-02-09 09:06:37 2030-02-09 09:06:40
      776       3        2     4.392993 2030-02-09 09:06:43 2030-02-09 09:06:47
      777       1        0     0.000000 2030-02-09 09:06:50 2030-02-09 09:06:50
      778       1        1     0.000000 2030-02-09 09:06:52 2030-02-09 09:06:52
      779       1        0     0.000000 2030-02-09 09:06:54 2030-02-09 09:06:54
      780       1        1     0.000000 2030-02-09 09:06:56 2030-02-09 09:06:56
      781       1        0     0.000000 2030-02-09 09:06:59 2030-02-09 09:06:59
      782       1        1     0.000000 2030-02-09 09:07:02 2030-02-09 09:07:02
      783       2        1     3.395570 2030-02-09 09:07:05 2030-02-09 09:07:08
      784       2        1     1.128194 2030-02-09 09:07:10 2030-02-09 09:07:11
      785       2        1     1.328106 2030-02-09 09:07:15 2030-02-09 09:07:16
      786       2        1     3.428358 2030-02-09 09:07:19 2030-02-09 09:07:22
      787       2        1     2.414083 2030-02-09 09:07:25 2030-02-09 09:07:27
      788       6        3    12.600000 2030-02-09 09:07:30 2030-02-09 09:07:43
      789       2        1     1.017270 2030-02-09 09:07:44 2030-02-09 09:07:45
      790       2        1     2.354024 2030-02-09 09:07:48 2030-02-09 09:07:50
      791       2        1     2.566914 2030-02-09 09:07:53 2030-02-09 09:07:56
      792       1        0     0.000000 2030-02-09 09:07:59 2030-02-09 09:07:59
      793       1        1     0.000000 2030-02-09 09:08:02 2030-02-09 09:08:02
      794       4        2     5.299435 2030-02-09 09:08:04 2030-02-09 09:08:09
      795       2        1     4.100000 2030-02-09 09:00:27 2030-02-09 09:00:31
      796       2        1     3.004417 2030-02-09 09:08:13 2030-02-09 09:08:16
      797       1        0     0.000000 2030-02-09 09:08:19 2030-02-09 09:08:19
      798       1        1     0.500000 2030-02-09 09:09:40 2030-02-09 09:09:41
      799       5        2     9.500000 2030-02-09 09:09:42 2030-02-09 09:09:52
      800       2        1     1.800000 2030-02-09 09:09:53 2030-02-09 09:09:54
      801       1        1     0.000000 2030-02-09 09:09:55 2030-02-09 09:09:55
      802       2        1     3.371938 2030-02-09 09:09:58 2030-02-09 09:10:02
      803       2        1     3.393739 2030-02-09 09:10:04 2030-02-09 09:10:07
      804       3        1     4.085392 2030-02-09 09:10:11 2030-02-09 09:10:15
      805       2        1     3.100000 2030-02-09 09:10:18 2030-02-09 09:10:21
      806       4        2     6.000000 2030-02-09 09:10:24 2030-02-09 09:10:30
      807       1        1     0.000000 2030-02-09 09:10:31 2030-02-09 09:10:31
      808       5        2     9.504447 2030-02-09 09:10:34 2030-02-09 09:10:44
      809       1        1     0.000000 2030-02-09 09:10:47 2030-02-09 09:10:47
      810       1        0     0.000000 2030-02-09 09:10:50 2030-02-09 09:10:50
      811       5        2     9.700000 2030-02-09 09:00:33 2030-02-09 09:00:43
      812       5        3     9.700000 2030-02-09 09:10:53 2030-02-09 09:11:03
      813       2        1     2.478796 2030-02-09 09:11:05 2030-02-09 09:11:08
      814       3        1     4.572445 2030-02-09 09:11:11 2030-02-09 09:11:16
      815       3        2     6.600000 2030-02-09 09:11:17 2030-02-09 09:11:23
      816       2        1     1.966287 2030-02-09 09:11:24 2030-02-09 09:11:26
      817       2        1     2.824788 2030-02-09 09:11:29 2030-02-09 09:11:32
      818       1        0     0.000000 2030-02-09 09:11:35 2030-02-09 09:11:35
      819       2        1     1.800000 2030-02-09 09:11:39 2030-02-09 09:11:41
      820       1        1     0.000000 2030-02-09 09:11:41 2030-02-09 09:11:41
      821       1        0     0.000000 2030-02-09 09:11:45 2030-02-09 09:11:45
      822       3        2     2.668557 2030-02-09 09:11:47 2030-02-09 09:11:50
      823       4        2     5.217882 2030-02-09 09:11:53 2030-02-09 09:11:58
      824       5        2     9.700000 2030-02-09 09:12:00 2030-02-09 09:12:10
      825       3        2     4.000000 2030-02-09 09:12:11 2030-02-09 09:12:15
      826       6        3    10.700000 2030-02-09 09:12:16 2030-02-09 09:12:27
      827       8        4    16.000000 2030-02-09 09:00:45 2030-02-09 09:01:01
      828       4        2     6.300000 2030-02-09 09:12:29 2030-02-09 09:12:36
      829       6        3    11.600000 2030-02-09 09:12:37 2030-02-09 09:12:48
      830       4        2     7.100000 2030-02-09 09:12:49 2030-02-09 09:12:56
      831       4        2     7.700000 2030-02-09 09:12:58 2030-02-09 09:13:05
      832       3        1     5.500000 2030-02-09 09:13:07 2030-02-09 09:13:12
      833       3        2     4.200608 2030-02-09 09:13:13 2030-02-09 09:13:17
      834       1        0     0.000000 2030-02-09 09:13:20 2030-02-09 09:13:20
      835       5        3     9.700000 2030-02-09 09:13:21 2030-02-09 09:13:31
      836       4        2     9.700000 2030-02-09 09:13:33 2030-02-09 09:13:42
      837       1        0     0.600000 2030-02-09 09:13:44 2030-02-09 09:13:44
      838       3        2     4.600000 2030-02-09 09:15:07 2030-02-09 09:15:12
      839       6        3    13.500000 2030-02-09 09:01:03 2030-02-09 09:01:16
      840       2        1     1.500000 2030-02-09 09:15:15 2030-02-09 09:15:16
      841       4        2     9.500000 2030-02-09 09:15:19 2030-02-09 09:15:28
      842       6        3    11.200000 2030-02-09 09:15:28 2030-02-09 09:15:39
      843       6        3    12.800000 2030-02-09 09:15:41 2030-02-09 09:15:53
      844       2        1     2.500000 2030-02-09 09:15:56 2030-02-09 09:15:58
      845       4        2     7.700000 2030-02-09 09:15:59 2030-02-09 09:16:06
      846       5        2     9.400000 2030-02-09 09:16:09 2030-02-09 09:16:19
      847       3        2     4.800000 2030-02-09 09:16:21 2030-02-09 09:16:26
      848       8        4    17.100000 2030-02-09 09:16:28 2030-02-09 09:16:45
      849       5        2     8.800000 2030-02-09 09:16:46 2030-02-09 09:16:55
      850       6        3     8.800000 2030-02-09 09:01:19 2030-02-09 09:01:27
      851       7        4    13.100000 2030-02-09 09:16:58 2030-02-09 09:17:11
      852       2        1     2.000000 2030-02-09 09:17:13 2030-02-09 09:17:15
      853       2        1     2.600000 2030-02-09 09:17:17 2030-02-09 09:17:19
      854       5        2     8.700000 2030-02-09 09:17:21 2030-02-09 09:17:29
      855       6        3    10.600000 2030-02-09 09:17:32 2030-02-09 09:17:42
      856       5        3     8.700000 2030-02-09 09:17:44 2030-02-09 09:17:53
      857       3        1     5.100000 2030-02-09 09:17:54 2030-02-09 09:17:59
      858       6        3    10.600000 2030-02-09 09:18:00 2030-02-09 09:18:11
      859       1        1     0.000000 2030-02-09 09:18:13 2030-02-09 09:18:13
      860       4        2     8.897214 2030-02-09 09:18:16 2030-02-09 09:18:25
      861       5        2     7.900000 2030-02-09 09:18:27 2030-02-09 09:18:35
      862       8        4    14.000000 2030-02-09 09:01:29 2030-02-09 09:01:43
      863       1        1     0.000000 2030-02-09 09:18:35 2030-02-09 09:18:35
      864       3        1     3.209775 2030-02-09 09:18:38 2030-02-09 09:18:41
      865       4        2     6.900000 2030-02-09 09:19:55 2030-02-09 09:20:02
      866       6        3    14.700000 2030-02-09 09:20:03 2030-02-09 09:20:17
      867       4        2     7.800000 2030-02-09 09:20:19 2030-02-09 09:20:26
      868       5        3     8.800000 2030-02-09 09:20:27 2030-02-09 09:20:36
      869       7        3    16.000000 2030-02-09 09:20:38 2030-02-09 09:20:54
      870       5        3     7.800000 2030-02-09 09:20:55 2030-02-09 09:21:03
      871       2        1     4.400000 2030-02-09 09:21:04 2030-02-09 09:21:08
      872       4        2     5.500000 2030-02-09 09:21:09 2030-02-09 09:21:15
      873       4        2     9.800000 2030-02-09 09:21:15 2030-02-09 09:21:25
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
      188  65.25890
      189  59.33115
      190  69.20179
      191  65.50030
      192  71.29394
      193  70.16740
      194  58.25825
      195  42.00388
      196  40.79687
      197  41.89659
      198  42.64762
      199  45.30303
      200        NA
      201  83.04215
      202  75.47823
      203  61.31601
      204  56.64891
      205  67.59245
      206  42.88902
      207  74.75403
      208        NA
      209  87.38738
      210  58.58012
      211  85.45617
      212  84.81243
      213  76.92664
      214  70.32833
      215  79.01879
      216  61.47694
      217  86.74364
      218  78.80421
      219  70.97207
      220        NA
      221  82.72028
      222  84.97336
      223  68.71899
      224  64.37376
      225  69.52366
      226  45.38350
      227  87.54831
      228  79.34066
      229  85.13430
      230  63.24722
      231        NA
      232  81.27187
      233  84.32963
      234  72.90328
      235  58.25825
      236  59.54573
      237  81.43281
      238        NA
      239  59.86760
      240  63.89096
      241  72.58141
      242  62.12068
      243  81.75468
      244        NA
      245  80.52084
      246  76.76571
      247  44.57883
      248  79.76982
      249        NA
      250  71.85721
      251  95.43410
      252  81.91561
      253  88.99672
      254  77.08758
      255  72.42048
      256  73.22515
      257  76.04150
      258  99.29652
      259  77.57038
      260  88.51392
      261  84.08822
      262  43.77416
      263  82.23748
      264  84.73196
      265  92.21541
      266  84.89290
      267  68.39712
      268  82.55935
      269  73.86889
      270  70.16740
      271  81.43281
      272  89.10401
      273        NA
      274  86.74364
      275  69.68460
      276  74.43216
      277  91.08887
      278  65.82217
      279  34.84230
      280  84.49056
      281  65.66124
      282  85.37570
      283  84.65149
      284  72.58141
      285  82.47888
      286  93.02008
      287  72.17908
      288  90.60607
      289  64.21283
      290  66.14404
      291  84.32963
      292  37.65865
      293  63.24722
      294  77.24851
      295  83.04215
      296  84.00776
      297  76.28291
      298  82.72028
      299  74.91496
      300  78.69692
      301  75.63917
      302  70.81114
      303  81.91561
      304  91.89354
      305  71.13300
      306  43.29135
      307  93.02008
      308        NA
      309  67.59245
      310  79.98440
      311  83.60542
      312  74.02982
      313  65.82217
      314  80.78907
      315  82.68005
      316  91.41074
      317  82.82757
      318  85.61710
      319  92.21541
      320  84.00776
      321  88.83579
      322        NA
      323  33.47436
      324  66.06357
      325  80.06486
      326  65.33937
      327  67.99478
      328  68.39712
      329  69.20179
      330  77.78496
      331  59.54573
      332  65.50030
      333  84.97336
      334  45.50420
      335  40.23360
      336  84.86607
      337  72.36684
      338  80.06486
      339  68.12890
      340  81.27187
      341  44.09603
      342  42.00388
      343  43.37182
      344  48.03892
      345  47.47565
      346  44.20332
      347  42.80855
      348  48.54854
      349  37.90005
      350  46.51004
      351  38.62426
      352  61.47694
      353  67.43151
      354  80.52084
      355  70.11375
      356  62.76442
      357  71.53534
      358  65.37960
      359  74.71380
      360  77.73132
      361  44.68612
      362  77.24851
      363  81.99608
      364  77.78496
      365  65.98310
      366  71.02572
      367  69.44319
      368  79.09926
      369  72.09861
      370  78.21412
      371  78.77739
      372  45.86630
      373  70.16740
      374  96.23877
      375  82.18383
      376  87.22644
      377        NA
      378  73.14468
      379  88.88943
      380  77.73132
      381  84.38327
      382  80.30627
      383  90.12326
      384  76.28291
      385  81.75468
      386        NA
      387  42.80855
      388  83.92729
      389  71.05254
      390  85.45617
      391  67.75338
      392  90.76700
      393  68.02161
      394  74.67356
      395  69.76506
      396  80.54767
      397  86.09990
      398  80.46720
      399  76.12197
      400  41.03827
      401  88.62121
      402  98.16998
      403  87.38738
      404  71.61581
      405        NA
      406  76.72548
      407  72.09861
      408  72.50095
      409  77.24851
      410  69.09450
      411  79.09926
      412  37.65865
      413  79.26019
      414  81.03047
      415  92.69821
      416  71.69628
      417  74.61992
      418  84.32963
      419  66.78778
      420  71.45487
      421  63.24722
      422  86.74364
      423  84.81243
      424  76.20244
      425        NA
      426  41.19921
      427  83.60542
      428  78.45552
      429  79.58206
      430  65.33937
      431  64.69563
      432  62.44255
      433  80.78907
      434  81.11094
      435  69.36273
      436  67.19011
      437  78.53599
      438  70.81114
      439  70.86478
      440  45.54444
      441  64.13236
      442  86.50224
      443  73.30562
      444  71.29394
      445  84.24916
      446  69.52366
      447  75.15636
      448  73.92253
      449  76.65842
      450  58.49965
      451  48.03892
      452  48.97770
      453  35.48604
      454  41.14556
      455  38.70472
      456  37.33678
      457  37.65865
      458  72.68870
      459  81.27187
      460  84.65149
      461        NA
      462  80.78907
      463  76.28291
      464  36.85398
      465  74.99543
      466  80.22580
      467  74.83450
      468  73.70796
      469  77.89225
      470  77.40945
      471  58.90199
      472  61.47694
      473  74.99543
      474        NA
      475  83.52495
      476  59.70666
      477  72.09861
      478  64.69563
      479  86.26084
      480  77.89225
      481  35.24463
      482  76.04150
      483  84.65149
      484  61.15507
      485  64.37376
      486  72.25955
      487  56.80984
      488  71.29394
      489  68.07525
      490        NA
      491  72.90328
      492  68.07525
      493  73.86889
      494        NA
      495  66.94871
      496        NA
      497  80.06486
      498  70.65020
      499  80.62813
      500  39.58986
      501  66.14404
      502        NA
      503  75.15636
      504  82.47888
      505  95.11223
      506  74.67356
      507  77.48991
      508  69.12132
      509  84.49056
      510  71.13300
      511  92.45681
      512  85.45617
      513  89.15766
      514        NA
      515  40.79687
      516  93.58335
      517  92.69821
      518  83.60542
      519  82.98851
      520  77.81178
      521  83.04215
      522        NA
      523  81.99608
      524  82.23748
      525  66.30497
      526  86.04626
      527  88.67485
      528  73.06422
      529  94.79036
      530  95.59503
      531  83.04215
      532  45.94677
      533  79.90393
      534  73.66772
      535  82.39841
      536  73.86889
      537  62.92535
      538  77.89225
      539        NA
      540  81.67421
      541  83.04215
      542  84.97336
      543  69.68460
      544  70.48927
      545  87.54831
      546  77.08758
      547  33.63529
      548  81.70103
      549  63.08628
      550  79.50159
      551  86.74364
      552  62.44255
      553  71.61581
      554  76.28291
      555  72.42048
      556        NA
      557  71.45487
      558  79.39430
      559  81.75468
      560  83.28355
      561  42.37939
      562  65.33937
      563  72.25955
      564  70.22104
      565  67.75338
      566  72.25955
      567  76.87300
      568  61.31601
      569  68.87992
      570  67.75338
      571  77.83860
      572  59.54573
      573  40.07267
      574  73.30562
      575  64.37376
      576  74.67356
      577  81.91561
      578  67.27058
      579  57.45358
      580  65.33937
      581  44.79341
      582  44.73976
      583  81.91561
      584  71.61581
      585  70.65020
      586  79.23337
      587  77.24851
      588  67.67292
      589  72.42048
      590  64.21283
      591  78.21412
      592  68.19595
      593  45.58467
      594  70.97207
      595  44.25696
      596  37.81958
      597  44.73976
      598  45.86630
      599  41.11874
      600  58.66059
      601        NA
      602  70.48927
      603  56.80984
      604        NA
      605  77.57038
      606  65.01750
      607  39.10706
      608  62.60348
      609  76.36337
      610  82.88122
      611        NA
      612  76.76571
      613  87.06551
      614  69.36273
      615  65.66124
      616  56.48797
      617  73.86889
      618  67.43151
      619  61.07460
      620  81.43281
      621  70.16740
      622  59.54573
      623  44.17649
      624  75.96104
      625  70.00646
      626        NA
      627  74.19076
      628  86.58271
      629  67.59245
      630  80.46720
      631        NA
      632  84.49056
      633  69.52366
      634  81.27187
      635  76.81935
      636  61.63788
      637  84.00776
      638        NA
      639  66.46591
      640        NA
      641  77.73132
      642  43.93509
      643  79.82346
      644  77.89225
      645  89.47953
      646  77.89225
      647  71.13300
      648  88.03112
      649  70.48927
      650  67.10964
      651  70.91843
      652  88.24570
      653  79.98440
      654  81.43281
      655  89.15766
      656  41.92341
      657  77.19487
      658  69.36273
      659  67.91432
      660  91.08887
      661  72.09861
      662        NA
      663  84.81243
      664  80.89636
      665  76.60477
      666        NA
      667  78.53599
      668  81.83514
      669  74.19076
      670  80.18556
      671  44.73976
      672  83.04215
      673  88.83579
      674  98.97466
      675  98.81372
      676  75.15636
      677  78.32141
      678  79.50159
      679  66.14404
      680  75.15636
      681  85.48835
      682  44.63247
      683  91.00840
      684  75.47823
      685  78.45552
      686  77.40945
      687  78.69692
      688  88.99672
      689  64.21283
      690  77.24851
      691  83.36402
      692  76.76571
      693  69.60413
      694  81.35234
      695  44.57883
      696  67.10964
      697  74.02982
      698  89.64046
      699  71.93768
      700  77.73132
      701  78.37505
      702        NA
      703  72.31319
      704  76.84618
      705  69.04086
      706  80.95000
      707  79.74300
      708  86.50224
      709  78.45552
      710  34.76183
      711  84.24916
      712  70.38198
      713  69.20179
      714  76.44384
      715        NA
      716  66.94871
      717  74.67356
      718  80.14533
      719  77.08758
      720  72.17908
      721  68.66534
      722  45.54444
      723  47.58294
      724  69.20179
      725  63.40815
      726  76.28291
      727  84.97336
      728  78.21412
      729  61.87928
      730  73.26539
      731  80.54767
      732  41.03827
      733  41.56131
      734  41.76248
      735  39.54963
      736  34.27903
      737  40.79687
      738  45.86630
      739  65.17843
      740  63.08628
      741  69.84553
      742  58.41919
      743        NA
      744  33.63529
      745  59.38479
      746  58.58012
      747        NA
      748  85.77804
      749        NA
      750  74.51263
      751  69.68460
      752  79.82346
      753        NA
      754  68.39712
      755  67.02918
      756  71.61581
      757  70.97207
      758  75.15636
      759  58.41919
      760        NA
      761  58.09732
      762  75.96104
      763  88.19205
      764  77.89225
      765        NA
      766  80.62813
      767  83.04215
      768  68.39712
      769        NA
      770  38.57061
      771  88.35299
      772  72.01814
      773  69.68460
      774  60.35040
      775  72.25955
      776  75.07590
      777        NA
      778  56.64891
      779        NA
      780  62.12068
      781        NA
      782  75.96104
      783  65.01750
      784  75.31730
      785  74.83450
      786  59.70666
      787  73.22515
      788  63.40815
      789  86.09990
      790  81.91561
      791  58.74106
      792        NA
      793  60.99414
      794  73.06422
      795  36.85398
      796  76.92664
      797        NA
      798  91.57167
      799  80.78907
      800  90.60607
      801  92.05448
      802  98.00905
      803  70.97207
      804  98.97466
      805  78.05318
      806  85.77804
      807  86.58271
      808  90.12326
      809  98.16998
      810        NA
      811  41.36014
      812  82.55935
      813  77.73132
      814  68.87992
      815  69.84553
      816  66.94871
      817  74.02982
      818        NA
      819  91.89354
      820  96.07784
      821        NA
      822  80.30627
      823  69.44319
      824  81.91561
      825  81.59374
      826  70.91843
      827  42.32575
      828  75.55870
      829  84.65149
      830  75.47823
      831  74.19076
      832  88.51392
      833  84.81243
      834        NA
      835  82.61299
      836  79.09926
      837        NA
      838  82.31795
      839  45.22257
      840  77.73132
      841  81.27187
      842  77.51674
      843  73.06422
      844  82.23748
      845  78.13365
      846  87.87018
      847  70.65020
      848  73.94936
      849  63.89096
      850  38.46332
      851  78.77739
      852  78.37505
      853  93.02008
      854  76.68524
      855  83.47131
      856  71.66945
      857  82.23748
      858  77.99954
      859  73.38609
      860  73.46655
      861  72.98375
      862  43.29135
      863  79.66253
      864  73.06422
      865  73.30562
      866  69.25544
      867  76.92664
      868  75.31730
      869  69.09450
      870  76.87300
      871  60.83320
      872  63.00582
      873  77.81178

# segment_session_shots() on one match's shots is stable

    Code
      as.data.frame(segs)
    Output
        segment_index               regime          start_time            end_time
      1             1                  gap 2030-01-05 16:00:00 2030-01-05 16:02:52
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

