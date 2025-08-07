import random , math
from node import Node

def insert_hnsw(hnsw, q, M, Mmax, ef_construction, Ml):
    W = set()   #nearest neighbors
    ep = hnsw.get_entry()  
    L = ep.layer   #level of entry (top)
    nl = math.floor(-math.log(random.uniform(0,1))*Ml)  #level of new entry

    for layer in range(L, nl, -1):
        W = search_layer(q, ep, 1, layer)
        ep = get_nearest(q,W)

    for layer in range(min(L, nl), -1, -1):
        W = search_layer(q, ep, ef_construction, layer)
        neighbors = select_neighbors(q, W, M, layer)  # Algo 3 or 4

        for neighbor in neighbors:
            hnsw.add_connection(q, neighbor, layer)
            hnsw.add_connection(neighbor, q, layer)

                # Shrink neighbor's connections if needed
            if len(hnsw.get_connections(neighbor, layer)) > Mmax:
                new_conns = select_neighbors(
                    neighbor, 
                    hnsw.get_connections(neighbor, layer), 
                    Mmax, 
                    layer
                )
            hnsw.set_connections(neighbor, new_conns, layer)

            ep = W

    if nl > L:
        hnsw.set_entry(q)
