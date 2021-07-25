# ProceduralTerrain

This is a project for creating procedural terrains using a combination of noises. These noises can be edited by an artist and saved for use in games.

AtlasTextures structures were used to store the heightmap and normalmap generated for the visible nodes of a quadtree. When a node is initialized, compute shader is dispatched to generate this data. During the heightmap generation, the noises are evaluated and added, resulting in the final height of the terrain. Rendering is done using GPU_Instancing of all nodes within the frustum.

To test, it is possible to open the MyTerrain scene and select the Terrain object. From this interface (image below), it is possible to add, remove and edit noises. The results obtained can be seen when starting the game. It is also possible to edit the values in play mode, and the results will be immediately reflected in the terrain.

Below are two terrains (2<sup>19</sup>x2<sup>19</sup>km each) quickly generated for testing.

![Screenshot](https://github.com/ffranzin/ProceduralTerrain/blob/af529f13becbd53d4f5e036d3003feb1decb3588/Assets/SampleImages/sample1.png?raw=true)

![Screenshot](https://github.com/ffranzin/ProceduralTerrain/blob/7ebfe8e330e046229e77727ee5ff87af51100258/Assets/SampleImages/sample2.png?raw=true)
