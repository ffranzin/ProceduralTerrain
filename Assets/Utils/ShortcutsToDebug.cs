using UnityEngine;

public class ShortcutsToDebug : MonoBehaviour
{
    public bool DEBUG_DISABLE_LOD_DISTANCE_CULLING = false;
    public bool DEBUG_DISABLE_LOD_FRUSTUM_CULLING = false;


    void Start()
    {
        Shader.SetGlobalInt("DEBUG_DISABLE_LOD_DISTANCE_CULLING", DEBUG_DISABLE_LOD_DISTANCE_CULLING ? 1 : 0);
        Shader.SetGlobalInt("DEBUG_DISABLE_LOD_FRUSTUM_CULLING", DEBUG_DISABLE_LOD_FRUSTUM_CULLING ? 1 : 0);
    }

    void Update()
    {
        if(Input.GetKey(KeyCode.D) && Input.GetKeyDown(KeyCode.Alpha1))
        {
            DEBUG_DISABLE_LOD_DISTANCE_CULLING = !DEBUG_DISABLE_LOD_DISTANCE_CULLING;
            Shader.SetGlobalInt("DEBUG_DISABLE_LOD_DISTANCE_CULLING", DEBUG_DISABLE_LOD_DISTANCE_CULLING ? 1 : 0);
            Debug.LogError("DEBUG_DISABLE_LOD_DISTANCE_CULLING " + DEBUG_DISABLE_LOD_DISTANCE_CULLING);
        }
        else if (Input.GetKey(KeyCode.D) && Input.GetKeyDown(KeyCode.Alpha2))
        {
            DEBUG_DISABLE_LOD_FRUSTUM_CULLING = !DEBUG_DISABLE_LOD_FRUSTUM_CULLING;
            Shader.SetGlobalInt("DEBUG_DISABLE_LOD_FRUSTUM_CULLING", DEBUG_DISABLE_LOD_FRUSTUM_CULLING ? 1 : 0);
            Debug.LogError("DEBUG_DISABLE_LOD_FRUSTUM_CULLING " + DEBUG_DISABLE_LOD_FRUSTUM_CULLING);
        }
    }
}
