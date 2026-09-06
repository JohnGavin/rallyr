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
      3    9000001      100           net_volley                 2             5
      4    9000001      101           net_volley                 2             5
      5    9000001      102           net_volley                 2             5
      6    9000001      103           net_volley                 2             5
      7    9000001      104           net_volley                 2             5
      8    9000001      105           net_volley                 2             5
      9    9000001      106           net_volley                 2             5
      10   9000001      107           net_volley                 2             5
      11   9000001      108           net_volley                 2             5
      12   9000001      109           net_volley                 2             5
      13   9000001       11          mini_tennis                 1             1
      14   9000001      110           net_volley                 2             5
      15   9000001      111           net_volley                 2             5
      16   9000001      112           net_volley                 2             5
      17   9000001      113           net_volley                 2             5
      18   9000001      114           net_volley                 2             5
      19   9000001      115           net_volley                 2             5
      20   9000001      116           net_volley                 2             5
      21   9000001       12          mini_tennis                 1             1
      22   9000001       13          mini_tennis                 1             1
      23   9000001       14          mini_tennis                 1             1
      24   9000001       15          mini_tennis                 1             1
      25   9000001       16          mini_tennis                 1             1
      26   9000001       17          mini_tennis                 1             1
      27   9000001       18           net_volley                 1             2
      28   9000001       19           net_volley                 1             2
      29   9000001        2          mini_tennis                 1             1
      30   9000001       20           net_volley                 1             2
      31   9000001       21           net_volley                 1             2
      32   9000001       22           net_volley                 1             2
      33   9000001       23           net_volley                 1             2
      34   9000001       24           net_volley                 1             2
      35   9000001       25           net_volley                 1             2
      36   9000001       26           net_volley                 1             2
      37   9000001       27           net_volley                 1             2
      38   9000001       28           net_volley                 1             2
      39   9000001       29           net_volley                 1             2
      40   9000001        3          mini_tennis                 1             1
      41   9000001       30           net_volley                 1             2
      42   9000001       31           net_volley                 1             2
      43   9000001       32           net_volley                 1             2
      44   9000001       33           net_volley                 1             2
      45   9000001       34           net_volley                 1             2
      46   9000001       35           net_volley                 1             2
      47   9000001       36           net_volley                 1             2
      48   9000001       37           net_volley                 1             2
      49   9000001       38           net_volley                 1             2
      50   9000001       39           net_volley                 1             2
      51   9000001        4          mini_tennis                 1             1
      52   9000001       40           net_volley                 1             2
      53   9000001       41           net_volley                 1             2
      54   9000001       42           net_volley                 1             2
      55   9000001       43           net_volley                 1             2
      56   9000001       44 forehand_cross_court                 1             3
      57   9000001       45 forehand_cross_court                 1             3
      58   9000001       46 forehand_cross_court                 1             3
      59   9000001       47 forehand_cross_court                 1             3
      60   9000001       48 forehand_cross_court                 1             3
      61   9000001       49 forehand_cross_court                 1             3
      62   9000001        5          mini_tennis                 1             1
      63   9000001       50 forehand_cross_court                 1             3
      64   9000001       51 forehand_cross_court                 1             3
      65   9000001       52 forehand_cross_court                 1             3
      66   9000001       53 forehand_cross_court                 1             3
      67   9000001       54 forehand_cross_court                 1             3
      68   9000001       55 forehand_cross_court                 1             3
      69   9000001       56 forehand_cross_court                 1             3
      70   9000001       57 forehand_cross_court                 1             3
      71   9000001       58 forehand_cross_court                 1             3
      72   9000001       59 forehand_cross_court                 1             3
      73   9000001        6          mini_tennis                 1             1
      74   9000001       60 forehand_cross_court                 1             3
      75   9000001       61 forehand_cross_court                 1             3
      76   9000001       62 forehand_cross_court                 1             3
      77   9000001       63 forehand_cross_court                 1             3
      78   9000001       64 forehand_cross_court                 1             3
      79   9000001       65 forehand_cross_court                 1             3
      80   9000001       66 forehand_cross_court                 1             3
      81   9000001       67 forehand_cross_court                 1             3
      82   9000001       68 forehand_cross_court                 1             3
      83   9000001       69 forehand_cross_court                 1             3
      84   9000001        7          mini_tennis                 1             1
      85   9000001       70 backhand_cross_court                 1             4
      86   9000001       71 backhand_cross_court                 1             4
      87   9000001       72 backhand_cross_court                 1             4
      88   9000001       73 backhand_cross_court                 1             4
      89   9000001       74 backhand_cross_court                 1             4
      90   9000001       75 backhand_cross_court                 1             4
      91   9000001       76 backhand_cross_court                 1             4
      92   9000001       77 backhand_cross_court                 1             4
      93   9000001       78 backhand_cross_court                 1             4
      94   9000001       79 backhand_cross_court                 1             4
      95   9000001        8          mini_tennis                 1             1
      96   9000001       80 backhand_cross_court                 1             4
      97   9000001       81 backhand_cross_court                 1             4
      98   9000001       82 backhand_cross_court                 1             4
      99   9000001       83 backhand_cross_court                 1             4
      100  9000001       84 backhand_cross_court                 1             4
      101  9000001       85 backhand_cross_court                 1             4
      102  9000001       86 backhand_cross_court                 1             4
      103  9000001       87 backhand_cross_court                 1             4
      104  9000001       88 backhand_cross_court                 1             4
      105  9000001       89 backhand_cross_court                 1             4
      106  9000001        9          mini_tennis                 1             1
      107  9000001       90 backhand_cross_court                 1             4
      108  9000001       91 backhand_cross_court                 1             4
      109  9000001       92 backhand_cross_court                 1             4
      110  9000001       93 backhand_cross_court                 1             4
      111  9000001       94 backhand_cross_court                 1             4
      112  9000001       95 backhand_cross_court                 1             4
      113  9000001       96           net_volley                 2             5
      114  9000001       97           net_volley                 2             5
      115  9000001       98           net_volley                 2             5
      116  9000001       99           net_volley                 2             5
      117  9000002        1          mini_tennis                 1             1
      118  9000002       10          mini_tennis                 1             1
      119  9000002      100           net_volley                 2             7
      120  9000002      101           net_volley                 2             7
      121  9000002      102           net_volley                 2             7
      122  9000002      103           net_volley                 2             7
      123  9000002      104           net_volley                 2             7
      124  9000002      105           net_volley                 2             7
      125  9000002      106           net_volley                 2             7
      126  9000002       11          mini_tennis                 1             1
      127  9000002       12          mini_tennis                 1             1
      128  9000002       13          mini_tennis                 1             1
      129  9000002       14          mini_tennis                 1             1
      130  9000002       15          mini_tennis                 1             1
      131  9000002       16          mini_tennis                 1             1
      132  9000002       17           net_volley                 1             2
      133  9000002       18           net_volley                 1             2
      134  9000002       19           net_volley                 1             2
      135  9000002        2          mini_tennis                 1             1
      136  9000002       20           net_volley                 1             2
      137  9000002       21           net_volley                 1             2
      138  9000002       22           net_volley                 1             2
      139  9000002       23           net_volley                 1             2
      140  9000002       24           net_volley                 1             2
      141  9000002       25           net_volley                 1             2
      142  9000002       26           net_volley                 1             2
      143  9000002       27           net_volley                 1             2
      144  9000002       28           net_volley                 1             2
      145  9000002       29           net_volley                 1             2
      146  9000002        3          mini_tennis                 1             1
      147  9000002       30           net_volley                 1             2
      148  9000002       31           net_volley                 1             2
      149  9000002       32           net_volley                 1             2
      150  9000002       33           net_volley                 1             2
      151  9000002       34           net_volley                 1             2
      152  9000002       35           net_volley                 1             2
      153  9000002       36           net_volley                 1             2
      154  9000002       37           net_volley                 1             2
      155  9000002       38           net_volley                 1             2
      156  9000002       39                  gap                 1             3
      157  9000002        4          mini_tennis                 1             1
      158  9000002       40 forehand_cross_court                 1             4
      159  9000002       41 forehand_cross_court                 1             4
      160  9000002       42 forehand_cross_court                 1             4
      161  9000002       43 forehand_cross_court                 1             4
      162  9000002       44 forehand_cross_court                 1             4
      163  9000002       45 forehand_cross_court                 1             4
      164  9000002       46 forehand_cross_court                 1             4
      165  9000002       47 forehand_cross_court                 1             4
      166  9000002       48 forehand_cross_court                 1             4
      167  9000002       49 forehand_cross_court                 1             4
      168  9000002        5          mini_tennis                 1             1
      169  9000002       50 forehand_cross_court                 1             4
      170  9000002       51 forehand_cross_court                 1             4
      171  9000002       52 forehand_cross_court                 1             4
      172  9000002       53 forehand_cross_court                 1             4
      173  9000002       54 forehand_cross_court                 1             4
      174  9000002       55 forehand_cross_court                 1             4
      175  9000002       56 forehand_cross_court                 1             4
      176  9000002       57 forehand_cross_court                 1             4
      177  9000002       58 forehand_cross_court                 1             4
      178  9000002       59 forehand_cross_court                 1             4
      179  9000002        6          mini_tennis                 1             1
      180  9000002       60 forehand_cross_court                 1             4
      181  9000002       61 forehand_cross_court                 1             4
      182  9000002       62 forehand_cross_court                 1             4
      183  9000002       63 forehand_cross_court                 1             4
      184  9000002       64 forehand_cross_court                 1             4
      185  9000002       65                mixed                 1             5
      186  9000002       66                mixed                 1             5
      187  9000002       67                mixed                 1             5
      188  9000002       68 backhand_cross_court                 1             6
      189  9000002       69 backhand_cross_court                 1             6
      190  9000002        7          mini_tennis                 1             1
      191  9000002       70 backhand_cross_court                 1             6
      192  9000002       71 backhand_cross_court                 1             6
      193  9000002       72 backhand_cross_court                 1             6
      194  9000002       73 backhand_cross_court                 1             6
      195  9000002       74 backhand_cross_court                 1             6
      196  9000002       75 backhand_cross_court                 1             6
      197  9000002       76 backhand_cross_court                 1             6
      198  9000002       77 backhand_cross_court                 1             6
      199  9000002       78 backhand_cross_court                 1             6
      200  9000002       79 backhand_cross_court                 1             6
      201  9000002        8          mini_tennis                 1             1
      202  9000002       80 backhand_cross_court                 1             6
      203  9000002       81 backhand_cross_court                 1             6
      204  9000002       82 backhand_cross_court                 1             6
      205  9000002       83 backhand_cross_court                 1             6
      206  9000002       84 backhand_cross_court                 1             6
      207  9000002       85 backhand_cross_court                 1             6
      208  9000002       86 backhand_cross_court                 1             6
      209  9000002       87 backhand_cross_court                 1             6
      210  9000002       88 backhand_cross_court                 1             6
      211  9000002       89 backhand_cross_court                 1             6
      212  9000002        9          mini_tennis                 1             1
      213  9000002       90           net_volley                 2             7
      214  9000002       91           net_volley                 2             7
      215  9000002       92           net_volley                 2             7
      216  9000002       93           net_volley                 2             7
      217  9000002       94           net_volley                 2             7
      218  9000002       95           net_volley                 2             7
      219  9000002       96           net_volley                 2             7
      220  9000002       97           net_volley                 2             7
      221  9000002       98           net_volley                 2             7
      222  9000002       99           net_volley                 2             7
      223  9000003        1          mini_tennis                 1             1
      224  9000003       10          mini_tennis                 1             1
      225  9000003      100           net_volley                 2             7
      226  9000003      101           net_volley                 2             7
      227  9000003      102           net_volley                 2             7
      228  9000003      103           net_volley                 2             7
      229  9000003      104           net_volley                 2             7
      230  9000003       11          mini_tennis                 1             1
      231  9000003       12          mini_tennis                 1             1
      232  9000003       13          mini_tennis                 1             1
      233  9000003       14          mini_tennis                 1             1
      234  9000003       15          mini_tennis                 1             1
      235  9000003       16          mini_tennis                 1             1
      236  9000003       17          mini_tennis                 1             1
      237  9000003       18          mini_tennis                 1             1
      238  9000003       19          mini_tennis                 1             1
      239  9000003        2          mini_tennis                 1             1
      240  9000003       20                  gap                 1             2
      241  9000003       21           net_volley                 1             3
      242  9000003       22           net_volley                 1             3
      243  9000003       23           net_volley                 1             3
      244  9000003       24           net_volley                 1             3
      245  9000003       25           net_volley                 1             3
      246  9000003       26           net_volley                 1             3
      247  9000003       27           net_volley                 1             3
      248  9000003       28           net_volley                 1             3
      249  9000003       29           net_volley                 1             3
      250  9000003        3          mini_tennis                 1             1
      251  9000003       30           net_volley                 1             3
      252  9000003       31           net_volley                 1             3
      253  9000003       32           net_volley                 1             3
      254  9000003       33           net_volley                 1             3
      255  9000003       34           net_volley                 1             3
      256  9000003       35           net_volley                 1             3
      257  9000003       36           net_volley                 1             3
      258  9000003       37           net_volley                 1             3
      259  9000003       38 forehand_cross_court                 1             4
      260  9000003       39 forehand_cross_court                 1             4
      261  9000003        4          mini_tennis                 1             1
      262  9000003       40 forehand_cross_court                 1             4
      263  9000003       41 forehand_cross_court                 1             4
      264  9000003       42 forehand_cross_court                 1             4
      265  9000003       43 forehand_cross_court                 1             4
      266  9000003       44 forehand_cross_court                 1             4
      267  9000003       45 forehand_cross_court                 1             4
      268  9000003       46 forehand_cross_court                 1             4
      269  9000003       47 forehand_cross_court                 1             4
      270  9000003       48 forehand_cross_court                 1             4
      271  9000003       49 forehand_cross_court                 1             4
      272  9000003        5          mini_tennis                 1             1
      273  9000003       50 forehand_cross_court                 1             4
      274  9000003       51 forehand_cross_court                 1             4
      275  9000003       52 forehand_cross_court                 1             4
      276  9000003       53 forehand_cross_court                 1             4
      277  9000003       54 forehand_cross_court                 1             4
      278  9000003       55 forehand_cross_court                 1             4
      279  9000003       56 forehand_cross_court                 1             4
      280  9000003       57 forehand_cross_court                 1             4
      281  9000003       58 forehand_cross_court                 1             4
      282  9000003       59 forehand_cross_court                 1             4
      283  9000003        6          mini_tennis                 1             1
      284  9000003       60 forehand_cross_court                 1             4
      285  9000003       61 forehand_cross_court                 1             4
      286  9000003       62 forehand_cross_court                 1             4
      287  9000003       63 backhand_cross_court                 1             5
      288  9000003       64 backhand_cross_court                 1             5
      289  9000003       65 backhand_cross_court                 1             5
      290  9000003       66 backhand_cross_court                 1             5
      291  9000003       67 backhand_cross_court                 1             5
      292  9000003       68 backhand_cross_court                 1             5
      293  9000003       69 backhand_cross_court                 1             5
      294  9000003        7          mini_tennis                 1             1
      295  9000003       70 backhand_cross_court                 1             5
      296  9000003       71 backhand_cross_court                 1             5
      297  9000003       72 backhand_cross_court                 1             5
      298  9000003       73 backhand_cross_court                 1             5
      299  9000003       74 backhand_cross_court                 1             5
      300  9000003       75 backhand_cross_court                 1             5
      301  9000003       76 backhand_cross_court                 1             5
      302  9000003       77 backhand_cross_court                 1             5
      303  9000003       78 backhand_cross_court                 1             5
      304  9000003       79 backhand_cross_court                 1             5
      305  9000003        8          mini_tennis                 1             1
      306  9000003       80 backhand_cross_court                 1             5
      307  9000003       81 backhand_cross_court                 1             5
      308  9000003       82 backhand_cross_court                 1             5
      309  9000003       83 backhand_cross_court                 1             5
      310  9000003       84 backhand_cross_court                 1             5
      311  9000003       85 backhand_cross_court                 1             5
      312  9000003       86 backhand_cross_court                 1             5
      313  9000003       87                  gap                 2             6
      314  9000003       88           net_volley                 2             7
      315  9000003       89           net_volley                 2             7
      316  9000003        9          mini_tennis                 1             1
      317  9000003       90           net_volley                 2             7
      318  9000003       91           net_volley                 2             7
      319  9000003       92           net_volley                 2             7
      320  9000003       93           net_volley                 2             7
      321  9000003       94           net_volley                 2             7
      322  9000003       95           net_volley                 2             7
      323  9000003       96           net_volley                 2             7
      324  9000003       97           net_volley                 2             7
      325  9000003       98           net_volley                 2             7
      326  9000003       99           net_volley                 2             7
      327  9000004        1          mini_tennis                 1             1
      328  9000004       10          mini_tennis                 1             1
      329  9000004       11          mini_tennis                 1             1
      330  9000004       12          mini_tennis                 1             1
      331  9000004       13          mini_tennis                 1             1
      332  9000004       14          mini_tennis                 1             1
      333  9000004       15          mini_tennis                 1             1
      334  9000004       16           net_volley                 1             2
      335  9000004       17           net_volley                 1             2
      336  9000004       18           net_volley                 1             2
      337  9000004       19           net_volley                 1             2
      338  9000004        2          mini_tennis                 1             1
      339  9000004       20           net_volley                 1             2
      340  9000004       21           net_volley                 1             2
      341  9000004       22           net_volley                 1             2
      342  9000004       23           net_volley                 1             2
      343  9000004       24           net_volley                 1             2
      344  9000004       25           net_volley                 1             2
      345  9000004       26           net_volley                 1             2
      346  9000004       27           net_volley                 1             2
      347  9000004       28           net_volley                 1             2
      348  9000004       29           net_volley                 1             2
      349  9000004        3          mini_tennis                 1             1
      350  9000004       30           net_volley                 1             2
      351  9000004       31           net_volley                 1             2
      352  9000004       32           net_volley                 1             2
      353  9000004       33           net_volley                 1             2
      354  9000004       34           net_volley                 1             2
      355  9000004       35           net_volley                 1             2
      356  9000004       36           net_volley                 1             2
      357  9000004       37           net_volley                 1             2
      358  9000004       38           net_volley                 1             2
      359  9000004       39           net_volley                 1             2
      360  9000004        4          mini_tennis                 1             1
      361  9000004       40           net_volley                 1             2
      362  9000004       41 forehand_cross_court                 1             3
      363  9000004       42 forehand_cross_court                 1             3
      364  9000004       43 forehand_cross_court                 1             3
      365  9000004       44 forehand_cross_court                 1             3
      366  9000004       45 forehand_cross_court                 1             3
      367  9000004       46 forehand_cross_court                 1             3
      368  9000004       47 forehand_cross_court                 1             3
      369  9000004       48 forehand_cross_court                 1             3
      370  9000004       49 forehand_cross_court                 1             3
      371  9000004        5          mini_tennis                 1             1
      372  9000004       50 forehand_cross_court                 1             3
      373  9000004       51 forehand_cross_court                 1             3
      374  9000004       52 forehand_cross_court                 1             3
      375  9000004       53 forehand_cross_court                 1             3
      376  9000004       54 forehand_cross_court                 1             3
      377  9000004       55 forehand_cross_court                 1             3
      378  9000004       56 forehand_cross_court                 1             3
      379  9000004       57 forehand_cross_court                 1             3
      380  9000004       58 forehand_cross_court                 1             3
      381  9000004       59 forehand_cross_court                 1             3
      382  9000004        6          mini_tennis                 1             1
      383  9000004       60 forehand_cross_court                 1             3
      384  9000004       61 forehand_cross_court                 1             3
      385  9000004       62 backhand_cross_court                 1             4
      386  9000004       63 backhand_cross_court                 1             4
      387  9000004       64 backhand_cross_court                 1             4
      388  9000004       65 backhand_cross_court                 1             4
      389  9000004       66 backhand_cross_court                 1             4
      390  9000004       67 backhand_cross_court                 1             4
      391  9000004       68 backhand_cross_court                 1             4
      392  9000004       69 backhand_cross_court                 1             4
      393  9000004        7          mini_tennis                 1             1
      394  9000004       70 backhand_cross_court                 1             4
      395  9000004       71 backhand_cross_court                 1             4
      396  9000004       72 backhand_cross_court                 1             4
      397  9000004       73 backhand_cross_court                 1             4
      398  9000004       74 backhand_cross_court                 1             4
      399  9000004       75 backhand_cross_court                 1             4
      400  9000004       76 backhand_cross_court                 1             4
      401  9000004       77 backhand_cross_court                 1             4
      402  9000004       78 backhand_cross_court                 1             4
      403  9000004       79 backhand_cross_court                 1             4
      404  9000004        8          mini_tennis                 1             1
      405  9000004       80 backhand_cross_court                 1             4
      406  9000004       81           net_volley                 2             5
      407  9000004       82           net_volley                 2             5
      408  9000004       83           net_volley                 2             5
      409  9000004       84           net_volley                 2             5
      410  9000004       85           net_volley                 2             5
      411  9000004       86           net_volley                 2             5
      412  9000004       87           net_volley                 2             5
      413  9000004       88           net_volley                 2             5
      414  9000004       89           net_volley                 2             5
      415  9000004        9          mini_tennis                 1             1
      416  9000004       90           net_volley                 2             5
      417  9000004       91           net_volley                 2             5
      418  9000004       92           net_volley                 2             5
      419  9000004       93           net_volley                 2             5
      420  9000004       94           net_volley                 2             5
      421  9000004       95           net_volley                 2             5
      422  9000004       96           net_volley                 2             5
      423  9000005        1          mini_tennis                 1             1
      424  9000005       10          mini_tennis                 1             1
      425  9000005      100           net_volley                 2             8
      426  9000005      101           net_volley                 2             8
      427  9000005      102           net_volley                 2             8
      428  9000005      103           net_volley                 2             8
      429  9000005      104           net_volley                 2             8
      430  9000005      105           net_volley                 2             8
      431  9000005      106           net_volley                 2             8
      432  9000005      107           net_volley                 2             8
      433  9000005      108           net_volley                 2             8
      434  9000005      109           net_volley                 2             8
      435  9000005       11          mini_tennis                 1             1
      436  9000005      110           net_volley                 2             8
      437  9000005       12          mini_tennis                 1             1
      438  9000005       13          mini_tennis                 1             1
      439  9000005       14          mini_tennis                 1             1
      440  9000005       15          mini_tennis                 1             1
      441  9000005       16          mini_tennis                 1             1
      442  9000005       17           net_volley                 1             3
      443  9000005       18           net_volley                 1             3
      444  9000005       19           net_volley                 1             3
      445  9000005        2          mini_tennis                 1             1
      446  9000005       20           net_volley                 1             3
      447  9000005       21           net_volley                 1             3
      448  9000005       22           net_volley                 1             3
      449  9000005       23           net_volley                 1             3
      450  9000005       24           net_volley                 1             3
      451  9000005       25           net_volley                 1             3
      452  9000005       26           net_volley                 1             3
      453  9000005       27           net_volley                 1             3
      454  9000005       28           net_volley                 1             3
      455  9000005       29           net_volley                 1             3
      456  9000005        3          mini_tennis                 1             1
      457  9000005       30           net_volley                 1             3
      458  9000005       31           net_volley                 1             3
      459  9000005       32           net_volley                 1             3
      460  9000005       33           net_volley                 1             3
      461  9000005       34           net_volley                 1             3
      462  9000005       35           net_volley                 1             3
      463  9000005       36           net_volley                 1             3
      464  9000005       37           net_volley                 1             3
      465  9000005       38           net_volley                 1             3
      466  9000005       39                  gap                 2             4
      467  9000005        4          mini_tennis                 1             1
      468  9000005       40 forehand_cross_court                 1             5
      469  9000005       41 forehand_cross_court                 1             5
      470  9000005       42 forehand_cross_court                 1             5
      471  9000005       43 forehand_cross_court                 1             5
      472  9000005       44 forehand_cross_court                 1             5
      473  9000005       45 forehand_cross_court                 1             5
      474  9000005       46 forehand_cross_court                 1             5
      475  9000005       47 forehand_cross_court                 1             5
      476  9000005       48 forehand_cross_court                 1             5
      477  9000005       49 forehand_cross_court                 1             5
      478  9000005        5          mini_tennis                 1             1
      479  9000005       50 forehand_cross_court                 1             5
      480  9000005       51 forehand_cross_court                 1             5
      481  9000005       52 forehand_cross_court                 1             5
      482  9000005       53 forehand_cross_court                 1             5
      483  9000005       54 forehand_cross_court                 1             5
      484  9000005       55 forehand_cross_court                 1             5
      485  9000005       56 forehand_cross_court                 1             5
      486  9000005       57 forehand_cross_court                 1             5
      487  9000005       58 forehand_cross_court                 1             5
      488  9000005       59 forehand_cross_court                 1             5
      489  9000005        6          mini_tennis                 1             1
      490  9000005       60 forehand_cross_court                 1             5
      491  9000005       61 forehand_cross_court                 1             5
      492  9000005       62 forehand_cross_court                 1             5
      493  9000005       63 forehand_cross_court                 1             5
      494  9000005       64 forehand_cross_court                 1             5
      495  9000005       65 forehand_cross_court                 1             5
      496  9000005       66 forehand_cross_court                 1             5
      497  9000005       67 forehand_cross_court                 1             5
      498  9000005       68 forehand_cross_court                 1             5
      499  9000005       69 forehand_cross_court                 1             5
      500  9000005        7          mini_tennis                 1             1
      501  9000005       70 forehand_cross_court                 1             5
      502  9000005       71 backhand_cross_court                 1             6
      503  9000005       72 backhand_cross_court                 1             6
      504  9000005       73 backhand_cross_court                 1             6
      505  9000005       74 backhand_cross_court                 1             6
      506  9000005       75 backhand_cross_court                 1             6
      507  9000005       76 backhand_cross_court                 1             6
      508  9000005       77 backhand_cross_court                 1             6
      509  9000005       78 backhand_cross_court                 1             6
      510  9000005       79 backhand_cross_court                 1             6
      511  9000005        8          mini_tennis                 1             1
      512  9000005       80 backhand_cross_court                 1             6
      513  9000005       81 backhand_cross_court                 1             6
      514  9000005       82 backhand_cross_court                 1             6
      515  9000005       83 backhand_cross_court                 1             6
      516  9000005       84 backhand_cross_court                 1             6
      517  9000005       85 backhand_cross_court                 1             6
      518  9000005       86 backhand_cross_court                 1             6
      519  9000005       87 backhand_cross_court                 1             6
      520  9000005       88 backhand_cross_court                 1             6
      521  9000005       89 backhand_cross_court                 1             6
      522  9000005        9          mini_tennis                 1             1
      523  9000005       90 backhand_cross_court                 1             6
      524  9000005       91 backhand_cross_court                 1             6
      525  9000005       92 backhand_cross_court                 1             6
      526  9000005       93 backhand_cross_court                 1             6
      527  9000005       94 backhand_cross_court                 1             6
      528  9000005       95 backhand_cross_court                 1             6
      529  9000005       96 backhand_cross_court                 1             6
      530  9000005       97                  gap                 3             7
      531  9000005       98           net_volley                 2             8
      532  9000005       99           net_volley                 2             8
      533  9000006        1          mini_tennis                 1             1
      534  9000006       10          mini_tennis                 1             1
      535  9000006      100           net_volley                 2             6
      536  9000006      101           net_volley                 2             6
      537  9000006      102           net_volley                 2             6
      538  9000006      103           net_volley                 2             6
      539  9000006      104           net_volley                 2             6
      540  9000006      105           net_volley                 2             6
      541  9000006      106           net_volley                 2             6
      542  9000006      107           net_volley                 2             6
      543  9000006       11          mini_tennis                 1             1
      544  9000006       12          mini_tennis                 1             1
      545  9000006       13          mini_tennis                 1             1
      546  9000006       14          mini_tennis                 1             1
      547  9000006       15          mini_tennis                 1             1
      548  9000006       16          mini_tennis                 1             1
      549  9000006       17          mini_tennis                 1             1
      550  9000006       18           net_volley                 1             2
      551  9000006       19           net_volley                 1             2
      552  9000006        2          mini_tennis                 1             1
      553  9000006       20           net_volley                 1             2
      554  9000006       21           net_volley                 1             2
      555  9000006       22           net_volley                 1             2
      556  9000006       23           net_volley                 1             2
      557  9000006       24           net_volley                 1             2
      558  9000006       25           net_volley                 1             2
      559  9000006       26           net_volley                 1             2
      560  9000006       27           net_volley                 1             2
      561  9000006       28           net_volley                 1             2
      562  9000006       29           net_volley                 1             2
      563  9000006        3          mini_tennis                 1             1
      564  9000006       30           net_volley                 1             2
      565  9000006       31           net_volley                 1             2
      566  9000006       32           net_volley                 1             2
      567  9000006       33           net_volley                 1             2
      568  9000006       34           net_volley                 1             2
      569  9000006       35           net_volley                 1             2
      570  9000006       36           net_volley                 1             2
      571  9000006       37           net_volley                 1             2
      572  9000006       38           net_volley                 1             2
      573  9000006       39           net_volley                 1             2
      574  9000006        4          mini_tennis                 1             1
      575  9000006       40           net_volley                 1             2
      576  9000006       41 forehand_cross_court                 1             3
      577  9000006       42 forehand_cross_court                 1             3
      578  9000006       43 forehand_cross_court                 1             3
      579  9000006       44 forehand_cross_court                 1             3
      580  9000006       45 forehand_cross_court                 1             3
      581  9000006       46 forehand_cross_court                 1             3
      582  9000006       47 forehand_cross_court                 1             3
      583  9000006       48 forehand_cross_court                 1             3
      584  9000006       49 forehand_cross_court                 1             3
      585  9000006        5          mini_tennis                 1             1
      586  9000006       50 forehand_cross_court                 1             3
      587  9000006       51 forehand_cross_court                 1             3
      588  9000006       52 forehand_cross_court                 1             3
      589  9000006       53 forehand_cross_court                 1             3
      590  9000006       54 forehand_cross_court                 1             3
      591  9000006       55 forehand_cross_court                 1             3
      592  9000006       56 forehand_cross_court                 1             3
      593  9000006       57 forehand_cross_court                 1             3
      594  9000006       58 forehand_cross_court                 1             3
      595  9000006       59 forehand_cross_court                 1             3
      596  9000006        6          mini_tennis                 1             1
      597  9000006       60 forehand_cross_court                 1             3
      598  9000006       61 forehand_cross_court                 1             3
      599  9000006       62 forehand_cross_court                 1             3
      600  9000006       63 forehand_cross_court                 1             3
      601  9000006       64 forehand_cross_court                 1             3
      602  9000006       65 forehand_cross_court                 1             3
      603  9000006       66 forehand_cross_court                 1             3
      604  9000006       67 forehand_cross_court                 1             3
      605  9000006       68 forehand_cross_court                 1             3
      606  9000006       69 backhand_cross_court                 1             4
      607  9000006        7          mini_tennis                 1             1
      608  9000006       70 backhand_cross_court                 1             4
      609  9000006       71 backhand_cross_court                 1             4
      610  9000006       72 backhand_cross_court                 1             4
      611  9000006       73 backhand_cross_court                 1             4
      612  9000006       74 backhand_cross_court                 1             4
      613  9000006       75 backhand_cross_court                 1             4
      614  9000006       76 backhand_cross_court                 1             4
      615  9000006       77 backhand_cross_court                 1             4
      616  9000006       78 backhand_cross_court                 1             4
      617  9000006       79 backhand_cross_court                 1             4
      618  9000006        8          mini_tennis                 1             1
      619  9000006       80 backhand_cross_court                 1             4
      620  9000006       81 backhand_cross_court                 1             4
      621  9000006       82 backhand_cross_court                 1             4
      622  9000006       83 backhand_cross_court                 1             4
      623  9000006       84 backhand_cross_court                 1             4
      624  9000006       85 backhand_cross_court                 1             4
      625  9000006       86 backhand_cross_court                 1             4
      626  9000006       87 backhand_cross_court                 1             4
      627  9000006       88 backhand_cross_court                 1             4
      628  9000006       89 backhand_cross_court                 1             4
      629  9000006        9          mini_tennis                 1             1
      630  9000006       90 backhand_cross_court                 1             4
      631  9000006       91                  gap                 1             5
      632  9000006       92           net_volley                 2             6
      633  9000006       93           net_volley                 2             6
      634  9000006       94           net_volley                 2             6
      635  9000006       95           net_volley                 2             6
      636  9000006       96           net_volley                 2             6
      637  9000006       97           net_volley                 2             6
      638  9000006       98           net_volley                 2             6
      639  9000006       99           net_volley                 2             6
          n_shots duration_sec          start_time            end_time speed_kmh
      1         2          3.5 2030-01-05 16:00:00 2030-01-05 16:00:03  41.36014
      2         6         11.2 2030-01-05 16:01:40 2030-01-05 16:01:52  45.11528
      3         5         10.3 2030-01-05 16:20:19 2030-01-05 16:20:30  74.67356
      4         4          6.0 2030-01-05 16:20:32 2030-01-05 16:20:38  61.31601
      5         6         11.3 2030-01-05 16:20:41 2030-01-05 16:20:52  68.55805
      6         3          4.2 2030-01-05 16:20:55 2030-01-05 16:20:59  80.70860
      7         6         12.1 2030-01-05 16:21:02 2030-01-05 16:21:14  70.22104
      8         2          2.4 2030-01-05 16:21:15 2030-01-05 16:21:17  88.03112
      9         5         11.3 2030-01-05 16:21:19 2030-01-05 16:21:30  79.82346
      10        2          1.8 2030-01-05 16:21:31 2030-01-05 16:21:33  58.90199
      11        3          3.7 2030-01-05 16:21:36 2030-01-05 16:21:39  73.78842
      12        3          5.0 2030-01-05 16:21:41 2030-01-05 16:21:46  64.85656
      13        5          8.7 2030-01-05 16:01:54 2030-01-05 16:02:03  40.12631
      14        4          8.3 2030-01-05 16:21:47 2030-01-05 16:21:55  84.41009
      15        3          5.6 2030-01-05 16:21:56 2030-01-05 16:22:02  84.24916
      16        4          5.8 2030-01-05 16:22:04 2030-01-05 16:22:10  68.79946
      17        4          8.8 2030-01-05 16:22:13 2030-01-05 16:22:21  64.21283
      18        2          3.6 2030-01-05 16:22:23 2030-01-05 16:22:26  83.84682
      19        4          7.4 2030-01-05 16:22:28 2030-01-05 16:22:35  66.70731
      20        1          0.9 2030-01-05 16:22:37 2030-01-05 16:22:38        NA
      21        7         14.6 2030-01-05 16:02:04 2030-01-05 16:02:19  44.68612
      22        6          9.9 2030-01-05 16:02:22 2030-01-05 16:02:32  44.47154
      23        2          1.5 2030-01-05 16:02:33 2030-01-05 16:02:35  36.69304
      24        3          4.0 2030-01-05 16:02:36 2030-01-05 16:02:40  33.39389
      25        2          2.7 2030-01-05 16:02:41 2030-01-05 16:02:43  47.79752
      26        3          5.0 2030-01-05 16:02:46 2030-01-05 16:02:52  49.24593
      27        1          0.6 2030-01-05 16:03:40 2030-01-05 16:03:40  81.91561
      28        7         15.2 2030-01-05 16:03:42 2030-01-05 16:03:57  60.45769
      29        4          9.2 2030-01-05 16:00:05 2030-01-05 16:00:14  40.47500
      30        5          9.4 2030-01-05 16:03:59 2030-01-05 16:04:08  69.04086
      31        5         11.8 2030-01-05 16:04:11 2030-01-05 16:04:22  76.20244
      32        4          8.2 2030-01-05 16:04:24 2030-01-05 16:04:32  80.95000
      33        4          6.8 2030-01-05 16:04:34 2030-01-05 16:04:40  66.22451
      34        3          4.3 2030-01-05 16:04:41 2030-01-05 16:04:46  63.00582
      35        5         12.1 2030-01-05 16:04:49 2030-01-05 16:05:01  82.88122
      36        3          4.4 2030-01-05 16:05:02 2030-01-05 16:05:07  83.76636
      37        4          8.1 2030-01-05 16:05:08 2030-01-05 16:05:16  70.08693
      38        6         14.4 2030-01-05 16:05:18 2030-01-05 16:05:32  70.16740
      39        2          1.8 2030-01-05 16:05:34 2030-01-05 16:05:35  76.60477
      40        7         14.8 2030-01-05 16:00:16 2030-01-05 16:00:31  43.17065
      41        4          8.0 2030-01-05 16:05:38 2030-01-05 16:05:46  63.81049
      42        5         11.8 2030-01-05 16:05:49 2030-01-05 16:06:00  74.02982
      43        4          7.4 2030-01-05 16:06:03 2030-01-05 16:06:10  71.37441
      44        7         13.5 2030-01-05 16:06:12 2030-01-05 16:06:26  69.88576
      45        7         13.7 2030-01-05 16:06:26 2030-01-05 16:06:40  76.33655
      46        4          8.5 2030-01-05 16:06:41 2030-01-05 16:06:49  69.60413
      47        5          9.6 2030-01-05 16:06:50 2030-01-05 16:07:00  74.67356
      48        2          1.8 2030-01-05 16:07:00 2030-01-05 16:07:02  63.89096
      49        4          6.5 2030-01-05 16:07:04 2030-01-05 16:07:11  65.17843
      50        4          6.2 2030-01-05 16:07:11 2030-01-05 16:07:17  77.81178
      51        4          7.4 2030-01-05 16:00:31 2030-01-05 16:00:39  41.76248
      52        3          6.2 2030-01-05 16:07:20 2030-01-05 16:07:26  68.71899
      53        5         11.3 2030-01-05 16:07:29 2030-01-05 16:07:40  80.25262
      54        3          6.2 2030-01-05 16:07:43 2030-01-05 16:07:49  63.73002
      55        1          0.4 2030-01-05 16:07:50 2030-01-05 16:07:50  75.80010
      56        1          0.7 2030-01-05 16:09:11 2030-01-05 16:09:12  91.24980
      57        5         10.0 2030-01-05 16:09:13 2030-01-05 16:09:23  81.59374
      58        5          7.8 2030-01-05 16:09:24 2030-01-05 16:09:32  84.65149
      59        6         12.0 2030-01-05 16:09:34 2030-01-05 16:09:46  90.55242
      60        3          6.3 2030-01-05 16:09:48 2030-01-05 16:09:54  70.97207
      61        7         13.3 2030-01-05 16:09:56 2030-01-05 16:10:09  82.23748
      62        3          3.3 2030-01-05 16:00:42 2030-01-05 16:00:45  43.45229
      63        2          2.0 2030-01-05 16:10:10 2030-01-05 16:10:12  77.08758
      64        6         14.2 2030-01-05 16:10:15 2030-01-05 16:10:30  84.22234
      65        4          8.3 2030-01-05 16:10:32 2030-01-05 16:10:41  82.55935
      66        3          4.5 2030-01-05 16:10:43 2030-01-05 16:10:48  84.65149
      67        2          2.1 2030-01-05 16:10:49 2030-01-05 16:10:52  64.37376
      68        4          5.3 2030-01-05 16:10:53 2030-01-05 16:10:58  75.07590
      69        4          8.7 2030-01-05 16:11:01 2030-01-05 16:11:10  87.46785
      70        3          5.3 2030-01-05 16:11:12 2030-01-05 16:11:18  82.55935
      71        8         15.5 2030-01-05 16:11:18 2030-01-05 16:11:34  86.09990
      72        7         12.5 2030-01-05 16:11:35 2030-01-05 16:11:47  81.27187
      73        7         15.3 2030-01-05 16:00:45 2030-01-05 16:01:01  36.85398
      74        3          4.7 2030-01-05 16:11:49 2030-01-05 16:11:53  94.30756
      75        5         12.8 2030-01-05 16:11:55 2030-01-05 16:12:08  96.23877
      76        5          8.1 2030-01-05 16:12:10 2030-01-05 16:12:18  92.21541
      77        2          2.8 2030-01-05 16:12:19 2030-01-05 16:12:22  90.44513
      78        5         11.7 2030-01-05 16:12:23 2030-01-05 16:12:35  75.07590
      79        6         12.6 2030-01-05 16:12:36 2030-01-05 16:12:48  87.49467
      80        6         13.3 2030-01-05 16:12:49 2030-01-05 16:13:02  82.50570
      81        5         10.5 2030-01-05 16:13:03 2030-01-05 16:13:13  92.00083
      82        3          5.1 2030-01-05 16:13:15 2030-01-05 16:13:20  79.98440
      83        1          0.8 2030-01-05 16:13:22 2030-01-05 16:13:22  74.67356
      84        6         12.5 2030-01-05 16:01:02 2030-01-05 16:01:14  41.36014
      85        1          0.3 2030-01-05 16:14:32 2030-01-05 16:14:33  85.93897
      86        7         11.9 2030-01-05 16:14:35 2030-01-05 16:14:47  66.30497
      87        6         11.9 2030-01-05 16:14:47 2030-01-05 16:14:59  76.92664
      88        6         12.9 2030-01-05 16:15:01 2030-01-05 16:15:14  76.49748
      89        3          3.0 2030-01-05 16:15:16 2030-01-05 16:15:19  73.30562
      90        4          8.3 2030-01-05 16:15:22 2030-01-05 16:15:30  77.89225
      91        4          6.5 2030-01-05 16:15:31 2030-01-05 16:15:37  76.84618
      92        2          2.7 2030-01-05 16:15:39 2030-01-05 16:15:42  81.27187
      93        7         16.5 2030-01-05 16:15:42 2030-01-05 16:15:59  79.82346
      94        3          7.3 2030-01-05 16:16:00 2030-01-05 16:16:07  72.25955
      95        3          5.4 2030-01-05 16:01:15 2030-01-05 16:01:21  43.77416
      96        6         14.2 2030-01-05 16:16:08 2030-01-05 16:16:22  73.54702
      97        4          5.5 2030-01-05 16:16:25 2030-01-05 16:16:30  82.55935
      98        2          2.7 2030-01-05 16:16:33 2030-01-05 16:16:35  79.17972
      99        4          6.2 2030-01-05 16:16:36 2030-01-05 16:16:42  70.89160
      100       6         15.8 2030-01-05 16:16:43 2030-01-05 16:16:59  85.67075
      101       6         10.9 2030-01-05 16:17:00 2030-01-05 16:17:11  78.05318
      102       4          6.6 2030-01-05 16:17:12 2030-01-05 16:17:19  72.90328
      103       3          4.2 2030-01-05 16:17:20 2030-01-05 16:17:24  76.60477
      104       4          8.9 2030-01-05 16:17:25 2030-01-05 16:17:34  79.42113
      105       2          2.8 2030-01-05 16:17:36 2030-01-05 16:17:38  79.82346
      106       8         16.7 2030-01-05 16:01:23 2030-01-05 16:01:40  41.84294
      107       2          2.1 2030-01-05 16:17:40 2030-01-05 16:17:42  72.25955
      108       2          2.9 2030-01-05 16:17:44 2030-01-05 16:17:47  79.01879
      109       6         12.6 2030-01-05 16:17:50 2030-01-05 16:18:02  74.61992
      110       6         13.8 2030-01-05 16:18:04 2030-01-05 16:18:17  85.18794
      111       4          6.0 2030-01-05 16:18:18 2030-01-05 16:18:24  67.02918
      112       2          2.4 2030-01-05 16:18:26 2030-01-05 16:18:29  65.50030
      113       4          7.0 2030-01-05 16:19:40 2030-01-05 16:19:47  65.98310
      114       5          8.1 2030-01-05 16:19:47 2030-01-05 16:19:55  79.82346
      115       5         11.6 2030-01-05 16:19:58 2030-01-05 16:20:10  79.66253
      116       5          8.4 2030-01-05 16:20:10 2030-01-05 16:20:19  85.08065
      117       3          4.9 2030-01-12 18:00:00 2030-01-12 18:00:04  42.96948
      118       6          9.3 2030-01-12 18:01:15 2030-01-12 18:01:25  41.09192
      119       7         14.5 2030-01-12 18:20:06 2030-01-12 18:20:21  65.25890
      120       7         13.5 2030-01-12 18:20:23 2030-01-12 18:20:37  59.33115
      121       2          2.9 2030-01-12 18:20:39 2030-01-12 18:20:42  69.20179
      122       5         10.8 2030-01-12 18:20:43 2030-01-12 18:20:54  65.50030
      123       2          3.1 2030-01-12 18:20:56 2030-01-12 18:20:59  71.29394
      124       2          2.8 2030-01-12 18:21:00 2030-01-12 18:21:03  70.16740
      125       3          6.9 2030-01-12 18:21:04 2030-01-12 18:21:11  58.25825
      126       8         17.0 2030-01-12 18:01:26 2030-01-12 18:01:43  42.00388
      127       3          5.8 2030-01-12 18:01:45 2030-01-12 18:01:51  40.79687
      128       6          9.8 2030-01-12 18:01:52 2030-01-12 18:02:02  41.89659
      129       3          4.5 2030-01-12 18:02:02 2030-01-12 18:02:07  42.64762
      130       3          5.1 2030-01-12 18:02:08 2030-01-12 18:02:13  45.30303
      131       1          0.7 2030-01-12 18:02:13 2030-01-12 18:02:14        NA
      132       2          1.9 2030-01-12 18:03:20 2030-01-12 18:03:22  83.04215
      133       5         13.0 2030-01-12 18:03:23 2030-01-12 18:03:36  64.48105
      134       3          5.0 2030-01-12 18:03:37 2030-01-12 18:03:42  67.59245
      135       4          6.6 2030-01-12 18:00:05 2030-01-12 18:00:11  42.88902
      136       4          6.3 2030-01-12 18:03:43 2030-01-12 18:03:50  74.75403
      137       3          4.1 2030-01-12 18:03:52 2030-01-12 18:03:56  72.98375
      138       4          8.6 2030-01-12 18:03:59 2030-01-12 18:04:08  85.13430
      139       6         10.4 2030-01-12 18:04:08 2030-01-12 18:04:19  74.72721
      140       6         11.4 2030-01-12 18:04:21 2030-01-12 18:04:32  75.74646
      141       6          7.0 2030-01-12 18:04:34 2030-01-12 18:04:41  78.80421
      142       3          6.5 2030-01-12 18:04:43 2030-01-12 18:04:50  70.97207
      143       5         10.3 2030-01-12 18:04:51 2030-01-12 18:05:02  78.80421
      144       3          5.4 2030-01-12 18:05:03 2030-01-12 18:05:08  64.37376
      145       3          4.5 2030-01-12 18:05:10 2030-01-12 18:05:14  69.52366
      146       6          9.6 2030-01-12 18:00:14 2030-01-12 18:00:23  45.38350
      147       6         15.6 2030-01-12 18:05:16 2030-01-12 18:05:32  84.00776
      148       3          6.1 2030-01-12 18:05:32 2030-01-12 18:05:38  63.24722
      149       7         12.4 2030-01-12 18:05:39 2030-01-12 18:05:52  79.94416
      150       6         10.3 2030-01-12 18:05:54 2030-01-12 18:06:04  59.11657
      151       3          6.3 2030-01-12 18:06:06 2030-01-12 18:06:12  81.43281
      152       5         10.4 2030-01-12 18:06:14 2030-01-12 18:06:24  61.20872
      153       5          8.3 2030-01-12 18:06:26 2030-01-12 18:06:34  67.35105
      154       6          7.7 2030-01-12 18:06:36 2030-01-12 18:06:44  81.75468
      155       5         10.1 2030-01-12 18:06:45 2030-01-12 18:06:55  80.52084
      156       6         12.7 2030-01-12 18:07:52 2030-01-12 18:08:05  76.76571
      157       2          2.6 2030-01-12 18:00:24 2030-01-12 18:00:27  44.57883
      158       6         11.7 2030-01-12 18:08:07 2030-01-12 18:08:18  79.76982
      159       3          5.4 2030-01-12 18:08:20 2030-01-12 18:08:25  71.85721
      160       3          5.0 2030-01-12 18:08:26 2030-01-12 18:08:31  95.43410
      161       3          5.8 2030-01-12 18:08:32 2030-01-12 18:08:37  81.91561
      162       3          4.4 2030-01-12 18:08:38 2030-01-12 18:08:43  88.99672
      163       5          8.9 2030-01-12 18:08:44 2030-01-12 18:08:53  75.53188
      164       2          2.6 2030-01-12 18:08:55 2030-01-12 18:08:58  73.22515
      165       4          6.9 2030-01-12 18:09:00 2030-01-12 18:09:07  76.04150
      166       6         12.5 2030-01-12 18:09:10 2030-01-12 18:09:22  84.81243
      167       7         16.7 2030-01-12 18:09:24 2030-01-12 18:09:41  85.56346
      168       4          7.5 2030-01-12 18:00:28 2030-01-12 18:00:36  43.77416
      169       3          4.5 2030-01-12 18:09:42 2030-01-12 18:09:47  82.23748
      170       5         10.3 2030-01-12 18:09:50 2030-01-12 18:10:00  84.73196
      171       2          2.0 2030-01-12 18:10:01 2030-01-12 18:10:03  92.21541
      172       6         13.9 2030-01-12 18:10:05 2030-01-12 18:10:19  79.39430
      173       3          4.2 2030-01-12 18:10:20 2030-01-12 18:10:24  82.55935
      174       6         12.3 2030-01-12 18:10:26 2030-01-12 18:10:39  72.63506
      175       4          6.4 2030-01-12 18:10:41 2030-01-12 18:10:47  81.43281
      176       7         12.5 2030-01-12 18:10:49 2030-01-12 18:11:01  89.10401
      177       8         16.9 2030-01-12 18:11:03 2030-01-12 18:11:19  82.47888
      178       7         15.9 2030-01-12 18:11:20 2030-01-12 18:11:36  76.44384
      179       5          7.0 2030-01-12 18:00:38 2030-01-12 18:00:45  34.84230
      180       4          8.0 2030-01-12 18:11:37 2030-01-12 18:11:45  84.49056
      181       3          3.0 2030-01-12 18:11:47 2030-01-12 18:11:50  65.66124
      182       3          4.5 2030-01-12 18:11:51 2030-01-12 18:11:56  85.37570
      183       7         15.9 2030-01-12 18:11:57 2030-01-12 18:12:13  84.65149
      184       5          6.9 2030-01-12 18:12:15 2030-01-12 18:12:22  72.58141
      185       3          5.9 2030-01-12 18:13:36 2030-01-12 18:13:42  82.47888
      186       2          3.6 2030-01-12 18:13:44 2030-01-12 18:13:47  93.02008
      187       5          9.9 2030-01-12 18:13:49 2030-01-12 18:13:59  72.17908
      188       5         10.6 2030-01-12 18:14:00 2030-01-12 18:14:10  73.65431
      189       5         11.0 2030-01-12 18:14:12 2030-01-12 18:14:23  84.32963
      190       4          9.9 2030-01-12 18:00:48 2030-01-12 18:00:58  37.65865
      191       3          5.1 2030-01-12 18:14:24 2030-01-12 18:14:29  63.24722
      192       2          2.7 2030-01-12 18:14:32 2030-01-12 18:14:35  77.24851
      193       4          5.5 2030-01-12 18:14:36 2030-01-12 18:14:42  83.04215
      194       2          3.8 2030-01-12 18:14:43 2030-01-12 18:14:46  84.00776
      195       3          4.3 2030-01-12 18:14:49 2030-01-12 18:14:53  76.28291
      196       3          5.0 2030-01-12 18:14:55 2030-01-12 18:15:00  82.72028
      197       7         12.9 2030-01-12 18:15:01 2030-01-12 18:15:14  76.17562
      198       4          9.4 2030-01-12 18:15:15 2030-01-12 18:15:24  73.22515
      199       4          7.5 2030-01-12 18:15:26 2030-01-12 18:15:34  86.90458
      200       5          8.7 2030-01-12 18:15:35 2030-01-12 18:15:44  71.13300
      201       3          5.5 2030-01-12 18:00:59 2030-01-12 18:01:05  43.29135
      202       3          7.0 2030-01-12 18:15:45 2030-01-12 18:15:52  93.02008
      203       4          8.1 2030-01-12 18:15:54 2030-01-12 18:16:02  73.78842
      204       4          6.8 2030-01-12 18:16:04 2030-01-12 18:16:11  83.60542
      205       6         12.5 2030-01-12 18:16:13 2030-01-12 18:16:25  73.54702
      206       7         13.8 2030-01-12 18:16:28 2030-01-12 18:16:41  82.68005
      207       2          2.6 2030-01-12 18:16:44 2030-01-12 18:16:47  91.41074
      208       6         12.4 2030-01-12 18:16:49 2030-01-12 18:17:01  82.82757
      209       5          8.7 2030-01-12 18:17:02 2030-01-12 18:17:11  85.61710
      210       7         16.3 2030-01-12 18:17:12 2030-01-12 18:17:29  87.26668
      211       1          0.7 2030-01-12 18:17:29 2030-01-12 18:17:30        NA
      212       3          6.0 2030-01-12 18:01:07 2030-01-12 18:01:13  33.47436
      213       3          5.1 2030-01-12 18:18:30 2030-01-12 18:18:35  66.06357
      214       4          8.4 2030-01-12 18:18:37 2030-01-12 18:18:46  80.06486
      215       7         13.7 2030-01-12 18:18:46 2030-01-12 18:19:00  65.33937
      216       4          8.9 2030-01-12 18:19:02 2030-01-12 18:19:11  67.99478
      217       4          6.8 2030-01-12 18:19:14 2030-01-12 18:19:20  68.39712
      218       4          8.2 2030-01-12 18:19:22 2030-01-12 18:19:30  69.20179
      219       6         12.6 2030-01-12 18:19:32 2030-01-12 18:19:44  77.78496
      220       2          3.2 2030-01-12 18:19:46 2030-01-12 18:19:49  59.54573
      221       3          4.6 2030-01-12 18:19:51 2030-01-12 18:19:56  65.50030
      222       3          6.5 2030-01-12 18:19:58 2030-01-12 18:20:04  84.97336
      223       7         12.0 2030-01-19 13:00:00 2030-01-19 13:00:12  45.50420
      224       2          3.6 2030-01-19 13:01:33 2030-01-19 13:01:37  40.23360
      225       6         14.8 2030-01-19 13:20:54 2030-01-19 13:21:09  84.86607
      226       6         11.7 2030-01-19 13:21:11 2030-01-19 13:21:23  72.36684
      227       3          6.1 2030-01-19 13:21:25 2030-01-19 13:21:31  80.06486
      228       6         11.5 2030-01-19 13:21:33 2030-01-19 13:21:44  68.12890
      229       2          2.8 2030-01-19 13:21:47 2030-01-19 13:21:50  81.27187
      230       3          4.6 2030-01-19 13:01:40 2030-01-19 13:01:44  44.09603
      231       4          6.3 2030-01-19 13:01:47 2030-01-19 13:01:53  42.00388
      232       4          8.2 2030-01-19 13:01:54 2030-01-19 13:02:03  43.37182
      233       4          7.2 2030-01-19 13:02:03 2030-01-19 13:02:10  48.03892
      234       3          5.1 2030-01-19 13:02:13 2030-01-19 13:02:18  47.47565
      235       6          9.8 2030-01-19 13:02:19 2030-01-19 13:02:29  44.20332
      236       2          3.6 2030-01-19 13:02:30 2030-01-19 13:02:33  42.80855
      237       6         16.2 2030-01-19 13:02:35 2030-01-19 13:02:51  48.54854
      238       4          8.9 2030-01-19 13:02:52 2030-01-19 13:03:01  37.90005
      239       3          6.4 2030-01-19 13:00:13 2030-01-19 13:00:20  46.51004
      240       1          0.9 2030-01-19 13:03:04 2030-01-19 13:03:05  38.62426
      241       1          0.5 2030-01-19 13:04:22 2030-01-19 13:04:22  61.47694
      242       3          4.7 2030-01-19 13:04:24 2030-01-19 13:04:29  67.43151
      243       5         11.1 2030-01-19 13:04:31 2030-01-19 13:04:42  80.52084
      244       6         10.5 2030-01-19 13:04:43 2030-01-19 13:04:54  70.11375
      245       4          5.4 2030-01-19 13:04:55 2030-01-19 13:05:00  62.76442
      246       5         12.0 2030-01-19 13:05:00 2030-01-19 13:05:12  71.53534
      247       7         13.8 2030-01-19 13:05:13 2030-01-19 13:05:27  65.37960
      248       8         15.1 2030-01-19 13:05:29 2030-01-19 13:05:44  74.71380
      249       6         11.8 2030-01-19 13:05:45 2030-01-19 13:05:57  77.73132
      250       5         13.2 2030-01-19 13:00:22 2030-01-19 13:00:35  44.68612
      251       4          6.3 2030-01-19 13:05:58 2030-01-19 13:06:04  77.24851
      252       5          9.1 2030-01-19 13:06:06 2030-01-19 13:06:15  81.99608
      253       5          9.2 2030-01-19 13:06:15 2030-01-19 13:06:25  77.78496
      254       5          7.3 2030-01-19 13:06:25 2030-01-19 13:06:33  65.98310
      255       5         10.0 2030-01-19 13:06:34 2030-01-19 13:06:44  71.02572
      256       5          9.5 2030-01-19 13:06:46 2030-01-19 13:06:55  69.44319
      257       3          6.4 2030-01-19 13:06:58 2030-01-19 13:07:04  79.09926
      258       2          3.3 2030-01-19 13:07:06 2030-01-19 13:07:09  72.09861
      259       2          2.6 2030-01-19 13:08:31 2030-01-19 13:08:34  78.21412
      260       3          4.3 2030-01-19 13:08:34 2030-01-19 13:08:39  78.77739
      261       6         10.7 2030-01-19 13:00:38 2030-01-19 13:00:48  45.86630
      262       3          3.9 2030-01-19 13:08:41 2030-01-19 13:08:45  70.16740
      263       3          4.4 2030-01-19 13:08:45 2030-01-19 13:08:50  96.23877
      264       6         10.3 2030-01-19 13:08:52 2030-01-19 13:09:02  82.18383
      265       5         12.2 2030-01-19 13:09:03 2030-01-19 13:09:15  87.22644
      266       4          9.0 2030-01-19 13:09:17 2030-01-19 13:09:26  73.14468
      267       7         13.3 2030-01-19 13:09:27 2030-01-19 13:09:40  86.09990
      268       6         10.7 2030-01-19 13:09:41 2030-01-19 13:09:52  84.38327
      269       3          4.3 2030-01-19 13:09:53 2030-01-19 13:09:57  80.30627
      270       3          6.0 2030-01-19 13:10:00 2030-01-19 13:10:06  83.20308
      271       5         10.8 2030-01-19 13:10:07 2030-01-19 13:10:17  81.75468
      272       3          6.7 2030-01-19 13:00:49 2030-01-19 13:00:56  42.80855
      273       4          6.2 2030-01-19 13:10:20 2030-01-19 13:10:26  83.92729
      274       4          6.2 2030-01-19 13:10:28 2030-01-19 13:10:34  71.05254
      275       5          9.8 2030-01-19 13:10:34 2030-01-19 13:10:44  85.45617
      276       5          9.8 2030-01-19 13:10:46 2030-01-19 13:10:56  79.26019
      277       5         10.3 2030-01-19 13:10:58 2030-01-19 13:11:08  68.02161
      278       6         10.8 2030-01-19 13:11:10 2030-01-19 13:11:21  74.67356
      279       5          9.3 2030-01-19 13:11:23 2030-01-19 13:11:32  69.76506
      280       5         10.6 2030-01-19 13:11:35 2030-01-19 13:11:46  82.39841
      281       3          6.9 2030-01-19 13:11:48 2030-01-19 13:11:55  80.46720
      282       2          1.8 2030-01-19 13:11:57 2030-01-19 13:11:59  76.12197
      283       5         10.1 2030-01-19 13:00:57 2030-01-19 13:01:07  41.03827
      284       6         11.9 2030-01-19 13:12:01 2030-01-19 13:12:13  88.62121
      285       2          3.3 2030-01-19 13:12:16 2030-01-19 13:12:19  98.16998
      286       1          0.8 2030-01-19 13:12:20 2030-01-19 13:12:21  87.38738
      287       2          3.9 2030-01-19 13:13:44 2030-01-19 13:13:48  71.61581
      288       8         12.4 2030-01-19 13:13:50 2030-01-19 13:14:02  76.72548
      289       5          9.6 2030-01-19 13:14:05 2030-01-19 13:14:15  72.09861
      290       4          5.7 2030-01-19 13:14:16 2030-01-19 13:14:21  72.50095
      291       5          8.6 2030-01-19 13:14:22 2030-01-19 13:14:30  77.24851
      292       5         10.0 2030-01-19 13:14:31 2030-01-19 13:14:41  69.09450
      293       5          7.7 2030-01-19 13:14:44 2030-01-19 13:14:51  79.09926
      294       5          9.9 2030-01-19 13:01:08 2030-01-19 13:01:17  37.65865
      295       4          6.8 2030-01-19 13:14:53 2030-01-19 13:15:00  79.26019
      296       7         14.2 2030-01-19 13:15:02 2030-01-19 13:15:17  81.03047
      297       7         14.2 2030-01-19 13:15:18 2030-01-19 13:15:32  78.69692
      298       5          7.8 2030-01-19 13:15:33 2030-01-19 13:15:41  74.61992
      299       3          3.0 2030-01-19 13:15:42 2030-01-19 13:15:45  84.32963
      300       5          9.5 2030-01-19 13:15:46 2030-01-19 13:15:55  66.78778
      301       3          4.2 2030-01-19 13:15:56 2030-01-19 13:16:01  71.45487
      302       2          3.3 2030-01-19 13:16:01 2030-01-19 13:16:05  63.24722
      303       6         10.2 2030-01-19 13:16:06 2030-01-19 13:16:17  86.74364
      304       6         15.0 2030-01-19 13:16:18 2030-01-19 13:16:33  79.07244
      305       2          1.9 2030-01-19 13:01:19 2030-01-19 13:01:21  41.19921
      306       4          5.8 2030-01-19 13:16:35 2030-01-19 13:16:41  83.60542
      307       7         11.6 2030-01-19 13:16:41 2030-01-19 13:16:53  78.45552
      308       4          6.9 2030-01-19 13:16:55 2030-01-19 13:17:02  79.58206
      309       3          3.8 2030-01-19 13:17:03 2030-01-19 13:17:07  65.33937
      310       5         11.7 2030-01-19 13:17:10 2030-01-19 13:17:21  69.30908
      311       4         10.3 2030-01-19 13:17:23 2030-01-19 13:17:33  75.23683
      312       5          9.8 2030-01-19 13:17:34 2030-01-19 13:17:44  67.19011
      313       2          4.1 2030-01-19 13:18:59 2030-01-19 13:19:03  78.53599
      314       4          7.2 2030-01-19 13:19:04 2030-01-19 13:19:11  70.81114
      315       5          9.1 2030-01-19 13:19:14 2030-01-19 13:19:23  70.86478
      316       4          9.2 2030-01-19 13:01:24 2030-01-19 13:01:33  45.54444
      317       5          7.4 2030-01-19 13:19:23 2030-01-19 13:19:31  64.13236
      318       4          5.7 2030-01-19 13:19:31 2030-01-19 13:19:37  86.50224
      319       3          2.9 2030-01-19 13:19:38 2030-01-19 13:19:41  73.30562
      320       4          8.4 2030-01-19 13:19:43 2030-01-19 13:19:52  71.29394
      321       4          8.1 2030-01-19 13:19:54 2030-01-19 13:20:02  84.24916
      322       3          4.4 2030-01-19 13:20:04 2030-01-19 13:20:08  69.52366
      323       5          8.7 2030-01-19 13:20:09 2030-01-19 13:20:18  75.15636
      324       7         15.1 2030-01-19 13:20:18 2030-01-19 13:20:33  73.92253
      325       5          8.5 2030-01-19 13:20:36 2030-01-19 13:20:44  76.65842
      326       5          8.2 2030-01-19 13:20:45 2030-01-19 13:20:53  58.49965
      327       3          6.4 2030-01-26 18:00:00 2030-01-26 18:00:06  48.03892
      328       5          7.6 2030-01-26 18:01:17 2030-01-26 18:01:24  48.97770
      329       4          6.8 2030-01-26 18:01:25 2030-01-26 18:01:32  35.48604
      330       6         13.9 2030-01-26 18:01:33 2030-01-26 18:01:47  41.14556
      331       5          7.7 2030-01-26 18:01:49 2030-01-26 18:01:57  38.70472
      332       2          2.6 2030-01-26 18:01:58 2030-01-26 18:02:01  37.33678
      333       4          6.3 2030-01-26 18:02:02 2030-01-26 18:02:08  37.65865
      334       5          8.8 2030-01-26 18:03:13 2030-01-26 18:03:22  72.68870
      335       5         10.2 2030-01-26 18:03:25 2030-01-26 18:03:35  82.96168
      336       3          5.0 2030-01-26 18:03:37 2030-01-26 18:03:42  80.78907
      337       6          9.2 2030-01-26 18:03:45 2030-01-26 18:03:54  76.28291
      338       3          6.2 2030-01-26 18:00:07 2030-01-26 18:00:13  36.85398
      339       2          3.6 2030-01-26 18:03:56 2030-01-26 18:04:00  74.99543
      340       5          8.1 2030-01-26 18:04:01 2030-01-26 18:04:09  80.22580
      341       3          4.9 2030-01-26 18:04:10 2030-01-26 18:04:15  74.83450
      342       4          7.9 2030-01-26 18:04:16 2030-01-26 18:04:24  73.70796
      343       4          8.5 2030-01-26 18:04:27 2030-01-26 18:04:36  77.65085
      344       4          8.9 2030-01-26 18:04:37 2030-01-26 18:04:46  60.18947
      345       3          5.7 2030-01-26 18:04:47 2030-01-26 18:04:52  74.99543
      346       5          8.9 2030-01-26 18:04:54 2030-01-26 18:05:03  71.77674
      347       2          4.0 2030-01-26 18:05:05 2030-01-26 18:05:09  64.69563
      348       4          9.2 2030-01-26 18:05:09 2030-01-26 18:05:18  82.07654
      349       3          4.7 2030-01-26 18:00:14 2030-01-26 18:00:18  35.24463
      350       5          7.9 2030-01-26 18:05:19 2030-01-26 18:05:27  76.04150
      351       5          8.2 2030-01-26 18:05:27 2030-01-26 18:05:36  76.81935
      352       4          8.0 2030-01-26 18:05:37 2030-01-26 18:05:45  68.31665
      353       4          5.8 2030-01-26 18:05:47 2030-01-26 18:05:53  64.05189
      354       5          8.3 2030-01-26 18:05:54 2030-01-26 18:06:02  68.07525
      355       4          7.9 2030-01-26 18:06:04 2030-01-26 18:06:12  72.90328
      356       6         11.5 2030-01-26 18:06:13 2030-01-26 18:06:25  70.00646
      357       4          6.6 2030-01-26 18:06:26 2030-01-26 18:06:33  66.94871
      358       3          3.1 2030-01-26 18:06:35 2030-01-26 18:06:38  80.06486
      359       4          6.5 2030-01-26 18:06:39 2030-01-26 18:06:46  75.63917
      360       7         12.1 2030-01-26 18:00:20 2030-01-26 18:00:32  39.58986
      361       5          7.6 2030-01-26 18:06:47 2030-01-26 18:06:55  66.14404
      362       5          8.2 2030-01-26 18:08:16 2030-01-26 18:08:25  80.03804
      363       2          2.1 2030-01-26 18:08:27 2030-01-26 18:08:29  95.11223
      364       5          8.6 2030-01-26 18:08:31 2030-01-26 18:08:40  74.67356
      365       3          3.1 2030-01-26 18:08:41 2030-01-26 18:08:45  77.48991
      366       4          7.4 2030-01-26 18:08:45 2030-01-26 18:08:52  69.12132
      367       3          5.7 2030-01-26 18:08:54 2030-01-26 18:08:59  84.49056
      368       2          2.1 2030-01-26 18:09:01 2030-01-26 18:09:04  71.13300
      369       4          9.3 2030-01-26 18:09:05 2030-01-26 18:09:14  92.45681
      370       4          8.5 2030-01-26 18:09:15 2030-01-26 18:09:24  87.30691
      371       3          5.6 2030-01-26 18:00:35 2030-01-26 18:00:40  40.79687
      372       5          9.4 2030-01-26 18:09:26 2030-01-26 18:09:35  93.28831
      373       4          9.2 2030-01-26 18:09:38 2030-01-26 18:09:47  83.60542
      374       6         11.8 2030-01-26 18:09:48 2030-01-26 18:10:00  82.98851
      375       4          6.2 2030-01-26 18:10:02 2030-01-26 18:10:08  77.81178
      376       5          7.9 2030-01-26 18:10:11 2030-01-26 18:10:19  83.04215
      377       4          6.9 2030-01-26 18:10:21 2030-01-26 18:10:28  81.99608
      378       4          7.2 2030-01-26 18:10:30 2030-01-26 18:10:37  74.27123
      379       7         13.5 2030-01-26 18:10:39 2030-01-26 18:10:53  86.70341
      380       3          4.3 2030-01-26 18:10:53 2030-01-26 18:10:58  73.06422
      381       7         14.2 2030-01-26 18:10:58 2030-01-26 18:11:13  89.11742
      382       4          7.8 2030-01-26 18:00:42 2030-01-26 18:00:50  45.94677
      383       5          8.9 2030-01-26 18:11:13 2030-01-26 18:11:22  79.90393
      384       7         14.4 2030-01-26 18:11:24 2030-01-26 18:11:38  73.66772
      385       2          2.5 2030-01-26 18:12:51 2030-01-26 18:12:54  82.39841
      386       3          4.8 2030-01-26 18:12:56 2030-01-26 18:13:01  73.86889
      387       3          6.7 2030-01-26 18:13:01 2030-01-26 18:13:08  62.92535
      388       2          3.7 2030-01-26 18:13:09 2030-01-26 18:13:13  77.89225
      389       4          5.5 2030-01-26 18:13:15 2030-01-26 18:13:20  81.67421
      390       9         21.8 2030-01-26 18:13:22 2030-01-26 18:13:44  84.20088
      391       6         13.2 2030-01-26 18:13:46 2030-01-26 18:13:59  75.90739
      392       5         11.9 2030-01-26 18:14:01 2030-01-26 18:14:13  77.08758
      393       3          6.4 2030-01-26 18:00:51 2030-01-26 18:00:57  33.63529
      394       6         10.8 2030-01-26 18:14:15 2030-01-26 18:14:26  81.70103
      395       5         13.9 2030-01-26 18:14:28 2030-01-26 18:14:42  74.02982
      396       4          8.3 2030-01-26 18:14:44 2030-01-26 18:14:52  74.59309
      397       4          8.5 2030-01-26 18:14:53 2030-01-26 18:15:02  71.61581
      398       2          3.1 2030-01-26 18:15:04 2030-01-26 18:15:07  76.28291
      399       3          5.8 2030-01-26 18:15:09 2030-01-26 18:15:15  72.42048
      400       7         12.6 2030-01-26 18:15:16 2030-01-26 18:15:29  71.45487
      401       7         12.9 2030-01-26 18:15:31 2030-01-26 18:15:44  79.39430
      402       3          6.9 2030-01-26 18:15:45 2030-01-26 18:15:52  81.75468
      403       4          7.1 2030-01-26 18:15:54 2030-01-26 18:16:01  83.28355
      404       5          9.5 2030-01-26 18:00:58 2030-01-26 18:01:08  42.37939
      405       6         12.8 2030-01-26 18:16:03 2030-01-26 18:16:15  69.95282
      406       6         12.0 2030-01-26 18:17:37 2030-01-26 18:17:49  70.22104
      407       2          2.9 2030-01-26 18:17:52 2030-01-26 18:17:55  67.75338
      408       8         15.9 2030-01-26 18:17:56 2030-01-26 18:18:12  72.25955
      409       6         11.5 2030-01-26 18:18:13 2030-01-26 18:18:24  76.87300
      410       2          2.6 2030-01-26 18:18:26 2030-01-26 18:18:29  61.31601
      411       2          2.8 2030-01-26 18:18:31 2030-01-26 18:18:34  68.87992
      412       2          4.2 2030-01-26 18:18:35 2030-01-26 18:18:39  67.75338
      413       5          7.6 2030-01-26 18:18:41 2030-01-26 18:18:49  77.83860
      414       3          3.7 2030-01-26 18:18:49 2030-01-26 18:18:53  59.54573
      415       3          5.7 2030-01-26 18:01:09 2030-01-26 18:01:14  40.07267
      416       4          5.4 2030-01-26 18:18:55 2030-01-26 18:19:00  73.30562
      417       4          9.9 2030-01-26 18:19:02 2030-01-26 18:19:12  64.37376
      418       2          1.8 2030-01-26 18:19:14 2030-01-26 18:19:15  74.67356
      419       3          6.7 2030-01-26 18:19:18 2030-01-26 18:19:24  81.91561
      420       5         10.2 2030-01-26 18:19:26 2030-01-26 18:19:36  67.27058
      421       2          3.8 2030-01-26 18:19:36 2030-01-26 18:19:40  57.45358
      422       1          0.5 2030-01-26 18:19:41 2030-01-26 18:19:41  65.33937
      423       5          8.8 2030-02-02 14:00:00 2030-02-02 14:00:08  44.79341
      424       3          4.7 2030-02-02 14:01:33 2030-02-02 14:01:37  44.73976
      425       4         10.0 2030-02-02 14:19:26 2030-02-02 14:19:36  81.91561
      426       4          6.3 2030-02-02 14:19:39 2030-02-02 14:19:45  71.61581
      427       4          8.7 2030-02-02 14:19:48 2030-02-02 14:19:56  70.65020
      428       5          9.3 2030-02-02 14:19:57 2030-02-02 14:20:06  79.23337
      429       2          3.1 2030-02-02 14:20:07 2030-02-02 14:20:10  77.24851
      430       8         15.0 2030-02-02 14:20:13 2030-02-02 14:20:28  67.67292
      431       6         11.8 2030-02-02 14:20:29 2030-02-02 14:20:41  72.42048
      432       4         10.4 2030-02-02 14:20:43 2030-02-02 14:20:53  64.21283
      433       3          3.6 2030-02-02 14:20:55 2030-02-02 14:20:59  78.21412
      434       7         12.4 2030-02-02 14:21:00 2030-02-02 14:21:12  68.19595
      435       8         16.3 2030-02-02 14:01:38 2030-02-02 14:01:54  45.58467
      436       2          3.6 2030-02-02 14:21:14 2030-02-02 14:21:18  70.97207
      437       2          2.9 2030-02-02 14:01:55 2030-02-02 14:01:58  44.25696
      438       3          3.9 2030-02-02 14:02:01 2030-02-02 14:02:04  37.81958
      439       5          8.8 2030-02-02 14:02:06 2030-02-02 14:02:15  44.73976
      440       8         15.5 2030-02-02 14:02:16 2030-02-02 14:02:31  45.86630
      441       3          6.3 2030-02-02 14:02:33 2030-02-02 14:02:39  41.11874
      442       4          7.0 2030-02-02 14:03:58 2030-02-02 14:04:05  58.66059
      443       4          7.8 2030-02-02 14:04:06 2030-02-02 14:04:14  63.64956
      444       4          6.3 2030-02-02 14:04:15 2030-02-02 14:04:21  71.29394
      445       2          3.3 2030-02-02 14:00:08 2030-02-02 14:00:12  39.10706
      446       3          4.3 2030-02-02 14:04:23 2030-02-02 14:04:27  62.60348
      447       7         16.4 2030-02-02 14:04:29 2030-02-02 14:04:45  78.53599
      448       3          4.3 2030-02-02 14:04:46 2030-02-02 14:04:50  76.76571
      449       3          5.2 2030-02-02 14:04:51 2030-02-02 14:04:56  87.06551
      450       3          2.8 2030-02-02 14:04:58 2030-02-02 14:05:01  69.36273
      451       4          6.4 2030-02-02 14:05:01 2030-02-02 14:05:07  61.07460
      452       4          6.0 2030-02-02 14:05:09 2030-02-02 14:05:15  70.65020
      453       5          6.0 2030-02-02 14:05:18 2030-02-02 14:05:24  61.07460
      454       3          5.0 2030-02-02 14:05:26 2030-02-02 14:05:31  75.80010
      455       2          1.9 2030-02-02 14:05:34 2030-02-02 14:05:35  59.54573
      456       5          9.6 2030-02-02 14:00:14 2030-02-02 14:00:23  44.17649
      457       3          5.6 2030-02-02 14:05:37 2030-02-02 14:05:43  75.96104
      458       4          6.0 2030-02-02 14:05:45 2030-02-02 14:05:51  70.00646
      459       6         11.5 2030-02-02 14:05:53 2030-02-02 14:06:05  76.12197
      460       2          3.8 2030-02-02 14:06:07 2030-02-02 14:06:11  80.46720
      461       2          2.2 2030-02-02 14:06:13 2030-02-02 14:06:16  84.49056
      462       4          7.4 2030-02-02 14:06:17 2030-02-02 14:06:24  75.39777
      463       5          8.2 2030-02-02 14:06:25 2030-02-02 14:06:33  76.81935
      464       5         11.4 2030-02-02 14:06:34 2030-02-02 14:06:45  72.82282
      465       4          8.1 2030-02-02 14:06:47 2030-02-02 14:06:55  66.46591
      466       5          8.1 2030-02-02 14:06:57 2030-02-02 14:07:05  77.73132
      467       7         11.3 2030-02-02 14:00:24 2030-02-02 14:00:35  43.93509
      468       2          2.7 2030-02-02 14:08:26 2030-02-02 14:08:28  79.82346
      469       5         11.6 2030-02-02 14:08:31 2030-02-02 14:08:42  81.75468
      470       7         15.4 2030-02-02 14:08:44 2030-02-02 14:08:59  71.13300
      471       7         13.1 2030-02-02 14:09:00 2030-02-02 14:09:13  88.03112
      472       2          2.3 2030-02-02 14:09:15 2030-02-02 14:09:17  70.48927
      473       4          6.5 2030-02-02 14:09:19 2030-02-02 14:09:25  67.10964
      474       7         10.8 2030-02-02 14:09:28 2030-02-02 14:09:39  70.91843
      475       5         10.9 2030-02-02 14:09:40 2030-02-02 14:09:51  88.24570
      476       3          4.5 2030-02-02 14:09:52 2030-02-02 14:09:56  79.98440
      477       3          6.8 2030-02-02 14:09:58 2030-02-02 14:10:05  85.29523
      478       9         18.1 2030-02-02 14:00:38 2030-02-02 14:00:56  41.92341
      479       6         11.5 2030-02-02 14:10:06 2030-02-02 14:10:18  77.19487
      480       3          5.1 2030-02-02 14:10:18 2030-02-02 14:10:23  69.36273
      481       2          2.5 2030-02-02 14:10:23 2030-02-02 14:10:26  67.91432
      482       4          9.7 2030-02-02 14:10:28 2030-02-02 14:10:38  81.59374
      483       5          8.6 2030-02-02 14:10:40 2030-02-02 14:10:49  84.81243
      484       7         14.0 2030-02-02 14:10:50 2030-02-02 14:11:04  80.89636
      485       2          3.8 2030-02-02 14:11:07 2030-02-02 14:11:10  76.60477
      486       2          1.9 2030-02-02 14:11:13 2030-02-02 14:11:15  78.53599
      487       4          7.4 2030-02-02 14:11:15 2030-02-02 14:11:23  81.83514
      488       9         17.8 2030-02-02 14:11:24 2030-02-02 14:11:42  78.98660
      489       2          3.9 2030-02-02 14:00:58 2030-02-02 14:01:02  44.73976
      490       5         10.0 2030-02-02 14:11:43 2030-02-02 14:11:53  83.04215
      491       3          5.5 2030-02-02 14:11:54 2030-02-02 14:11:59  88.83579
      492       2          3.8 2030-02-02 14:12:00 2030-02-02 14:12:04  98.97466
      493       3          6.2 2030-02-02 14:12:06 2030-02-02 14:12:13  98.81372
      494       2          3.2 2030-02-02 14:12:14 2030-02-02 14:12:17  75.15636
      495       5          8.8 2030-02-02 14:12:18 2030-02-02 14:12:27  78.32141
      496       2          3.0 2030-02-02 14:12:28 2030-02-02 14:12:31  79.50159
      497       2          3.9 2030-02-02 14:12:33 2030-02-02 14:12:37  66.14404
      498       3          6.4 2030-02-02 14:12:39 2030-02-02 14:12:46  75.15636
      499      10         18.3 2030-02-02 14:12:47 2030-02-02 14:13:06  85.48835
      500       5         10.3 2030-02-02 14:01:05 2030-02-02 14:01:15  44.63247
      501       3          6.0 2030-02-02 14:13:08 2030-02-02 14:13:14  91.00840
      502       1          0.3 2030-02-02 14:14:01 2030-02-02 14:14:02  75.47823
      503       5          9.1 2030-02-02 14:14:04 2030-02-02 14:14:13  78.45552
      504       3          5.0 2030-02-02 14:14:15 2030-02-02 14:14:20  77.40945
      505       5         10.4 2030-02-02 14:14:22 2030-02-02 14:14:33  83.84682
      506       5         11.6 2030-02-02 14:14:35 2030-02-02 14:14:47  72.90328
      507       3          3.7 2030-02-02 14:14:48 2030-02-02 14:14:51  83.36402
      508       2          3.3 2030-02-02 14:14:54 2030-02-02 14:14:57  76.76571
      509       4          7.5 2030-02-02 14:14:58 2030-02-02 14:15:06  69.60413
      510       3          6.1 2030-02-02 14:15:09 2030-02-02 14:15:15  81.35234
      511       6         10.6 2030-02-02 14:01:17 2030-02-02 14:01:27  44.57883
      512       2          2.5 2030-02-02 14:15:17 2030-02-02 14:15:20  67.10964
      513       5          8.9 2030-02-02 14:15:21 2030-02-02 14:15:30  81.83514
      514       5         10.0 2030-02-02 14:15:32 2030-02-02 14:15:42  71.93768
      515       5         13.1 2030-02-02 14:15:44 2030-02-02 14:15:57  78.05318
      516       6         11.9 2030-02-02 14:15:59 2030-02-02 14:16:11  72.31319
      517       4          7.5 2030-02-02 14:16:11 2030-02-02 14:16:18  76.84618
      518       5         13.1 2030-02-02 14:16:20 2030-02-02 14:16:33  76.98029
      519       5          9.2 2030-02-02 14:16:33 2030-02-02 14:16:43  79.74300
      520       4          5.4 2030-02-02 14:16:44 2030-02-02 14:16:50  86.50224
      521       4          7.5 2030-02-02 14:16:51 2030-02-02 14:16:59  78.45552
      522       2          2.9 2030-02-02 14:01:28 2030-02-02 14:01:31  34.76183
      523       4          5.9 2030-02-02 14:16:59 2030-02-02 14:17:05  84.24916
      524       6         11.4 2030-02-02 14:17:06 2030-02-02 14:17:17  70.38198
      525       2          3.5 2030-02-02 14:17:19 2030-02-02 14:17:23  69.20179
      526       2          3.7 2030-02-02 14:17:24 2030-02-02 14:17:28  76.44384
      527       5          8.4 2030-02-02 14:17:31 2030-02-02 14:17:39  66.94871
      528       6          8.9 2030-02-02 14:17:40 2030-02-02 14:17:49  74.67356
      529       4          8.3 2030-02-02 14:17:50 2030-02-02 14:17:58  80.14533
      530       2          1.8 2030-02-02 14:18:59 2030-02-02 14:19:00  77.08758
      531       4          8.7 2030-02-02 14:19:02 2030-02-02 14:19:11  72.17908
      532       6         12.3 2030-02-02 14:19:13 2030-02-02 14:19:25  68.66534
      533       5          8.5 2030-02-09 09:00:00 2030-02-09 09:00:08  45.54444
      534       5          9.4 2030-02-09 09:01:44 2030-02-09 09:01:53  47.58294
      535       4          4.7 2030-02-09 09:21:26 2030-02-09 09:21:30  69.20179
      536       5         11.7 2030-02-09 09:21:33 2030-02-09 09:21:44  63.40815
      537       2          3.1 2030-02-09 09:21:47 2030-02-09 09:21:50  76.28291
      538       2          3.6 2030-02-09 09:21:51 2030-02-09 09:21:55  84.97336
      539       2          3.6 2030-02-09 09:21:56 2030-02-09 09:22:00  78.21412
      540       4          7.4 2030-02-09 09:22:02 2030-02-09 09:22:10  61.87928
      541       7         14.7 2030-02-09 09:22:12 2030-02-09 09:22:27  73.26539
      542       5          7.6 2030-02-09 09:22:29 2030-02-09 09:22:36  80.54767
      543       3          5.1 2030-02-09 09:01:55 2030-02-09 09:02:00  41.03827
      544       7         13.7 2030-02-09 09:02:00 2030-02-09 09:02:14  41.56131
      545       5          8.3 2030-02-09 09:02:15 2030-02-09 09:02:24  41.76248
      546       8         14.9 2030-02-09 09:02:25 2030-02-09 09:02:40  39.54963
      547       2          3.3 2030-02-09 09:02:41 2030-02-09 09:02:44  34.27903
      548       3          5.7 2030-02-09 09:02:45 2030-02-09 09:02:50  40.79687
      549       2          3.9 2030-02-09 09:02:53 2030-02-09 09:02:57  45.86630
      550       1          0.5 2030-02-09 09:04:11 2030-02-09 09:04:11  65.17843
      551       7         16.0 2030-02-09 09:04:13 2030-02-09 09:04:29  63.78367
      552       3          5.0 2030-02-09 09:00:10 2030-02-09 09:00:15  33.63529
      553       4          7.7 2030-02-09 09:04:30 2030-02-09 09:04:38  58.98246
      554       2          3.0 2030-02-09 09:04:40 2030-02-09 09:04:43  85.77804
      555       3          4.7 2030-02-09 09:04:44 2030-02-09 09:04:49  72.09861
      556       3          5.7 2030-02-09 09:04:50 2030-02-09 09:04:56  79.82346
      557       7         12.2 2030-02-09 09:04:57 2030-02-09 09:05:09  68.51782
      558       9         17.4 2030-02-09 09:05:12 2030-02-09 09:05:29  68.87992
      559       7         14.6 2030-02-09 09:05:32 2030-02-09 09:05:47  71.49511
      560       5         10.2 2030-02-09 09:05:48 2030-02-09 09:05:58  83.04215
      561       3          6.4 2030-02-09 09:05:59 2030-02-09 09:06:05  81.83514
      562       3          6.2 2030-02-09 09:06:06 2030-02-09 09:06:12  68.39712
      563       5         11.1 2030-02-09 09:00:16 2030-02-09 09:00:27  38.57061
      564       5          9.1 2030-02-09 09:06:14 2030-02-09 09:06:23  77.46309
      565       7         16.0 2030-02-09 09:06:24 2030-02-09 09:06:40  67.43151
      566       4          7.7 2030-02-09 09:06:43 2030-02-09 09:06:51  75.07590
      567       2          2.9 2030-02-09 09:06:52 2030-02-09 09:06:55  56.64891
      568       2          3.6 2030-02-09 09:06:56 2030-02-09 09:07:00  62.12068
      569       5          9.5 2030-02-09 09:07:02 2030-02-09 09:07:12  72.09861
      570       6         13.5 2030-02-09 09:07:15 2030-02-09 09:07:28  69.25544
      571       6         12.6 2030-02-09 09:07:30 2030-02-09 09:07:43  63.40815
      572       7         15.7 2030-02-09 09:07:44 2030-02-09 09:08:00  75.58552
      573       5          8.7 2030-02-09 09:08:02 2030-02-09 09:08:10  69.04086
      574       2          4.1 2030-02-09 09:00:27 2030-02-09 09:00:31  36.85398
      575       3          7.0 2030-02-09 09:08:13 2030-02-09 09:08:20  76.92664
      576       1          0.5 2030-02-09 09:09:40 2030-02-09 09:09:41  91.57167
      577       5          9.5 2030-02-09 09:09:42 2030-02-09 09:09:52  80.78907
      578       2          1.8 2030-02-09 09:09:53 2030-02-09 09:09:54  90.60607
      579       3          7.0 2030-02-09 09:09:55 2030-02-09 09:10:02  95.03176
      580       5         11.5 2030-02-09 09:10:04 2030-02-09 09:10:16  84.97336
      581       2          3.1 2030-02-09 09:10:18 2030-02-09 09:10:21  78.05318
      582       4          6.0 2030-02-09 09:10:24 2030-02-09 09:10:30  85.77804
      583       6         13.3 2030-02-09 09:10:31 2030-02-09 09:10:44  88.94308
      584       2          3.6 2030-02-09 09:10:47 2030-02-09 09:10:51  98.16998
      585       5          9.7 2030-02-09 09:00:33 2030-02-09 09:00:43  41.36014
      586       5          9.7 2030-02-09 09:10:53 2030-02-09 09:11:03  82.55935
      587       5         10.9 2030-02-09 09:11:05 2030-02-09 09:11:16  73.30562
      588       3          6.6 2030-02-09 09:11:17 2030-02-09 09:11:23  69.84553
      589       5         11.3 2030-02-09 09:11:24 2030-02-09 09:11:36  70.48927
      590       2          1.8 2030-02-09 09:11:39 2030-02-09 09:11:41  91.89354
      591       2          4.4 2030-02-09 09:11:41 2030-02-09 09:11:46  96.07784
      592       7         11.9 2030-02-09 09:11:47 2030-02-09 09:11:59  74.87473
      593       5          9.7 2030-02-09 09:12:00 2030-02-09 09:12:10  81.91561
      594       3          4.0 2030-02-09 09:12:11 2030-02-09 09:12:15  81.59374
      595       6         10.7 2030-02-09 09:12:16 2030-02-09 09:12:27  70.91843
      596       8         16.0 2030-02-09 09:00:45 2030-02-09 09:01:01  42.32575
      597       4          6.3 2030-02-09 09:12:29 2030-02-09 09:12:36  75.55870
      598       6         11.6 2030-02-09 09:12:37 2030-02-09 09:12:48  84.65149
      599       4          7.1 2030-02-09 09:12:49 2030-02-09 09:12:56  75.47823
      600       4          7.7 2030-02-09 09:12:58 2030-02-09 09:13:05  74.19076
      601       3          5.5 2030-02-09 09:13:07 2030-02-09 09:13:12  88.51392
      602       4          8.2 2030-02-09 09:13:13 2030-02-09 09:13:21  84.81243
      603       5          9.7 2030-02-09 09:13:21 2030-02-09 09:13:31  82.61299
      604       4          9.7 2030-02-09 09:13:33 2030-02-09 09:13:42  79.09926
      605       1          0.6 2030-02-09 09:13:44 2030-02-09 09:13:44        NA
      606       3          4.6 2030-02-09 09:15:07 2030-02-09 09:15:12  82.31795
      607       6         13.5 2030-02-09 09:01:03 2030-02-09 09:01:16  45.22257
      608       2          1.5 2030-02-09 09:15:15 2030-02-09 09:15:16  77.73132
      609       4          9.5 2030-02-09 09:15:19 2030-02-09 09:15:28  81.27187
      610       6         11.2 2030-02-09 09:15:28 2030-02-09 09:15:39  77.51674
      611       6         12.8 2030-02-09 09:15:41 2030-02-09 09:15:53  73.06422
      612       2          2.5 2030-02-09 09:15:56 2030-02-09 09:15:58  82.23748
      613       4          7.7 2030-02-09 09:15:59 2030-02-09 09:16:06  78.13365
      614       5          9.4 2030-02-09 09:16:09 2030-02-09 09:16:19  87.87018
      615       3          4.8 2030-02-09 09:16:21 2030-02-09 09:16:26  70.65020
      616       8         17.1 2030-02-09 09:16:28 2030-02-09 09:16:45  73.94936
      617       5          8.8 2030-02-09 09:16:46 2030-02-09 09:16:55  63.89096
      618       6          8.8 2030-02-09 09:01:19 2030-02-09 09:01:27  38.46332
      619       7         13.1 2030-02-09 09:16:58 2030-02-09 09:17:11  78.77739
      620       2          2.0 2030-02-09 09:17:13 2030-02-09 09:17:15  78.37505
      621       2          2.6 2030-02-09 09:17:17 2030-02-09 09:17:19  93.02008
      622       5          8.7 2030-02-09 09:17:21 2030-02-09 09:17:29  76.68524
      623       6         10.6 2030-02-09 09:17:32 2030-02-09 09:17:42  83.47131
      624       5          8.7 2030-02-09 09:17:44 2030-02-09 09:17:53  71.66945
      625       3          5.1 2030-02-09 09:17:54 2030-02-09 09:17:59  82.23748
      626       6         10.6 2030-02-09 09:18:00 2030-02-09 09:18:11  77.99954
      627       5         12.9 2030-02-09 09:18:13 2030-02-09 09:18:26  73.43973
      628       5          7.9 2030-02-09 09:18:27 2030-02-09 09:18:35  72.98375
      629       8         14.0 2030-02-09 09:01:29 2030-02-09 09:01:43  43.29135
      630       4          7.0 2030-02-09 09:18:35 2030-02-09 09:18:42  76.36337
      631       4          6.9 2030-02-09 09:19:55 2030-02-09 09:20:02  73.30562
      632       6         14.7 2030-02-09 09:20:03 2030-02-09 09:20:17  69.25544
      633       4          7.8 2030-02-09 09:20:19 2030-02-09 09:20:26  76.92664
      634       5          8.8 2030-02-09 09:20:27 2030-02-09 09:20:36  75.31730
      635       7         16.0 2030-02-09 09:20:38 2030-02-09 09:20:54  69.09450
      636       5          7.8 2030-02-09 09:20:55 2030-02-09 09:21:03  76.87300
      637       2          4.4 2030-02-09 09:21:04 2030-02-09 09:21:08  60.83320
      638       4          5.5 2030-02-09 09:21:09 2030-02-09 09:21:15  63.00582
      639       4          9.8 2030-02-09 09:21:15 2030-02-09 09:21:25  77.81178

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

