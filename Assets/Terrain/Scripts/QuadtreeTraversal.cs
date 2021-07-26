using System.Collections.Generic;
using UnityEngine;
using Utils.Cameras;

namespace MyTerrain
{
    public static class QuadTreeTraversal
    {
        public static void TerrainNodeSelection(List<QuadTreeNode> selection, TerrainLODSettings settings)
        {
            if (selection != null && settings != null)
            {
                selection.Clear();

                TerrainNodeSelection(settings.Terrain.m_QuadTree.m_Root, selection, settings);
            }
        }


        private static void TerrainNodeSelection(QuadTreeNode node, List<QuadTreeNode> selection, TerrainLODSettings settings)
        {
            if (node == null || selection.Count >= selection.Capacity)
            {
                return;
            }

            node.m_SelectionTimestamp = Time.frameCount;

            if (!GeometryUtility.TestPlanesAABB(MainCamera.Instance.FrustumPlanes, node.m_BoundsWorld))
            {
                return;
                // selection.Add(node);
            }

            node.sqrDistanceToCamera = Mathf.Sqrt(node.m_BoundsWorld.SqrDistance(MainCamera.Instance.Camera.transform.position));

            // Only subdivide if this is not a leaf and it is out its of range
            if (!node.isLeaf && node.sqrDistanceToCamera < settings.viewRanges[node.m_Depth].x)
            {
                if (!node.hasBeenRefined)
                {
                    node.Refine();
                    selection.Add(node);
                }
                else
                {
                    for (int i = 0; i < 4; i++)
                    {
                        TerrainNodeSelection(node.m_Children[i], selection, settings);
                    }
                }
            }
            else
            {
                selection.Add(node);
            }
        }
    }
}
