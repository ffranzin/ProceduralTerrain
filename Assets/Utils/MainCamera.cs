using UnityEngine;


namespace Utils.Cameras
{
    public class MainCamera : Singleton<MainCamera>
    {
        public Plane[] FrustumPlanes { get; private set; }
        public Vector4[] FrustumPlanesNormals { get; private set; }

        private Camera m_Camera;
        public Camera Camera
        {
            get
            {
                return m_Camera;
            }
            set
            {
                m_Camera = value;
                UpdateFrustumPlanes();
            }
        }

        void Awake()
        {
            m_Camera = Camera.main;

            FrustumPlanes = new Plane[6];
            FrustumPlanesNormals = new Vector4[6];

            base.Awake();
        }

        private void UpdateFrustumPlanes()
        {
            GeometryUtility.CalculateFrustumPlanes(m_Camera, FrustumPlanes);

            for (int i = 0; i < 6; i++)
            {
                FrustumPlanesNormals[i] = FrustumPlanes[i].normal;
            }
        }


        private void FixedUpdate()
        {
            UpdateFrustumPlanes();
        }
    }
}