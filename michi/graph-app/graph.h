/* Stuff to create graphs that can deal with euclidean distances. */

#ifndef GRAPH_H
#define GRAPH_H

#include <assert.h>

#include "common.h"

typedef struct Vertex
{
    i32 id;
    i32 pos_x;
    i32 pos_y;
} Vertex;

typedef struct Graph
{
    Vertex* verts;
    u32     num_verts;
} Graph;

void   graph_create(Graph* out_graph, u32 num_verts);
void   graph_destroy(Graph* in_graph);
Vertex graph_get(const Graph* in_graph, u32 x, u32 y);
void   graph_set(Graph* in_graph, u32 x, u32 y, Vertex v);
void   graph_remove(Graph* in_graph, u32 x, u32 y);
void   graph_print(const Graph* in_graph);
void   graph_create_mst(Graph* in_graph);

#endif
