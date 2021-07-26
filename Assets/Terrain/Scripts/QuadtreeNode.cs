using UnityEngine;

namespace MyTerrain
{
    public class QuadTreeNode
    {
        private QuadTree m_QuadTree;
        private QuadTreeNode m_Parent = null;
        public QuadTreeNode[] m_Children = new QuadTreeNode[4];

        public int m_Depth;
        public int m_SelectionTimestamp;

        public Bounds m_BoundsWorld;
        public Vector4 m_BoundsXZMinSize;
        public float m_BoundsXZDiagonal;

        public float sqrDistanceToCamera;
        public Rect m_rectWorld;
        public bool isReadyForRendering = false;

        public const float DefaultMinHeight = -8000f;
        public const float DefaultMaxHeight = 8000f;

        public float m_MinHeight { get; private set; } = DefaultMinHeight;
        public float m_MaxHeight { get; private set; } = DefaultMaxHeight;

        public bool isLeaf => m_Depth == m_QuadTree.MaxDepth;
        public bool hasBeenRefined => m_Children[0] != null && m_Children[1] != null && m_Children[2] != null && m_Children[3] != null;

        public ComputeBuffer m_MinMaxBuffer;

        public MyTerrain Terrain
        {
            get
            {
                return m_QuadTree.Terrain;
            }
        }

        public Vector2 MinMaxViewRange()
        {
            return MyTerrain.Instance.m_TerrainLODSettings.viewRanges[m_Depth];
        }


        public Atlas.AtlasPageDescriptor HeightmapDescriptor { get; private set; }

        public Atlas.AtlasPageDescriptor NormalmapDescriptor { get; private set; }

        private void UpdateMaps()
        {
            if (!isReadyForRendering)
            {
                NormalmapDescriptor = NormalmapDescriptor ?? m_QuadTree.Terrain.m_NormalmapAtlas.GetPage();
                HeightmapDescriptor = HeightmapDescriptor ?? m_QuadTree.Terrain.m_HeightmapAtlas.GetPage();

                QuadtreeNodeGenerator.DispatchHeightmapKernel(this);
                QuadtreeNodeGenerator.DispatchNormalmapKernel(this);

                isReadyForRendering = true;
            }
        }


        public void Initialize(QuadTree quadtree, QuadTreeNode parent, Bounds bounds)
        {
            m_QuadTree = quadtree;
            m_QuadTree.m_NodeCount++;

            m_BoundsWorld = bounds;
            m_rectWorld = new Rect(new Vector2(m_BoundsWorld.min.x, m_BoundsWorld.min.z), new Vector2(m_BoundsWorld.size.x, m_BoundsWorld.size.z));
            m_Parent = parent;

            m_Depth = parent != null ? parent.m_Depth + 1 : 0;

            m_BoundsXZDiagonal = Mathf.Sqrt(2f * (m_BoundsWorld.extents.x * m_BoundsWorld.extents.x));

            m_MinMaxBuffer = new ComputeBuffer(2, sizeof(int));

            UpdateMaps();
        }


        public void UpdateMinMax(float minHeight, float maxHeight)
        {
            m_MinHeight = m_MinHeight == DefaultMinHeight ? minHeight : Mathf.Min(minHeight, m_MinHeight);
            m_MaxHeight = m_MaxHeight == DefaultMaxHeight ? maxHeight : Mathf.Max(maxHeight, m_MaxHeight);

            float height = (m_MaxHeight - m_MinHeight);
            float centerHeight = m_MinHeight + height / 2;

            Vector3 boundsCenter = new Vector3(m_BoundsWorld.center.x, centerHeight, m_BoundsWorld.center.z);
            Vector3 boundsSize = new Vector3(m_BoundsWorld.size.x, height, m_BoundsWorld.size.z);

            m_BoundsWorld = new Bounds(boundsCenter, boundsSize);

            m_BoundsXZMinSize = new Vector4(m_BoundsWorld.min.x, m_BoundsWorld.min.z, m_BoundsWorld.size.x, m_BoundsWorld.size.z);

            if (m_Parent != null)
                m_Parent.UpdateMinMax(m_MinHeight, m_MaxHeight);
        }



        public void Release()
        {
            Reset();

            m_Children = null;

            isReadyForRendering = false;
        }



        public void Reset()
        {
            ReleaseChildren();

            if (m_Parent != null)
            {
                for (int i = 0; i < 4; i++)
                {
                    if (m_Parent.m_Children[i] == this)
                        m_Parent.m_Children[i] = null;
                }
            }

            ReleaseHeightmap();
            ReleaseNormalmap();

            m_Parent = null;

            if (m_QuadTree != null)
                m_QuadTree.m_NodeCount--;
            m_QuadTree = null;

            m_MinHeight = DefaultMinHeight;
            m_MaxHeight = DefaultMaxHeight;

            m_MinMaxBuffer?.Release();
            m_MinMaxBuffer = null;

            isReadyForRendering = false;
        }


        public void ReleaseChildren()
        {
            if (hasBeenRefined)
            {
                for (int i = 0; i < 4; i++)
                {
                    QuadTreeNodePool.ReleaseNode(m_Children[i]);
                    m_Children[i] = null;
                }
            }
        }

        public void Refine()
        {
            for (int i = 0; i < 4; i++)
            {
                if (m_Children[i] == null)
                {
                    m_Children[i] = QuadTreeNodePool.GetNode();
                }

                Bounds childBounds;
                GetChildBounds(i, out childBounds);
                m_Children[i].Initialize(m_QuadTree, this, childBounds);
            }
        }


        private void GetChildBounds(int childIndex, out Bounds childBounds)
        {
            Vector3 extends = m_BoundsWorld.extents;
            Vector3 childrenSize = new Vector3(extends.x, 10, extends.z);
            Vector3 center = new Vector3(m_BoundsWorld.center.x, 0, m_BoundsWorld.center.z);
            Vector3 position;
            switch (childIndex)
            {
                case 0:
                    position = new Vector3(-extends.x, 0, -extends.z) / 2;
                    break;
                case 1:
                    position = new Vector3(-extends.x, 0, extends.z) / 2;
                    break;
                case 2:
                    position = new Vector3(extends.x, 0, extends.z) / 2;
                    break;
                case 3:
                    position = new Vector3(extends.x, 0, -extends.z) / 2;
                    break;
                default:
                    position = Vector3.zero;
                    break;
            }
            childBounds = new Bounds(center + position, childrenSize);
        }


        private void ReleaseHeightmap()
        {
            if (HeightmapDescriptor != null)
            {
                HeightmapDescriptor.Release();
                HeightmapDescriptor = null;
            }
        }


        private void ReleaseNormalmap()
        {
            if (NormalmapDescriptor != null)
            {
                NormalmapDescriptor.Release();
                NormalmapDescriptor = null;
            }
        }

    }
}