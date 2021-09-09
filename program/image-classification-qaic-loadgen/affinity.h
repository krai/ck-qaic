#ifdef G292
#if !defined(G292_CONFB)
#define G292_CONFA
#endif
#endif

#if defined (G292_CONFB)
#define AFFINITY_CARD(i) \
  (i == 0? 4 : \
        i == 1? 68 : \
        i < 10? 64 + (i-1)*8 : (i-10)*8)
#elif defined (G292_CONFA)
#define AFFINITY_CARD(i) ((i > 7) * -64 + 64 + 8 * i)

#elif defined (R282)
#define AFFINITY_CARD(i) ((i < 8) ?  4 * i: 0)

#else
#define AFFINITY_CARD(i) (4 * i)
#endif
