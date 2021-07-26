using System.Collections.Generic;

namespace MyTerrain
{
    public static class QuadTreeNodePool
    {
        private const int POOL_SIZE = 2048;
        private static List<QuadTreeNode> pool;

        public static bool IsFull
        {
            get
            {
                return pool.Count >= POOL_SIZE;
            }
        }

        public static void InitializePool()
        {
            pool = new List<QuadTreeNode>();

            CreateNodes(POOL_SIZE);
        }

        private static void CreateNodes(int nodesCount)
        {
            for (int i = 0; i < nodesCount; i++)
            {
                pool.Add(new QuadTreeNode());
            }
        }

        public static QuadTreeNode GetNode()
        {
            if (pool.Count == 0)
            {
                CreateNodes(16);
            }

            QuadTreeNode node = pool[0];
            pool.RemoveAt(0);

            return node;
        }

        public static void ReleaseNode(QuadTreeNode node)
        {
            if (IsFull)
            {
                node.Release();
                return;
            }

            node.Reset();
            pool.Add(node);
        }

        public static void ReleasePool()
        {
            for (int i = 0; pool != null && i < pool.Count; i++)
            {
                if (pool[i] != null)
                {
                    pool[i]?.Release();
                    pool[i] = null;
                }
            }
        }
    }
}