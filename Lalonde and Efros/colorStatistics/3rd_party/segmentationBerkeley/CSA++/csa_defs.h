#define	TRUE	1
#define	FALSE	0
#define	MAXLINE	100
#define	DEFAULT_SCALE_FACTOR	10
#define	DEFAULT_PO_COST_THRESH	(2.0 * sqrt((double) n) * \
				 sqrt(sqrt((double) n)))
#define	DEFAULT_PO_WORK_THRESH	50
#define	DEFAULT_UPD_FAC		2
#if	defined(USE_SP_AUG_FORWARD) || defined(USE_SP_AUG_BACKWARD)
#ifndef	USE_SP_AUG
#define	USE_SP_AUG
#endif
#endif

#ifdef	USE_SP_AUG
#define	EXCESS_THRESH	127
#else
#define	EXCESS_THRESH	0
#endif

#if	defined(USE_P_UPDATE) || defined(STRONG_PO)
#define	WORK_TYPE	unsigned
#define	REFINE_WORK	relabelings
#endif

#if	defined(DEBUG) && defined(ROUND_COSTS)
#define	MAGIC_MARKER	0xAAAAAAAA
#endif

#ifdef	QUEUE_ORDER
#define	ACTIVE_TYPE	queue
#define	create_active(size)	active = q_create(size)
#define	make_active(v)		enq(active, (char *) v)
#define	get_active_node(v)	v = (lhs_ptr) deq(active)
#else
#define	ACTIVE_TYPE	stack
#define	create_active(size)	active = st_create(size)
#define	make_active(v)		st_push(active, (char *) v)
#define	get_active_node(v)	v = (lhs_ptr) st_pop(active)
#endif

#define	st_push(s, el) \
{\
*(s->top) = (char *) el;\
s->top++;\
}

#define	st_empty(s)	(s->top == s->bottom)

#define	enq(q, el) \
{\
*(q->tail) = el;\
if (q->tail == q->end) q->tail = q->storage;\
else q->tail++;\
}

#define q_empty(q) (q->head == q->tail ? 1 : 0)

#define	insert_list(node, head) \
{\
node->next = (*(head));\
(*(head))->prev = node;\
(*(head)) = node;\
node->prev = tail_rhs_node;\
}

#define	delete_list(node, head) \
{\
if (node->prev == tail_rhs_node)\
  (*(head)) = node->next;\
node->prev->next = node->next;\
node->next->prev = node->prev;\
}

/*
The author hereby apologizes for the following incomprehensible
muddle. Price-outs involve moving arcs around in the data structure,
and it turns out to be faster to copy them field-by-field than to use
memcpy() because they're so small. But the set of fields an arc has
depends on lots of things, hence this mess.
*/

#if	defined(USE_PRICE_OUT) || defined(ROUND_COSTS)
#ifdef	STORE_REV_ARCS
#ifdef	ROUND_COSTS
#define	copy_lr_arc(a, b) \
{\
b->head = a->head;\
b->c_init = a->c_init;\
b->c = a->c;\
b->rev = a->rev;\
}
#else	/* ROUND_COSTS */
#define	copy_lr_arc(a, b) \
{\
b->head = a->head;\
b->c = a->c;\
b->rev = a->rev;\
}
#endif	/* ROUND_COSTS */

#ifdef	USE_P_UPDATE
#define	copy_rl_arc(a, b) \
	{ b->tail = a->tail; b->c = a->c; b->rev = a->rev; }
#else	/* USE_P_UPDATE */
#define	copy_rl_arc(a, b) \
	{ b->tail = a->tail; b->rev = a->rev; }
#endif	/* USE_P_UPDATE */

#define	exch_rl_arcs(a, b) \
{\
copy_rl_arc(b, tail_rl_arc);\
copy_rl_arc(a, b);\
copy_rl_arc(tail_rl_arc, a);\
}
#else	/* STORE_REV_ARCS */
#ifdef	PREC_COSTS
#define	copy_lr_arc(a, b) \
{\
b->head = a->head;\
b->c = a->c;\
}
#else	/* PREC_COSTS */
#define	copy_lr_arc(a, b) \
{\
b->head = a->head;\
b->c_init = a->c_init;\
b->c = a->c;\
}
#endif	/* PREC_COSTS */
#endif	/* STORE_REV_ARCS */

#define	exch_lr_arcs(a, b) \
{\
copy_lr_arc(b, tail_lr_arc);\
copy_lr_arc(a, b);\
copy_lr_arc(tail_lr_arc, a);\
}

extern	lr_aptr	tail_lr_arc;
#ifdef	STORE_REV_ARCS
extern	rl_aptr	tail_rl_arc;
#endif

#ifdef	STORE_REV_ARCS
#define	price_in_rev(a) \
{ \
register	rl_aptr	b_a = --a->head->back_arcs; \
register	rl_aptr	a_r = a->rev; \
if (b_a != a_r) \
  { \
  register	lr_aptr	b_r = b_a->rev; \
  exch_rl_arcs(b_a, a_r); \
  b_r->rev = a_r; \
  a->rev = b_a; \
  } \
}

#define	price_out_rev(a) \
{ \
register	rl_aptr	b_a = a->head->back_arcs; \
register	rl_aptr	a_r = a->rev; \
if (b_a != a_r) \
  { \
  register	lr_aptr	b_r = b_a->rev; \
  exch_rl_arcs(b_a, a_r); \
  b_r->rev = a_r; \
  a->rev = b_a; \
  } \
a->head->back_arcs++; \
}

#define	handle_rev_pointers(a, b)	{ a->rev->rev = b; b->rev->rev = a; }
#else	/* STORE_REV_ARCS */
#define	price_in_rev(a)		/* do nothing */
#define	price_out_rev(a)	/* do nothing */
#define	handle_rev_pointers(a, b)	/* do nothing */
#endif	/* STORE_REV_ARCS */

#define	price_in_unm_arc(v, a) \
{ \
register	lr_aptr	f_a = --v->first; \
price_in_rev(a); \
if (f_a != a) \
  { \
  if (v->matched == f_a) v->matched = a; \
  handle_rev_pointers(a, f_a); \
  exch_lr_arcs(a, f_a); \
  } \
}

#define	price_in_mch_arc(v, a) \
{ \
register	lr_aptr	f_a = --v->first; \
price_in_rev(a); \
a->head->node_info.priced_in = TRUE; \
if (f_a != a) \
  { \
  v->matched = f_a; \
  handle_rev_pointers(a, f_a); \
  exch_lr_arcs(a, f_a); \
  } \
}

#define	price_out_unm_arc(v, a) \
{ \
register	lr_aptr	f_a = v->first++; \
price_out_rev(a); \
if (f_a != a) \
  { \
  if (v->matched == f_a) v->matched = a; \
  handle_rev_pointers(a, f_a); \
  exch_lr_arcs(a, f_a); \
  } \
}

#define	price_out_mch_arc(v, a) \
{ \
register	lr_aptr	f_a = v->first++; \
price_out_rev(a); \
a->head->node_info.priced_in = FALSE; \
if (f_a != a) \
  { \
  v->matched = f_a; \
  handle_rev_pointers(a, f_a); \
  exch_lr_arcs(a, f_a); \
  } \
}
#endif	/* USE_PRICE_OUT || ROUND_COSTS */
