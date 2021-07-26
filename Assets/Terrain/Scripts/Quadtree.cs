using System;
using System.Collections.Generic;
using UnityEngine;

namespace MyTerrain
{
    public class QuadTree
    {
        public MyTerrain Terrain { get; private set; }

        public int m_NodeCount = 0;

        public int MaxDepth { get; private set; } = 0;
        public int LevelCount { get; private set; } = 0;

        public QuadTreeNode m_Root = null;

        public double[] m_LevelMaxDiameter;

        public QuadTree(MyTerrain terrain)
        {
            Terrain = terrain;
            MaxDepth = (int)Mathf.Log(TerrainSettings.TERRAIN_SIZE, 2) - (int)Mathf.Log(TerrainSettings.LEAF_NODE_SIZE, 2);
            LevelCount = MaxDepth + 1;

            InitializeLevelMaxDiameterArray();

            Bounds terrainBounds = new Bounds(new Vector3(0.5f, 0, 0.5f) * TerrainSettings.TERRAIN_SIZE, new Vector3(TerrainSettings.TERRAIN_SIZE, 10, TerrainSettings.TERRAIN_SIZE));
            m_Root = QuadTreeNodePool.GetNode();
            m_Root.Initialize(this, null, terrainBounds);
        }


        void InitializeLevelMaxDiameterArray()
        {
            m_LevelMaxDiameter = new double[LevelCount];

            double terrainDiagonal = Math.Sqrt((double)TerrainSettings.TERRAIN_SIZE * (double)TerrainSettings.TERRAIN_SIZE * 2.0f);
            for (int i = MaxDepth; i >= 0; i--)
            {
                m_LevelMaxDiameter[i] = terrainDiagonal / Math.Pow(2, i);
            }
        }


        public void CollectOldNodes()
        {
            CollectOldNodes(m_Root);
        }


        private int CollectOldNodes(QuadTreeNode node)
        {
            if (node == null)
                return 0;

            if (node.isLeaf || !node.hasBeenRefined)
            {
                return node.m_SelectionTimestamp;
            }

            int mostRecentlySelected = 0;

            for (int i = 0; i < 4; i++)
            {
                mostRecentlySelected = Math.Max(mostRecentlySelected, CollectOldNodes(node.m_Children[i]));
            }

            if (Time.frameCount - mostRecentlySelected > Terrain.COLLECTION_INTERVAL)
            {
                node.ReleaseChildren();
                return Time.frameCount;
            }

            return mostRecentlySelected;
        }


        public void Reset()
        {
            Bounds terrainBounds = m_Root.m_BoundsWorld;

            m_Root.Reset();
            
            m_Root.Initialize(this, null, terrainBounds);
        }
    }
}
