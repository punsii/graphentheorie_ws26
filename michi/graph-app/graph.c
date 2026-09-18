#include "graph.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h> /* for memset */

#define GRAPH_ASSERT_INIT(graph)                                                                                       \
    assert(in_graph && "Graph is NULL");                                                                               \
    assert(in_graph->verts && "Graph was never initialized!");

#define GRAPH_ASSERT_DIMENSIONS(graph)                                                                                 \
    assert(x < in_graph->num_verts && "Graph does not contain that many vertices.");                                   \
    assert(y < in_graph->num_verts && "Graph does not contain that many vertices.");

void graph_create(Graph* out_graph, u32 num_verts)
{
    u32 num_verts_2      = num_verts * num_verts;
    out_graph->verts     = malloc(num_verts_2 * sizeof(Vertex));
    out_graph->num_verts = num_verts;
    memset(out_graph->verts, 0, num_verts_2 * sizeof(Vertex));
}

void graph_destroy(Graph* in_graph)
{
    GRAPH_ASSERT_INIT(in_graph);
    free(in_graph->verts);
    in_graph->num_verts = 0;
}

Vertex graph_get(const Graph* in_graph, u32 x, u32 y)
{
    GRAPH_ASSERT_INIT(in_graph);
    GRAPH_ASSERT_DIMENSIONS(in_graph);

    return in_graph->verts[ y * in_graph->num_verts + x ];
}

void graph_set(Graph* in_graph, u32 x, u32 y, Vertex v)
{
    GRAPH_ASSERT_INIT(in_graph);
    GRAPH_ASSERT_DIMENSIONS(in_graph);

    in_graph->verts[ y * in_graph->num_verts + x ] = v;
}

void graph_remove(Graph* in_graph, u32 x, u32 y)
{
    in_graph->verts[ y * in_graph->num_verts + x ] = (Vertex){ .id = 0 };
}

void graph_print(const Graph* in_graph)
{
    GRAPH_ASSERT_INIT(in_graph);

    for ( u32 y = 0; y < in_graph->num_verts; y++ )
    {
        for ( u32 x = 0; x < in_graph->num_verts; x++ )
        {
            Vertex v = graph_get(in_graph, x, y);
            printf("%d ", v.id);
        }
        printf("\n");
    }
}

void graph_create_mst(Graph* in_graph) {}
