#define	PREC_COSTS

#if	defined(QUICK_MIN) && !defined(NUM_BEST)
#define	NUM_BEST	3
#endif

#if	defined(USE_SP_AUG_FORWARD) || defined(USE_SP_AUG_BACKWARD)
#ifndef	USE_SP_AUG
#define	USE_SP_AUG
#endif
#endif

#if	defined(USE_P_UPDATE) || defined(BACK_PRICE_OUT) || \
	defined(USE_SP_AUG_BACKWARD)
#define	STORE_REV_ARCS
#endif

typedef	struct	lhs_node	{
#if	defined(QUICK_MIN)
				struct	{
					/*
					flag used to indicate to
					double_push() that so few arcs
					are incident that best[] is
					useless.
					*/
#ifdef	QUICK_MIN
					unsigned	few_arcs : 1;
#endif
					}	node_info;
#ifdef	QUICK_MIN
				/*
				list of arcs to consider first in
				calculating the minimum-reduced-cost
				incident arc; if we find it here, we
				need look no further.
				*/
				struct	lr_arc	*best[NUM_BEST];
				/*
				bound on the reduced cost of an arc we
				can be certain still belongs among
				those in best[].
				*/
				double	next_best;
#endif
#endif
#ifdef	EXPLICIT_LHS_PRICES
				/*
				price of this node.
				*/
				double	p;
#endif
				/*
				first arc in the arc array associated
				with this node.
				*/
				struct	lr_arc	*priced_out;
				/*
				first priced-in arc in the arc array
				associated with this node.
				*/
				struct	lr_arc	*first;
				/*
				matching arc (if any) associated with
				this node; NULL if this node is
				unmatched.
				*/
				struct	lr_arc	*matched;
#if	defined(USE_P_UPDATE)
				/*
				price change required on this node (in
				units of epsilon) to ensure that its
				excess can reach a deficit in the
				admissible graph. computed and used in
				p_update().
				*/
				long	delta_reqd;
#endif
#ifdef	USE_SP_AUG_BACKWARD
				struct	lr_arc	*aug_path;
#endif
				}	*lhs_ptr;

typedef	struct	rhs_node	{
				struct	{
#ifdef	USE_P_REFINE
					/*
					depth-first search flags.
					dfs is to determine whether
					admissible graph contains a
					cycle in p_refine().
					*/
					unsigned	srchng : 1;
					unsigned	srched : 1;
#endif
					/*
					flag to indicate this node's
					matching arc (if any) is
					priced in.
					*/
					unsigned	priced_in : 1;
					}	node_info;
				/*
				lhs node this rhs node is matched to.
				*/
				lhs_ptr	matched;
				/*
				price of this node.
				*/
				double	p;
#ifdef	USE_SP_AUG_FORWARD
				struct	lr_arc	*aug_path;
#endif
#if	defined(USE_P_REFINE) || defined(USE_P_UPDATE) || defined(USE_SP_AUG)
				/*
				number of epsilons of price change
				required at this node to accomplish
				p_refine()'s or p_update()'s goal.
				*/
				long	key;
				/*
				fields to maintain buckets of nodes as
				lists in p_refine() and p_update().
				*/
				struct	rhs_node	*prev, *next;
#endif
#ifdef	STORE_REV_ARCS
				/*
				first back arc in the arc array
				associated with this node.
				*/
				struct	rl_arc	*priced_out;
				/*
				first priced-in back arc in the arc
				array associated with this node.
				*/
				struct	rl_arc	*back_arcs;
#endif
				}	*rhs_ptr;

#ifdef	STORE_REV_ARCS
typedef	struct	rl_arc		{
				/*
				lhs node associated with this back
				arc. some would have liked the name
				head better.
				*/
				lhs_ptr	tail;
#if	defined(USE_P_UPDATE) || defined(USE_SP_AUG_BACKWARD)
				/*
				cost of this back arc. this cost gets
				modified to incorporate other arc
				costs in p_update() and sp_aug(),
				while forward arc costs remain
				constant throughout.
				*/
				double	c;
#endif
#if	defined(USE_PRICE_OUT) || defined(USE_SP_AUG_BACKWARD)
				/*
				this arc's reverse in the forward arc
				list.
				*/
				struct	lr_arc	*rev;
#endif
				}	*rl_aptr;
#endif

typedef	struct	lr_arc		{
				/*
				rhs node associated with this arc.
				*/
				rhs_ptr	head;
				/*
				arc cost.
				*/
				double	c;
#ifdef	USE_SP_AUG_FORWARD
				lhs_ptr	tail;
#endif
#ifdef	STORE_REV_ARCS
				/*
				this arc's reverse in the back arc
				list.
				*/
				struct	rl_arc	*rev;
#endif
				}	*lr_aptr;

typedef	struct	stack_st	{
				/*
				Sometimes stacks have lhs nodes, and
				other times they have rhs nodes. So
				there's a little type clash;
				everything gets cast to (char *) so we
				can use the same structure for both.
				*/
				char	**bottom;
				char	**top;
				}	*stack;

typedef	struct	queue_st	{
				/*
				Sometimes queues have lhs nodes, and
				other times they have rhs nodes. So
				there's a little type clash;
				everything gets cast to (char *) so we
				can use the same structure for both.
				*/
				char		**head;
				char		**tail;
				char		**storage;
				char		**end;
				unsigned	max_size;
				}	*queue;
